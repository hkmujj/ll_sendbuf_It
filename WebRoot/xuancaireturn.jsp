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

	logger.info("xuancai return entry1");
	out.clearBuffer();
	logger.info("xuancai return orderNo=" + request.getParameter("req_id"));
	if (request.getParameter("req_id") != null) {
		String taskid = request.getParameter("req_id");
		String result = request.getParameter("code");
		logger.info("xuancai taskid=" + taskid + "&result" + result);
		String info = "success";
		String status = null;
		String mark = "xuancai";
		String msg = "";
		if (result.equals("1")) {
			status = "0";
			LLTempDatabase.addReport(mark, taskid, status, info, "01");
			JSONObject json = new JSONObject();
			json.put("code", "1");
			json.put("text", "success");
			json.put("ext", new JSONObject());
			out.print(json.toString().trim());
		} else if (result.equals("2")) {
			status = "1";
			msg = request.getParameter("msg");
			if (msg == null) {
				msg = "fail";
			}
			logger.info("xuancai return msg=" + msg);
			info = msg;
			LLTempDatabase.addReport(mark, taskid, status, info, "01");
			JSONObject json = new JSONObject();
			json.put("code", "1");
			json.put("text", "success");
			json.put("ext", new JSONObject());
			out.clearBuffer();
			out.print(json.toString().trim());

		} else {
			logger.info("xuancai bad str");
			out.print("FAILED");
		}
	} else {
		logger.info("xuancai bad str");
		out.print("FAILED");
	}
%>