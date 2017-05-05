<%@page import="util.SHA1,
				util.MD5Util,
				net.sf.json.JSONArray,
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
	
	while(true){
		String ret = null;
		
		//获取公共参数
		String routeid = request.getAttribute("routeid").toString();
		
		Object idsobj = request.getAttribute("ids");
		if(idsobj == null){
			request.setAttribute("result", "S." + routeid + ":ids are needed to get status@" + TimeUtils.getSysLogTimeString());
			break;
		}
		
		String ids = idsobj.toString(); 
		
		logger.info("ids = " + ids + ", routeid = " + routeid);
		
		//获取通道能数, 每个通道不同
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
		
		//发送请求前先准备好参数
		String[] idarray = ids.split(",");
		JSONObject obj = new JSONObject();
		for(int i = 0; i < idarray.length; i++){
			url = url + "?action=api_order_traffic_query&";
			String timestamp = String.valueOf(System.currentTimeMillis());
			String app_sign = MD5Util.getUpperMD5(app_key + app_secret + agent_id + timestamp);
			
			String order_agent_bill = idarray[i];
			
			String str = "app_key=" + app_key + "&order_agent_bill=" + order_agent_bill + "&timestamp="
				 + timestamp + "&agent_id=" + agent_id + "&app_sign=" + app_sign;
		
			url = url + str;
		
			//发送查询/获取状态前先获取连接, 防止访问线程超量
			Cache.getStatusConnection(routeid);
			try {
				//ret = HttpAccess.postNameValuePairRequest(url, params, "utf-8", "ltkuandai");
				ret = HttpAccess.postEntity(url, "", "", "utf-8", "weicheng");
			} catch (Exception e) {
				e.printStackTrace();
				logger.info(e.getMessage());
			} finally {
				//发送查询/获取状态后释放连接
				Cache.releaseStatusConnection(routeid);
			}
			
			//这里判断结果, 每个通道情况不同, 成功的节点ID对应success, 失败的对应失败信息
			if (ret != null && ret.trim().length() > 0) {
				//request.setAttribute("result", "success");
				logger.info("weicheng status ret = " + ret);
				try {
					JSONObject retjson = JSONObject.fromObject(ret);
					String code = retjson.getString("code");
					if(code.equals("0000")){
						JSONObject note = retjson.getJSONObject("object");
						if("1".equals(note.getString("order_status"))){
							JSONObject rp = new JSONObject();
							rp.put("code", 0);
							rp.put("message", "success");
							rp.put("resp", ret);
							obj.put(idarray[i], rp);
						}else if("2".equals(note.getString("order_status"))){
							JSONObject rp = new JSONObject();
							rp.put("code", note.getString("order_system_code"));
							rp.put("message", note.getString("order_system_msg"));
							rp.put("resp", note.toString());
							obj.put(idarray[i], rp);
						}
					}else{
						logger.warn("weicheng status : " + ", message = " + code + "." + retjson.getString("msg") + "@" + TimeUtils.getSysLogTimeString());
					}
				} catch (Exception e) {
					logger.warn(e.getMessage(), e);
					logger.info("weicheng status : " + e.getMessage() + ", ret = " + ret + "@" + TimeUtils.getSysLogTimeString());
				}
			} else {
				logger.info("weicheng status : " + "fail@" + TimeUtils.getSysLogTimeString());
			}
		}
	
		request.setAttribute("retjson", obj.toString());
		request.setAttribute("result", "success");
		
		break;
	}
	
	request.getRequestDispatcher("request.jsp").forward(request,response);
%>