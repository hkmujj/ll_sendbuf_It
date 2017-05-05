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

	logger.info("baimiao return entry1");

	Map<String, String[]> paramMap = request.getParameterMap();
	if (paramMap != null) {
		for (Entry<String, String[]> param : paramMap.entrySet()) {
			logger.info("baimiao return key = " + param.getKey() + ", value = " + param.getValue()[0]);
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
		logger.info("baimiao no request data");
		out.print("no request data");
		return;
	}

	logger.info("baimiao return str = " + str);

	JSONObject jsonobj = null;
	try {
		jsonobj = JSONObject.fromObject(str);
	} catch (Exception e) {
		logger.warn(e.getMessage(), e);
		out.print("bad json data");
		return;
	}

	String taskid = jsonobj.getString("userorderno");
	String resultcode = jsonobj.getString("userorderno");

	String mark = "baimiao";
	String status = "";
	String info = "成功";
	if (resultcode.equals("00000")) {
		status = "0";
	} else {
		info = "fail";
		status = "1";
		if (jsonobj.get("resultdescription") != null) {
			info = jsonobj.getString("resultdescription");
		}
	}

	LLTempDatabase.addReport(mark, taskid, status, info, "01");
	JSONObject json = new JSONObject();
	json.put("resultcode", "0");
	json.put("resultdescription", "succeed");
	out.print(json.toString());
%>