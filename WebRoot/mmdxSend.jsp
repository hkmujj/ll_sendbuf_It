<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%@page import="org.apache.logging.log4j.LogManager"%>
<%@page import="org.apache.logging.log4j.Logger"%>
<%@page import="ec.flowmmyd.send.Send"%>
<%@page import="cache.Cache"%>
<%@page import="util.TimeUtils"%>
<%
	boolean logflag = true;
	Logger logger = LogManager.getLogger();
	
	logger.info("mmdx entry1");

	//获取公共参数
	String taskid = request.getAttribute("taskid").toString();
	String routeid = request.getAttribute("routeid").toString();
	String userPhone = request.getAttribute("phone").toString();
	String productCode = request.getAttribute("package").toString();
	
	logger.info("mmdx entry2");
	
	try {
		while (true) {
			String ret = null;
			
			Map<String, String> routeparams = Cache.getRouteParams(routeid);
			if(routeparams == null){
				request.setAttribute("result", "S." + routeid + ":wrong routeparams@" + TimeUtils.getSysLogTimeString());
				break;
			}
			String sendLogPath = routeparams.get("sendLogPath");
			if(sendLogPath == null){
				request.setAttribute("result", "S." + routeid + ":wrong routeparams, sendLogPath is null@" + TimeUtils.getSysLogTimeString());
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
			
			String flowType = routeparams.get("flowType");
			if(flowType == null){
				request.setAttribute("result", "S." + routeid + ":wrong routeparams, flowType is null@" + TimeUtils.getSysLogTimeString());
				break;
			}
			
			
			
			String smsId = routeparams.get("smsId");
			if(smsId == null){
				request.setAttribute("result", "S." + routeid + ":wrong routeparams, smsId is null@" + TimeUtils.getSysLogTimeString());
				break;
			}
			
			
			
			String activityName = routeparams.get("activityName");
			if(activityName == null){
				request.setAttribute("result", "S." + routeid + ":wrong routeparams, activityName is null@" + TimeUtils.getSysLogTimeString());
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

			//检查通道参数, 每个通道有不同参数, 对应 ll_routes.api_param
			String packagecodeArray[] = productCode.split("\\.");
			Map<String, String> infoMap = new HashMap<String, String>();
			infoMap.put("account", account);
			infoMap.put("flowType", flowType);
			infoMap.put("password", password);
			infoMap.put("smsId", smsId);
			infoMap.put("sendLogPath", sendLogPath);
			infoMap.put("activityName", activityName);
			infoMap.put("userPhone", userPhone);
			infoMap.put("productCode", packagecodeArray[1]);
			infoMap.put("param1", param1);
			infoMap.put("param2", param2);

			Map<String, String> resultMap = new HashMap<String, String>();
			
			/************************************/
			//request.setAttribute("result", "success");
			//break;
			/************************************/
			
			//在执行请求前先获取连接, 防止访问通道线程超量
			
			Cache.getConnection(routeid);
			try {
				resultMap = Send.newRun(infoMap);
			} catch (Exception e) {
				e.printStackTrace();
				logger.info(e.getMessage());
			} finally {
				//在执行请求后记得释放连接
				Cache.releaseConnection(routeid);
			}

			String state = resultMap.get("state");
			String info = resultMap.get("info");
			if (state.equals("success")) {
			//String idInfoArray[]=info.split(":")[1].split("#");
			//String reportid=idInfoArray[0];
				request.setAttribute("result", "success");
				request.setAttribute("reportid", info);
				request.setAttribute("orgreturn", info);
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
	
	request.getRequestDispatcher("request.jsp").forward(request,response);
%>