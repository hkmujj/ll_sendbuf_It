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
	
	logger.info("maiersi return entry1");
	
	Map<String, String[]> paramMap = request.getParameterMap();
	if(paramMap != null){
		for(Entry<String, String[]> param : paramMap.entrySet()){
			logger.info("maiersi return key = " + param.getKey() + ", value = " + param.getValue()[0]);
		}
	}
	
	String taskid = request.getParameter("tradeNo");
	String result = request.getParameter("result");
	String info = request.getParameter("remoteMessage");
	
	String status = null;
	if(info == null){
		info = result;
	}
	String mark = "maiersi";
	if(result.equals("s")){
		status = "0";
	}else{
		status = "1";
	}
	LLTempDatabase.addReport(mark, taskid, status, info, "01");
	out.print("true");
%>