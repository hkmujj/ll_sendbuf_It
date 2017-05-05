<%@page import="java.io.InputStreamReader"%>
<%@page import="java.io.OutputStreamWriter"%>
<%@page import="java.io.BufferedReader"%>
<%@page import="java.io.PrintWriter"%>
<%@page import="java.net.HttpURLConnection"%>
<%@page import="java.net.URL"%>
<%@page import="com.sun.org.apache.xml.internal.security.utils.Base64"%>
<%@page import="javax.crypto.Mac"%>
<%@page import="javax.crypto.spec.SecretKeySpec"%>
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
	<%!public static JSONObject toJsonRemoveSignature(Object object) {
		JSONObject json = JSONObject.fromObject(object);
		json.remove("signature");
		return json;
	}

	public static String doSign(JSONObject json, String secret) throws Exception {
		String baseStr = "";
		for (Object key : new TreeSet(json.keySet())) {
			baseStr += ("&" + key + "=" + json.get(key));
		}

		SecretKeySpec key = new SecretKeySpec(secret.getBytes("UTF-8"), "HmacSHA1");
		Mac mac = Mac.getInstance("HmacSHA1");
		mac.init(key);
		byte[] bytes = mac.doFinal(baseStr.substring(1).getBytes("UTF-8"));

		json.put("signature", new String(Base64.encode(bytes)));
		return json.toString();
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

		String mt_url = routeparams.get("mt_url");
		if (mt_url == null) {
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, mt_url is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String platid = routeparams.get("platid");
		if (platid == null) {
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, platid is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String token = routeparams.get("token");
		if (token == null) {
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, token is null@" + TimeUtils.getSysLogTimeString());
			break;
		}

		//发送请求前先准备好参数
		String[] idarray = ids.split(",");
		JSONObject obj = new JSONObject();

		for (int i = 0; i < idarray.length; i++) {
			try {
				JSONObject json = new JSONObject();
				json.put("cmd_flag", "flux_queryOrder");
				json.put("orderid", idarray[i]);
				json.put("platid", platid);
				json.put("timestamp", System.currentTimeMillis() + "");
				json.put("token", "");
				json.put("version", "");
				json.put("signature", "");
				String reqjson = doSign(toJsonRemoveSignature(json.toString()), token);
				logger.info("dingshang retjson = " + reqjson);
				URL url = new URL(mt_url);

				HttpURLConnection connection = (HttpURLConnection) url.openConnection();
				connection.setRequestMethod("POST");
				connection.setDoOutput(true);
				connection.setRequestProperty("Content-Type", "text/html;charset=utf-8;");

				PrintWriter outpr = new PrintWriter(new OutputStreamWriter(connection.getOutputStream(), "UTF-8"));
				outpr.println(reqjson);
				outpr.close();
				BufferedReader in = new BufferedReader(new InputStreamReader(connection.getInputStream(), "UTF-8"));

				StringBuffer bankXmlBuffer = new StringBuffer();
				String inputLine;
				while ((inputLine = in.readLine()) != null) {
					bankXmlBuffer.append(inputLine);
				}
				in.close();
				ret = bankXmlBuffer.toString();
			} catch (Exception e) {
				e.printStackTrace();
			}
			//这里判断结果, 每个通道情况不同, 成功的节点ID对应success, 失败的对应失败信息
			if (ret != null && ret.trim().length() > 0) {
				//request.setAttribute("result", "success");
				logger.info("dingshan status ret = " + ret);
				try {
					JSONObject robj = JSONObject.fromObject(ret);
						JSONObject datejson = robj.getJSONObject("data");
						String staus = datejson.getString("state");
						if (staus.equals("S")) {
							JSONObject rp = new JSONObject();
							rp.put("code", 0);
							rp.put("message", "success");
							rp.put("resp", ret);
							obj.put(idarray[i], rp);
						} else if (staus.equals("F")) {
							JSONObject rp = new JSONObject();
							rp.put("code", "1");
							String msg = "失败";
							if (robj.get("desc") != null) {
								msg = robj.getString("desc");
							}
							rp.put("message", msg);
							rp.put("resp", ret);
							obj.put(idarray[i], rp);
						} else {
							logger.info("dingshan status : [" + idarray[i] + "]充值中@" + TimeUtils.getSysLogTimeString());
						}
					
				} catch (Exception e) {
					logger.warn(e.getMessage(), e);
					logger.info("dingshan status : " + e.getMessage() + ", ret = " + ret + "@" + TimeUtils.getSysLogTimeString());
				}
			} else {
				logger.info("dingshan status : " + "fail@" + TimeUtils.getSysLogTimeString());
			}
		}

		request.setAttribute("retjson", obj.toString());
		request.setAttribute("result", "success");

		break;
	}

	request.getRequestDispatcher("request.jsp").forward(request, response);
%>