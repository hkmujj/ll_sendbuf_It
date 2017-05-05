<%@page import="util.AES,
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
	String userid = request.getAttribute("userid").toString();
	
	logger.warn("dianxingufen XX userid=" + userid);
	
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
		String service_code = routeparams.get("service_code");
		if(service_code == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, service_code is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String contract_id = routeparams.get("contract_id");
		if(contract_id == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, contract_id is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String activity_id = routeparams.get("activity_id");
		if(activity_id == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, activity_id is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String order_type = routeparams.get("order_type");
		if(order_type == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, order_type is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String effect_type = routeparams.get("effect_type");
		if(effect_type == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, effect_type is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String partner_no = routeparams.get("partner_no");
		if(partner_no == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, partner_no is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String aespassword = routeparams.get("aespassword");
		if(aespassword == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, aespassword is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String aesvector = routeparams.get("aesvector");
		if(aesvector == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, aesvector is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		
		//参数准备, 每个通道不同
		String packagecode = null;
		try{
			packageid = packageid.split("\\.")[1];
		} catch (Exception e) {
			logger.warn(e.getMessage(), e);
		}
		if(routeid.equals("3006")){
			if(packageid.equals("5M")){
				packagecode = "104365";
			}else if(packageid.equals("10M")){
				packagecode = "104366";
			}else if(packageid.equals("30M")){
				packagecode = "104367";
			}else if(packageid.equals("50M")){
				packagecode = "104368";
			}else if(packageid.equals("100M")){
				packagecode = "104369";
			}else if(packageid.equals("200M")){
				packagecode = "104370";
			}else if(packageid.equals("500M")){
				packagecode = "104371";
			}else if(packageid.equals("1G")){
				packagecode = "104372";
			}
		}else if(routeid.equals("3026")){
			if(packageid.equals("1G")){
				packagecode = "104683";
			}
		}else if(routeid.equals("3025")){
			if(packageid.equals("1G")){
				packagecode = "104682";
			}
		}
		
		if(packagecode == null){
			request.setAttribute("result", "S." + routeid + ":unrecognized package@" + TimeUtils.getSysLogTimeString());
			break;
		}
		
		if(userid != null){
			if(userid.equals("10272")){
				activity_id = "104993";
			}else if(userid.equals("10275")){
				activity_id = "104992";
			}else if(userid.equals("10268")){
				activity_id = "104989";
			}else if(userid.equals("10332")){
				activity_id = "104988";
			}else if(userid.equals("10311")){
				activity_id = "104987";
			}else if(userid.equals("10469")){
				activity_id = "105032";
			}else if(userid.equals("10276")){
				activity_id = "105055";
			}else if(userid.equals("10480")){
				activity_id = "105066";
			}else if(userid.equals("10155")){
				activity_id = "105177";
			}else if(userid.equals("10119")){
				activity_id = "104994";
			}else if(userid.equals("10587")){
				activity_id = "105387";
			}//else if(userid.equals("10238")){activity_id = "105054";}
		}
		
		JSONObject jsonParam = new JSONObject();  
		jsonParam.put("request_no", taskid);
		jsonParam.put("service_code", service_code);
		jsonParam.put("contract_id", contract_id);
		jsonParam.put("activity_id", activity_id);
		jsonParam.put("phone_id", phone);
		jsonParam.put("order_type", order_type);
		jsonParam.put("plat_offer_id", packagecode);
		jsonParam.put("effect_type", effect_type);

		String param = AES.aesEncode(jsonParam.toString(), aespassword, aesvector);
		
		JSONObject json = new JSONObject();
		json.put("partner_no", partner_no);
		json.put("code", param);
		
		logger.info("dianxingufen send json = " + json.toString());
		
		//在执行请求前先获取连接, 防止访问通道线程超量
		Cache.getConnection(routeid);
		try {
			//ret = HttpAccess.postNameValuePairRequest(url, params, "utf-8", "mysend");
			ret = HttpAccess.postJsonRequest(url, json.toString(), "utf-8", "dianxingufen");
		} catch (Exception e) {
			e.printStackTrace();
			logger.info(e.getMessage());
		} finally {
			//在执行请求后记得释放连接
			Cache.releaseConnection(routeid);
		}
	
		//这里判断结果, 每个通道情况不同, 成功的保存 success 到 result 中并返回到 request.jsp
		if (ret != null && ret.trim().length() > 0) {
			logger.info("dianxingufen send ret = " + ret);
			try {
				JSONObject retjson = JSONObject.fromObject(ret);
				String code = retjson.getString("result_code");
				if(code.equals("00000")){
					request.setAttribute("result", "success");
				}else{
					request.setAttribute("code", code);
					request.setAttribute("result", "R." + routeid + ":" + code + "@" + TimeUtils.getSysLogTimeString());
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