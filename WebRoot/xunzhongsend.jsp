<%@page import="util.TimeUtils,
				http.HttpAccess,
				util.MD5Util,
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
	
	//获取公共参数
	String taskid = request.getAttribute("taskid").toString();
	String routeid = request.getAttribute("routeid").toString();
	String phone = request.getAttribute("phone").toString();
	String packageid = request.getAttribute("package").toString();
	
	while(true){
		String ret = null;
		
		//检查通道参数, 每个通道有不同参数, 对应 ll_routes.api_params(私有参数)
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
		String effectStartTime = routeparams.get("effectStartTime");
		if(effectStartTime == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, effectStartTime is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String effectTime = routeparams.get("effectTime");
		if(effectTime == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, effectTime is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String net = routeparams.get("net");
		if(net == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, net is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String action = "flowOrder";
		
		
		//参数准备, 每个通道不同
		StringBuffer flowCode = new StringBuffer();
		flowCode.append(net);
		String packagecode = null;
		try{
			packageid = packageid.split("\\.")[1];
			String pkstr = packageid.substring(0, packageid.length() - 1);
			int pk = Integer.parseInt(pkstr);
			if(packageid.indexOf('G') >= 0){
				pk *= 1024;
			}
			packagecode = String.valueOf(pk);
		} catch (Exception e) {
			logger.warn(e.getMessage(), 0);
		}
		
		if(packagecode == null){
			request.setAttribute("result", "S." + routeid + ":unrecognized package@" + TimeUtils.getSysLogTimeString());
			break;
		}
		
		while(true){
			if(packagecode.length() < 6){
				packagecode = "0" + packagecode;
			}else {
				break;
			}
		}
		
		logger.info("xunzhongsend packagecode = " + packagecode);
		flowCode.append(packagecode);
		flowCode.append("1");//第10位[1标准包 2红包 3快餐 4转增] 
		flowCode.append("0");//第11位 0全国漫游 1省内漫游 
		logger.info("xunzhongsend flowCode = " + flowCode);
		String time = TimeUtils.getTimeStamp();
		String Authorization = MyBase64.base64Encode(accountSID + "|" + time);
		String Sign = MD5Util.getLowerMD5(accountSID + authToken + time);
		String sendurl = url + "/" + version + "/sid/" + accountSID + "/" + func
							 + "/" + funcURL + "?Sign=" + Sign;
							 
		logger.info("xunzhongsendurl = " + sendurl);

		JSONObject obj = new JSONObject();
		obj.put("action", action);
		obj.put("appid", appid);
		obj.put("phone", phone);
		obj.put("flowCode", flowCode.toString());
		obj.put("effectStartTime", effectStartTime);
		obj.put("effectTime", effectTime);
		obj.put("customParm", taskid);
		logger.info("xunzhong send obj =" + obj.toString());
		
		LinkedHashMap<String, String> header = new LinkedHashMap<String, String>();
		header.put("Authorization", Authorization);
		
		try {
			ret = HttpAccess.postJsonRequest(sendurl, obj.toString(), "utf-8", header, "xunzhongsend");
			//ret = HttpAccess.postNameValuePairRequest(url, param,"application/x-www-form-urlencoded", "utf-8", "gdshangtong");
			//ret = HttpAccess.postJsonRequest(url, json.toString(), "utf-8", "weikesend");
			//ret = HttpAccess.getNameValuePairRequest(url, param, "utf-8", "mark");
		} catch (Exception e) {
			e.printStackTrace();
			logger.info(e.getMessage());
		}
	
		//这里判断结果, 每个通道情况不同, 成功的保存 success 到 result 中并返回到 request.jsp(ret为返回的结果)
		if (ret != null && ret.trim().length() > 0) {
			logger.info("xunzhong send ret = " + ret);
			try {
				JSONObject retjson = JSONObject.fromObject(ret);
				String retCode = retjson.getString("statusCode"); //":"0" 下单/订购成功
				
				if(retCode.equals("0")){
					request.setAttribute("result", "success");
					request.setAttribute("reportid", retjson.get("requestId"));
				}else{
					request.setAttribute("code", 1);
					String message = retjson.getString("statusMsg");
					request.setAttribute("result", "R." + routeid + ":" + retCode + ":" + message + "@" + TimeUtils.getSysLogTimeString());
				}
				request.setAttribute("orgreturn", ret);
			} catch (Exception e) {
				e.printStackTrace();
				logger.info(e.getMessage());
				request.setAttribute("result", "R." + routeid + ":" + e.getMessage() + "@" + TimeUtils.getSysLogTimeString());
			}
		} else {
			request.setAttribute("result", "R." + routeid + ":fail@" + TimeUtils.getSysLogTimeString());
		}
		
		break;
	}

	request.getRequestDispatcher("request.jsp").forward(request,response);
%>