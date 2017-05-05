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
	logger.info("root guoxin");
	//获取公共参数
	String routeid = request.getAttribute("routeid").toString();
	String orderid = request.getAttribute("ids").toString();
	if (orderid.contains(",")) {
		orderid = orderid.substring(0, orderid.indexOf(","));
	}
	logger.info("status guoxin orderid = " + orderid);
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

			String APPKEY = routeparams.get("APPKEY");
			if (APPKEY == null) {
				request.setAttribute("result", "S." + routeid
						+ ":wrong routeparams, APPKEY  is null@"
						+ TimeUtils.getSysLogTimeString());
				break;
			}

			String SECURITY_KEY = routeparams.get("SECURITY_KEY");
			if (SECURITY_KEY == null) {
				request.setAttribute("result", "S." + routeid
						+ ":wrong routeparams, SECURITY_KEY  is null@"
						+ TimeUtils.getSysLogTimeString());
				break;
			}

			//
			String resultTxt = "";

			SimpleDateFormat sdf = new SimpleDateFormat(
					"yyyyMMddHHmmss");
			String time = sdf.format(new Date());
			String paramsSort = "appkey" + APPKEY + "cstmOrderNo"
					+ orderid + "timeStamp" + time;
			String sig = shaEncrypt(paramsSort + SECURITY_KEY);
			JSONObject jsb = new JSONObject();
			jsb.put("appkey", APPKEY);
			jsb.put("cstmOrderNo", orderid);
			jsb.put("sig", sig);
			jsb.put("timeStamp", time);

			//发送查询/获取状态前先获取连接, 防止访问线程超量
			Cache.getStatusConnection(routeid);
			try {
				DefaultHttpClient httpClient = new DefaultHttpClient();
				HttpPost method = new HttpPost(url
						+ "/api/rest/1.0/order/status");
				StringEntity entity = new StringEntity(
						jsb.toJSONString(), "utf-8");
				entity.setContentEncoding("utf-8");
				entity.setContentType("application/json");
				method.setEntity(entity);

				HttpResponse result = httpClient.execute(method);
				/** 请求发送成功，并得到响应 **/
				if (result.getStatusLine().getStatusCode() == 200) {
					try {
						/** 读取服务器返回过来的json字符串数据 **/
						resultTxt = EntityUtils.toString(
								result.getEntity(), "utf-8");
						/** 把json字符串转换成json对象 **/
						System.out.println(resultTxt);
					} catch (Exception e) {
						e.printStackTrace();
					}
				}

				logger.info("status guoxin resultTxt = " + resultTxt);
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
				String code = jbn2.getString("code");
				String msg = jbn2.getString("msg");
				JSONObject dataJson = jbn2.getJSONObject("data");
				if (code.equals("0000") & dataJson != null) {
					if (code.equals("0000")) {

						String cstmOrderNo = dataJson
								.getString("cstmOrderNo");
						String status = dataJson.getString("status");
						String errorDesc = dataJson
								.getString("errorDesc");
						JSONObject rp = new JSONObject();

						rp.put("resp", status + "." + errorDesc);
						if (status.equals("7")) {
							rp.put("message", "success");
							rp.put("code", "0");
							obj.put(cstmOrderNo, rp);
						} else if (status.equals("8")) {
							rp.put("message",
									status.replace("success", ""));
							rp.put("code", "11");
							obj.put(cstmOrderNo, rp);
						}

					}
				}

			}

			request.setAttribute("retjson", obj.toString());
			request.setAttribute("result", "success");

			break;
		}

		logger.info("guoxinstausTest");
	} catch (Exception e) {
		e.printStackTrace();
		logger.info("root guoxin" + e.toString());
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
