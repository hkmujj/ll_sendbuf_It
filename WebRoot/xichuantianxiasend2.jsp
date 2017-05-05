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
		String password = routeparams.get("password");
		if(password == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, password is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String flowType = routeparams.get("flowType");//填写3
		if(flowType == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, flowType is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String isRepeatOrder = routeparams.get("isRepeatOrder");//填写0
		if(isRepeatOrder == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, isRepeatOrder is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String range = routeparams.get("range");//0是全国，1是省内
		if(range == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, range is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String smsid = routeparams.get("smsid");
		if(smsid == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, smsid is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		
		//参数准备, 每个通道不同
		String packagecode = null;
		packageid = packageid.substring(3);
		if(range.equals("0")){
			//0是全国，1是省内
			if(packageid.equals("5M")){
				packagecode = "100017125";
			}else if(packageid.equals("10M")){
				packagecode = "100017126";
			}else if(packageid.equals("30M")){
				packagecode = "100017127";
			}else if(packageid.equals("50M")){
				packagecode = "100017128";
			}else if(packageid.equals("200M")){
				packagecode = "100017129";
			}else if(packageid.equals("100M")){
				packagecode = "100017130";
			}else if(packageid.equals("500M")){
				packagecode = "100017131";
			}else if(packageid.equals("1G")){
				packagecode = "100017132";
			}
		}else if(range.equals("1")){
			//0是全国，1是省内
			if(packageid.equals("500M")){
				packagecode = "100012326";
			}else if(packageid.equals("10M")){
				packagecode = "100012327";
			}else if(packageid.equals("100M")){
				packagecode = "100012328";
			}else if(packageid.equals("30M")){
				packagecode = "100012329";
			}else if(packageid.equals("220M")){
				packagecode = "100012330";
			}
		}
		
		if(packagecode == null){
			request.setAttribute("result", "S." + routeid + ":unrecognized package@" + TimeUtils.getSysLogTimeString());
			break;
		}
		/*
		HashMap<String, String> param = new HashMap<String, String>();
		param.put("taskid", taskid);
		param.put("url", url);
		param.put("account", account);
		param.put("password", password);
		param.put("phone", phone);
		param.put("productCode", packagecode);
		param.put("flowType", flowType);
		param.put("isRepeatOrder", isRepeatOrder);
		param.put("smsid", smsid);
		*/
		//在执行请求前先获取连接, 防止访问通道线程超量
		Cache.getConnection(routeid);
		try {
			//ret = HttpAccess.postNameValuePairRequest(url, param,"application/x-www-form-urlencoded", "utf-8", "gdshangtong");
			//ret = HttpAccess.postJsonRequest(url, json.toString(), "utf-8", "weikesend");
			//ret = HttpAccess.getNameValuePairRequest(url, param, "utf-8", "mark");
			//ret = HttpAccess.postNameValuePairRequest(url, param, "utf-8", "xichuantianxiasend");
			
			//request.setAttribute("taskid", taskid);
			//request.setAttribute("url", url);
			//request.setAttribute("account", account);
			//request.setAttribute("password", password);
			//request.setAttribute("phone", phone);
			//request.setAttribute("productCode", packagecode);
			//request.setAttribute("flowType", flowType);
			//request.setAttribute("isRepeatOrder", isRepeatOrder);
			//request.setAttribute("smsid", smsid);
			HashMap<String, String> param = new HashMap<String, String>();
			param.put("taskid", taskid);
			param.put("sendurl", sendurl);
			param.put("account", account);
			param.put("password", password);
			param.put("phone", phone);
			param.put("productCode", packagecode);
			param.put("flowType", flowType);
			param.put("isRepeatOrder", isRepeatOrder);
			param.put("smsid", smsid);
			
			
			//request.getRequestDispatcher("../ll_client/WebRoot/sendret.jsp").forward(request,response);
			String rxurl = "http://10.169.118.24:9122/ll_client/sendret.jsp";
			//String rxurl = "http://127.0.0.1:8080/ll_client/sendret.jsp";
			ret = HttpAccess.postNameValuePairRequest(rxurl, param, "utf-8", "xichuantianxiasend");
			//ret = request.getAttribute("ret").toString();
		} catch (Exception e) {
			e.printStackTrace();
			logger.info(e.getMessage());
		} finally {
			//在执行请求后记得释放连接
			Cache.releaseConnection(routeid);
		}
	
		//这里判断结果, 每个通道情况不同, 成功的保存 success 到 result 中并返回到 request.jsp(ret为返回的结果)
		if (ret != null && ret.trim().length() > 0) {
			logger.info("xichuantianxiasend ret = " + ret);

			try {
				JSONObject retjson = JSONObject.fromObject(ret);
				String resultCode = retjson.getString("resultCode"); 
				
				Object odobj = retjson.get("sessionId");
				
				if(resultCode.equals("0") && odobj != null){
					request.setAttribute("result", "success");
					request.setAttribute("reportid", TimeUtils.getTimeStamp() + "." + odobj.toString());
				}else{
					request.setAttribute("code", 1);
					String message = "zx fail";
					if(retjson.get("resultDesc") != null){
						message = retjson.getString("resultDesc");
					}	
					request.setAttribute("result", "R." + routeid + ":" + resultCode + ":" + message + "@" + TimeUtils.getSysLogTimeString());
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