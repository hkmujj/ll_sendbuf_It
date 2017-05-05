<%@page import="com.alibaba.fastjson.JSONObject"%>
<%@page import="util.MD5Util"%>
<%@page import="java.util.Iterator"%>
<%@page
	import="http.HttpsAccess,
				util.TimeUtils,
				java.net.URLDecoder,
				util.MyStringUtils,
				java.util.Map.Entry,
				java.util.Map,
				org.dom4j.Element,
				org.dom4j.DocumentException,
				org.dom4j.DocumentHelper,
				org.dom4j.Document,
				http.HttpAccess,
				java.util.LinkedHashMap,
				java.util.HashMap,
				database.LLTempDatabase,
				org.apache.commons.codec.binary.Base64,
				javax.crypto.Cipher,
				javax.crypto.spec.SecretKeySpec,
				javax.crypto.SecretKey,
				java.security.SecureRandom,
				javax.crypto.KeyGenerator,
				java.util.Collections,
				java.util.Arrays,
				java.util.ArrayList,
				java.util.List,
				java.io.UnsupportedEncodingException,
				java.security.NoSuchAlgorithmException,
				java.security.MessageDigest,
				org.apache.logging.log4j.LogManager,
				org.apache.logging.log4j.Logger"
	language="java" pageEncoding="UTF-8"%><%!public static Logger logger = LogManager.getLogger();

	public static void report(Document doc) {
		String taskid;
		String linkid;
		String sign;
		String phoneNumber;
		String status;
		String code;
		String dbstr;
		String msg;
		logger.info("ali ready get root");

		Element root = doc.getRootElement();

		for (Iterator<Element> iter = root.elementIterator("status"); iter.hasNext();) {
			Element element = iter.next();
			taskid = element.attribute("taskid").getText();
			code = element.attribute("code").getText();
			linkid = element.attribute("linkid").getText();
			dbstr = LLTempDatabase.getMapValue("ali", linkid, "07");
			phoneNumber = dbstr.substring(dbstr.length() - 11);
			logger.info("ali return taskid=" + taskid + "@code=" + code + "@linkid=" + linkid);
			if (code.equals("0")) {
				status = "success";
				msg = "成功";

			} else {
				status = "fail";
				msg = "充值失败";
				if (element.attribute("message") != null) {
					msg = element.attribute("message").getText();

				}

			}
			StringBuffer sb = new StringBuffer();
			sb.append("msg");
			sb.append(msg);
			sb.append("orderId");
			sb.append(linkid);
			sb.append("phone");
			sb.append(phoneNumber);
			sb.append("status");
			sb.append(status);
			logger.info("ali return signstr=" + sb.toString());
			sign = MD5Util.getLowerMD5(sb.toString());
			logger.info("ali return signstrbac=" + sign);
			String rpurl = "http://140.205.173.14/flowCallBack.do?";
			//String rpurl = "http://140.205.37.174/flowCallBack.do?";

			StringBuffer sba = new StringBuffer();
			sba.append(rpurl);
			sba.append("msg=");
			sba.append(msg);
			sba.append("&orderId=");
			sba.append(linkid);
			logger.info("ali return3" + sba.toString());
			sba.append("&phone=");
			sba.append(phoneNumber);
			sba.append("&status=");
			sba.append(status);
			sba.append("&sign=");
			sba.append(sign);
			logger.info("ali return url = " + sba.toString());
			String lbret = null;
			for (int z = 0; z < 2 && lbret == null; z++) {
				lbret = HttpAccess.postNameValuePairRequest(sba.toString(), new HashMap(), "utf-8", "alicall");
				try {
					logger.info("ali return lbret = " + lbret + phoneNumber);
					JSONObject json = JSONObject.parseObject(lbret);
					String lbstatus = json.getString("status");
					logger.info("ali return status=" + lbstatus);
					if (!lbstatus.equals("success")) {
						logger.info("ali return msg=" + json.getString("msg"));
						lbret = null;
					}
				} catch (Exception e) {
					e.printStackTrace();
					logger.info("ali returnadd" + e.getMessage());
				}
			}
		}
	}%>
<%
	logger.info("ali return entry");

	Map<String, String[]> paramMap = request.getParameterMap();
	if (paramMap != null) {
		for (Entry<String, String[]> param : paramMap.entrySet()) {
			logger.info("ali return key = " + param.getKey() + ", value = " + param.getValue()[0]);
		}
	}

	String str = MyStringUtils.inputStringToString(request.getInputStream());
	if (str == null || str.length() <= 0) {
		str = request.getParameter("json");
	}

	if (str == null || str.length() <= 0) {
		if (request.getQueryString() != null) {
			str = URLDecoder.decode(request.getQueryString(), "utf-8");
		}
	}

	logger.info("ali return xml = " + str);

	Document obj = null;
	try {
		obj = DocumentHelper.parseText(str);
	} catch (Exception e) {
		logger.error(e.getMessage(), e);
	}
	if (obj == null) {
		out.print("bad xml data");
		logger.info("ali return bad xml data");
		return;
	}

	logger.info("ali return ready report");

	report(obj);

	out.print("success");
%>