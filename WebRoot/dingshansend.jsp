<%@page import="java.io.InputStreamReader"%>
<%@page import="java.io.OutputStreamWriter"%>
<%@page import="java.io.BufferedReader"%>
<%@page import="java.io.PrintWriter"%>
<%@page import="java.net.HttpURLConnection"%>
<%@page import="java.net.URL"%>
<%@page import="com.sun.org.apache.xml.internal.security.utils.Base64"%>
<%@page import="javax.crypto.Mac"%>
<%@page import="javax.crypto.spec.SecretKeySpec"%>
<%@page import="util.MD5Util,
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

		//参数准备, 每个通道不同
		String packagecode = null;
		try {			
			if(packageid.equals("dx.5M")){//电信全国
				packagecode = "prod.1000000005M01";
			}else if(packageid.equals("dx.10M")){
				packagecode = "prod.1000000010M01";
			}else if(packageid.equals("dx.30M")){
				packagecode = "prod.1000000030M01";
			}else if(packageid.equals("dx.50M")){
				packagecode = "prod.1000000050M01";
			}else if(packageid.equals("dx.100M")){
				packagecode = "prod.1000000100M01";
			}else if(packageid.equals("dx.200M")){
				packagecode = "prod.1000000200M01";
			}else if(packageid.equals("dx.500M")){
				packagecode = "prod.1000000500M01";
			}else if(packageid.equals("dx.1G")){
				packagecode = "prod.1000001024M01";
			}else if(packageid.equals("lt.20M")){//联通全国
				packagecode = "prod.1001000020M01";
			}else if(packageid.equals("lt.50M")){
				packagecode = "prod.1001000050M01";
			}else if(packageid.equals("lt.100M")){
				packagecode = "prod.1001000100M01";
			}else if(packageid.equals("lt.200M")){
				packagecode = "prod.1001000200M01";
			}else if(packageid.equals("lt.500M")){
				packagecode = "prod.1001000500M01";
			}else if(packageid.equals("yd.10M")){//移动全国
				packagecode = "prod.1008600010M01";
			}else if(packageid.equals("yd.30M")){
				packagecode = "prod.1008600030M01";
			}else if(packageid.equals("yd.70M")){
				packagecode = "prod.1008600070M01";
			}else if(packageid.equals("yd.150M")){
				packagecode = "prod.1008600150M01";
			}else if(packageid.equals("yd.500M")){
				packagecode = "prod.1008600500M01";
			}else if(packageid.equals("yd.1G")){
				packagecode = "prod.1008601024M01";
			}else if(packageid.equals("yd.2G")){
				packagecode = "prod.1008602048M01";
			}else if(packageid.equals("yd.3G")){
				packagecode = "prod.1008603072M01";
			}else if(packageid.equals("yd.4G")){
				packagecode = "prod.1008604096M01";
			}else if(packageid.equals("yd.6G")){
				packagecode = "prod.1008606144M01";
			}else if(packageid.equals("yd.11G")){
				packagecode = "prod.1008611264M01";
			}
			
			
			} catch (Exception e) {
			logger.warn(e.getMessage(), 0);
		}

		if (packagecode == null) {
			request.setAttribute("result", "S." + routeid + ":unrecognized package@" + TimeUtils.getSysLogTimeString());
			break;
		}
		try {
			JSONObject json = new JSONObject();
			json.put("cmd_flag", "flux_recharge");
			json.put("flx_type", "S");
			json.put("mobile", phone);
			json.put("orderid", taskid);
			json.put("packagesize", "");
			json.put("platid", platid);
			json.put("productcode", packagecode);
			json.put("reserve", "");
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

		//这里判断结果, 每个通道情况不同, 成功的保存 success 到 result 中并返回到 request.jsp
		if (ret != null && ret.trim().length() > 0) {
			logger.info("dingshan send ret = " + ret);
			try {
				JSONObject retjson = JSONObject.fromObject(ret);
				String resultCode = retjson.getString("ret_code"); //":"MOB00001"
				if (resultCode.equals("0000")) {
					request.setAttribute("result", "success");
					//request.setAttribute("reportid",taskid);
				} else {
					request.setAttribute("code", resultCode);
					String resultMsg = retjson.getString("ret_msg");
					request.setAttribute("result",
							"R." + routeid + ":" + resultCode + ":" + resultMsg + "@" + TimeUtils.getSysLogTimeString());
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