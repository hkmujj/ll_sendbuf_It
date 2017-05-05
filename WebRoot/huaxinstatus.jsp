<%@page import="java.security.GeneralSecurityException"%>
<%@page import="java.io.IOException"%>
<%@page import="com.taobao.api.Constants"%>
<%@page import="util.SHA1,
				util.MD5Util,
				net.sf.json.JSONArray,
				util.TimeUtils,
				http.HttpAccess,
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
%><%!
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
	boolean logflag = true;
	Logger logger = LogManager.getLogger();
	
	while(true){
		String ret = null;
		
		//获取公共参数
		
		String routeid = request.getAttribute("routeid").toString();

		
		Object idsobj = request.getAttribute("ids");
		if(idsobj == null){
			request.setAttribute("result", "S." + routeid + ":ids are needed to get status@" + TimeUtils.getSysLogTimeString());
			break;
		}
		
		String ids = idsobj.toString(); 
		
		logger.info("ids = " + ids + ", routeid = " + routeid);
		
		//获取通道能数, 每个通道不同
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
		String appid = routeparams.get("appid");
		if(appid == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, appid is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String accountId = routeparams.get("accountId");
		if(accountId == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, accountId is null@" + TimeUtils.getSysLogTimeString());
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
		String actionName = "flowRechargeStatus";//查询
		
		//发送请求前先准备好参数
		String[] idarray = ids.split(",");
		JSONObject obj = new JSONObject();
		
		for(int i = 0; i < idarray.length; i++){
			String value = idarray[i];
			String timestamp = TimeUtils.getTimeString();
			String key = secret + "appid" + appid + "productId" + productId + "reqId" + value 
					+ "sign_method" + "md5" + "timestamp" + timestamp + secret;
					
					
			logger.info("huaxinstatus key = " + key);
			
			String sign = null;
			try{
				sign = byte2hex(encryptMD5(key));
			}catch(IOException e){
				e.printStackTrace();
			}
	
			logger.info("huaxinstatus sign = " + sign);		
			
			JSONObject jsonParam = new JSONObject();  
			jsonParam.put("appid", appid);
			jsonParam.put("sign", sign);
			jsonParam.put("timestamp", timestamp);
			jsonParam.put("sign_method", "md5");
			jsonParam.put("reqId", value);
			jsonParam.put("productId", productId);
			
			String urla= url + "/custom/" + accountId + "/flowPackage/" + actionName;
			logger.info("huaxinstatus url = " + urla);
			logger.info("huaxinstatus jsonobj = " + jsonParam.toString());
			//发送查询/获取状态前先获取连接, 防止访问线程超量
			Cache.getStatusConnection(routeid);
			try {
				ret = HttpAccess.postJsonRequest(urla, jsonParam.toString(), "utf-8", "huaxinstatus");
			} catch (Exception e) {
				e.printStackTrace();
				logger.info(e.getMessage());
			} finally {
				//发送查询/获取状态后释放连接
				Cache.releaseStatusConnection(routeid);
			}
			
			//这里判断结果, 每个通道情况不同, 成功的节点ID对应success, 失败的对应失败信息
			if (ret != null && ret.trim().length() > 0) {
			logger.info("huaxin status ret = " + ret);
				
				try {
					JSONObject retjson = JSONObject.fromObject(ret);
					String retCode = retjson.getString("status");
					if(retCode.equals("3")){
						JSONObject rp = new JSONObject();
						rp.put("code", 0);
						rp.put("message", "success");
						rp.put("resp", ret);
						obj.put(idarray[i], rp);
					}else if(retCode.equals("4")){
						JSONObject rp = new JSONObject();
						rp.put("code", 1);
						rp.put("message", "失败");
						rp.put("resp", ret);
						obj.put(idarray[i], rp);
						logger.info("huaxin status : [" + idarray[i] + "]状态码" + retCode + ":" + "失败" + "@" + TimeUtils.getSysLogTimeString());
					}else{
						logger.info("huaxin status : [" + idarray[i] + "]充值中,状态码" + retCode + ":" + "充值中" + "@" + TimeUtils.getSysLogTimeString());
					}
				} catch (Exception e) {
					logger.warn(e.getMessage(), e);
					logger.info("huaxin status : " + e.getMessage() + ", ret = " + ret + "@" + TimeUtils.getSysLogTimeString());
				}
			} else {
				logger.info("huaxin status : " + "fail@" + TimeUtils.getSysLogTimeString());
			}
		}
	
		request.setAttribute("retjson", obj.toString());
		request.setAttribute("result", "success");
		
		break;
	}
	
	request.getRequestDispatcher("request.jsp").forward(request,response);
%>