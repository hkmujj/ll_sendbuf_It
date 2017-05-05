<%@page import="org.dom4j.Element"%>
<%@page import="org.dom4j.Document"%>
<%@page import="org.dom4j.DocumentHelper"%>
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

	logger.info("maisi return entry");

	String str = MyStringUtils.inputStringToString(request.getInputStream());

	if (str == null || str.length() <= 0) {
		str = request.getParameter("json");
	}
	if (str == null || str.length() <= 0) {
		if (request.getQueryString() != null) {
			str = URLDecoder.decode(request.getQueryString(), "utf-8");
		}
	}

	Map<String, String[]> paramMap = request.getParameterMap();
	if (paramMap != null) {
		for (Entry<String, String[]> param : paramMap.entrySet()) {
			logger.info("maisi return key = " + param.getKey() + ", value = " + param.getValue()[0]);
		}
	}

	String orderId = request.getParameter("cpparam");
	String result = request.getParameter("retCode");

	if (str == null) {
		logger.info("maisi no request data");
		out.print("no request data");
		return;
	}

	logger.info("maisi return str = " + str);

	if (orderId != null) {
		String status = "";
		String info = "";
		String mark = "maisi";
		if (result.equals("0")) {
			status = "0";
			info = "充值成功";
		} else {
			status = "1";
			info = result;
		}
		LLTempDatabase.addReport(mark, orderId, status, info, "01");

		out.print("ok");
	} else {
		out.print("fail");
		logger.info("maisi huidiao orderid fail");
	}
%>