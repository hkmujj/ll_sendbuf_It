<%@page import="org.dom4j.DocumentHelper"%>
<%@page import="org.dom4j.Element"%>
<%@page import="org.apache.http.util.EntityUtils"%>
<%@page import="org.apache.http.HttpResponse"%>
<%@page import="org.apache.http.entity.StringEntity"%>
<%@page import="org.apache.http.client.methods.HttpPost"%>
<%@page import="org.apache.http.impl.client.DefaultHttpClient"%>
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
<%@page import="org.bouncycastle.util.encoders.Hex"%>
<%@page
	import="org.bouncycastle.crypto.paddings.PaddedBufferedBlockCipher"%>
<%@page import="org.bouncycastle.crypto.modes.CBCBlockCipher"%>
<%@page import="org.bouncycastle.crypto.engines.AESFastEngine"%>
<%@page import="org.bouncycastle.crypto.CipherParameters"%>
<%@page import="org.bouncycastle.crypto.params.ParametersWithIV"%>
<%@page import="org.bouncycastle.crypto.params.KeyParameter"%>

<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%
	boolean logflag = true;
	Logger logger = LogManager.getLogger();

	logger.info("zhuowang entry1");

	//获取公共参数
	String taskid = request.getAttribute("taskid").toString();
	String routeid = request.getAttribute("routeid").toString();
	String phone = request.getAttribute("phone").toString();
	String packageid = request.getAttribute("package").toString();

	logger.info("zhuowang entry2");

	Map<String, String> prdcodeMap = new HashMap<String, String>();
	prdcodeMap.put("10M", "prod.10086000000121");
	prdcodeMap.put("30M", "prod.10000008585101");
	prdcodeMap.put("70M", "prod.10000008585102");
	prdcodeMap.put("150M", "prod.10000008585103");
	prdcodeMap.put("500M", "prod.10000008585104");
	prdcodeMap.put("1024M", "prod.10000008585105");
	prdcodeMap.put("2048M", "prod.10000008585106");
	prdcodeMap.put("3072M", "prod.10000008585107");
	prdcodeMap.put("4096M", "prod.10000008585108");
	prdcodeMap.put("6144M", "prod.10000008585109");
	prdcodeMap.put("11264M", "prod.10000008585110");

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

			String resultTxt = "";
			//KB流量大小
			String flow = "";
			//检查通道参数, 每个通道有不同参数, 对应 ll_routes.api_param
			String packagecodeArray[] = packageid.split("\\.");
			flow = packagecodeArray[1];
			if (flow.contains("G")) {
				flow = Integer.parseInt(flow.substring(0,
						flow.length() - 1)) * 1024 + "M";
			}

			/* 
			if (productId == null | ("").equals(productId)) {
				request.setAttribute("result", "R." + routeid
						+ ":没有对应产品@" + TimeUtils.getSysLogTimeString());
				return;
			}
			 */

			/************************************/
			//request.setAttribute("result", "success");
			//break;
			/************************************/

			//在执行请求前先获取连接, 防止访问通道线程超量

			String action = "MeberShipRequest";
			String requestid = System.currentTimeMillis() + ""
					+ (int) (Math.random() * 100000 + 100000);
			String requesttoken = "";

			String channelid = "";
			String isnotify = "1";
			String crmapplycode = requestid
					+ (int) (Math.random() * 100000 + 100000);
			String usecycle = "1";
			String mobile = "";
			String username = "";
			String efftype = "2";
			String efftime = "";
			String prdcode = "";
			String opttype = "0";

			url = url + "/free_recharge";
			mobile = phone;
			prdcode = prdcodeMap.get(flow);
			requesttoken = requestid + "+" + mmd5(key);
			requesttoken = mmd5(requesttoken);

			Element requestEle = DocumentHelper
					.createElement("REQUEST");
			requestEle.addElement("ACTION").addText(action);
			requestEle.addElement("RequestID").addText(requestid);
			requestEle.addElement("RequestToken").addText(requesttoken);
			requestEle.addElement("ECCode").addText(eccode);
			// requestEle.addElement("ChannelID").addText();
			requestEle.addElement("IsNotify").addText(isnotify);
			Element bodyEle = DocumentHelper.createElement("BODY");
			Element MemberEle = DocumentHelper.createElement("Member");
			MemberEle.addElement("CRMApplyCode").addText(crmapplycode);
			MemberEle.addElement("UsecyCle").addText(usecycle);
			MemberEle.addElement("Mobile").addText(mobile);
			// MemberEle.addElement("UserName").addText();
			MemberEle.addElement("EffType").addText(efftype);
			// MemberEle.addElement("EffTime").addText();
			MemberEle.addElement("PrdCode").addText(prdcode);
			MemberEle.addElement("OptType").addText(opttype);
			bodyEle.add(MemberEle);
			requestEle.add(bodyEle);
			String xml = "<?xml version='1.0' encoding='utf-8'?>"
					+ requestEle.asXML();

			logger.info("zhuowang entry2 Test01:");
			Cache.getConnection(routeid);
			try {

				HttpClient hc = new HttpClient();
				PostMethod mt = new PostMethod(url);
				mt.setRequestBody(xml);
				int stat = hc.executeMethod(mt);
				if (stat == 200) {
					resultTxt = mt.getResponseBodyAsString();
					System.out.println("resutl:" + resultTxt);
				} else {
					System.out.println("HttpError:" + stat);
				}

			} catch (Exception e) {
				e.printStackTrace();
				logger.info(e.getMessage());
			} finally {
				//在执行请求后记得释放连接
				Cache.releaseConnection(routeid);
			}
			logger.info("zhuowang entry2 Test02:" + resultTxt);

			Element resEle = DocumentHelper.parseText(resultTxt)
					.getRootElement();
			String retCode = resEle.element("retCode").getText();
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
				//0＝成功，1＝其他失败。2=无法识别号码归属地,3=余额不足,充值失败,6=手机号不合法,7=产品未开通
				String resultCode = eleMember.element("ResultCode")
						.getText();
				String resultMsg = eleMember.element("ResultMsg")
						.getText();
				System.out.println("提交结果:" + resultMobile
						+ CRMApplyCode + resultCode + resultMsg);
				if ("0".equals(resultCode)) {
					request.setAttribute("result", "success");
					request.setAttribute("reportid", requestID);
					request.setAttribute("orgreturn", resultCode + ":"
							+ resultMsg);
				} else {
					request.setAttribute("result", "R." + routeid + ":"
							+ resultCode + ":" + resultMsg + "@"
							+ TimeUtils.getSysLogTimeString());
				}

			} else {
				String retMsg = resEle.element("retMsg").getText();
				System.out.println("提交失败:" + retCode + ":" + retMsg);
				request.setAttribute("result",
						"R." + routeid + ":" + retCode + ":" + retMsg
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