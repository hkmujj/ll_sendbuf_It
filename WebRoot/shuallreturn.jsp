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
%><%!
	public static String getFromBASE64(String s) { 
		if (s == null) return null; 
			try { 
				byte[] b = new org.apache.commons.codec.binary.Base64().decode(s); 
				return new String(b, "utf-8"); 
			} catch (Exception e) {
				return null;
		}
	} 
 %><%
	boolean logflag = true;
	Logger logger = LogManager.getLogger();
	
	logger.info("shuall return entry1");
	
	Map<String, String[]> paramMap = request.getParameterMap();
	HashMap<String,String> params = new HashMap<String,String>();
	if(paramMap != null){
		for(Entry<String, String[]> param : paramMap.entrySet()){
			params.put(param.getKey(), param.getValue()[0]);
			logger.info("shuall return key = " + param.getKey() + ", value = " + param.getValue()[0]);
		}
	}
	
	String resData = params.get("resData");
	String retdata = getFromBASE64(resData);
	
	logger.info("shuall json = " + retdata);
	JSONObject obj = null;
	
	try{
		obj = JSONObject.fromObject(retdata);
	}catch(Exception e){
		out.print(retdata);
		e.printStackTrace();
		return;
	}
	
	String taskid = obj.getString("orderNo");
	
	JSONObject retobj = new JSONObject();
	JSONArray retarr = JSONArray.fromObject(obj.getString("result"));
	for(int i = 0;i<retarr.size(); i++){
		retobj = retarr.getJSONObject(i);
	}
	String message = "";
	String resDscp = "失败";
	if(retobj.get("resDscp")!=null){
	resDscp = retobj.getString("resDscp");
	}
	String status = retobj.getString("status");
	
	
	if(status == null){
		status = "";
	}
	String mark = "shuall";
	if(status.equals("S")){
		status = "0";
		message = "成功";
	}else{
		status = "1";
		message = resDscp;
		
	}
	LLTempDatabase.addReport(mark, taskid, status, message, "01");
	out.print("ok");
%>