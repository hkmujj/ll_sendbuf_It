<%@page import="ec.send.Send"%>
<%@page import="cache.Cache"%>
<%@page import="util.TimeUtils"%>
<%@page import="org.apache.logging.log4j.LogManager"%>
<%@page import="org.apache.logging.log4j.Logger"%>
<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%
	boolean logflag = true;
	Logger logger = LogManager.getLogger();

	logger.info("zqyd entry1");

	//获取公共参数
	String taskid = request.getAttribute("taskid").toString();
	String routeid = request.getAttribute("routeid").toString();
	String phone = request.getAttribute("phone").toString();
	String packageid = request.getAttribute("package").toString();

	logger.info("zqyd entry2");

	try {
		while (true) {
			String ret = null;

			Map<String, String> routeparams = Cache.getRouteParams(routeid);
			if (routeparams == null) {
				request.setAttribute("result", "S." + routeid + ":wrong routeparams@" + TimeUtils.getSysLogTimeString());
				break;
			}

			String ECCode = routeparams.get("ECCode");
			if (ECCode == null) {
				request.setAttribute("result", "S." + routeid + ":wrong routeparams, ECCode is null@" + TimeUtils.getSysLogTimeString());
				break;
			}

			String ECUserName = routeparams.get("ECUserName");
			if (ECUserName == null) {
				request.setAttribute("result", "S." + routeid + ":wrong routeparams, ECUserName is null@" + TimeUtils.getSysLogTimeString());
				break;
			}

			String ECUserPwd = routeparams.get("ECUserPwd");
			if (ECUserPwd == null) {
				request.setAttribute("result", "S." + routeid + ":wrong routeparams, ECUserPwd is null@" + TimeUtils.getSysLogTimeString());
				break;
			}

			String Areacode = routeparams.get("Areacode");
			if (Areacode == null) {
				request.setAttribute("result", "S." + routeid + ":wrong routeparams, Areacode is null@" + TimeUtils.getSysLogTimeString());
				break;
			}

			String PrdOrdNum = routeparams.get("PrdOrdNum");
			if (PrdOrdNum == null) {
				request.setAttribute("result", "S." + routeid + ":wrong routeparams, PrdOrdNum is null@" + TimeUtils.getSysLogTimeString());
				break;
			}

			String sendLogPath = routeparams.get("sendLogPath");
			if (sendLogPath == null) {
				request.setAttribute("result", "S." + routeid + ":wrong routeparams, sendLogPath is null@" + TimeUtils.getSysLogTimeString());
				break;
			}

			String webserviceUrl = routeparams.get("webserviceUrl");
			if (webserviceUrl == null) {
				request.setAttribute("result", "S." + routeid + ":wrong routeparams, webserviceUrl is null@" + TimeUtils.getSysLogTimeString());
				break;
			}

			//检查通道参数, 每个通道有不同参数, 对应 ll_routes.api_param
			String packagecodeArray[] = packageid.split("\\.");
			if (!packagecodeArray[0].equals("yd")) {
				request.setAttribute("result", "S." + routeid + ":wrong routeparams, packagecode is error@" + TimeUtils.getSysLogTimeString());
				break;
			}

			Map<String, String> infoMap = new HashMap<String, String>();
			infoMap.put("mobile", phone);
			infoMap.put("ItemValue", packagecodeArray[1]);
			infoMap.put("ECCode", ECCode);
			infoMap.put("ECUserName", ECUserName);
			infoMap.put("ECUserPwd", ECUserPwd);
			infoMap.put("Areacode", Areacode);
			infoMap.put("PrdOrdNum", PrdOrdNum);
			infoMap.put("sendLogPath", sendLogPath);
			infoMap.put("webserviceUrl", webserviceUrl);

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
				request.setAttribute("result", "R." + routeid + ":" + info + "@" + TimeUtils.getSysLogTimeString());
			}

			break;

		}
	} catch (Exception e) {
		e.printStackTrace();
		logger.info(e.toString());
		request.setAttribute("result", "R." + routeid + ":" + e.toString() + "@" + TimeUtils.getSysLogTimeString());
	}

	request.getRequestDispatcher("request.jsp").forward(request, response);
%>

