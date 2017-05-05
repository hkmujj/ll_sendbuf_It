<%@page import="org.dom4j.DocumentHelper"%>
<%@page import="org.dom4j.Element"%>
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
	logger.info("root zhuowang");
	//获取公共参数
	String routeid = request.getAttribute("routeid").toString();
	String orderid = request.getAttribute("ids").toString();
	if (orderid.contains(",")) {
		orderid = orderid.substring(0, orderid.indexOf(","));
	}
	logger.info("status zhuowang orderid = " + orderid);

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

			String key = routeparams.get("key");
			if (key == null) {
				request.setAttribute("result", "S." + routeid
						+ ":wrong routeparams, key  is null@"
						+ TimeUtils.getSysLogTimeString());
				break;
			}

			String eccode = routeparams.get("eccode");
			if (eccode == null) {
				request.setAttribute("result", "S." + routeid
						+ ":wrong routeparams, eccode  is null@"
						+ TimeUtils.getSysLogTimeString());
				break;
			}

			//
			String resultTxt = "";

			String action = "MeberShipQuery";
			String requestid = "";
			String requesttoken = "";

			url = url + "/MeberShipQuery";
			requestid = orderid;

			requesttoken = requestid + "+" + mmd5(key);
			requesttoken = mmd5(requesttoken);

			Element requestEle = DocumentHelper
					.createElement("REQUEST");
			requestEle.addElement("ACTION").addText(action);
			requestEle.addElement("RequestID").addText(requestid);
			requestEle.addElement("RequestToken").addText(requesttoken);
			requestEle.addElement("ECCode").addText(eccode);

			String xml = "<?xml version='1.0' encoding='utf-8'?>"
					+ requestEle.asXML();

			//发送查询/获取状态前先获取连接, 防止访问线程超量
			Cache.getStatusConnection(routeid);
			try {

				HttpClient hc = new HttpClient();
				PostMethod mt = new PostMethod(url);
				mt.setRequestBody(xml);
				int stat = hc.executeMethod(mt);
				if (stat == 200) {
					resultTxt = mt.getResponseBodyAsString();
					System.out.println("return:" + resultTxt);
				} else {
					System.out.println("HttpError:" + stat);
				}

				logger.info("status zhuowang resultTxt = " + resultTxt);
			} catch (Exception e) {
				e.printStackTrace();
				logger.info(e.getMessage());
			} finally {
				//发送查询/获取状态后释放连接
				Cache.releaseStatusConnection(routeid);
			}

			JSONObject obj = new JSONObject();
			Element resEle = DocumentHelper.parseText(resultTxt)
					.getRootElement();
			String retCode = resEle.element("retCode").getText();
			JSONObject rp = new JSONObject();
			if ("0".equals(retCode)) {
				String requestID = resEle.element("RequestID")
						.getText();
				Element eleBODY = resEle.element("BODY");
				String ordNum = eleBODY.element("OrdNum").getText();
				Element eleMember = eleBODY.element("Member");
				String resultMobile = eleMember.element("Mobile")
						.getText();
				String CRMApplyCode = eleMember.element("CRMApplyCode")
						.getText();
				//0＝成功，-1 = 失败,1 = 正在处理中,该接口返回含义与充值接口不同，代表提交到上游接口的状态
				String resultCode = eleMember.element("ResultCode")
						.getText();
				String resultMsg = eleMember.element("ResultMsg")
						.getText();
				System.out.println("查询结果:" + resultMobile
						+ CRMApplyCode + resultCode + resultMsg);

				if ("0".equals(resultCode)) {
					rp.put("message", "success");
					rp.put("code", "0");
					obj.put(requestID, rp);
				} else if ("-1".equals(resultCode)) {
					rp.put("message", resultCode.replace("success", ""));
					rp.put("code", "-10");
					obj.put(requestID, rp);
				} else {
					System.out.println("充值中:" + retCode + ":"
							+ resultMsg);
				}
			} else {
				String retMsg = resEle.element("retMsg").getText();
				System.out.println("查询失败:" + retCode + ":" + retMsg);
			}
			request.setAttribute("retjson", obj.toString());
			request.setAttribute("result", "success");

			break;
		}

		logger.info("mopinstausTest");
	} catch (Exception e) {
		e.printStackTrace();
		logger.info("root zhuowang" + e.toString());
		request.setAttribute(
				"result",
				"R." + routeid + ":" + e.toString() + "@"
						+ TimeUtils.getSysLogTimeString());
	}
	request.getRequestDispatcher("request.jsp").forward(request,
			response);
%>

<%!public static String mmd5(String s) {
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

	// 大写MD5加密
	private static final char HEX_DIGITS[] = { '0', '1', '2', '3', '4', '5',
			'6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F' };

	public static String toHexString(byte[] b) {
		// String to byte
		StringBuilder sb = new StringBuilder(b.length * 2);
		for (int i = 0; i < b.length; i++) {
			sb.append(HEX_DIGITS[(b[i] & 0xf0) >>> 4]);
			sb.append(HEX_DIGITS[b[i] & 0x0f]);
		}
		return sb.toString();
	}%>
