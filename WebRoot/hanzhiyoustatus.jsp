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
		String merchId = routeparams.get("merchId");
		if(merchId == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, merchId is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String key = routeparams.get("key");
		if(key == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, key is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		
		//发送请求前先准备好参数
		String[] idarray = ids.split(",");
		JSONObject obj = new JSONObject();
		
		url = url + "/mobileBBC/bbc/queryOrder.action";
		JSONObject json = new JSONObject();
		
		for(int i = 0; i < idarray.length; i++){
			String orderId = idarray[i];
			String settleDate = TimeUtils.getTimeStamp();
			
			json.put("merchId", merchId);
			json.put("orderId", orderId);
			json.put("settleDate", settleDate);
			String sign = MD5Util.getUpperMD5(merchId + orderId + settleDate + key);
			json.put("sign", sign);
			
			Map<String, String> param = new HashMap<String, String>();
			param.put("json", json.toString());
			//System.out.println("json = " + json.toString());
		
			//发送查询/获取状态前先获取连接, 防止访问线程超量
			Cache.getStatusConnection(routeid);
			try {
				//ret = HttpAccess.postNameValuePairRequest(url, params, "utf-8", "ltkuandai");
				ret = URLDecoder.decode(HttpAccess.postNameValuePairRequest(url, param, "utf-8", "hanzhiyou"), "utf-8");
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
				logger.info("hanzhiyou status ret = " + ret);
				try {
					JSONObject retjson = JSONObject.fromObject(ret);
					String retCode = retjson.getString("retCode");
					Object objc = retjson.get("status");
					String code = "888";
					if(objc != null){
						code = retjson.getString("status");
					}
					String message = retjson.getString("msg");
					if(retCode.equals("MOB00001") && code.equals("00")){
						JSONObject rp = new JSONObject();
						rp.put("code", 0);
						rp.put("message", "success");
						rp.put("resp", ret);
						obj.put(idarray[i], rp);
					}else if(code.equals("90")){
						logger.info("hanzhiyou status : [" + idarray[i] + "]充值中@" + TimeUtils.getSysLogTimeString());
					}else if(code.equals("01")){
						JSONObject rp = new JSONObject();
						rp.put("code", code);
						if(message.equals("成功")){
							message = "失败";
						}
						rp.put("message", message);
						rp.put("resp", ret);
						obj.put(idarray[i], rp);
					}else{
						logger.info("hanzhiyou status : [" + idarray[i] + "]状态码" + code + ":" + message + "@" + TimeUtils.getSysLogTimeString());
					}
				} catch (Exception e) {
					logger.warn(e.getMessage(), e);
					logger.info("hanzhiyou status : " + e.getMessage() + ", ret = " + ret + "@" + TimeUtils.getSysLogTimeString());
				}
			} else {
				logger.info("hanzhiyou status : " + "fail@" + TimeUtils.getSysLogTimeString());
			}
		}
	
		request.setAttribute("retjson", obj.toString());
		request.setAttribute("result", "success");
		
		break;
	}
	
	request.getRequestDispatcher("request.jsp").forward(request,response);
%>