<%@page import="java.util.Iterator"%>
<%@page import="http.HttpsAccess,
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
				net.sf.json.JSONObject,
				org.apache.logging.log4j.LogManager,
				org.apache.logging.log4j.Logger" 
		language="java" pageEncoding="UTF-8"
%><%!
	
	public static Logger logger = LogManager.getLogger();
	
	public static String encrypt(String content, String password)
			throws Exception {
		KeyGenerator kgen = KeyGenerator.getInstance("AES");
		SecureRandom random = SecureRandom.getInstance("SHA1PRNG");
		random.setSeed(password.getBytes());
		kgen.init(128, random);
		SecretKey secretKey = kgen.generateKey();
		byte[] enCodeFormat = secretKey.getEncoded();
		SecretKeySpec key = new SecretKeySpec(enCodeFormat, "AES");
		Cipher cipher = Cipher.getInstance("AES/ECB/PKCS5Padding");
		byte[] byteContent = content.getBytes("utf-8");
		cipher.init(1, key);
		byte[] result = cipher.doFinal(byteContent);
		if ((result != null) && (result.length > 0)) {
			return Base64.encodeBase64URLSafeString(result);
		}
		return null;
	}
	
	public static String strToMd5(String str, String charSet) {
		String md5Str = null;
		if (str != null && str.length() != 0) {
			try {
				MessageDigest md = MessageDigest.getInstance("MD5");
				md.update(str.getBytes(charSet));
				byte b[] = md.digest();
				int i;
				StringBuffer buf = new StringBuffer("");
				for (int offset = 0; offset < b.length; offset++) {
					i = b[offset];
					if (i < 0)
						i += 256;
					if (i < 16)
						buf.append("0");
					buf.append(Integer.toHexString(i));
				}
				md5Str = buf.toString();
			} catch (NoSuchAlgorithmException e) {
				logger.error("MD5加密发生异常。加密串：" + str);
			} catch (UnsupportedEncodingException e2) {
				logger.error("MD5加密发生异常。加密串：" + str);
			}
		}
		return md5Str;
	}

	/**
	 * 按照字典序逆序拼接参数
	 * 
	 * @param params
	 * @return
	 */
	public static String getSign(String... params) {
		List<String> srcList = new ArrayList<String>();
		for (String param : params) {
			srcList.add(param);
		}
		// 按照字典序逆序拼接参数
		Arrays.sort(params);
		Collections.sort(srcList, String.CASE_INSENSITIVE_ORDER);
		Collections.reverse(srcList);
		StringBuilder sb = new StringBuilder();
		for (int i = 0; i < srcList.size(); i++) {
			sb.append(srcList.get(i));
		}
		return sb.toString();
	}

	/***
	 * MD5加密调用
	 */
	public static String getSignAndMD5(String... params) {
		String sign = getSign(params);
		return strToMd5(sign, "utf-8");
	}
	
	public static void report(Document doc) {
		String taskid;
		String linkid;

		String data;
		String time;
		String partyId = "10024";
		String sign;

		// 加密的时候用的apiKey（蓝标提供）
		//String apiKey = "16E9B9BA838B8C7E24420FE13ADDB25E";
		String apiKey = "1B401AD9A60A71D50388C563A0EFE7A7";
		String orderId  ;
		String channelOrderId ;
		String phoneNumber ;
		String amount ;
		String type ;
		String channelType = "2";
		String status ;
		String resultCode ;
		String failReason = null;
		String payAmount = null;
		String ext ;
		
		logger.info("lanbiao ready get root");
		
		Element root = doc.getRootElement();
		
		for(Iterator<Element> iter = root.elementIterator("status"); iter.hasNext();){
			Element element = iter.next();
			
			logger.info("lanbiao ready taskid");
			
			taskid = element.attribute("taskid").getText();
			
			logger.info("lanbiao ready get code");
			
			String code=element.attribute("code").getText();
			
			logger.info("lanbiao ready get linkid");
			
			linkid = element.attribute("linkid").getText();
			
			if (code.equals("0")) {
				status="1";
				resultCode="00000";
			}
			else {
				status="0";
				resultCode=code;
			}
		
			channelOrderId=taskid;		
			// 以channelOrderId为参数从数据库提取data
			logger.info("lanbiao ready database");
			
			String dataJson=LLTempDatabase.getMapValue("lanbiao", linkid, "02");
			//LLTempDatabase.deleteMapData("lanbiao", channelOrderId, "02");
			
			logger.info("lanbiao data taskid = " + channelOrderId + ", json = " + dataJson);
			
			if(dataJson != null && dataJson.length() > 0){
				JSONObject dataObj=JSONObject.fromObject(dataJson);
				orderId=dataObj.getString("orderId");
				phoneNumber=dataObj.getString("phoneNumber");
				amount=dataObj.getString("amount");
				type=dataObj.getString("type");
				ext=dataObj.getString("ext");
			}else{
				orderId="";
				phoneNumber="";
				amount="";
				type="";
				ext="";
			}
			
			JSONObject obj = new JSONObject();
			obj.put("orderId", orderId);
			obj.put("channelOrderId", channelOrderId);
			obj.put("phoneNumber", phoneNumber);
			obj.put("amount", amount);
			obj.put("type", type);
			obj.put("channelType", channelType);
			obj.put("status", status);
			obj.put("resultCode", resultCode);
			obj.put("failReason", failReason);
			obj.put("payAmount", payAmount);
			obj.put("ext", ext);
			
			logger.info("lanbiao return call obj = " + obj.toString());
			
			try {
				data = encrypt(obj.toString(), apiKey);
			} catch (Exception e) {
				e.printStackTrace();
				data = null;
			}
			time = TimeUtils.getTimeStamp();
			sign = getSignAndMD5(partyId, data, time);
			
			JSONObject objReport = new JSONObject();
			objReport.put("partyId", partyId);
			objReport.put("data", data);
			objReport.put("time", time);
			objReport.put("sign", sign);
			String rpurl = "https://chong.blueplus.cc/cgi_bin/callBackController/callBack";
			//String rpurl = "https://sandbox.blueplus.cc/cgi_bin/callBackController/callBack";
	
			String lbret = HttpsAccess.postJsonRequest(rpurl, objReport.toString(), "utf-8", "lanbiaocall");
			
			logger.info("lanbiao rpstr = " + objReport.toString() + ", lbret = " + lbret);
			
			for(int v = 0; v < 2 && lbret == null; v++){
				//out.print("fail : return null");
				//return;
				try {
					Thread.sleep(1000);
				} catch (InterruptedException e) {
					e.printStackTrace();
				}
				lbret = HttpsAccess.postJsonRequest(rpurl, objReport.toString(), "utf-8", "lanbiaocall");
			}
			
		}
	}
 %><%
	logger.info("lanbiao return entry");
	
	Map<String, String[]> paramMap = request.getParameterMap();
	if(paramMap != null){
		for(Entry<String, String[]> param : paramMap.entrySet()){
			logger.info("lanbiao return key = " + param.getKey() + ", value = " + param.getValue()[0]);
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

	logger.info("lanbiao return xml = " + str);
	
	Document obj = null;
	try {
		obj = DocumentHelper.parseText(str);
	} catch (Exception e) {
		logger.error(e.getMessage(), e);
	}
	if(obj == null){
		out.print("bad xml data");
		logger.info("lanbiao return bad xml data");
		return;
	}
	
	logger.info("lanbiao ready report");
	
	report(obj);
	
	out.print("success");
%>