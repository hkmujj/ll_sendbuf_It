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
	
	logger.info("jutongda return entry");
	
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
		logger.info("jutongda no request data");
		out.print("no request data");
		return;
	}
	
	logger.info("jutongda return str = " + str);
	
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
		
		String taskid = obj.getString("billId");
		String result = obj.getString("status");
		String info = "success";
		
		String status = null;
		String mark = "jutongda";
		if(result.equals("充值成功")){
			status = "0";
		}else if(result.equals("充值失败")){
			status = "1";
			info = "fail";
		}else{
			continue;
		}
		LLTempDatabase.addReport(mark, taskid, status, info, "01");
	}
	
	out.print("1");
%>