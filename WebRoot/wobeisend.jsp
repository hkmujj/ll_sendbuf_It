<%@page import="com.sun.org.apache.xpath.internal.operations.Lt"%>
<%@page import="net.sf.json.JSONArray"%>
<%@page import="java.rmi.RemoteException"%>
<%@page import="com.huawei.webservice.wb.company.CompanyServiceStub"%>
<%@page import="org.apache.commons.codec.binary.Base64"%>
<%@page import="javax.crypto.Cipher"%>
<%@page import="javax.crypto.spec.SecretKeySpec"%>
<%@page
	import="com.huawei.webservice.wb.company.CompanyServiceStub.GiveFlowResponse"%>
<%@page
	import="com.huawei.webservice.wb.company.CompanyServiceStub.GiveFlow"%>
<%@page
	import="com.huawei.webservice.wb.company.CompanyServiceStub.ResponseWbVo"%>
<%@page import="util.MD5Util"%>
<%@page
	import="util.TimeUtils,
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

<%!public static boolean logflag = true;
	public static Logger logger = LogManager.getLogger();

	public static String giveFlow(String phone[], String channel, String uName, String url, String key, String flowCode, String msgId, StringBuffer log) throws RemoteException {
		GiveFlow giveFlow = new GiveFlow();
		giveFlow.setChannel(channel);
		giveFlow.setUName(uName);
		giveFlow.setPhone(phone);
		giveFlow.setFlowCode(flowCode);
		giveFlow.setMsgId(msgId);
		String giveflowsrc = "channel=" + channel + "|serviceName=giveFlow|";
		giveFlow.setSecretKey(Encrypt(giveflowsrc, key, log));

		GiveFlowResponse giveFlowResponse = new CompanyServiceStub(url).giveFlow(giveFlow);

		ResponseWbVo responseWbVo = giveFlowResponse.get_return();

		return JSONObject.fromObject(responseWbVo).toString();
	}

	protected static String Encrypt(String sSrc, String sKey, StringBuffer log) {
		String result = "";
		try{
			byte[] raw = sKey.getBytes("utf-8");
			SecretKeySpec skeySpec = new SecretKeySpec(raw, "AES");
			Cipher cipher = Cipher.getInstance("AES/ECB/PKCS5Padding");// "算法/模式/补码方式"
			cipher.init(Cipher.ENCRYPT_MODE, skeySpec);
			byte[] encrypted = cipher.doFinal(sSrc.getBytes("utf-8"));
			result = new Base64().encodeToString(encrypted);// 此处使用BASE64做转码功能，同时能起到2次加密的作用。
		}catch(Exception e){
			log.append("，生成沃贝秘钥错误，错误原因：" + e);
		}

		return result;
	}%>>
<%
	//获取公共参数
	out.clearBuffer();
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
		String channel = routeparams.get("channel");
		if(channel == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, channel is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String key = routeparams.get("key");
		if(key == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, key is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String uName = routeparams.get("uName");
		if(uName == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, uName is null@" + TimeUtils.getSysLogTimeString());
			break;
		}

		//参数准备, 每个通道不同
		String packagecode = null;
		int a=(int)(1+Math.random()*(3));
		try{
		if(a==1){
			if(packageid.equals("lt.10M")){
				packagecode = "1047";
			}else if(packageid.equals("lt.20M")){
				packagecode = "1050";
			}else if(packageid.equals("lt.30M")){
				packagecode = "1053";
			}else if(packageid.equals("lt.50M")){
				packagecode = "1056";
			}else if(packageid.equals("lt.100M")){
				packagecode = "1059";
			}else if(packageid.equals("lt.200M")){
				packagecode = "1062";
			}else if(packageid.equals("lt.300M")){
				packagecode = "1065";
			}else if(packageid.equals("lt.500M")){
				packagecode = "1068";
			}else if(packageid.equals("lt.1G")){
				packagecode = "1071";
			}
		}else if(a==2){
			if(packageid.equals("lt.10M")){
				packagecode = "1048";
			}else if(packageid.equals("lt.20M")){
				packagecode = "1051";
			}else if(packageid.equals("lt.30M")){
				packagecode = "1054";
			}else if(packageid.equals("lt.50M")){
				packagecode = "1057";
			}else if(packageid.equals("lt.100M")){
				packagecode = "1060";
			}else if(packageid.equals("lt.200M")){
				packagecode = "1063";
			}else if(packageid.equals("lt.300M")){
				packagecode = "1066";
			}else if(packageid.equals("lt.500M")){
				packagecode = "1069";
			}else if(packageid.equals("lt.1G")){
				packagecode = "1072";
			}
		}else if(a==3){
			if(packageid.equals("lt.10M")){
				packagecode = "1049";
			}else if(packageid.equals("lt.20M")){
				packagecode = "1052";
			}else if(packageid.equals("lt.30M")){
				packagecode = "1055";
			}else if(packageid.equals("lt.50M")){
				packagecode = "1058";
			}else if(packageid.equals("lt.100M")){
				packagecode = "1061";
			}else if(packageid.equals("lt.200M")){
				packagecode = "1064";
			}else if(packageid.equals("lt.300M")){
				packagecode = "1067";
			}else if(packageid.equals("lt.500M")){
				packagecode = "1070";
			}else if(packageid.equals("lt.1G")){
				packagecode = "1073";
			}
		}
		}catch(Exception e){
			logger.warn(e.getMessage(), 0);
		}

		if(packagecode == null){
			request.setAttribute("result", "S." + routeid + ":unrecognized package@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String[] mobile = { phone };

		//在执行请求前先获取连接, 防止访问通道线程超量
		Cache.getConnection(routeid);
		try{
			//ret = HttpAccess.postNameValuePairRequest(url, params, "utf-8", "mysend");
			//ret = HttpAccess.postJsonRequest(url, json.toString(), "utf-8", "weikesend");
			ret = giveFlow(mobile, channel, uName, url, key, packagecode, "0", new StringBuffer());

		}catch(Exception e){
			e.printStackTrace();
			logger.info(e.getMessage());
		}finally{
			//在执行请求后记得释放连接
			Cache.releaseConnection(routeid);
		}

		//这里判断结果, 每个通道情况不同, 成功的保存 success 到 result 中并返回到 request.jsp
		if(ret != null && ret.trim().length() > 0){
			logger.info("wobei send ret = " + ret);
			try{
				JSONObject retjson = JSONObject.fromObject(ret);
				String code = retjson.getString("code");
				String msg = retjson.getString("msg"); //":"MOB00001"
				if(code.equals("1")){
					JSONArray array = retjson.getJSONArray("datas");
					if(array != null && !array.toString().equals("[]")){
						JSONObject datajson = array.getJSONObject(0);
						if(datajson.getString("flowOrderId") != null && datajson.getString("flowOrderId").trim().length() > 0){
							String floworderid = datajson.getString("flowOrderId");
							request.setAttribute("result", "success");
							request.setAttribute("reportid", floworderid);
						}else{
						request.setAttribute("code", "1");
						request.setAttribute("result", "R." + routeid + ":" + code + ":" + msg + "@" + TimeUtils.getSysLogTimeString());
						}
					}else{
						request.setAttribute("code", "1");
						request.setAttribute("result", "R." + routeid + ":" + code + ":" + msg + "@" + TimeUtils.getSysLogTimeString());
					}
				}else{
					request.setAttribute("code", "1");
					request.setAttribute("result", "R." + routeid + ":" + code + ":" + msg + "@" + TimeUtils.getSysLogTimeString());
				}
				request.setAttribute("orgreturn", ret);
			}catch(Exception e){
				e.printStackTrace();
				logger.info(e.getMessage());
				request.setAttribute("result", "R." + routeid + ":" + e.getMessage() + "@" + TimeUtils.getSysLogTimeString());
			}
		}else{
			request.setAttribute("result", "R." + routeid + ":fail@" + TimeUtils.getSysLogTimeString());
		}

		break;
	}

	request.getRequestDispatcher("request.jsp").forward(request, response);
%>