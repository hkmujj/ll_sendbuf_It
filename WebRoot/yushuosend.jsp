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
	language="java" pageEncoding="UTF-8"%><%!public static String getSha1(String str) {
		if (str == null || str.length() == 0) {
			return null;
		}
		char hexDigits[] = { '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'a', 'b', 'c', 'd', 'e', 'f' };
		try {
			MessageDigest mdTemp = MessageDigest.getInstance("SHA1");
			mdTemp.update(str.getBytes("UTF-8"));

			byte[] md = mdTemp.digest();
			int j = md.length;
			char buf[] = new char[j * 2];
			int k = 0;
			for (int i = 0; i < j; i++) {
				byte byte0 = md[i];
				buf[k++] = hexDigits[byte0 >>> 4 & 0xf];
				buf[k++] = hexDigits[byte0 & 0xf];
			}
			return new String(buf);
		} catch (Exception e) {
			// TODO: handle exception
			return null;
		}
	}%>
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
		String userName = routeparams.get("userName");
		if (userName == null) {
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, userName is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String key = routeparams.get("key");
		if (key == null) {
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, key is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String range = routeparams.get("range");
		if (range == null) {
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, range is null@" + TimeUtils.getSysLogTimeString());
			break;
		}

		//参数准备, 每个通道不同
		String packagecode = null;
		String packagetype = null;
		if (packageid.indexOf("yd.") > -1) {
			try {
				String[] dts = packageid.split("\\.");
				packagetype = dts[0].toUpperCase();
				packageid = dts[1];
				String pkstr = packageid.substring(0, packageid.length() - 1);
				int pk = Integer.parseInt(pkstr);
				if (packageid.indexOf('G') >= 0) {
					pk *= 1024;
				}
				packagecode = "" + String.valueOf(pk);
			} catch (Exception e) {
				logger.warn(e.getMessage(), 0);
			}
		} else if (packageid.indexOf("lt.") > -1) {
			try {
				String[] dts = packageid.split("\\.");
				packagetype = dts[0].toUpperCase();
				packageid = dts[1];
				String pkstr = packageid.substring(0, packageid.length() - 1);
				int pk = Integer.parseInt(pkstr);
				if (packageid.indexOf('G') >= 0) {
					pk *= 1024;
				}
				packagecode = "" + String.valueOf(pk);
			} catch (Exception e) {
				logger.warn(e.getMessage(), 0);
			}
		} else if (packageid.indexOf("dx.") > -1) {
			try {
				String[] dts = packageid.split("\\.");
				packagetype = dts[0].toUpperCase();
				packageid = dts[1];
				String pkstr = packageid.substring(0, packageid.length() - 1);
				int pk = Integer.parseInt(pkstr);
				if (packageid.indexOf('G') >= 0) {
					pk *= 1024;
				}
				packagecode = "" + String.valueOf(pk);
			} catch (Exception e) {
				logger.warn(e.getMessage(), 0);
			}
		}
		if (packagecode == null) {
			request.setAttribute("result", "S." + routeid + ":unrecognized package@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String timeStamp = System.currentTimeMillis() / 1000 + "";
		String signbef = "userName" + userName + "mobile" + phone + "orderMeal" + packagecode + "timeStamp" + timeStamp + "key" + key;
		String sign = getSha1(signbef);
		JSONObject json = new JSONObject();
		json.put("userName", userName);
		json.put("mobile", phone);
		json.put("orderMeal", packagecode);
		json.put("orderTime", "1");
		json.put("msgId", taskid);
		json.put("range", range);
		json.put("sign", sign);
		json.put("timeStamp", timeStamp);
		logger.info("yushuo send json = " + json.toString());

		//在执行请求前先获取连接, 防止访问通道线程超量
		Cache.getConnection(routeid);
		try {
			ret = HttpAccess.postJsonRequest(url, json.toString(), "utf-8", "yushuo");
		} catch (Exception e) {
			e.printStackTrace();
			logger.info(e.getMessage());
		} finally {
			//在执行请求后记得释放连接
			Cache.releaseConnection(routeid);
		}

		//这里判断结果, 每个通道情况不同, 成功的保存 success 到 result 中并返回到 request.jsp
		if (ret != null && ret.trim().length() > 0) {
			logger.info("yushuo send ret = " + ret);
			try {
				JSONObject retjson = JSONObject.fromObject(ret);
				String code = retjson.getString("code");
				if (code != null && code.equals("0000")) {
					request.setAttribute("result", "success");
				} else {
					request.setAttribute("code", 1);
					request.setAttribute("result", "R." + routeid + ":" + code + retjson.getString("msg") + "@" + TimeUtils.getSysLogTimeString());
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