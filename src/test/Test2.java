package test;

import http.HttpAccess;
import http.VResponseHandler;

import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;

import org.apache.http.NameValuePair;
import org.apache.http.client.ResponseHandler;
import org.apache.http.client.entity.UrlEncodedFormEntity;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.entity.StringEntity;
import org.apache.http.impl.client.CloseableHttpClient;
import org.apache.http.impl.client.HttpClients;
import org.apache.http.message.BasicNameValuePair;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

public class Test2 {
	private static Logger logger = LogManager.getLogger(HttpAccess.class.getName());

	public static String postNamevalveRequest(String url, Map<String, String> valuelist, Map<String, String> header,String mark){
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
            
			httppost.setEntity(new UrlEncodedFormEntity(values, "utf-8"));

            
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
	public static void main(String[] args) {
		String url="http://116.211.105.4/flowpack/recharge";
		Map<String, String> header=new HashMap<String, String>();
		
		String str = AuthSample.createAuthHead();
		header.put("Content-Type", "application/x-www-form-urlencoded");
		header.put("Authorization", str);
		
		System.out.println("str = " + str);
		
		Map<String, String> valuelist=new HashMap<String, String>();
		valuelist.put("mobile", "13307117777");
		valuelist.put("packet", "10");
		valuelist.put("nationwide", "true");


//		mobile=13307117777&packet=10&nationwide=true
		System.out.println(postNamevalveRequest(url, valuelist, header, "maiyi"));
	}
}
