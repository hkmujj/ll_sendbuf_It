<%@page import="org.dom4j.Element"%>
<%@page import="org.dom4j.Document"%>
<%@page import="org.dom4j.DocumentHelper"%>
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
	boolean logflag = true;
	Logger logger = LogManager.getLogger();
	
	logger.info("fengzhushou return entry");
	
	String str = MyStringUtils.inputStringToString(request.getInputStream());
	logger.info("fengzhushou return str1 = " + str);
	
	if(str == null || str.length() <= 0){
		str=request.getParameter("json");
	}
	logger.info("fengzhushou return str2 = " + str);
	
	if(str == null || str.length() <= 0){
		if(request.getQueryString() != null){
			str = URLDecoder.decode(request.getQueryString(), "utf-8");
		}
	}
	logger.info("fengzhushou return str3 = " + str);
	
	if(str == null){
		logger.info("fengzhushou no request data");
		out.print("no request data");
		return;
	}
	
	logger.info("fengzhushou return str = " + str);
	
	Document doc = DocumentHelper.parseText(str);
	Element root = doc.getRootElement();
	String retcode =root.elementText("retcode");
	String msg =root.elementText("msg");
	String orderId =root.elementText("orderId");
	String status="";
	String info="";
	String mark="fengzhushou";
		if(retcode.equals("1")){
			status = "0";
			info="充值成功";
		}else if(retcode.equals("9")){
			status = "1";
			info = msg;
		}else{
		out.print("bad request");
		return;
		}
		LLTempDatabase.addReport(mark, orderId, status, info, "01");
	
	
	out.print("ok");
%>