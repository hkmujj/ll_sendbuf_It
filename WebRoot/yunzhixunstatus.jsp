<%@page import="database.LLTempDatabase"%>
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
		String mark = "yunzhixun";
		
		LinkedHashMap<String, String> params = new LinkedHashMap<String, String>();
	
		params.put("V", "1.1");
		params.put("Action", "getReports");
		params.put("Account", account);
		//params.put("Password", password);
		params.put("Count", "100");
		
		String sign = MD5Util.getLowerMD5("account=" + account + "&count=100&key=" + password);
		params.put("Sign", sign);
		
		//JSONObject obj = new JSONObject();
		
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
			logger.info("yunzhixun status ret = " + ret);
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
							//String mark = routeid;
							String taskid = sobj.getString("TaskID");
							String status = "0";
							String info = "success";
							LLTempDatabase.addReport(mark, taskid, status, info, "03");
							
						}else if(sobj.getString("Status").equals("5")){
							//失败							
							String reportcode = vobj.getString("ReportCode");
							if(reportcode.length() > 64){
								reportcode = reportcode.substring(0, 64);
							}
							//String mark = routeid;
							String taskid = sobj.getString("TaskID");
							String status = "1";
							String info = reportcode;
							LLTempDatabase.addReport(mark, taskid, status, info, "03");
						}
					}
				}
				//request.setAttribute("orgreturn", ret);
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
	
		Object idsobj = request.getAttribute("ids");
		if(idsobj == null){
			request.setAttribute("result", "S." + routeid + ":ids are needed to get status@" + TimeUtils.getSysLogTimeString());
			break;
		}
		
		String ids = idsobj.toString(); 
		
		logger.info("ids = " + ids + ", routeid = " + routeid);
		
		//发送请求前先准备好参数
		String[] idarray = ids.split(",");
		JSONObject obj = new JSONObject();
		
		LLTempDatabase.getStatus(mark, idarray, obj, "03");
	
		logger.info("yunzhixun[" + routeid +"] retjson = " + obj.toString());
		
		request.setAttribute("retjson", obj.toString());
		request.setAttribute("result", "success");
		
		break;
	}
	
	request.getRequestDispatcher("request.jsp").forward(request,response);
	//Log.logout("String = " + str, 0);
	//out.print((new MsgBufQuerier()).jsonRpc(str));
	//out.print("hello");
%>