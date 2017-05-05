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

	logger.info("dingshan return entry");

	Map<String, String[]> paramMap = request.getParameterMap();
	if (paramMap != null) {
		for (Entry<String, String[]> param : paramMap.entrySet()) {
			logger.info("dingshan return key = " + param.getKey() + ", value = " + param.getValue()[0]);
		}
	}

	String str = MyStringUtils.inputStringToString(request.getInputStream());
	if (str == null || str.length() <= 0) {
		str = request.getParameter("json");
	}
	if (str == null || str.length() <= 0) {
		if (request.getQueryString() != null) {
			str = URLDecoder.decode(request.getQueryString(), "utf-8");
		}
	}

	if (str == null) {
		logger.info("dingshan no request data");
		out.print("no request data");
		return;
	}

	logger.info("dingshan return str = " + str);

	JSONObject jsonobj = null;
	try {
		jsonobj = JSONObject.fromObject(str);
		String taskid = jsonobj.getString("order_id");
		String resultcode = jsonobj.getString("status");
		String mark = "dingshan";
		String status = "";
		String info = "成功";
		if (resultcode.equals("S")) {
			status = "0";
			LLTempDatabase.addReport(mark, taskid, status, info, "01");
		} else if (resultcode.equals("F")) {
			info = "fail";
			status = "1";
			if (jsonobj.get("desc") != null) {
				info = jsonobj.getString("desc");
			}
			LLTempDatabase.addReport(mark, taskid, status, info, "01");
		}
		JSONObject json = new JSONObject();
		json.put("ret_code", "00");
		json.put("ret_msg", "ok");
		out.clearBuffer();
		out.print(json.toString());
	} catch (Exception e) {
		logger.warn(e.getMessage(), e);
		out.print("bad json data");
		return;
	}
%>