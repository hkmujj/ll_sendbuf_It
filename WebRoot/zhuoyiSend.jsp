<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%@page import="org.apache.logging.log4j.LogManager"%>
<%@page import="org.apache.logging.log4j.Logger"%>
<%@page import="ec.send.zhuoyi.Send"%>
<%@page import="cache.Cache"%>
<%@page import="util.TimeUtils"%>
<%
	boolean logflag = true;
	Logger logger = LogManager.getLogger();
	
	logger.info("zhuoyi entry1");

	//获取公共参数
	String taskid = request.getAttribute("taskid").toString();
	String routeid = request.getAttribute("routeid").toString();
	String phone = request.getAttribute("phone").toString();
	String packageid = request.getAttribute("package").toString();
	
	logger.info("zhuoyi entry2");
	
	try {
		while (true) {
			String ret = null;
			
			Map<String, String> routeparams = Cache.getRouteParams(routeid);
			if(routeparams == null){
				request.setAttribute("result", "S." + routeid + ":wrong routeparams@" + TimeUtils.getSysLogTimeString());
				break;
			}
			
			String UrlSend = routeparams.get("UrlSend");
			if(UrlSend == null){
				request.setAttribute("result", "S." + routeid + ":wrong routeparams, UrlSend is null@" + TimeUtils.getSysLogTimeString());
				break;
			}	
			
			String customer = routeparams.get("customer");
			if(customer == null){
				request.setAttribute("result", "S." + routeid + ":wrong routeparams, customer is null@" + TimeUtils.getSysLogTimeString());
				break;
			}
			
			String token = routeparams.get("token");
			if(token == null){
				request.setAttribute("result", "S." + routeid + ":wrong routeparams, token is null@" + TimeUtils.getSysLogTimeString());
				break;
			}
			
			String effectType = routeparams.get("effectType");
			if(effectType == null){
				request.setAttribute("result", "S." + routeid + ":wrong routeparams, effectType is null@" + TimeUtils.getSysLogTimeString());
				break;
			}
			
			String sendLogPath = routeparams.get("sendLogPath");
			if(sendLogPath == null){
				request.setAttribute("result", "S." + routeid + ":wrong routeparams, sendLogPath is null@" + TimeUtils.getSysLogTimeString());
				break;
			}
			
			String areaRange = routeparams.get("areaRange");
			if(areaRange == null){
				request.setAttribute("result", "S." + routeid + ":wrong routeparams, areaRange is null@" + TimeUtils.getSysLogTimeString());
				break;
			}

			//检查通道参数, 每个通道有不同参数, 对应 ll_routes.api_param
			String packagecodeArray[] = packageid.split("\\.");
			/* 
			if (!packagecodeArray[0].startsWith("lt")) {
				request.setAttribute("result", "S." + routeid
						+ ":wrong routeparams, packagecode is error@"
						+ TimeUtils.getSysLogTimeString());
				break;
			}
			 */

			Map<String, String> infoMap = new HashMap<String, String>();
			infoMap.put("phone", phone);
			infoMap.put("product", packagecodeArray[1]);
			infoMap.put("UrlSend", UrlSend);
			infoMap.put("customer", customer);
			infoMap.put("token", token);
			infoMap.put("effectType", effectType);
			infoMap.put("sendLogPath", sendLogPath);
			infoMap.put("areaRange", areaRange);

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