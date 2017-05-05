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
	
	logger.info("qiannai return entry1");
	
	
	String str = MyStringUtils.inputStringToString(request.getInputStream());
	if(str == null || str.length() <= 0){
		str=request.getParameter("json");
	}
	if(str == null || str.length() <= 0){
		if(request.getQueryString() != null){
			str = URLDecoder.decode(request.getQueryString(), "utf-8");
		}
	}
	
	if(str == null){
		logger.info("qiannai no request data");
		out.print("no request data");
		return;
	}
	
	logger.info("qiannai return str = " + str);
	
	JSONObject obj = null;
	try{
		obj = JSONObject.fromObject(str);
	} catch (Exception e) {
		logger.warn(e.getMessage(), 0);
		out.print("bad json data");
		return;
	}

	String taskid = obj.getString("downNum");
	String result = obj.getString("status");
	
	String status = null;
	String info = result;
	String mark = "qiannai";
	if(result.equals("6")){
		status = "1";
	}else{
		status = "0";
	}
	LLTempDatabase.addReport(mark, taskid, status, info, "01");
	
	out.print("1");
%>