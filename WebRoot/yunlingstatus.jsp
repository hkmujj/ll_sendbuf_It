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
		
		String rpurl = routeparams.get("rpurl");
		if(rpurl == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, rpurl is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String account = routeparams.get("account");
		if(account == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, account is null@" + TimeUtils.getSysLogTimeString());
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
		JSONObject json = new JSONObject();
		
		for(int i = 0; i < idarray.length; i++){
			String orderId = idarray[i];
			String settleDate = TimeUtils.getTimeStamp();
			json.put("account", account);
			json.put("query_code", orderId);
			String sign = "account" + account + "query_code" + orderId + "key" + key;
			json.put("sign", sign);
			//发送查询/获取状态前先获取连接, 防止访问线程超量
			Cache.getStatusConnection(routeid);
			try {
				//ret = HttpAccess.postNameValuePairRequest(url, params, "utf-8", "ltkuandai");
				//ret = URLDecoder.decode(HttpAccess.postNameValuePairRequest(url, param, "utf-8", "hanzhiyou"), "utf-8");
				  ret = HttpAccess.postJsonRequest(rpurl, json.toString(), "utf-8", "yunlingstatus");
			} catch (Exception e) {
				e.printStackTrace();
				logger.error(e.getMessage(),e);
			} finally {
				//发送查询/获取状态后释放连接
				Cache.releaseStatusConnection(routeid);
			}
			
			//这里判断结果, 每个通道情况不同, 成功的节点ID对应success, 失败的对应失败信息
			if (ret != null && ret.trim().length() > 0) {
				//request.setAttribute("result", "success");
				logger.info("yunling status ret = " + ret);
				try {
					JSONObject retjson = JSONObject.fromObject(ret);
					String retCode = retjson.getString("err_code");
					String retMsg = retjson.getString("err_msg");
					String statusCode = retjson.getString("status");
					String message = retjson.getString("reply_msg");
					if(retCode.equals("0") && statusCode.equals("3")){
						JSONObject rp = new JSONObject();
						rp.put("code", 0);
						rp.put("message", "success");
						rp.put("resp", ret);
						obj.put(idarray[i], rp);
					}else if(retCode.equals("0") && statusCode.equals("1")){
						logger.info("yunling status : [" + idarray[i] + "]充值中@" + TimeUtils.getSysLogTimeString());
					}else if(retCode.equals("0") && statusCode.equals("0")){
						logger.info("yunling status : [" + idarray[i] + "]等待处理@" + TimeUtils.getSysLogTimeString());
					}else if(retCode.equals("0") && statusCode.equals("2")){
						JSONObject rp = new JSONObject();
						rp.put("code", "2");
						rp.put("message", message);
						rp.put("resp", ret);
						obj.put(idarray[i], rp);
						logger.info("yunling status : [" + idarray[i] + "]状态码" + statusCode + ":" + message + "@" + TimeUtils.getSysLogTimeString());
					}else if(!retCode.equals(0)){
						/*
						JSONObject rp = new JSONObject();
						rp.put("code", retCode);
						rp.put("message", retMsg);
						rp.put("resp", ret);
						obj.put(idarray[i], rp);
						*/
						logger.info("yunling status : [" + idarray[i] + "]状态码" + retCode + ":" + retMsg + "@" + TimeUtils.getSysLogTimeString());
					}
					
				} catch (Exception e) {
					logger.warn(e.getMessage(), e);
					logger.info("yunling status : " + e.getMessage() + ", ret = " + ret + "@" + TimeUtils.getSysLogTimeString());
				}
			} else {
				logger.info("yunling status : " + "fail@" + TimeUtils.getSysLogTimeString());
			}
		}
	
		request.setAttribute("retjson", obj.toString());
		request.setAttribute("result", "success");
		
		break;
	}
	
	request.getRequestDispatcher("request.jsp").forward(request,response);
%>