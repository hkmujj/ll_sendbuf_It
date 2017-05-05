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
	
	logger.info("app send entry");
	
	String str = MyStringUtils.inputStringToString(request.getInputStream());
	if(str == null || str.length() <= 0){
		str=request.getParameter("xml");
	}
	if(str == null || str.length() <= 0){
		if(request.getQueryString() != null){
			str = URLDecoder.decode(request.getQueryString(), "utf-8");
		}
	}
	
	Element retxml = DocumentHelper.createElement("response");
	
	if(str == null){
		logger.info("app no request data");
		retxml.addElement("result").setText("9997");
		retxml.addElement("desc").setText("请求数据为空");
		out.print(retxml.asXML());
		logger.info("app ret xml = " + retxml.asXML());
		return;
	}
	
	logger.info("app send str = " + str);
	
	Document obj = null;
	
	try {
		obj = DocumentHelper.parseText(str);
	} catch (Exception e) {
		logger.error(e.getMessage(), e);
	}
	
	if(obj == null){
		retxml.addElement("result").setText("9996");
		retxml.addElement("desc").setText("请求数据格式无效");
		out.print(retxml.asXML());
		logger.info("app return bad xml data");
		logger.info("app ret xml = " + retxml.asXML());
		return;
	}
	
	String userid = "10383";
	String password = "79e13d86a778aabcd998ea86c4895066";
	
	try{
		Element root = obj.getRootElement();
		Element head = root.element("head");
		String custInteId = head.elementText("custInteId");
		String orderId = head.elementText("orderId");
		String echo = head.elementText("echo");
		String timestamp = head.elementText("timestamp");
		
		if(!custInteId.equals(userid)){
			retxml.addElement("result").setText("0007");
			retxml.addElement("desc").setText("接入ID无效");
			out.print(retxml.asXML());
			logger.info("app ret xml = " + retxml.asXML());
			return;
		}
		
		String sign = custInteId + orderId + password + echo + timestamp; 
		sign = myMD5(sign);
		if(!sign.equals(head.elementText("chargeSign"))){
			retxml.addElement("result").setText("0009");
			retxml.addElement("desc").setText("接入校验失败");
			out.print(retxml.asXML());
			logger.info("app ret xml = " + retxml.asXML());
			return;
		}
		
		Element body = root.element("body");
		int i = 0;
		Element item = null;
		for(Iterator<Element> iter = body.elementIterator("item"); iter.hasNext(); i++){
			item = iter.next();
			if(i > 1){
				break;
			}
		}
		
		if(i > 1){
			retxml.addElement("result").setText("8800");
			retxml.addElement("desc").setText("一次只能提交一个单号码订单");
			out.print(retxml.asXML());
			logger.info("app ret xml = " + retxml.asXML());
			return;
		}
		
		String packCode = item.elementText("packCode");
		
		String orgpackCode = packCode;
		
		String orderType = item.elementText("orderType");
		
		String mobile = item.elementText("mobile");
		
		HashMap<String, String> map = new HashMap<String, String>();
		map.put("100010", "10");
		map.put("100030", "30");
		map.put("100070", "70");
		map.put("100100", "100");
		map.put("100150", "150");
		map.put("100300", "300");
		map.put("100500", "500");
		map.put("101024", "1024");
		map.put("102048", "2048");
		map.put("103072", "3072");
		map.put("104096", "4096");
		map.put("106144", "6144");
		map.put("111264", "11264");
		map.put("100020", "20");
		map.put("100050", "50");
		map.put("100100", "100");
		map.put("100200", "200");
		map.put("100500", "500");
		map.put("101024", "1024");
		map.put("100005", "5");
		map.put("100010", "10");
		map.put("100030", "30");
		map.put("100050", "50");
		map.put("100100", "100");
		map.put("100200", "200");
		map.put("100500", "500");
		map.put("101024", "1024");
		
		packCode = map.get(packCode);
		if(packCode == null){
			retxml.addElement("result").setText("0041");
			retxml.addElement("desc").setText("无效的产品代码");
			out.print(retxml.asXML());
			logger.info("app ret xml = " + retxml.asXML());
			return;
		}
		
		HashMap<String, String> params = new LinkedHashMap<String, String>();
		params.put("action", "charge");
		params.put("userid", userid);
		params.put("password", password);
		params.put("phone", mobile);
		params.put("mbytes", packCode);
		params.put("linkid", orderId);

		String url = "http://127.0.0.1:9301/lcll/xml/api.jsp";
		synchronized(vlock){
			if(odmap.get("orderId") != null){
				retxml.addElement("result").setText("8802");
				retxml.addElement("desc").setText("重复的订单号");
				out.print(retxml.asXML());
				logger.info("app ret xml = " + retxml.asXML());
				return;
			}
			String ret = HttpAccess.postNameValuePairRequest(url, params, "utf-8", "app");
			System.out.println("app send ret=" + ret);
			
			Document document;
			try {
				document = DocumentHelper.parseText(ret);
			} catch (DocumentException e) {
				logger.error(e.getMessage(), e );
				retxml.addElement("result").setText("8803");
				retxml.addElement("desc").setText("服务器故障");
				out.print(retxml.asXML());
				logger.info("app ret xml = " + retxml.asXML());
				return;
			}
			Element rootv = document.getRootElement();
	
			String returnval = rootv.attribute("return").getText();
			if (returnval.equals("0")) {
				retxml.addElement("result").setText("0000");
				retxml.addElement("desc").setText("成功");
				out.print(retxml.asXML());
				logger.info("app ret xml = " + retxml.asXML());
				
				JSONObject json = new JSONObject();
				json.put("orderType", orderType);
				json.put("packCode", orgpackCode);
				json.put("mobile", mobile);
				
				LLTempDatabase.putMap("app", orderId, json.toString(), "05");
				return;
			} else {
				if(returnval.equals("1001002")){
					retxml.addElement("result").setText("0022");
					retxml.addElement("desc").setText("余额不足");
					out.print(retxml.asXML());
					logger.info("app ret xml = " + retxml.asXML());
					return;
				}else if(returnval.equals("1002011")){
					retxml.addElement("result").setText("0041");
					retxml.addElement("desc").setText("无效的产品代码");
					out.print(retxml.asXML());
					logger.info("app ret xml = " + retxml.asXML());
					return;
				}else{
					retxml.addElement("result").setText("8808");
					retxml.addElement("desc").setText(rootv.attribute("info").getText());
					out.print(retxml.asXML());
					logger.info("app ret xml = " + retxml.asXML());
					return;
				}
			}
		}
	}catch(Exception e){
		logger.error(e.getMessage(), e );
		retxml.addElement("result").setText("8804");
		retxml.addElement("desc").setText("程序接口异常");
		out.print(retxml.asXML());
		logger.info("app ret xml = " + retxml.asXML());
		return;
	}
	
%>