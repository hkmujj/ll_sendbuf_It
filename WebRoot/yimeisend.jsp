<%@page import="util.AES,
				util.MD5Util,
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
		String appId = routeparams.get("appId");
		if(appId == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, appId is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String token = routeparams.get("token");
		if(token == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, token is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		
		//参数准备, 每个通道不同
		String packagecode = null;
		String packagetype=null;
		if(packageid.indexOf("yd.") > -1){
		packagetype="cmcc";
			try{
				packageid = packageid.split("\\.")[1];
			} catch (Exception e) {
				logger.warn(e.getMessage(), 0);
			}
			if(packageid.equals("10M")){
				packagecode = "11";
			}else if(packageid.equals("30M")){
				packagecode = "12";
			}else if(packageid.equals("70M")){
				packagecode = "13";
			}else if(packageid.equals("150M")){
				packagecode = "14";
			}else if(packageid.equals("500M")){
				packagecode = "15";
			}else if(packageid.equals("1G")){
				packagecode = "16";
			}else if(packageid.equals("2G")){
				packagecode = "17";
			}else if(packageid.equals("3G")){
				packagecode = "18";
			}else if(packageid.equals("4G")){
				packagecode = "19";
			}else if(packageid.equals("6G")){
				packagecode = "20";
			}else if(packageid.equals("11G")){
				packagecode = "21";
			}
		}else if(packageid.indexOf("lt.") > -1){
			packagetype="cucc";
			try{
				packageid = packageid.split("\\.")[1];
			} catch (Exception e) {
				logger.warn(e.getMessage(), 0);
			}
			if(packageid.equals("20M")){
				packagecode = "24";
			}else if(packageid.equals("50M")){
				packagecode = "9";
			}else if(packageid.equals("100M")){
				packagecode = "25";
			}
		}
		if(packagecode == null){
			request.setAttribute("result", "S." + routeid + ":unrecognized package@" + TimeUtils.getSysLogTimeString());
			break;
		}
		
		StringBuffer buffer = new StringBuffer();
		buffer.append("mobiles=" + phone).append("&taskNo=" + taskid).append("&"+packagetype+"=" + packagecode).append("&etype=0");

		String requestcode = buffer.toString();
		String key = MD5Util.getLowerMD5(requestcode);
		String value = AES.ymAesEncrypt(requestcode, token);
		
		Map<String, String> params = new HashMap<String, String>();
		params.put("key", key);
		params.put("value", value);
		params.put("appId", appId);
		
		//在执行请求前先获取连接, 防止访问通道线程超量
		Cache.getConnection(routeid);
		try {
			ret = HttpAccess.postNameValuePairRequest(url, params, "utf-8", "yimei");
		} catch (Exception e) {
			e.printStackTrace();
			logger.info(e.getMessage());
		} finally {
			//在执行请求后记得释放连接
			Cache.releaseConnection(routeid);
		}
	
		//这里判断结果, 每个通道情况不同, 成功的保存 success 到 result 中并返回到 request.jsp
		if (ret != null && ret.trim().length() > 0) {
			logger.info("yimei send ret = " + ret);
			try {
				JSONObject retjson = JSONObject.fromObject(ret);
				String code = retjson.getString("code");
				String mobileNumber = retjson.getString("mobileNumber");
				if(code != null && code.equals("M0001") && mobileNumber != null && mobileNumber.equals("1")){
					request.setAttribute("result", "success");
					request.setAttribute("reportid", retjson.getString("batchNo"));
				}else{
					request.setAttribute("code", 1);
					request.setAttribute("result", "R." + routeid + ":" + retjson.getString("msg") + "@" + TimeUtils.getSysLogTimeString());
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