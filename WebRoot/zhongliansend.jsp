<%@page import="org.dom4j.DocumentHelper"%>
<%@page import="org.dom4j.Element"%>
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
		String userId = routeparams.get("userId");
		if(userId == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, userId is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String privatekey = routeparams.get("privatekey");
		if(privatekey == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, privatekey is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		
		
		//参数准备, 每个通道不同
		String packagecode = null;
	    if(routeid.equals("1118")){
			//全国移动
			if(packageid.equals("yd.10M")){
				packagecode = "14919";
			}else if(packageid.equals("yd.30M")){
				packagecode = "14920";
			}else if(packageid.equals("yd.20M")){
				packagecode = "100020";
			}else if(packageid.equals("yd.50M")){
				packagecode = "100050";
			}else if(packageid.equals("yd.70M")){
				packagecode = "14921";
			}else if(packageid.equals("yd.150M")){
				packagecode = "14922";
			}else if(packageid.equals("yd.500M")){
				packagecode = "14923";
			}else if(packageid.equals("yd.1G")){
				packagecode = "14924";
			}else if(packageid.equals("yd.2G")){
				packagecode = "14925";
			}else if(packageid.equals("yd.3G")){
				packagecode = "14926";
			}else if(packageid.equals("yd.4G")){
				packagecode = "14927";
			}else if(packageid.equals("yd.6G")){
				packagecode = "14928";
			}else if(packageid.equals("yd.11G")){
				packagecode = "14929";
			}else if(packageid.equals("yd.100M")){
				packagecode = "16157";
			}else if(packageid.equals("yd.200M")){
				packagecode = "100200";
			}else if(packageid.equals("yd.300M")){
				packagecode = "16158";
			}
		}else if(routeid.equals("1116")){
			//山东移动
			if(packageid.equals("yd.10M")){
				packagecode = "14908";
			}else if(packageid.equals("yd.30M")){
				packagecode = "14909";
			}else if(packageid.equals("yd.70M")){
				packagecode = "14910";
			}else if(packageid.equals("yd.150M")){
				packagecode = "14911";
			}else if(packageid.equals("yd.500M")){
				packagecode = "14912";
			}else if(packageid.equals("yd.1G")){
				packagecode = "14913";
			}else if(packageid.equals("yd.2G")){
				packagecode = "14914";
			}else if(packageid.equals("yd.3G")){
				packagecode = "14915";
			}else if(packageid.equals("yd.4G")){
				packagecode = "14916";
			}else if(packageid.equals("yd.6G")){
				packagecode = "14917";
			}else if(packageid.equals("yd.11G")){
				packagecode = "14918";
			}else if(packageid.equals("yd.100M")){
				packagecode = "15963";
			}else if(packageid.equals("yd.300M")){
				packagecode = "15964";
			}
		}else if(routeid.equals("1117")){
			//湖南移动
		/* 	if(packageid.equals("yd.30M")){
				packagecode = "14930";
			}else if(packageid.equals("yd.70M")){
				packagecode = "14931";
			}else if(packageid.equals("yd.150M")){
				packagecode = "14932";
			}else if(packageid.equals("yd.500M")){
				packagecode = "14933";
			}else if(packageid.equals("yd.1G")){
				packagecode = "14934";
			}else if(packageid.equals("yd.2G")){
				packagecode = "14935";
			}else if(packageid.equals("yd.3G")){
				packagecode = "14938";
			}else if(packageid.equals("yd.4G")){
				packagecode = "14939";
			}else if(packageid.equals("yd.6G")){
				packagecode = "14940";
			}else if(packageid.equals("yd.11G")){
				packagecode = "14941";
			}else if(packageid.equals("yd.100M")){
				packagecode = "14936";
			}else if(packageid.equals("yd.300M")){
				packagecode = "14937";
			}else if(packageid.equals("yd.10M")){
				packagecode = "16092";
			} */
			if(packageid.equals("yd.30M")){
				packagecode = "15865";
			}else if(packageid.equals("yd.70M")){
				packagecode = "15866";
			}else if(packageid.equals("yd.150M")){
				packagecode = "15867";
			}else if(packageid.equals("yd.500M")){
				packagecode = "15868";
			}else if(packageid.equals("yd.1G")){
				packagecode = "15869";
			}else if(packageid.equals("yd.2G")){
				packagecode = "15870";
			}else if(packageid.equals("yd.3G")){
				packagecode = "15873";
			}else if(packageid.equals("yd.4G")){
				packagecode = "15874";
			}else if(packageid.equals("yd.6G")){
				packagecode = "15875";
			}else if(packageid.equals("yd.11G")){
				packagecode = "15876";
			}else if(packageid.equals("yd.100M")){
				packagecode = "15871";
			}else if(packageid.equals("yd.300M")){
				packagecode = "15872";
			}else if(packageid.equals("yd.10M")){
				packagecode = "15877";
			}
		}else if(routeid.equals("1119")){
			//内蒙古移动
			if(packageid.equals("yd.10M")){
				packagecode = "14988";
			}else if(packageid.equals("yd.30M")){
				packagecode = "14989";
			}else if(packageid.equals("yd.70M")){
				packagecode = "14990";
			}else if(packageid.equals("yd.150M")){
				packagecode = "14991";
			}else if(packageid.equals("yd.500M")){
				packagecode = "14992";
			}else if(packageid.equals("yd.1G")){
				packagecode = "14993";
			}else if(packageid.equals("yd.2G")){
				packagecode = "14994";
			}else if(packageid.equals("yd.3G")){
				packagecode = "14995";
			}else if(packageid.equals("yd.4G")){
				packagecode = "14996";
			}else if(packageid.equals("yd.6G")){
				packagecode = "14997";
			}else if(packageid.equals("yd.11G")){
				packagecode = "14998";
			}
		}else if(routeid.equals("1121")){
			//河北移动省内
			if(packageid.equals("yd.10M")){
				packagecode = "14910";
			}else if(packageid.equals("yd.30M")){
				packagecode = "14911";
			}else if(packageid.equals("yd.50M")){
				packagecode = "14912";
			}else if(packageid.equals("yd.70M")){
				packagecode = "14913";
			}else if(packageid.equals("yd.100M")){
				packagecode = "14914";
			}else if(packageid.equals("yd.150M")){
				packagecode = "14915";
			}else if(packageid.equals("yd.200M")){
				packagecode = "14916";
			}else if(packageid.equals("yd.300M")){
				packagecode = "14917";
			}else if(packageid.equals("yd.500M")){
				packagecode = "14918";
			}else if(packageid.equals("yd.1G")){
				packagecode = "14919";
			}else if(packageid.equals("yd.2G")){
				packagecode = "14920";
			}
		}else if(routeid.equals("1120")){
			//河北移动全国
			if(packageid.equals("yd.10M")){
				packagecode = "14921";
			}else if(packageid.equals("yd.30M")){
				packagecode = "14922";
			}else if(packageid.equals("yd.50M")){
				packagecode = "14923";
			}else if(packageid.equals("yd.70M")){
				packagecode = "14924";
			}else if(packageid.equals("yd.100M")){
				packagecode = "14925";
			}else if(packageid.equals("yd.150M")){
				packagecode = "14926";
			}else if(packageid.equals("yd.200M")){
				packagecode = "14927";
			}else if(packageid.equals("yd.300M")){
				packagecode = "14928";
			}else if(packageid.equals("yd.500M")){
				packagecode = "14929";
			}
		}else if(routeid.equals("2046")){
			//全国联通
			if(packageid.equals("lt.20M")){
				packagecode = "15007";
			}else if(packageid.equals("lt.50M")){
				packagecode = "15008";
			}else if(packageid.equals("lt.100M")){
				packagecode = "15009";
			}else if(packageid.equals("lt.200M")){
				packagecode = "15010";
			}else if(packageid.equals("lt.500M")){
				packagecode = "15011";
			}else if(packageid.equals("lt.30M")){
				packagecode = "15012";
			}else if(packageid.equals("lt.300M")){
				packagecode = "15013";
			}else if(packageid.equals("lt.1G")){
				packagecode = "15014";
			}
		}else if(routeid.equals("2086")){
			//广东联通本地
			if(packageid.equals("lt.20M")){
				packagecode = "16112";
			}else if(packageid.equals("lt.50M")){
				packagecode = "16113";
			}else if(packageid.equals("lt.100M")){
				packagecode = "16114";
			}else if(packageid.equals("lt.200M")){
				packagecode = "16115";
			}else if(packageid.equals("lt.500M")){
				packagecode = "16116";
			}else if(packageid.equals("lt.30M")){
				packagecode = "16117";
			}else if(packageid.equals("lt.300M")){
				packagecode = "16118";
			}else if(packageid.equals("lt.1G")){
				packagecode = "16119";
			}else if(packageid.equals("lt.10M")){
				packagecode = "16120";
			}
		}else if(routeid.equals("2063")){
			//全国联通

			 if(packageid.equals("lt.30M")){
				packagecode = "15012";
			}else if(packageid.equals("lt.300M")){
				packagecode = "15013";
			}else if(packageid.equals("lt.1G")){
				packagecode = "15014";
			}
		}else if(routeid.equals("1129")){
			//陕西移动
			if(packageid.equals("yd.30M")){
				packagecode = "15076";
			}else if(packageid.equals("yd.70M")){
				packagecode = "15077";
			}else if(packageid.equals("yd.150M")){
				packagecode = "15078";
			}else if(packageid.equals("yd.500M")){
				packagecode = "15079";
			}else if(packageid.equals("yd.1G")){
				packagecode = "15080";
			}else if(packageid.equals("yd.2G")){
				packagecode = "15081";
			}
		}else if(routeid.equals("1135")){
			//广东移动  !=微信
		/*	if(packageid.equals("yd.30M")){
				packagecode = "15980";
			}else if(packageid.equals("yd.70M")){
				packagecode = "15981";
			}else if(packageid.equals("yd.150M")){
				packagecode = "15982";
			}else if(packageid.equals("yd.500M")){
				packagecode = "15983";
			}else if(packageid.equals("yd.1G")){
				packagecode = "15984";
			}else if(packageid.equals("yd.2G")){
				packagecode = "15985";
			}else if(packageid.equals("yd.3G")){
				packagecode = "15988";
			}else if(packageid.equals("yd.4G")){
				packagecode = "15989";
			}else if(packageid.equals("yd.6G")){
				packagecode = "15990";
			}else if(packageid.equals("yd.11G")){
				packagecode = "15991";
			}*/
			if(packageid.equals("yd.10M")){
				packagecode = "16094";
			}else if(packageid.equals("yd.30M")){
				packagecode = "15993";
			}else if(packageid.equals("yd.70M")){
				packagecode = "15994";
			}else if(packageid.equals("yd.150M")){
				packagecode = "15995";
			}else if(packageid.equals("yd.500M")){
				packagecode = "15996";
			}else if(packageid.equals("yd.1G")){
				packagecode = "15997";
			}else if(packageid.equals("yd.2G")){
				packagecode = "15998";
			}else if(packageid.equals("yd.3G")){
				packagecode = "16001";
			}else if(packageid.equals("yd.4G")){
				packagecode = "16002";
			}else if(packageid.equals("yd.6G")){
				packagecode = "16003";
			}else if(packageid.equals("yd.11G")){
				packagecode = "16004";
			}
			/* if(packageid.equals("yd.10M")){
				packagecode = "16093";
			}else if(packageid.equals("yd.30M")){
				packagecode = "15052";
			}else if(packageid.equals("yd.70M")){
				packagecode = "15053";
			}else if(packageid.equals("yd.100M")){
				packagecode = "15058";
			}else if(packageid.equals("yd.150M")){
				packagecode = "15054";
			}else if(packageid.equals("yd.300M")){
				packagecode = "15059";
			}else if(packageid.equals("yd.500M")){
				packagecode = "15055";
			}else if(packageid.equals("yd.1G")){
				packagecode = "15056";
			}else if(packageid.equals("yd.2G")){
				packagecode = "15057";
			}else if(packageid.equals("yd.3G")){
				packagecode = "15060";
			}else if(packageid.equals("yd.4G")){
				packagecode = "15061";
			}else if(packageid.equals("yd.6G")){
				packagecode = "15062";
			}else if(packageid.equals("yd.11G")){
				packagecode = "15063";
			} */
		}else if(routeid.equals("1137")){
			//陕西移动不限价
			if(packageid.equals("yd.30M")){
				packagecode = "15937";
			}else if(packageid.equals("yd.70M")){
				packagecode = "15938";
			}else if(packageid.equals("yd.150M")){
				packagecode = "15939";
			}else if(packageid.equals("yd.500M")){
				packagecode = "15940";
			}else if(packageid.equals("yd.1G")){
				packagecode = "15941";
			}else if(packageid.equals("yd.2G")){
				packagecode = "15942";
			} 
		}else if(routeid.equals("1111")){
			//浙江移动
			if(packageid.equals("yd.30M")){
				packagecode = "15040";
			}else if(packageid.equals("yd.70M")){
				packagecode = "15041";
			}else if(packageid.equals("yd.150M")){
				packagecode = "15042";
			}else if(packageid.equals("yd.500M")){
				packagecode = "15043";
			}else if(packageid.equals("yd.1G")){
				packagecode = "15044";
			}else if(packageid.equals("yd.2G")){
				packagecode = "15045";
			}else if(packageid.equals("yd.3G")){
				packagecode = "15048";
			}else if(packageid.equals("yd.4G")){
				packagecode = "15049";
			}else if(packageid.equals("yd.6G")){
				packagecode = "15050";
			}else if(packageid.equals("yd.11G")){
				packagecode = "15051";
			}else if(packageid.equals("yd.10M")){
				packagecode = "15979";
			}
		}else if(routeid.equals("1152")){
			//浙江移动 不限价
			if(packageid.equals("yd.10M")){
				packagecode = "16039";
			}else if(packageid.equals("yd.30M")){
				packagecode = "15951";
			}else if(packageid.equals("yd.70M")){
				packagecode = "15952";
			}else if(packageid.equals("yd.150M")){
				packagecode = "15953";
			}else if(packageid.equals("yd.500M")){
				packagecode = "15954";
			}else if(packageid.equals("yd.1G")){
				packagecode = "15955";
			}else if(packageid.equals("yd.2G")){
				packagecode = "15956";
			}else if(packageid.equals("yd.3G")){
				packagecode = "15959";
			}else if(packageid.equals("yd.4G")){
				packagecode = "15960";
			}else if(packageid.equals("yd.6G")){
				packagecode = "15961";
			}else if(packageid.equals("yd.11G")){
				packagecode = "15962";
			}else if(packageid.equals("yd.100M")){
				packagecode = "15957";
			}else if(packageid.equals("yd.300M")){
				packagecode = "15958";
			}
		}else if(routeid.equals("3191")){
			//江苏电信
			if(packageid.equals("dx.5M")){
				packagecode = "16049";
			}else if(packageid.equals("dx.10M")){
				packagecode = "16041";
			}else if(packageid.equals("dx.30M")){
				packagecode = "16048";
			}else if(packageid.equals("dx.50M")){
				packagecode = "16042";
			}else if(packageid.equals("dx.100M")){
				packagecode = "16043";
			}else if(packageid.equals("dx.200M")){
				packagecode = "16044";
			}else if(packageid.equals("dx.500M")){
				packagecode = "16046";
			}else if(packageid.equals("dx.1G")){
				packagecode = "16047";
			}
		}else if(routeid.equals("3204")){
			//全国电信
			if(packageid.equals("dx.5M")){
				packagecode = "16168";
			}else if(packageid.equals("dx.10M")){
				packagecode = "15088";
			}else if(packageid.equals("dx.30M")){
				packagecode = "15095";
			}else if(packageid.equals("dx.50M")){
				packagecode = "15089";
			}else if(packageid.equals("dx.100M")){
				packagecode = "15090";
			}else if(packageid.equals("dx.200M")){
				packagecode = "15091";
			}else if(packageid.equals("dx.500M")){
				packagecode = "15093";
			}else if(packageid.equals("dx.1G")){
				packagecode = "15094";
			}
		}else if(routeid.equals("3223")){
			//广东电信
			if(packageid.equals("dx.5M")){
				packagecode = "16255";
			}else if(packageid.equals("dx.10M")){
				packagecode = "14999";
			}else if(packageid.equals("dx.30M")){
				packagecode = "15005";
			}else if(packageid.equals("dx.50M")){
				packagecode = "15000";
			}else if(packageid.equals("dx.100M")){
				packagecode = "15001";
			}else if(packageid.equals("dx.200M")){
				packagecode = "15002";
			}else if(packageid.equals("dx.500M")){
				packagecode = "15003";
			}else if(packageid.equals("dx.1G")){
				packagecode = "15004";
			}
		}else if(routeid.equals("3231")){
			//福建电信（电信1G）
			if(packageid.equals("dx.1G")){
				packagecode = "14948";
			}
		}else if(routeid.equals("3230")){
			//福建电信（福建电信5-500M）
			if(packageid.equals("dx.10M")){
				packagecode = "14942";
			}else if(packageid.equals("dx.50M")){
				packagecode = "14943";
			}else if(packageid.equals("dx.100M")){
				packagecode = "14944";
			}else if(packageid.equals("dx.200M")){
				packagecode = "14945";
			}else if(packageid.equals("dx.300M")){
				packagecode = "14946";
			}else if(packageid.equals("dx.500M")){
				packagecode = "14947";
			}
		}else if(routeid.equals("2057")){
			//山东联通
			if(packageid.equals("lt.20M")){
				packagecode = "16023";
			}else if(packageid.equals("lt.50M")){
				packagecode = "16024";
			}else if(packageid.equals("lt.100M")){
				packagecode = "16025";
			}else if(packageid.equals("lt.200M")){
				packagecode = "16026";
			}else if(packageid.equals("lt.500M")){
				packagecode = "16027";
			}else if(packageid.equals("lt.30M")){
				packagecode = "16028";
			}else if(packageid.equals("lt.300M")){
				packagecode = "16029";
			}else if(packageid.equals("lt.1G")){
				packagecode = "16030";
			}
		}else if(routeid.equals("2061")){
			//江苏联通
			if(packageid.equals("lt.20M")){
				packagecode = "15934";
			}else if(packageid.equals("lt.50M")){
				packagecode = "15932";
			}else if(packageid.equals("lt.100M")){
				packagecode = "15936";
			}else if(packageid.equals("lt.200M")){
				packagecode = "15935";
			}else if(packageid.equals("lt.500M")){
				packagecode = "15933";
			}
		}else if(routeid.equals("3222")){
			//全国电信(5-50M)
			if(packageid.equals("dx.5M")){
				packagecode = "16168";
			}else if(packageid.equals("dx.10M")){
				packagecode = "15088";
			}else if(packageid.equals("dx.30M")){
				packagecode = "15095";
			}else if(packageid.equals("dx.50M")){
				packagecode = "15089";
			}
		}else if(routeid.equals("3204")){
			//全国电信(100M-1G)
			if(packageid.equals("dx.100M")){
				packagecode = "15090";
			}else if(packageid.equals("dx.200M")){
				packagecode = "15091";
			}else if(packageid.equals("dx.500M")){
				packagecode = "15093";
			}else if(packageid.equals("dx.1G")){
				packagecode = "15094";
			}
		}
		
		if(packagecode == null){
			request.setAttribute("result", "S." + routeid + ":unrecognized package@" + TimeUtils.getSysLogTimeString());
			break;
		}
		
		String dtCreate = TimeUtils.getTimeStamp();
		
		String sign = dtCreate + packagecode + taskid + phone + userId + privatekey;
		logger.info("bef sign = " + sign);
		sign = MD5Util.getLowerMD5(sign);
		logger.info("aft sign = " + sign);

		HashMap<String, String> param = new HashMap<String, String>();
		param.put("userId", userId);
		param.put("itemId", packagecode);
		param.put("uid", phone);
		param.put("serialno", taskid);
		param.put("dtCreate", dtCreate);
		param.put("sign", sign);
		
		//在执行请求前先获取连接, 防止访问通道线程超量
		Cache.getConnection(routeid);
		try {
			ret = HttpAccess.getNameValuePairRequest(sendurl, param, "utf-8", "zhongliansend");
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
			logger.info("zhongliansend ret = " + ret);


			try {
				Document retDocument = DocumentHelper.parseText(ret);
				Element responseElement = retDocument.getRootElement();
				Element codeElement = responseElement.element("code");
				Element descElement = responseElement.element("desc");
				
				String resultCode = codeElement.getText();
				logger.info("zhongliansend resultCode = " + resultCode);
				String descMessage = descElement.getText();
				logger.info("zhongliansend descMessage = " + descMessage);

				if(resultCode.equals("00")){
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