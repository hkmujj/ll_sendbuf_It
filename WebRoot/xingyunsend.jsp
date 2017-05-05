<%@page import="org.apache.http.HttpEntity"%>
<%@page import="org.apache.http.util.EntityUtils"%>
<%@page import="org.apache.http.client.ClientProtocolException"%>
<%@page import="org.apache.http.HttpResponse"%>
<%@page import="java.io.IOException"%>
<%@page import="org.apache.http.entity.StringEntity"%>
<%@page import="org.apache.http.client.ResponseHandler"%>
<%@page import="org.apache.http.client.config.RequestConfig"%>
<%@page import="org.apache.http.impl.client.HttpClients"%>
<%@page import="org.apache.http.impl.client.CloseableHttpClient"%>
<%@page import="org.apache.http.client.methods.HttpPost"%>
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

<%!boolean logflag = true;
	public static Logger logger = LogManager.getLogger();

	public static String postJsonRequest(String url, String jsondata, String encode, String mark) {
		String bacTxt = null;
		HttpPost httppost = null;
		CloseableHttpClient httpclient = HttpClients.createDefault();
		try {
			httppost = new HttpPost(url);

			RequestConfig requestConfig = RequestConfig.custom().setSocketTimeout(90000).setConnectTimeout(5000).build();
			httppost.setConfig(requestConfig);

			ResponseHandler<String> responseHandler = new MyResponseHandler(mark, "utf-8");

			StringEntity entity = new StringEntity(jsondata, encode);
			entity.setContentEncoding(encode);
			entity.setContentType("application/json");

			httppost.setEntity(entity);

			bacTxt = httpclient.execute(httppost, responseHandler);

		} catch (Exception e) {
			StringBuffer sb = new StringBuffer();
			sb.append('[');
			sb.append(mark);
			sb.append("] Exception : ");
			sb.append(e.getMessage());
			logger.warn(sb.toString(), e);
		} finally {
			try {
				httppost.releaseConnection();
				httpclient.close();
			} catch (IOException e) {
				StringBuffer sb = new StringBuffer();
				sb.append('[');
				sb.append(mark);
				sb.append("] close httplicent Exception : ");
				sb.append(e.getMessage());
				logger.warn(sb.toString(), e);
			}
		}

		StringBuffer sb = new StringBuffer();
		sb.append('[');
		sb.append(mark);
		sb.append("] response text = ");
		sb.append(bacTxt);

		logger.info(sb.toString());

		return bacTxt;
	}

	private static class MyResponseHandler implements ResponseHandler<String> {
		private String mark = null;
		private String enc = null;

		public MyResponseHandler(String str, String encstr) {
			mark = str;
			enc = encstr;
		}

		@Override
		public String handleResponse(HttpResponse response) throws ClientProtocolException, IOException {
			int status = response.getStatusLine().getStatusCode();
			if (status >= 200 && status < 300) {
				HttpEntity entity = response.getEntity();
				return entity != null ? EntityUtils.toString(entity, enc) : null;
			} else {
				StringBuffer sb = new StringBuffer();
				sb.append('[');
				sb.append(mark);
				sb.append("] unexpected response status : ");
				sb.append(status);
				throw new ClientProtocolException(sb.toString());
			}
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
		String key = routeparams.get("key");
		if (key == null) {
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, key is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String clientId = routeparams.get("clientId");
		if (clientId == null) {
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, clientId is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String merchant = routeparams.get("merchant");
		if (merchant == null) {
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, merchant is null@" + TimeUtils.getSysLogTimeString());
			break;
		}

		//参数准备, 每个通道不同
		String packagecode = null;
		if (routeid.equals("1318")) {
			//全国移动
			if (packageid.equals("yd.10M")) {
				packagecode = "16263";
			} else if (packageid.equals("yd.30M")) {
				packagecode = "16264";
			} else if (packageid.equals("yd.70M")) {
				packagecode = "16265";
			} else if (packageid.equals("yd.100M")) {
				packagecode = "16266";
			} else if (packageid.equals("yd.150M")) {
				packagecode = "16267";
			} else if (packageid.equals("yd.300M")) {
				packagecode = "16268";
			} else if (packageid.equals("yd.500M")) {
				packagecode = "16269";
			} else if (packageid.equals("yd.1G")) {
				packagecode = "16270";
			} else if (packageid.equals("yd.2G")) {
				packagecode = "16271";
			} else if (packageid.equals("yd.3G")) {
				packagecode = "16272";
			} else if (packageid.equals("yd.4G")) {
				packagecode = "16273";
			} else if (packageid.equals("yd.6G")) {
				packagecode = "16274";
			} else if (packageid.equals("yd.11G")) {
				packagecode = "16275";
			}
		} else if (routeid.equals("1319")) {
			//吉林移动
			if (packageid.equals("yd.10M")) {
				packagecode = "16184";
			} else if (packageid.equals("yd.30M")) {
				packagecode = "16185";
			} else if (packageid.equals("yd.70M")) {
				packagecode = "16186";
			} else if (packageid.equals("yd.100M")) {
				packagecode = "16187";
			} else if (packageid.equals("yd.150M")) {
				packagecode = "16188";
			} else if (packageid.equals("yd.300M")) {
				packagecode = "16189";
			} else if (packageid.equals("yd.500M")) {
				packagecode = "16190";
			} else if (packageid.equals("yd.1G")) {
				packagecode = "16191";
			} else if (packageid.equals("yd.2G")) {
				packagecode = "16192";
			} else if (packageid.equals("yd.3G")) {
				packagecode = "16193";
			} else if (packageid.equals("yd.4G")) {
				packagecode = "16194";
			} else if (packageid.equals("yd.6G")) {
				packagecode = "16195";
			} else if (packageid.equals("yd.11G")) {
				packagecode = "16196";
			}
		} else if (routeid.equals("1355")) {
			//山东移动
			if (packageid.equals("yd.10M")) {
				packagecode = "16509";
			} else if (packageid.equals("yd.30M")) {
				packagecode = "16510";
			} else if (packageid.equals("yd.70M")) {
				packagecode = "16511";
			} else if (packageid.equals("yd.100M")) {
				packagecode = "16512";
			} else if (packageid.equals("yd.150M")) {
				packagecode = "16513";
			} else if (packageid.equals("yd.300M")) {
				packagecode = "16514";
			} else if (packageid.equals("yd.500M")) {
				packagecode = "16515";
			} else if (packageid.equals("yd.1G")) {
				packagecode = "16516";
			} else if (packageid.equals("yd.2G")) {
				packagecode = "16517";
			} else if (packageid.equals("yd.3G")) {
				packagecode = "16518";
			} else if (packageid.equals("yd.4G")) {
				packagecode = "16519";
			} else if (packageid.equals("yd.6G")) {
				packagecode = "16520";
			} else if (packageid.equals("yd.11G")) {
				packagecode = "16521";
			}
		} else if (routeid.equals("1353")) {
			//内蒙古移动
			if (packageid.equals("yd.10M")) {
				packagecode = "16496";
			} else if (packageid.equals("yd.30M")) {
				packagecode = "16497";
			} else if (packageid.equals("yd.70M")) {
				packagecode = "16498";
			} else if (packageid.equals("yd.100M")) {
				packagecode = "16499";
			} else if (packageid.equals("yd.150M")) {
				packagecode = "16500";
			} else if (packageid.equals("yd.300M")) {
				packagecode = "16501";
			} else if (packageid.equals("yd.500M")) {
				packagecode = "16502";
			} else if (packageid.equals("yd.1G")) {
				packagecode = "16503";
			} else if (packageid.equals("yd.2G")) {
				packagecode = "16504";
			} else if (packageid.equals("yd.3G")) {
				packagecode = "16505";
			} else if (packageid.equals("yd.4G")) {
				packagecode = "16506";
			} else if (packageid.equals("yd.6G")) {
				packagecode = "16507";
			} else if (packageid.equals("yd.11G")) {
				packagecode = "16508";
			}
		} else if (routeid.equals("1395")) {
			//湖南移动
			if (packageid.equals("yd.10M")) {
				packagecode = "16843";
			} else if (packageid.equals("yd.30M")) {
				packagecode = "16844";
			} else if (packageid.equals("yd.70M")) {
				packagecode = "16845";
			} else if (packageid.equals("yd.100M")) {
				packagecode = "16846";
			} else if (packageid.equals("yd.150M")) {
				packagecode = "16847";
			} else if (packageid.equals("yd.300M")) {
				packagecode = "16848";
			} else if (packageid.equals("yd.500M")) {
				packagecode = "16849";
			} else if (packageid.equals("yd.1G")) {
				packagecode = "16850";
			} else if (packageid.equals("yd.2G")) {
				packagecode = "16851";
			} else if (packageid.equals("yd.3G")) {
				packagecode = "16852";
			} else if (packageid.equals("yd.4G")) {
				packagecode = "16853";
			} else if (packageid.equals("yd.6G")) {
				packagecode = "16854";
			} else if (packageid.equals("yd.11G")) {
				packagecode = "16855";
			}
		} else if (routeid.equals("1354")) {
			//浙江移动
			if (packageid.equals("yd.10M")) {
				packagecode = "16391";
			} else if (packageid.equals("yd.30M")) {
				packagecode = "16392";
			} else if (packageid.equals("yd.70M")) {
				packagecode = "16393";
			} else if (packageid.equals("yd.150M")) {
				packagecode = "16395";
			} else if (packageid.equals("yd.500M")) {
				packagecode = "16397";
			} else if (packageid.equals("yd.1G")) {
				packagecode = "16398";
			} else if (packageid.equals("yd.2G")) {
				packagecode = "16399";
			} else if (packageid.equals("yd.3G")) {
				packagecode = "16400";
			} else if (packageid.equals("yd.4G")) {
				packagecode = "16401";
			} else if (packageid.equals("yd.6G")) {
				packagecode = "16402";
			} else if (packageid.equals("yd.11G")) {
				packagecode = "16403";
			}
		} else if (routeid.equals("1352")) {
			//黑龙江移动
			if (packageid.equals("yd.70M")) {
				packagecode = "16488";
			} else if (packageid.equals("yd.100M")) {
				packagecode = "16489";
			} else if (packageid.equals("yd.150M")) {
				packagecode = "16490";
			} else if (packageid.equals("yd.500M")) {
				packagecode = "16492";
			} else if (packageid.equals("yd.1G")) {
				packagecode = "16493";
			} else if (packageid.equals("yd.2G")) {
				packagecode = "16494";
			} else if (packageid.equals("yd.3G")) {
				packagecode = "16495";
			}
		}else if (routeid.equals("1320")) {
			//陕西移动
			if (packageid.equals("yd.10M")) {
				packagecode = "16210";
			} else if (packageid.equals("yd.30M")) {
				packagecode = "16211";
			} else if (packageid.equals("yd.70M")) {
				packagecode = "16212";
			} else if (packageid.equals("yd.150M")) {
				packagecode = "16214";
			} else if (packageid.equals("yd.500M")) {
				packagecode = "16216";
			} else if (packageid.equals("yd.1G")) {
				packagecode = "16217";
			} else if (packageid.equals("yd.2G")) {
				packagecode = "16218";
			} else if (packageid.equals("yd.3G")) {
				packagecode = "16219";
			} else if (packageid.equals("yd.4G")) {
				packagecode = "16220";
			} else if (packageid.equals("yd.6G")) {
				packagecode = "16221";
			} else if (packageid.equals("yd.11G")) {
				packagecode = "16222";
			}
		} else if (routeid.equals("1321")) {
			//西藏移动
			if (packageid.equals("yd.10M")) {
				packagecode = "16223";
			} else if (packageid.equals("yd.30M")) {
				packagecode = "16224";
			} else if (packageid.equals("yd.70M")) {
				packagecode = "16225";
			} else if (packageid.equals("yd.100M")) {
				packagecode = "16226";
			} else if (packageid.equals("yd.150M")) {
				packagecode = "16227";
			} else if (packageid.equals("yd.300M")) {
				packagecode = "16228";
			} else if (packageid.equals("yd.500M")) {
				packagecode = "16229";
			} else if (packageid.equals("yd.1G")) {
				packagecode = "16230";
			} else if (packageid.equals("yd.2G")) {
				packagecode = "16231";
			} else if (packageid.equals("yd.3G")) {
				packagecode = "16232";
			} else if (packageid.equals("yd.4G")) {
				packagecode = "16233";
			} else if (packageid.equals("yd.6G")) {
				packagecode = "16234";
			} else if (packageid.equals("yd.11G")) {
				packagecode = "16235";
			}
		} else if (routeid.equals("1322")) {
			//天津移动
			if (packageid.equals("yd.30M")) {
				packagecode = "16236";
			} else if (packageid.equals("yd.70M")) {
				packagecode = "16237";
			} else if (packageid.equals("yd.150M")) {
				packagecode = "16239";
			} else if (packageid.equals("yd.500M")) {
				packagecode = "16241";
			} else if (packageid.equals("yd.1G")) {
				packagecode = "16242";
			} else if (packageid.equals("yd.2G")) {
				packagecode = "16243";
			} else if (packageid.equals("yd.3G")) {
				packagecode = "16244";
			} else if (packageid.equals("yd.4G")) {
				packagecode = "16245";
			} else if (packageid.equals("yd.6G")) {
				packagecode = "16246";
			} else if (packageid.equals("yd.11G")) {
				packagecode = "16247";
			} else if (packageid.equals("yd.700M")) {
				packagecode = "16248";
			}
		} else if (routeid.equals("1323")) {
			//青海移动
			if (packageid.equals("yd.10M")) {
				packagecode = "16249";
			} else if (packageid.equals("yd.30M")) {
				packagecode = "16250";
			} else if (packageid.equals("yd.70M")) {
				packagecode = "16251";
			} else if (packageid.equals("yd.100M")) {
				packagecode = "16252";
			} else if (packageid.equals("yd.150M")) {
				packagecode = "16253";
			} else if (packageid.equals("yd.300M")) {
				packagecode = "16254";
			} else if (packageid.equals("yd.500M")) {
				packagecode = "16255";
			} else if (packageid.equals("yd.1G")) {
				packagecode = "16256";
			}
		} else if (routeid.equals("2287")) {
			//山东联通
			if (packageid.equals("lt.30M")) {
				packagecode = "16159";
			} else if (packageid.equals("lt.300M")) {
				packagecode = "16158";
			} else if (packageid.equals("lt.100M")) {
				packagecode = "16154";
			} else if (packageid.equals("lt.50M")) {
				packagecode = "16153";
			} else if (packageid.equals("lt.200M")) {
				packagecode = "16155";
			} else if (packageid.equals("lt.500M")) {
				packagecode = "16156";
			} else if (packageid.equals("lt.20M")) {
				packagecode = "16152";
			} else if (packageid.equals("lt.1G")) {
				packagecode = "16157";
			}
		} else if (routeid.equals("2286")) {
			//全国联通
			if (packageid.equals("lt.30M")) {
				packagecode = "16150";
			} else if (packageid.equals("lt.300M")) {
				packagecode = "16151";
			} else if (packageid.equals("lt.1G")) {
				packagecode = "16149";
			}
		}
		if (packagecode == null) {
			request.setAttribute("result", "S." + routeid + ":unrecognized package@" + TimeUtils.getSysLogTimeString());
			break;
		}

		url = url + "/capi/trade.charge";
		String ts = "" + System.currentTimeMillis();
		String version = "V100";
		String signbef = "accountVal" + phone + "clientId" + clientId + "merchant" + merchant + "outTradeNo" + taskid + "product" + packagecode + "ts" + ts + "version" + version + key;
		System.out.println(signbef);
		String sign = MD5Util.getLowerMD5(signbef);
		JSONObject json = new JSONObject();
		json.put("accountVal", phone);
		json.put("clientId", clientId);
		json.put("merchant", merchant);
		json.put("outTradeNo", taskid);
		json.put("product", packagecode);
		json.put("sign", sign);
		json.put("ts", ts);
		json.put("version", version);

		//在执行请求前先获取连接, 防止访问通道线程超量
		Cache.getConnection(routeid);
		try {
			//ret = HttpAccess.postNameValuePairRequest(url, params, "utf-8", "mysend");
			//ret = HttpAccess.postJsonRequest(url, json.toString(), "utf-8", "weikesend");
			ret = postJsonRequest(url, json.toString(), "utf-8", "xingyun");
		} catch (Exception e) {
			e.printStackTrace();
			logger.info(e.getMessage());
		} finally {
			//在执行请求后记得释放连接
			Cache.releaseConnection(routeid);
		}

		//这里判断结果, 每个通道情况不同, 成功的保存 success 到 result 中并返回到 request.jsp
		if (ret != null && ret.trim().length() > 0) {
			logger.info("xingyun send ret = " + ret);
			try {
				JSONObject retjson = JSONObject.fromObject(ret);
				String resultCode = retjson.getString("rspCode"); //":"MOB00001"
				if (resultCode.equals("0")) {
					request.setAttribute("result", "success");
					//request.setAttribute("reportid",taskid);
				} else {
					request.setAttribute("code", resultCode);
					String resultMsg = retjson.getString("rspMsg");
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