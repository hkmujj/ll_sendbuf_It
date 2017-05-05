<%@page import="org.dom4j.Element"%>
<%@page import="org.dom4j.DocumentHelper"%>
<%@page import="org.dom4j.Document"%>
<%@page import="util.MD5Util"%>
<%@page
	import="util.TimeUtils,
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

	while (true) {
		String ret = null;

		//检查通道参数, 每个通道有不同参数, 对应 ll_routes.api_params
		Map<String, String> routeparams = Cache.getRouteParams(routeid);
		if (routeparams == null) {
			request.setAttribute("result","S." + routeid + ":wrong routeparams@"+ TimeUtils.getSysLogTimeString());
			break;
		}

		String mt_url = routeparams.get("mt_url");
		if (mt_url == null) {
			request.setAttribute("result",
					"S." + routeid + ":wrong routeparams, mt_url is null@"
							+ TimeUtils.getSysLogTimeString());
			break;
		}
		String userid = routeparams.get("userid");
		if (userid == null) {
			request.setAttribute("result", "S." + routeid
					+ ":wrong routeparams, userid is null@"
					+ TimeUtils.getSysLogTimeString());
			break;
		}
		String pwd = routeparams.get("pwd");
		if (pwd == null) {
			request.setAttribute("result",
					"S." + routeid + ":wrong routeparams, pwd is null@"
							+ TimeUtils.getSysLogTimeString());
			break;
		}
		String key = routeparams.get("key");
		if (key == null) {
			request.setAttribute("result", "S." + routeid
					+ ":wrong routeparams, key is null@"
					+ TimeUtils.getSysLogTimeString());
			break;
		}
		String area = routeparams.get("area");
		if (area == null) {
			request.setAttribute("result", "S." + routeid
					+ ":wrong routeparams, area is null@"
					+ TimeUtils.getSysLogTimeString());
			break;
		}
		
		
		//参数准备, 每个通道不同
		String packagecode = null;
		try {
			packageid = packageid.split("\\.")[1];
			String pkstr = packageid.substring(0,
					packageid.length() - 1);
			int pk = Integer.parseInt(pkstr);
			if (packageid.indexOf('G') >= 0) {
				pk *= 1024;
			}
			packagecode = String.valueOf(pk);
		} catch (Exception e) {
			logger.warn(e.getMessage(), 0);
		}

		if (packagecode == null) {
			request.setAttribute("result",
					"S." + routeid + ":unrecognized package@"
							+ TimeUtils.getSysLogTimeString());
			break;
		}

		String timestamp = System.currentTimeMillis() + "";
		Map<String, String> parms=new LinkedHashMap<String, String>();
		parms.put("userid", userid);
		parms.put("pwd", pwd);
		parms.put("orderid", taskid);
		parms.put("account", phone);
		parms.put("gprs", packagecode);
		parms.put("area", area);
		//area=0全国  area=1省内
		parms.put("effecttime", "0");
		parms.put("validity", "0");
		parms.put("times", timestamp);
		
		Iterator iter=parms.entrySet().iterator();
		String akey="";
		String burl="";
		while (iter.hasNext()) {
			Map.Entry entry=(Map.Entry)iter.next();
			akey=akey+entry.getKey()+entry.getValue();
		}
		String userkey=MD5Util.getUpperMD5(akey+key);
		
		parms.put("userkey", userkey);
		
		Iterator itera=parms.entrySet().iterator();
	
		while (itera.hasNext()) {
			Map.Entry entry=(Map.Entry)itera.next();
			burl=burl+"&"+entry.getKey()+"="+entry.getValue();
		}
		//burl=burl.replace("?mc&", "?");
		burl = "?" + burl.substring(1);
		String url = mt_url + burl;


		//在执行请求前先获取连接, 防止访问通道线程超量
		Cache.getConnection(routeid);
		try {
			//ret = HttpAccess.postNameValuePairRequest(url, params, "utf-8", "mysend");
			//ret = HttpAccess.postJsonRequest(url, json.toString(), "utf-8", "weikesend");
			ret=HttpAccess.postNameValuePairRequest(url, new HashMap<String, String>(), "utf-8", "toushimi");
			
		} catch (Exception e) {
			e.printStackTrace();
			logger.info(e.getMessage());
		} finally {
			//在执行请求后记得释放连接
			Cache.releaseConnection(routeid);
		}

		//这里判断结果, 每个通道情况不同, 成功的保存 success 到 result 中并返回到 request.jsp
		if (ret != null && ret.trim().length() > 0) {
			logger.info("toushimi send ret = " + ret);
			try {
				Document document = DocumentHelper.parseText(ret);
				Element root=document.getRootElement();
				Element	errele=root.element("error");
				Element staele=root.element("state");
				String error=errele.getText();
				String state=staele.getText();
				if (error.equals("0") && (state.equals("0") || state.equals("8"))) {
					request.setAttribute("result", "success");
				} else {
					request.setAttribute("code", state);
					request.setAttribute("result","R." + routeid + "error:" + error + "state:"+ state + "@"+ TimeUtils.getSysLogTimeString());
				}
				request.setAttribute("orgreturn", ret);
			} catch (Exception e)    {
				e.printStackTrace();
				logger.info(e.getMessage());
				request.setAttribute("result","R." + routeid + ":" + e.getMessage() + "@"+ TimeUtils.getSysLogTimeString());
			}
		} else {
			request.setAttribute("result", "R." + routeid + ":fail@"+ TimeUtils.getSysLogTimeString());
		}

		break;
	}

	request.getRequestDispatcher("request.jsp").forward(request,
			response);
%>