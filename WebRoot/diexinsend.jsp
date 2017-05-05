<%@page import="com.alibaba.fastjson.util.Base64"%>
<%@page import="org.dom4j.Element"%>
<%@page import="org.dom4j.DocumentHelper"%>
<%@page import="org.dom4j.Document"%>
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
	public final static String myMD5(String s) {
		String ret = null;
		try {
			byte[] btInput = s.getBytes("utf-8");
			// 获得MD5摘要算法的 MessageDigest 对象
			MessageDigest mdInst = MessageDigest.getInstance("MD5");
			// 使用指定的字节更新摘要
			mdInst.update(btInput);
			// 获得密文
			byte[] md = mdInst.digest();
			// 把密文转换成十六进制的字符串形式
			ret = new org.apache.commons.codec.binary.Base64().encodeToString(md);
		} catch (Exception e) {
			e.printStackTrace();
			return null;
		}
		
		return ret;
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
		
		String url = routeparams.get("url");
		if(url == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, url is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String custInteId = routeparams.get("custInteId");
		if(custInteId == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, custInteId is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String secretKey = routeparams.get("secretKey");
		if(secretKey == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, secretKey is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String orderType = routeparams.get("orderType");
		if(orderType == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, orderType is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String version = routeparams.get("version");
		if(version == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, version is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String effectType = routeparams.get("effectType");
		if(effectType == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, effectType is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		
		
		
		//参数准备, 每个通道不同
		String packagecode = null;
		if(packageid.equals("yd.10M")){
			packagecode = "100010";
		}else if(packageid.equals("yd.30M")){
			packagecode = "100030";
		}else if(packageid.equals("yd.70M")){
			packagecode = "100070";
		}else if(packageid.equals("yd.150M")){
			packagecode = "100150";
		}else if(packageid.equals("yd.500M")){
			packagecode = "100500";
		}else if(packageid.equals("yd.1G")){
			packagecode = "101024";
		}else if(packageid.equals("yd.2G")){
			packagecode = "102048";
		}else if(packageid.equals("yd.3G")){
			packagecode = "103072";
		}else if(packageid.equals("yd.4G")){
			packagecode = "104096";
		}else if(packageid.equals("yd.6G")){
			packagecode = "106144";
		}else if(packageid.equals("yd.11G")){
			packagecode = "111264";
		}else if(packageid.equals("lt.20M")){
			packagecode = "100020";
		}else if(packageid.equals("lt.50M")){
			packagecode = "100050";
		}else if(packageid.equals("lt.100M")){
			packagecode = "100100";
		}else if(packageid.equals("lt.200M")){
			packagecode = "100200";
		}else if(packageid.equals("lt.500M")){
			packagecode = "100500";
		}else if(packageid.equals("lt.1G")){
			packagecode = "101024";
		}else if(packageid.equals("dx.5M")){
			packagecode = "100005";
		}else if(packageid.equals("dx.10M")){
			packagecode = "100010";
		}else if(packageid.equals("dx.30M")){
			packagecode = "100030";
		}else if(packageid.equals("dx.50M")){
			packagecode = "100050";
		}else if(packageid.equals("dx.100M")){
			packagecode = "100100";
		}else if(packageid.equals("dx.200M")){
			packagecode = "100200";
		}else if(packageid.equals("dx.500M")){
			packagecode = "100500";
		}else if(packageid.equals("dx.1G")){
			packagecode = "101024";
		}
		
		if(packagecode == null){
			request.setAttribute("result", "S." + routeid + ":unrecognized package@" + TimeUtils.getSysLogTimeString());
			break;
		}
		
		String echo = "" + new Random().nextInt(10000000);
		String timestamp = TimeUtils.getTimeStamp();//YYYYMMDDHHMMSS
		String sign = custInteId + taskid + secretKey + echo + timestamp; 
		String chargeSign = myMD5(sign);
		//String md5sign = MD5Util.getLowerMD5(sign);
		//String chargeSign = MyBase64.base64Encode(md5sign);//签名
		
		//使用 DocumentHelper 类创建一个文档实例。
		Document document = DocumentHelper.createDocument();
		//使用 addElement() 方法创建根元素 <request> 。 addElement() 用于向 XML 文档中增加元素。
		Element requestElement = document.addElement("request");
		
		Element headElement =  requestElement.addElement("head");
		
		Element custInteIdElement=headElement.addElement("custInteId");
		Element echoElement=headElement.addElement("echo");
		Element orderIdElement=headElement.addElement("orderId");
		Element timestampElement=headElement.addElement("timestamp");
		Element orderTypeElement=headElement.addElement("orderType");
		Element versionElement=headElement.addElement("version");
		Element chargeSignElement=headElement.addElement("chargeSign");
		
		custInteIdElement.setText(custInteId);
		echoElement.setText(echo);
		orderIdElement.setText(taskid);
		timestampElement.setText(timestamp);
		orderTypeElement.setText(orderType);
		versionElement.setText(version);
		chargeSignElement.setText(chargeSign);
		
		Element bodyElement =  requestElement.addElement("body");
		Element itemElement =  bodyElement.addElement("item");
		
		Element packCodeElement =  itemElement.addElement("packCode");
		Element mobileElement =  itemElement.addElement("mobile");
		Element effectTypeElement =  itemElement.addElement("effectType");
		
		packCodeElement.setText(packagecode);
		mobileElement.setText(phone);
		effectTypeElement.setText(effectType);
		
		logger.info("diexinsend xml = " + document.asXML());
		
		//在执行请求前先获取连接, 防止访问通道线程超量
		Cache.getConnection(routeid);
		try {
			//ret = HttpAccess.postNameValuePairRequest(url, param,"application/x-www-form-urlencoded", "utf-8", "gdshangtong");
			//ret = HttpAccess.postJsonRequest(url, json.toString(), "utf-8", "weikesend");
			//ret = HttpAccess.getNameValuePairRequest(url, param, "utf-8", "mark");
			ret = HttpAccess.postXmlRequest(url, document.asXML(), "utf-8", "diexinsend");
		} catch (Exception e) {
			e.printStackTrace();
			logger.info(e.getMessage());
		} finally {
			//在执行请求后记得释放连接
			Cache.releaseConnection(routeid);
		}
	
		//这里判断结果, 每个通道情况不同, 成功的保存 success 到 result 中并返回到 request.jsp(ret为返回的结果)
		if (ret != null && ret.trim().length() > 0) {
			logger.info("diexinsend ret = " + ret);


			try {
				Document retDocument = DocumentHelper.parseText(ret);
				Element responseElement = retDocument.getRootElement();
				Element resultElement = responseElement.element("result");
				Element descElement = responseElement.element("desc");
				
				String resultCode = resultElement.getText();
				logger.info("diexinsend resultCode = " + resultCode);
				String descMessage = descElement.getText();
				logger.info("diexinsend descMessage = " + descMessage);

				if(resultCode.equals("0000")){
					request.setAttribute("result", "success");
				}else{
					request.setAttribute("code", 1);	
				 	request.setAttribute("result", "R." + routeid + ":" + resultCode + ":" + descMessage + "@" + TimeUtils.getSysLogTimeString());
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