<%@page import="org.apache.commons.httpclient.methods.GetMethod"%>
<%@page import="org.apache.http.util.EntityUtils"%>
<%@page import="org.apache.http.HttpResponse"%>
<%@page import="org.apache.http.entity.StringEntity"%>
<%@page import="org.apache.http.client.methods.HttpPost"%>
<%@page import="org.apache.http.impl.client.DefaultHttpClient"%>
<%@page import="java.security.NoSuchAlgorithmException"%>
<%@page import="org.apache.commons.httpclient.methods.PostMethod"%>
<%@page import="org.apache.commons.httpclient.HttpClient"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="com.alibaba.fastjson.JSONObject"%>
<%@page import="com.alibaba.fastjson.JSON"%>
<%@page import="com.alibaba.fastjson.JSONArray"%>
<%@page import="java.io.IOException"%>
<%@page import="java.io.InputStreamReader"%>
<%@page import="java.net.URLConnection"%>
<%@page import="java.net.URL"%>
<%@page import="java.io.BufferedReader"%>
<%@page import="java.security.MessageDigest"%>
<%@page import="util.TimeUtils"%>
<%@page import="cache.Cache"%>
<%@page import="org.apache.logging.log4j.LogManager"%>
<%@page import="org.apache.logging.log4j.Logger"%>
<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%
	boolean logflag = true;
	Logger logger = LogManager.getLogger();
	logger.info("root mopin");
	//获取公共参数
	String routeid = request.getAttribute("routeid").toString();
	String orderid = request.getAttribute("ids").toString();
	if (orderid.contains(",")) {
		orderid = orderid.substring(0, orderid.indexOf(","));
	}
	logger.info("status mopin orderid = " + orderid);

	try {
		while (true) {
			String ret = null;

			Map<String, String> routeparams = Cache
					.getRouteParams(routeid);
			if (routeparams == null) {
				request.setAttribute("result",
						"S." + routeid + ":wrong routeparams@"
								+ TimeUtils.getSysLogTimeString());
				break;
			}

			String url = routeparams.get("url");
			if (url == null) {
				request.setAttribute("result", "S." + routeid
						+ ":wrong routeparams, url is null@"
						+ TimeUtils.getSysLogTimeString());
				break;
			}

			String notifyUrl = routeparams.get("notifyUrl");
			if (notifyUrl == null) {
				request.setAttribute("result", "S." + routeid
						+ ":wrong routeparams, notifyUrl  is null@"
						+ TimeUtils.getSysLogTimeString());
				break;
			}

			String cp_user = routeparams.get("cp_user");
			if (cp_user == null) {
				request.setAttribute("result", "S." + routeid
						+ ":wrong routeparams, cp_user  is null@"
						+ TimeUtils.getSysLogTimeString());
				break;
			}
			String api_key = routeparams.get("api_key");
			if (api_key == null) {
				request.setAttribute("result", "S." + routeid
						+ ":wrong routeparams, api_key  is null@"
						+ TimeUtils.getSysLogTimeString());
				break;
			}
			String secret_key = routeparams.get("secret_key");
			if (secret_key == null) {
				request.setAttribute("result", "S." + routeid
						+ ":wrong routeparams, secret_key  is null@"
						+ TimeUtils.getSysLogTimeString());
				break;
			}

			//
			String resultTxt = "";

			String orderId = orderid;
			url += "/common/order?orderId=" + orderId + "&cp_user="
					+ cp_user;

			//发送查询/获取状态前先获取连接, 防止访问线程超量
			Cache.getStatusConnection(routeid);
			try {

				HttpClient hc = new HttpClient();
				GetMethod mt = new GetMethod(url);
				int stat = hc.executeMethod(mt);
				if (stat == 200) {
					resultTxt = mt.getResponseBodyAsString();
					System.out.println("resutl:" + resultTxt);
				} else {
					System.out.println("HttpError:" + stat);
				}

				logger.info("status mopin resultTxt = " + resultTxt);
			} catch (Exception e) {
				e.printStackTrace();
				logger.info(e.getMessage());
			} finally {
				//发送查询/获取状态后释放连接
				Cache.releaseStatusConnection(routeid);
			}
			JSONObject obj = new JSONObject();

			if (!resultTxt.equals("")) {
				JSONObject jbn2 = JSON.parseObject(resultTxt);

				String statusCode = jbn2.getString("statusCode");
				JSONObject dataJson = jbn2.getJSONObject("data");

				if (dataJson!=null|!"".equals(dataJson)) {
					String message = dataJson.getString("message");
					String price = dataJson.getString("price");
					String status = dataJson.getString("status");
					String channelOrderId = dataJson
							.getString("channelOrderId");
					String orderIdRest = dataJson.getString("orderId");

					JSONObject rp = new JSONObject();

					rp.put("resp", status + "." + message);

					if ("1".equals(status)) {
						rp.put("message", "success");
						rp.put("code", "0");
						obj.put(orderIdRest, rp);
					} else if ("0".equals(status)|"10".equals(status)|"11".equals(status)) {
						rp.put("message", status.replace("success", ""));
						rp.put("code", "-20");
						obj.put(orderIdRest, rp);
					}
				}

			}

			request.setAttribute("retjson", obj.toString());
			request.setAttribute("result", "success");

			break;
		}

		logger.info("mopinstausTest");
	} catch (Exception e) {
		e.printStackTrace();
		logger.info("root mopin" + e.toString());
		request.setAttribute(
				"result",
				"R." + routeid + ":" + e.toString() + "@"
						+ TimeUtils.getSysLogTimeString());
	}
	request.getRequestDispatcher("request.jsp").forward(request,
			response);
%>

<%!/**
	 * SHA加密
	 *
	 * @param inputStr
	 * @return
	 */
	public static String shaEncrypt(String inputStr) {
		byte[] inputData = inputStr.getBytes();
		String returnString = "";
		try {
			inputData = encryptSHA(inputData);
			for (int i = 0; i < inputData.length; i++) {
				returnString += byteToHexString(inputData[i]);
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		return returnString;
	}

	/**
	 * SHA加密字节
	 *
	 * @param data
	 * @return
	 * @throws Exception
	 */
	public static byte[] encryptSHA(byte[] data) throws Exception {
		MessageDigest sha = MessageDigest.getInstance("SHA");
		sha.update(data);
		return sha.digest();
	}

	private static String byteToHexString(byte ib) {
		char[] Digit = { '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'a',
				'b', 'c', 'd', 'e', 'f' };
		char[] ob = new char[2];
		ob[0] = Digit[(ib >>> 4) & 0X0F];
		ob[1] = Digit[ib & 0X0F];

		String s = new String(ob);

		return s;
	}%>
