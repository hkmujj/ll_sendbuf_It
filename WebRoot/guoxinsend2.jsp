<%@page import="com.alibaba.fastjson.util.Base64"%>
<%@page import="org.dom4j.Element"%>
<%@page import="org.dom4j.DocumentHelper"%>
<%@page import="org.dom4j.Document"%>
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
	language="java" pageEncoding="UTF-8"%><%!public static String shaEncrypt(String inputStr) {
		byte[] inputData = inputStr.getBytes();
		String returnString = "";
		try {
			inputData = encryptSHA(inputData);
			for (int i = 0; i < inputData.length; i++) {
				returnString += byteToHexString(inputData[i]);
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		return returnString;
	}

	public static String dataDecrypt(Map<String, Object> serviceParams) {
		StringBuilder sb = new StringBuilder();
		Object[] keys = serviceParams.keySet().toArray();
		Arrays.sort(keys);
		for (Object key : keys) {
			sb.append(key).append(serviceParams.get(key));
		}
		return sb.toString();
	}

	public static byte[] encryptSHA(byte[] data) throws Exception {
		MessageDigest sha = MessageDigest.getInstance("SHA");
		sha.update(data);
		return sha.digest();
	}

	private static String byteToHexString(byte ib) {
		char[] Digit = { '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'a', 'b', 'c', 'd', 'e', 'f' };
		char[] ob = new char[2];
		ob[0] = Digit[(ib >>> 4) & 0X0F];
		ob[1] = Digit[ib & 0X0F];

		String s = new String(ob);

		return s;
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
		String appkey = routeparams.get("appkey");
		if (appkey == null) {
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, appkey is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String method = routeparams.get("method");
		if (method == null) {
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, method is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String v = routeparams.get("v");
		if (v == null) {
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, v is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String region = routeparams.get("region");
		if (region == null) {
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, region is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String key = routeparams.get("key");
		if (key == null) {
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, key is null@" + TimeUtils.getSysLogTimeString());
			break;
		}

		//参数准备, 每个通道不同
		String packagecode = null;

		if (packageid.indexOf("lt.") > -1) {
			String packagetype = "LT";
			try {
				String[] dts = packageid.split("\\.");
				packagetype = dts[0].toUpperCase();
				packageid = dts[1];
				String pkstr = packageid.substring(0, packageid.length() - 1);
				int pk = Integer.parseInt(pkstr);
				if (packageid.indexOf('G') >= 0) {
					pk *= 1024;
				}
				packageid = "00000" + String.valueOf(pk);
				packageid = packageid.substring(packageid.length() - 6);

				packagecode = packagetype + packageid;

			} catch (Exception e) {
				logger.warn(e.getMessage(), 0);
			}
		}

		if (packagecode == null) {
			request.setAttribute("result", "S." + routeid + ":unrecognized package@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String callbackUrl = "http://120.24.156.98:9302/ll_sendbuf/guoxinreturn2.jsp";
		String strsig = "appkey" + appkey + "callbackUrl" + callbackUrl + "cstmOrderNo" + taskid + "method" + method + "phoneNo" + phone + "productId" + packagecode + "region" + region + "v" + v + key;
		String sig = shaEncrypt(strsig);
		JSONObject json = new JSONObject();
		json.put("appkey", appkey);
		json.put("callbackUrl", callbackUrl);
		json.put("cstmOrderNo", taskid);
		json.put("method", method);
		json.put("phoneNo", phone);
		json.put("productId", packagecode);
		json.put("region", region);
		json.put("v", v);
		json.put("sig", sig);

		logger.info("guoxinsend2 json=" + json.toString());
		//在执行请求前先获取连接, 防止访问通道线程超量
		Cache.getConnection(routeid);
		try {
			//ret = HttpAccess.postNameValuePairRequest(url, param,"application/x-www-form-urlencoded", "utf-8", "gdshangtong");
			//ret = HttpAccess.postJsonRequest(url, json.toString(), "utf-8", "weikesend");
			//ret = HttpAccess.getNameValuePairRequest(url, param, "utf-8", "mark");
			ret = HttpAccess.postJsonRequest(url, json.toString(), "utf-8", "guoxin2");
		} catch (Exception e) {
			e.printStackTrace();
			logger.info(e.getMessage());
		} finally {
			//在执行请求后记得释放连接
			Cache.releaseConnection(routeid);
		}

		//这里判断结果, 每个通道情况不同, 成功的保存 success 到 result 中并返回到 request.jsp(ret为返回的结果)
		if (ret != null && ret.trim().length() > 0) {
			logger.info("guoxin2send ret = " + ret);
			try {
				JSONObject retjson = JSONObject.fromObject(ret);
				String code = retjson.getString("code");
				if (code != null && code.equals("0")) {
					request.setAttribute("result", "success");
				} else {
					request.setAttribute("code", 1);
					String msg = "fail";
					if (retjson.get("msg") != null) {
						msg = retjson.getString("msg");
					}
					request.setAttribute("result", "R." + routeid + ":" + msg + "@" + TimeUtils.getSysLogTimeString());
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