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
		
		String url = routeparams.get("url");
		if(url == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, url is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String accountSID = routeparams.get("accountSID");
		if(accountSID == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, accountSID is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String authToken = routeparams.get("authToken");
		if(authToken == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, authToken is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String version = routeparams.get("version");
		if(version == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, version is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String func = routeparams.get("func");
		if(func == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, func is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String funcURL = routeparams.get("funcURL");
		if(funcURL == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, funcURL is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String appid = routeparams.get("appid");
		if(appid == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, appid is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String action = "getTrafficResult";
		
		//发送请求前先准备好参数
		String[] idarray = ids.split(",");
		JSONObject obj = new JSONObject();
		
		for(int i = 0; i < idarray.length; i++){
			String value = idarray[i];
			String time = TimeUtils.getTimeStamp();
			String Authorization = MyBase64.base64Encode(accountSID + "|" + time);
			String Sign = MD5Util.getLowerMD5(accountSID + authToken + time);
			String rpurl = url + "/" + version + "/sid/" + accountSID + "/" + func
							 + "/" + funcURL + "?Sign=" + Sign;		
			
			JSONObject jsobj = new JSONObject();
			jsobj.put("action", action);
			jsobj.put("appid", appid);
			jsobj.put("requestId", value);
			logger.info("xunzhong status jsobj =" + jsobj.toString());
			
			LinkedHashMap<String, String> header = new LinkedHashMap<String, String>();
			header.put("Authorization", Authorization);

			//发送查询/获取状态前先获取连接, 防止访问线程超量
			Cache.getStatusConnection(routeid);
			try {
				ret = HttpAccess.postJsonRequest(rpurl, jsobj.toString(), "utf-8", header, "xunzhongstatus");
				//ret = HttpAccess.postNameValuePairRequest(rpurl, param, "utf-8", "gdshangtongstatus.jsp");
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
			logger.info("xunzhong status ret = " + ret);
				
				try {
					JSONObject retjson = JSONObject.fromObject(ret);
					String retCode = retjson.getString("trafficSts");
					
					if(retCode.equals("1")){
						JSONObject rp = new JSONObject();
						rp.put("code", 0);
						rp.put("message", "success");
						rp.put("resp", ret);
						obj.put(idarray[i], rp);
					}else if(retCode.equals("0")){
						logger.info("xunzhong status : [" + idarray[i] + "]充值中@" + TimeUtils.getSysLogTimeString());
					}else {
						JSONObject rp = new JSONObject();
						rp.put("code", 1);
						String message = retjson.getString("remark");
						rp.put("message", message);
						rp.put("resp", ret);
						obj.put(idarray[i], rp);
						logger.info("xunzhong status : [" + idarray[i] + "]状态码" + retCode + ":" + message + "@" + TimeUtils.getSysLogTimeString());
					}
				} catch (Exception e) {
					logger.warn(e.getMessage(), e);
					logger.info("xunzhong status : " + e.getMessage() + ", ret = " + ret + "@" + TimeUtils.getSysLogTimeString());
				}
			} else {
				logger.info("xunzhong status : " + "fail@" + TimeUtils.getSysLogTimeString());
			}
		}
	
		request.setAttribute("retjson", obj.toString());
		request.setAttribute("result", "success");
		
		break;
	}
	
	request.getRequestDispatcher("request.jsp").forward(request,response);
%>