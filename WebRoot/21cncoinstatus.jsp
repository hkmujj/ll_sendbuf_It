<%@page import="database.LLTempDatabase,
				util.SHA1,
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
		
		//发送请求前先准备好参数
		String[] idarray = ids.split(",");
		JSONObject obj = new JSONObject();
		
		for(int i = 0; i < idarray.length; i++){
			String orderId = idarray[i];
			String url = LLTempDatabase.getMapValue("21cncoin", orderId, "04");
			
			//发送查询/获取状态前先获取连接, 防止访问线程超量
			Cache.getStatusConnection(routeid);
			try {
				//ret = HttpAccess.postNameValuePairRequest(url, params, "utf-8", "ltkuandai");
				ret = HttpAccess.postNameValuePairRequest(url, new HashMap<String, String>(), "utf-8", "21cncoinstatus.jsp");
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
				logger.info("21cncoin status ret = " + ret);
				try {
					JSONObject retjson = JSONObject.fromObject(ret);
					String objc = retjson.getString("status");
					if(objc.equals("0")){
						JSONObject rp = new JSONObject();
						rp.put("code", 0);
						rp.put("message", "success");
						rp.put("resp", ret);
						obj.put(idarray[i], rp);
					}else if(objc.equals("1")){
						logger.info("21cncoin status : [" + idarray[i] + "]充值中@" + TimeUtils.getSysLogTimeString());
					}else{
						JSONObject rp = new JSONObject();
						rp.put("code", objc);
						String message = "失败";
						if(retjson.get("msg") != null){
							message = retjson.getString("msg");
						}
						if(retjson.get("statusDesc") != null){
							message = retjson.getString("statusDesc");
						}
						rp.put("message", message);
						rp.put("resp", ret);
						obj.put(idarray[i], rp);
					}
				} catch (Exception e) {
					logger.warn(e.getMessage(), e);
					logger.info("21cncoin status : " + e.getMessage() + ", ret = " + ret + "@" + TimeUtils.getSysLogTimeString());
				}
			} else {
				logger.info("21cncoin status : " + "fail@" + TimeUtils.getSysLogTimeString());
			}
		}
	
		request.setAttribute("retjson", obj.toString());
		request.setAttribute("result", "success");
		
		break;
	}
	
	request.getRequestDispatcher("request.jsp").forward(request,response);
%>