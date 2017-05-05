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
		String username = routeparams.get("username");
		if(username == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, username is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String password = routeparams.get("password");
		if(password == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, password is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		
		//发送请求前先准备好参数
		String[] idarray = ids.split(",");
		JSONObject obj = new JSONObject();
		
		url = url + "/queryOrderInfo";
		JSONObject json = new JSONObject();
		
		for(int i = 0; i < idarray.length; i++){			
			String timestamp = TimeUtils.getTimeStamp();
			String echo = "" + new Random().nextInt(8888);
			
			String digest = MD5Util.getUpperMD5(username + MD5Util.getUpperMD5(password) + timestamp + echo);
			String month = "20" + idarray[i].substring(0, 4);
			String orderIds = idarray[i];
			
			HashMap<String, String> params = new LinkedHashMap<String, String>();
			params.put("username", username);
			params.put("timestamp", timestamp);
			params.put("echo", echo);
			params.put("digest", digest);
			params.put("month", month);
			params.put("orderIds", orderIds);
			logger.info("username = " + username + ", password = " + password + ", timestamp = " + timestamp + ", echo = " + 
			echo + ", digest = " + digest + ", month = " + month + ", orderIds = " + orderIds);
			//System.out.println("json = " + json.toString());
		
			//发送查询/获取状态前先获取连接, 防止访问线程超量
			Cache.getStatusConnection(routeid);
			try {
				//ret = HttpAccess.postNameValuePairRequest(url, params, "utf-8", "ltkuandai");
				ret = HttpAccess.postNameValuePairRequest(url, params, "utf-8", "jiaxun");
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
				logger.info("jiaxun status ret = " + ret);
				try {
					JSONObject retjson = JSONObject.fromObject(ret);
					String retCode = retjson.getString("status");
					if(retCode.equals("0")){
						JSONArray ary = retjson.getJSONArray("orderMessage");
						if(ary.size() > 0){
							JSONObject note = ary.getJSONObject(0);
							if(note.getString("status").equals("0") || note.getString("status").equals("-1")){
								//充值中
							}else if(note.getString("status").equals("1") && note.getString("result").equals("00000")){
								JSONObject rp = new JSONObject();
								rp.put("code", 0);
								rp.put("message", "success");
								rp.put("resp", note.toString());
								obj.put(idarray[i], rp);
							}else{
								JSONObject rp = new JSONObject();
								rp.put("code", note.getString("result"));
								rp.put("message", note.getString("desc"));
								rp.put("resp", ret);
								obj.put(idarray[i], rp);
							}
						}
					}
				} catch (Exception e) {
					logger.warn(e.getMessage(), e);
					logger.info("jiaxun status : " + e.getMessage() + ", ret = " + ret + "@" + TimeUtils.getSysLogTimeString());
				}
			} else {
				logger.info("jiaxun status : " + "fail@" + TimeUtils.getSysLogTimeString());
			}
		}
	
		request.setAttribute("retjson", obj.toString());
		request.setAttribute("result", "success");
		
		break;
	}
	
	request.getRequestDispatcher("request.jsp").forward(request,response);
%>