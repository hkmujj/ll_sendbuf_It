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
	
	Map<String, String[]> paramMap = request.getParameterMap();
	HashMap<String,String> params = new HashMap<String,String>();
	if(paramMap != null){
		for(Entry<String, String[]> param : paramMap.entrySet()){
			params.put(param.getKey(), param.getValue()[0]);
			logger.info("xichuan return key = " + param.getKey() + ", value = " + param.getValue()[0]);
		}
	}
	
		JSONObject obj = new JSONObject();
		try {
			obj.put("sessionId", params.get("sessionId"));
			obj.put("resultCode", "0");
			obj.put("resultDesc", "ok");
		} catch (JSONException e) {
			System.out.println(e.getMessage());;
		}
	
	
	out.print(obj.toString());
%>