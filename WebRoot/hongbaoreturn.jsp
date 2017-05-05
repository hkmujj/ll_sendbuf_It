<%@page import="java.net.URLEncoder"%>
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
	
	logger.info("hongbao return entry1");
	
	Map<String, String[]> paramMap = request.getParameterMap();
	if(paramMap != null){
		for(Entry<String, String[]> param : paramMap.entrySet()){
			logger.info("hongbao return key = " + param.getKey() + ", value = " + param.getValue()[0]);
		}
		logger.info("hongbao get request uri ################ = " + request.getRequestURI().toString());
	}
	
	String taskid = request.getParameter("transactionID");
	String result = request.getParameter("result");
	//String info = request.getParameter("resultDesc");
	
	
	String info = null;
	
	String status = null;
	String mark = "hongbao";
	if(result.equals("0")){
		status = "0";
		info = "成功";
	}else{
		status = "1";
		info = result;
	}
	
	LLTempDatabase.addReport(mark, taskid, status, info, "01");
	
	out.print("{\"message\":\"ok\",\"status\":\"ok\",\"code\":\"0\"}");
%>