<%@page import="http.HttpAccess"%>
<%@page import="java.util.HashMap"%>
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
		
		
		String username = routeparams.get("username");
		if(username == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, username is null@" + TimeUtils.getSysLogTimeString());
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
		String url = routeparams.get("url");
		if(url == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, url is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		
		//参数准备, 每个通道不同
		String packagecode = null;
		try{
			if(packageid.equals("dx.5M")){
				packagecode = "18";
			}
		} catch (Exception e) {
			logger.warn(e.getMessage(), 0);
		}
		
		if(packagecode == null){
			request.setAttribute("result", "S." + routeid + ":unrecognized package@" + TimeUtils.getSysLogTimeString());
			break;
		}
		
		String productId = packagecode;
		String mobile = phone;
		String transId = taskid;
		String sign = MD5Util.getLowerMD5(username + transId + productId + mobile + appId + appSecret);
		
		
		String params = "?" + "username=" + username + "&transId=" + transId + "&appId=" + appId 
								+ "&sign=" + sign + "&productId=" + productId + "&mobile=" + mobile;
		
		url = url + "/ytx/data/setProductByMobile2.jsp" + params;
		
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
			logger.info("jutongda send ret = " + ret);
			try {
				JSONObject retjson = JSONObject.fromObject(ret);
				String retCode = retjson.getString("code"); //":"MOB00001"
				Object obj = retjson.get("billId");
				String rpid = null;
				if(obj != null && obj.toString().trim().length() > 0){
					rpid = obj.toString();
				}
				String message = retjson.getString("message");
				if(retCode.equals("000") && rpid != null){
					request.setAttribute("result", "success");
					request.setAttribute("reportid", rpid);
				}else{
					request.setAttribute("code", 1);
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