<%@page import="org.apache.http.util.EntityUtils"%>
<%@page import="org.apache.http.HttpEntity"%>
<%@page import="org.apache.http.client.ClientProtocolException"%>
<%@page import="org.apache.http.HttpResponse"%>
<%@page import="java.io.IOException"%>
<%@page import="org.apache.http.entity.StringEntity"%>
<%@page import="java.util.Map.Entry"%>
<%@page import="org.apache.http.client.ResponseHandler"%>
<%@page import="org.apache.http.client.config.RequestConfig"%>
<%@page import="org.apache.http.impl.client.HttpClients"%>
<%@page import="org.apache.http.impl.client.CloseableHttpClient"%>
<%@page import="org.apache.http.client.methods.HttpPost"%>
<%@page
	import="util.TimeUtils,
				http.HttpAccess,
				util.MD5Util,
				cache.Cache,
				net.sf.json.JSONException,
				net.sf.json.JSONObject,
				java.util.*,
				util.MyStringUtils,
				java.net.URLDecoder,
				org.apache.logging.log4j.LogManager,
				org.apache.logging.log4j.Logger,
				util.MyBase64,
				java.security.MessageDigest,
				java.security.NoSuchAlgorithmException,
				java.io.UnsupportedEncodingException"
	language="java" pageEncoding="UTF-8"%><%!public static String postJsonRequest(String url, String jsondata, String encode, String retenc, Map<String, String> header, String mark) {
		String bacTxt = null;
		HttpPost httppost = null;
		CloseableHttpClient httpclient = HttpClients.createDefault();
		try {
			httppost = new HttpPost(url);

			RequestConfig requestConfig = RequestConfig.custom().setSocketTimeout(90000).setConnectTimeout(5000).build();
			httppost.setConfig(requestConfig);

			ResponseHandler<String> responseHandler = new MyResponseHandler(mark, retenc);

			for (Entry<String, String> entry : header.entrySet()) {
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

	private static class MyResponseHandler implements ResponseHandler<String> {
		private String mark = null;
		private String enc = null;

		public MyResponseHandler(String str, String encstr) {
			mark = str;
			enc = encstr;
		}

		@Override
		public String handleResponse(HttpResponse response) throws ClientProtocolException, IOException {
			int status = response.getStatusLine().getStatusCode();
			if (status >= 200 && status < 300) {
				HttpEntity entity = response.getEntity();
				return entity != null ? EntityUtils.toString(entity, enc) : null;
			} else {
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

	//获取公共参数
	String taskid = request.getAttribute("taskid").toString();
	String routeid = request.getAttribute("routeid").toString();
	String phone = request.getAttribute("phone").toString();
	String packageid = request.getAttribute("package").toString();

	while (true) {
		String ret = null;

		//检查通道参数, 每个通道有不同参数, 对应 ll_routes.api_params(私有参数)
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
		String MerChant = routeparams.get("MerChant");
		if (MerChant == null) {
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, MerChant is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String ClientID = routeparams.get("ClientID");
		if (ClientID == null) {
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, ClientID is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String ClientSeceret = routeparams.get("ClientSeceret");
		if (ClientSeceret == null) {
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, ClientSeceret is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String Version = routeparams.get("Version");
		if (Version == null) {
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, Version is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String Action = "GetToken";
		String sendAction = "SendOrder";

		//参数准备, 每个通道不同
		//广东移动50M红包
		String packagecode = null;
		if (routeid.equals("1206")) {
			if (packageid.equals("yd.50M")) {
				packagecode = "10022";
			}
		} else if (routeid.equals("1316")) {
			if (packageid.equals("yd.70M")) {
				packagecode = "10077";
			} else if (packageid.equals("yd.100M")) {
				packagecode = "10078";
			} else if (packageid.equals("yd.150M")) {
				packagecode = "10079";
			} else if (packageid.equals("yd.300M")) {
				packagecode = "10080";
			} else if (packageid.equals("yd.500M")) {
				packagecode = "10081";
			} else if (packageid.equals("yd.1G")) {
				packagecode = "10082";
			} else if (packageid.equals("yd.2G")) {
				packagecode = "10083";
			} else if (packageid.equals("yd.3G")) {
				packagecode = "10084";
			} else if (packageid.equals("yd.4G")) {
				packagecode = "10085";
			} else if (packageid.equals("yd.6G")) {
				packagecode = "10086";
			} else if (packageid.equals("yd.11G")) {
				packagecode = "10087";
			}
		}

		if (packagecode == null) {
			request.setAttribute("result", "S." + routeid + ":unrecognized package@" + TimeUtils.getSysLogTimeString());
			break;
		}

		JSONObject obj = new JSONObject();
		obj.put("MerChant", MerChant);
		obj.put("ClientID", ClientID);
		obj.put("ClientSeceret", ClientSeceret);
		obj.put("Version", Version);
		obj.put("Action", Action);
		logger.info("huayi get token = " + obj.toString());

		String sign = MD5Util.getUpperMD5(obj.toString());
		logger.info("huayi get token sign = " + sign);

		LinkedHashMap<String, String> header = new LinkedHashMap<String, String>();
		header.put("Sign", sign);
		//在执行请求前先获取连接, 防止访问通道线程超量
		Cache.getConnection(routeid);
		try {
			ret = HttpAccess.postJsonRequest(url, obj.toString(), "utf-8", header, "huayigettoken");
		} catch (Exception e) {
			e.printStackTrace();
			logger.info(e.getMessage());
		} finally {
			//在执行请求后记得释放连接
			Cache.releaseConnection(routeid);
		}

		JSONObject retobj = JSONObject.fromObject(ret);
		String Token = retobj.getString("Msg");

		JSONObject sendobj = new JSONObject();
		sendobj.put("MerChant", MerChant);
		sendobj.put("Product", packagecode);
		sendobj.put("Mobile", phone);
		sendobj.put("Version", Version);
		sendobj.put("Action", sendAction);
		sendobj.put("FlowKey", taskid);
		logger.info("huayi send value = " + sendobj.toString());

		String sendsign = MD5Util.getUpperMD5(sendobj.toString());
		logger.info("huayi send sign = " + sendsign.toString());

		LinkedHashMap<String, String> sendheader = new LinkedHashMap<String, String>();
		sendheader.put("Sign", sendsign);
		sendheader.put("Token", Token);

		String sendret = null;
		try {
			sendret = postJsonRequest(url, sendobj.toString(), "utf-8", "utf-8", sendheader, "huayisend");
		} catch (Exception e) {
			e.printStackTrace();
			logger.info(e.getMessage());
		}

		//这里判断结果, 每个通道情况不同, 成功的保存 success 到 result 中并返回到 request.jsp(ret为返回的结果)
		if (sendret != null && sendret.trim().length() > 0) {
			logger.info("huayisend send sendret = " + sendret);
			try {
				JSONObject retjson = JSONObject.fromObject(sendret);
				String retCode = retjson.getString("Type"); //":"4" 下单/订购成功

				if (retCode.equals("4")) {
					request.setAttribute("result", "success");
				} else {
					request.setAttribute("code", 1);
					String message = retjson.getString("Msg");
					request.setAttribute("result", "R." + routeid + ":" + retCode + ":" + message + "@" + TimeUtils.getSysLogTimeString());
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