<%@page import="java.net.URLEncoder"%>
<%@page import="org.eclipse.jetty.util.UrlEncoded"%>
<%@page import="com.aspire.portal.web.security.client.GenerateSignature"%>
<%@page import="net.sf.json.JSONObject"%>
<%@page import="util.TimeUtils"%>
<%@page import="database.LLTempDatabase"%>
<%@page import="database.DatabaseUtils"%>
<%@page import="http.HttpAccess"%>
<%@page import="org.dom4j.io.XMLWriter"%>
<%@page import="org.dom4j.io.OutputFormat"%>
<%@page import="java.io.StringWriter"%>
<%@page import="key.Key"%>

<%@ page language="java"
	import="java.util.*,
								org.apache.logging.log4j.LogManager,
								org.apache.logging.log4j.Logger,
								java.util.Map.Entry,
								database.LLTempDatabase,
								org.dom4j.Element,
								org.dom4j.DocumentHelper,
								org.dom4j.Document,
								java.sql.Connection,
								java.sql.PreparedStatement,
								java.sql.ResultSet,
								java.util.HashMap,
								java.util.LinkedHashMap"
	pageEncoding="UTF-8"%><%!private static boolean logflag = true;
	private static Logger logger = LogManager.getLogger();
	private static HashMap<String, zqstatus> statusmap = null;

	private static class zqstatus {
		public String taskid;
		public String info;
		public String code;
	}

	private static boolean savestatus(ArrayList<zqstatus> ary,String cdt) {
		StringBuffer sb = new StringBuffer();
		try {
			for (int i = 0; i < ary.size(); i++) {
				zqstatus zq = ary.get(i);
				//	LLTempDatabase.addReport("zqydhongbao", zq.taskid, zq.code, zq.info, "01");
				LLTempDatabase.addReport(cdt, zq.taskid, zq.code, zq.info, "01");
			}
		} catch (Exception e) {
			e.printStackTrace();
			logger.info("zqllt e= " + e);
			return false;
		}
		return true;
	}

	private static ArrayList<zqstatus> status(String[] userids) {
		ArrayList<zqstatus> arr = new ArrayList<zqstatus>();
		for (int i = 0; i < userids.length; i++) {
			logger.info(userids[i]);
			String ret = getStatus(userids[i]);
			if (ret.indexOf("充值失败") >= 0) {
				zqstatus zq = new zqstatus();
				zq.code = "1";
				zq.info = ret.substring(ret.indexOf("失败码:"), ret.indexOf(", 失败原因")).substring(4);
				zq.taskid = userids[i];
				arr.add(zq);
			} else if (ret.indexOf("充值成功") >= 0) {
				zqstatus zq = new zqstatus();
				zq.code = "0";
				zq.info = "成功";
				zq.taskid = userids[i];
				arr.add(zq);
			} else {
			}
			logger.info("zqllt 1");
		}
		logger.info("zqllt arrsize=" + arr.size());
		return arr;
	}

	private static String getStatus(String userid) {
		String ids = LLTempDatabase.getMapValue("zqydhongbao", userid, "06");
		logger.info("" + ids);
		if (ids == null || ids.trim().length() <= 0) {
			return "S.@查询不到订单号";
		}
		Map<String, String> parm = new HashMap<String, String>();
		parm.put("portalType", ids.substring(0, 3));
		parm.put("portalID", ids.substring(3, 13));
		String t = String.valueOf(System.currentTimeMillis());
		parm.put("transactionID", TimeUtils.getTimeStamp().substring(2) + t.substring(0, 8));
		parm.put("method", "companyDonateFlow");
		parm.put("mobile", ids.substring(ids.length() - 11));
		parm.put("sequence", ids.substring(0, ids.length() - 11));
		StringBuffer sb = new StringBuffer();
		sb.append("method=");
		sb.append(parm.get("method"));
		sb.append("&mobile=");
		sb.append(parm.get("mobile"));
		sb.append("&portalID=");
		sb.append(parm.get("portalID"));
		sb.append("&portalType=");
		sb.append(parm.get("portalType"));
		sb.append("&sequence=");
		sb.append(parm.get("sequence"));
		sb.append("&transactionID=");
		sb.append(parm.get("transactionID"));
		logger.info("zqhongbaostatus2 sign string=" + sb.toString());
		GenerateSignature gs = new GenerateSignature();
		String path = Key.keypath + "liulianghongbao/rasPrivateKey.txt";
		if (ids.substring(0, 3).equals("WWW")) {
			path = Key.keypath + "liulianghongbao/private.key";
		}
		String sign = gs.sign(sb.toString(), path);
		parm.put("sign", sign);

		String ret = "";
		//发送查询/获取状态前先获取连接, 防止访问线程超量
		try {
			ret = http.HttpAccess.postNameValuePairRequest("http://gd.liuliangjia.cn:20811/openapi/v2.0", parm, "utf-8", "zqhongbaostatus2");
		} catch (Exception e) {
			e.printStackTrace();
			logger.info(e.getMessage());
			return userid + ":查询失败@查询错误，查询错误";

		} finally {
			//发送查询/获取状态后释放连接
		}

		//这里判断结果, 每个通道情况不同, 成功的节点ID对应success, 失败的对应失败信息
		if (ret != null && ret.trim().length() > 0) {
			//request.setAttribute("result", "success");
			logger.info("zqydhongbao  status ret = " + ret);
			try {
				JSONObject robj = JSONObject.fromObject(ret);
				String retCode = robj.getString("code");
				if (retCode.equals("0")) {
					JSONObject jsondata = robj.getJSONObject("result");
					String staus = jsondata.getString("retCode");
					if (staus.equals("0")) {
						return userid + ":" + "充值成功";
					} else if (staus.trim().length() == 0) {
						return userid + ":" + "充值中";
					} else if (staus.trim().length() > 0) {
						String msg = "失败";
						if (jsondata.get("reqMsg") != null) {
							msg = jsondata.getString("reqMsg");
						}
						return userid + ":充值失败, 失败码:" + staus + ", 失败原因:" + msg;
					} else {
						logger.info("zqydhongbao  status : [" + ret + "]充值中@" + TimeUtils.getSysLogTimeString());
						return userid + ":查询失败@查询返回 : [" + ret + "]";

					}
				} else {
					logger.info("zqydhongbao  status : [" + ret + "]状态码" + retCode + "@" + TimeUtils.getSysLogTimeString());
					return userid + ":查询失败@查询返回 : [" + ret + "]";
				}
			} catch (Exception e) {
				logger.warn(e.getMessage(), e);
				logger.info("zqydhongbao  status : " + e.getMessage() + ", ret = " + ret + "@" + TimeUtils.getSysLogTimeString());
				return userid + ":查询失败@查询返回 : [" + ret + "]";

			}
		} else {
			logger.info("zqydhongbao  status : " + "fail@" + TimeUtils.getSysLogTimeString());
			return userid + ":查询失败@查询没有返回 ";
		}
	}%>
<%
	logger.info("zqllt here");
	out.print("");
	Map<String, String[]> paramMap = request.getParameterMap();
	logger.info("zqllt act" + paramMap.get("act"));
	if (paramMap.get("act") != null) {
		String act = paramMap.get("act")[0].toString();
		if (act.equals("pushstatus")) {
			String ids = paramMap.get("ids")[0].toString();
			String cdt = paramMap.get("cdt")[0].toString();
			if (ids.trim().length() <= 0) {
				out.print("没有选中要推送状态的订单");
				return;
			}

			String[] idarr = ids.split(",");
			ArrayList<zqstatus> statuslist = new ArrayList<zqstatus>();

			for (int i = 0; i < idarr.length; i++) {
				zqstatus unit = statusmap.get(idarr[i]);
				statuslist.add(unit);
			}

			if (statuslist.size() <= 0) {
				out.print("没有符合的订单号");
				return;
			}

			boolean retb = savestatus(statuslist,cdt);
			logger.info("zqllt zqhongbao here5=");

			if (retb) {
				out.print("success");
			} else {
				out.print("fail");
			}

			return;
		}
	}

	String userid = request.getParameter("userid");
	if (userid.trim().length() <= 0) {
		out.print("订单号为空");
		return;
	}
	String[] userids = userid.replace("\r", "\n").replace("\n\n", "\n").split("\n");

	ArrayList<zqstatus> arr = null;
	arr = status(userids);
	logger.info("zqhongbaoary llt=" + arr);
	statusmap = new HashMap<String, zqstatus>();
	for (int i = 0; i < arr.size(); i++) {
		statusmap.put(arr.get(i).taskid, arr.get(i));
	}

	out.print("<div style=\"height:600px; width:100%; overflow:auto; word-wrap:break-word;\">");
	out.print("<table class=\"gridtable\" >");

	out.print("<tr>");
	out.print("<td style=\"background:#eee; width:20%; border-bottom:1px solid #555; border-right:1px solid #555;\">选择</td>");
	out.print("<td style=\"background:#eee; width:30%; border-bottom:1px solid #555; border-right:1px solid #555;\">平台订单号</td>");
	out.print("<td style=\"background:#eee; width:20%; border-bottom:1px solid #555; border-right:1px solid #555;\">描述</td>");
	out.print("<td style=\"background:#eee; width:20%; border-bottom:1px solid #555; border-right:1px solid #555;\">状态码</td>");

	out.print("</tr>");
	for (int i = 0; i < arr.size(); i++) {
		zqstatus unit = arr.get(i);
		out.print("<tr>");
		String color = "";
		if ((i & 1) != 0) {
			color = "background:#eee;";
		}
		out.print("<td style=\"");
		out.print(color);
		out.print("width:20%;\">");
		out.print("<input type=\"checkbox\" name=\"pushids\" value=\"");
		out.print(unit.taskid);
		out.print("\"/>");
		out.print("</td><td style=\"");
		out.print(color);
		out.print("width:30%;\">");
		out.print(unit.taskid);
		out.print("</td><td style=\"");
		out.print(color);
		out.print("width:20%;\">");
		out.print(unit.info);
		out.print("</td><td style=\"");
		out.print(color);
		out.print("width:20%;\">");
		out.print(unit.code);
		out.print("</td></tr>");
	}
	out.print("</table>");
	int b = 0;
	for (int i = 0; i < userids.length; i++) {
		if (statusmap.get(userids[i]) == null) {
			if (b == 0) {
				out.print("<table class=\"loadidtable\">");
				out.print("<tr>");
				String color = "";
				if ((b & 1) != 0) {
					color = "background:#eee;";
				}
				out.print("<td style=\"");
				out.print(color);
				out.print("width:100%;\">");
				out.print("状态未知订单号");
				out.print("</td></tr>");
				b++;

				out.print("<tr>");
				if ((b & 1) != 0) {
					color = "background:#eee;";
				}
				out.print("<td style=\"");
				out.print(color);
				out.print("width:100%;\">");
				out.print(userids[i]);
				out.print("</td></tr>");
			} else {
				b++;
				out.print("<tr>");
				String color = "";
				if ((b & 1) != 0) {
					color = "background:#eee;";
				}
				out.print("<td style=\"");
				out.print(color);
				out.print("width:100%;\">");
				out.print(userids[i]);
				out.print("</td></tr>");
			}
		}
	}
	if (b != 0) {
		out.print("</table>");
	}
	out.print("</div>");

	Thread.sleep(1000);
%>