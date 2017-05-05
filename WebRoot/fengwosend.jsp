<%@page import="com.sun.jmx.snmp.tasks.Task"%>
<%@page import="java.security.MessageDigest"%>
<%@page
	import="util.AES,
				util.MD5Util,
				util.TimeUtils,
				http.HttpAccess,
				cache.Cache,
				net.sf.json.JSONException,
				net.sf.json.JSONObject,
				java.util.*,
				util.MyStringUtils,
				java.net.URLDecoder,
				org.apache.logging.log4j.LogManager,
				org.apache.logging.log4j.Logger"
	language="java" pageEncoding="UTF-8"%>
<%
	boolean logflag = true;
	Logger logger = LogManager.getLogger();

	//获取公共参数
	String taskid = request.getAttribute("taskid").toString();
	String routeid = request.getAttribute("routeid").toString();
	String phone = request.getAttribute("phone").toString();
	String packageid = request.getAttribute("package").toString();

	while (true) {
		String ret = null;

		//检查通道参数, 每个通道有不同参数, 对应 ll_routes.api_params
		Map<String, String> routeparams = Cache.getRouteParams(routeid);
		if (routeparams == null) {
			request.setAttribute("result", "S." + routeid + ":wrong routeparams@" + TimeUtils.getSysLogTimeString());
			break;
		}

		String url = routeparams.get("url");
		if (url == null) {
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, url is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String appid = routeparams.get("appid");
		if (appid == null) {
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, appid is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String appsecret = routeparams.get("appsecret");
		if (appsecret == null) {
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, appsecret is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String ordertype = routeparams.get("ordertype");
		if (ordertype == null) {
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, ordertype is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String version = routeparams.get("version");
		if (version == null) {
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, version is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		//参数准备, 每个通道不同
		String packagecode = null;
		String packagetype = null;
		if (packageid.indexOf("lt.") > -1) {
			try {
				String[] dts = packageid.split("\\.");
				packagetype = dts[0].toUpperCase();
				packageid = dts[1];
				String pkstr = packageid.substring(0, packageid.length() - 1);
				int pk = Integer.parseInt(pkstr);
				if (packageid.indexOf('G') >= 0) {
					pk *= 1024;
				}
				packagecode = packagetype + String.valueOf(pk);
			} catch (Exception e) {
				logger.warn(e.getMessage(), 0);
			}
		}
		if (packagecode == null) {
			request.setAttribute("result", "S." + routeid + ":unrecognized package@" + TimeUtils.getSysLogTimeString());
			break;
		}

		String timestamp = TimeUtils.getTimeStamp();
		String seqno = timestamp;
		String secertkey = MD5Util.getUpperMD5(timestamp + seqno + appid + appsecret);
		String sign = MD5Util.getUpperMD5(appsecret + phone + packagecode + ordertype + taskid);
		JSONObject json = new JSONObject();
		JSONObject obj = new JSONObject();
		JSONObject bodyjson = new JSONObject();
		JSONObject bodyobj = new JSONObject();

		obj.put("VERSION", version);
		obj.put("TIMESTAMP", timestamp);
		obj.put("SEQNO", seqno);
		obj.put("APPID", appid);
		obj.put("SECERTKEY", secertkey);

		bodyjson.put("SIGN", sign);
		bodyjson.put("ORDERTYPE", ordertype);
		bodyjson.put("USER", phone);
		bodyjson.put("PACKAGEID", packagecode);
		bodyjson.put("EXTORDER", taskid);
		bodyjson.put("NOTE", "");

		bodyobj.put("CONTENT", bodyjson);
		json.put("HEADER", obj);
		json.put("MSGBODY", bodyobj);
		logger.info("fengwo json=" + json.toString());

		//在执行请求前先获取连接, 防止访问通道线程超量
		Cache.getConnection(routeid);
		try {
			ret = HttpAccess.postJsonRequest(url, json.toString(), "utf-8", "fengwo");
		} catch (Exception e) {
			e.printStackTrace();
			logger.info(e.getMessage());
		} finally {
			//在执行请求后记得释放连接
			Cache.releaseConnection(routeid);
		}

		//这里判断结果, 每个通道情况不同, 成功的保存 success 到 result 中并返回到 request.jsp
		if (ret != null && ret.trim().length() > 0) {
			logger.info("fengwo send ret = " + ret);
			try {
				JSONObject retjson = JSONObject.fromObject(ret);
				JSONObject msgjson = retjson.getJSONObject("MSGBODY").getJSONObject("RESP");
				String code = msgjson.getString("RCODE");
				if (code != null && code.equals("00")) {
					request.setAttribute("result", "success");
				} else {
					request.setAttribute("code", 1);
					String msg = "fail";
					if (msgjson.get("RMSG") != null) {
						msg = msgjson.getString("RMSG");
					}

					request.setAttribute("result", "R." + routeid + ":" + code + "" + msg + "@" + TimeUtils.getSysLogTimeString());
				}
				request.setAttribute("orgreturn", ret);
			} catch (Exception e) {
				e.printStackTrace();
				logger.info(e.getMessage());
				request.setAttribute("result", "R." + routeid + ":" + e.getMessage() + "@" + TimeUtils.getSysLogTimeString());
			}
		} else {
			request.setAttribute("result", "R." + routeid + ":fail@" + TimeUtils.getSysLogTimeString());
		}

		break;
	}

	request.getRequestDispatcher("request.jsp").forward(request, response);
%>