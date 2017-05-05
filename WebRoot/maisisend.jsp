<%@page import="java.util.LinkedHashMap"%>
<%@page import="java.util.Map.Entry"%>
<%@page import="org.dom4j.Element"%>
<%@page import="org.dom4j.DocumentHelper"%>
<%@page import="org.dom4j.Document"%>
<%@page import="java.util.Date"%>
<%@page import="java.text.SimpleDateFormat"%>
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

		//检查通道参数, 每个通道有不同参数, 对应 ll_routes.api_params
		Map<String, String> routeparams = Cache.getRouteParams(routeid);
		if (routeparams == null) {
			request.setAttribute("result", "S." + routeid + ":wrong routeparams@" + TimeUtils.getSysLogTimeString());
			break;
		}

		String cpid = routeparams.get("cpid");
		if (cpid == null) {
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, cpid is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String range = routeparams.get("range");
		if (range == null) {
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, range is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String appID = routeparams.get("appID");
		if (appID == null) {
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, appID is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String appKey = routeparams.get("appKey");
		if (appKey == null) {
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, appKey is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String url = routeparams.get("url");
		if (url == null) {
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, url is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String password = routeparams.get("password");
		if (password == null) {
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, password is null@" + TimeUtils.getSysLogTimeString());
			break;
		}

		//参数准备, 每个通道不同
		String packagecode = null;
		try {
			packageid = packageid.split("\\.")[1];
			String pkstr = packageid.substring(0, packageid.length() - 1);
			int pk = Integer.parseInt(pkstr);
			if (packageid.indexOf('G') >= 0) {
				pk *= 1024;
			}
			packagecode = String.valueOf(pk);
		} catch (Exception e) {
			logger.warn(e.getMessage(), 0);
		}

		if (packagecode == null) {
			request.setAttribute("result", "S." + routeid + ":unrecognized package@" + TimeUtils.getSysLogTimeString());
			break;
		}
		Map<String, String> maps = new LinkedHashMap<String, String>();
		maps.put("appID", appID);
		maps.put("appKey", appKey);
		maps.put("cpid", cpid);
		maps.put("cpparam", taskid);
		maps.put("flowValue", packagecode);
		maps.put("Mobile", phone); 
		maps.put("range", range);
		String paramstr="";
		for(Entry<String, String> entry : maps.entrySet()){
			if(paramstr.length() > 0){
				paramstr = paramstr + "&";
			}
			paramstr = paramstr + entry.getKey() + "=" + entry.getValue();
		}
		
		Map<String, String> parm = new HashMap<String, String>();
		parm.put("cpid", cpid);
		parm.put("cpparam", taskid);
		parm.put("flowValue", packagecode);
		parm.put("Mobile", phone);
		parm.put("range", range);
		logger.info("sign bef="+paramstr+MD5Util.getUpperMD5(password));
		String sign= MD5Util.getLowerMD5(paramstr+MD5Util.getUpperMD5(password));
		logger.info("sign bac="+sign);
		parm.put("sign", sign);

		//在执行请求前先获取连接, 防止访问通道线程超量
		Cache.getConnection(routeid);
		try {
			//ret = HttpAccess.postNameValuePairRequest(url, params, "utf-8", "mysend");
			ret = HttpAccess.postNameValuePairRequest(url, parm, "utf-8", "maisi");
		} catch (Exception e) {
			e.printStackTrace();
			logger.info(e.getMessage());
		} finally {
			//在执行请求后记得释放连接
			Cache.releaseConnection(routeid);
		}

		//这里判断结果, 每个通道情况不同, 成功的保存 success 到 result 中并返回到 request.jsp
		if (ret != null && ret.trim().length() > 0) {
			logger.info("maisi send ret = " + ret);
			try {
				Document doc = DocumentHelper.parseText(ret);
				Element root = doc.getRootElement();
				String retCode = root.elementText("retCode");
				if (retCode.equals("0")) {
					request.setAttribute("result", "success");
				} else {
					String msg = root.elementText("retMsg");
					request.setAttribute("code", 1);
					request.setAttribute("result", "R." + routeid + ":" + msg + "@" + TimeUtils.getSysLogTimeString());
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