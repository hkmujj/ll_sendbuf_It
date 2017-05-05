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
		String AppId = routeparams.get("AppId");
		if(AppId == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, AppId is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String AppSecret = routeparams.get("AppSecret");
		if(AppSecret == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, AppSecret is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		
		//发送请求前先准备好参数
		String[] idarray = ids.split(",");
		JSONObject obj = new JSONObject();
		
		for(int i = 0; i < idarray.length; i++){
			String value = idarray[i];
			String Sig = "AppId=" + AppId + "OutOrderNum=" + value + AppSecret;
			Sig = MD5Util.getUpperMD5(Sig);		
			
			HashMap<String, String> param = new HashMap<String, String>();
			param.put("AppId", AppId);
			param.put("OutOrderNum", value);
			param.put("Sig", Sig);

			//发送查询/获取状态前先获取连接, 防止访问线程超量
			Cache.getStatusConnection(routeid);
			try {
				 ret = HttpAccess.postNameValuePairRequest(rpurl, param, "utf-8", "aosaistatus");
				//ret = HttpAccess.getNameValuePairRequest(url, param, "utf-8", "gzyunsheng");
			} catch (Exception e) {
				e.printStackTrace();
				logger.info(e.getMessage());
			} finally {
				//发送查询/获取状态后释放连接
				Cache.releaseStatusConnection(routeid);
			}
			
			//这里判断结果, 每个通道情况不同, 成功的节点ID对应success, 失败的对应失败信息
			if (ret != null && ret.trim().length() > 0) {
			logger.info("aosai status ret = " + ret);
				
				try {
					JSONObject retjson = JSONObject.fromObject(ret);
					String retCode = retjson.getString("code");
					JSONObject odobj = retjson.getJSONObject("data");
					
					if(retCode.equals("0") && odobj.getString("orderStatus").equals("2")){
						JSONObject rp = new JSONObject();
						rp.put("code", 0);
						rp.put("message", "success");
						rp.put("resp", ret);
						obj.put(idarray[i], rp);
					}else if(retCode.equals("0") && odobj.getString("orderStatus").equals("0") || odobj.getString("orderStatus").equals("1")){
						logger.info("gdshangtong status : [" + idarray[i] + "]充值中@" + TimeUtils.getSysLogTimeString());
					}else if(odobj.getString("failReason").length() > 0){
						JSONObject rp = new JSONObject();
						rp.put("code", 1);
						String message = odobj.getString("failReason");
						rp.put("message", message);
						rp.put("resp", ret);
						obj.put(idarray[i], rp);
						logger.info("aosai status : [" + idarray[i] + "]状态码" + retCode + ":" + message + "@" + TimeUtils.getSysLogTimeString());
					}else {
						JSONObject rp = new JSONObject();
						rp.put("code", 1);
						String message = retjson.getString("message");
						rp.put("message", message);
						rp.put("resp", ret);
						obj.put(idarray[i], rp);
						logger.info("aosai status : [" + idarray[i] + "]状态码" + retCode + ":" + message + "@" + TimeUtils.getSysLogTimeString());
					}
				} catch (Exception e) {
					logger.warn(e.getMessage(), e);
					logger.info("aosai status : " + e.getMessage() + ", ret = " + ret + "@" + TimeUtils.getSysLogTimeString());
				}
			} else {
				logger.info("aosai status : " + "fail@" + TimeUtils.getSysLogTimeString());
			}
		}
	
		request.setAttribute("retjson", obj.toString());
		request.setAttribute("result", "success");
		
		break;
	}
	
	request.getRequestDispatcher("request.jsp").forward(request,response);
%>