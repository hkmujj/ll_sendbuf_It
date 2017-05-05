<%@page import="org.apache.http.conn.ssl.NoopHostnameVerifier"%>
<%@page import="javax.net.ssl.TrustManager"%>
<%@page import="javax.net.ssl.SSLContext"%>
<%@page import="http.MyX509TrustManager"%>
<%@page import="org.apache.commons.codec.digest.DigestUtils"%>
<%@page import="com.alibaba.fastjson.JSONArray"%>
<%@page import="com.alibaba.fastjson.JSONObject"%>
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
<%@page
	import="util.TimeUtils,
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
	try{
	String baseUrl="https://shandong.4ggogo.com/sd-web-in/products.html";
	String url="https://shandong.4ggogo.com/sd-web-in/auth.html";
	String rpurl="https://shandong.4ggogo.com/sd-web-in/chargeResult/";
		String appSecret="ae3235e752004356a62439ecf22a51d5";
		String appKey="ad90e4ef5d6241d4899e82cc17cf185f";
		String requestXML = "";
		String token = gettoken(appKey, appSecret, url);
		out.print(token);
 		String signatrue = DigestUtils.sha256Hex(requestXML + appSecret);
			rpurl = rpurl + "4441455454114" + ".html";
			requestXML = "";
			signatrue = DigestUtils.sha256Hex(requestXML + appSecret);
				String ret= doGet(baseUrl, "", token, signatrue, "utf-8", false);
				out.print("<xmp>"+ret+"</xmp>"); 
	}catch(Exception e){
	
	e.printStackTrace();
	}
%>