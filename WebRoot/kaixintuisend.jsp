<%@page import="com.alibaba.fastjson.JSONObject"%>
<%@page import="util.TimeUtils,
				http.HttpAccess,
				util.MD5Util,
				cache.Cache,
				java.util.*,
				util.MyStringUtils,
				java.net.URLDecoder,
				org.apache.logging.log4j.LogManager,
				org.apache.logging.log4j.Logger,
				util.MyBase64,
				java.security.MessageDigest,
				java.security.NoSuchAlgorithmException,
				java.io.UnsupportedEncodingException"
		language="java" pageEncoding="UTF-8"
%><%
	boolean logflag = true;
	Logger logger = LogManager.getLogger();
	
	//获取公共参数
	String taskid = request.getAttribute("taskid").toString();
	String routeid = request.getAttribute("routeid").toString();
	String phone = request.getAttribute("phone").toString();
	String packageid = request.getAttribute("package").toString();
	
	while(true){
		String ret = null;
		
		//检查通道参数, 每个通道有不同参数, 对应 ll_routes.api_params(私有参数)
		Map<String, String> routeparams = Cache.getRouteParams(routeid);
		if(routeparams == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams@" + TimeUtils.getSysLogTimeString());
			break;
		}
		
		String url = routeparams.get("url");
		if(url == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, url is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String appid = routeparams.get("appid");
		if(appid == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, appid is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String appsecret = routeparams.get("appsecret");
		if(appsecret == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, appsecret is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String packtype = routeparams.get("packtype");
		if(packtype == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, packtype is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String notifyurl = routeparams.get("notifyurl");
		if(notifyurl == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, notifyurl is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		
		//参数准备, 每个通道不同
		String packagecode = null;
		try{
			packagecode = packageid.split("\\.")[1];
			logger.info("kaixintui packagecode = " + packagecode);
		} catch (Exception e) {
			logger.warn(e.getMessage(), 0);
		}
		
		if(packagecode == null){
			request.setAttribute("result", "S." + routeid + ":unrecognized package@" + TimeUtils.getSysLogTimeString());
			break;
		}
		
		String sig = appid + phone + packtype + packagecode + taskid + notifyurl + taskid + appsecret;
		logger.info("kaixintuisend 加密前=" + sig);
		String sign = MD5Util.getLowerMD5(sig);
		logger.info("kaixintuisend 加密后=" + sign);

		HashMap<String, String> map = new HashMap<String, String>();
		map.put("appid", appid);
		map.put("mobile", phone);
		map.put("packtype", packtype);
		map.put("packcode", packagecode);
		map.put("batchno", taskid);
		map.put("notifyurl", notifyurl);
		map.put("requestid", taskid);
		map.put("sign", sign);
		
		logger.info("kaixintui 请求参数=" + map.toString());
		
		//在执行请求前先获取连接, 防止访问通道线程超量
		Cache.getConnection(routeid);
		try {
			ret = HttpAccess.postNameValuePairRequest(url, map, "utf-8", "kaixintuisend");
		} catch (Exception e) {
			e.printStackTrace();
			logger.info(e.getMessage());
		} finally {
			//在执行请求后记得释放连接
			Cache.releaseConnection(routeid);
		}
	
		//这里判断结果, 每个通道情况不同, 成功的保存 success 到 result 中并返回到 request.jsp(ret为返回的结果)
		if (ret != null && ret.trim().length() > 0) {
			logger.info("kaixintui send ret = " + ret);
			try {
				JSONObject retjson = JSONObject.parseObject(ret);
				String retCode = retjson.getString("retcode");
				String message = retjson.getString("retmsg");
				String batchno = retjson.getString("batchno");
				if(retCode.equals("0")){
					request.setAttribute("result", "success");
					request.setAttribute("reportid", batchno);
				}else{
					request.setAttribute("code", 1);
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

	request.getRequestDispatcher("request.jsp").forward(request,response);
%>