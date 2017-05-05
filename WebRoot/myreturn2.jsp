<%@page import="database.LLTempDatabase"%>
<%@page import="util.MD5Util,
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
		logger.info("my no request data");
		out.print("no request data");
		return;
	}
	
	logger.info("my return str = " + str);
	
	JSONArray objarray = null;
	String routeid = null;
	try{
		JSONObject myobj = JSONObject.fromObject(str);
		routeid = myobj.getString("routeid");
		objarray = myobj.getJSONObject("array").getJSONArray("Reports");
	} catch (Exception e) {
		logger.warn(e.getMessage(), 0);
		out.print("bad json data");
		return;
	}

	for(int i = 0; i < objarray.size(); i++){
		JSONObject sobj = objarray.getJSONObject(i);
		JSONObject vobj = JSONObject.fromObject(sobj.toString().replaceAll("\\\\u", "\\u"));
		if(sobj.getString("Status").equals("4")){
			//成功
			
			String mark = routeid;
			String taskid = sobj.getString("TaskID");
			String status = "0";
			String info = "success";
			LLTempDatabase.addReport(mark, taskid, status, info, "03");
			
		}else if(sobj.getString("Status").equals("5")){
			//失败
			
			String reportcode = vobj.getString("ReportCode");
			if(reportcode.length() > 64){
				reportcode = reportcode.substring(0, 64);
			}
			String mark = routeid;
			String taskid = sobj.getString("TaskID");
			String status = "1";
			String info = reportcode;
			LLTempDatabase.addReport(mark, taskid, status, info, "03");
		}
	}
	
	out.print("success ~ " + TimeUtils.getTimeString());
	
	
%>