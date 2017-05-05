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
	
	while(true){
		String ret = null;
		
		//检查通道参数, 每个通道有不同参数, 对应 ll_routes.api_params
		Map<String, String> routeparams = Cache.getRouteParams(routeid);
		if(routeparams == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams@" + TimeUtils.getSysLogTimeString());
			break;
		}
		
		String mturl = routeparams.get("mturl");
		if(mturl == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, mturl is null@" + TimeUtils.getSysLogTimeString());
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
		//参数准备, 每个通道不同
		
		String packagecode = null;
		if(packageid.equals("yd.10M")){
			packagecode = "YD_e526aa86940340a6b95c747cace2909a";
		}else if(packageid.equals("yd.30M")){
			packagecode = "YD_b74ab7284e734597bb7af96b396662b6";
		}else if(packageid.equals("yd.70M")){
			packagecode = "YD_ecfbea53a1e5463983bcb7610b8c0bfe";
		}else if(packageid.equals("yd.150M")){
			packagecode = "YD_5579866441cb4fd5accc6af85402ac5f";
		}else if(packageid.equals("yd.500M")){
			packagecode = "YD_8328c49792314bfdaa03ecc90c8302ea";
		}else if(packageid.equals("yd.1G")){
			packagecode = "YD_14b664dd41e24342a040726932b83b21";
		}else if(packageid.equals("yd.2G")){
			packagecode = "YD_1005ea6cce2f4ac092c6189aba1d8985";
		}else if(packageid.equals("lt.20M")){
			packagecode = "LT_99293974c30f4fe1ab2b9c4c63caa249";
		}else if(packageid.equals("lt.50M")){
			packagecode = "LT_775141c7e0fa48bbb355789415d11f49";
		}else if(packageid.equals("lt.100M")){
			packagecode = "LT_4a9653ca7ce440ffac9924f281938e78";
		}else if(packageid.equals("lt.200M")){
			packagecode = "LT_e040f689ddab4df0a13062c59b619884";
		}else if(packageid.equals("lt.500M")){
			packagecode = "LT_37d6b10307c24269b6223c7dbe31b3b6";
		}else if(packageid.equals("dx.5M")){
			packagecode = "DX_85cd87822ae745f9954318ace8616740";
		}else if(packageid.equals("dx.10M")){
			packagecode = "DX_733459afd2744438978e54ff53fb391b";
		}else if(packageid.equals("dx.30M")){
			packagecode = "DX_41021084602f4338ae07f1082d23015b";
		}else if(packageid.equals("dx.50M")){
			packagecode = "DX_cc3cde7dfebe4b89b8cf01d5bde1c265";
		}else if(packageid.equals("dx.100M")){
			packagecode = "DX_05b1d1a86ba640528be237e922770ce6";
		}else if(packageid.equals("dx.200M")){
			packagecode = "DX_e3895503590a4bb9981e5d4a098d4c90";
		}else if(packageid.equals("dx.500M")){
			packagecode = "DX_1100cb1b683f45d6b1da99769d4ee4f2";
		}else if(packageid.equals("dx.1G")){
			packagecode = "DX_581bf7213ec94b6fb1e23af999dea35c";
		}
		
		if(packagecode == null){
			request.setAttribute("result", "S." + routeid + ":unrecognized package@" + TimeUtils.getSysLogTimeString());
			break;
		}
		
		JSONObject json = new JSONObject();
		json.put("phone", phone);
		json.put("cpOrderNos", packagecode);
		json.put("cpUserName", account);
		json.put("timestamp", TimeUtils.getTimeStamp());
		json.put("transNo", taskid);
		
		LinkedHashMap<String, String> header = new LinkedHashMap<String, String>();
		header.put("X-FDN-Auth", MD5Util.getLowerMD5(json.toString() + api_key));
		
		//在执行请求前先获取连接, 防止访问通道线程超量
		Cache.getConnection(routeid);
		try {
			ret = HttpAccess.postJsonRequest(mturl, json.toString(), "utf-8", header, "wangsusend");
		} catch (Exception e) {
			e.printStackTrace();
			logger.info(e.getMessage());
		} finally {
			//在执行请求后记得释放连接
			Cache.releaseConnection(routeid);
		}
	
		//这里判断结果, 每个通道情况不同, 成功的保存 success 到 result 中并返回到 request.jsp
		if (ret != null && ret.trim().length() > 0) {
			logger.info("wangsu send ret = " + ret);
			try {
				JSONObject retjson = JSONObject.fromObject(ret);
				String code = retjson.getString("responseCode");
				if(code.equals("10000")){
					request.setAttribute("result", "success");
					request.setAttribute("reportid", retjson.getJSONObject("responseData").getString("orderId"));
				}else{
					request.setAttribute("code", code);
					Object responseobj = json.get("responseMsg");
					String responseMsg = code;
					if(responseobj != null){
						responseMsg = responseobj.toString();
					}
					request.setAttribute("result", "R." + routeid + ":" + responseMsg + "@" + TimeUtils.getSysLogTimeString());
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