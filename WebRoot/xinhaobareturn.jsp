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
	
	logger.info("xinhaoba return entry1");
	
	Map<String, String[]> paramMap = request.getParameterMap();
	HashMap<String,String> params = new HashMap<String,String>();
	if(paramMap != null){
		for(Entry<String, String[]> param : paramMap.entrySet()){
			params.put(param.getKey(), param.getValue()[0]);
			logger.info("xinhaoba return key = " + param.getKey() + ", value = " + param.getValue()[0]);
		}
	}

	String taskid = params.get("submitorderid");
	String result = params.get("state");
	
	String status = null;
	String info = "成功";
	String mark = "xinhaoba";
	if(result.equals("1")){
		status = "0";
	}else{
		status = "1";
		info = params.get("note");
	}
	LLTempDatabase.addReport(mark, taskid, status, info, "01");
	
	out.print("0000");
%>