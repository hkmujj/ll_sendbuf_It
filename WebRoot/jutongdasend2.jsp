<%@page import="http.HttpAccess"%>
<%@page import="java.util.HashMap"%>
<%@page
	import="net.sf.json.JSONObject,
				java.util.Map,
				util.TimeUtils,
				cache.Cache,
				org.apache.http.impl.client.HttpClients,
				org.apache.http.impl.client.CloseableHttpClient,
				java.net.URLDecoder,
				org.apache.logging.log4j.LogManager,
				java.io.BufferedReader,
				java.io.IOException,
				java.io.InputStream,
				java.io.InputStreamReader,
				java.io.UnsupportedEncodingException,
				java.nio.charset.Charset,
				java.util.ArrayList,
				java.util.List,
				org.apache.http.client.methods.HttpPost,
				org.apache.http.HttpResponse,
				org.apache.http.NameValuePair,
				org.apache.http.client.HttpClient,
				org.apache.http.client.entity.UrlEncodedFormEntity,
				org.apache.http.client.methods.HttpPost,
				org.apache.http.message.BasicNameValuePair,
				org.apache.http.protocol.HTTP,
				util.MD5Util,
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
			request.setAttribute("result", "S." + routeid + ":wrong routeparams@" + TimeUtils.getSysLogTimeString());
			break;
		}

		String token = routeparams.get("token");
		if (token == null) {
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, token is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String url = routeparams.get("url");
		if (url == null) {
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, url is null@" + TimeUtils.getSysLogTimeString());
			break;
		}

		//参数准备, 每个通道不同
		String packagecode = null;
		try {
			if (packageid.indexOf("lt") >= 0) {
				if (packageid.equals("lt.20M")) {
					packagecode = "200001";
				} else if (packageid.equals("lt.30M")) {
					packagecode = "200002";
				} else if (packageid.equals("lt.50M")) {
					packagecode = "200003";
				} else if (packageid.equals("lt.100M")) {
					packagecode = "200004";
				} else if (packageid.equals("lt.200M")) {
					packagecode = "200005";
				} else if (packageid.equals("lt.300M")) {
					packagecode = "200006";
				} else if (packageid.equals("lt.500M")) {
					packagecode = "200007";
				} else if (packageid.equals("lt.1G")) {
					packagecode = "200008";
				}
			} else if (packageid.indexOf("dx") >= 0) {
				//电信
				if (packageid.equals("dx.5M")) {
					packagecode = "300001";
				} else if (packageid.equals("dx.10M")) {
					packagecode = "300002";
				} else if (packageid.equals("dx.30M")) {
					packagecode = "300003";
				} else if (packageid.equals("dx.50M")) {
					packagecode = "300004";
				} else if (packageid.equals("dx.100M")) {
					packagecode = "300005";
				} else if (packageid.equals("dx.200M")) {
					packagecode = "300006";
				} else if (packageid.equals("dx.500M")) {
					packagecode = "300008";
				} else if (packageid.equals("dx.1G")) {
					packagecode = "300009";
				}

			} else {
				//移动
				if (packageid.equals("yd.10M")) {
					packagecode = "100001";
				} else if (packageid.equals("yd.30M")) {
					packagecode = "100002";
				} else if (packageid.equals("yd.70M")) {
					packagecode = "100003";
				} else if (packageid.equals("yd.150M")) {
					packagecode = "100005";
				} else if (packageid.equals("yd.500M")) {
					packagecode = "100007";
				} else if (packageid.equals("yd.1G")) {
					packagecode = "100008";
				} else if (packageid.equals("yd.2G")) {
					packagecode = "100009";
				} else if (packageid.equals("yd.3G")) {
					packagecode = "100010";
				} else if (packageid.equals("yd.4G")) {
					packagecode = "100011";
				} else if (packageid.equals("yd.6G")) {
					packagecode = "100012";
				} else if (packageid.equals("yd.11G")) {
					packagecode = "100013";
				}
			}
		} catch (Exception e) {
			logger.warn(e.getMessage(), 0);
		}

		if (packagecode == null) {
			request.setAttribute("result", "S." + routeid + ":unrecognized package@" + TimeUtils.getSysLogTimeString());
			break;
		}

		String callbackUrl = "http://120.24.156.98:9302/ll_sendbuf/jutongdareturn2.jsp";

		String sign = MD5Util.getLowerMD5(token + phone + taskid + packagecode + callbackUrl);

		String params = "?" + "token=" + token + "&mobile=" + phone + "&customId=" + taskid + "&sign=" + sign + "&code=" + packagecode + "&callbackUrl=" + callbackUrl;

		url = url + params;

		//在执行请求前先获取连接, 防止访问通道线程超量
		Cache.getConnection(routeid);
		try {
			//ret = HttpAccess.postNameValuePairRequest(url, params, "utf-8", "mysend");
			ret = HttpAccess.postNameValuePairRequest(url, new HashMap<String, String>(), "utf-8", "jutongda");
		} catch (Exception e) {
			e.printStackTrace();
			logger.info(e.getMessage());
		} finally {
			//在执行请求后记得释放连接
			Cache.releaseConnection(routeid);
		}

		//这里判断结果, 每个通道情况不同, 成功的保存 success 到 result 中并返回到 request.jsp
		if (ret != null && ret.trim().length() > 0) {
			logger.info("jutongda2 send ret = " + ret);
			try {
				JSONObject retjson = JSONObject.fromObject(ret);
				String retCode = retjson.getString("statusCode"); //":"MOB00001"
				if (retCode.equals("1000")) {
					request.setAttribute("result", "success");
				} else {
					request.setAttribute("code", 1);
					String message = "充值提交失败";
					if (retjson.get("statusMsg") != null) {
						message = retjson.getString("statusMsg");
					}
					request.setAttribute("result", "R." + routeid + ":" + message + "@" + TimeUtils.getSysLogTimeString());
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