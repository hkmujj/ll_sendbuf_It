<%@page import="java.security.NoSuchAlgorithmException"%>
<%@page import="org.apache.commons.httpclient.methods.PostMethod"%>
<%@page import="org.apache.commons.httpclient.HttpClient"%>
<%@page import="com.alibaba.fastjson.JSON"%>
<%@page import="com.alibaba.fastjson.JSONObject"%>
<%@page import="java.io.IOException"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.security.MessageDigest"%>
<%@page import="java.io.InputStreamReader"%>
<%@page import="java.net.URLConnection"%>
<%@page import="java.net.URL"%>
<%@page import="java.io.BufferedReader"%>
<%@page import="cache.Cache"%>
<%@page import="util.TimeUtils"%>
<%@page import="org.apache.logging.log4j.LogManager"%>
<%@page import="org.apache.logging.log4j.Logger"%>
<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%
	boolean logflag = true;
	Logger logger = LogManager.getLogger();

	logger.info("fujianzhonghang entry1");

	//获取公共参数
	String taskid = request.getAttribute("taskid").toString();
	String routeid = request.getAttribute("routeid").toString();
	String phone = request.getAttribute("phone").toString();
	String packageid = request.getAttribute("package").toString();

	logger.info("fujianzhonghang entry2");

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

			String v = routeparams.get("v");
			if (v == null) {
				request.setAttribute("result",
						"S." + routeid
								+ ":wrong routeparams, v  is null@"
								+ TimeUtils.getSysLogTimeString());
				break;
			}

			String account = routeparams.get("account");
			if (account == null) {
				request.setAttribute("result", "S." + routeid
						+ ":wrong routeparams, account is null@"
						+ TimeUtils.getSysLogTimeString());
				break;
			}
			String key = routeparams.get("key");
			if (key == null) {
				request.setAttribute("result", "S." + routeid
						+ ":wrong routeparams, key is null@"
						+ TimeUtils.getSysLogTimeString());
				break;
			}

			String scope = routeparams.get("scope");
			if (scope == null) {
				request.setAttribute("result", "S." + routeid
						+ ":wrong routeparams, scope is null@"
						+ TimeUtils.getSysLogTimeString());
				break;
			}

			String resultTxt = "";

			String flow = "";
			//检查通道参数, 每个通道有不同参数, 对应 ll_routes.api_param
			String packagecodeArray[] = packageid.split("\\.");
			flow = packagecodeArray[1];
			if (flow.contains("G")) {
				flow = Integer.parseInt(flow.substring(0,
						flow.length() - 1)) * 1024 + "M";
			}
			flow = flow.replace("M", "");

			String transno = getNowTime("yyyyMMddHHmmssSSS")
					+ getFixLenthString(5);
			String sign = "";
			String signStr = "account=" + account + "&mobile=" + phone
					+ "&notifyurl=&package=" + flow + "&transno="
					+ transno + "&key=" + key;
			sign = mmd5(signStr);

			/************************************/
			//request.setAttribute("result", "success");
			//break;
			/************************************/

			//在执行请求前先获取连接, 防止访问通道线程超量

			logger.info("fujianzhonghang entry2 Test01:");
			Cache.getConnection(routeid);
			try {
				HttpClient hc = new HttpClient();
				PostMethod mt = new PostMethod(url);
				mt.setRequestHeader("Content-Type",
						"application/x-www-form-urlencoded;charset=UTF-8");
				mt.addParameter("action", "charge");
				mt.addParameter("v", v);
				mt.addParameter("account", account);
				mt.addParameter("mobile", phone);
				mt.addParameter("package", flow);
				mt.addParameter("sign", sign);
				mt.addParameter("transno", transno);
				mt.addParameter("scope", scope);
				mt.addParameter("notifyurl", "");
				int sta = hc.executeMethod(mt);
				if (sta == 200) {
					resultTxt = mt.getResponseBodyAsString();
					resultTxt = decodeUnicode(resultTxt);
					resultTxt = decodeUnicode(resultTxt);
				}
			} catch (Exception e) {
				e.printStackTrace();
				logger.info(e.getMessage());
			} finally {
				//在执行请求后记得释放连接
				Cache.releaseConnection(routeid);
			}
			logger.info("fujianzhonghang entry2 Test02:" + resultTxt);

			JSONObject jbn = JSON.parseObject(resultTxt);
			String code = jbn.getString("code");
			String message = jbn.getString("message");
			String orderId = jbn.getString("orderId");
			String transnoBac = jbn.getString("transno");

			if (code.equals("000")) {
				request.setAttribute("result", "success");
				request.setAttribute("reportid", orderId + phone);
				request.setAttribute("orgreturn", code + ":" + message);
			} else {
				request.setAttribute("result",
						"R." + routeid + ":" + code + ":" + message
								+ "@" + TimeUtils.getSysLogTimeString());
			}

			//JSONObject jbn = JSON.parseObject(result);
			//String status = jbn.getString("status");
			// msgid = jbn.getString("msgid");
			//String description = jbn.getString("description");

			break;

		}
	} catch (Exception e) {
		e.printStackTrace();
		logger.info(e.toString());
		request.setAttribute(
				"result",
				"R." + routeid + ":" + e.toString() + "@"
						+ TimeUtils.getSysLogTimeString());
	}

	request.getRequestDispatcher("request.jsp").forward(request,
			response);
%>

<%!// 小写MD5加密
	private static final char HEX_DIGITS[] = { '0', '1', '2', '3', '4', '5',
			'6', '7', '8', '9', 'a', 'b', 'c', 'd', 'e', 'f' };

	public static String toHexString(byte[] b) {
		// String to byte
		StringBuilder sb = new StringBuilder(b.length * 2);
		for (int i = 0; i < b.length; i++) {
			sb.append(HEX_DIGITS[(b[i] & 0xf0) >>> 4]);
			sb.append(HEX_DIGITS[b[i] & 0x0f]);
		}
		return sb.toString();
	}

	public static String mmd5(String s) {
		try {
			// Create MD5 Hash
			MessageDigest digest = java.security.MessageDigest
					.getInstance("MD5");
			digest.update(s.getBytes());
			byte messageDigest[] = digest.digest();

			return toHexString(messageDigest);
		} catch (NoSuchAlgorithmException e) {
			e.printStackTrace();
		}

		return "";
	}

	/**
	 * 
	 * 
	 * 
	 * unicode 转换成 中文
	 * 
	 * @param theString
	 * 
	 * @return
	 */

	public static String decodeUnicode(String theString) {

		char aChar;

		int len = theString.length();

		StringBuffer outBuffer = new StringBuffer(len);

		for (int x = 0; x < len;) {

			aChar = theString.charAt(x++);

			if (aChar == '\\') {

				aChar = theString.charAt(x++);

				if (aChar == 'u') {

					// Read the xxxx

					int value = 0;

					for (int i = 0; i < 4; i++) {

						aChar = theString.charAt(x++);

						switch (aChar) {

						case '0':

						case '1':

						case '2':

						case '3':

						case '4':

						case '5':

						case '6':

						case '7':

						case '8':

						case '9':

							value = (value << 4) + aChar - '0';

							break;

						case 'a':

						case 'b':

						case 'c':

						case 'd':

						case 'e':

						case 'f':

							value = (value << 4) + 10 + aChar - 'a';

							break;

						case 'A':

						case 'B':

						case 'C':

						case 'D':

						case 'E':

						case 'F':

							value = (value << 4) + 10 + aChar - 'A';

							break;

						default:

							throw new IllegalArgumentException(

							"Malformed   \\uxxxx   encoding.");

						}

					}

					outBuffer.append((char) value);

				} else {

					if (aChar == 't')

						aChar = '\t';

					else if (aChar == 'r')

						aChar = '\r';

					else if (aChar == 'n')

						aChar = '\n';

					else if (aChar == 'f')

						aChar = '\f';

					outBuffer.append(aChar);

				}

			} else

				outBuffer.append(aChar);

		}

		return outBuffer.toString();

	}

	/*
	 * 返回长度为【strLength】的随机数，在前面补0
	 */
	public static String getFixLenthString(int strLength) {

		Random rm = new Random();

		// 获得随机数
		double pross = (1 + rm.nextDouble()) * Math.pow(10, strLength);

		// 将获得的获得随机数转化为字符串
		String fixLenthString = String.valueOf(pross);

		// 返回固定的长度的随机数
		return fixLenthString.substring(1, strLength + 1);
	}

	public static String getNowTime(String timeType) {
		// 设置日期格式.如："yyyy-MM-dd HH:mm:ss:SSS"
		SimpleDateFormat df = new SimpleDateFormat(timeType);
		// new Date()为获取当前系统时间
		String nowTime = df.format(new Date());
		return nowTime;
	}%>

