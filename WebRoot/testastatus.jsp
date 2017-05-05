<%@page import="database.LLTempDatabase,
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
		
		//发送请求前先准备好参数
		String[] idarray = {"1610181129210559430"};
		JSONObject obj = new JSONObject();
		
		LLTempDatabase.getStatus("hongbao", idarray, obj, "01");
	
		logger.info("hongbao retjson = " + obj.toString());
		out.print(obj.toString());
		
	
	
	//Log.logout("String = " + str, 0);
	//out.print((new MsgBufQuerier()).jsonRpc(str));
	//out.print("hello");
%>