<%@page import="util.MD5Util"%>
<%@page
	import="util.TimeUtils,
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
			request.setAttribute(
					"result",
					"S." + routeid + ":wrong routeparams@"
							+ TimeUtils.getSysLogTimeString());
			break;
		}

		String mt_url = routeparams.get("mt_url");
		if (mt_url == null) {
			request.setAttribute("result",
					"S." + routeid + ":wrong routeparams, mt_url is null@"
							+ TimeUtils.getSysLogTimeString());
			break;
		}
		String account = routeparams.get("account");
		if (account == null) {
			request.setAttribute("result", "S." + routeid
					+ ":wrong routeparams, account is null@"
					+ TimeUtils.getSysLogTimeString());
			break;
		}
		String pwd = routeparams.get("pwd");
		if (pwd == null) {
			request.setAttribute("result",
					"S." + routeid + ":wrong routeparams, pwd is null@"
							+ TimeUtils.getSysLogTimeString());
			break;
		}
		String msgTemplateId = routeparams.get("msgTemplateId");
		if (msgTemplateId == null) {
			request.setAttribute("result", "S." + routeid
					+ ":wrong routeparams, msgTemplateId is null@"
					+ TimeUtils.getSysLogTimeString());
			break;
		}

		//参数准备, 每个通道不同
		String packagecode = null;
		try {
			packageid = packageid.split("\\.")[1];
			String pkstr = packageid.substring(0,
					packageid.length() - 1);
			int pk = Integer.parseInt(pkstr);
			if (packageid.indexOf('G') >= 0) {
				pk *= 1000;
			}
			packagecode = String.valueOf(pk);
		} catch (Exception e) {
			logger.warn(e.getMessage(), 0);
		}

		if (packagecode == null) {
			request.setAttribute("result",
					"S." + routeid + ":unrecognized package@"
							+ TimeUtils.getSysLogTimeString());
			break;
		}

		String timestamp = System.currentTimeMillis() + "";

		String mobiles = phone;
		String sign = MD5Util.getLowerMD5(account
				+ MD5Util.getLowerMD5(pwd) + timestamp + mobiles);
		String packageSize = packagecode;
		String clientOrderId = taskid;
		//HashMap<String, String> params = new LinkedHashMap<String, String>();
		JSONObject params = new JSONObject();
		params.put("timestamp", timestamp);
		params.put("sign", sign);
		params.put("mobiles", mobiles);
		params.put("account", account);
		params.put("packageSize", packageSize);
		params.put("msgTemplateId", msgTemplateId);
		params.put("clientOrderId", clientOrderId);

		//在执行请求前先获取连接, 防止访问通道线程超量
		Cache.getConnection(routeid);
		try {
			//ret = HttpAccess.postNameValuePairRequest(url, params, "utf-8", "mysend");
			//ret = HttpAccess.postJsonRequest(url, json.toString(), "utf-8", "weikesend");
		      ret =HttpAccess.postJsonRequest(mt_url, params.toString(), "utf-8", "daHan");
			
		} catch (Exception e) {
			e.printStackTrace();
			logger.info(e.getMessage());
		} finally {
			//在执行请求后记得释放连接
			Cache.releaseConnection(routeid);
		}

		//这里判断结果, 每个通道情况不同, 成功的保存 success 到 result 中并返回到 request.jsp
		if (ret != null && ret.trim().length() > 0) {
			logger.info("dahan send ret = " + ret);
			try {
				JSONObject retjson = JSONObject.fromObject(ret);
				String resultCode = retjson.getString("resultCode"); //":"MOB00001"
				if (resultCode.equals("00")) {
					request.setAttribute("result", "success");
				} else {
					request.setAttribute("code", resultCode);
					String resultMsg=retjson.getString("resultMsg");
					request.setAttribute(
							"result",
							"R." + routeid + ":" + resultCode + ":"
									+ resultMsg + "@"
									+ TimeUtils.getSysLogTimeString());
				}
				request.setAttribute("orgreturn", ret);
			} catch (Exception e) {
				e.printStackTrace();
				logger.info(e.getMessage());
				request.setAttribute("result",
						"R." + routeid + ":" + e.getMessage() + "@"
								+ TimeUtils.getSysLogTimeString());
			}
		} else {
			request.setAttribute("result", "R." + routeid + ":fail@"
					+ TimeUtils.getSysLogTimeString());
		}

		break;
	}

	request.getRequestDispatcher("request.jsp").forward(request,
			response);
%>