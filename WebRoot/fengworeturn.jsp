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

	logger.info("fengwo return entry");

	Map<String, String[]> paramMap = request.getParameterMap();
	if (paramMap != null) {
		for (Entry<String, String[]> param : paramMap.entrySet()) {
			logger.info("fengwo return key = " + param.getKey() + ", value = " + param.getValue()[0]);
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
		logger.info("fengwo no request data");
		out.print("no request data");
		return;
	}

	logger.info("fengwo return str = " + str);

	JSONObject jsonobj = null;
	try {
		jsonobj = JSONObject.fromObject(str);
		JSONObject msgjson = jsonobj.getJSONObject("MSGBODY").getJSONObject("CONTENT");
		String taskid = msgjson.getString("EXTORDER");
		String resultcode = msgjson.getString("CODE");
		String mark = "fengwo";
		String status = "";
		String info = "成功";
		if (resultcode.equals("00")) {
			status = "0";
		} else {
			info = "fail";
			status = "1";
			if (msgjson.get("STATUS") != null) {
				info = msgjson.getString("STATUS");
			}
		}
		LLTempDatabase.addReport(mark, taskid, status, info, "01");
		JSONObject json = new JSONObject();
		JSONObject headjson = jsonobj.getJSONObject("HEADER");
		JSONObject bodyjson = new JSONObject();
		JSONObject respjson = new JSONObject();
		respjson.put("RCODE", "00");
		respjson.put("RMSG", "ok");
		bodyjson.put("RESP", respjson);
		json.put("HEADER", headjson);
		json.put("MSGBODY", bodyjson);
		out.clearBuffer();
		out.print(json.toString());
	} catch (Exception e) {
		logger.warn(e.getMessage(), e);
		out.print("bad json data");
		return;
	}
%>