<%@page import="util.SHA1,
				util.AES,
				util.TimeUtils,
				http.HttpAccess,
				cache.Cache,
				net.sf.json.JSONException,
				net.sf.json.JSONObject,
				java.util.*,
				util.MyStringUtils,
				java.net.URLDecoder,
				org.apache.logging.log4j.LogManager,
				org.apache.logging.log4j.Logger" 
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
		
		//检查通道参数, 每个通道有不同参数, 对应 ll_routes.api_params
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
		String appkey = routeparams.get("appkey");
		if(appkey == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, appkey is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String appsecret = routeparams.get("appsecret");
		if(appsecret == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, appsecret is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		
		//参数准备, 每个通道不同
		String packagecode = null;
		try{
			packageid = packageid.split("\\.")[1];
		} catch (Exception e) {
			logger.warn(e.getMessage(), 0);
		}
		
		if(packageid.equals("20M")){
			packagecode = "002000";
		}else if(packageid.equals("50M")){
			packagecode = "000501";
		}else if(packageid.equals("100M")){
			packagecode = "001000";
		}else if(packageid.equals("200M")){
			packagecode = "002001";
		}else if(packageid.equals("500M")){
			packagecode = "005000";
		}else if(packageid.equals("1G")){
			packagecode = "0001G1";
		}
		
		if(packagecode == null){
			request.setAttribute("result", "S." + routeid + ":unrecognized package@" + TimeUtils.getSysLogTimeString());
			break;
		}
		
		String action = "orderPkg";
		String timeStamp = TimeUtils.getTimeStamp();
		
		StringBuffer sb = new StringBuffer();
		sb.append("action");
		sb.append(action);
		sb.append("appKey");
		sb.append(appkey);
		sb.append("phoneNo");
		sb.append(phone);
		sb.append("pkgNo");
		sb.append(packagecode);
		sb.append("timeStamp");
		sb.append(timeStamp);
		String sign = SHA1.sha1Encode(appsecret + sb.toString() + appsecret);
		
		System.out.println("sign = " + sign);
		
		Map<String, String> params = new HashMap<String, String>();
		params.put("action", action);
		params.put("appKey", appkey);
		params.put("phoneNo", phone);
		params.put("pkgNo", packagecode);
		params.put("timeStamp", timeStamp);
		params.put("sign", sign);
		
		//在执行请求前先获取连接, 防止访问通道线程超量
		Cache.getConnection(routeid);
		try {
			//ret = HttpAccess.postNameValuePairRequest(url, params, "utf-8", "mysend");
			ret = HttpAccess.postNameValuePairRequest(url, params, "utf-8", "ltkuandai");
		} catch (Exception e) {
			e.printStackTrace();
			logger.info(e.getMessage());
		} finally {
			//在执行请求后记得释放连接
			Cache.releaseConnection(routeid);
		}
	
		//这里判断结果, 每个通道情况不同, 成功的保存 success 到 result 中并返回到 request.jsp
		if (ret != null && ret.trim().length() > 0) {
			logger.info("ltkuandai send ret = " + ret);
			try {
				JSONObject retjson = JSONObject.fromObject(ret);
				String code = retjson.getString("respCode");
				if(code.equals("0000")){
					request.setAttribute("result", "success");
					request.setAttribute("reportid", retjson.getString("orderId"));
				}else{
					request.setAttribute("code", code);
					request.setAttribute("result", "R." + routeid + ":" + code + "@" + TimeUtils.getSysLogTimeString());
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