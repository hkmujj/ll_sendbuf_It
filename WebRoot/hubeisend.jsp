<%@page import="java.security.MessageDigest"%>
<%@page import="sun.misc.BASE64Encoder"%>
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
<%!public static String encryptBASE64(byte[] key) throws Exception {

		return (new BASE64Encoder()).encodeBuffer(key);
	}

	public static byte[] encryptSHA(byte[] data) throws Exception {
		MessageDigest sha = MessageDigest.getInstance("SHA");
		sha.update(data);
		return sha.digest();
	}

	public static String shaEncrypt(String inputStr) {
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
		String backUrl = routeparams.get("backUrl");
		if (backUrl == null) {
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, backUrl is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String appSecret = routeparams.get("appSecret");
		if (appSecret == null) {
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, appSecret is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String action = routeparams.get("action");
		if (action == null) {
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, action is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String appKey = routeparams.get("appKey");
		if (appKey == null) {
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, appKey is null@" + TimeUtils.getSysLogTimeString());
			break;
		}

		//参数准备, 每个通道不同
		String packagecode = null;
		if (routeid.equals("1206")) {
			if (packageid.equals("yd.50M")) {
				packagecode = "10022";
			}
		} else if (routeid.equals("1316")) {
		}

		if (packagecode == null) {
			request.setAttribute("result", "S." + routeid + ":unrecognized package@" + TimeUtils.getSysLogTimeString());
			break;
		}
		try {
			backUrl = encryptBASE64(backUrl.getBytes());
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
			logger.info(e.getMessage());
		}
		String timeStamp = TimeUtils.getTimeStamp();
		Map<String, String> parm = new HashMap<String, String>();
		String signbef = appSecret + "action" + action + "appKey" + appKey + "backUrl" + backUrl + "phoneNo" + phone + "pkgNo" + packagecode + "timeStamp" + timeStamp + "transNo" + taskid + appSecret;
		System.out.println("signbef =" + signbef);
		String sign = shaEncrypt(signbef).toUpperCase();
		System.out.println(sign);
		parm.put("action", action);
		parm.put("appKey", appKey);
		parm.put("pkgNo", packagecode);
		parm.put("phoneNo", phone);
		parm.put("backUrl", backUrl);
		parm.put("transNo", taskid);
		parm.put("timeStamp", timeStamp);
		parm.put("sign", sign);
		//在执行请求前先获取连接, 防止访问通道线程超量
		Cache.getConnection(routeid);
		try {
			ret = HttpAccess.getNameValuePairRequest(url, parm, "utf-8", "hubei");
		} catch (Exception e) {
			e.printStackTrace();
			logger.info(e.getMessage());
		} finally {
			//在执行请求后记得释放连接
			Cache.releaseConnection(routeid);
		}

		//这里判断结果, 每个通道情况不同, 成功的保存 success 到 result 中并返回到 request.jsp
		if (ret != null && ret.trim().length() > 0) {
			logger.info("hubei send ret = " + ret + ", mobile = " + phone);
			try {
				JSONObject retjson = JSONObject.fromObject(ret);
				String code = retjson.getString("respCode");
				if (code.equals("0000")) {
					request.setAttribute("result", "success");
				} else {
					request.setAttribute("code", code);
				//	request.setAttribute("result", "R." + routeid + ":" + message + "@" + TimeUtils.getSysLogTimeString());
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
	//Log.logout("String = " + str, 0);
	//out.print((new MsgBufQuerier()).jsonRpc(str));
	//out.print("hello");
%>