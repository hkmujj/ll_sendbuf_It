<%@page
	import="util.SHA1,
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
	language="java" pageEncoding="UTF-8"%>
<%
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
		String secretkey = routeparams.get("secretkey");
		if(secretkey == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, secretkey is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String business_id = routeparams.get("business_id");
		if(business_id == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, business_id is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String methodstatus = routeparams.get("methodstatus");
		if(methodstatus == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, methodstatus is null@" + TimeUtils.getSysLogTimeString());
			break;
		}

		//发送请求前先准备好参数
		String[] idarray = ids.split(",");
		JSONObject obj = new JSONObject();

		for(int i = 0; i < idarray.length; i++){
			String timestamp = TimeUtils.getTimeStamp();
			JSONObject json = new JSONObject();
			json.put("trans_no", idarray[i]);

			String befsign = secretkey + "business_id" + business_id + "method" + methodstatus + "timestamp" + timestamp + json.toString() + secretkey;
			System.out.println("befsign = " + befsign);
			String sign = MD5Util.getUpperMD5(befsign);
			System.out.println("sign = " + sign);

			String statusurl = url + "?business_id=" + business_id + "&method=" + methodstatus + "&timestamp=" + timestamp + "&sign=" + sign;

			//发送查询/获取状态前先获取连接, 防止访问线程超量
			Cache.getStatusConnection(routeid);
			try{
				ret = HttpAccess.postJsonRequest(statusurl, json.toString(), "utf-8", "erheistatus");
			}catch(Exception e){
				e.printStackTrace();
				logger.info(e.getMessage());
			}finally{
				//发送查询/获取状态后释放连接
				Cache.releaseStatusConnection(routeid);
			}

			//这里判断结果, 每个通道情况不同, 成功的节点ID对应success, 失败的对应失败信息
			if(ret != null && ret.trim().length() > 0){
				//request.setAttribute("result", "success");
				logger.info("erhei status ret = " + ret);
				try{
					JSONObject retjson = JSONObject.fromObject(ret);
					String status = retjson.getString("status");
					String message = retjson.getString("message");
					if(status.equals("0")){
						JSONObject datajson = retjson.getJSONObject("data");
						String retCode = datajson.getString("order_status");
						if(retCode.equals("0")){
							JSONObject rp = new JSONObject();
							rp.put("code", 0);
							rp.put("message", "success");
							rp.put("resp", ret);
							obj.put(idarray[i], rp);
						}else if(retCode.equals("1")){
							logger.info("erhei status : [" + idarray[i] + "]充值中" + TimeUtils.getSysLogTimeString());
						}else{
							JSONObject rp = new JSONObject();
							rp.put("code", retCode);
							rp.put("message", datajson.getString("order_message"));
							rp.put("resp", ret);
							obj.put(idarray[i], rp);
						}
					}else{
						logger.info("erhei status : [" + idarray[i] + "]充值中@message=" + message + "@" + TimeUtils.getSysLogTimeString());
					}
				}catch(Exception e){
					logger.warn(e.getMessage(), e);
					logger.info("erhei status : " + e.getMessage() + ", ret = " + ret + "@" + TimeUtils.getSysLogTimeString());
				}
			}else{
				logger.info("erhei status : " + "fail@" + TimeUtils.getSysLogTimeString());
			}
		}

		request.setAttribute("retjson", obj.toString());
		request.setAttribute("result", "success");

		break;
	}

	request.getRequestDispatcher("request.jsp").forward(request, response);
%>