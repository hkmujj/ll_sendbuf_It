<%@page import="database.LLTempDatabase"%>
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
				org.apache.logging.log4j.Logger,
				com.aspire.portal.web.security.client.GenerateSignature,
				key.Key" 
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
		
		String url = routeparams.get("url");
		if(url == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, url is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String portaltype = routeparams.get("portaltype");
		if(portaltype == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, portaltype is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String portalid = routeparams.get("portalid");
		if(portalid == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, portalid is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String company_code = routeparams.get("company_code");
		if(company_code == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, company_code is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String activity_code = routeparams.get("activity_code");
		if(activity_code == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, activity_code is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String org_acct_no = routeparams.get("org_acct_no");
		if(org_acct_no == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, org_acct_no is null@" + TimeUtils.getSysLogTimeString());
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
			packageid = packageid.split("\\.")[1];
			packageid = packageid.substring(0, packageid.length() - 1);
		} catch (Exception e) {
			logger.warn(e.getMessage(), 0);
		}
		
		if(packageid.equals("10")){
			packagecode = "10001";
		}else if(packageid.equals("50")){
			packagecode = "10003";
		}else if(packageid.equals("100")){
			packagecode = "10004";
		}else if(packageid.equals("200")){
			packagecode = "10005";
		}
		
		if(packagecode == null){
			request.setAttribute("result", "S." + routeid + ":unrecognized package, packageid = " + packageid + "@" + TimeUtils.getSysLogTimeString());
			break;
		}
		
	LinkedHashMap<String, String> param = new LinkedHashMap<String, String>();
		param.put("portalType", portaltype);
		param.put("portalID", portalid);
		param.put("transactionID", taskid);
		param.put("method", "companyFlowPkgHandsel");
		String t = String.valueOf(System.currentTimeMillis());
		String timestamp = TimeUtils.getTimeStamp();
		String sequence = portaltype + portalid + timestamp + t.substring(t.length() - 6);
		param.put("sequence", sequence);
		param.put("company_code", company_code);
		if (activity_code.length() > 0) {
			param.put("activity_code", activity_code);
		}
		String oper_data_list = "{\"user_list\":[{\"msisdn\":\"" + phone + "\",\"product_id\":\"" + packagecode + "\",\"product_value\":\"" + packageid + "\"}]}";
		param.put("oper_data_list", oper_data_list);
		param.put("oper_time", timestamp);
		param.put("org_acct_no", org_acct_no);
		param.put("notify_url", returnurl);
		//param.put("signType", "MD5");

		StringBuffer sb = new StringBuffer();
		if (activity_code.length() > 0) {
			sb.append("activity_code=");
			sb.append(activity_code);
			sb.append("&");
		}
		sb.append("company_code=");
		sb.append(company_code);
		sb.append("&method=companyFlowPkgHandsel");
		sb.append("&notify_url=");
		sb.append(returnurl);
		sb.append("&oper_data_list=");
		sb.append(oper_data_list);
		sb.append("&oper_time=");
		sb.append(timestamp);
		sb.append("&org_acct_no=");
		sb.append(org_acct_no);
		sb.append("&portalID=");
		sb.append(portalid);
		sb.append("&portalType=");
		sb.append(portaltype);
		sb.append("&sequence=");
		sb.append(sequence);
		//sb.append("signType=MD5&");
		sb.append("&transactionID=");
		sb.append(taskid);
		
		//sb.append("B029AE4ECF812B1C0651FBB9228F65D4");
		
		//param.put("sign", MD5Util.getLowerMD5(sb.toString()));
		
		logger.info("zqydhongbao2 sb = "+ sb.toString());
		GenerateSignature gs = new GenerateSignature();
		String path = Key.keypath + "liulianghongbao/rasPrivateKey.txt";
		String sign = gs.sign(sb.toString(), path);
		logger.info("zqydhongbao2 sign string = " + sb.toString());
		logger.info("zqydhongbao2 path = " + path + ", sign = " + sign);
		
		param.put("sign", sign);
		
		//在执行请求前先获取连接, 防止访问通道线程超量
		Cache.getConnection(routeid);
		try {
			ret = HttpAccess.postNameValuePairRequest(url, param, "application/x-www-form-urlencoded", "utf-8", "www");
		} catch (Exception e) {
			e.printStackTrace();
			logger.info(e.getMessage());
		} finally {
			//在执行请求后记得释放连接
			Cache.releaseConnection(routeid);
		}
	
		//这里判断结果, 每个通道情况不同, 成功的保存 success 到 result 中并返回到 request.jsp
		if (ret != null && ret.trim().length() > 0) {
			logger.info("zqydhong bao liu liang send ret = " + ret);
			try {
				JSONObject retjson = JSONObject.fromObject(ret);
				 
				if(retjson.getString("status").equals("ok")){
					request.setAttribute("result", "success");
					LLTempDatabase.putMap("zqydhongbao", taskid, sequence+phone, "06");
				}else{
					String code =  retjson.getString("code");
					if(code == null){
						code = "1";
					}
					request.setAttribute("code", code);
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