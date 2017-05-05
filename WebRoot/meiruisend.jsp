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
		String key = routeparams.get("key");
		if(key == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, key is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String userId = routeparams.get("userId");
		if(userId == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, userId is null@" + TimeUtils.getSysLogTimeString());
			break;
		}

		//参数准备, 每个通道不同
		String packagecode = null;
		try{
			if(packageid.equals("yd.10M")){
				packagecode = "318";
			}else if(packageid.equals("yd.30M")){
				packagecode = "319";
			}else if(packageid.equals("yd.70M")){
				packagecode = "320";
			}else if(packageid.equals("yd.150M")){
				packagecode = "321";
			}else if(packageid.equals("yd.500M")){
				packagecode = "322";
			}else if(packageid.equals("yd.1G")){
				packagecode = "323";
			}else if(packageid.equals("yd.2G")){
				packagecode = "440";
			}else if(packageid.equals("yd.3G")){
				packagecode = "441";
			}
			
		}catch(Exception e){
			logger.warn(e.getMessage(), 0);
		}

		if(packagecode == null){
			request.setAttribute("result", "S." + routeid + ":unrecognized package@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String create_time = TimeUtils.getTimeStamp();
		String c = create_time + packagecode + phone + taskid + userId + key;
		String sign = MD5Util.getLowerMD5(c);
		HashMap<String, String> urlparm = new HashMap<String, String>();
		urlparm.put("userId", userId);
		urlparm.put("number", phone);
		urlparm.put("goods", packagecode);
		urlparm.put("order_no", taskid);
		urlparm.put("create_time", create_time);
		urlparm.put("sign", sign);

		//在执行请求前先获取连接, 防止访问通道线程超量
		Cache.getConnection(routeid);
		try{
			//ret = HttpAccess.postNameValuePairRequest(url, params, "utf-8", "mysend");
			//ret = HttpAccess.postJsonRequest(url, json.toString(), "utf-8", "weikesend");
			ret = HttpAccess.getNameValuePairRequest(mt_url, urlparm, "utf-8", "meirui");

		}catch(Exception e){
			e.printStackTrace();
			logger.info(e.getMessage());
		}finally{
			//在执行请求后记得释放连接
			Cache.releaseConnection(routeid);
		}

		//这里判断结果, 每个通道情况不同, 成功的保存 success 到 result 中并返回到 request.jsp
		if(ret != null && ret.trim().length() > 0){
			logger.info("meirui send ret = " + ret);
			try{
				Document doc = DocumentHelper.parseText(ret);
				String code =doc.getRootElement().elementText("code") ;
				String desc =doc.getRootElement().elementText("desc") ;
				if(code.equals("00")&&desc.equals("交易成功")){
					request.setAttribute("result", "success");
				}else{
					request.setAttribute("code", "-1");
					request.setAttribute("result", "R." + routeid + ":" + code + ":" + desc + "@" + TimeUtils.getSysLogTimeString());
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