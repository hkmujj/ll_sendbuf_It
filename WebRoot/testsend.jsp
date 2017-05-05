<%@page import="test.TestThread,
				test.TestCache,
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
	
	String taskid = request.getAttribute("taskid").toString(); 
	String routeid = request.getAttribute("routeid").toString();
	String phone = request.getAttribute("phone").toString();
	String packageid = request.getAttribute("package").toString();
	
	Random rd = new Random();
	int vx = rd.nextInt(100);
	
	TestThread.mysleep(rd.nextInt(20) + 1);
	
	while(true){
		String ret = null;
		
		if(vx >= 900){
			request.setAttribute("code", "2033");
			request.setAttribute("result", "S." + routeid + ":random error@" + TimeUtils.getSysLogTimeString());
			request.setAttribute("orgreturn", "random error");
			logger.info("charge random error");
			break;
		}
		
		if(vx >= 800){
			request.setAttribute("result", "success");
			request.setAttribute("orgreturn", "success without report");
			logger.info("charge success without report");
			break;
		}
		
		Cache.getConnection(routeid);
		try {
			TestCache.saveid(routeid, taskid);
		} catch (Exception e) {
			e.printStackTrace();
			logger.info(e.getMessage());
		} finally {
			Cache.releaseConnection(routeid);
		}
	
		logger.info("charge success");
		request.setAttribute("result", "success");
		request.setAttribute("orgreturn", "request success");
		
		break;
	}

	request.getRequestDispatcher("request.jsp").forward(request,response);

%>