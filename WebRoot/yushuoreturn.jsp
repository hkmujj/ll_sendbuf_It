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

	logger.info("yushuo return entry1");

	Map<String, String[]> paramMap = request.getParameterMap();
	if (paramMap != null) {
		for (Entry<String, String[]> param : paramMap.entrySet()) {
			logger.info("yushuo return key = " + param.getKey() + ", value = " + param.getValue()[0]);
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
		logger.info("yushuo no request data");
		out.print("no request data");
		return;
	}

	logger.info("yushuo return str = " + str);

	JSONObject jsonobj = null;
	try {
		jsonobj = JSONObject.fromObject(str);
	} catch (Exception e) {
		logger.warn(e.getMessage(), e);
		out.print("bad json data");
		return;
	}

	String taskid = jsonobj.getString("msgId");
	String code = jsonobj.getString("err");

	String mark = "yushuo";
	String status = "1";
	String info = "成功";
	if (code.equals("0")) {
		status = "0";
		LLTempDatabase.addReport(mark, taskid, status, info, "01");

	} else if (code.equals("45")) {
		if (jsonobj.get("fail_describe") != null) {
			info = jsonobj.getString("fail_describe");
		} else {
			info = "失败";
		}
		LLTempDatabase.addReport(mark, taskid, status, info, "01");

	}

	out.print("0000");
%>