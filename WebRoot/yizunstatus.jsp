<%@page import="org.dom4j.Element"%>
<%@page import="org.dom4j.DocumentHelper"%>
<%@page import="org.dom4j.Document"%>
<%@page import="util.SHA1,
				util.MD5Util,
				net.sf.json.JSONArray,
				util.TimeUtils,
				http.HttpAccess,
				cache.Cache,
				net.sf.json.JSONException,
				net.sf.json.JSONObject,
				java.util.*,
				util.MyStringUtils,
				java.net.URLDecoder,
				org.apache.logging.log4j.LogManager,
				org.apache.logging.log4j.Logger,
				util.MyBase64,
				java.security.MessageDigest,
				java.security.NoSuchAlgorithmException,
				java.io.UnsupportedEncodingException"
		language="java" pageEncoding="UTF-8"
%><%

	out.clearBuffer();
	boolean logflag = true;
	Logger logger = LogManager.getLogger();
	
	while(true){
		String ret = null;
		
		//获取公共参数
		
		String routeid = request.getAttribute("routeid").toString();

		
		Object idsobj = request.getAttribute("ids");
		if(idsobj == null){
			request.setAttribute("result", "S." + routeid + ":ids are needed to get status@" + TimeUtils.getSysLogTimeString());
			break;
		}
		
		String ids = idsobj.toString(); 
		
		logger.info("ids = " + ids + ", routeid = " + routeid);
		
		//获取通道能数, 每个通道不同
		Map<String, String> routeparams = Cache.getRouteParams(routeid);
		if(routeparams == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams@" + TimeUtils.getSysLogTimeString());
			break;
		}
		
		String rpurl = routeparams.get("rpurl");
		if(rpurl == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, rpurl is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String userId = routeparams.get("userId");
		if(userId == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, userId is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String privatekey = routeparams.get("privatekey");
		if(privatekey == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, privatekey is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		
		//发送请求前先准备好参数
		String[] idarray = ids.split(",");
		JSONObject obj = new JSONObject();
		
		for(int i = 0; i < idarray.length; i++){
			String value = idarray[i];
			String sig = value + userId + privatekey;
			String sign = MD5Util.getLowerMD5(sig);	
			logger.info("yizunstatus 加密前: " + sig);
			logger.info("yizunstatus 加密后: " + sign);
			
			HashMap<String, String> param = new HashMap<String, String>();
			param.put("userId", userId);
			param.put("serialno", value);
			param.put("sign", sign);
			
			logger.info("yizunstatus 参数: " + param);

			//发送查询/获取状态前先获取连接, 防止访问线程超量
			Cache.getStatusConnection(routeid);
			try {
				//ret = HttpAccess.postNameValuePairRequest(rpurl, param, "utf-8", "gdshangtongstatus.jsp");
				ret = HttpAccess.getNameValuePairRequest(rpurl, param, "utf-8", "yizunstatus");
			} catch (Exception e) {
				e.printStackTrace();
				logger.warn(e.getMessage(), e);
			} finally {
				//发送查询/获取状态后释放连接
				Cache.releaseStatusConnection(routeid);
			}
			
			//这里判断结果, 每个通道情况不同, 成功的节点ID对应success, 失败的对应失败信息
			if (ret != null && ret.trim().length() > 0) {
			logger.info("yizun status ret = " + ret);
				
				try {
					Document retDocument = DocumentHelper.parseText(ret);
					Element responseElement = retDocument.getRootElement();
					Element codeElement = responseElement.element("code");
					String codeValue = codeElement.getText();
					if(codeValue.equals("00")){
						Element dataElement = responseElement.element("data");
						Element statusElement = dataElement.element("status");
						Element DescElement = dataElement.element("statusDesc");
						
						String retCode = statusElement.getText();
						String message = DescElement.getText();
						if(retCode.equals("2")){
							JSONObject rp = new JSONObject();
							rp.put("code", 0);
							rp.put("message", "success");
							rp.put("resp", ret);
							obj.put(idarray[i], rp);
						}else if(retCode.equals("3")){
							JSONObject rp = new JSONObject();
							rp.put("code", 1);
							rp.put("message", message);
							rp.put("resp", ret);
							obj.put(idarray[i], rp);
							logger.info("yizun status : [" + idarray[i] + "]状态码" + retCode + ":" + message + "@" + TimeUtils.getSysLogTimeString());
						}else{
							logger.info("yizun status : [" + idarray[i] + "]充值中,状态码" + retCode + ":" + message + "@" + TimeUtils.getSysLogTimeString());
						}
					}else{
						logger.info("yizun status : [" + idarray[i] + "]查询状态失败,失败码code" + codeValue + "@" + TimeUtils.getSysLogTimeString());
					}
				} catch (Exception e) {
					logger.warn(e.getMessage(), e);
					logger.info("yizun status : " + e.getMessage() + ", ret = " + ret + "@" + TimeUtils.getSysLogTimeString());
				}
			} else {
				logger.info("yizun status : " + "fail@" + TimeUtils.getSysLogTimeString());
			}
		}
	
		request.setAttribute("retjson", obj.toString());
		request.setAttribute("result", "success");
		
		break;
	}
	
	request.getRequestDispatcher("request.jsp").forward(request,response);
%>