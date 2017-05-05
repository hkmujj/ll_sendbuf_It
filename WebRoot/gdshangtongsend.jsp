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
		String account = routeparams.get("account");
		if(account == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, account is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String apiKey = routeparams.get("apiKey");
		if(apiKey == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, apiKey is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String range = routeparams.get("range");
		if(range == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, range is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String action = "Charge";
		
		
		//参数准备, 每个通道不同
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
		
		String timeStamp = "" + (System.currentTimeMillis() / 1000);
		String sign = apiKey + "account=" + account + "&action=" + action + "&phone=" +
						phone + "&range=" + range + "&size=" + packagecode + "&timeStamp=" +
						timeStamp + apiKey;
				sign = MD5Util.getLowerMD5(sign);

		HashMap<String, String> param = new HashMap<String, String>();
		param.put("account", account);
		param.put("action", action);
		param.put("phone", phone);
		param.put("size", packagecode);
		param.put("range", range);
		param.put("timeStamp", timeStamp);
		//param.put("orderNo", taskid);//附加参数
		param.put("sign", sign);
		
		//在执行请求前先获取连接, 防止访问通道线程超量
		Cache.getConnection(routeid);
		try {
			ret = HttpAccess.postNameValuePairRequest(url, param,"application/x-www-form-urlencoded", "utf-8", "gdshangtong");
			//ret = HttpAccess.postJsonRequest(url, json.toString(), "utf-8", "weikesend");
			//ret = HttpAccess.getNameValuePairRequest(url, param, "utf-8", "mark");
		} catch (Exception e) {
			e.printStackTrace();
			logger.info(e.getMessage());
		} finally {
			//在执行请求后记得释放连接
			Cache.releaseConnection(routeid);
		}
	
		//这里判断结果, 每个通道情况不同, 成功的保存 success 到 result 中并返回到 request.jsp(ret为返回的结果)
		if (ret != null && ret.trim().length() > 0) {
			logger.info("gdshangtong send ret = " + ret);


			try {
				JSONObject retjson = JSONObject.fromObject(ret);
				String retCode = retjson.getString("respCode"); //":"0000" 下单/订购成功
				
				Object odobj = retjson.get("orderID");
				
				if(retCode.equals("0000") && odobj != null){
					request.setAttribute("result", "success");
					request.setAttribute("reportid", odobj.toString());
				}else{
					request.setAttribute("code", 1);
					//将返回结果的message转为中文
					String message = retjson.getString("respMsg");
					message = message.replace("\\\\u", "\\u");
					
					if(message.indexOf("\\u") > -1)
					{
			    		StringBuffer string = new StringBuffer();
			 
			    		String[] hex = message.split("\\\\u");
			 
			    		for (int i = 1; i < hex.length; i++) {
			       		 // 转换出每一个代码点
			       		 int data = Integer.parseInt(hex[i], 16);
			        	 // 追加成string
			       		 string.append((char) data);
			       		 }
			       		 message = string.toString();
			   		 }
		   							
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