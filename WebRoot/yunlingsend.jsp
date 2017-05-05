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
		
		String sendurl = routeparams.get("sendurl");
		if(sendurl == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, sendurl is null@" + TimeUtils.getSysLogTimeString());
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
		if(packageid.equals("yd.10M")){
			packagecode = "CMP-GD-LL-10M";
		}else if(packageid.equals("yd.30M")){
			packagecode = "CMP-GD-LL-30M";
		}else if(packageid.equals("yd.70M")){
			packagecode = "CMP-GD-LL-70M";
		}else if(packageid.equals("yd.150M")){
			packagecode = "CMP-GD-LL-150M";
		}else if(packageid.equals("yd.500M")){
			packagecode = "CMP-GD-LL-500M";
		}else if(packageid.equals("yd.1G")){
			packagecode = "CMP-GD-LL-1G";
		}else if(packageid.equals("yd.2G")){
			packagecode = "CMP-GD-LL-2G";
		}else if(packageid.equals("yd.3G")){
			packagecode = "CMP-GD-LL-3G";
		}else if(packageid.equals("yd.4G")){
			packagecode = "CMP-GD-LL-4G";
		}else if(packageid.equals("yd.6G")){
			packagecode = "CMP-GD-LL-6G";
		}else if(packageid.equals("yd.11G")){
			packagecode = "CMP-GD-LL-11G";
		}	
		
		if(packagecode == null){
			request.setAttribute("result", "S." + routeid + ":unrecognized package@" + TimeUtils.getSysLogTimeString());
			break;
		}
		
		String sign = "account" + account + "mobile" + phone + "product_id" + packagecode + "query_code"
						 + taskid + "key" + key;
		sign = MD5Util.getLowerMD5(sign);
		
		logger.info("yunlingsend sign = " + sign);

		JSONObject obj = new JSONObject();
		obj.put("account", account);
		obj.put("mobile", phone);
		obj.put("product_id", packagecode);
		obj.put("query_code", taskid);
		obj.put("sign", sign);

		//在执行请求前先获取连接, 防止访问通道线程超量
		Cache.getConnection(routeid);
		try {
			//ret = HttpAccess.postNameValuePairRequest(url, param,"application/x-www-form-urlencoded", "utf-8", "gdshangtong");
			//ret = HttpAccess.postJsonRequest(url, json.toString(), "utf-8", "weikesend");
			//ret = HttpAccess.getNameValuePairRequest(url, param, "utf-8", "hualeihuisend");
			  ret = HttpAccess.postJsonRequest(sendurl, obj.toString(), "utf-8", "yunlingsend");
		} catch (Exception e) {
			e.printStackTrace();
			logger.error(e.getMessage() ,e);
		} finally {
			//在执行请求后记得释放连接
			Cache.releaseConnection(routeid);
		}
	
		//这里判断结果, 每个通道情况不同, 成功的保存 success 到 result 中并返回到 request.jsp(ret为返回的结果)
		if (ret != null && ret.trim().length() > 0) {
			logger.info("yunling send ret = " + ret);


			try {
				JSONObject retjson = JSONObject.fromObject(ret);
				String retCode = retjson.getString("err_code"); //":"0000" 下单/订购成功
				
				if(retCode.equals("0")){
					request.setAttribute("result", "success");
				}else{
					request.setAttribute("code", retCode);
					String message = retjson.getString("err_msg");
				 	request.setAttribute("result", "R." + routeid + ":" + retCode + ":" + message + "@" + TimeUtils.getSysLogTimeString());
				}
				request.setAttribute("orgreturn", ret);
			} catch (Exception e) {
				e.printStackTrace();
				logger.error(e.getMessage(),e);
				request.setAttribute("result", "R." + routeid + ":" + e.getMessage() + "@" + TimeUtils.getSysLogTimeString());
			}
		} else {
			request.setAttribute("result", "R." + routeid + ":fail@" + TimeUtils.getSysLogTimeString());
		}
		
		break;
	}

	request.getRequestDispatcher("request.jsp").forward(request,response);
%>