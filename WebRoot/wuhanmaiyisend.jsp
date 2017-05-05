<%@page import="java.util.HashMap"%>
<%@page import="http.VResponseHandler"%>
<%@page import="java.util.Map.Entry"%>
<%@page import="org.apache.http.client.ResponseHandler"%>
<%@page import="org.apache.commons.codec.binary.Hex"%>
<%@page import="org.apache.commons.codec.binary.Base64"%>
<%@page import="java.security.GeneralSecurityException"%>
<%@page import="java.security.MessageDigest"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.util.Date"%>
<%@page import="net.sf.json.JSONObject,
				java.util.Map,
				util.TimeUtils,
				cache.Cache,
				org.apache.http.impl.client.HttpClients,
				org.apache.http.impl.client.CloseableHttpClient,
				java.net.URLDecoder,
				org.apache.logging.log4j.LogManager,
				java.io.BufferedReader,
				java.io.IOException,
				java.io.InputStream,
				java.io.InputStreamReader,
				java.io.UnsupportedEncodingException,
				java.nio.charset.Charset,
				java.util.ArrayList,
				java.util.List,
				org.apache.http.client.methods.HttpPost,
				org.apache.http.HttpResponse,
				org.apache.http.NameValuePair,
				org.apache.http.client.HttpClient,
				org.apache.http.client.entity.UrlEncodedFormEntity,
				org.apache.http.client.methods.HttpPost,
				org.apache.http.message.BasicNameValuePair,
				org.apache.http.protocol.HTTP,
				util.MD5Util,
				org.apache.logging.log4j.Logger"
		language="java" pageEncoding="UTF-8"
%><%!private static boolean logflag = true;
	private static Logger logger = LogManager.getLogger();

	public static String createAuthHead(String username, String authcode) {
		Date date = new Date();
		SimpleDateFormat simpleDateFormat = new SimpleDateFormat("yyyyMMddHHmmss");
		String timestamp = simpleDateFormat.format(date);
		String needHash = username + authcode + timestamp;
		byte[] md5result = md5(needHash.getBytes());
		String sign = encodeHex(md5result);
		String nameAndTimestamp = username + ":" + timestamp;
		return "sign=\"" + sign + "\",nonce=\""
				+ encodeBase64(nameAndTimestamp.getBytes()) + "\"";
	}


	public static String encodeBase64(byte[] input) {
		return Base64.encodeBase64String(input);
	}

	public static String encodeHex(byte[] input) {
		return Hex.encodeHexString(input);
	}

	public static byte[] md5(byte[] input) {
		return digest(input, "MD5", null, 1);
	}

	public static byte[] digest(byte[] input, String algorithm, byte[] salt, int iterations) {
		try {
			MessageDigest e = MessageDigest.getInstance(algorithm);
			if (salt != null) {
				e.update(salt);
			}
			byte[] result = e.digest(input);
			for (int i = 1; i < iterations; ++i) {
				e.reset();
				result = e.digest(result);
			}
			return result;
		} catch (GeneralSecurityException e) {
			throw new RuntimeException(e);
		}
	}
	
	public static String postNamevalveRequest(String url, Map<String, String> valuelist, String encode,Map<String, String> header,String mark){
		String bacTxt = null;
		HttpPost httppost = null;
		CloseableHttpClient httpclient = HttpClients.createDefault();
		try {
			httppost = new HttpPost(url);
			
			ResponseHandler<String> responseHandler = new VResponseHandler(mark);
			for(Entry<String, String> entry : header.entrySet()){
				httppost.setHeader(entry.getKey(), entry.getValue());
			}
			
            List<NameValuePair> values = new ArrayList<NameValuePair>();
            for(Entry<String, String> entry : valuelist.entrySet()){
            	values.add(new BasicNameValuePair(entry.getKey(), entry.getValue()));
            }
            
			httppost.setEntity(new UrlEncodedFormEntity(values, encode));

            
            bacTxt = httpclient.execute(httppost, responseHandler);
            
		} catch (Exception e) {
			StringBuffer sb = new StringBuffer();
			sb.append('[');
			sb.append(mark);
			sb.append("] Exception : ");
			sb.append(e.getMessage());
			logger.warn(sb.toString(), e);
		} finally {
			try {
				httppost.releaseConnection();
				httpclient.close();
			} catch (IOException e) {
				StringBuffer sb = new StringBuffer();
				sb.append('[');
				sb.append(mark);
				sb.append("] close httplicent Exception : ");
				sb.append(e.getMessage());
				logger.warn(sb.toString(), e);
			}
		}
		
		StringBuffer sb = new StringBuffer();
		sb.append('[');
		sb.append(mark);
		sb.append("] response text = ");
		sb.append(bacTxt);
		
		logger.info(sb.toString());
		
		return bacTxt;
	}
	
	%><%
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
		String username = routeparams.get("username");
		if (username == null) {
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, username is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String authcode = routeparams.get("authcode");
		if (authcode == null) {
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, authcode is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		
		
		//参数准备, 每个通道不同
		String packagecode = null;
		
		
			//湖北
			if(packageid.equals("dx.5M")){
				packagecode = "5";
			}else if(packageid.equals("dx.10M")){
				packagecode = "10";
			}else if(packageid.equals("dx.30M")){
				packagecode = "30";
			}else if(packageid.equals("dx.50M")){
				packagecode = "50";
			}else if(packageid.equals("dx.100M")){
				packagecode = "100";
			}else if(packageid.equals("dx.200M")){
				packagecode = "200";
			}else if(packageid.equals("dx.500M")){
				packagecode = "500";
			}else if(packageid.equals("dx.1G")){
				packagecode = "1024";
			}
		
		
		if(packagecode == null){
			request.setAttribute("result", "S." + routeid + ":unrecognized package@" + TimeUtils.getSysLogTimeString());
			break;
		}
		
		Map<String, String> headerlist=new HashMap<String, String>();
		
		String str = createAuthHead(username,authcode);
		
		headerlist.put("Content-Type", "application/x-www-form-urlencoded");
		headerlist.put("Authorization", str);
		Map<String, String> idlist=new HashMap<String, String>();
		idlist.put("mobile",phone);
		idlist.put("packet", packagecode);
		
		
		//在执行请求前先获取连接, 防止访问通道线程超量
		Cache.getConnection(routeid);
		try {
			//ret = HttpAccess.postNameValuePairRequest(url, params, "utf-8", "mysend");
			//ret = HttpAccess.postJsonRequest(url, json.toString(), "utf-8", "weikesend");
		 	//post.setEntity(new UrlEncodedFormEntity(param, HTTP.UTF_8));
		 	ret=postNamevalveRequest(url, idlist, "utf-8", headerlist, "maiyi");
		} catch (Exception e) {
			e.printStackTrace();
			logger.info("[maiyisend.jsp]headerlist="+headerlist.toString());
			logger.info(e.getMessage());
		} finally {
			//在执行请求后记得释放连接
			Cache.releaseConnection(routeid);
		}
	
		//这里判断结果, 每个通道情况不同, 成功的保存 success 到 result 中并返回到 request.jsp
		if (ret != null && ret.trim().length() > 0) {
			logger.info("maiyi send ret = " + ret);
			try {
				JSONObject retjson = JSONObject.fromObject(ret);
				String retCode = retjson.getString("status"); //":"MOB00001"
				Object obj = retjson.get("serial");
				String rpid = null;
				if(obj != null && obj.toString().trim().length() > 0){
					rpid = obj.toString();
				}
				String message = retjson.getString("message");
				if(retCode.equals("10000") && rpid != null){
					request.setAttribute("result", "success");
					request.setAttribute("reportid", rpid);
				}else{
					request.setAttribute("code", 1);
					request.setAttribute("result", "R." + routeid + ":" + message + "@" + TimeUtils.getSysLogTimeString());
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