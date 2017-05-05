<%@page import="org.apache.http.client.methods.HttpPost"%>
<%@page
	import="
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

org.apache.http.HttpResponse,
org.apache.http.NameValuePair,
org.apache.http.client.HttpClient,
org.apache.http.client.entity.UrlEncodedFormEntity,
org.apache.http.client.methods.HttpPost,
org.apache.http.impl.client.DefaultHttpClient,
org.apache.http.message.BasicNameValuePair,
org.apache.http.protocol.HTTP,
util.MD5Util,
				org.apache.logging.log4j.Logger"
	language="java" pageEncoding="UTF-8"%><%!private static boolean logflag = true;
	private static Logger logger = LogManager.getLogger();
	public static final String cert = "ZI1ZRL508QCQWEY5BDNGHDQ1BO8WE2RG";
	public static final String uri = "http://www.gdletao.com/api/v1.php";
	public static final String user_name = "I5GOGP4FSK";

	private static String execute(HttpPost post) {
		try {
			HttpClient http_client = new DefaultHttpClient();
			HttpResponse response = http_client.execute(post);
			if (response.getStatusLine().getStatusCode() == 404) {
				throw new IOException("Network Error");
			}
			;
			InputStream is = response.getEntity().getContent();
			BufferedReader br = new BufferedReader(new InputStreamReader(is, Charset.forName("UTF-8")));
			StringBuilder sb = new StringBuilder();
			String line = null;
			while ((line = br.readLine()) != null) {
				sb.append(line);
			}
			return sb.toString();
		} catch (IOException e) {
			return "";
		}
	}

	public static String orderQuery() {
		String call_name = "OrderQuery";
		long timestamp = System.currentTimeMillis() / 1000L;
		String timestr = String.valueOf(timestamp);
		String signature = MD5Util.getLowerMD5(timestr + cert);
		HttpPost post = new HttpPost(uri);
		post.setHeader("API-USER-NAME", user_name);
		post.setHeader("API-NAME", call_name);
		post.setHeader("API-TIMESTAMP", timestamp + "");
		post.setHeader("API-SIGNATURE", signature);
		List<NameValuePair> param = new ArrayList<NameValuePair>();
		param.add(new BasicNameValuePair("order_number", "123456"));
		String ret = null;
		try {
			post.setEntity(new UrlEncodedFormEntity(param, HTTP.UTF_8));
			ret = execute(post);
		} catch (UnsupportedEncodingException e) {
			e.printStackTrace();
		} catch (IOException e) {
			e.printStackTrace();
		}
		logger.info("letao ret = " + ret);
		return ret;
	}

	public static String orderCreate() {
		String call_name = "OrderCreate";
		long timestamp = System.currentTimeMillis() / 1000L;
		String signature = MD5Util.getLowerMD5(timestamp + cert);
		HttpPost post = new HttpPost(uri);
		post.setHeader("API-USER-NAME", user_name);
		post.setHeader("API-NAME", call_name);
		post.setHeader("API-TIMESTAMP", timestamp + "");
		post.setHeader("API-SIGNATURE", signature);
		List<NameValuePair> param = new ArrayList<NameValuePair>();
		param.add(new BasicNameValuePair("phone_number", "15017556283"));
		param.add(new BasicNameValuePair("product_id", "1"));
		String ret = null;
		try {
			post.setEntity(new UrlEncodedFormEntity(param, HTTP.UTF_8));
			ret = execute(post);
		} catch (UnsupportedEncodingException e) {
			e.printStackTrace();
		} catch (IOException e) {
			e.printStackTrace();
		}
		logger.info("letao ret = " + ret);
		return ret;
	}

	public static String productQuery() {
		String call_name = "ProductQuery";
		long timestamp = System.currentTimeMillis() / 1000L;
		String signature = MD5Util.getLowerMD5(timestamp + cert);
		HttpPost post = new HttpPost(uri);
		post.setHeader("API-USER-NAME", user_name);
		post.setHeader("API-NAME", call_name);
		post.setHeader("API-TIMESTAMP", timestamp + "");
		post.setHeader("API-SIGNATURE", signature);
		List<NameValuePair> param = new ArrayList<NameValuePair>();
		String ret = null;
		try {
			post.setEntity(new UrlEncodedFormEntity(param, HTTP.UTF_8));
			ret = execute(post);
		} catch (UnsupportedEncodingException e) {
			e.printStackTrace();
		} catch (IOException e) {
			e.printStackTrace();
		}
		logger.info("letao ret = " + ret);
		return ret;
	}%>
<%
	out.print(orderQuery());
%>