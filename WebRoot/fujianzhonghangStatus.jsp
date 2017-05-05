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
	logger.info("root fujianzhonghang");
	//获取公共参数
	String routeid = request.getAttribute("routeid").toString();
	String orderid = request.getAttribute("ids").toString();
	if(orderid.contains(",")){
	orderid = orderid.substring(0, orderid.indexOf(","));
	}
	orderid=orderid.substring(0,orderid.length()-11);
	logger.info("status fujianzhonghang orderid = "
						+ orderid);
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

			//
			String resultTxt = "";

			String sign = "";
			String signStr = "account=" + account + "&orderid="
					+ orderid + "&key=" + key;
			sign = mmd5(signStr);

			//发送查询/获取状态前先获取连接, 防止访问线程超量
			Cache.getStatusConnection(routeid);
			try {
				logger.info("status fujianzhonghang status");
				HttpClient hc = new HttpClient();
				PostMethod mt = new PostMethod(url);
				mt.setRequestHeader("Content-Type",
						"application/x-www-form-urlencoded;charset=UTF-8");
				mt.addParameter("action", "getStatus");
				mt.addParameter("v", v);
				mt.addParameter("account", account);
				mt.addParameter("orderid", orderid);
				mt.addParameter("sign", sign);
				int sta = hc.executeMethod(mt);
				if (sta == 200) {
					resultTxt = mt.getResponseBodyAsString();
					resultTxt = decodeUnicode(resultTxt);
					resultTxt = decodeUnicode(resultTxt);
				}
				//dyresponse = client.execute(dyrequest);
				logger.info("status fujianzhonghang resultTxt = "
						+ resultTxt);
			} catch (Exception e) {
				e.printStackTrace();
				logger.info(e.getMessage());
			} finally {
				//发送查询/获取状态后释放连接
				Cache.releaseStatusConnection(routeid);
			}
			JSONObject obj = new JSONObject();
			/* 
			JSONObject jbn = JSON.parseObject(resultTxt);
			String status=jbn.getString("status");
			String description=jbn.getString("description");
			String reports=jbn.getString("reports");
			if(status.equals("1")){
			JSONArray reportsJsonArray= JSON.parseArray(reports);
			for(int i=0;i<reportsJsonArray.size();i++){
			JSONObject arrayjson=reportsJsonArray.getJSONObject(i);
				String mobile=arrayjson.getString("mobile");
				String msgid=arrayjson.getString("msgid");
				String time=arrayjson.getString("time");
				String statu=arrayjson.getString("status");
				String backTxt=mobile+","+msgid+","+time+","+statu;
				System.out.println(backTxt);
				JSONObject rp = new JSONObject();
				rp.put("resp", backTxt);
				if(statu.equals("00000")){
				rp.put("message", "success");
				rp.put("code", "0");
				}else{
				rp.put("message", statu);
				rp.put("code", "11");
				}
				obj.put(msgid, rp);
			}
			} */

			if (!resultTxt.equals("")) {
				JSONObject jbn2 = JSON.parseObject(resultTxt);
				String code = jbn2.getString("code");
				String message = jbn2.getString("message");
				if (code.equals("000")) {
					JSONArray dataJSONArray = jbn2.getJSONArray("data");
					JSONObject packageJSONObject = new JSONObject();
					for (Object packageStr : dataJSONArray) {
						packageJSONObject = JSON.parseObject(packageStr
								.toString());
					}

					String status = packageJSONObject
							.getString("status");
					String orderid2 = packageJSONObject
							.getString("orderid");
					String mobile = packageJSONObject
							.getString("mobile");
					JSONObject rp = new JSONObject();
					rp.put("resp", status + "." + orderid2);
					if (status.equals("3")) {
						rp.put("message", "success");
						rp.put("code", "0");
						obj.put(orderid2 + mobile, rp);
					} else if (status.equals("2") | status.equals("4")) {
						rp.put("message", status.replace("success", ""));
						rp.put("code", "11");
						obj.put(orderid2 + mobile, rp);
					}
					
				}
			}

			request.setAttribute("retjson", obj.toString());
			request.setAttribute("result", "success");

			break;
		}

		logger.info("fujianzhonghangstausTest");
	} catch (Exception e) {
		e.printStackTrace();
		logger.info("root fujianzhonghang" + e.toString());
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
