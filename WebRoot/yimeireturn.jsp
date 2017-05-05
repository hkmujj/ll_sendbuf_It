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
	
	logger.info("yimei return entry1");
	
	Map<String, String[]> paramMap = request.getParameterMap();
	if(paramMap != null){
		for(Entry<String, String[]> param : paramMap.entrySet()){
			logger.info("yimei return key = " + param.getKey() + ", value = " + param.getValue()[0]);
		}
	}
	
	String str = MyStringUtils.inputStringToString(request.getInputStream());
	if(str == null || str.length() <= 0){
		str=request.getParameter("data");
	}
	if(str == null || str.length() <= 0){
		if(request.getQueryString() != null){
			str = URLDecoder.decode(request.getQueryString(), "utf-8");
		}
	}
	
	if(str == null){
		logger.info("yimei no request data");
		out.print("no request data");
		return;
	}
	
	logger.info("yimei return str = " + str);
	
	JSONObject jsonobj = null;
	try{
		jsonobj = JSONObject.fromObject(str);
	} catch (Exception e) {
		logger.warn(e.getMessage(), e);
		out.print("bad json data");
		return;
	}

	String taskid = jsonobj.getString("batchNo");
	JSONArray ary = null;
	
	try{
		ary = jsonobj.getJSONArray("errorlist");
	} catch (Exception e) {
		logger.warn(e.getMessage(), e);
	}
	
	String mark = "yimei";
	String status = "1";
	String info = "成功";
	if(ary == null || ary.size() <= 0){
		status = "0";
	}else{
		try{
			info = ary.getJSONObject(0).getString("message");
		} catch (Exception e) {
			info = "失败";
			logger.warn(e.getMessage(), e);
		}
	}
	
	LLTempDatabase.addReport(mark, taskid, status, info, "01");
	
	out.print("SUCCESS");
%>