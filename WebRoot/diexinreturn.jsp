<%@page import="org.dom4j.Element"%>
<%@page import="org.dom4j.DocumentHelper"%>
<%@page import="org.dom4j.Document"%>
<%@page import="java.util.Map.Entry,
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
%><%
	out.clearBuffer();
	boolean logflag = true;
	Logger logger = LogManager.getLogger();
	
	logger.info("diexin return entry");
	
	String str = MyStringUtils.inputStringToString(request.getInputStream());
	if(str == null || str.length() <= 0){
		str=request.getParameter("xml");
	}
	if(str == null || str.length() <= 0){
		if(request.getQueryString() != null){
			str = URLDecoder.decode(request.getQueryString(), "utf-8");
		}
	}
	
	Map<String, String[]> paramMap = request.getParameterMap();
	if(paramMap != null){
		for(Entry<String, String[]> param : paramMap.entrySet()){
			logger.info("diexin return key = " + param.getKey() + ", value = " + param.getValue()[0]);
		}
	}
	
	if(str == null){
		logger.info("diexin no request data");
		out.print("no request data");
		return;
	}
	
	logger.info("diexin return str = " + str);
	
	Document obj = null;
	try {
		obj = DocumentHelper.parseText(str);
	} catch (Exception e) {
		logger.error(e.getMessage(), e);
	}
	if(obj == null){
		out.print("bad xml data");
		logger.info("diexin return bad xml data");
		return;
	}
	
	Element requestElement = obj.getRootElement();
	Element bodyElement = requestElement.element("body");
	
	List<Element> items = bodyElement.elements("item");
	for(int i=0; i < items.size(); i++){
		try{
			Element itemElement = bodyElement.element("item");
			Element orderIdElement = itemElement.element("orderId");
			Element resultElement = itemElement.element("result");
			Element descElement = itemElement.element("desc");
			
			String taskid = orderIdElement.getText();
			String descMessage = descElement.getText();
			logger.info("diexinreturn descMessage = " + descMessage);
			
			String result = resultElement.getText();
			logger.info("diexinreturn result = " + result);
			if(result.equals("1003")){
				Element gateErrorCodeElement = itemElement.element("gateErrorCode");
				descMessage = gateErrorCodeElement.getText();
				logger.info("diexinreturn gateErrorCode = " + descMessage);
			}
		
			String status = null;
			if(result.equals("0000")){
				status = "0";
			}else{
				status = "1";
			}
			LLTempDatabase.addReport("diexin", taskid, status, descMessage, "01");
		}catch(Exception e){
			logger.error(e.getMessage(), e);
		}
	}
	
	Document document = DocumentHelper.createDocument();
	Element responseElement = document.addElement("response");
	Element result_Element = responseElement.addElement("result");
	Element desc_Element = responseElement.addElement("desc");
	
	result_Element.setText("0000");
	desc_Element.setText("成功");

	out.print(document.asXML());
%>