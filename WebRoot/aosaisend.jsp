<%@page import="util.TimeUtils,
				http.HttpAccess,
				util.MD5Util,
				cache.Cache,
				net.sf.json.JSONException,
				net.sf.json.JSONObject,
				java.util.*,
				util.MyStringUtils,
				java.net.URLDecoder,
				org.apache.logging.log4j.LogManager,
				org.apache.logging.log4j.Logger,
				util.MyBase64,
				java.security.MessageDigest,
				java.security.NoSuchAlgorithmException,
				java.io.UnsupportedEncodingException"
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
		
		//检查通道参数, 每个通道有不同参数, 对应 ll_routes.api_params(私有参数)
		Map<String, String> routeparams = Cache.getRouteParams(routeid);
		if(routeparams == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams@" + TimeUtils.getSysLogTimeString());
			break;
		}
		
		String sendurl = routeparams.get("sendurl");
		if(sendurl == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, sendurl is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String AppId = routeparams.get("AppId");
		if(AppId == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, AppId is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String AppSecret = routeparams.get("AppSecret");
		if(AppSecret == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, AppSecret is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		
		//参数准备, 每个通道不同
		String packagecode = null;
		if(packageid.equals("yd.10M")){
			packagecode = "YD100010";
		}else if(packageid.equals("yd.20M")){
			packagecode = "YD100020";
		}else if(packageid.equals("yd.30M")){
			packagecode = "YD100030";
		}else if(packageid.equals("yd.50M")){
			packagecode = "YD100050";
		}else if(packageid.equals("yd.70M")){
			packagecode = "YD100070";
		}else if(packageid.equals("yd.100M")){
			packagecode = "YD100100";
		}else if(packageid.equals("yd.150M")){
			packagecode = "YD100150";
		}else if(packageid.equals("yd.200M")){
			packagecode = "YD100200";
		}else if(packageid.equals("yd.300M")){
			packagecode = "YD100300";
		}else if(packageid.equals("yd.500M")){
			packagecode = "YD100500";
		}else if(packageid.equals("yd.700M")){
			packagecode = "YD100700";
		}else if(packageid.equals("yd.1G")){
			packagecode = "YD101024";
		}else if(packageid.equals("yd.2G")){
			packagecode = "YD102048";
		}else if(packageid.equals("yd.3G")){
			packagecode = "YD103072";
		}else if(packageid.equals("yd.4G")){
			packagecode = "YD104096";
		}else if(packageid.equals("yd.6G")){
			packagecode = "YD106144";
		}else if(packageid.equals("yd.11G")){
			packagecode = "YD111264";
		}else if(packageid.equals("lt.20M")){
			packagecode = "LT100020";
		}else if(packageid.equals("lt.50M")){
			packagecode = "LT100050";
		}else if(packageid.equals("lt.100M")){
			packagecode = "LT100100";
		}else if(packageid.equals("lt.200M")){
			packagecode = "LT100200";
		}else if(packageid.equals("lt.500M")){
			packagecode = "LT100500";
		}else if(packageid.equals("dx.5M")){
			packagecode = "DX100005";
		}else if(packageid.equals("dx.10M")){
			packagecode = "DX100010";
		}else if(packageid.equals("dx.30M")){
			packagecode = "DX100030";
		}else if(packageid.equals("dx.50M")){
			packagecode = "DX100050";
		}else if(packageid.equals("dx.100M")){
			packagecode = "DX100100";
		}else if(packageid.equals("dx.200M")){
			packagecode = "DX100200";
		}else if(packageid.equals("dx.500M")){
			packagecode = "DX100500";
		}else if(packageid.equals("dx.1G")){
			packagecode = "DX101024";
		}
		
		if(packagecode == null){
			request.setAttribute("result", "S." + routeid + ":unrecognized package@" + TimeUtils.getSysLogTimeString());
			break;
		}
		
		String Sig = "AppId=" + AppId + "Mobile=" + phone + "OutOrderNum=" + taskid 
				+ "ProductNum=" + packagecode + AppSecret;
		Sig = MD5Util.getUpperMD5(Sig);

		HashMap<String, String> param = new HashMap<String, String>();
		param.put("AppId", AppId);
		param.put("OutOrderNum", taskid);
		param.put("Mobile", phone);
		param.put("ProductNum", packagecode);
		param.put("Sig", Sig);
		
		//在执行请求前先获取连接, 防止访问通道线程超量
		Cache.getConnection(routeid);
		try {
			ret = HttpAccess.postNameValuePairRequest(sendurl, param, "utf-8", "aosaisend");
			//ret = HttpAccess.postJsonRequest(url, json.toString(), "utf-8", "weikesend");
			//ret = HttpAccess.getNameValuePairRequest(url, param, "utf-8", "mark");
		} catch (Exception e) {
			e.printStackTrace();
			logger.info(e.getMessage());
		} finally {
			//在执行请求后记得释放连接
			Cache.releaseConnection(routeid);
		}
	
		//这里判断结果, 每个通道情况不同, 成功的保存 success 到 result 中并返回到 request.jsp(ret为返回的结果)
		if (ret != null && ret.trim().length() > 0) {
			logger.info("aosai send ret = " + ret);


			try {
				JSONObject retjson = JSONObject.fromObject(ret);
				String retCode = retjson.getString("code"); //":"0000" 下单/订购成功
				
				if(retCode.equals("0")){
					request.setAttribute("result", "success");
				}else{
					request.setAttribute("code", 1);
					//将返回结果的message转为中文
					String message = retjson.getString("message");
				 	request.setAttribute("result", "R." + routeid + ":" + retCode + ":" + message + "@" + TimeUtils.getSysLogTimeString());
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