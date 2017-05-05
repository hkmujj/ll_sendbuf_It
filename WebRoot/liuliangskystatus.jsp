<%@page import="java.security.MessageDigest"%>
<%@page
	import="java.text.SimpleDateFormat,
				util.SHA1,
				util.MD5Util,
				net.sf.json.JSONArray,
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

	while (true) {
		String ret = null;

		//获取公共参数
		String routeid = request.getAttribute("routeid").toString();

		Object idsobj = request.getAttribute("ids");
		if (idsobj == null) {
			request.setAttribute("result", "S." + routeid + ":ids are needed to get status@" + TimeUtils.getSysLogTimeString());
			break;
		}

		String ids = idsobj.toString();

		logger.info("ids = " + ids + ", routeid = " + routeid);

		//获取通道能数, 每个通道不同
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
		String account = routeparams.get("account");
		if (account == null) {
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, account is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String key = routeparams.get("key");
		if (key == null) {
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, key is null@" + TimeUtils.getSysLogTimeString());
			break;
		}

		//发送请求前先准备好参数
		String[] idarray = ids.split(",");
		JSONObject obj = new JSONObject();
		for (int i = 0; i < idarray.length; i++) {
			String signbef = "account=" + account;
			SimpleDateFormat df = new SimpleDateFormat("yyyy-MM-dd");
			String SendTime = df.format(new Date());
			String sign = MD5Util.getLowerMD5(signbef + "&key=" + key);
			String urla = url + "v=1.1&action=queryReport&" + signbef + "&sign=" + sign + "&TaskID=" + idarray[i] + "&SendTime=" + SendTime;
			//发送查询/获取状态前先获取连接, 防止访问线程超量
			Cache.getStatusConnection(routeid);
			try {
				ret = HttpAccess.postNameValuePairRequest(urla, new HashMap<String, String>(), "utf-8", "liuliangsky");
			} catch (Exception e) {
				e.printStackTrace();
				logger.info(e.getMessage());
			} finally {
				//发送查询/获取状态后释放连接
				Cache.releaseStatusConnection(routeid);
			}

			//这里判断结果, 每个通道情况不同, 成功的节点ID对应success, 失败的对应失败信息
			if (ret != null && ret.trim().length() > 0) {
				//request.setAttribute("result", "success");
				logger.info("liuliangsky status ret = " + ret);
				try {
					JSONObject robj = JSONObject.fromObject(ret);
					String retCode = robj.getString("Code");
					if (retCode.equals("0")) {
						JSONArray chargeerr = robj.getJSONArray("Reports");
						JSONObject chargeInfo = chargeerr.getJSONObject(0);
						String staus = chargeInfo.getString("Status");
						if (staus.equals("4")) {
							JSONObject rp = new JSONObject();
							rp.put("code", 0);
							rp.put("message", "success");
							rp.put("resp", ret);
							obj.put(idarray[i], rp);
						} else if (staus.equals("5")) {
							JSONObject rp = new JSONObject();
							rp.put("code", staus);
							String msg = "失败";
							if (chargeInfo.get("ReportCode") != null) {
								msg = chargeInfo.getString("ReportCode");
							}
							rp.put("message", msg);
							rp.put("resp", ret);
							obj.put(idarray[i], rp);
						} else {
							logger.info("liuliangsky status : [" + idarray[i] + "]充值中@" + TimeUtils.getSysLogTimeString());
						}
					} else {
						logger.info("liuliangsky status : [" + idarray[i] + "]状态码" + retCode + ":" + robj.getString("Message") + "@" + TimeUtils.getSysLogTimeString());

					}
				} catch (Exception e) {
					logger.warn(e.getMessage(), e);
					logger.info("liuliangsky status : " + e.getMessage() + ", ret = " + ret + "@" + TimeUtils.getSysLogTimeString());
				}
			} else {
				logger.info("liuliangsky status : " + "fail@" + TimeUtils.getSysLogTimeString());
			}
		}

		request.setAttribute("retjson", obj.toString());
		request.setAttribute("result", "success");

		break;
	}

	request.getRequestDispatcher("request.jsp").forward(request, response);
%>