<%@page import="org.dom4j.Element"%>
<%@page import="org.dom4j.DocumentHelper"%>
<%@page import="org.dom4j.Document"%>
<%@page
	import="java.util.Map.Entry,
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
	language="java" pageEncoding="UTF-8"%>
<%
	boolean logflag = true;
	Logger logger = LogManager.getLogger();

	logger.info("guoxin2 return entry1");

	Map<String, String[]> paramMap = request.getParameterMap();
	if (paramMap != null) {
		for (Entry<String, String[]> param : paramMap.entrySet()) {
			logger.info("guoxin2 return key = " + param.getKey() + ", value = " + param.getValue()[0]);
		}
	}

	String str = MyStringUtils.inputStringToString(request.getInputStream());
	if (str == null || str.length() <= 0) {
		str = request.getParameter("data");
	}
	if (str == null || str.length() <= 0) {
		if (request.getQueryString() != null) {
			str = URLDecoder.decode(request.getQueryString(), "utf-8");
		}
	}

	if (str == null) {
		logger.info("guoxin2 no request data");
		out.print("no request data");
		return;
	}

	logger.info("guoxin2 return str = " + str);

	JSONObject jsonobj = null;
	try {
		jsonobj = JSONObject.fromObject(str);
	} catch (Exception e) {
		logger.warn(e.getMessage(), e);
		out.print("bad json data");
		return;
	}

	String taskid = jsonobj.getString("orderId");
	String resultcode = jsonobj.getString("status");

	String mark = "guoxin2";
	String status = "";
	String info = "成功";
	if (resultcode.equals("7")) {
		status = "0";
		LLTempDatabase.addReport(mark, taskid, status, info, "01");

	} else if (resultcode.equals("8")) {
		info = "fail";
		status = "1";
		if (jsonobj.get("errorDesc") != null) {
			info = jsonobj.getString("errorDesc");
		}
		LLTempDatabase.addReport(mark, taskid, status, info, "01");
	}

	JSONObject json = new JSONObject();
	json.put("code", "0");
	json.put("msg", "接收成功");
	out.print(json.toString());
%>