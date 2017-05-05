<%@page import="java.util.Map.Entry,
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
		language="java" pageEncoding="UTF-8"
%><%
	boolean logflag = true;
	Logger logger = LogManager.getLogger();
	
	logger.info("zhongchenyuan return entry1");
	request.setCharacterEncoding("utf-8");
	logger.info("zhongchenyuan  return update");
	logger.info("zhongchenyuan return entry");

	logger.info("zhongchenyuan return orderNo=" + request.getParameter("orderNo"));
	if (request.getParameter("orderNo") != null) {
		String taskid = request.getParameter("orderNo");
		String result = request.getParameter("resCode");
		logger.info("zhongchenyuan taskid=" + taskid + "&result" + result);
		String info = "success";
		String status = null;
		String mark = "zhongchenyuan";
		String msg = "";
		if(result.equals("00")) {
			status = "0";
		} else{
			status = "1";
			msg = request.getParameter("redMsg");
			msg = URLDecoder.decode(msg);
			logger.info("zhongchenyuan return msg="+msg);
			info = msg;
		}
		LLTempDatabase.addReport(mark, taskid, status, info, "01");
		out.print("success");
	} else {
		logger.info("zhongchenyuan bad str");
		out.print("fail");
	}
%>