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
	
	logger.info("zhonglian return entry");

	Map<String, String[]> paramMap = request.getParameterMap();
	HashMap<String,String> params = new HashMap<String,String>();
	if(paramMap != null){
		for(Entry<String, String[]> param : paramMap.entrySet()){
			params.put(param.getKey(), param.getValue()[0]);
			logger.info("zhonglian return key = " + param.getKey() + ", value = " + param.getValue()[0]);
		}
	}
	
	String respCode = null;
	String rspDesc = null;
	String status = null;
	
	String taskid = params.get("orderid");
	String result = params.get("errcode");
	//OrderSuccess
	if(taskid == null || taskid.trim().length() == 0){
		out.print("orderid is blank!");
		return;
	}
	
	if(result == null){
		result = "";
	}

	String mark = "lecai";
	if(result.equalsIgnoreCase("OrderFail")){
		status = "1";
		rspDesc = "失败";
	}else{
		status = "0";
		rspDesc = "成功";
	}
	LLTempDatabase.addReport(mark, taskid, status, rspDesc, "01");
	out.print("true");
%>