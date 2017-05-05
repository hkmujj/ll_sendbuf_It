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
		
		String mturl = routeparams.get("mturl");
		if(mturl == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, mturl is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String username = routeparams.get("username");
		if(username == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, username is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String key = routeparams.get("key");
		if(key == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, key is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String returnurl = routeparams.get("returnurl");
		if(returnurl == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, returnurl is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		//参数准备, 每个通道不同
		
		String packagecode = null;
		try{
			packagecode = packageid.split("\\.")[1];
		} catch (Exception e) {
			logger.warn(e.getMessage(), 0);
		}
		
		if(packagecode == null){
			request.setAttribute("result", "S." + routeid + ":unrecognized package@" + TimeUtils.getSysLogTimeString());
			break;
		}
		
		long t = System.currentTimeMillis();
		
		JSONObject json = new JSONObject();
		json.put("username", username);
		json.put("timestamp", t);
		json.put("tradeNo", taskid);
		json.put("mobiles", phone);
		json.put("spec", packagecode);
		json.put("areaType", "c");
		json.put("effectiveType", "tm");
		json.put("url", returnurl);
		json.put("signature", MD5Util.getLowerMD5(String.valueOf(t) + taskid + phone + packagecode + returnurl + key));
		
		//在执行请求前先获取连接, 防止访问通道线程超量
		Cache.getConnection(routeid);
		try {
			ret = HttpAccess.postJsonRequest(mturl, json.toString(), "utf-8", "maiersisend");
		} catch (Exception e) {
			e.printStackTrace();
			logger.info(e.getMessage());
		} finally {
			//在执行请求后记得释放连接
			Cache.releaseConnection(routeid);
		}
	
		//这里判断结果, 每个通道情况不同, 成功的保存 success 到 result 中并返回到 request.jsp
		if (ret != null && ret.trim().length() > 0) {
			logger.info("maiersi send ret = " + ret);
			try {
				JSONObject retjson = JSONObject.fromObject(ret);
				if(retjson.getBoolean("ok")){
					if(retjson.getJSONArray("object").size() <= 0){
						request.setAttribute("result", "success");
					}else{
						request.setAttribute("result", "R." + routeid + ":" + retjson.getJSONArray("object").getJSONObject(0).getString("message") + "@" + TimeUtils.getSysLogTimeString());
					}
				}else{
					request.setAttribute("code", retjson.getString("code"));
					request.setAttribute("result", "R." + routeid + ":" + retjson.getString("message") + "@" + TimeUtils.getSysLogTimeString());
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
	//Log.logout("String = " + str, 0);
	//out.print((new MsgBufQuerier()).jsonRpc(str));
	//out.print("hello");
%>