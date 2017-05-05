<%@page import="java.security.Signature"%>
<%@page import="java.security.PrivateKey"%>
<%@page import="java.security.KeyFactory"%>
<%@page import="java.security.spec.PKCS8EncodedKeySpec"%>
<%@page import="org.apache.commons.codec.binary.Base64"%>
<%@page import="org.dom4j.Element"%>
<%@page import="org.dom4j.DocumentHelper"%>
<%@page import="org.dom4j.Document"%>
<%@page import="http.HttpAccess"%>
<%@page import="java.util.HashMap"%>
<%@page import="util.MyBase64"%>
<%@page import="java.security.NoSuchAlgorithmException"%>
<%@page import="java.security.MessageDigest"%>
<%@page
	import="net.sf.json.JSONObject,
				java.util.Map,
				util.TimeUtils,
				cache.Cache,
				org.apache.http.impl.client.HttpClients,
				org.apache.http.impl.client.CloseableHttpClient,
				java.net.URLDecoder,
				org.apache.logging.log4j.LogManager,
				java.io.BufferedReader,
				java.io.IOException,
				java.io.InputStream,
				java.io.InputStreamReader,
				java.io.UnsupportedEncodingException,
				java.nio.charset.Charset,
				java.util.ArrayList,
				java.util.List,
				org.apache.http.client.methods.HttpPost,
				org.apache.http.HttpResponse,
				org.apache.http.NameValuePair,
				org.apache.http.client.HttpClient,
				org.apache.http.client.entity.UrlEncodedFormEntity,
				org.apache.http.client.methods.HttpPost,
				org.apache.http.message.BasicNameValuePair,
				org.apache.http.protocol.HTTP,
				util.MD5Util,
				org.apache.logging.log4j.Logger"
	language="java" pageEncoding="UTF-8"%><%!private static boolean logflag = true;
	private static Logger logger = LogManager.getLogger();

	public static String sign(byte[] data, String privateKey) throws Exception {
		// 解密由base64编码的私钥   
		byte[] keyBytes = Base64.decodeBase64(privateKey.getBytes());

		// 构造PKCS8EncodedKeySpec对象   
		PKCS8EncodedKeySpec pkcs8KeySpec = new PKCS8EncodedKeySpec(keyBytes);

		// RSAConstants.KEY_ALGORITHM 指定的加密算法   
		KeyFactory keyFactory = KeyFactory.getInstance("RSA");

		// 取私钥匙对象   
		PrivateKey priKey = keyFactory.generatePrivate(pkcs8KeySpec);

		// 用私钥对信息生成数字签名   
		Signature signature = Signature.getInstance("SHA1withRSA");
		signature.initSign(priKey);
		signature.update(data);
		return Base64.encodeBase64String(signature.sign());
	}%>
<%
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
		String macid = routeparams.get("macid");
		if(macid == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, macid is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String arsid = routeparams.get("arsid");
		if(arsid == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, arsid is null@" + TimeUtils.getSysLogTimeString());
			break;
		}

		//参数准备, 每个通道不同
		String packagecode = null;

		try{
			packageid = packageid.split("\\.")[1];
			String pkstr = packageid.substring(0, packageid.length() - 1);
			int pk = Integer.parseInt(pkstr);
			if(packageid.indexOf('G') >= 0){
				pk *= 1000;
			}
			packagecode = String.valueOf(pk);
		}catch(Exception e){
			logger.warn(e.getMessage(), 0);
		}

		if(packagecode == null){
			request.setAttribute("result", "S." + routeid + ":unrecognized package@" + TimeUtils.getSysLogTimeString());
			break;
		}

		//arsid, deno, macid, orderid, phone, sign, time

		String deno = packagecode;
		String orderid = taskid;
		String time = "" + (System.currentTimeMillis() + 3600 * 8 * 1000) / 1000;
		String date = "arsid" + arsid + "deno" + deno + "macid" + macid + "orderid" + orderid + "phone" + phone + "time" + time;
		String prikey = "MIICdwIBADANBgkqhkiG9w0BAQEFAASCAmEwggJdAgEAAoGBAMeTqbHzk5bQ4z5o" + "oKtDOSTcMQmvswOskFJMNu+xfUk6XpNPjd3Y8n54UIxyEcqBzVbf+cYu4BbmzGtX"
				+ "mbT8MEW2uo18M8mgpudGtHkZWJnjjIcQRwot/Xjvra6dN+gFgzv9dFc9e/fuJkbq" + "jH7oI/INM4PvjnwvwGsrS65LSqQjAgMBAAECgYAGVYltPG3Su456zJdM2DVYFiT4"
				+ "SbtEwpVSB1k3AksXp+KYik3WXKxVlzv3OSeXZcc+mp0yzQoPsAOM5JrcQ6TEg0xl" + "HR7o+onqF77fDWqRvdBR821jKbr37q2jYtb/+G5T7Lt58GBZzfH3ygwCSZt/0FqB"
				+ "h7K1txV0t5qVt5OuAQJBAOrefA5DS2/vZw3xneiaH4LntdMSNWq05IRJEBJ3Vlmj" + "jbpJznXHP07Wd8qjyYz9bWLCUoXQ5yse0r7YyQrJNRsCQQDZiFM2TkPrcAndEsIM"
				+ "HRrSmwAKFntFe5M7ciZcLoAEstZBRUhOUQGxjh5iZTiacDB/0XQYevJV9soEKl0b" + "5yWZAkBM52qxdOF3lmklDK9K4WReBabopPauqOqGUjIcCc1RbpdSnyYmNIaLNvhk"
				+ "drrhGn49ryk8PcnjuaUB7pPtnzJvAkEArIssbcPQrdv1huxNDKy9TNXzRw0kBC4L" + "z7gwYyfjFVcBCU66Fpy8eiifQy7EogNhBNGPg6dptvQEsx8jMXG76QJBAKLou7Cj"
				+ "M6+POFaQnBk8272eEqWennPUUiDxvEPo0OzFP4dS9iPRQbfg+Qg4BH4ocuWPqaS3" + "/QUtsi1B10ducsc=";
		String sign = sign(date.getBytes("UTF-8"), prikey);
		Map<String, String> param = new HashMap<String, String>();
		param.put("arsid", arsid);
		param.put("deno", deno);
		param.put("macid", macid);
		param.put("orderid", orderid);
		param.put("phone", phone);
		param.put("time", time);
		param.put("sign", sign);

		//在执行请求前先获取连接, 防止访问通道线程超量
		Cache.getConnection(routeid);
		try{
			ret = HttpAccess.postNameValuePairRequest(url, param, "utf-8", "lecai");
		}catch(Exception e){
			e.printStackTrace();
			logger.info(e.getMessage());
		}finally{
			//在执行请求后记得释放连接
			Cache.releaseConnection(routeid);
		}

		//这里判断结果, 每个通道情况不同, 成功的保存 success 到 result 中并返回到 request.jsp
		if(ret != null && ret.trim().length() > 0){
			logger.info("lecai send ret = " + ret);
			try{
				Document retDocument = DocumentHelper.parseText(ret);
				Element responseElement = retDocument.getRootElement();
				String errcode = responseElement.element("errcode").getText();

				if(errcode.equalsIgnoreCase("OrderSended")){
					request.setAttribute("result", "success");
					//request.setAttribute("reportid", rpid);
				}else{
					String errinfo = responseElement.element("errinfo").getText();
					request.setAttribute("code", 1);
					request.setAttribute("result", "R." + routeid + ":" + errinfo + "@" + TimeUtils.getSysLogTimeString());
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