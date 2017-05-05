<%@page import="util.MyStringUtils"%>
<%@page import="database.LLTempDatabase"%>
<%@page
	import="util.Utility,
				java.util.Map.Entry,
				net.sf.json.JSONArray,
				util.TimeUtils,
				net.sf.json.JSONException,
				net.sf.json.JSONObject,
				java.util.*,
				java.net.URLDecoder,
				org.apache.logging.log4j.LogManager,
				org.apache.logging.log4j.Logger"
	language="java" pageEncoding="UTF-8"%>


<%
	boolean logflag = true;
	Logger logger = LogManager.getLogger();
	logger.info("kachi2 recharge entry");

	Map<String, String[]> paramMap = request.getParameterMap();
	if (paramMap != null) {
		for (Entry<String, String[]> param : paramMap.entrySet()) {
			logger.info("kachi2 recharge key = " + param.getKey() + ", value = " + param.getValue()[0]);
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

	logger.info("kachi2 recharge json = " + str);

	if (str == null || str.trim().length() <= 0) {
		out.print("bad json data");
		return;
	}

	JSONObject obj = null;
	try {
		obj = JSONObject.fromObject(str);
	} catch (Exception e) {
		logger.error(e.getMessage(), e);
		out.print("bad json data");
	}
	if (obj == null) {
		out.print("bad json data");
	} else {
		String taskid = obj.getString("bizid");
		String resultCode = obj.getString("resultCode");
		String status = "";
		String info = "";
		if (resultCode.equals("T00004")) {
			status = "1";
			if (obj.get("resultMsg") != null) {
				info = obj.getString("resultMsg");
			} else {
				info = "充值失败";
			}
		} else {
			status = "0";
			info = "充值成功";
		}
		logger.info("kachi2 obj = " + obj.toString());
		LLTempDatabase.addReport("kachi2", taskid, status, info, "01");
		out.print("1");
	}
%>