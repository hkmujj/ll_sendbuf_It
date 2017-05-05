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
	
	private static byte[] vlock = new byte[0];
	
	public static String decrypt(String content, String password) throws Exception {
		KeyGenerator kgen = KeyGenerator.getInstance("AES");
		SecureRandom random = SecureRandom.getInstance("SHA1PRNG");
		random.setSeed(password.getBytes());
		kgen.init(128, random);
		SecretKey secretKey = kgen.generateKey();
		byte[] enCodeFormat = secretKey.getEncoded();
		SecretKeySpec key = new SecretKeySpec(enCodeFormat, "AES");
		Cipher cipher = Cipher.getInstance("AES/ECB/PKCS5Padding");
		cipher.init(2, key);
		byte[] result = cipher.doFinal(Base64.decodeBase64(content));
		if ((result != null) && (result.length > 0)) {
			logger.debug("[AESUtils][decrypt][result.length]:" + result.length);
			logger.debug("[AESUtils][decrypt][result]:"
					+ new String(result, "utf-8"));
			return new String(result, "utf-8");
		} else {
			logger.debug("[AESUtils][decrypt][result] is null");
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
	
	// 流量充值
	public static String handleRecharge(JSONObject obj) {

		String data;
		String partyId;
		String sign;
		String time;
		String password;
		
		String jsondata;

		JSONObject dataObj = new JSONObject();
		data = obj.getString("data");
		partyId = obj.getString("partyId");
		sign = obj.getString("sign");
		time = obj.getString("time");
		String md5sign;

		// 判断签名
		md5sign = getSignAndMD5(partyId, data, time);
		if (md5sign.equals(sign)) {
			password = "16E9B9BA838B8C7E24420FE13ADDB25E";// 下家提供password
			//password = "1B401AD9A60A71D50388C563A0EFE7A7";// 下家提供password
			try {
				jsondata = decrypt(data, password);
			} catch (Exception e) {
				e.printStackTrace();
				jsondata = null;
			}
			dataObj = JSONObject.fromObject(jsondata);
		} else {
			return null;
		}
		return doRecharge(dataObj);
	}
	
	// 充值流量类型
	public static String doRecharge(JSONObject obj) {
		logger.info("lanbiao doRecharge:" + obj.toString());
		String url = "http://120.25.135.185:9301/lcll/xml/api.jsp";
		String action = "charge";
		
		String userid = "10296";
		String password = "57d0bb01910ff92ce9fd2f4c22b84262";
		
		//String userid = "10302";
		//String password = "f526bcc0a468b69bb0298c5f4a41eb2a";
		
		String phone = obj.getString("phoneNumber");
		String mbytes = obj.getString("amount");
		
		String orderId;
		orderId = obj.getString("orderId");
		
		JSONObject reponseObj = new JSONObject();
		String channelOrderId = null;
		String status = null;
		String resultCode = null;
		String failReason = null; 
			
		synchronized(vlock){
			String val = LLTempDatabase.getMapValue("lanbiao", orderId, "02");
			
			if(val == null){
	
				HashMap<String, String> params = new LinkedHashMap<String, String>();
				params.put("action", action);
				params.put("userid", userid);
				params.put("password", password);
				params.put("phone", phone);
				params.put("mbytes", mbytes);
				params.put("linkid", orderId);
		
				String ret = HttpAccess.postNameValuePairRequest(url, params, "utf-8", "lanbiaosend");
				System.out.println("ret=" + ret);
				
				Document document;
				try {
					document = DocumentHelper.parseText(ret);
				} catch (DocumentException e) {
					e.printStackTrace();
					return null;
				}
				Element root = document.getRootElement();
		
				String returnval = root.attribute("return").getText();
				if (returnval.equals("0")) {
					status = "1";
					resultCode = "00000";
					channelOrderId = root.attribute("taskid").getText();
					reponseObj.put("channelOrderId", channelOrderId);
					obj.put("channelOrderId", channelOrderId);
					LLTempDatabase.putMap("lanbiao", orderId, obj.toString(), "02");
				} else {
					status = "0";
					if(returnval.equals("1001002")){
						resultCode = "10011";
						failReason = "账户余额不足";
					}else if(returnval.equals("1002011")){
						resultCode = "10013";
						failReason = "所充值的产品不存在";
					}else{
						resultCode = returnval;
						failReason = root.attribute("info").getText();
					}
				}
			}else{
				status = "0";
				resultCode = "10008";
				failReason = "订单重复";
			}
		}
		
		logger.info("lanbiao request = " + obj.toString() + ", taskid = " + channelOrderId);
		
		reponseObj.put("orderId", orderId);
		reponseObj.put("status", status);
		reponseObj.put("resultCode", resultCode);
		reponseObj.put("failReason", failReason);
	

		return reponseObj.toString();

	}
 %><%
	logger.info("lanbiao recharge entry");
	
	Map<String, String[]> paramMap = request.getParameterMap();
	if(paramMap != null){
		for(Entry<String, String[]> param : paramMap.entrySet()){
			logger.info("lanbiao recharge key = " + param.getKey() + ", value = " + param.getValue()[0]);
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

	logger.info("lanbiao recharge json = " + str);
	
	if(str == null || str.trim().length() <= 0){
		out.print("bad json data");
		return;
	}
	
	JSONObject obj = null;
	try {
		obj = JSONObject.fromObject(str);
	} catch (Exception e) {
		logger.error(e.getMessage(), e);
	}
	if(obj == null){
		out.print("bad json data");
	}else{
		String retstr = handleRecharge(obj);
		logger.info("lanbiao recharge ret = " + retstr);
		out.print(retstr);
	}
%>