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
	logger.info("root chuanglan");
	//获取公共参数
	String routeid = request.getAttribute("routeid").toString();
	String orderid = request.getAttribute("ids").toString();
	if (orderid.contains(",")) {
		orderid = orderid.substring(0, orderid.indexOf(","));
	}
	logger.info("status chuanglan orderid = " + orderid);

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

			String account = routeparams.get("account");
			if (account == null) {
				request.setAttribute("result", "S." + routeid
						+ ":wrong routeparams, account  is null@"
						+ TimeUtils.getSysLogTimeString());
				break;
			}

			String key = routeparams.get("key");
			if (key == null) {
				request.setAttribute("result", "S." + routeid
						+ ":wrong routeparams, key  is null@"
						+ TimeUtils.getSysLogTimeString());
				break;
			}

			//
			String resultTxt = "";

			String extId = "";
			String signature = "";

			url += "checkStatus";
			extId = orderid;
			signature = "account=" + account + "&ext_id=" + extId
					+ "key=" + key;

			//发送查询/获取状态前先获取连接, 防止访问线程超量
			Cache.getStatusConnection(routeid);
			try {

				HttpClient hc = new HttpClient();
				PostMethod mt = new PostMethod(url);
				mt.addParameter("account", account);
				mt.addParameter("ext_id", extId);
				mt.addParameter("signature", signature);
				int sta = hc.executeMethod(mt);
				if (sta == 200) {
					resultTxt = mt.getResponseBodyAsString();
					System.out.println("return:" + resultTxt);
				} else {
					System.out.println("HttpError:" + sta);
				}

				logger.info("status chuanglan resultTxt = " + resultTxt);
			} catch (Exception e) {
				e.printStackTrace();
				logger.info(e.getMessage());
			} finally {
				//发送查询/获取状态后释放连接
				Cache.releaseStatusConnection(routeid);
			}
			JSONObject obj = new JSONObject();

			JSONArray ja = JSON.parseArray(resultTxt);
			for (int i = 0; i < ja.size(); i++) {
				JSONObject jb = ja.getJSONObject(i);
				String code = jb.getString("code");
				String desc = jb.getString("desc");
				String extidBac = jb.getString("ext_id");

				JSONObject rp = new JSONObject();
				rp.put("resp", code + "." + desc);

				if (code.equals("0")) {
					System.out.println("充值成功.");
					rp.put("message", "success");
					rp.put("code", "0");
					obj.put(extidBac, rp);
				} else if (code.equals("000015")) {
					System.out.println("充值失败.");
					rp.put("message", code.replace("success", ""));
					rp.put("code", "-20");
					obj.put(extidBac, rp);
				} 
			}
			request.setAttribute("retjson", obj.toString());
			request.setAttribute("result", "success");

			break;
		}

		logger.info("mopinstausTest");
	} catch (Exception e) {
		e.printStackTrace();
		logger.info("root chuanglan" + e.toString());
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
