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

	logger.info("bozhirui return entry1");
	request.setCharacterEncoding("utf-8");
	logger.info("bozhirui return entry");
	Map<String, String[]> paramMap = request.getParameterMap();
	if (paramMap != null) {
		for (Entry<String, String[]> param : paramMap.entrySet()) {
			logger.info("bozhirui return key = " + param.getKey() + ", value = " + param.getValue()[0]);
		}
	}

	logger.info("bozhirui return orderNo=" + request.getParameter("tbOrderNo"));
	if (request.getParameter("tbOrderNo") != null) {
		String taskid = request.getParameter("tbOrderNo");
		String result = request.getParameter("coopOrderStatus");
		logger.info("bozhirui taskid=" + taskid + "&result" + result);
		String info = "success";
		String status = null;
		String mark = "bozhirui";
		String msg = "";
		if (result.equals("SUCCESS")) {
			status = "0";
			LLTempDatabase.addReport(mark, taskid, status, info, "01");
		} else if (result.equals("FAILED")) {
			status = "1";
			msg = request.getParameter("failDesc");
			if (msg == null) {
				msg = "fail";
			}
			logger.info("bozhirui return msg=" + msg);
			info = msg;
			LLTempDatabase.addReport(mark, taskid, status, info, "01");

		}
		out.print("SUCCESS");
	} else {
		logger.info("bozhirui bad str");
		out.print("FAILED");
	}
%>