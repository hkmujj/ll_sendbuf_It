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
	
	logger.info("bjhouhua return entry1");
	
	Map<String, String[]> paramMap = request.getParameterMap();
	if(paramMap != null){
		for(Entry<String, String[]> param : paramMap.entrySet()){
			logger.info("bjhouhua return key = " + param.getKey() + ", value = " + param.getValue()[0]);
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
		logger.info("bjhouhua no request data");
		out.print("no request data");
		return;
	}
	
	logger.info("bjhouhua return str = " + str);
	
	JSONArray objarray = null;
	try{
		objarray = JSONArray.fromObject(str);
	} catch (Exception e) {
		logger.warn(e.getMessage(), 0);
		out.print("bad json data");
		return;
	}

	for(int i = 0; i < objarray.size(); i++){
		JSONObject obj = objarray.getJSONObject(i);
		
		String taskid = obj.getString("order_id");
		String result = obj.getString("errcode");
		String info = obj.getString("msg");
		
		String status = null;
		String mark = "bjhouhua";
		if(result.equals("0")){
			status = "0";
		}else{
			status = "1";
		}
		LLTempDatabase.addReport(mark, taskid, status, info, "01");
	}
	
	out.print("1");
%>