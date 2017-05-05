<%@page import="net.sf.json.JSONObject"%>
<%@page import="util.TimeUtils"%>
<%@page import="cache.Cache"%>
<%@page import="org.apache.logging.log4j.LogManager"%>
<%@page import="org.apache.logging.log4j.Logger"%>
<%@page import="ec.check.CheckBatch"%>
<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%
	boolean logflag = true;
	Logger logger = LogManager.getLogger();

	//获取公共参数
	String ids = request.getAttribute("ids").toString();
	String routeid = request.getAttribute("routeid").toString();

	try {
		while (true) {
			String ret = null;
			
			Map<String, String> routeparams = Cache.getRouteParams(routeid);
			if(routeparams == null){
				request.setAttribute("result", "S." + routeid + ":wrong routeparams@" + TimeUtils.getSysLogTimeString());
				break;
			}
			
			String ECCode = routeparams.get("ECCode");
			if(ECCode == null){
				request.setAttribute("result", "S." + routeid + ":wrong routeparams, ECCode is null@" + TimeUtils.getSysLogTimeString());
				break;
			}	
			
			String ECUserName = routeparams.get("ECUserName");
			if(ECUserName == null){
				request.setAttribute("result", "S." + routeid + ":wrong routeparams, ECUserName is null@" + TimeUtils.getSysLogTimeString());
				break;
			}
			
			String ECUserPwd = routeparams.get("ECUserPwd");
			if(ECUserPwd == null){
				request.setAttribute("result", "S." + routeid + ":wrong routeparams, ECUserPwd is null@" + TimeUtils.getSysLogTimeString());
				break;
			}
			
			String Areacode = routeparams.get("Areacode");
			if(Areacode == null){
				request.setAttribute("result", "S." + routeid + ":wrong routeparams, Areacode is null@" + TimeUtils.getSysLogTimeString());
				break;
			}
			
			
			String checkBatchLogPath = routeparams.get("checkBatchLogPath");
			if(checkBatchLogPath == null){
				request.setAttribute("result", "S." + routeid + ":wrong routeparams, checkBatchLogPath is null@" + TimeUtils.getSysLogTimeString());
				break;
			}
			
			String webserviceUrl = routeparams.get("webserviceUrl");
			if(webserviceUrl == null){
				request.setAttribute("result", "S." + routeid + ":wrong routeparams, webserviceUrl is null@" + TimeUtils.getSysLogTimeString());
				break;
			}
			
			//
			Map<String, String> infoMap = new HashMap<String, String>();
			
					
			infoMap.put("ECCode", ECCode);
			infoMap.put("ECUserName", ECUserName);
			infoMap.put("ECUserPwd", ECUserPwd);
			infoMap.put("Areacode", Areacode);
			infoMap.put("checkBatchLogPath", checkBatchLogPath);
			infoMap.put("webserviceUrl", webserviceUrl);
			logger.info("put CRMApplyCodes ids = " + ids);
			
			infoMap.put("CRMApplyCodes",ids);
			//发送查询/获取状态前先获取连接, 防止访问线程超量
			Map<String, String> resultMap = new HashMap<String, String>();
			Cache.getStatusConnection(routeid);
			try {
				resultMap = CheckBatch.checkReportBatchRun(infoMap);
				//dyresponse = client.execute(dyrequest);
				//logger.info("status ret = " + ret);
			} catch (Exception e) {
				e.printStackTrace();
				logger.info(e.getMessage());
			} finally {
				//发送查询/获取状态后释放连接
				Cache.releaseStatusConnection(routeid);
			}

			String state = resultMap.get("state");
			String info = resultMap.get("info");

			if (state.equals("success")) {
				JSONObject obj = new JSONObject();
				String infoArray[] = info.split("#");
				for (String report : infoArray) {
					String id = report
							.substring(0, report.indexOf(":"));
					String idReport = report.substring(report
							.indexOf(":") + 1);
					JSONObject rp = new JSONObject();
					rp.put("resp", idReport);
					if (idReport.equals("4")) {
						idReport = "0";
					} else if (idReport.equals("0")) {
						idReport = "10";
					}
					rp.put("code", idReport);
					if (idReport.equals("0")) {
						rp.put("message", "success");
					} else {
						rp.put("message", idReport);
					}
					obj.put(id, rp);
				}
				request.setAttribute("retjson", obj.toString());
				request.setAttribute("result", "success");
			} else {
				request.setAttribute("result", "R." + routeid + ":"
						+ info + "@" + TimeUtils.getSysLogTimeString());
			}
			break;
		}
	} catch (Exception e) {
		e.printStackTrace();
		logger.info(e.toString());
		request.setAttribute(
				"result",
				"R." + routeid + ":" + e.toString() + "@"
						+ TimeUtils.getSysLogTimeString());
	}
	request.getRequestDispatcher("request.jsp").forward(request,
			response);
%>

