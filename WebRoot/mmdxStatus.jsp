<%@page import="net.sf.json.JSONObject"%>
<%@page import="util.TimeUtils"%>
<%@page import="cache.Cache"%>
<%@page import="org.apache.logging.log4j.LogManager"%>
<%@page import="org.apache.logging.log4j.Logger"%>
<%@page import="ec.flowmmyd.check.CheckBatch"%>
<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%
	boolean logflag = true;
	Logger logger = LogManager.getLogger();

	//获取公共参数
	String ids = request.getAttribute("ids").toString();
	ids=ids.split(",")[0];
	String routeid = request.getAttribute("routeid").toString();

	try {
		while (true) {
	String ret = null;
	
	Map<String, String> routeparams = Cache.getRouteParams(routeid);
	if(routeparams == null){
		request.setAttribute("result", "S." + routeid + ":wrong routeparams@" + TimeUtils.getSysLogTimeString());
		break;
	}
	
	String account = routeparams.get("account");
	if(account == null){
		request.setAttribute("result", "S." + routeid + ":wrong routeparams, account is null@" + TimeUtils.getSysLogTimeString());
		break;
	}	
	
	
	
	String password = routeparams.get("password");
	if(password == null){
		request.setAttribute("result", "S." + routeid + ":wrong routeparams, password is null@" + TimeUtils.getSysLogTimeString());
		break;
	}
	
	String checkBatchLogPath = routeparams.get("checkBatchLogPath");
	if(checkBatchLogPath == null){
		request.setAttribute("result", "S." + routeid + ":wrong routeparams, checkBatchLogPath is null@" + TimeUtils.getSysLogTimeString());
		break;
	}
	
	String param1 = routeparams.get("param1");
	if(param1 == null){
		request.setAttribute("result", "S." + routeid + ":wrong routeparams, param1 is null@" + TimeUtils.getSysLogTimeString());
		break;
	}
	String param2 = routeparams.get("param2");
	if(param2 == null){
		request.setAttribute("result", "S." + routeid + ":wrong routeparams, param2 is null@" + TimeUtils.getSysLogTimeString());
		break;
	}
	
	//
	Map<String, String> infoMap = new HashMap<String, String>();
	
	infoMap.put("account", account);
	infoMap.put("password", password);	
	infoMap.put("param1", param1);
	infoMap.put("param2", param2);
	infoMap.put("checkBatchLogPath", checkBatchLogPath);
	infoMap.put("sessionId", ids);
	logger.info("put CRMApplyCodes ids = " + ids);
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
			String  resp= report.substring(report
					.indexOf(":") + 1);
			JSONObject rp = new JSONObject();
			rp.put("resp", resp);
			String idReport=resp.split("@")[0];
					rp.put("code", idReport);
					if (resp.length() > 74) {
						resp = resp.substring(0, 75);
					}
					if (idReport.equals("0")) {
						rp.put("message", "success");
					} else {
						rp.put("message", resp);
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

