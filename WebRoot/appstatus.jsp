<%@page import="org.dom4j.DocumentException"%>
<%@page import="java.security.MessageDigest"%>
<%@page import="org.dom4j.DocumentHelper,
				org.dom4j.Document,
				org.dom4j.Element,
				java.util.Map.Entry,
				database.LLTempDatabase,
				util.MD5Util,
				net.sf.json.JSONArray,
				util.TimeUtils,
				http.HttpAccess,
				cache.Cache,
				net.sf.json.JSONException,
				net.sf.json.JSONObject,
				java.util.*,
				util.MyStringUtils,
				java.net.URLDecoder,
				org.apache.logging.log4j.LogManager,
				org.apache.logging.log4j.Logger" 
		language="java" pageEncoding="UTF-8"
%><%!
	public static byte[] vlock = new byte[0];
	public static Object hashobj = new Object();
	public static HashMap<String, Object> odmap = new HashMap<String, Object>();

	public final static String myMD5(String s) {
		String ret = null;
		try {
			byte[] btInput = s.getBytes("utf-8");
			// 获得MD5摘要算法的 MessageDigest 对象
			MessageDigest mdInst = MessageDigest.getInstance("MD5");
			// 使用指定的字节更新摘要
			mdInst.update(btInput);
			// 获得密文
			byte[] md = mdInst.digest();
			// 把密文转换成十六进制的字符串形式
			ret = new org.apache.commons.codec.binary.Base64().encodeToString(md);
		} catch (Exception e) {
			e.printStackTrace();
			return null;
		}
		
		return ret;
	}
%><%
	
	out.clearBuffer();

	boolean logflag = true;
	Logger logger = LogManager.getLogger();
	
	logger.info("app status entry");
	
	Map<String, String[]> paramMap = request.getParameterMap();
	if(paramMap != null){
		for(Entry<String, String[]> param : paramMap.entrySet()){
			logger.info("app return key = " + param.getKey() + ", value = " + param.getValue()[0]);
		}
	}
	
	String str = MyStringUtils.inputStringToString(request.getInputStream());
	if(str == null || str.length() <= 0){
		str=request.getParameter("xml");
	}
	
	if(str == null || str.length() <= 0){
		if(request.getQueryString() != null){
			str = URLDecoder.decode(request.getQueryString(), "utf-8");
		}
	}
	
	if(str == null){
		logger.info("app status no request data");
		out.print("no request data");
		return;
	}
	
	logger.info("app status str = " + str);
	
	Document obj = null;
	
	try {
		obj = DocumentHelper.parseText(str);
	} catch (Exception e) {
		logger.error(e.getMessage(), e);
	}
	
	if(obj == null){
		logger.info("app status bad xml data");
		out.print("bad xml data");
		return;
	}
	
	try{
		Element retxml = DocumentHelper.createElement("request");
		Element headElement =  retxml.addElement("head");
		
		Element custInteIdElement = headElement.addElement("custInteId");
		Element echoElement = headElement.addElement("echo");
		Element timestampElement = headElement.addElement("timestamp");
		Element chargeSignElement = headElement.addElement("chargeSign");
		
		String custInteId = "10383";
		String secretKey = "79e13d86a778aabcd998ea86c4895066";
		String echo = "" + new Random().nextInt(10000000);
		String timestamp = TimeUtils.getTimeStamp();//YYYYMMDDHHMMSS
		String sign = custInteId + secretKey + echo + timestamp; 
		
		String chargeSign = myMD5(sign);
		
		custInteIdElement.setText(custInteId);
		echoElement.setText(echo);
		timestampElement.setText(timestamp);
		chargeSignElement.setText(chargeSign);
		
		Element bodyElement =  retxml.addElement("body");
		
		Element root = obj.getRootElement();
		Element status = null;
		for(Iterator<Element> iter = root.elementIterator("status"); iter.hasNext();){
			status = iter.next();
			Element itemElement = bodyElement.addElement("item");

			String linkid = status.attributeValue("linkid");
			String json = LLTempDatabase.getMapValue("app", linkid, "05");
			itemElement.addElement("orderId").setText(linkid);
			
			itemElement.addElement("orderType").setText("");
			itemElement.addElement("packCode").setText("");
			itemElement.addElement("mobile").setText("");
			
			if(status.attributeValue("code").equals("0")){
				itemElement.addElement("result").setText("0000");
				itemElement.addElement("desc").setText("成功");
			}else{
				itemElement.addElement("result").setText("8810");
				itemElement.addElement("desc").setText(status.attributeValue("message"));
			}
			
			try{
				JSONObject jsonobj = JSONObject.fromObject(json);
				if(jsonobj.get("mobile") != null){
					itemElement.element("mobile").setText(jsonobj.getString("mobile"));
				}
				if(jsonobj.get("packCode") != null){
					itemElement.element("packCode").setText(jsonobj.getString("packCode"));
				}
				if(jsonobj.get("orderType") != null){
					itemElement.element("orderType").setText(jsonobj.getString("orderType"));
				}
			}catch(Exception e){
				logger.error(e.getMessage(), e);
			}
		}
		
		String returnurl = "http://183.131.89.226:15348/traffic/tsg/CMCC_TSG_LLGH";
		String ret = HttpAccess.postXmlRequest(returnurl, retxml.asXML(), "utf-8", "app");
		logger.info("app return ret = " + ret + ", retxml = " + retxml.asXML());
		out.print("success");
	}catch(Exception e){
		logger.error(e.getMessage(), e);
		out.print(e.getMessage());
		return;
	}
	
%>