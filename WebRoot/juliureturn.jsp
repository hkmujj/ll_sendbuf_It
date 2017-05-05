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

	logger.info("juliu return entry1");
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
		logger.info("juliu no llt request data");
		out.print("no request llt data");
		return;
	}

	logger.info("juliu return str = " + str);
	String taskid = str.substring(str.indexOf("name=\"out_trade_no\"") + 21).split("\r\n")[1];
	String result = str.substring(str.indexOf("name=\"code\"") + 13).split("\r\n")[1];
	logger.info("juliu taskid=" + taskid + "&result" + result);
		logger.info("juliu taskid="+str.substring(str.indexOf("name=\"out_trade_no\"") + 21,str.indexOf("name=\"out_trade_no\"") + 40));
	String info = "success";
	String status = null;
	String mark = "juliu";
	String msg = "fail";
	if (result.equals("200")) {
		status = "0";
		LLTempDatabase.addReport(mark, taskid, status, info, "01");
	} else if (result.equals("500") || result.equals("501")) {
		status = "1";
		if (str.indexOf("name=\"msg\"") > -1) {
			msg = str.substring(str.indexOf("name=\"msg\"") + 12).split("\r\n")[0];
		}
		logger.info("juliu return msg=" + msg);
		info = msg;
		LLTempDatabase.addReport(mark, taskid, status, info, "01");

	}
	out.clearBuffer();
	out.print("ok");
%>