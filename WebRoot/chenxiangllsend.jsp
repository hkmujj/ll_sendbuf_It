<%@page import="org.apache.http.util.EntityUtils"%>
<%@page import="org.apache.http.HttpResponse"%>
<%@page import="org.apache.http.entity.StringEntity"%>
<%@page import="org.apache.http.client.methods.HttpPost"%>
<%@page import="org.apache.http.impl.client.DefaultHttpClient"%>
<%@page import="util.SHA1"%>
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
	language="java" pageEncoding="UTF-8"%><%!boolean logflag = true;
	Logger logger = LogManager.getLogger();

	public String postValue(String url, String obj) {
		DefaultHttpClient httpClient = new DefaultHttpClient();
		HttpPost method = new HttpPost(url);
		try {
			if (null != obj) {
				//解决中文乱码问题
				StringEntity entity = new StringEntity(obj, "utf-8");
				entity.setContentEncoding("utf-8");
				entity.setContentType("application/json");
				method.setEntity(entity);
			}
			HttpResponse result = httpClient.execute(method);
			/**请求发送成功，并得到响应**/
			if (result.getStatusLine().getStatusCode() == 200) {
				String str = "";
				try {
					/**读取服务器返回过来的json字符串数据**/
					str = EntityUtils.toString(result.getEntity(), "utf-8");
					/**把json字符串转换成json对象**/
					logger.info("chenxiang str = " + str);
				} catch (Exception e) {
					logger.error("chenxiang post : " + e.getMessage(), e);
					return "";
				}
				return str;
			} else {
				logger.error("chenxiang post retcode : " + result.getStatusLine().getStatusCode());
			}
			return "";
		} catch (Exception e) {
			logger.error("chenxiang post1 : " + e.getMessage(), e);
			return "";
		}
	}%>
<%
	out.clearBuffer();
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

		String sendurl = routeparams.get("sendurl");
		if (sendurl == null) {
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, sendurl is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String appkey = routeparams.get("appkey");
		if (appkey == null) {
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, appkey is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String securityKey = routeparams.get("securityKey");
		if (securityKey == null) {
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, securityKey is null@" + TimeUtils.getSysLogTimeString());
			break;
		}

		//参数准备, 每个通道不同
		String packagecode = null;
		try {
			if (routeid.equals("2044")) {
				//广东联通
				if (packageid.equals("lt.10M")) {
					packagecode = "LTGDY200010";
				} else if (packageid.equals("lt.30M")) {
					packagecode = "LTGDY200030";
				} else if (packageid.equals("lt.50M")) {
					packagecode = "LTGDY200050";
				} else if (packageid.equals("lt.100M")) {
					packagecode = "LTGDY200100";
				} else if (packageid.equals("lt.200M")) {
					packagecode = "LTGDY200200";
				} else if (packageid.equals("lt.300M")) {
					packagecode = "LTGDY200300";
				} else if (packageid.equals("lt.500M")) {
					packagecode = "LTGDY200500";
				} else if (packageid.equals("lt.1G")) {
					packagecode = "LTGDY201024";
				}
			} else if (routeid.equals("2045")) {
				//山东联通
				if (packageid.equals("lt.20M")) {
					packagecode = "LTSDY400020";
				} else if (packageid.equals("lt.30M")) {
					packagecode = "LTSDY400030";
				} else if (packageid.equals("lt.50M")) {
					packagecode = "LTSDY400050";
				} else if (packageid.equals("lt.100M")) {
					packagecode = "LTSDY400100";
				} else if (packageid.equals("lt.200M")) {
					packagecode = "LTSDY400200";
				} else if (packageid.equals("lt.300M")) {
					packagecode = "LTSDY400300";
				} else if (packageid.equals("lt.500M")) {
					packagecode = "LTSDY400500";
				} else if (packageid.equals("lt.1G")) {
					packagecode = "LTSDY401024";
				}
			} else if (routeid.equals("2222")) {
				//广东联通（日包）
				if (packageid.equals("lt.200M")) {
					packagecode = "LTGDD200M";
				}
			} else if (routeid.equals("2288")) {
				//广东联通（日包）
				if (packageid.equals("lt.1G")) {
					packagecode = "LTGDD1G";
				}
			} else if (routeid.equals("2289")) {
				//广东联通（日包）
				if (packageid.equals("lt.3G")) {
					packagecode = "LTGDD3G";
				}
			} else if (routeid.equals("3167")) {
				//全国电信
				if (packageid.equals("dx.5M")) {
					packagecode = "DXALY5M";
				} else if (packageid.equals("dx.10M")) {
					packagecode = "DXALY10M";
				} else if (packageid.equals("dx.30M")) {
					packagecode = "DXALY30M";
				} else if (packageid.equals("dx.50M")) {
					packagecode = "DXALY50M";
				} else if (packageid.equals("dx.100M")) {
					packagecode = "DXALY100M";
				} else if (packageid.equals("dx.200M")) {
					packagecode = "DXALY200M";
				} else if (packageid.equals("dx.500M")) {
					packagecode = "DXALY500M";
				} else if (packageid.equals("dx.1G")) {
					packagecode = "DXALY1024M";
				}
			} else if (routeid.equals("3276")) {
				//西藏电信
				if (packageid.equals("dx.5M")) {
					packagecode = "DXXZY100005";
				} else if (packageid.equals("dx.10M")) {
					packagecode = "DXXZY100010";
				} else if (packageid.equals("dx.30M")) {
					packagecode = "DXXZY100030";
				} else if (packageid.equals("dx.50M")) {
					packagecode = "DXXZY100050";
				} else if (packageid.equals("dx.100M")) {
					packagecode = "DXXZY100100";
				} else if (packageid.equals("dx.200M")) {
					packagecode = "DXXZY100200";
				} else if (packageid.equals("dx.500M")) {
					packagecode = "DXXZY100500";
				} else if (packageid.equals("dx.1G")) {
					packagecode = "DXXZY101024";
				}
			} else if (routeid.equals("1189")) {
				//福建移动
				if (packageid.equals("yd.10M")) {
					packagecode = "YDFJY10M";
				} else if (packageid.equals("yd.30M")) {
					packagecode = "YDFJY30M";
				} else if (packageid.equals("yd.70M")) {
					packagecode = "YDFJY70M";
				} else if (packageid.equals("yd.150M")) {
					packagecode = "YDFJY150M";
				} else if (packageid.equals("yd.500M")) {
					packagecode = "YDFJY500M";
				} else if (packageid.equals("yd.1G")) {
					packagecode = "YDFJY1G";
				} else if (packageid.equals("yd.2G")) {
					packagecode = "YDFJY2G";
				} else if (packageid.equals("yd.3G")) {
					packagecode = "YDFJY3G";
				} else if (packageid.equals("yd.4G")) {
					packagecode = "YDFJY4G";
				} else if (packageid.equals("yd.6G")) {
					packagecode = "YDFJY6G";
				} else if (packageid.equals("yd.11G")) {
					packagecode = "YDFJY11G";
				}
			}
		} catch (Exception e) {
			logger.warn(e.getMessage(), e);
		}

		if (packagecode == null) {
			request.setAttribute("result", "S." + routeid + ":unrecognized package@" + TimeUtils.getSysLogTimeString());
			break;
		}

		String timeStamp = TimeUtils.getTimeStamp();
		String sign = "appkey" + appkey + "cstmOrderNo" + taskid + "phoneNo" + phone + "productId" + packagecode + "timeStamp" + timeStamp + securityKey;
		String sig = SHA1.sha1Encode(sign);
		sig = sig.toLowerCase();

		JSONObject obj = new JSONObject();
		obj.put("sig", sig);
		obj.put("appkey", appkey);
		obj.put("timeStamp", timeStamp);
		obj.put("phoneNo", phone);
		obj.put("productId", packagecode);
		obj.put("cstmOrderNo", taskid);
		logger.info("chenxiangsend obj = " + obj);

		//在执行请求前先获取连接, 防止访问通道线程超量
		//Cache.getConnection(routeid);
		try {
			ret = postValue(sendurl, obj.toString());
			//ret = HttpAccess.postJsonRequest(sendurl, obj.toString(), "utf-8", "chenxiangsend");
			//ret = HttpAccess.postJsonRequest(url, json.toString(), "utf-8", "weikesend");
			//ret = HttpAccess.getNameValuePairRequest(url, param, "utf-8", "mark");
		} catch (Exception e) {
			e.printStackTrace();
			logger.info(e.getMessage());
		} finally {
			//在执行请求后记得释放连接
			Cache.releaseConnection(routeid);
		}

		//这里判断结果, 每个通道情况不同, 成功的保存 success 到 result 中并返回到 request.jsp(ret为返回的结果)
		if (ret != null && ret.trim().length() > 0) {
			logger.info("chenxiang send ret = " + ret);

			try {
				JSONObject retjson = JSONObject.fromObject(ret);
				String retCode = retjson.getString("code"); //":"0000" 下单/订购成功

				JSONObject odobj = retjson.getJSONObject("data");
				String reportid = odobj.getString("cstmOrderNo");

				if (retCode.equals("0000") && odobj != null) {
					request.setAttribute("result", "success");
					request.setAttribute("reportid", reportid);
				} else {
					request.setAttribute("code", 1);
					//msg为乱码，错误信息为code编号
					String message = retCode;
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