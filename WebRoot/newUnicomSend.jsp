<%@page import="http.HttpAccess"%>
<%@page import="org.apache.http.client.HttpClient"%>
<%@page import="cache.Cache"%>
<%@page import="util.TimeUtils"%>
<%@page import="org.apache.logging.log4j.LogManager"%>
<%@page import="org.apache.logging.log4j.Logger"%>
<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%
	boolean logflag = true;
	Logger logger = LogManager.getLogger();

	logger.info("newUnicom entry1");

	//获取公共参数
	//任务ID，流水号
	String taskid = request.getAttribute("taskid").toString();
	//通道ID
	String routeid = request.getAttribute("routeid").toString();
	String phone = request.getAttribute("phone").toString();
	//流量包规格
	String packageid = request.getAttribute("package").toString();

	logger.info("newUnicom entry2");

	try {
		while (true) {
			String ret = null;

			Map<String, String> routeparams = Cache
					.getRouteParams(routeid);
			if (routeparams == null) {
				request.setAttribute("result",
						"S." + routeid + ":wrong routeparams@"
								+ TimeUtils.getSysLogTimeString());
				break;
			}

			String pkey = routeparams.get("pkey");
			if (pkey == null) {
				request.setAttribute("result", "S." + routeid
						+ ":wrong routeparams, pkey is null@"
						+ TimeUtils.getSysLogTimeString());
				break;
			}

			String loginName = routeparams.get("loginName");
			if (loginName == null) {
				request.setAttribute("result", "S." + routeid
						+ ":wrong routeparams, loginName is null@"
						+ TimeUtils.getSysLogTimeString());
				break;
			}

			String partnerSecret = routeparams.get("partnerSecret");
			if (partnerSecret == null) {
				request.setAttribute("result", "S." + routeid
						+ ":wrong routeparams, partnerSecret is null@"
						+ TimeUtils.getSysLogTimeString());
				break;
			}

			String sendLogPath = routeparams.get("sendLogPath");
			if (sendLogPath == null) {
				request.setAttribute("result", "S." + routeid
						+ ":wrong routeparams, sendLogPath is null@"
						+ TimeUtils.getSysLogTimeString());
				break;
			}

			String linkURLSend = routeparams.get("linkURLSend");
			if (linkURLSend == null) {
				request.setAttribute("result", "S." + routeid
						+ ":wrong routeparams, linkURLSend is null@"
						+ TimeUtils.getSysLogTimeString());
				break;
			}

			//检查通道参数, 每个通道有不同参数, 对应 ll_routes.api_param
			//例如：yd.150M、yd.1G、lt.500M、dx.200M
			String packagecodeArray[] = packageid.split("\\.");
			if (!packagecodeArray[0].startsWith("lt")) {
				request.setAttribute("result", "S." + routeid
						+ ":wrong routeparams, packagecode is error@"
						+ TimeUtils.getSysLogTimeString());
				break;
			}

			Map<String, String> infoMap = new HashMap<String, String>();
			infoMap.put("phoneNo", phone);
			infoMap.put("productCode", packagecodeArray[1]);
			infoMap.put("pkey", pkey);
			infoMap.put("loginName", loginName);
			infoMap.put("partnerSecret", partnerSecret);
			infoMap.put("sendLogPath", sendLogPath);
			infoMap.put("linkURLSend", linkURLSend);
			StringBuffer sb = new StringBuffer();
			for (String key : infoMap.keySet()) {
				sb.append("####" + key + "::" + infoMap.get(key));
			}
			String sbStr = sb.toString();
			sbStr = sbStr.substring(4);
			Map<String, String> resultMap = new HashMap<String, String>();

			/************************************/
			//request.setAttribute("result", "success");
			//break;
			/************************************/

			//在执行请求前先获取连接, 防止访问通道线程超量

			Cache.getConnection(routeid);
			try {
				Map<String, String> valuemap = new HashMap<String, String>();
				valuemap.put("text", sbStr);
				String httpResult = HttpAccess
						.postNameValuePairRequest(
								infoMap.get("linkURLSend"), valuemap,
								"utf-8", "");
				httpResult=httpResult.trim();
				String httpResultArray[] = httpResult.split("####");
				for (String one : httpResultArray) {
					resultMap.put(one.substring(0, one.indexOf("::")),
							one.substring(one.indexOf("::") + 2));
				}
			} catch (Exception e) {
				e.printStackTrace();
				logger.info(e.toString());
			} finally {
				//在执行请求后记得释放连接
				Cache.releaseConnection(routeid);
			}

			String state = resultMap.get("state");
			String info = resultMap.get("info");
			//orgreturn:原始信息
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

	request.getRequestDispatcher("request.jsp").forward(request,
			response);
%>

