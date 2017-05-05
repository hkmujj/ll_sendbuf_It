<%@page import="net.sf.json.JSONObject"%>
<%@page import="util.TimeUtils"%>
<%@page import="cache.Cache"%>
<%@page import="org.apache.logging.log4j.LogManager"%>
<%@page import="org.apache.logging.log4j.Logger"%>
<%@page import="ec.flowyonghe.check.CheckBatch"%>
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
	
	String appKey = routeparams.get("appKey");
	if(appKey == null){
		request.setAttribute("result", "S." + routeid + ":wrong routeparams, appKey is null@" + TimeUtils.getSysLogTimeString());
		break;
	}	
	
	
	
	String appSecret = routeparams.get("appSecret");
	if(appSecret == null){
		request.setAttribute("result", "S." + routeid + ":wrong routeparams, appSecret is null@" + TimeUtils.getSysLogTimeString());
		break;
	}
	
	String checkBatchLogPath = routeparams.get("checkBatchLogPath");
	if(checkBatchLogPath == null){
		request.setAttribute("result", "S." + routeid + ":wrong routeparams, checkBatchLogPath is null@" + TimeUtils.getSysLogTimeString());
		break;
	}
	String checkReportUrl = routeparams.get("checkReportUrl");
	if(checkReportUrl == null){
		request.setAttribute("result", "S." + routeid + ":wrong routeparams, checkReportUrl is null@" + TimeUtils.getSysLogTimeString());
		break;
	}
	
	//
	Map<String, String> infoMap = new HashMap<String, String>();
	
	infoMap.put("appKey", appKey);
	infoMap.put("appSecret", appSecret);	
	infoMap.put("checkReportUrl", checkReportUrl);
	infoMap.put("checkBatchLogPath", checkBatchLogPath);
	infoMap.put("batchNo", ids);
	infoMap.put("appSecret", appSecret);
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
					if (idReport.equals("4")) {
						rp.put("message", "success");
					} else {
						rp.put("message", resp);
					}
					if(!(idReport.equals("1")|idReport.equals("2")|idReport.equals("3"))){
					obj.put(id, rp);
					}
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

