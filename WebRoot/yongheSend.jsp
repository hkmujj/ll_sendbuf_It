<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%@page import="org.apache.logging.log4j.LogManager"%>
<%@page import="org.apache.logging.log4j.Logger"%>
<%@page import="ec.flowyonghe.send.Send"%>
<%@page import="cache.Cache"%>
<%@page import="util.TimeUtils"%>
<%
	boolean logflag = true;
	Logger logger = LogManager.getLogger();
	
	logger.info("yonghe entry1");

	//获取公共参数
	String taskid = request.getAttribute("taskid").toString();
	String routeid = request.getAttribute("routeid").toString();
	String userPhone = request.getAttribute("phone").toString();
	String productCode = request.getAttribute("package").toString();
	
	logger.info("yonghe entry2");
	
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
			String appKey = routeparams.get("appKey");
			if(appKey == null){
				request.setAttribute("result", "S." + routeid + ":wrong routeparams, appKey is null@" + TimeUtils.getSysLogTimeString());
				break;
			}	
			
			
			
			String effective = routeparams.get("effective");
			if(effective == null){
				request.setAttribute("result", "S." + routeid + ":wrong routeparams, effective is null@" + TimeUtils.getSysLogTimeString());
				break;
			}
			
			String range = routeparams.get("range");
			if(range == null){
				request.setAttribute("result", "S." + routeid + ":wrong routeparams, range is null@" + TimeUtils.getSysLogTimeString());
				break;
			}
			
			
			
			String appSecret = routeparams.get("appSecret");
			if(appSecret == null){
				request.setAttribute("result", "S." + routeid + ":wrong routeparams, appSecret is null@" + TimeUtils.getSysLogTimeString());
				break;
			}
			
			
			
			String verify = routeparams.get("verify");
			if(verify == null){
				request.setAttribute("result", "S." + routeid + ":wrong routeparams, verify is null@" + TimeUtils.getSysLogTimeString());
				break;
			}
			
			String sendUrl = routeparams.get("sendUrl");
			if(sendUrl == null){
				request.setAttribute("result", "S." + routeid + ":wrong routeparams, sendUrl is null@" + TimeUtils.getSysLogTimeString());
				break;
			}
			
			//检查通道参数, 每个通道有不同参数, 对应 ll_routes.api_param
			String packagecodeArray[] = productCode.split("\\.");
			Map<String, String> infoMap = new HashMap<String, String>();
			infoMap.put("appKey", appKey);
			infoMap.put("range", range);
			infoMap.put("effective", effective);
			infoMap.put("appSecret", appSecret);
			infoMap.put("sendLogPath", sendLogPath);
			infoMap.put("verify", verify);
			infoMap.put("sendUrl", sendUrl);
			infoMap.put("mobileNumber", userPhone);
			infoMap.put("size", packagecodeArray[1]);
			infoMap.put("batchNo", "");

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