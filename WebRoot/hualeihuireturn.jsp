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
	
	logger.info("hualeihui return entry1");
	
	Map<String, String[]> paramMap = request.getParameterMap();
	HashMap<String,String> params = new HashMap<String,String>();
	if(paramMap != null){
		for(Entry<String, String[]> param : paramMap.entrySet()){
			params.put(param.getKey(), param.getValue()[0]);
			logger.info("hualeihui return key = " + param.getKey() + ", value = " + param.getValue()[0]);
		}
	}
	
	
	String respCode = null;
	String rspDesc = null;
	String status = null;
	
	String taskid = params.get("privateChannel");
	String result = params.get("status");
	
	if(result == null){
		result = "";
	}
	
	if(result.equals("error")){
		respCode = params.get("respCode");
		rspDesc = params.get("rspDesc");
	}
	
	String mark = "hualeihui";
	if(result.equals("success")){
		status = "0";
	}else{
		status = "1";
	}
	LLTempDatabase.addReport(mark, taskid, status, result, "01");
	out.print("success");
%>