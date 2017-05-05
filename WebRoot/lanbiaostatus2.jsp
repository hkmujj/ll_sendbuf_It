<%@page import="java.net.URLDecoder,
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
		language="java" pageEncoding="UTF-8"
%><%!
	
	public static Logger logger = LogManager.getLogger();
	
	// 查询状态报告
	public static String inquer(JSONObject obj) {
		//
		String url = "http://120.25.135.185:9301/lcll/xml/api.jsp";

		String action = "querystatus";
		String userid = "10296";
		String password = "57d0bb01910ff92ce9fd2f4c22b84262";


		//String userid = "10302";
		//String password = "f526bcc0a468b69bb0298c5f4a41eb2a";
		
		String taskid = obj.getString("orderId");
		String dbstr = LLTempDatabase.getMapValue("lanbiao", taskid, "02");
		JSONObject jo = null;
		
		if(dbstr != null){
			try {
				jo = JSONObject.fromObject(dbstr);
			} catch (Exception e) {
				logger.info("lanbiao status json data = " + obj);
			}
		}
		
		if(dbstr == null || jo == null){
			JSONObject obja = new JSONObject();
			obja.put("orderId", obj.getString("orderId"));
			obja.put("channelOrderId", "");
			obja.put("status", 3);
			obja.put("channelType", "2");
			return obja.toString();
		}
		
		taskid = jo.getString("channelOrderId");

		HashMap<String, String> params = new LinkedHashMap<String, String>();
		params.put("action", action);
		params.put("userid", userid);
		params.put("password", password);
		params.put("taskid", taskid);

		String ret = HttpAccess.postNameValuePairRequest(url, params, "utf-8", "lanbiaostatus");

		System.out.println("ret=" + ret);

		String orderId;
		String status;
		String channelOrderId;
		String channelType;
		String resultCode = null;
		String resultDesc = null;

		Document document;
		try {
			document = DocumentHelper.parseText(ret);
		} catch (DocumentException e) {
			e.printStackTrace();
			return null;
		}
		Element root = document.getRootElement();
		channelOrderId = taskid;
		orderId = obj.getString("orderId");
		channelType = "2";
		String info = root.attribute("info").getText();
		String definfo = "Table 'llmain.rec_task";
		if (root.attribute("taskid") == null) {
			if (info.contains(definfo) || info.equals("成功")) {
				status = "3";
				// resultCode="0001";
				// resultDesc="查询不到订单";

			} else {
				status = "4";
				resultCode = "0002";
				// resultDesc="查询异常";
				resultDesc = info;
			}
		} else if (root.attribute("code") == null) {
			status = "2";
			// resultCode="0003";
			// resultDesc="充值中";
		} else if (root.attribute("code").getText().equals("0")) {
			status = "1";
			// resultCode="0000";
			// resultDesc="充值成功";
		} else {
			status = "0";
			// resultCode="0004";
			// resultDesc="充值失败";
			resultCode = root.attribute("code").getText();
			resultDesc = root.attribute("message").getText();
		}

		JSONObject obja = new JSONObject();
		obja.put("orderId", orderId);
		obja.put("channelOrderId", channelOrderId);
		obja.put("status", status);
		obja.put("channelType", channelType);
		if (resultCode != null) {
			obja.put("resultCode", resultCode);
			obja.put("resultDesc", resultDesc);
		}
		/*
		 * String orderId; String channelOrderId; String phoneNumber;
		 * orderId=obj.getString("orderId");
		 * channelOrderId=obj.getString("channelOrderId");
		 * phoneNumber=obj.getString("phoneNumber");
		 */
		return obja.toString();
	}
 %><%
	logger.info("lanbiao status entry");
	
	Map<String, String[]> paramMap = request.getParameterMap();
	if(paramMap != null){
		for(Entry<String, String[]> param : paramMap.entrySet()){
			logger.info("lanbiao status key = " + param.getKey() + ", value = " + param.getValue()[0]);
		}
	}
	
	String str = MyStringUtils.inputStringToString(request.getInputStream());
	if(str == null || str.length() <= 0){
		str=request.getParameter("json");
	}
	
	if(str == null || str.length() <= 0){
		if(request.getQueryString() != null){
			str = URLDecoder.decode(request.getQueryString(), "utf-8");
		}
	}

	logger.info("lanbiao status json = " + str);
	
	JSONObject obj = null;
	
	try {
		obj = JSONObject.fromObject(str);
	} catch (Exception e) {
		logger.error(e.getMessage(), e);
	}
	if(obj == null){
		out.print("bad json data");
	}else{
		out.print(inquer(obj));
	}
%>