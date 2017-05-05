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
	
	logger.info("weinaier return entry1");
	
	Map<String, String[]> paramMap = request.getParameterMap();
	if(paramMap != null){
		for(Entry<String, String[]> param : paramMap.entrySet()){
			logger.info("weinaier return key = " + param.getKey() + ", value = " + param.getValue()[0]);
		}
	}
	
	String taskid = paramMap.get("orderid")[0];
	String result = paramMap.get("result")[0];
	
	String status = null;
	String info = paramMap.get("desc")[0];
	String mark = "weinaier";
	if(result.equals("SUCCESS")){
		status = "0";
	}else{
		status = "1";
	}
	LLTempDatabase.addReport(mark, taskid, status, info, "01");
	
	out.print("ok");
%>