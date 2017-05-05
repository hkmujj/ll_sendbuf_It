<%@page import="org.dom4j.DocumentHelper,
				org.dom4j.Document,
				org.dom4j.Element,
				java.util.Map.Entry,
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
	
	logger.info("yituo return entry1");
	
	Map<String, String[]> paramMap = request.getParameterMap();
	if(paramMap != null){
		for(Entry<String, String[]> param : paramMap.entrySet()){
			logger.info("yituo return key = " + param.getKey() + ", value = " + param.getValue()[0]);
		}
	}
	
	String str = MyStringUtils.inputStringToString(request.getInputStream());
	if(str == null || str.length() <= 0){
		str=request.getParameter("json");
	}
	if(str == null || str.length() <= 0){
		if(request.getQueryString() != null){
			str = URLDecoder.decode(request.getQueryString(), "utf-8");
		}
	}
	
	if(str == null){
		logger.info("yituo no request data");
		out.print("no request data");
		return;
	}
	
	logger.info("yituo return str = " + str);
	
	JSONObject obj = null;
	try{
		Document doc = DocumentHelper.parseText(str);
		Element root = doc.getRootElement();
		for(Iterator<Element> iter = root.elementIterator("data"); iter.hasNext();){
			Element element = iter.next();
			try{
				String taskid = element.elementText("transIDO");
				String result = element.elementText("status");
				String info = element.elementText("desc");
				String status = null;
				String mark = "yituo";
				if(result.equals("0")){
					status = "0";
				}else{
					status = "1";
				}
				LLTempDatabase.addReport(mark, taskid, status, info, "01");
			}catch (Exception e) {
				logger.warn(e.getMessage(), e);
			}
		}
	} catch (Exception e) {
		logger.warn(e.getMessage(), 0);
		out.print("bad json data");
		return;
	}

	out.print("0");
%>