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
<%
	boolean logflag = true;
	Logger logger = LogManager.getLogger();

	//获取公共参数
	String taskid = request.getAttribute("taskid").toString();
	String routeid = request.getAttribute("routeid").toString();
	String phone = request.getAttribute("phone").toString();
	String packageid = request.getAttribute("package").toString();

	while(true){
		String ret = null;

		//检查通道参数, 每个通道有不同参数, 对应 ll_routes.api_params
		Map<String, String> routeparams = Cache.getRouteParams(routeid);
		if(routeparams == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams@" + TimeUtils.getSysLogTimeString());
			break;
		}

		String mt_url = routeparams.get("mt_url");
		if(mt_url == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, mt_url is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String account = routeparams.get("account");
		if(account == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, account is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String password = routeparams.get("password");
		if(password == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, password is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String key = routeparams.get("key");
		if(key == null){
			request.setAttribute("result", "S." + routeid + ":wrong key, msgTemplateId is null@" + TimeUtils.getSysLogTimeString());
			break;
		}

		//参数准备, 每个通道不同
		String packagecode = null;
		String channelMarker = "";
		try{
			if(packageid.contains("dx.")){
				channelMarker = "JTDTY";
				if(packageid.equals("dx.5M")){
					packagecode = "18";
				}else if(packageid.equals("dx.10M")){
					packagecode = "19";
				}else if(packageid.equals("dx.30M")){
					packagecode = "20";
				}else if(packageid.equals("dx.50M")){
					packagecode = "21";
				}else if(packageid.equals("dx.100M")){
					packagecode = "22";
				}else if(packageid.equals("dx.200M")){
					packagecode = "23";
				}else if(packageid.equals("dx.500M")){
					packagecode = "24";
				}else if(packageid.equals("dx.1G")){
					packagecode = "25";
				}
			}else if(packageid.contains("lt.")){
				channelMarker = "DLTY";//30 150 300 700福建联通
				if(packageid.equals("lt.10M")){
					packagecode = "DL10";
				}else if(packageid.equals("lt.20M")){
					packagecode = "DL20";
				}else if(packageid.equals("lt.30M")){
					packagecode = "DL30";
				}else if(packageid.equals("lt.50M")){
					packagecode = "DL50";
				}else if(packageid.equals("lt.100M")){
					packagecode = "DL100";
				}else if(packageid.equals("lt.150M")){
					packagecode = "DL150";
				}else if(packageid.equals("lt.200M")){
					packagecode = "DL200";
				}else if(packageid.equals("lt.300M")){
					packagecode = "DL300";
				}else if(packageid.equals("lt.500M")){
					packagecode = "DL500";
				}else if(packageid.equals("lt.700M")){
					packagecode = "DL700";
				}else if(packageid.equals("lt.1G")){
					packagecode = "DL1000";
				}
			}else if(packageid.contains("yd.")){
				channelMarker = "DLMTY";
				if(packageid.equals("yd.10M")){
					packagecode = "DLM10";
				}else if(packageid.equals("yd.30M")){
					packagecode = "DLM30";
				}else if(packageid.equals("yd.70M")){
					packagecode = "DLM70";
				}else if(packageid.equals("yd.150M")){
					packagecode = "DLM150";
				}else if(packageid.equals("yd.500M")){
					//packagecode = "DLM500";
					packagecode = "DLMQG500";
				}else if(packageid.equals("yd.1G")){
					packagecode = "DLM1000";
				}else if(packageid.equals("yd.2G")){
					//packagecode = "DLM2000"
					packagecode = "DLMQG2048";
				}else if(packageid.equals("yd.3G")){
					packagecode = "DLM3000";
				}else if(packageid.equals("yd.4G")){
					packagecode = "DLM4000";
				}else if(packageid.equals("yd.6G")){
					packagecode = "DLM6000";
				}else if(packageid.equals("yd.11G")){
					packagecode = "DLM11000";
				}else if(packageid.equals("yd.100M")){
					packagecode = "DLM100";
				}else if(packageid.equals("yd.300M")){
					packagecode = "DLM300";
				}
			}
		}catch(Exception e){
			logger.warn(e.getMessage(), 0);
		}

		if(packagecode == null){
			request.setAttribute("result", "S." + routeid + ":unrecognized package@" + TimeUtils.getSysLogTimeString());
			break;
		}

		String sign = MD5Util.getUpperMD5(account + MD5Util.getUpperMD5(password) + key);
		String callbackURL = "http://120.24.156.98:9302/ll_sendbuf/status_ok.jsp";
		Map<String, String> parms = new LinkedHashMap<String, String>();
		parms.put("account", account);
		parms.put("password", password);
		parms.put("sign", sign);
		parms.put("account", account);
		parms.put("flowNum", packagecode);
		parms.put("mobile", phone);
		parms.put("channelMarker", channelMarker);
		parms.put("callbackURL", callbackURL);
		parms.put("range", "0");
		String burl = "";
		Iterator itera = parms.entrySet().iterator();
		while(itera.hasNext()){
			Map.Entry entry = (Map.Entry) itera.next();
			burl = burl + "&" + entry.getKey() + "=" + entry.getValue();
		}
		burl = "?" + burl.substring(1);

		String url = mt_url + burl;
		logger.info("deli send requese=" + url);

		//在执行请求前先获取连接, 防止访问通道线程超量
		Cache.getConnection(routeid);
		try{
			//ret = HttpAccess.postNameValuePairRequest(url, params, "utf-8", "mysend");
			//ret = HttpAccess.postJsonRequest(url, json.toString(), "utf-8", "weikesend");
			ret = HttpAccess.postNameValuePairRequest(url, new HashMap<String, String>(), "utf-8", "deli");
		}catch(Exception e){
			e.printStackTrace();
			logger.info(e.getMessage());
		}finally{
			//在执行请求后记得释放连接
			Cache.releaseConnection(routeid);
		}

		//这里判断结果, 每个通道情况不同, 成功的保存 success 到 result 中并返回到 request.jsp
		if(ret != null && ret.trim().length() > 0){
			logger.info("deli send ret = " + ret);
			try{
				JSONObject retjson = JSONObject.fromObject(ret);
				String resultCode = retjson.getString("code"); //":"2000"
				String state = retjson.getString("state");
				String sessionId = retjson.getString("sessionId");
				if(resultCode.equals("2000") && state.equals("true")){
					request.setAttribute("result", "success");
					request.setAttribute("reportid", sessionId);
				}else{
					request.setAttribute("code", resultCode);
					String resultMsg = retjson.getString("msg");
					request.setAttribute("result", "R." + routeid + ":" + resultCode + ":" + resultMsg + "@" + TimeUtils.getSysLogTimeString());
				}
				request.setAttribute("orgreturn", ret);
			}catch(Exception e){
				e.printStackTrace();
				logger.info(e.getMessage());
				request.setAttribute("result", "R." + routeid + ":" + e.getMessage() + "@" + TimeUtils.getSysLogTimeString());
			}
		}else{
			request.setAttribute("result", "R." + routeid + ":fail@" + TimeUtils.getSysLogTimeString());
		}

		break;
	}

	request.getRequestDispatcher("request.jsp").forward(request, response);
%>