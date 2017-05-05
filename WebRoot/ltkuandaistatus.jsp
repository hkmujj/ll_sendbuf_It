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
		String appkey = routeparams.get("appkey");
		if(appkey == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, appkey is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String appsecret = routeparams.get("appsecret");
		if(appsecret == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, appsecret is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		
		//发送请求前先准备好参数
		String[] idarray = ids.split(",");
		JSONObject obj = new JSONObject();
		for(int i = 0; i < idarray.length; i++){
			String action = "queryOrder";
			String timeStamp = TimeUtils.getTimeStamp();
			
			StringBuffer sb = new StringBuffer();
			sb.append("action");
			sb.append(action);
			sb.append("appKey");
			sb.append(appkey);
			sb.append("orderId");
			sb.append(idarray[i]);
			sb.append("timeStamp");
			sb.append(timeStamp);
			String sign = SHA1.sha1Encode(appsecret + sb.toString() + appsecret);
			
			System.out.println("sign = " + sign);
			
			Map<String, String> params = new HashMap<String, String>();
			params.put("action", action);
			params.put("appKey", appkey);
			params.put("orderId", idarray[i]);
			params.put("timeStamp", timeStamp);
			params.put("sign", sign);
		
			//发送查询/获取状态前先获取连接, 防止访问线程超量
			Cache.getStatusConnection(routeid);
			try {
				ret = HttpAccess.postNameValuePairRequest(url, params, "utf-8", "ltkuandai");
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
				logger.info("ltkuandai status ret = " + ret);
				try {
					JSONObject retjson = JSONObject.fromObject(ret);
					String code = retjson.getString("respCode");
					if(code.equals("0000")){
						JSONObject rp = new JSONObject();
						rp.put("code", 0);
						rp.put("message", "success");
						rp.put("resp", ret);
						obj.put(idarray[i], rp);
					}else if(code.equals("0001")){
						logger.info("ltkuandai status : [" + idarray[i] + "]充值中@" + TimeUtils.getSysLogTimeString());
					}else{
						JSONObject rp = new JSONObject();
						rp.put("code", code);
						rp.put("message", code);
						rp.put("resp", ret);
						obj.put(idarray[i], rp);
					}
				} catch (Exception e) {
					logger.warn(e.getMessage(), e);
					logger.info("ltkuandai status : " + e.getMessage() + ", ret = " + ret + "@" + TimeUtils.getSysLogTimeString());
				}
			} else {
				logger.info("ltkuandai status : " + "fail@" + TimeUtils.getSysLogTimeString());
			}
		}
	
		request.setAttribute("retjson", obj.toString());
		request.setAttribute("result", "success");
		
		break;
	}
	
	request.getRequestDispatcher("request.jsp").forward(request,response);
%>