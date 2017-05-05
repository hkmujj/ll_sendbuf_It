package http;

import java.io.IOException;

import javax.net.ssl.SSLContext;
import javax.net.ssl.TrustManager;

import org.apache.http.client.ResponseHandler;
import org.apache.http.client.config.RequestConfig;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.conn.ssl.NoopHostnameVerifier;
import org.apache.http.entity.StringEntity;
import org.apache.http.impl.client.CloseableHttpClient;
import org.apache.http.impl.client.HttpClients;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;


public class HttpsAccess {
	
	private static Logger logger = LogManager.getLogger(HttpsAccess.class.getName());
	
	public static String postXmlRequest(String url, String xmldata, String encode, String mark){
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
			
			RequestConfig requestConfig = RequestConfig.custom().setSocketTimeout(90000).setConnectTimeout(5000).build();
			httppost.setConfig(requestConfig);
			
			ResponseHandler<String> responseHandler = new VResponseHandler(mark);

			StringEntity entity = new StringEntity(xmldata, encode); 
            httppost.addHeader("Content-Type", "text/xml"); 
            
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
	
	public static String postJsonRequest(String url, String jsondata, String encode, String mark){
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
			
			RequestConfig requestConfig = RequestConfig.custom().setSocketTimeout(90000).setConnectTimeout(5000).build();
			httppost.setConfig(requestConfig);
			
			ResponseHandler<String> responseHandler = new VResponseHandler(mark);
       
			StringEntity entity = new StringEntity(jsondata, encode);    
            entity.setContentEncoding(encode);    
            entity.setContentType("application/json");
            
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
	
	public static void main(String[] args) {
		testapi();
	}
	
	private static void testapi() {
		String url = "https://120.24.156.98:9309/ll_sendbuf/lanbiaosend.jsp";
		StringBuffer sb = new StringBuffer();
		sb.append("<root userid=\"200716\" password=\"0ebe454dae4978ac888290b7574765f0\">");
		sb.append("</root>");
		String ret = postXmlRequest(url, sb.toString(), "utf-8", "www");
		System.out.println("ret = " + ret);
	}
}
