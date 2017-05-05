<%@page import="javax.xml.bind.DatatypeConverter"%>
<%@page import="javax.crypto.spec.IvParameterSpec"%>
<%@page import="javax.crypto.spec.SecretKeySpec"%>
<%@page import="javax.crypto.Cipher"%>
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
%><%!
	public static String encrypt(String input, String key, String vi) throws Exception {
		try {
			Cipher cipher = Cipher.getInstance("AES/CBC/PKCS5Padding");
			cipher.init(Cipher.ENCRYPT_MODE,
			new SecretKeySpec(key.getBytes(), "AES"),
			new IvParameterSpec(vi.getBytes()));
			byte[] encrypted = cipher.doFinal(input.getBytes("utf-8"));
			//  此处使用 BASE64 做转码。
			return DatatypeConverter.printBase64Binary(encrypted); 
			} catch (Exception ex) {
				return null;
			}
	}
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
		String partner_no = routeparams.get("partner_no");
		if(partner_no == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, partner_no is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String contract_id = routeparams.get("contract_id");
		if(contract_id == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, contract_id is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String effect_type = routeparams.get("effect_type");
		if(effect_type == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, effect_type is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String aes_password = routeparams.get("aes_password");
		if(aes_password == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, aes_password is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String aes_iv = routeparams.get("aes_iv");
		if(aes_iv == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, aes_iv is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		
		//参数准备, 每个通道不同
		
		String packagecode = null;
		String facevalue = null;//面值
		if(packageid.equals("yd.10M")){
			packagecode = "TBM00000100A";
			facevalue = "3";
		}else if(packageid.equals("yd.30M")){
			packagecode = "TBM00000300A";
			facevalue = "5";
		}else if(packageid.equals("yd.70M")){
			packagecode = "TBM00000700A";
			facevalue = "10";
		}else if(packageid.equals("yd.150M")){
			packagecode = "TBM00001500A";
			facevalue = "20";
		}else if(packageid.equals("yd.500M")){
			packagecode = "TBM00005000A";
			facevalue = "30";
		}else if(packageid.equals("yd.1G")){
			packagecode = "TBM00010000A";
			facevalue = "50";
		}else if(packageid.equals("yd.2G")){
			packagecode = "TBM00020000A";
			facevalue = "70";
		}else if(packageid.equals("yd.3G")){
			packagecode = "TBM00030000A";
			facevalue = "100";
		}else if(packageid.equals("yd.4G")){
			packagecode = "TBM00040000A";
			facevalue = "130";
		}else if(packageid.equals("yd.6G")){
			packagecode = "TBM00060000A";
			facevalue = "180";
		}else if(packageid.equals("yd.11G")){
			packagecode = "TBM00110000A";
			facevalue = "280";
		}else if(packageid.equals("lt.20M")){
			packagecode = "TBU00000200A";
			facevalue = "3";
		}else if(packageid.equals("lt.50M")){
			packagecode = "TBU00000500A";
			facevalue = "6";
		}else if(packageid.equals("lt.100M")){
			packagecode = "TBU00001000A";
			facevalue = "10";
		}else if(packageid.equals("lt.200M")){
			packagecode = "TBU00002000A";
			facevalue = "15";
		}else if(packageid.equals("lt.500M")){
			packagecode = "TBU00005000A";
			facevalue = "30";
		}else if(packageid.equals("lt.1G")){
			packagecode = "TBU00010000A";
			facevalue = "100";
		}else if(packageid.equals("dx.5M")){
			packagecode = "TBC00000050B";
			facevalue = "1";
		}else if(packageid.equals("dx.10M")){
			packagecode = "TBC00000100B";
			facevalue = "2";
		}else if(packageid.equals("dx.30M")){
			packagecode = "TBC00000300B";
			facevalue = "5";
		}else if(packageid.equals("dx.50M")){
			packagecode = "TBC00000500B";
			facevalue = "7";
		}else if(packageid.equals("dx.100M")){
			packagecode = "TBC00001000B";
			facevalue = "10";
		}else if(packageid.equals("dx.200M")){
			packagecode = "TBC00002000B";
			facevalue = "15";
		}else if(packageid.equals("dx.500M")){
			packagecode = "TBC00005000B";
			facevalue = "30";
		}else if(packageid.equals("dx.1G")){
			packagecode = "TBC00010000B";
			facevalue = "50";
		}
		
		if(packagecode == null){
			request.setAttribute("result", "S." + routeid + ":unrecognized package@" + TimeUtils.getSysLogTimeString());
			break;
		}
		if(facevalue == null){
			request.setAttribute("result", "S." + routeid + ":unrecognized facevalue@" + TimeUtils.getSysLogTimeString());
			break;
		}
		
		long timestamp = System.currentTimeMillis()/1000;
		
		JSONObject obj = new JSONObject();
		obj.put("plat_offer_id", packagecode);
		obj.put("phone_id", phone);
		obj.put("facevalue", facevalue);
		obj.put("order_id", taskid);
		obj.put("request_no", taskid);
		obj.put("contract_id", contract_id);
		obj.put("timestamp", timestamp);
		obj.put("effect_type", effect_type);
		logger.info("quxunsend codeobj = " + obj.toString());
		
		String code;
		JSONObject req = new JSONObject();
		try{
			code = encrypt(obj.toString(), aes_password, aes_iv);
			req.put("partner_no", partner_no);
			req.put("code", code);
			logger.info("quxun reqobj = " + req.toString());
		}catch(Exception e){
			e.printStackTrace();
		}
		
		//在执行请求前先获取连接, 防止访问通道线程超量
		Cache.getConnection(routeid);
		try {
			//ret = HttpAccess.postNameValuePairRequest(url, params, "utf-8", "mysend");
			//ret = HttpAccess.postJsonRequest(url, json.toString(), "utf-8", "weikesend");
			ret = HttpAccess.postJsonRequest(sendurl, req.toString(), "utf-8", "quxunsend");
		} catch (Exception e) {
			e.printStackTrace();
			logger.info(e.getMessage());
		} finally {
			//在执行请求后记得释放连接
			Cache.releaseConnection(routeid);
		}
	
		//这里判断结果, 每个通道情况不同, 成功的保存 success 到 result 中并返回到 request.jsp(ret为返回的结果)
		if (ret != null && ret.trim().length() > 0) {
			logger.info("quxun send ret = " + ret);

			try {
				JSONObject retjson = JSONObject.fromObject(ret);
				String retCode = retjson.getString("result_code"); //":"00000" 下单/订购成功
				
				if(retCode.equals("00000")){
					request.setAttribute("result", "success");
				}else{
					request.setAttribute("code", 1);
					request.setAttribute("result", "R." + routeid + ":" + retCode + "@" + TimeUtils.getSysLogTimeString());
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