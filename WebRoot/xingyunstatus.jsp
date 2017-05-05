
<%@page import="org.apache.http.util.EntityUtils"%>
<%@page import="org.apache.http.HttpEntity"%>
<%@page import="org.apache.http.client.ClientProtocolException"%>
<%@page import="org.apache.http.HttpResponse"%>
<%@page import="java.io.IOException"%>
<%@page import="org.apache.http.entity.StringEntity"%>
<%@page import="org.apache.http.client.ResponseHandler"%>
<%@page import="org.apache.http.client.config.RequestConfig"%>
<%@page import="org.apache.http.impl.client.HttpClients"%>
<%@page import="org.apache.http.impl.client.CloseableHttpClient"%>
<%@page import="org.apache.http.client.methods.HttpPost"%>
<%@page
	import="java.text.SimpleDateFormat,
				util.SHA1,
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
	language="java" pageEncoding="UTF-8"%>
<%!boolean logflag = true;
	public static Logger logger = LogManager.getLogger();

	public static String postJsonRequest(String url, String jsondata, String encode, String mark) {
		String bacTxt = null;
		HttpPost httppost = null;
		CloseableHttpClient httpclient = HttpClients.createDefault();
		try {
			httppost = new HttpPost(url);

			RequestConfig requestConfig = RequestConfig.custom().setSocketTimeout(90000).setConnectTimeout(5000).build();
			httppost.setConfig(requestConfig);

			ResponseHandler<String> responseHandler = new MyResponseHandler(mark, "utf-8");

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
	out.clearBuffer();
	while (true) {
		String ret = null;

		//获取公共参数
		String routeid = request.getAttribute("routeid").toString();

		Object idsobj = request.getAttribute("ids");
		if (idsobj == null) {
			request.setAttribute("result", "S." + routeid + ":ids are needed to get status@" + TimeUtils.getSysLogTimeString());
			break;
		}

		String ids = idsobj.toString();

		logger.info("ids = " + ids + ", routeid = " + routeid);

		//获取通道能数, 每个通道不同
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
		String merchant = routeparams.get("merchant");
		if (merchant == null) {
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, merchant is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String clientId = routeparams.get("clientId");
		if (clientId == null) {
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, clientId is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String key = routeparams.get("key");
		if (key == null) {
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, key is null@" + TimeUtils.getSysLogTimeString());
			break;
		}

		//发送请求前先准备好参数
		String[] idarray = ids.split(",");
		JSONObject obj = new JSONObject();

		for (int i = 0; i < idarray.length; i++) {
			url = url + "/capi/query.order";
			String ts = "" + System.currentTimeMillis();
			String version = "V100";
			String signbef = "clientId" + clientId + "merchant" + merchant + "outTradeNo" + idarray[i] + "ts" + ts + "version" + version + key;
			System.out.println(signbef);
			String sign = MD5Util.getLowerMD5(signbef);
			JSONObject json = new JSONObject();
			json.put("clientId", clientId);
			json.put("merchant", merchant);
			json.put("outTradeNo", idarray[i]);
			json.put("sign", sign);
			json.put("ts", ts);
			json.put("version", version);
			//发送查询/获取状态前先获取连接, 防止访问线程超量
			Cache.getStatusConnection(routeid);
			try {
				ret = HttpAccess.postJsonRequest(url, json.toString(), "utf-8", "xingyun");
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
				logger.info("xingyun status ret = " + ret);
				try {
					JSONObject robj = JSONObject.fromObject(ret);
					String retCode = robj.getString("rspCode");
					if (retCode.equals("0")) {
						String staus = robj.getString("status");
						if (staus.equals("4")) {
							JSONObject rp = new JSONObject();
							rp.put("code", 0);
							rp.put("message", "success");
							rp.put("resp", ret);
							obj.put(idarray[i], rp);
						} else if (staus.equals("5")) {
							JSONObject rp = new JSONObject();
							rp.put("code", "1");
							String msg = "失败";
							if (robj.get("rspMsg") != null) {
								msg = robj.getString("rspMsg");
							}
							logger.info("xingyun msg=" + msg + idarray[i]);
							rp.put("message", staus + ":" + msg);
							rp.put("resp", ret);
							obj.put(idarray[i], rp);
						} else {
							logger.info("xingyun status : [" + idarray[i] + "]充值中@" + TimeUtils.getSysLogTimeString());
						}
					} else {
						logger.info("xingyun status : [" + idarray[i] + "]状态码" + retCode + "@" + TimeUtils.getSysLogTimeString());

					}
				} catch (Exception e) {
					logger.warn(e.getMessage(), e);
					logger.info("xingyun status : " + e.getMessage() + ", ret = " + ret + "@" + TimeUtils.getSysLogTimeString());
				}
			} else {
				logger.info("xingyun status : " + "fail@" + TimeUtils.getSysLogTimeString());
			}
		}

		request.setAttribute("retjson", obj.toString());
		request.setAttribute("result", "success");

		break;
	}

	request.getRequestDispatcher("request.jsp").forward(request, response);
%>