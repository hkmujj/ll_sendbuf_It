<%@page import="org.dom4j.DocumentHelper"%>
<%@page import="org.dom4j.Element"%>
<%@page import="org.dom4j.Document"%>
<%@page import="org.apache.http.HttpEntity"%>
<%@page import="org.apache.http.util.EntityUtils"%>
<%@page import="java.io.IOException"%>
<%@page import="org.apache.http.client.ClientProtocolException"%>
<%@page import="org.apache.http.HttpResponse"%>
<%@page import="org.apache.http.client.ResponseHandler"%>
<%@page import="org.apache.http.client.config.RequestConfig"%>
<%@page import="java.net.URLEncoder"%>
<%@page import="org.apache.http.impl.client.HttpClients"%>
<%@page import="java.util.Map.Entry"%>
<%@page import="org.apache.http.impl.client.CloseableHttpClient"%>
<%@page import="org.apache.http.client.methods.HttpGet"%>
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
		String Account = routeparams.get("Account");
		if (Account == null) {
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, Account is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String apikey = routeparams.get("apikey");
		if (apikey == null) {
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, apikey is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String Range = routeparams.get("Range");
		if (Range == null) {
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, Range is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		//参数准备, 每个通道不同
		String packagecode = null;
		if (packageid.indexOf("yd.") > -1) {
			try {
				packageid = packageid.split("\\.")[1];
				packagecode = packageid.substring(0,packageid.length()-1);
				if(packageid.contains("G")){
				int pk = Integer.valueOf(packagecode);
				packagecode = pk*1024+"";
				}
			} catch (Exception e) {
				logger.warn(e.getMessage(), 0);
			}
		}
		if (packagecode == null) {
			request.setAttribute("result", "S." + routeid + ":unrecognized package@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String nonce_str = System.currentTimeMillis() + "";
		String signbeg = "account=" + Account + "&nonce_str=" + nonce_str + "&out_trade_no=" + taskid + "&phone=" + phone + "&range=" + Range + "&size=" + packagecode;
		logger.info("juliu send signbef = " + signbeg);
		String Sign = MD5Util.getLowerMD5(signbeg);

		Sign = MD5Util.getLowerMD5(Sign.substring(0, 16) + apikey + Sign.substring(16));
		logger.info("juliu send sign = " + Sign);
		Map<String, String> parm = new HashMap<String, String>();
		parm.put("account", Account);
		parm.put("phone", phone);
		parm.put("size", packagecode);
		parm.put("nonce_str", nonce_str);
		parm.put("range", Range);
		parm.put("out_trade_no", taskid);
		parm.put("sign", Sign);

		//在执行请求前先获取连接, 防止访问通道线程超量
		Cache.getConnection(routeid);
		try {
			ret = HttpAccess.postNameValuePairRequest(url, parm, "utf-8", "juliu");
		} catch (Exception e) {
			e.printStackTrace();
			logger.info(e.getMessage());
		} finally {
			//在执行请求后记得释放连接
			Cache.releaseConnection(routeid);
		}

		//这里判断结果, 每个通道情况不同, 成功的保存 success 到 result 中并返回到 request.jsp
		if (ret != null && ret.trim().length() > 0) {
			logger.info("juliu send ret = " + ret);
			try {
				JSONObject json = JSONObject.fromObject(ret);
				String code = json.getString("state");
				if (code != null && code.equals("1")) {
					request.setAttribute("result", "success");
				} else {
					String desc = "fail";
					if (json.get("msg") != null) {
						desc = json.getString("msg");
					}
					request.setAttribute("code", 1);
					request.setAttribute("result", "R." + routeid + ":" + code + desc + "@" + TimeUtils.getSysLogTimeString());
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