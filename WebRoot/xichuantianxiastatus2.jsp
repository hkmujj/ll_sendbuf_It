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
		String account = routeparams.get("account");
		if(account == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, account is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String password = routeparams.get("password");
		if(password == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, password is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		
		//发送请求前先准备好参数
		String[] idarray = ids.split(",");
		JSONObject obj = new JSONObject();
		
		for(int i = 0; i < idarray.length; i++){
			String value = idarray[i];

			//发送查询/获取状态前先获取连接, 防止访问线程超量
			//Cache.getStatusConnection(routeid);
			try {
				//request.setAttribute("rpurl", rpurl);
				//request.setAttribute("account", account);
				//request.setAttribute("password", password);
				//request.setAttribute("sessionId", value);
				
				HashMap<String, String> param = new HashMap<String, String>();
				param.put("rpurl", rpurl);
				param.put("account", account);
				param.put("password", password);
				param.put("sessionId", value);
				
				ret = HttpAccess.postNameValuePairRequest("http://10.169.118.24:9122/ll_client/statusret.jsp", param, "utf-8", "xichuantianxiastatus");
				//request.getRequestDispatcher("../ll_client/WebRoot/statusret.jsp").forward(request,response);
				//ret = request.getAttribute("statusret").toString();
			} catch (Exception e) {
				e.printStackTrace();
				logger.info(e.getMessage());
			} finally {
				//发送查询/获取状态后释放连接
				//Cache.releaseStatusConnection(routeid);
			}
			
			//这里判断结果, 每个通道情况不同, 成功的节点ID对应success, 失败的对应失败信息
			if (ret != null && ret.trim().length() > 0) {
			logger.info("xichuantianxia status ret = " + ret);
				
				try {
					JSONObject retjson = JSONObject.fromObject(ret);
					String retCode = retjson.getString("status");
					String message = retjson.getString("msg");
					if(retCode.equals("0")){
						JSONObject rp = new JSONObject();
						rp.put("code", 0);
						rp.put("message", "success");
						rp.put("resp", ret);
						obj.put(idarray[i], rp);
					}else if(retCode.equals("2")){
						JSONObject rp = new JSONObject();
						rp.put("code", 1);
						//将返回结果的message转为中文
						if(message.length() > 128){
							message = message.substring(0, 128);
						}
						rp.put("message", message);
						rp.put("resp", ret);
						obj.put(idarray[i], rp);
						logger.info("xichuantianxia status : [" + idarray[i] + "]状态码" + retCode + ":" + message + "@" + TimeUtils.getSysLogTimeString());
					}else{
						logger.info("xichuantianxia status : [" + idarray[i] + "]充值中,状态码" + retCode + ":" + message + "@" + TimeUtils.getSysLogTimeString());
					}
				} catch (Exception e) {
					logger.warn(e.getMessage(), e);
					logger.info("xichuantianxia status : " + e.getMessage() + ", ret = " + ret + "@" + TimeUtils.getSysLogTimeString());
				}
			} else {
				logger.info("xichuantianxia status : " + "fail@" + TimeUtils.getSysLogTimeString());
			}
		}
	
		request.setAttribute("retjson", obj.toString());
		request.setAttribute("result", "success");
		
		break;
	}
	
	request.getRequestDispatcher("request.jsp").forward(request,response);
%>