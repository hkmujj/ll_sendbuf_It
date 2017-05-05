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

	logger.info("jutongda2 return entry");
	logger.info("jutongda2 return customId=" + request.getParameter("customId"));
	if (request.getParameter("customId") != null) {
		String taskid = request.getParameter("customId");
		String result = request.getParameter("status");
		logger.info("jutongda2 customid=" + taskid + "&result" + result);
		String info = "success";
		String status = null;
		String mark = "jutongda2";
		if (result.equals("7")) {
			status = "0";
		} else if (result.equals("8")) {
			status = "1";
			info = "fail";
		}
		LLTempDatabase.addReport(mark, taskid, status, info, "01");
		out.clearBuffer();
		out.print("SUCCESS");
	} else {
		logger.info("jutongda bad str");
		out.print("fail");
	}
%>