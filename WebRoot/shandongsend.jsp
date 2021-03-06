<%@page import="org.apache.http.conn.ssl.NoopHostnameVerifier"%>
<%@page import="javax.net.ssl.TrustManager"%>
<%@page import="javax.net.ssl.SSLContext"%>
<%@page import="http.MyX509TrustManager"%>
<%@page import="org.dom4j.Element"%>
<%@page import="org.dom4j.DocumentHelper"%>
<%@page import="org.dom4j.Document"%>
<%@page import="java.security.MessageDigest"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="org.apache.commons.httpclient.URIException"%>
<%@page import="java.io.InputStreamReader"%>
<%@page import="org.apache.commons.httpclient.HttpStatus"%>
<%@page import="java.io.BufferedReader"%>
<%@page import="org.apache.commons.httpclient.util.URIUtil"%>
<%@page import="org.apache.commons.httpclient.methods.GetMethod"%>
<%@page import="org.apache.commons.httpclient.HttpMethod"%>
<%@page import="org.apache.commons.httpclient.HttpClient"%>
<%@page import="java.io.IOException"%>
<%@page import="org.apache.http.entity.StringEntity"%>
<%@page import="java.util.Map.Entry"%>
<%@page import="http.VResponseHandler"%>
<%@page import="org.apache.http.client.ResponseHandler"%>
<%@page import="org.apache.http.client.config.RequestConfig"%>
<%@page import="org.apache.http.impl.client.HttpClients"%>
<%@page import="org.apache.http.impl.client.CloseableHttpClient"%>
<%@page import="org.apache.http.client.methods.HttpPost"%>
<%@page import="util.MD5Util"%>
<%@page import="util.TimeUtils,
				http.HttpAccess,
				cache.Cache,
				java.util.*,
				util.MyStringUtils,
				java.net.URLDecoder,
				org.apache.logging.log4j.LogManager,
				org.apache.logging.log4j.Logger"
	language="java" pageEncoding="UTF-8"%>
<%!public static boolean logflag = true;
	public static Logger logger = LogManager.getLogger();

	public static String Encrypt(String strSrc) {
		MessageDigest md = null;
		String strDes = null;

		byte[] bt = strSrc.getBytes();
		try{
			md = MessageDigest.getInstance("SHA-256");
			md.update(bt);
			strDes = bytes2Hex(md.digest()); // to HexString
		}catch(Exception e){
			return null;
		}
		return strDes;
	}

	public static String bytes2Hex(byte[] bts) {
		String des = "";
		String tmp = null;
		for(int i = 0; i < bts.length; i++){
			tmp = (Integer.toHexString(bts[i] & 0xFF));
			if(tmp.length() == 1){
				des += "0";
			}
			des += tmp;
		}
		return des;
	}

	public static String gettoken(String appKey, String appSecret, String url) {
		String sign = "";
		SimpleDateFormat s = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS");
		String ret = "";
		try{
			String time = s.format(new Date());
			//String time1 = time.substring(0, 23);
			//String time2 = time.substring(26, 32);
			String time3 = time + "+08:00";

			sign = appKey + time3 + appSecret;
			sign = Encrypt(sign);
			Document document = DocumentHelper.createDocument();
			Element requestElement = document.addElement("Request");

			Element datetimeElement = requestElement.addElement("Datetime");
			Element authorizationElement = requestElement.addElement("Authorization");

			Element appKeyElement = authorizationElement.addElement("AppKey");
			Element signElement = authorizationElement.addElement("Sign");

			datetimeElement.setText(time3);
			appKeyElement.setText(appKey);
			signElement.setText(sign);
			logger.info("shandongll gettoken xml =" + document.asXML());
			LinkedHashMap<String, String> header = new LinkedHashMap<String, String>();
			header.put("4GGOGO-Auth-Token", sign);//4GGOGO-Auth-Token  HTTP-X-4GGOGO-Signature
			ret = postXmlRequest(url, document.asXML(), "utf-8", header, "shandongll");
			logger.info("shandongll gettoken ret = " + ret);
			if(ret == null){
				return "";
			}
			Document doc = DocumentHelper.parseText(ret);
			Element responseElement = doc.getRootElement();

			Element autElement = responseElement.element("Authorization");
			Element tokenElement = autElement.element("Token");
			String token = tokenElement.getText();
			logger.info("shandongll token =" + token + ",time=" + time);
			return token;
		}catch(Exception e){
			e.printStackTrace();
			logger.info("shandongll gettoken", e);
		}
		return ret;
	}

	public static String doGet(String url, String queryString, String token, String signatrue, String charset, boolean pretty) {
		StringBuffer response = new StringBuffer();
		HttpClient client = new HttpClient();
		HttpMethod method = new GetMethod(url);

		try{
			method.setQueryString(URIUtil.encodeQuery(queryString));

			method.addRequestHeader("HTTP-X-4GGOGO-Signature", signatrue);

			method.addRequestHeader("4GGOGO-Auth-Token", token);
			method.addRequestHeader("Content-Type", "text/xml");

			client.executeMethod(method);
			logger.info("shandongll get net code=" + method.getStatusCode());
			if(method.getStatusCode() == HttpStatus.SC_OK){
				BufferedReader reader = new BufferedReader(new InputStreamReader(method.getResponseBodyAsStream(), charset));
				String line;
				while((line = reader.readLine()) != null){
					if(pretty){
						response.append(line).append(System.getProperty("line.separator"));
					}else{
						response.append(line);
					}
				}

				reader.close();
			}
		}catch(URIException e){
			logger.info("shandongll HTTP Get,codequeryString'" + queryString + "'exception!" + e.getMessage());
		}catch(IOException e){
			logger.info("shandongll HTTP Get,queryString'" + queryString + "'exception!" + e.getMessage());
		}finally{
			method.releaseConnection();
		}

		return response.toString();
	}
	
	public static String postXmlRequest(String url, String xmldata, String encode, Map<String, String> header, String mark){
		String bacTxt = null;
		HttpPost httppost = null;
		CloseableHttpClient httpclient = null;
		SSLContext sslContext = null;
		try {
			sslContext = SSLContext.getInstance("TLS");
			
			MyX509TrustManager tm = new MyX509TrustManager();
			
			sslContext.init(null, new TrustManager[] { tm }, new java.security.SecureRandom());
			
			httpclient = HttpClients.custom().setSSLContext(sslContext).setSSLHostnameVerifier(NoopHostnameVerifier.INSTANCE).build();
			
			httppost = new HttpPost(url);
			
			ResponseHandler<String> responseHandler = new VResponseHandler(mark);

			StringEntity entity = new StringEntity(xmldata, encode); 
			
            httppost.addHeader("Content-Type", "text/xml"); 
            
            for(Entry<String, String> entry : header.entrySet()){
				httppost.addHeader(entry.getKey(), entry.getValue());
			}
			
			httppost.setEntity(entity);
            
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
				if(httppost != null){
					httppost.releaseConnection();
				}
				if(httpclient != null){
					httpclient.close();
				}
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
%>
<%
	//获取公共参数
	out.clearBuffer();
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

		String mturl = routeparams.get("mturl");
		if(mturl == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, mturl is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String url = routeparams.get("url");
		if(url == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, url is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String appKey = routeparams.get("appKey");
		if(appKey == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, appKey is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String appSecret = routeparams.get("appSecret");
		if(appSecret == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, appSecret is null@" + TimeUtils.getSysLogTimeString());
			break;
		}

		//参数准备, 每个通道不同
		String sign = null;
		String packagecode = null;
		String token = null;
		try{
/* 			if(packageid.equals("yd.10M")){
			packagecode="5378040597617108701";
			}else if(packageid.equals("yd.30M")){
			packagecode="5378040597617108702";
			}else if(packageid.equals("yd.70M")){
			packagecode="5378040597617108703";
			}else if(packageid.equals("yd.150M")){
			packagecode="5378040597617108704";
			}else if(packageid.equals("yd.100M")){
			packagecode="5378040597617108712";
			}else if(packageid.equals("yd.300M")){
			packagecode="5378040597617108713";
			}else if(packageid.equals("yd.500M")){
			packagecode="5378040597617108705";
			}else if(packageid.equals("yd.1G")){
			packagecode="5378040597617108706";
			}else if(packageid.equals("yd.2G")){
			packagecode="5378040597617108707";
			}else if(packageid.equals("yd.3G")){
			packagecode="5378040597617108708";
			}else if(packageid.equals("yd.4G")){
			packagecode="5378040597617108709";
			}else if(packageid.equals("yd.6G")){
			packagecode="5378040597617108710";
			}else if(packageid.equals("yd.11G")){
			packagecode="5378040597617108711";
			} */
			if(packageid.equals("yd.10M")){
			packagecode="5378041907608109201";
			}else if(packageid.equals("yd.30M")){
			packagecode="5378041907608109202";
			}else if(packageid.equals("yd.70M")){
			packagecode="5378041907608109203";
			}else if(packageid.equals("yd.150M")){
			packagecode="5378041907608109204";
			}else if(packageid.equals("yd.100M")){
			packagecode="5378041907608109212";
			}else if(packageid.equals("yd.300M")){
			packagecode="5378041907608109213";
			}else if(packageid.equals("yd.500M")){
			packagecode="5378041907608109205";
			}else if(packageid.equals("yd.1G")){
			packagecode="5378041907608109206";
			}else if(packageid.equals("yd.2G")){
			packagecode="5378041907608109207";
			}else if(packageid.equals("yd.3G")){
			packagecode="5378041907608109208";
			}else if(packageid.equals("yd.4G")){
			packagecode="5378041907608109209";
			}else if(packageid.equals("yd.6G")){
			packagecode="5378041907608109210";
			}else if(packageid.equals("yd.11G")){
			packagecode="5378041907608109211";
			}
		}catch(Exception e){
			logger.warn(e.getMessage(), 0);
		}

		if(packagecode == null){
			request.setAttribute("result", "S." + routeid + ":unrecognized package@" + TimeUtils.getSysLogTimeString());
			break;
		}

		String timestamp = System.currentTimeMillis() + "";

		SimpleDateFormat s = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS");
		
			String time = s.format(new Date());
			//String time1 = time.substring(0, 23);
			//String time2 = time.substring(26, 32);
			String time3 = time + "+08:00";			
			Document document1 = DocumentHelper.createDocument();
			Element requestElement1 = document1.addElement("Request");
			Element datetimeElement1 =  requestElement1.addElement("Datetime");
			Element chargeDataElement =  requestElement1.addElement("ChargeData");
			Element mobileElement =  chargeDataElement.addElement("Mobile");
			Element productIdElement =  chargeDataElement.addElement("ProductId");
			Element serialNumElement =  chargeDataElement.addElement("SerialNum");
			datetimeElement1.setText(time3);
			mobileElement.setText(phone);
			productIdElement.setText(packagecode);
			serialNumElement.setText(taskid);
			logger.info("shandong xml"+document1.asXML());
			LinkedHashMap<String, String> tokenheader = new LinkedHashMap<String, String>();
			sign =  document1.asXML()+ appSecret;
			logger.info("shandongll sign =" + sign);
			sign = Encrypt(sign);
			tokenheader.put("HTTP-X-4GGOGO-Signature", sign);
		//在执行请求前先获取连接, 防止访问通道线程超量
		Cache.getConnection(routeid);
		try{
			//ret = HttpAccess.postNameValuePairRequest(url, params, "utf-8", "mysend");
			//ret = HttpAccess.postJsonRequest(url, json.toString(), "utf-8", "weikesend");
			token = gettoken(appKey, appSecret, url);
			tokenheader.put("4GGOGO-Auth-Token", token);
			ret = postXmlRequest(mturl, document1.asXML(), "utf-8", tokenheader, "shandongllsend");
		}catch(Exception e){
			e.printStackTrace();
			logger.info(e.getMessage());
		}finally{
			//在执行请求后记得释放连接
			Cache.releaseConnection(routeid);
		}

		//这里判断结果, 每个通道情况不同, 成功的保存 success 到 result 中并返回到 request.jsp
		if(ret != null && ret.trim().length() > 0 && ret.indexOf(taskid)>=0){
			logger.info("shandong send ret = " + ret);
			try{
			if(ret.indexOf(taskid)>=0){
				request.setAttribute("result", "success");
			}else{
					request.setAttribute("code", "1");
					request.setAttribute("result", "R." + routeid + ":@" + TimeUtils.getSysLogTimeString());
			}
				request.setAttribute("orgreturn", ret);
			}catch(Exception e){
				e.printStackTrace();
				logger.info(e.getMessage());
				request.setAttribute("result", "R." + routeid + ":" + e.getMessage() + "@" + TimeUtils.getSysLogTimeString());
			}
		}else{
			request.setAttribute("result", "R." + routeid + ":fail@" + TimeUtils.getSysLogTimeString());
		}

		break;
	}

	request.getRequestDispatcher("request.jsp").forward(request, response);
%>