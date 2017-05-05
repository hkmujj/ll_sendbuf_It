package test;


import http.VResponseHandler;

import java.io.IOException;

import org.apache.http.client.ResponseHandler;
import org.apache.http.client.config.RequestConfig;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.entity.StringEntity;
import org.apache.http.impl.client.CloseableHttpClient;
import org.apache.http.impl.client.HttpClients;

public class Testzhongchenyuan {
	public static void main(String[] args) {
		String url = "http://119.29.48.212:9096/callback/MingChuanNotifyUrl.jsp";
		String xml = "<root><status taskid=\"1704190935202702110\" linkid=\"\" code=\"0\" message=\"\" time=\"2017-04-19\"/><status taskid=\"1704190935202702110\" linkid=\"\" code=\"0\" message=\"\" time=\"2017-04-19\"/></root>";
		System.out.println(xml);
		String ret = postXmlRequest(url, xml, "utf-8", "mark");
		System.out.println();
	}
	
	public static String postXmlRequest(String url, String xmldata, String encode, String mark) {
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
			}
		}
		StringBuffer sb = new StringBuffer();
		sb.append('[');
		sb.append(mark);
		sb.append("] response text = ");
		sb.append(bacTxt);
		return bacTxt;
	}
}
