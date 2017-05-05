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

	logger.info("xinyun return entry1");
	request.setCharacterEncoding("utf-8");
	logger.info("xinyun return entry");
	Map<String, String[]> paramMap = request.getParameterMap();
	if (paramMap != null) {
		for (Entry<String, String[]> param : paramMap.entrySet()) {
			logger.info("xinyun return key = " + param.getKey() + ", value = " + param.getValue()[0]);
		}
	}

	logger.info("xinyun return orderNo=" + request.getParameter("tradeno"));
	if (request.getParameter("tradeno") != null) {
		String taskid = request.getParameter("tradeno");
		String result = request.getParameter("status");
		logger.info("xinyun taskid=" + taskid + "&result" + result);
		String info = "success";
		String status = null;
		String mark = "xinyun";
		String msg = "";
		if (result.equals("1")) {
			status = "0";
		} else {
			status = "1";
			msg = request.getParameter("message");
			logger.info("xinyun return msg=" + msg);
			info = msg;
		}
		LLTempDatabase.addReport(mark, taskid, status, info, "01");
		out.print("success");
	} else {
		logger.info("xinyun bad str");
		out.print("fail");
	}
%>