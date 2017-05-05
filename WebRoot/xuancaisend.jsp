<%@page import="http.VResponseHandler"%>
<%@page import="org.dom4j.DocumentHelper"%>
<%@page import="org.dom4j.Element"%>
<%@page import="org.dom4j.Document"%>
<%@page import="org.apache.http.HttpEntity"%>
<%@page import="org.apache.http.util.EntityUtils"%>
<%@page import="java.io.IOException"%>
<%@page import="org.apache.http.client.ClientProtocolException"%>
<%@page import="org.apache.http.HttpResponse"%>
<%@page import="org.apache.http.client.ResponseHandler"%>
<%@page import="org.apache.http.client.config.RequestConfig"%>
<%@page import="java.net.URLEncoder"%>
<%@page import="org.apache.http.impl.client.HttpClients"%>
<%@page import="java.util.Map.Entry"%>
<%@page import="org.apache.http.impl.client.CloseableHttpClient"%>
<%@page import="org.apache.http.client.methods.HttpGet"%>
<%@page
	import="util.AES,
				util.MD5Util,
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
	language="java" pageEncoding="UTF-8"%>
<%!private static Logger logger = LogManager.getLogger(HttpAccess.class.getName());


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
			
			httpget = new HttpGet(url  );
			
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
			}
		}
		
		StringBuffer sb = new StringBuffer();
		sb.append('[');
		sb.append(mark);
		sb.append("] response text = ");
		sb.append(bacTxt);
		
		
		return bacTxt;
	}
		private static class MyResponseHandler implements ResponseHandler<String>{
		private String mark = null;
		private String enc = null;
		public MyResponseHandler(String str, String encstr){
			mark = str;
			enc = encstr;
		}
		@Override
		public String handleResponse(HttpResponse response) throws ClientProtocolException, IOException {
			 int status = response.getStatusLine().getStatusCode();
	         if (status >= 200 && status < 300){
	             HttpEntity entity = response.getEntity();
	             return entity !=null ? EntityUtils.toString(entity, enc) : null;
	         }else{
	        	 StringBuffer sb = new StringBuffer();
	        	 sb.append('[');
	        	 sb.append(mark);
	        	 sb.append("] unexpected response status : ");
	        	 sb.append(status);
	             throw new ClientProtocolException(sb.toString());
	         }
		}
		}%>
<%
	boolean logflag = true;
	Logger logger = LogManager.getLogger();
	out.clearBuffer();
	//获取公共参数
	String taskid = request.getAttribute("taskid").toString();
	String routeid = request.getAttribute("routeid").toString();
	String phone = request.getAttribute("phone").toString();
	String packageid = request.getAttribute("package").toString();

	while (true) {
		String ret = null;

		//检查通道参数, 每个通道有不同参数, 对应 ll_routes.api_params
		Map<String, String> routeparams = Cache.getRouteParams(routeid);
		if (routeparams == null) {
			request.setAttribute("result", "S." + routeid + ":wrong routeparams@" + TimeUtils.getSysLogTimeString());
			break;
		}

		String url = routeparams.get("url");
		if (url == null) {
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, url is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String channel_code = routeparams.get("channel_code");
		if (channel_code == null) {
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, channel_code is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String key = routeparams.get("key");
		if (key == null) {
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, key is null@" + TimeUtils.getSysLogTimeString());
			break;
		}

		//参数准备, 每个通道不同
		String packagecode = null;
		String packgetype = null;
		if (packageid.indexOf("lt.") > -1) {
			try {
				packageid = packageid.split("\\.")[1];
				packgetype = packageid;
			} catch (Exception e) {
				logger.warn(e.getMessage(), 0);
			}
			if (packageid.equals("30M")) {
				packagecode = "7000030";
			} else if (packageid.equals("300M")) {
				packagecode = "7000300";
			} else if (packageid.equals("20M")) {
				packagecode = "7000020 ";
			} else if (packageid.equals("50M")) {
				packagecode = "7000050";
			} else if (packageid.equals("100M")) {
				packagecode = "7000100";
			} else if (packageid.equals("200M")) {
				packagecode = "7000200";
			} else if (packageid.equals("500M")) {
				packagecode = "7000500";
			} else if (packageid.equals("1G")) {
				packagecode = "7001024";
			}
		}else if(packageid.indexOf("dx.") > -1){
			try {
				packageid = packageid.split("\\.")[1];
				packgetype = packageid;
			} catch (Exception e) {
				logger.warn(e.getMessage(), 0);
			}
			if (packageid.equals("5M")) {
				packagecode = "5000005";
			} else if (packageid.equals("10M")) {
				packagecode = "5000010";
			} else if (packageid.equals("30M")) {
				packagecode = "5000030";
			}else if (packageid.equals("50M")) {
				packagecode = "5000050";
			}else if (packageid.equals("100M")) {
				packagecode = "5000100";
			}else if (packageid.equals("150M")) {
				packagecode = "5000150";
			}else if (packageid.equals("200M")) {
				packagecode = "5000200";
			}else if (packageid.equals("300M")) {
				packagecode = "5000300";
			}else if (packageid.equals("500M")) {
				packagecode = "5000500";
			}else if (packageid.equals("1G")) {
				packagecode = "5001024";
			}else if (packageid.equals("2G")) {
				packagecode = "5002048";
			}else if (packageid.equals("3G")) {
				packagecode = "5003072";
			}
			
		}else if(packageid.indexOf("yd.") > -1){
			try {
				packageid = packageid.split("\\.")[1];
				packgetype = packageid;
			} catch (Exception e) {
				logger.warn(e.getMessage(), 0);
			}
			if (packageid.equals("10M")) {
				packagecode = "6000010";
			} else if (packageid.equals("30M")) {
				packagecode = "6000030";
			} else if (packageid.equals("70M")) {
				packagecode = "6000070";
			}else if (packageid.equals("100M")) {
				packagecode = "6000100";
			}else if (packageid.equals("150M")) {
				packagecode = "6000150";
			}else if (packageid.equals("300M")) {
				packagecode = "6000300";
			}else if (packageid.equals("500M")) {
				packagecode = "6000500";
			}else if (packageid.equals("1G")) {
				packagecode = "6001024";
			}else if (packageid.equals("2G")) {
				packagecode = "6002048";
			}else if (packageid.equals("3G")) {
				packagecode = "6003072";
			}else if (packageid.equals("4G")) {
				packagecode = "6004096";
			}else if (packageid.equals("6G")) {
				packagecode = "6006144";
			}else if (packageid.equals("11G")) {
				packagecode = "6011264";
			}
			
		}
		
		if (packagecode == null) {
			request.setAttribute("result", "S." + routeid + ":unrecognized package@" + TimeUtils.getSysLogTimeString());
			break;
		}
				String req_id = "20"+taskid;
		req_id=req_id.substring(0,20);
		String timestamp = System.currentTimeMillis() + "";
		String signbef = req_id + phone + packagecode + channel_code + timestamp + key;
		logger.info("xuancai sendbef="+signbef);
		String md5 = MD5Util.getLowerMD5(signbef);
		logger.info("xuancai send sign="+md5);

		Map<String, String> params = new HashMap<String, String>();
		params.put("req_id", req_id);
		params.put("phone", phone);
		params.put("pkg_name", packgetype);
		params.put("pkg_id", packagecode);
		params.put("channel_code", channel_code);
		params.put("timestamp", timestamp);
		params.put("md5", md5);

		String paramstr = null;
		url = url + "?req_id=" + req_id + "&phone=" + phone + "&channel_code=" + channel_code + "&pkg_name=" + packgetype + "&pkg_id=" + packagecode + "&timestamp=" + timestamp + "&md5=" + md5;
		logger.info("xuancai sendurl=" + url);
		//在执行请求前先获取连接, 防止访问通道线程超量
		Cache.getConnection(routeid);
		try {
			ret = getNameValuePairRequest(url, params, "utf-8", "xuancai");
		} catch (Exception e) {
			e.printStackTrace();
			logger.info(e.getMessage());
		} finally {
			//在执行请求后记得释放连接
			Cache.releaseConnection(routeid);
		}

		//这里判断结果, 每个通道情况不同, 成功的保存 success 到 result 中并返回到 request.jsp
		if (ret != null && ret.trim().length() > 0) {
			logger.info("xuancai send ret = " + ret);
			try {
				JSONObject json = JSONObject.fromObject(ret);
				String code = json.getString("code");
				if (code != null && code.equals("0")) {
					request.setAttribute("result", "success");
					request.setAttribute("reportid", req_id);
				} else {
					String desc = "fail";
					if(json.get("text")!=null){
					desc=json.getString("text");
					}
					request.setAttribute("code", 1);
					request.setAttribute("result", "R." + routeid + ":" + code + desc + "@" + TimeUtils.getSysLogTimeString());
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

	request.getRequestDispatcher("request.jsp").forward(request, response);
%>