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
<%!public static String shaEncrypt(String inputStr) {
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

	/**
	 * SHA加密字节
	 *
	 * @param data
	 * @return
	 * @throws Exception
	 */
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
		String appSecret = routeparams.get("appSecret");
		if (appSecret == null) {
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, appSecret is null@" + TimeUtils.getSysLogTimeString());
			break;
		}

		//参数准备, 每个通道不同
		String packagecode = null;
		if (routeid.equals("1199")) {
			if (packageid.equals("yd.200M")) {
				packagecode = "19004";
			}
		} else if (routeid.equals("1214")) {
			//陕西移动
			if (packageid.equals("yd.10M")) {
				packagecode = "12001.61";
			} else if (packageid.equals("yd.30M")) {
				packagecode = "12002.61";
			} else if (packageid.equals("yd.70M")) {
				packagecode = "12003.61";
			} else if (packageid.equals("yd.150M")) {
				packagecode = "12004.61";
			} else if (packageid.equals("yd.500M")) {
				packagecode = "12005.61";
			} else if (packageid.equals("yd.1G")) {
				packagecode = "12006.61";
			} else if (packageid.equals("yd.2G")) {
				packagecode = "12007.61";
			} else if (packageid.equals("yd.3G")) {
				packagecode = "12008.61";
			} else if (packageid.equals("yd.4G")) {
				packagecode = "12009.61";
			} else if (packageid.equals("yd.6G")) {
				packagecode = "12010.61";
			} else if (packageid.equals("yd.11G")) {
				packagecode = "12011.61";
			}

		} else if (routeid.equals("1215")) {
			//广东移动
			if (packageid.equals("yd.10M")) {
				packagecode = "11001";
			} else if (packageid.equals("yd.30M")) {
				packagecode = "11002";
			} else if (packageid.equals("yd.70M")) {
				packagecode = "11003";
			} else if (packageid.equals("yd.150M")) {
				packagecode = "11004";
			} else if (packageid.equals("yd.500M")) {
				packagecode = "11005";
			} else if (packageid.equals("yd.1G")) {
				packagecode = "11006";
			} else if (packageid.equals("yd.2G")) {
				packagecode = "11007";
			} else if (packageid.equals("yd.3G")) {
				packagecode = "11008";
			} else if (packageid.equals("yd.4G")) {
				packagecode = "11009";
			} else if (packageid.equals("yd.6G")) {
				packagecode = "11010";
			} else if (packageid.equals("yd.11G")) {
				packagecode = "11011";
			}

		}

		if (packagecode == null) {
			request.setAttribute("result", "S." + routeid + ":unrecognized package@" + TimeUtils.getSysLogTimeString());
			break;
		}
		JSONArray rechargeList = new JSONArray();
		JSONObject obj = new JSONObject();
		obj.put("clecs", "1");
		obj.put("mobile", phone);
		obj.put("flowCode", packagecode);
		obj.put("orderNum11", taskid);
		rechargeList.add(obj);
		String nonceStr = "mcwx";//随机字符串
		String timestamp = "" + System.currentTimeMillis();//14521545
		String signstr = "appSecret=" + appSecret + "&appid=" + appid + "&nonceStr=" + nonceStr + "&rechargeList=" + "Array" + "&timestamp=" + timestamp;
		String sign = shaEncrypt(signstr);
		JSONObject json = new JSONObject();
		json.put("nonceStr", nonceStr);
		json.put("timestamp", timestamp);
		json.put("rechargeList", rechargeList);
		logger.info("haiyi request=" + json.toString());
		Map<String, String> maps = new HashMap<String, String>();
		maps.put("appid", appid);
		maps.put("sign", sign);

		//在执行请求前先获取连接, 防止访问通道线程超量
		Cache.getConnection(routeid);
		try {
			//ret = HttpAccess.postNameValuePairRequest(url, params, "utf-8", "mysend");
			//ret = HttpAccess.postJsonRequest(url, json.toString(), "utf-8", "weikesend");
			ret = HttpAccess.postJsonRequest(url, json.toString(), "utf-8", maps, "haiyi");

		} catch (Exception e) {
			e.printStackTrace();
			logger.info(e.getMessage());
		} finally {
			//在执行请求后记得释放连接
			Cache.releaseConnection(routeid);
		}

		//这里判断结果, 每个通道情况不同, 成功的保存 success 到 result 中并返回到 request.jsp
		if (ret != null && ret.trim().length() > 0) {
			logger.info("haiyi send ret = " + ret);
			try {
				JSONObject retjson = JSONObject.fromObject(ret);
				JSONObject errorInfo = retjson.getJSONObject("errorInfo"); //":"MOB00001"
				String resultinfo = errorInfo.getString("errorCode");
				if (resultinfo.equals("MX_OK")) {
					JSONObject rechargejson = retjson.getJSONArray("rechargeList").getJSONObject(0);
					if (rechargejson.get("tradeStatus") != null) {
						String resultCode = rechargejson.getString("tradeStatus");
						if (resultCode.equals("2")) {
							String rpid = rechargejson.getString("orderNum");
							request.setAttribute("reportid", rpid);
							request.setAttribute("result", "success");
							//request.setAttribute("reportid",taskid);
						} else {
							request.setAttribute("code", resultCode);
							String resultMsg = rechargejson.getJSONObject("errorInfo").getString("errorCode");
							request.setAttribute("result", "R." + routeid + ":" + resultCode + ":" + resultMsg + "@" + TimeUtils.getSysLogTimeString());
						}
					} else {
						request.setAttribute("code", "1");
						String resultMsg = rechargejson.getJSONObject("errorInfo").getString("errorDescription");
						request.setAttribute("result", "R." + routeid + ":" + resultMsg + "@" + TimeUtils.getSysLogTimeString());
					}
				} else {
					request.setAttribute("code", resultinfo.substring(2));
					request.setAttribute("result", "R." + routeid + ":" + resultinfo + "@" + TimeUtils.getSysLogTimeString());

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