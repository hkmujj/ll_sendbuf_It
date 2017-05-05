<%@page import="java.util.Collection"%>
<%@page import="util.MD5Util"%>
<%@page
	import="java.net.URLDecoder,
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
				net.sf.json.JSONObject,
				org.apache.logging.log4j.LogManager,
				org.apache.logging.log4j.Logger"
	language="java" pageEncoding="UTF-8"%><%!public static Logger logger = LogManager.getLogger();

	// 查询状态报告
	public static String inquer(String orderId, String uid) {
		//
		String url = "http://120.25.135.185:9301/lcll/xml/api.jsp";

		String action = "querystatus";
		//String userid = "10296";
		//String password = "57d0bb01910ff92ce9fd2f4c22b84262";
		//String userid = "10301";
		//String password = "60a4b80d4af5e61a0bf600b0e986da74";
		String userid = "";
		String password = "";

		if (uid.equals("yunmchuan")) {
			userid = "10551";
			password = "f2b9a17600311994efb384f53140ee8f";
		} else if (uid.equals("yunmchuan1")) {
			userid = "10589";
			password = "e0a124c4be03ddb62d62303b6017547a";
		
		}

		String dbstr = LLTempDatabase.getMapValue("ali", orderId, "07");
		if (dbstr == null) {
			JSONObject obja = new JSONObject();
			obja.put("status", "notExist");
			obja.put("msg", "订单不存在");
			return obja.toString();
		}
		HashMap<String, String> params = new LinkedHashMap<String, String>();
		params.put("action", action);
		params.put("userid", userid);
		params.put("password", password);
		params.put("taskid", dbstr.substring(0, dbstr.length() - 11));

		String ret = HttpAccess.postNameValuePairRequest(url, params, "utf-8", "alistatus");

		System.out.println("ret=" + ret);

		String status = null;
		String msg = null;

		Document document;
		try {
			document = DocumentHelper.parseText(ret);
		} catch (DocumentException e) {
			e.printStackTrace();
			return null;
		}
		Element root = document.getRootElement();
		String info = root.attribute("info").getText();
		String definfo = "Table 'llmain.rec_task";

		if (root.attribute("taskid") == null) {
			if (info.contains(definfo) || info.equals("成功")) {
				status = "notExist";
				msg = "订单不存在";
				// resultCode="0001";
				// resultDesc="查询不到订单";
			}
		} else if (root.attribute("code") == null) {
			status = "processing";
			msg = "订单充值中";
			// resultCode="0003";
			// resultDesc="充值中";
		} else if (root.attribute("code").getText().equals("0")) {
			status = "success";
			msg = "成功";
			// resultCode="0000";
			// resultDesc="充值成功";
		} else {
			status = "fail";
			// resultCode="0004";
			// resultDesc="充值失败";
			msg = "充值失败";
			if (root.attribute("message") != null) {
				msg = root.attribute("message").getText();
			}
			logger.info("ali status=" + root.asXML());
		}

		JSONObject obja = new JSONObject();
		obja.put("status", status);
		obja.put("msg", msg);
		return obja.toString();
	}%>
<%
	logger.info("ali status entry");

	Map<String, String[]> paramMap = request.getParameterMap();
	if (paramMap != null) {
		for (Entry<String, String[]> param : paramMap.entrySet()) {
			logger.info("ali status key = " + param.getKey() + ", value = " + param.getValue()[0]);
		}
	}
	Collection<String> keyset = paramMap.keySet();
	List<String> list = new ArrayList<String>(keyset);

	//对key键值按字典升序排序  
	Collections.sort(list);
	StringBuffer sb = new StringBuffer();
	for (int i = 0; i < list.size(); i++) {
		if (!list.get(i).equals("sign")) {
			sb.append(list.get(i));
			sb.append(paramMap.get(list.get(i))[0]);
		}
	}

	JSONObject json = new JSONObject();
	String orderId = request.getParameter("orderId");
	String phone = request.getParameter("phone");
	String uid = request.getParameter("uid");
	String sign = request.getParameter("sign");
	if (uid != null && uid.equals("yunmchuan")) {
		logger.info("ali send signstr=" + sb.toString());
		String signstr = MD5Util.getLowerMD5(sb.toString());
		logger.info("ali send signstrbac=" + signstr);
		if (sign != null && signstr.equals(sign)) {

			String ret = inquer(orderId, uid);
			out.print(ret);
		} else {
			json.put("status", "fail");
			json.put("msg", "签名认证错误");
			out.print(json.toString());
		}
	} else if (uid != null && uid.equals("yunmchuan1")) {
		logger.info("ali send signstr=" + sb.toString());
		String signstr = MD5Util.getLowerMD5(sb.toString());
		logger.info("ali send signstrbac=" + signstr);
		if (sign != null && signstr.equals(sign)) {

			String ret = inquer(orderId, uid);
			out.print(ret);
		} else {
			json.put("status", "fail");
			json.put("msg", "签名认证错误");
			out.print(json.toString());
		}
	} else {
		json.put("status", "fail");
		json.put("msg", "客户标识不正确");
		out.print(json.toString());
	}
%>