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
		String channelNo = routeparams.get("channelNo");
		if(channelNo == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, channelNo is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String key = routeparams.get("key");
		if(key == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, key is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		
		//参数准备, 每个通道不同
		String packagecode = null;
		if(packageid.equals("dx.10M")){
			packagecode = "QGDXZL10M";
		}else if(packageid.equals("dx.30M")){
			packagecode = "QGDXZL30M";
		}else if(packageid.equals("dx.50M")){
			packagecode = "QGDXZL50M";
		}else if(packageid.equals("dx.100M")){
			packagecode = "QGDXZL100M";
		}else if(packageid.equals("dx.200M")){
			packagecode = "QGDXZL200M";
		}else if(packageid.equals("dx.500M")){
			packagecode = "QGDXZL500M";
		}else if(packageid.equals("dx.1G")){
			packagecode = "QGDXZL1G";
		}
		
		if(packagecode == null){
			request.setAttribute("result", "S." + routeid + ":unrecognized package@" + TimeUtils.getSysLogTimeString());
			break;
		}
		
		String requesttime = TimeUtils.getTimeStamp();
		String sig = "channelNo=" + channelNo + "&msisdn=" + phone  + "&orderno=" + taskid + "&productid="
				+ packagecode + "&requesttime=" + requesttime + "&key=" + key;
				
		logger.info("加密前sign = " + sig);
		String sign = MD5Util.getLowerMD5(sig);
		sign = MyBase64.base64Encode(sign);
		logger.info("加密后sign = " + sign);
				

		HashMap<String, String> param = new HashMap<String, String>();
		param.put("channelNo", channelNo);
		param.put("msisdn", phone);
		param.put("productid", packagecode);
		param.put("requesttime", requesttime);
		param.put("orderno", taskid);
		param.put("sign", sign);
		
		//在执行请求前先获取连接, 防止访问通道线程超量
		Cache.getConnection(routeid);
		try {
			logger.info("zhangyitongsend value=" + param);
			ret = HttpAccess.postNameValuePairRequest(sendurl, param, "utf-8", "zhangyitongsend");
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
			logger.info("zhangyitong send ret = " + ret);


			try {
				JSONObject retjson = JSONObject.fromObject(ret);
				String retCode = retjson.getString("resultcode"); //":"0" 下单/订购成功
				String orderno = retjson.getString("orderno");
				if(retCode.equals("0")){
					request.setAttribute("result", "success");
					request.setAttribute("reportid", orderno);
				}else{
					request.setAttribute("code", 1);
					String message = retCode;
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