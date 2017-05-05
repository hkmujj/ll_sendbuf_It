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
		String account = routeparams.get("account");
		if(account == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, account is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String password = routeparams.get("password");
		if(password == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, password is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		
		LinkedHashMap<String, String> params = new LinkedHashMap<String, String>();
	
		params.put("v", "1.0");
		params.put("Action", "getReports");
		params.put("Account", account);
		params.put("Password", password);
		params.put("Count", "100");
		
		JSONObject obj = new JSONObject();
		
		Cache.getStatusConnection(routeid);
		try {
			ret = HttpAccess.postNameValuePairRequest(url, params, "utf-8", "mystatus");
		} catch (Exception e) {
			e.printStackTrace();
			logger.info(e.getMessage());
		} finally {
			Cache.releaseStatusConnection(routeid);
		}

		//这里判断结果, 每个通道情况不同, 成功的保存 success 到 result 中并返回到 request.jsp
		if (ret != null && ret.trim().length() > 0) {
			logger.info("my status ret = " + ret);
			try {
				JSONObject retjson = JSONObject.fromObject(ret);
				String code = retjson.getString("Code");
				String message = retjson.getString("Message");
				if(code.equals("0")){
					JSONArray array = retjson.getJSONArray("Reports");
					for(int i = 0; i < array.size(); i++){
						JSONObject sobj = array.getJSONObject(i);
						JSONObject vobj = JSONObject.fromObject(sobj.toString().replaceAll("\\\\u", "\\u"));
						if(sobj.getString("Status").equals("4")){
							//成功
							JSONObject rp = new JSONObject();
							rp.put("code", 0);
							rp.put("message", "success");
							rp.put("resp", vobj.getString("ReportCode"));
							obj.put(sobj.getString("TaskID"), rp);
						}else if(sobj.getString("Status").equals("5")){
							//失败
							JSONObject rp = new JSONObject();
							rp.put("code", 1);
							String reportcode = vobj.getString("ReportCode");
							if(reportcode.length() > 200){
								reportcode = reportcode.substring(0, 160);
							}
							rp.put("message", "充值失败");
							rp.put("resp", reportcode);
							obj.put(sobj.getString("TaskID"), rp);
						}
					}
				}
				request.setAttribute("orgreturn", ret);
			} catch (Exception e) {
				e.printStackTrace();
				//logger.info(e.getMessage());
				logger.info("result", "R." + routeid + ":" + e.getMessage() + "@" + TimeUtils.getSysLogTimeString());
				//request.setAttribute("result", "R." + routeid + ":" + e.getMessage() + "@" + TimeUtils.getSysLogTimeString());
			}
		} else {
			//request.setAttribute("result", "R." + routeid + ":fail@" + TimeUtils.getSysLogTimeString());
			logger.info("result", "R." + routeid + ":fail@" + TimeUtils.getSysLogTimeString());
		}
	
		request.setAttribute("result", "success");
		request.setAttribute("retjson", obj.toString());
		
		break;
	}
	
	request.getRequestDispatcher("request.jsp").forward(request,response);
	//Log.logout("String = " + str, 0);
	//out.print((new MsgBufQuerier()).jsonRpc(str));
	//out.print("hello");
%>