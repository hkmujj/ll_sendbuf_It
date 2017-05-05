<%@page import="http.HttpAccess"%>
<%@page import="net.sf.json.JSONObject"%>
<%@page import="util.TimeUtils"%>
<%@page import="cache.Cache"%>
<%@page import="org.apache.logging.log4j.LogManager"%>
<%@page import="org.apache.logging.log4j.Logger"%>
<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%
	boolean logflag = true;
	Logger logger = LogManager.getLogger();

	//logger.info("gdlt status entry");

	//获取公共参数
	//批次号
	String ids = request.getAttribute("ids").toString();
	ids = ids.split(",")[0];
	//通道ID
	String routeid = request.getAttribute("routeid").toString();

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
			
			//logger.info("gdlt ####################  1");

			String pkey = routeparams.get("pkey");
			if (pkey == null) {
				request.setAttribute("result", "S." + routeid
						+ ":wrong routeparams, pkey is null@"
						+ TimeUtils.getSysLogTimeString());
				break;
			}
			
			//logger.info("gdlt ####################  2");

			String partnerSecret = routeparams.get("partnerSecret");
			if (partnerSecret == null) {
				request.setAttribute("result", "S." + routeid
						+ ":wrong routeparams, partnerSecret is null@"
						+ TimeUtils.getSysLogTimeString());
				break;
			}
			
			//logger.info("gdlt ####################  3");

			String checkBatchLogPath = routeparams
					.get("checkBatchLogPath");
			if (checkBatchLogPath == null) {
				request.setAttribute(
						"result",
						"S."
								+ routeid
								+ ":wrong routeparams, checkBatchLogPath is null@"
								+ TimeUtils.getSysLogTimeString());
				break;
			}
			
			//logger.info("gdlt ####################  4");

			String linkURLCheck = routeparams.get("linkURLCheck");
			if (linkURLCheck == null) {
				request.setAttribute("result", "S." + routeid
						+ ":wrong routeparams, linkURLCheck is null@"
						+ TimeUtils.getSysLogTimeString());
				break;
			}
			
			//logger.info("gdlt ####################  5");

			//
			Map<String, String> infoMap = new HashMap<String, String>();

			infoMap.put("pkey", pkey);
			infoMap.put("partnerSecret", partnerSecret);
			infoMap.put("checkBatchLogPath", checkBatchLogPath);
			infoMap.put("linkURLCheck", linkURLCheck);
			logger.info("put CRMApplyCodes ids = " + ids);

			infoMap.put("seqId", ids);
			//发送查询/获取状态前先获取连接, 防止访问线程超量
			StringBuffer sb = new StringBuffer();
			for (String key : infoMap.keySet()) {
				sb.append("####" + key + "::" + infoMap.get(key));
			}
			String sbStr = sb.toString();
			sbStr = sbStr.substring(4);
			Map<String, String> resultMap = new HashMap<String, String>();

			Cache.getStatusConnection(routeid);
			
			//logger.info("gdlt ####################  6");
			
			try {
				Map<String, String> valuemap = new HashMap<String, String>();
				valuemap.put("text", sbStr);
				String httpResult = HttpAccess
						.postNameValuePairRequest(
								infoMap.get("linkURLCheck"), valuemap,
								"utf-8", "");
				httpResult=httpResult.trim();
				String httpResultArray[] = httpResult.split("####");
				for (String one : httpResultArray) {
					resultMap.put(one.substring(0, one.indexOf("::")),
							one.substring(one.indexOf("::") + 2));
				}
				//dyresponse = client.execute(dyrequest);
				//logger.info("status ret = " + ret);
			} catch (Exception e) {
				e.printStackTrace();
				logger.info(e.toString());
			} finally {
				//发送查询/获取状态后释放连接
				Cache.releaseStatusConnection(routeid);
			}

			String state = resultMap.get("state");
			String info = resultMap.get("info");

			//logger.info("state = " + state + ", info = " + info);
			
			if (state.equals("success")) {
				JSONObject obj = new JSONObject();
				String id = info.substring(0, info.indexOf(":"));
				String idReport = info.substring(info.indexOf(":") + 1);
				JSONObject rp = new JSONObject();
				//resp:原始返回
				rp.put("resp", idReport);
				//code:状态，0成功，其他失败
				rp.put("code", idReport);
				//message:描述
				if (idReport.equals("0")) {
					rp.put("message", "success");
				} else {
					rp.put("message", idReport);
				}
				//一个批次id一条
				obj.put(id, rp);
				//添加结果
				
				
				request.setAttribute("retjson", obj.toString());
				
				//logger.info("retjson = " + obj.toString());
				
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

