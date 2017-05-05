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
	
	logger.info("tuobang return entry");
	
	Map<String, String[]> paramMap = request.getParameterMap();
	if(paramMap != null){
		for(Entry<String, String[]> param : paramMap.entrySet()){
			logger.info("tuobang return key = " + param.getKey() + ", value = " + param.getValue()[0]);
		}
	}
	
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
		logger.info("tuobang no request data");
		out.print("no request data");
		return;
	}
	
	logger.info("tuobang return str = " + str);
	
	String taskid = request.getParameter("req_id");
	String chg_sts = request.getParameter("chg_sts");
	
	String status = null;
	String mark = "tuobang";
	if(chg_sts.equals("S")){
		status = "0";
	}else if(chg_sts.equals("U")){
		logger.info("tuobang return chg_sts = " + chg_sts);
	}else{
		status = "1";
	}
	
	//LLTempDatabase.addReport(mark, taskid, status, info, "01");
	out.print("SUCCESS");
%>