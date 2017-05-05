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
	
	logger.info("liuliangsky return entry1");
		
	Map<String, String[]> paramMap = request.getParameterMap();
	if(paramMap != null){
		for(Entry<String, String[]> param : paramMap.entrySet()){
			logger.info("liuliangsky return key = " + param.getKey() + ", value = " + param.getValue()[0]);
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
		logger.info("liuliangsky no request data");
		out.print("no request data");
		return;
	}
	
	logger.info("liuliangsky return str = " + str);
	
	logger.info("liuliangsky return entry");

	logger.info("liuliangsky return orderNo=" + request.getParameter("TaskID"));
	if (request.getParameter("TaskID") != null) {
		String taskid = request.getParameter("TaskID");
		String result = request.getParameter("Status");
		logger.info("liuliangsky taskid=" + taskid + "&result" + result);
		String info = "success";
		String status = null;
		String mark = "liuliangsky";
		String msg = "";
		if(result.equals("4")) {
			status = "0";
		} else{
			status = "1";
			msg = request.getParameter("ReportCode");
			msg = URLDecoder.decode(msg);
			logger.info("liuliangsky return msg="+msg);
			info = msg;
		}
		out.print("ok");
	} else {
		logger.info("liuliangsky bad str");
		out.print("fail");
	}
%>