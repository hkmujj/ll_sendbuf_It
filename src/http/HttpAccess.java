package http;

import java.io.IOException;
import java.io.InputStream;
import java.net.URLEncoder;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;

import org.apache.http.NameValuePair;
import org.apache.http.client.ResponseHandler;
import org.apache.http.client.config.RequestConfig;
import org.apache.http.client.entity.UrlEncodedFormEntity;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.entity.StringEntity;
import org.apache.http.impl.client.CloseableHttpClient;
import org.apache.http.impl.client.HttpClients;
import org.apache.http.message.BasicNameValuePair;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

public class HttpAccess {
	
	private static Logger logger = LogManager.getLogger(HttpAccess.class.getName());
	
	public static String postJsonRequest(String url, String jsondata, String encode, String mark){
		String bacTxt = null;
		HttpPost httppost = null;
		CloseableHttpClient httpclient = HttpClients.createDefault();
		try {
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
	
	public static String postJsonRequest(String url, String jsondata, String encode, Map<String, String> header, String mark){
		String bacTxt = null;
		HttpPost httppost = null;
		CloseableHttpClient httpclient = HttpClients.createDefault();
		try {
			httppost = new HttpPost(url);
			
			RequestConfig requestConfig = RequestConfig.custom().setSocketTimeout(90000).setConnectTimeout(5000).build();
			httppost.setConfig(requestConfig);
			
			ResponseHandler<String> responseHandler = new VResponseHandler(mark);
			
			for(Entry<String, String> entry : header.entrySet()){
				httppost.setHeader(entry.getKey(), entry.getValue());
			}
       
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
	
	public static String postXmlRequest(String url, String xmldata, String encode, String mark){
		String bacTxt = null;
		HttpPost httppost = null;
		CloseableHttpClient httpclient = HttpClients.createDefault();
		try {
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
	
	public static String postNameValuePairRequest(String url, ArrayList<KeyValuePair> valuelist, String encode, String mark){
		String bacTxt = null;
		HttpPost httppost = null;
		CloseableHttpClient httpclient = HttpClients.createDefault();
		try {
			httppost = new HttpPost(url);
			
			RequestConfig requestConfig = RequestConfig.custom().setSocketTimeout(90000).setConnectTimeout(5000).build();
			httppost.setConfig(requestConfig);
			
			ResponseHandler<String> responseHandler = new VResponseHandler(mark);
            
            List<NameValuePair> values = new ArrayList<NameValuePair>();
            for(int i = 0; i < valuelist.size(); i++){
            	values.add(new BasicNameValuePair(valuelist.get(i).key, valuelist.get(i).value));
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
	
	public static String postNameValuePairRequest(String url, Map<String, String> valuelist, String encode, String mark){
		String bacTxt = null;
		HttpPost httppost = null;
		CloseableHttpClient httpclient = HttpClients.createDefault();
		try {
			httppost = new HttpPost(url);
			
			RequestConfig requestConfig = RequestConfig.custom().setSocketTimeout(90000).setConnectTimeout(5000).build();
			httppost.setConfig(requestConfig);
			
			ResponseHandler<String> responseHandler = new VResponseHandler(mark);
            
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
	
	public static String postNameValuePairRequest(String url, Map<String, String> valuelist, String contype, String encode, String mark){
		String bacTxt = null;
		HttpPost httppost = null;
		CloseableHttpClient httpclient = HttpClients.createDefault();
		try {
			httppost = new HttpPost(url);
			
			RequestConfig requestConfig = RequestConfig.custom().setSocketTimeout(90000).setConnectTimeout(5000).build();
			httppost.setConfig(requestConfig);
			
			ResponseHandler<String> responseHandler = new VResponseHandler(mark);
            
            List<NameValuePair> values = new ArrayList<NameValuePair>();
            for(Entry<String, String> entry : valuelist.entrySet()){
            	values.add(new BasicNameValuePair(entry.getKey(), entry.getValue()));
            }
            
            UrlEncodedFormEntity entity = new UrlEncodedFormEntity(values, encode);
            
            entity.setContentType(contype);
            
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
	
	public static String postEntity(String url, String entitystr, String contenttype, String encode, String mark){
		String bacTxt = null;
		HttpPost httppost = null;
		CloseableHttpClient httpclient = HttpClients.createDefault();
		try {
			httppost = new HttpPost(url);
			
			RequestConfig requestConfig = RequestConfig.custom().setSocketTimeout(90000).setConnectTimeout(5000).build();
			httppost.setConfig(requestConfig);
			
			ResponseHandler<String> responseHandler = new VResponseHandler(mark);
       
			StringEntity entity = new StringEntity(entitystr, encode);    
            entity.setContentEncoding(encode);    
            entity.setContentType(contenttype);
            
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
	
	public static String inputStringToString(InputStream in){
		try {		
			StringBuffer out = new StringBuffer(); 
			byte[] b = new byte[4096];
			for (int n; (n = in.read(b)) != -1;) {
				out.append(new String(b, 0, n));
			}
			return out.toString();
		} catch (Exception e) {
		}
		return "";
	}
	
	public static String getNameValuePairRequest(String url, Map<String, String> params, String encode, String mark){
		String bacTxt = null;
		HttpGet httpget = null;
		CloseableHttpClient httpclient = HttpClients.createDefault();
		try {
			String paramstr = "";
			try {
				for(Entry<String, String> entry : params.entrySet()){
					if(paramstr.length() > 0){
						paramstr = paramstr + "&";
					}
					paramstr = paramstr + entry.getKey() + "=" + URLEncoder.encode(entry.getValue(), encode);
				}
			} catch (Exception e) {
			}
			httpget = new HttpGet(url + "?" + paramstr);
			
			RequestConfig requestConfig = RequestConfig.custom().setSocketTimeout(90000).setConnectTimeout(5000).build();
			httpget.setConfig(requestConfig);
			
			//logger.info("get url = " + url + "?" + paramstr);
			
			ResponseHandler<String> responseHandler = new VResponseHandler(mark);

			httpget.addHeader("Content-Type", "text/xml"); 
            
            bacTxt = httpclient.execute(httpget, responseHandler);
            
		} catch (Exception e) {
			StringBuffer sb = new StringBuffer();
			sb.append('[');
			sb.append(mark);
			sb.append("] Exception : ");
			sb.append(e.getMessage());
			logger.warn(sb.toString(), e);
		} finally {
			try {
				httpget.releaseConnection();
				httpclient.close();
			} catch (Exception e) {
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

}
