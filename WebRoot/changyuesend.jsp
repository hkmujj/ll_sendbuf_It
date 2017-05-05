<%@page import="java.util.HashMap"%>
<%@page import="http.HttpAccess"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="net.sf.json.JSONObject,
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
		
		//检查通道参数, 每个通道有不同参数, 对应 ll_routes.api_params
		Map<String, String> routeparams = Cache.getRouteParams(routeid);
		if(routeparams == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams@" + TimeUtils.getSysLogTimeString());
			break;
		}
		
		String appId = routeparams.get("appId");
		if(appId == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, appId is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String appSecret = routeparams.get("appSecret");
		if(appSecret == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, appSecret is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String scope = routeparams.get("scope");
		if(scope == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, scope is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String callback_url = routeparams.get("callback_url");
		if(callback_url == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, callback_url is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String url = routeparams.get("url");
		if(url == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, url is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		
		//参数准备, 每个通道不同
		String packagecode = null;
		
		try{
			packageid = packageid.split("\\.")[1];
			String pkstr = packageid.substring(0, packageid.length() - 1);
			int pk = Integer.parseInt(pkstr);
			if(packageid.indexOf('G') >= 0){
				pk *= 1024;
			}
			packagecode = String.valueOf(pk);
		} catch (Exception e) {
			logger.warn(e.getMessage(), 0);
		}
		
		if(packagecode == null){
			request.setAttribute("result", "S." + routeid + ":unrecognized package@" + TimeUtils.getSysLogTimeString());
			break;
		}
		
		String app_id = appId;
		String verify_sign = MD5Util.getLowerMD5(appId + appSecret);
		String phone_no = phone;
		String flow_val = packagecode;
		//String scope = 
		String out_order_id = taskid;
		String timestamp = new SimpleDateFormat("yyyyMMddHHmmssSSS").format(System.currentTimeMillis()); 
		//String callback_url = 
		JSONObject obj = new JSONObject();
		JSONObject json = new JSONObject();
		json.put("app_id", app_id);
		json.put("verify_sign", verify_sign);
		json.put("phone_no", phone_no);
		json.put("flow_val", flow_val);
		json.put("scope", scope);
		json.put("out_order_id", out_order_id);
		json.put("timestamp", timestamp);
		json.put("callback_url", callback_url);
		logger.info("changyuesend data = " + json.toString());
		
		String sendurl = url + "?" + "app_id=" + app_id + "&verify_sign=" + verify_sign + "&phone_no=" + 
						 phone_no + "&flow_val=" + flow_val + "&scope=" + scope + "&out_order_id=" + out_order_id + 
						 "&timestamp=" + timestamp + "&callback_url=" + callback_url;
		logger.info("changyue sendurl = " + sendurl);
		
		//在执行请求前先获取连接, 防止访问通道线程超量
		Cache.getConnection(routeid);
		try {
			 ret = HttpAccess.postJsonRequest(sendurl, obj.toString(), "utf-8", "changyuesend");
			//ret = HttpAccess.postJsonRequest(url, json.toString(), "utf-8", "weikesend");
		} catch (Exception e) {
			e.printStackTrace();
			logger.info(e.getMessage());
		} finally {
			//在执行请求后记得释放连接
			Cache.releaseConnection(routeid);
		}
	
		//这里判断结果, 每个通道情况不同, 成功的保存 success 到 result 中并返回到 request.jsp
		if (ret != null && ret.trim().length() > 0) {
			logger.info("changyue send ret = " + ret);
			
			HashMap<String, String> errmap = new HashMap<String, String>();
			errmap.put("1", "系统升级中");
			errmap.put("-1", "参数错误");
			errmap.put("-2", "访问超速");
			errmap.put("-3", "鉴权失败");
			errmap.put("-4", "账号异常");
			errmap.put("-5", "异常订购");
			errmap.put("-6", "余额不足");
			errmap.put("-7", "系统异常");
			
			try {
				JSONObject retjson = JSONObject.fromObject(ret);
				String retCode = retjson.getString("result"); //":"MOB00001"
				if(retCode.equals("0")){
					request.setAttribute("result", "success");
				}else{
					request.setAttribute("code", 1);
					String message = errmap.get(retCode);
					if(message == null){
						message = retCode;
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

	request.getRequestDispatcher("request.jsp").forward(request,response);
%>