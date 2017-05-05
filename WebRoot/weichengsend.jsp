<%@page import="java.net.URLEncoder,
				util.MD5Util,
				util.SHA1,
				util.AES,
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
		
		String url = routeparams.get("url");
		if(url == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, url is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String agent_id = routeparams.get("agent_id");
		if(agent_id == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, agent_id is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String app_key = routeparams.get("app_key");
		if(app_key == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, app_key is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String app_secret = routeparams.get("app_secret");
		if(app_secret == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, app_secret is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String order_agent_back_url = routeparams.get("order_agent_back_url");
		if(order_agent_back_url == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, order_agent_back_url is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		
		//参数准备, 每个通道不同
		String packagecode = null;
		
		try{
			//yd.10M    yd.6G
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
		
		//url = "http://120.24.173.64:7001/index.do";
		url = url + "?action=api_order_traffic_submit&";
		String order_agent_bill = taskid;
		String timestamp = String.valueOf(System.currentTimeMillis());
		String order_agent_id = agent_id;
		String app_sign = MD5Util.getUpperMD5(app_key + app_secret + order_agent_id + timestamp+ order_agent_bill);
		
		String order_tel = phone;
		String traffic_size = packagecode;
		
		order_agent_back_url = URLEncoder.encode(order_agent_back_url, "utf-8");
		
		String str = "app_key=" + app_key + "&order_agent_bill=" + order_agent_bill + "&timestamp="
			 + timestamp + "&order_agent_id=" + order_agent_id + "&app_sign=" + app_sign + "&order_agent_back_url="
			  + order_agent_back_url + "&order_tel=" + order_tel + "&traffic_size=" + traffic_size;
	
		url = url + str;
		
		//在执行请求前先获取连接, 防止访问通道线程超量
		Cache.getConnection(routeid);
		try {
			//ret = HttpAccess.postNameValuePairRequest(url, params, "utf-8", "mysend");
			//ret = HttpAccess.postNameValuePairRequest(url, params, "utf-8", "ltkuandai");
			ret = HttpAccess.postEntity(url, "", "", "utf-8", "weicheng");
		} catch (Exception e) {
			e.printStackTrace();
			logger.info(e.getMessage());
		} finally {
			//在执行请求后记得释放连接
			Cache.releaseConnection(routeid);
		}
	
		//这里判断结果, 每个通道情况不同, 成功的保存 success 到 result 中并返回到 request.jsp
		if (ret != null && ret.trim().length() > 0) {
			logger.info("weicheng send ret = " + ret);
			try {
				JSONObject retjson = JSONObject.fromObject(ret);
				String code = retjson.getString("code");
				if(code.equals("0000")){
					request.setAttribute("result", "success");
					request.setAttribute("reportid", taskid);
				}else{
					request.setAttribute("code", code);
					request.setAttribute("result", "R." + routeid + ":" + code + "." + retjson.getString("msg") + "@" + TimeUtils.getSysLogTimeString());
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