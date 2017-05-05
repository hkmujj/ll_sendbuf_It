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
				org.apache.logging.log4j.Logger" 
		language="java" pageEncoding="UTF-8"
%><%

	
					String account ="dyxx";
			String password ="123456";
			String sign ="";
			String sessionId ="20161021064722203023";
			String key="dyxx168";
			 sign=  MD5Util.getUpperMD5(account+MD5Util.getUpperMD5(password)+key);
							Map<String, String> parms=new LinkedHashMap<String, String>();
							parms.put("account", account);
							parms.put("password", password);
							parms.put("sign", sign);
							parms.put("sessionId", sessionId);
							String burl="";
							Iterator itera=parms.entrySet().iterator();
							while (itera.hasNext()) {
								Map.Entry entry=(Map.Entry)itera.next();
								burl=burl+"&"+entry.getKey()+"="+entry.getValue();
							}
							burl="?"+burl.substring(1);
							
		String url="http://sdk.dellidc.com/queryOrder.json"+burl;
					//发送查询/获取状态前先获取连接, 防止访问线程超量
					
					String ret=HttpAccess.postNameValuePairRequest(url, new HashMap<String, String>(), "utf-8", "deli");
					out.print(ret);
					%>