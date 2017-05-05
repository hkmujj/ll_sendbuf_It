<%@page import="org.dom4j.Element"%>
<%@page import="org.dom4j.DocumentHelper"%>
<%@page import="org.dom4j.Document"%>
<%@page import="java.rmi.RemoteException"%>
<%@page import="javax.xml.rpc.ParameterMode"%>
<%@page import="javax.xml.rpc.ServiceException"%>
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
				java.io.UnsupportedEncodingException,
				org.apache.axis.client.Call,
				org.apache.axis.client.Service,
				org.apache.axis.encoding.XMLType"
		language="java" pageEncoding="UTF-8"
%><%!
	public static String productOpen(String url, String pkey, String seqId, String loginName, String phoneNo, String productCode,String code){
		String endpoint = url;
		String result = "no result!";
		Service service = new Service();
		Call call = null;
		Object[] object = new Object[6];
		object[0] = pkey;
		object[1] = seqId;
		object[2] = loginName;
		object[3] = phoneNo;
		object[4] = productCode;
		object[5] = code;
		
		try{
			try{
				call = (Call) service.createCall();
			}catch(ServiceException e){
				e.printStackTrace();
			}
			call.setTargetEndpointAddress(endpoint);// 远程调用路径
			call.setOperationName("productOpen");// 调用的方法名
			call.addParameter("pkey", XMLType.XSD_STRING,ParameterMode.IN);
			call.addParameter("seqId", XMLType.XSD_STRING,ParameterMode.IN);
			call.addParameter("loginName", XMLType.XSD_STRING,ParameterMode.IN);
			call.addParameter("phoneNo", XMLType.XSD_STRING,ParameterMode.IN);
			call.addParameter("productCode", XMLType.XSD_STRING,ParameterMode.IN);
			call.addParameter("code", XMLType.XSD_STRING,ParameterMode.IN);
			// 设置返回值类型：
			call.setReturnType(XMLType.XSD_STRING);// 返回值类型：String
			result = (String)call.invoke(object);
		}catch(RemoteException e){
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return result;
	}
 %><%
 	out.clearBuffer();
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
		String pkey = routeparams.get("pkey");
		if(pkey == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, pkey is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String pSecret = routeparams.get("pSecret");
		if(pSecret == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, pSecret is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String loginName = routeparams.get("loginName");
		if(loginName == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, loginName is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		
		
		//参数准备, 每个通道不同
		String packagecode = null;//对应文档的productbingdingId
		packageid = packageid.split("\\.")[1];
		if(packageid.equals("10M")){
			packagecode = "00000001";
		}else if(packageid.equals("30M")){
			packagecode = "00000002";
		}else if(packageid.equals("50M")){
			packagecode = "00000003";
		}else if(packageid.equals("100M")){
			packagecode = "00000004";
		}else if(packageid.equals("200M")){
			packagecode = "00000005";
		}else if(packageid.equals("300M")){
			packagecode = "00000006";
		}else if(packageid.equals("500M")){
			packagecode = "00000007";
		}else if(packageid.equals("1G")){
			packagecode = "00000008";
		}
		
		if(packagecode == null){
			request.setAttribute("result", "S." + routeid + ":unrecognized package@" + TimeUtils.getSysLogTimeString());
			break;
		}
		
		String sign = taskid + packagecode + pkey + phone + loginName + pSecret;
		String code = MD5Util.getUpperMD5(sign);
		logger.info("gdliantongcf send data = " + taskid + ":" + packagecode + ":" + pkey + ":" + phone + ":" + 
		             loginName + ":" + pSecret);

		//在执行请求前先获取连接, 防止访问通道线程超量
		Cache.getConnection(routeid);
		try {
			  ret = productOpen(url, pkey, taskid, loginName, phone, packagecode, code);
			//ret = HttpAccess.postNameValuePairRequest(url, param,"application/x-www-form-urlencoded", "utf-8", "gdshangtong");
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
			logger.info("gdliantongcf send ret = " + ret);


			try {
				Document retDocument = DocumentHelper.parseText(ret);
				Element responseElement = retDocument.getRootElement();
				Element resultCodeElement = responseElement.element("ResultCode");
				Element resultDescElement = responseElement.element("ResultDesc");
				
				String resultCode = resultCodeElement.getText();
				logger.info("gdliantongcf ResultCode = " + resultCode);
				String descMessage = resultDescElement.getText();
				logger.info("gdliantongcf ResultDesc = " + descMessage);

				if(resultCode.equals("0")){
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