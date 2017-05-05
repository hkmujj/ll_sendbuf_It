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
	
	logger.info("quxun return entry1");
	
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
		logger.info("quxun no request data");
		out.print("no request data");
		return;
	}
	
	logger.info("quxun return str = " + str);
	
	JSONObject obj = null;
	try{
		obj = JSONObject.fromObject(str);
	} catch (Exception e) {
		logger.warn(e.getMessage(), 0);
		out.print("bad json data");
		return;
	}

	String taskid = obj.getString("order_id");
	String result = obj.getString("orderstatus");
	String result_code = obj.getString("result_code");
	
	String status = null;
	String info = result_code;
	String mark = "quxun";
	if(result.equals("finish")){
		status = "0";
	}else{
		status = "1";
	}
	LLTempDatabase.addReport(mark, taskid, status, info, "01");
	
	out.print("1");
%>