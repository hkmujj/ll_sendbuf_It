<%@page import="util.MD5Util,
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
		String api_key = routeparams.get("api_key");
		if(api_key == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, api_key is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		
		//发送请求前先准备好参数
		String[] idarray = ids.split(",");
		JSONObject obj = new JSONObject();
		for(int i = 0; i < idarray.length; i++){
			JSONObject json = new JSONObject();
			json.put("cpUserName", account);
			json.put("orderId", idarray[i]);
			
			LinkedHashMap<String, String> header = new LinkedHashMap<String, String>();
			header.put("X-FDN-Auth", MD5Util.getLowerMD5(json.toString() + api_key));
					
			//发送查询/获取状态前先获取连接, 防止访问线程超量
			Cache.getStatusConnection(routeid);
			try {
				ret = HttpAccess.postJsonRequest(rpurl, json.toString(), "utf-8", header, "wangsureport");
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
				logger.info("aliday status ret = " + ret);
				try {
					JSONObject retjson = JSONObject.fromObject(ret);
					String code = retjson.getJSONObject("responseData").getString("resultCode");
					if(code.equals("10100")){
						JSONObject rp = new JSONObject();
						rp.put("code", 0);
						rp.put("message", "success");
						rp.put("resp", ret);
						obj.put(idarray[i], rp);
					}else if(code.equals("20407")){
						logger.info("wangsu status : [" + idarray[i] + "]充值中@" + TimeUtils.getSysLogTimeString());
					}else{
						JSONObject rp = new JSONObject();
						rp.put("code", 1);
						rp.put("message", retjson.getJSONObject("responseData").getString("resultCode"));
						rp.put("resp", ret);
						obj.put(idarray[i], rp);
					}
				} catch (Exception e) {
					//e.printStackTrace();
					logger.warn(e.getMessage(), e);
					//logger.info(e.getMessage());
					//request.setAttribute("result", "R." + routeid + ":" + e.getMessage() + "@" + TimeUtils.getSysLogTimeString());
					//obj.put(idarray[i], "R." + routeid + ":" + e.getMessage() + "@" + TimeUtils.getSysLogTimeString());
					
					//JSONObject rp = new JSONObject();
					//rp.put("code", 1);
					//rp.put("message", "R." + routeid + ":" + e.getMessage() + "@" + TimeUtils.getSysLogTimeString());
					//rp.put("resp", ret);
					//obj.put(idarray[i], rp);
					
					logger.info("wangsu status : " + e.getMessage() + ", ret = " + ret + "@" + TimeUtils.getSysLogTimeString());
				}
			} else {
				//obj.put(idarray[i], "R." + routeid + ":" + "fail@" + TimeUtils.getSysLogTimeString());
				
				//JSONObject rp = new JSONObject();
				//rp.put("code", 1);
				//rp.put("message", "R." + routeid + ":" + "fail@" + TimeUtils.getSysLogTimeString());
				//rp.put("resp", ret);
				//obj.put(idarray[i], rp);
				logger.info("alidayu status : " + "fail@" + TimeUtils.getSysLogTimeString());
			}
		}
	
		request.setAttribute("retjson", obj.toString());
		request.setAttribute("result", "success");
		
		break;
	}
	
	request.getRequestDispatcher("request.jsp").forward(request,response);
	//Log.logout("String = " + str, 0);
	//out.print((new MsgBufQuerier()).jsonRpc(str));
	//out.print("hello");
%>