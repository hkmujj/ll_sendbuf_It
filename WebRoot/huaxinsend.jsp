<%@page import="java.io.IOException"%>
<%@page import="java.security.GeneralSecurityException"%>
<%@page import="com.taobao.api.Constants"%>
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
%>
<%!
	public	static	byte[]	encryptMD5(String	data)	throws	IOException	{
		byte[]	bytes	=	null;
		try	{
			MessageDigest	md	=	MessageDigest.getInstance("MD5");
			bytes	=	md.digest(data.getBytes(Constants.CHARSET_UTF8));
		}	catch	(GeneralSecurityException	gse)	{
				System.out.println(gse.getMessage());
			}
		return	bytes;	
	}
	
	public	static	String	byte2hex(byte[]	bytes)	{
		StringBuilder	sign	=	new	StringBuilder();
		for	(int	i	=	0;	i	<	bytes.length;	i++)	{
			String	hex	=	Integer.toHexString(bytes[i]	&	0xFF);
			if	(hex.length()	==	1)	{
				sign.append("0");
			}
			sign.append(hex.toUpperCase());
		}
		return	sign.toString();
	}

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
		
		String url = routeparams.get("url");
		if(url == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, url is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String accountId = routeparams.get("accountId");
		if(accountId == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, accountId is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String appid = routeparams.get("appid");
		if(appid == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, appid is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String secret = routeparams.get("secret");
		if(secret == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, secret is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String productId = routeparams.get("productId");
		if(productId == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, productId is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String actionName = "flowRecharge";//充值
		
		
		//参数准备, 每个通道不同
		String packagecode = null;//对应文档的productbingdingId
		if(routeid.equals("2069") ){
		//全国联通
			if(packageid.equals("lt.20M")){
				packagecode = "200001";
			}else if(packageid.equals("lt.50M")){
				packagecode = "200002";
			}else if(packageid.equals("lt.100M")){
				packagecode = "200003";
			}else if(packageid.equals("lt.200M")){
				packagecode = "200004";
			}else if(packageid.equals("lt.500M")){
				packagecode = "200005";
			}
		}else if(routeid.equals("2173")){
		if(packageid.equals("lt.30M")){
				packagecode = "200006";
			}else if(packageid.equals("lt.300M")){
				packagecode = "200007";
			}else if(packageid.equals("lt.1G")){
				packagecode = "200008";
			}
		
		}else if(routeid.equals("1196")){
				//全国移动
			if(packageid.equals("yd.10M")){
				packagecode = "100001";
			}else if(packageid.equals("yd.30M")){
				packagecode = "100002";
			}else if(packageid.equals("yd.50M")){
				packagecode = "1000021";
			}else if(packageid.equals("yd.70M")){
				packagecode = "100003";
			}else if(packageid.equals("yd.100M")){
				packagecode = "1000031";
			}else if(packageid.equals("yd.150M")){
				packagecode = "100004";
			}else if(packageid.equals("yd.200M")){
				packagecode = "1000041";
			}else if(packageid.equals("yd.500M")){
				packagecode = "100005";
			}else if(packageid.equals("yd.20M")){
				packagecode = "100012";
			}else if(packageid.equals("yd.1G")){
				packagecode = "100006";
			}else if(packageid.equals("yd.2G")){
				packagecode = "100007";
			}else if(packageid.equals("yd.3G")){
				packagecode = "100008";
			}else if(packageid.equals("yd.4G")){
				packagecode = "100009";
			}else if(packageid.equals("yd.6G")){
				packagecode = "100010";
			}else if(packageid.equals("yd.11G")){
				packagecode = "100011";
			}
		}else if(routeid.equals("1210")){
				//全国移动
			if(packageid.equals("yd.30M")){
				packagecode = "100002";
			}else if(packageid.equals("yd.70M")){
				packagecode = "100003";
			}else if(packageid.equals("yd.150M")){
				packagecode = "100004";
			}else if(packageid.equals("yd.300M")){
				packagecode = "1000051";
			}
		}else if(routeid.equals("3203")){
				//全国电信
			if(packageid.equals("dx.5M")){
				packagecode = "300001";
			}else if(packageid.equals("dx.10M")){
				packagecode = "300002";
			}else if(packageid.equals("dx.30M")){
				packagecode = "300003";
			}else if(packageid.equals("dx.50M")){
				packagecode = "300004";
			}else if(packageid.equals("dx.100M")){
				packagecode = "300005";
			}else if(packageid.equals("dx.200M")){
				packagecode = "300006";
			}else if(packageid.equals("dx.500M")){
				packagecode = "300007";
			}else if(packageid.equals("dx.1G")){
				packagecode = "300008";
			}
		}
		
		
		if(packagecode == null){
			request.setAttribute("result", "S." + routeid + ":unrecognized package@" + TimeUtils.getSysLogTimeString());
			break;
		}
		
		String timestamp = TimeUtils.getTimeString();
		String key = secret + "appid" + appid + "phone" + phone + "productId" + productId 
				+ "reqId" + taskid + "sign_method" 
				+ "md5" + "standardfeeid" + packagecode + "timestamp" + timestamp + secret;
				
		logger.info("huaxinsend key = " + key);
		
		String sign = null;
		try{
			sign = byte2hex(encryptMD5(key));
		}catch(IOException e){
			e.printStackTrace();
		}

		logger.info("huaxinsend sign = " + sign);
		
		JSONObject jsonParam = new JSONObject();  
		jsonParam.put("appid", appid);
		jsonParam.put("sign", sign);
		jsonParam.put("timestamp", timestamp);
		jsonParam.put("sign_method", "md5");
		jsonParam.put("phone", phone);
		jsonParam.put("standardfeeid", packagecode);
		jsonParam.put("productId", productId);
		jsonParam.put("reqId", taskid);
		jsonParam.put("callbackUrl", "null");
		
		url = url + "/custom/" + accountId + "/flowPackage/" + actionName;
		logger.info("huaxinsend url = " + url);
		logger.info("huaxinsend jsonobj = " + jsonParam.toString());
		//在执行请求前先获取连接, 防止访问通道线程超量
		Cache.getConnection(routeid);
		try {
			ret = HttpAccess.postJsonRequest(url, jsonParam.toString(), "utf-8", "huaxinsend");
		} catch (Exception e) {
			e.printStackTrace();
			logger.info(e.getMessage());
		} finally {
			//在执行请求后记得释放连接
			Cache.releaseConnection(routeid);
		}
	
		//这里判断结果, 每个通道情况不同, 成功的保存 success 到 result 中并返回到 request.jsp(ret为返回的结果)
		if (ret != null && ret.trim().length() > 0) {
			logger.info("huaxin send ret = " + ret);


			try {
				JSONObject retjson = JSONObject.fromObject(ret);
				String retCode = retjson.getString("errorCode"); //":"0" 下单成功
				
				if(retCode.equals("0")){
					request.setAttribute("result", "success");
				}else{
					request.setAttribute("code", 1);
					request.setAttribute("result", "R." + routeid + ":" + retCode + "@" + TimeUtils.getSysLogTimeString());
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