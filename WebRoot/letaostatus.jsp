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
				net.sf.json.JSONObject,
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
%><%!
	private static boolean logflag = true;
	private static Logger logger = LogManager.getLogger();
	
	private static String execute(HttpPost post){
		CloseableHttpClient http_client = null;
        try {
            http_client = HttpClients.createDefault();
            HttpResponse response = http_client.execute(post);
            if(response.getStatusLine().getStatusCode() == 404){
                throw new IOException("Network Error");
            };
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
        } finally {
        	try{
				http_client.close();
			} catch (Exception e) {
				logger.warn(e.getMessage(), 0);
			}
        	
        }
	}
%><%
	
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
		String cert = routeparams.get("cert");
		if(cert == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, cert is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String user_name = routeparams.get("user_name");
		if(user_name == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, user_name is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		
		//发送请求前先准备好参数
		String[] idarray = ids.split(",");
		JSONObject obj = new JSONObject();
		
		JSONObject json = new JSONObject();
		
		for(int i = 0; i < idarray.length; i++){
			String orderId = idarray[i];
			
			String call_name = "OrderQuery";
	        long timestamp = System.currentTimeMillis()/1000L;
	        String timestr=String.valueOf(timestamp);
	        String signature =MD5Util.getLowerMD5(timestr + cert);
	        HttpPost post = new HttpPost(url);
	        post.setHeader("API-USER-NAME", user_name);
	        post.setHeader("API-NAME",call_name);
	        post.setHeader("API-TIMESTAMP", timestamp + "");
	        post.setHeader("API-SIGNATURE", signature);
	        List<NameValuePair> param = new ArrayList <NameValuePair>();  
	        param.add(new BasicNameValuePair("order_number", orderId));  
        
			//System.out.println("json = " + json.toString());
		
			//发送查询/获取状态前先获取连接, 防止访问线程超量
			Cache.getStatusConnection(routeid);
			try {
				//ret = HttpAccess.postNameValuePairRequest(url, params, "utf-8", "ltkuandai");
				//ret = URLDecoder.decode(HttpAccess.postNameValuePairRequest(url, param, "utf-8", "hanzhiyou"), "utf-8");
				post.setEntity(new UrlEncodedFormEntity(param, "utf-8"));
             	ret = execute(post);
			} catch (Exception e) {
				e.printStackTrace();
				logger.info(e.getMessage());
			} finally {
				//发送查询/获取状态后释放连接
				Cache.releaseStatusConnection(routeid);
			}
			
			//这里判断结果, 每个通道情况不同, 成功的节点ID对应success, 失败的对应失败信息
			if (ret != null && ret.trim().length() > 0) {
				//request.setAttribute("result", "success");
				logger.info("letao status ret = " + ret);
				try {
					JSONObject retjson = JSONObject.fromObject(ret);
					String retCode = retjson.getString("ack");
					Object objc = retjson.get("order");
					JSONObject order = null;
					if(retCode.equals("success") && objc != null){
						order = retjson.getJSONObject("order");
						if(order.get("order_number") != null && order.getString("order_number").equals(orderId)){
							if(order.get("shipping_status") != null){
								if(order.getString("shipping_status").equals("4")){
									//成功
									JSONObject rp = new JSONObject();
									rp.put("code", 0);
									rp.put("message", "success");
									rp.put("resp", order.toString());
									obj.put(idarray[i], rp);
								}else if(order.getString("shipping_status").equals("5")){
									//失败
									JSONObject rp = new JSONObject();
									rp.put("code", 1);
									rp.put("message", order.getString("shipping_status_message"));
									rp.put("resp", order.toString());
									obj.put(idarray[i], rp);
								}else{
									logger.info("letao status : [" + idarray[i] + "]状态码" + order.getString("shipping_status") + ":" + order.getString("shipping_status_desc") + "@" + TimeUtils.getSysLogTimeString());
								}
							}else{
								logger.info("letao status : [" + idarray[i] + "]状态码" + order.getString("shipping_status") + ":" + order.getString("shipping_status_desc") + "@" + TimeUtils.getSysLogTimeString());
							}
						}
					}else{
						logger.info("letao status : [" + idarray[i] + "]状态码" + retCode + ":" + retjson.getString("message") + "@" + TimeUtils.getSysLogTimeString());
					}
				} catch (Exception e) {
					logger.warn(e.getMessage(), e);
					logger.info("letao status : " + e.getMessage() + ", ret = " + ret + "@" + TimeUtils.getSysLogTimeString());
				}
			} else {
				logger.info("letao status : " + "fail@" + TimeUtils.getSysLogTimeString());
			}
		}
	
		request.setAttribute("retjson", obj.toString());
		request.setAttribute("result", "success");
		
		break;
	}
	
	request.getRequestDispatcher("request.jsp").forward(request,response);
%>