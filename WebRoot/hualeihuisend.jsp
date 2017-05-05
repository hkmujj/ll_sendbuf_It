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
		String channelId = routeparams.get("channelId");
		if (channelId == null) {
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, channelId is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String key = routeparams.get("key");
		if (key == null) {
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, key is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String privateChannel = taskid;//渠道私有字段（可以为空）
		String notifyUrl = "http://120.24.156.98:9302/ll_sendbuf/hualeihuireturn.jsp";

		//参数准备, 每个通道不同
		String packagecode = null;//对应文档的productbingdingId
		if (routeid.equals("1093") || routeid.equals("1167")) {
			if (packageid.equals("yd.10M")) {
				packagecode = "1";
			} else if (packageid.equals("yd.30M")) {
				packagecode = "2";
			} else if (packageid.equals("yd.70M")) {
				packagecode = "3";
			} else if (packageid.equals("yd.150M")) {
				packagecode = "4";
			} else if (packageid.equals("yd.500M")) {
				packagecode = "5";
			} else if (packageid.equals("yd.1G")) {
				packagecode = "6";
			} else if (packageid.equals("yd.2G")) {
				packagecode = "7";
			} else if (packageid.equals("yd.3G")) {
				packagecode = "8";
			} else if (packageid.equals("yd.4G")) {
				packagecode = "9";
			} else if (packageid.equals("yd.6G")) {
				packagecode = "10";
			} else if (packageid.equals("yd.11G")) {
				packagecode = "11";
			}
		} else if (routeid.equals("2032")) {
			if (packageid.equals("lt.20M")) {
				packagecode = "12";
			} else if (packageid.equals("lt.50M")) {
				packagecode = "13";
			} else if (packageid.equals("lt.100M")) {
				packagecode = "14";
			} else if (packageid.equals("lt.200M")) {
				packagecode = "15";
			} else if (packageid.equals("lt.500M")) {
				packagecode = "16";
			} else if (packageid.equals("lt.30M")) {
				packagecode = "34";
			} else if (packageid.equals("lt.300M")) {
				packagecode = "35";
			} else if (packageid.equals("lt.1G")) {
				packagecode = "32";
			}
		} else if (routeid.equals("3150")) {
			if (packageid.equals("dx.5M")) {
				packagecode = "17";
			} else if (packageid.equals("dx.10M")) {
				packagecode = "18";
			} else if (packageid.equals("dx.30M")) {
				packagecode = "19";
			} else if (packageid.equals("dx.50M")) {
				packagecode = "20";
			} else if (packageid.equals("dx.100M")) {
				packagecode = "21";
			} else if (packageid.equals("dx.200M")) {
				packagecode = "22";
			} else if (packageid.equals("dx.500M")) {
				packagecode = "23";
			} else if (packageid.equals("dx.1G")) {
				packagecode = "24";
			}
		}else if (routeid.equals("1197")) {
			if (packageid.equals("yd.200M")) {
				packagecode = "31";
			}
		}

		if (packagecode == null) {
			request.setAttribute("result", "S." + routeid + ":unrecognized package@" + TimeUtils.getSysLogTimeString());
			break;
		}

		String sign = phone + channelId + packagecode + privateChannel + key;
		sign = MD5Util.getLowerMD5(sign);
		logger.info("hualeihuisend sign = " + sign);

		HashMap<String, String> param = new HashMap<String, String>();
		param.put("channelId", channelId);
		param.put("productbingdingId", packagecode);
		param.put("phone", phone);
		param.put("privateChannel", privateChannel);
		param.put("notifyUrl", notifyUrl);
		param.put("sign", sign);

		logger.info("hualeihuisend" + param);

		//在执行请求前先获取连接, 防止访问通道线程超量
		Cache.getConnection(routeid);
		try {
			//ret = HttpAccess.postNameValuePairRequest(url, param,"application/x-www-form-urlencoded", "utf-8", "gdshangtong");
			//ret = HttpAccess.postJsonRequest(url, json.toString(), "utf-8", "weikesend");
			ret = HttpAccess.getNameValuePairRequest(url, param, "utf-8", "hualeihuisend");
		} catch (Exception e) {
			e.printStackTrace();
			logger.info(e.getMessage());
		} finally {
			//在执行请求后记得释放连接
			Cache.releaseConnection(routeid);
		}

		//这里判断结果, 每个通道情况不同, 成功的保存 success 到 result 中并返回到 request.jsp(ret为返回的结果)
		if (ret != null && ret.trim().length() > 0) {
			logger.info("hualeihui send ret = " + ret);

			try {
				JSONObject retjson = JSONObject.fromObject(ret);
				String retCode = retjson.getString("code"); //":"0000" 下单/订购成功

				if (retCode.equals("0")) {
					request.setAttribute("result", "success");
				} else {
					request.setAttribute("code", retCode);
					String message = retjson.getString("msg");
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