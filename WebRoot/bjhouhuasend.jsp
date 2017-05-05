<%@page import="util.SHA1"%>
<%@page import="util.TimeUtils,
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
		String account = routeparams.get("account");
		if(account == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, account is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String key = routeparams.get("key");
		if(key == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, key is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		
		//参数准备, 每个通道不同
		String packagecode = null;
		try{
			packageid = packageid.split("\\.")[1];
		} catch (Exception e) {
			logger.warn(e.getMessage(), 0);
		}
		
		if(packageid.equals("10M")){
			packagecode = "00010";
		}else if(packageid.equals("30M")){
			packagecode = "00030";
		}else if(packageid.equals("70M")){
			packagecode = "00070";
		}else if(packageid.equals("150M")){
			packagecode = "00150";
		}else if(packageid.equals("500M")){
			packagecode = "00500";
		}else if(packageid.equals("1G")){
			packagecode = "01024";
		}else if(packageid.equals("2G")){
			packagecode = "02048";
		}else if(packageid.equals("3G")){
			packagecode = "03072";
		}else if(packageid.equals("4G")){
			packagecode = "04096";
		}else if(packageid.equals("6G")){
			packagecode = "06144";
		}
		
		if(packagecode == null){
			request.setAttribute("result", "S." + routeid + ":unrecognized package@" + TimeUtils.getSysLogTimeString());
			break;
		}
		
		String t = String.valueOf(System.currentTimeMillis());
		String timestamp = t.substring(0, t.length() - 3);
		String noncestr = t.substring(t.length() - 6);
		String signstr = "amount=" + packagecode + "&mobile=" + phone + "&noncestr=" + noncestr + 
				"&order_id=" + taskid + "&timestamp=" + timestamp + "&uname=" + account + "&key=" + key;
		//System.out.println("signstr = " + signstr);
		String signature = SHA1.sha1Encode(signstr).toLowerCase();
		
		JSONObject json = new JSONObject();
		json.put("amount", packagecode);
		json.put("mobile", phone);
		json.put("noncestr", noncestr);
		json.put("order_id", taskid);
		json.put("timestamp", timestamp);
		json.put("uname", account);
		json.put("signature", signature);
		
		logger.info("bjhouhua send json = " + json.toString());
		
		//在执行请求前先获取连接, 防止访问通道线程超量
		Cache.getConnection(routeid);
		try {
			ret = HttpAccess.postJsonRequest(url, json.toString(), "utf-8", "bjhouhua");
		} catch (Exception e) {
			e.printStackTrace();
			logger.info(e.getMessage());
		} finally {
			//在执行请求后记得释放连接
			Cache.releaseConnection(routeid);
		}
	
		//这里判断结果, 每个通道情况不同, 成功的保存 success 到 result 中并返回到 request.jsp
		if (ret != null && ret.trim().length() > 0) {
			logger.info("bjhouhua send ret = " + ret);
			try {
				JSONObject retjson = JSONObject.fromObject(ret);
				String code = retjson.getString("errcode");
				if(code.equals("0")){
					request.setAttribute("result", "success");
					request.setAttribute("reportid", retjson.getString("order_id"));
				}else{
					request.setAttribute("code", code);
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