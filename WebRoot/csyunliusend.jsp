<%@page
	import="net.sf.json.JSONArray,
				java.io.InputStreamReader,
				java.net.URL,
				java.net.HttpURLConnection,
				java.io.BufferedReader,
				java.io.OutputStreamWriter,
				sun.misc.BASE64Encoder,
				java.io.UnsupportedEncodingException,
				sun.misc.BASE64Decoder,
				javax.crypto.Cipher,
				javax.crypto.spec.SecretKeySpec,
				java.io.IOException,
				java.security.InvalidKeyException,
				javax.crypto.BadPaddingException,
				javax.crypto.IllegalBlockSizeException,
				javax.crypto.NoSuchPaddingException,
				java.security.NoSuchAlgorithmException,
				util.MD5Util,
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
	language="java" pageEncoding="UTF-8"%>
<%!private static final String ALGO = "AES";

	public static String aesDecrypt(String ciphertext, String password) throws NoSuchAlgorithmException, NoSuchPaddingException, IllegalBlockSizeException, BadPaddingException, InvalidKeyException,
			IOException {
		byte[] enCodeFormat = password.getBytes();
		SecretKeySpec key = new SecretKeySpec(enCodeFormat, ALGO);
		Cipher cipher = Cipher.getInstance(ALGO);// 创建密码器
		cipher.init(Cipher.DECRYPT_MODE, key);// 初始化
		byte[] result = cipher.doFinal(new BASE64Decoder().decodeBuffer(ciphertext));
		return new String(result, "UTF-8"); //
	}

	public static String aesEncrypt(String content, String password) {
		byte[] result = null;
		try{

			byte[] enCodeFormat = password.getBytes();
			SecretKeySpec key = new SecretKeySpec(enCodeFormat, ALGO);
			Cipher cipher = Cipher.getInstance(ALGO);// 创建密码器
			byte[] byteContent = content.getBytes("UTF-8");
			cipher.init(Cipher.ENCRYPT_MODE, key);// 初始化
			result = cipher.doFinal(byteContent);
		}catch(InvalidKeyException e){
			e.printStackTrace();
		}catch(NoSuchAlgorithmException e){
			e.printStackTrace();
		}catch(NoSuchPaddingException e){
			e.printStackTrace();
		}catch(IllegalBlockSizeException e){
			e.printStackTrace();
		}catch(BadPaddingException e){
			e.printStackTrace();
		}catch(UnsupportedEncodingException e){
			e.printStackTrace();
		}
		return new BASE64Encoder().encode(result); // 加密
	}

	public static String requestFront(String custId, String secretkey, String suffix, String interfaceUrl, String timestamp, String paramsJson) throws Exception {
		String result = "";
		OutputStreamWriter out = null;
		BufferedReader reader = null;
		HttpURLConnection conn = null;
		try{
			URL url = new URL(interfaceUrl);
			conn = (HttpURLConnection) url.openConnection();
			conn.setRequestMethod("POST");
			conn.setDoOutput(true);
			conn.setDoInput(true);
			conn.setConnectTimeout(30 * 1000);
			conn.setReadTimeout(60 * 1000);
			conn.addRequestProperty("Accept", "*/*");
			conn.addRequestProperty("Content-Type", "text/plain");
			conn.addRequestProperty("timestamp", timestamp);
			conn.addRequestProperty("custid", custId);
			String text = encryptedDate(secretkey, paramsJson);
			out = new OutputStreamWriter(conn.getOutputStream());
			out.write(text);
			out.flush();
			reader = new BufferedReader(new InputStreamReader(conn.getInputStream(), "utf-8"));
			String line = "";
			while((line = reader.readLine()) != null){
				result += line;
			}
		}catch(IOException e){
			e.printStackTrace();
		}finally{
			try{
				if(out != null){
					out.close();
				}
				if(reader != null){
					reader.close();
				}
				if(conn != null){
					conn.disconnect();
				}
			}catch(IOException ex){
				ex.printStackTrace();
			}
		}
		return result;
	}

	/**
	 * @Description： 把map转换成json并加密
	 * @param pwd
	 *            密钥
	 * @param paramsJson 要加密的数据JSON数据
	 * @return 已加密的数据
	 * @author: LIZHAOYANG
	 * @since: 2015年6月5日 下午5:37:42
	 */
	public static String encryptedDate(String pwd, String paramsJson) throws Exception, NoSuchAlgorithmException, NoSuchPaddingException, IllegalBlockSizeException, BadPaddingException,
			UnsupportedEncodingException {
		String result = aesEncrypt(paramsJson, pwd);
		return result;
	}%>
<%
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

		String mt_url = routeparams.get("mt_url");
		if(mt_url == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, mt_url is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String custId = routeparams.get("custId");
		if(custId == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, custId is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String secretkey = routeparams.get("secretkey");
		if(secretkey == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, secretkey is null@" + TimeUtils.getSysLogTimeString());
			break;
		}

		//参数准备, 每个通道不同
		String packagecode = null;
		try{
			if(routeid.equals("3121")){
				//湖南电信
				if(packageid.equals("dx.5M")){
					packagecode = "10004207";
				}else if(packageid.equals("dx.10M")){
					packagecode = "10004208";
				}else if(packageid.equals("dx.30M")){
					packagecode = "10004209";
				}else if(packageid.equals("dx.50M")){
					packagecode = "10004210";
				}else if(packageid.equals("dx.100M")){
					packagecode = "10004211";
				}else if(packageid.equals("dx.200M")){
					packagecode = "10004212";
				}else if(packageid.equals("dx.500M")){
					packagecode = "10004213";
				}else if(packageid.equals("dx.1G")){
					packagecode = "10004214";
				}
			}else if(routeid.equals("3193")){
				//河南电信
				if(packageid.equals("dx.5M")){
					packagecode = "10004621";
				}else if(packageid.equals("dx.10M")){
					packagecode = "10004622";
				}else if(packageid.equals("dx.30M")){
					packagecode = "10004623";
				}else if(packageid.equals("dx.50M")){
					packagecode = "10004624";
				}else if(packageid.equals("dx.100M")){
					packagecode = "10004625";
				}else if(packageid.equals("dx.200M")){
					packagecode = "10004626";
				}else if(packageid.equals("dx.500M")){
					packagecode = "10004627";
				}else if(packageid.equals("dx.1G")){
					packagecode = "10004628";
				}
			}else if(routeid.equals("3239")){
				//湖北电信
				if(packageid.equals("dx.5M")){
					packagecode = "10004754";
				}else if(packageid.equals("dx.10M")){
					packagecode = "10004755";
				}else if(packageid.equals("dx.30M")){
					packagecode = "10004756";
				}else if(packageid.equals("dx.50M")){
					packagecode = "10004757";
				}else if(packageid.equals("dx.100M")){
					packagecode = "10004758";
				}else if(packageid.equals("dx.200M")){
					packagecode = "10004759";
				}else if(packageid.equals("dx.500M")){
					packagecode = "10004760";
				}else if(packageid.equals("dx.1G")){
					packagecode = "10004761";
				}
			}else if(routeid.equals("1164")){
				//河南移动
				if(packageid.equals("yd.70M")){
					packagecode = "10004612";
				}else if(packageid.equals("yd.150M")){
					packagecode = "10004613";
				}else if(packageid.equals("yd.500M")){
					packagecode = "10004614";
				}else if(packageid.equals("yd.1G")){
					packagecode = "10004615";
				}else if(packageid.equals("yd.2G")){
					packagecode = "10004616";
				}else if(packageid.equals("yd.3G")){
					packagecode = "10004617";
				}else if(packageid.equals("yd.4G")){
					packagecode = "10004618";
				}else if(packageid.equals("yd.6G")){
					packagecode = "10004619";
				}else if(packageid.equals("yd.11G")){
					packagecode = "10004620";
				}
			}else if(routeid.equals("3175")){
				//四川电信
				if(packageid.equals("dx.5M")){
					packagecode = "10004502";
				}else if(packageid.equals("dx.10M")){
					packagecode = "10004503";
				}else if(packageid.equals("dx.30M")){
					packagecode = "10004504";
				}else if(packageid.equals("dx.50M")){
					packagecode = "10004505";
				}else if(packageid.equals("dx.100M")){
					packagecode = "10004506";
				}
			}else if(routeid.equals("2029")){
				//安徽联通
				if(packageid.equals("lt.20M")){
					packagecode = "10004280";
				}else if(packageid.equals("lt.30M")){
					packagecode = "10004281";
				}else if(packageid.equals("lt.50M")){
					packagecode = "10004282";
				}else if(packageid.equals("lt.100M")){
					packagecode = "10004283";
				}else if(packageid.equals("lt.200M")){
					packagecode = "10004284";
				}else if(packageid.equals("lt.300M")){
					packagecode = "10004285";
				}else if(packageid.equals("lt.500M")){
					packagecode = "10004286";
				}else if(packageid.equals("lt.1G")){
					packagecode = "10004287";
				}
			}else if(routeid.equals("2049")){
				//合肥后向+安徽联通
				if(packageid.equals("lt.20M")){
					packagecode = "10002925";
				}
			}else if(routeid.equals("2047")){	
				//山东联通
				 if(packageid.equals("lt.20M")){
					packagecode = "10004388";
				}else if(packageid.equals("lt.30M")){
					packagecode = "10004389";
				}else if(packageid.equals("lt.50M")){
					packagecode = "10004390";
				}else if(packageid.equals("lt.100M")){
					packagecode = "10004391";
				}else if(packageid.equals("lt.200M")){
					packagecode = "10004392";
				}else if(packageid.equals("lt.300M")){
					packagecode = "10004393";
				}else if(packageid.equals("lt.500M")){
					packagecode = "10004394";
				}else if(packageid.equals("lt.1G")){
					packagecode = "10004395";
				}
			}else if(routeid.equals("3170")){
				//山东电信
				if(packageid.equals("dx.5M")){
					packagecode = "10004458";
				}else if(packageid.equals("dx.10M")){
					packagecode = "10004459";
				}else if(packageid.equals("dx.30M")){
					packagecode = "10004460";
				}else if(packageid.equals("dx.50M")){
					packagecode = "10004461";
				}else if(packageid.equals("dx.100M")){
					packagecode = "10004462";
				}else if(packageid.equals("dx.200M")){
					packagecode = "10004463";
				}else if(packageid.equals("dx.300M")){
					packagecode = "10004464";
				}else if(packageid.equals("dx.500M")){
					packagecode = "10004465";
				}else if(packageid.equals("dx.700M")){
					packagecode = "10004466";
				}else if(packageid.equals("dx.1G")){
					packagecode = "10004467";
				}
			}
		}catch(Exception e){
			logger.warn(e.getMessage(), 0);
		}

		if(packagecode == null){
			request.setAttribute("result", "S." + routeid + ":unrecognized package@" + TimeUtils.getSysLogTimeString());
			break;
		}

		String timestamp = TimeUtils.getTimeStamp();
		JSONObject json = new JSONObject();
		json.put("custId", custId);
		json.put("shopProductId", packagecode);
		json.put("telPhone", phone);
		json.put("requestNo", taskid);
		String paramsJson = json.toString();
		String suffix = "";
		logger.info("yunliu params=" + paramsJson);
		//在执行请求前先获取连接, 防止访问通道线程超量
		Cache.getConnection(routeid);
		try{
			//ret = HttpAccess.postNameValuePairRequest(url, params, "utf-8", "mysend");
			//ret = HttpAccess.postJsonRequest(url, json.toString(), "utf-8", "weikesend");
			ret = requestFront(custId, secretkey, suffix, mt_url, timestamp, paramsJson);

		}catch(Exception e){
			e.printStackTrace();
			logger.info(e.getMessage());
		}finally{
			//在执行请求后记得释放连接
			Cache.releaseConnection(routeid);
		}

		//这里判断结果, 每个通道情况不同, 成功的保存 success 到 result 中并返回到 request.jsp
		if(ret != null && ret.trim().length() > 0){
			logger.info("csyunliusend send ret = " + ret);
			try{
				JSONObject rtjson = JSONObject.fromObject(ret);
				String errorcode = rtjson.getString("errorcode");
				String code = rtjson.getString("code");
				JSONArray arr = rtjson.getJSONArray("message");
				if(code.equals("1") && errorcode.equals("200")){
					JSONObject mbjson = arr.getJSONObject(0);
					String orderId = mbjson.getString("orderId");
					request.setAttribute("result", "success");
					request.setAttribute("reportid", orderId + phone);
				}else{
					request.setAttribute("code", errorcode);
					request.setAttribute("result", "R." + routeid + ":" + errorcode + ":" + code + "@" + TimeUtils.getSysLogTimeString());
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