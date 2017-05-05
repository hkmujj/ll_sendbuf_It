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
	
	logger.info("changyue return entry");
	
	Map<String, String[]> paramMap = request.getParameterMap();
	HashMap<String,String> params = new HashMap<String,String>();
	if(paramMap != null){
		for(Entry<String, String[]> param : paramMap.entrySet()){
			params.put(param.getKey(), param.getValue()[0]);
			logger.info("changyue return key = " + param.getKey() + ", value = " + param.getValue()[0]);
		}
	}
	String taskid = params.get("out_order_id");
	String result = params.get("status");
	String status = null;
	String info = null;
	String mark = "changyue";
	if(result.equals("0")){
		status = "0";
		info = "成功";
	}else {
		status = "1";
		info = "失败";
	}
	LLTempDatabase.addReport(mark, taskid, status, info, "01");

	out.print("1");
%>