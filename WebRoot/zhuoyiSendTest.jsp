<%@page import="ec.send.zhuoyi.Send"%>
<%@page import="org.apache.logging.log4j.LogManager"%>
<%@page import="org.apache.logging.log4j.Logger"%>
<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%
	boolean logflag = true;
	Logger logger = LogManager.getLogger();

	logger.info("zhuoyi entry1");
	logger.info("zhuoyi entry2");

	try {

		Map<String, String> infoMap = new HashMap<String, String>();
		infoMap.put("phone", "15521097018");
		infoMap.put("areaRange", "shanghaiLiantongQuanguo");
		infoMap.put("product", "20M");
		infoMap.put("UrlSend",
				"http://120.26.78.209/nettraffic/api/order");
		infoMap.put("customer", "gzdyxx");
		infoMap.put("token", "8973557210");
		infoMap.put("effectType", "0");
		infoMap.put("sendLogPath",
				"Logs/Channel-Zhuoyi/Channel-Zhuoyi-8973557210/submitBackTxt.txt");

		Map<String, String> resultMap = new HashMap<String, String>();

		/************************************/
		//request.setAttribute("result", "success");
		//break;
		/************************************/

		//在执行请求前先获取连接, 防止访问通道线程超量

		try {
			resultMap = Send.newRun(infoMap);
		} catch (Exception e) {
			e.printStackTrace();
			logger.info(e.getMessage());
		} finally {
			//在执行请求后记得释放连接
		}

		String state = resultMap.get("state");
		String info = resultMap.get("info");
		System.out.println("@" + state + "@" + info + "@");
		if (state.equals("success")) {
		} else {

		}

	} catch (Exception e) {
		e.printStackTrace();
		logger.info(e.toString());
	}
%>