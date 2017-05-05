<%@page
	import="util.TimeUtils,
				http.HttpAccess,
				util.MD5Util,
				cache.Cache,
				net.sf.json.JSONException,
				net.sf.json.JSONObject,
				java.util.*,
				util.MyStringUtils,
				java.net.URLDecoder,
				org.apache.logging.log4j.LogManager,
				org.apache.logging.log4j.Logger,
				util.MyBase64,
				java.security.MessageDigest,
				java.security.NoSuchAlgorithmException,
				java.io.UnsupportedEncodingException"
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

		//检查通道参数, 每个通道有不同参数, 对应 ll_routes.api_params(私有参数)
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
		String loginname = routeparams.get("loginname");
		if (loginname == null) {
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, loginname is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String api_key = routeparams.get("api_key");
		if (api_key == null) {
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, api_key is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String prodid = routeparams.get("prodid");
		if (prodid == null) {
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, prodid is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String cmd = "recharge";

		//参数准备, 每个通道不同
		String packagecode = null;//新号吧接200M红包
		try {
			packageid = packageid.split("\\.")[1];
			String pkstr = packageid.substring(0, packageid.length() - 1);
			int pk = Integer.parseInt(pkstr);
			if (packageid.indexOf('G') >= 0) {
				pk *= 1000;
			}
			packagecode = String.valueOf(pk);
		} catch (Exception e) {
			logger.warn(e.getMessage(), 0);
		}

		if (packagecode == null) {
			request.setAttribute("result", "S." + routeid + ":unrecognized package@" + TimeUtils.getSysLogTimeString());
			break;
		}

		String sign = "api_key=" + api_key + "&prodid=" + prodid + "&submitorderid=" + taskid + "&phone=" + phone + "&num=" + packagecode;
		logger.info("xinhaobasend 加密前=" + sign);

		String check = MD5Util.getLowerMD5(sign);
		logger.info("xinhaobasend 加密后=" + check);

		HashMap<String, String> param = new HashMap<String, String>();
		param.put("cmd", cmd);
		param.put("loginname", loginname);
		param.put("prodid", prodid);
		param.put("submitorderid", taskid);
		param.put("phone", phone);
		param.put("num", packagecode);
		param.put("check", check);

		logger.info("xinhaoba 请求参数=" + param.toString());

		//在执行请求前先获取连接, 防止访问通道线程超量
		Cache.getConnection(routeid);
		try {
			ret = HttpAccess.postNameValuePairRequest(url, param, "utf-8", "xinhaobasend");
		} catch (Exception e) {
			e.printStackTrace();
			logger.info(e.getMessage());
		} finally {
			//在执行请求后记得释放连接
			Cache.releaseConnection(routeid);
		}

		//这里判断结果, 每个通道情况不同, 成功的保存 success 到 result 中并返回到 request.jsp(ret为返回的结果)
		if (ret != null && ret.trim().length() > 0) {
			logger.info("xinhaoba send ret = " + ret);
			try {
				JSONObject retjson = JSONObject.fromObject(ret);
				String retCode = retjson.getString("code");
				String message = retjson.getString("msg");
				if (retCode.equals("1")) {
					request.setAttribute("result", "success");
				} else {
					request.setAttribute("code", 1);
					request.setAttribute("result", "R." + routeid + ":" + retCode + ":" + message + "@" + TimeUtils.getSysLogTimeString());
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