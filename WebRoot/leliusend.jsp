<%@page import="javax.xml.bind.DatatypeConverter"%>
<%@page import="javax.crypto.spec.IvParameterSpec"%>
<%@page import="javax.crypto.spec.SecretKeySpec"%>
<%@page import="javax.crypto.Cipher"%>
<%@page import="java.security.MessageDigest"%>
<%@page import="net.sf.json.JSONArray"%>
<%@page
	import="util.MD5Util,
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
<%!public static String aesebcrypt(String input, String key, String vi) {
		try {
			Cipher cipher = Cipher.getInstance("AES/CBC/PKCS5Padding");

			cipher.init(Cipher.ENCRYPT_MODE, new SecretKeySpec(key.getBytes(), "AES"), new IvParameterSpec(vi.getBytes()));
			byte[] encrypted = cipher.doFinal(input.getBytes("utf-8"));
			return DatatypeConverter.printBase64Binary(encrypted);

		} catch (Exception e) {
			return null;
		}

	}%>
<%
	boolean logflag = true;
	Logger logger = LogManager.getLogger();
	out.clearBuffer();
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
		String partner_no = routeparams.get("partner_no");
		if (partner_no == null) {
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, partner_no is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String key = routeparams.get("key");
		if (key == null) {
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, key is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String iv = routeparams.get("iv");
		if (iv == null) {
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, iv is null@" + TimeUtils.getSysLogTimeString());
			break;
		}

		//参数准备, 每个通道不同
		String packagecode = null;
		if (routeid.equals("1237")) {
			//全国移动
			if (packageid.equals("yd.10M")) {
				packagecode = "EC100110";
			} else if (packageid.equals("yd.30M")) {
				packagecode = "EC100111";
			} else if (packageid.equals("yd.70M")) {
				packagecode = "EC100112";
			} else if (packageid.equals("yd.150M")) {
				packagecode = "EC100113";
			} else if (packageid.equals("yd.100M")) {
				packagecode = "EC100125";
			} else if (packageid.equals("yd.300M")) {
				packagecode = "EC100126";
			} else if (packageid.equals("yd.500M")) {
				packagecode = "EC100118";
			} else if (packageid.equals("yd.1G")) {
				packagecode = "EC100119";
			} else if (packageid.equals("yd.2G")) {
				packagecode = "EC100120";
			} else if (packageid.equals("yd.3G")) {
				packagecode = "EC100121";
			} else if (packageid.equals("yd.4G")) {
				packagecode = "EC2100122";
			} else if (packageid.equals("yd.6G")) {
				packagecode = "EC100123";
			} else if (packageid.equals("yd.11G")) {
				packagecode = "EC100124";
			}
		} else if (routeid.equals("1201")) {
			//广东移动
			if (packageid.equals("yd.10M")) {
				packagecode = "prod.10086000001992";
			} else if (packageid.equals("yd.30M")) {
				packagecode = "prod.10086000001993";
			} else if (packageid.equals("yd.70M")) {
				packagecode = "prod.10086000001994";
			} else if (packageid.equals("yd.150M")) {
				packagecode = "prod.10086000001995";
			}else if (packageid.equals("yd.500M")) {
				packagecode = "prod.10086000001996";
			} else if (packageid.equals("yd.1G")) {
				packagecode = "prod.10086000001997";
			} else if (packageid.equals("yd.2G")) {
				packagecode = "prod.10086000001998";
			} else if (packageid.equals("yd.3G")) {
				packagecode = "prod.10086000001999";
			} else if (packageid.equals("yd.4G")) {
				packagecode = "prod.10086000002000";
			} else if (packageid.equals("yd.6G")) {
				packagecode = "prod.10086000002001";
			} else if (packageid.equals("yd.11G")) {
				packagecode = "prod.10086000002002";
			}

		}
		if (packagecode == null) {
			request.setAttribute("result", "S." + routeid + ":unrecognized package@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String timestamp = "" + System.currentTimeMillis() / 1000;
		JSONObject obj = new JSONObject();
		obj.put("request_no", taskid);
		obj.put("contract_id", partner_no);
		obj.put("plat_offer_id", packagecode);
		obj.put("phone_id", phone);
		obj.put("order_id", taskid);
		obj.put("timestamp", timestamp);
		JSONObject json = new JSONObject();
		String code = aesebcrypt(obj.toString(), key, iv);
		json.put("partner_no", partner_no);
		json.put("code", code);

		//在执行请求前先获取连接, 防止访问通道线程超量
		Cache.getConnection(routeid);
		try {
			//ret = HttpAccess.postNameValuePairRequest(url, params, "utf-8", "mysend");
			//ret = HttpAccess.postJsonRequest(url, json.toString(), "utf-8", "weikesend");
			ret = HttpAccess.postJsonRequest(url, json.toString(), "utf-8", "leliu");

		} catch (Exception e) {
			e.printStackTrace();
			logger.info(e.getMessage());
		} finally {
			//在执行请求后记得释放连接
			Cache.releaseConnection(routeid);
		}

		//这里判断结果, 每个通道情况不同, 成功的保存 success 到 result 中并返回到 request.jsp
		if (ret != null && ret.trim().length() > 0) {
			logger.info("leliu send ret = " + ret + "[" + phone + "]");
			try {
				JSONObject retjson = JSONObject.fromObject(ret);
				String resultCode = retjson.getString("orderstatus");
				if (resultCode.equals("finish")) {
					request.setAttribute("result", "success");
					//request.setAttribute("reportid",taskid);
				} else {
					String result_code = retjson.getString("result_code");
					request.setAttribute("code", result_code);
					String resultMsg = retjson.getString("result_desc");
					request.setAttribute("result", "R." + routeid + ":" + resultCode + ":" + resultMsg + "@" + TimeUtils.getSysLogTimeString());
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