<%@page import="org.dom4j.Element"%>
<%@page import="org.dom4j.DocumentHelper"%>
<%@page import="org.dom4j.Document"%>
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
	out.clearBuffer();
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
		String userId = routeparams.get("userId");
		if(userId == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, userId is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String privatekey = routeparams.get("privatekey");
		if(privatekey == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, privatekey is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		
		//参数准备, 每个通道不同
		String packagecode = null;
		try{
			if(routeid.equals("1169")){
			//广东移动
				if(packageid.equals("yd.10M")){
					packagecode = "16606";
				}else if(packageid.equals("yd.30M")){
					packagecode = "16600";
				}else if(packageid.equals("yd.70M")){
					packagecode = "16607";
				}else if(packageid.equals("yd.150M")){
					packagecode = "16602";
				}else if(packageid.equals("yd.500M")){
					packagecode = "16603";
				}else if(packageid.equals("yd.1G")){
					packagecode = "16604";
				}else if(packageid.equals("yd.2G")){
					packagecode = "16605";
				}else if(packageid.equals("yd.3G")){
					packagecode = "16608";
				}else if(packageid.equals("yd.4G")){
					packagecode = "16609";
				}else if(packageid.equals("yd.6G")){
					packagecode = "16954";
				}else if(packageid.equals("yd.11G")){
					packagecode = "16955";
				}
			}else if(routeid.equals("1168")){
			//全国移动
				if(packageid.equals("yd.10M")){
					packagecode = "15293";
				}else if(packageid.equals("yd.30M")){
					packagecode = "15295";
				}else if(packageid.equals("yd.70M")){
					packagecode = "15294";
				}else if(packageid.equals("yd.150M")){
					packagecode = "15296";
				}else if(packageid.equals("yd.500M")){
					packagecode = "15297";
				}else if(packageid.equals("yd.1G")){
					packagecode = "15298";
				}else if(packageid.equals("yd.2G")){
					packagecode = "15299";
				}else if(packageid.equals("yd.3G")){
					packagecode = "15300";
				}else if(packageid.equals("yd.4G")){
					packagecode = "15305";
				}else if(packageid.equals("yd.6G")){
					packagecode = "16580";
				}else if(packageid.equals("yd.11G")){
					packagecode = "16581";
				}
			}
		} catch (Exception e) {
			logger.warn(e.getMessage(), e);
		}
		
		if(packagecode == null){
			request.setAttribute("result", "S." + routeid + ":unrecognized package@" + TimeUtils.getSysLogTimeString());
			break;
		}
		
		String dtCreate = TimeUtils.getTimeStamp();//time
		String sig = dtCreate + packagecode + taskid + phone + userId + privatekey;
		String sign = MD5Util.getLowerMD5(sig);
		logger.info("yizun 加密前: " + sig);
		logger.info("yizun 加密后: " + sign);

		HashMap<String, String> param = new HashMap<String, String>();
		param.put("userId", userId);
		param.put("itemId", packagecode);
		param.put("uid", phone);
		param.put("serialno", taskid);
		param.put("dtCreate", dtCreate);
		param.put("sign", sign);
		
		logger.info("yizun 参数: " + param);
		
		//在执行请求前先获取连接, 防止访问通道线程超量
		Cache.getConnection(routeid);
		try {
			//ret = HttpAccess.postJsonRequest(url, json.toString(), "utf-8", "weikesend");
			ret = HttpAccess.getNameValuePairRequest(sendurl, param, "utf-8", "yizunsend");
		} catch (Exception e) {
			e.printStackTrace();
			logger.warn(e.getMessage(), e);
		} finally {
			//在执行请求后记得释放连接
			Cache.releaseConnection(routeid);
		}
	
		//这里判断结果, 每个通道情况不同, 成功的保存 success 到 result 中并返回到 request.jsp(ret为返回的结果)
		if (ret != null && ret.trim().length() > 0) {
			logger.info("yizun ret = " + ret);


			try {
				Document retDocument = DocumentHelper.parseText(ret);
				Element responseElement = retDocument.getRootElement();
				Element codeElement = responseElement.element("code");
				Element descElement = responseElement.element("desc");
				
				String resultCode = codeElement.getText();
				logger.info("yizunsend resultCode = " + resultCode);
				String descMessage = descElement.getText();
				logger.info("yizunsend descMessage = " + descMessage);

				if(resultCode.equals("00")){
					request.setAttribute("result", "success");
					//request.setAttribute("reportid", retjson.getString("order_id"));//默认为我们的订单号
				}else{
					request.setAttribute("code", 1);	
				 	request.setAttribute("result", "R." + routeid + ":" + resultCode + ":" + descMessage + "@" + TimeUtils.getSysLogTimeString());
				}
				request.setAttribute("orgreturn", ret);
			} catch (Exception e) {
				e.printStackTrace();
				logger.warn(e.getMessage(), e);
				request.setAttribute("result", "R." + routeid + ":" + e.getMessage() + "@" + TimeUtils.getSysLogTimeString());
			}
		} else {
			request.setAttribute("result", "R." + routeid + ":fail@" + TimeUtils.getSysLogTimeString());
		}
		
		break;
	}

	request.getRequestDispatcher("request.jsp").forward(request,response);
%>