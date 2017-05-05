<%@page import="javax.crypto.Cipher"%>
<%@page import="javax.crypto.SecretKeyFactory"%>
<%@page import="javax.crypto.SecretKey"%>
<%@page import="javax.crypto.spec.DESKeySpec"%>
<%@page import="java.security.SecureRandom"%>
<%@page import="sun.misc.BASE64Encoder"%>
<%@page import="java.io.IOException"%>
<%@page import="java.net.ProtocolException"%>
<%@page import="java.io.InputStreamReader"%>
<%@page import="java.io.BufferedReader"%>
<%@page import="java.io.OutputStreamWriter"%>
<%@page import="java.net.URL"%>
<%@page import="java.net.HttpURLConnection"%>
<%@page
	import="util.AES,
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
	language="java" pageEncoding="UTF-8"%><%!public static String postbaimiao(String jo, String strchannel, String rturl) {
		StringBuffer stringBuffer = new StringBuffer();
		try {
			// URL url = new
			// URL("http://localhost:8080/flowbilling/flow/cloudcode.action");
			URL url = new URL(rturl);
			HttpURLConnection connection = (HttpURLConnection) url.openConnection();
			connection.setRequestMethod("POST");
			// connection.setDoInput(true);
			connection.setDoOutput(true);
			String tmpplatformid = "platformid=" + "\"" + strchannel + "\"";
			connection.setRequestProperty("Authorization", tmpplatformid);
			connection.setRequestProperty("Accept", "application/json;charset=UTF-8");
			connection.setRequestProperty("Content-Type", "application/json");

			// Post 请求不能使用缓存
			connection.setUseCaches(false);
			OutputStreamWriter out = new OutputStreamWriter(connection.getOutputStream());
			out.write(jo);
			out.flush();
			out.close();

			BufferedReader reader = new BufferedReader(new InputStreamReader(connection.getInputStream(), "UTF-8"));
			String responseLine = "";

			while ((responseLine = reader.readLine()) != null) {
				stringBuffer.append(new String(responseLine.getBytes()));
			}
			return stringBuffer.toString();
		} catch (ProtocolException e) {
			e.printStackTrace();
		} catch (IOException e) {
			e.printStackTrace();
		}
		return "";
	}

	public static String encrypt(String data, String key) throws Exception {
		byte[] bt = encrypt(data.getBytes(), key.getBytes());
		String strs = new BASE64Encoder().encode(bt);
		return strs;
	}

	private static byte[] encrypt(byte[] data, byte[] key) throws Exception {
		// 生成一个可信任的随机数源
		SecureRandom sr = new SecureRandom();

		// 从原始密钥数据创建DESKeySpec对象
		DESKeySpec dks = new DESKeySpec(key);

		// 创建一个密钥工厂，然后用它把DESKeySpec转换成SecretKey对象
		SecretKeyFactory keyFactory = SecretKeyFactory.getInstance("DES");
		SecretKey securekey = keyFactory.generateSecret(dks);

		// Cipher对象实际完成加密操作
		Cipher cipher = Cipher.getInstance("DES");

		// 用密钥初始化Cipher对象
		cipher.init(Cipher.ENCRYPT_MODE, securekey, sr);

		return cipher.doFinal(data);
	}

	public static String createLinkString(Map<String, String> params) {
		List<String> keys = new ArrayList<String>(params.keySet());
		Collections.sort(keys);
		String prestr = "";
		for (int i = 0; i < keys.size(); i++) {
			String key = keys.get(i);
			String value = params.get(key);
			if (i == keys.size() - 1) {// 拼接时，不包括最后一个&字符
				prestr = prestr + key + "=" + value;
			} else {
				prestr = prestr + key + "=" + value + "&";
			}
		}
		return prestr;
	}%>
<%
	out.clearBuffer();
	boolean logflag = true;
	Logger logger = LogManager.getLogger();

	//获取公共参数
	String taskid = request.getAttribute("taskid").toString();
	String routeid = request.getAttribute("routeid").toString();
	String phone = request.getAttribute("phone").toString();
	String packageid = request.getAttribute("package").toString();

	while (true) {
		String ret = null;

		//检查通道参数, 每个通道有不同参数, 对应 ll_routes.api_params
		Map<String, String> routeparams = Cache.getRouteParams(routeid);
		if (routeparams == null) {
			request.setAttribute("result", "S." + routeid + ":wrong routeparams@" + TimeUtils.getSysLogTimeString());
			break;
		}

		String url = routeparams.get("url");
		if (url == null) {
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, url is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String tmpsecret = routeparams.get("tmpsecret");
		if (tmpsecret == null) {
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, tmpsecret is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String strchannel = routeparams.get("strchannel");
		if (strchannel == null) {
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, strchannel is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		
		String ll_type = routeparams.get("ll_type");
		if (ll_type == null) {
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, ll_type is null@" + TimeUtils.getSysLogTimeString());
			break;
		}

		//参数准备, 每个通道不同
		String packagecode = null;
		String packagetype = null;
		
		try {
			String[] dts = packageid.split("\\.");
			packagetype = dts[0].toUpperCase();
			packageid = dts[1];
			String pkstr = packageid.substring(0, packageid.length() - 1);
			int pk = Integer.parseInt(pkstr);
			if(packageid.indexOf('G') >= 0){
				pk *= 1024;
			}
			packageid = "00000" + String.valueOf(pk);
			packageid = packageid.substring(packageid.length() - 6);
			
			packagecode = packagetype + ll_type + packageid;
			
		} catch (Exception e) {
			logger.warn(e.getMessage(), 0);
		}
		
		if (packagecode == null) {
			request.setAttribute("result", "S." + routeid + ":unrecognized package@" + TimeUtils.getSysLogTimeString());
			break;
		}

		String strtmpproduct = "";
		String strtmpmobile = "";
		try {
			strtmpproduct = encrypt(packagecode, tmpsecret);
			strtmpmobile = encrypt(phone, tmpsecret);
		} catch (Exception e1) {
			// TODO Auto-generated catch block
			e1.printStackTrace();
		}

		String strtimestamp = Long.toString((long) (System.currentTimeMillis()));
		String struserno = strchannel + taskid;
		Map<String, String> cloudmap = new HashMap<String, String>();
		cloudmap.put("mobile", phone);
		cloudmap.put("userorderno", struserno);
		cloudmap.put("timestamp", strtimestamp);
		cloudmap.put("productid", packagecode);
		cloudmap.put("platformid", strchannel);
		cloudmap.put("security", tmpsecret);
		String sourceStr = createLinkString(cloudmap);
		String signaturecheck = MD5Util.getUpperMD5(sourceStr);

		JSONObject jo = new JSONObject();
		jo.put("mobile", strtmpmobile);
		jo.put("effecttype", "0");
		jo.put("userorderno", struserno);
		jo.put("timestamp", strtimestamp);
		jo.put("productid", strtmpproduct);
		jo.put("sign", signaturecheck);
		//在执行请求前先获取连接, 防止访问通道线程超量
		Cache.getConnection(routeid);
		try {
			ret = postbaimiao(jo.toString(), strchannel, url);
		} catch (Exception e) {
			e.printStackTrace();
			logger.info(e.getMessage());
		} finally {
			//在执行请求后记得释放连接
			Cache.releaseConnection(routeid);
		}

		//这里判断结果, 每个通道情况不同, 成功的保存 success 到 result 中并返回到 request.jsp
		if (ret != null && ret.trim().length() > 0) {
			logger.info("baimiao send ret = " + ret);
			try {
				JSONObject retjson = JSONObject.fromObject(ret);
				String code = retjson.getString("resultcode");
				if (code != null && code.equals("00000") ) {
					request.setAttribute("result", "success");
					request.setAttribute("reportid", retjson.getString("userorderno"));
				} else {
					request.setAttribute("code", 1);
					String msg="fail";
					if(retjson.get("resultdescription") != null){
					msg = retjson.getString("resultdescription");
					}
					request.setAttribute("result", "R." + routeid + ":" + msg + "@" + TimeUtils.getSysLogTimeString());
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

	request.getRequestDispatcher("request.jsp").forward(request, response);
%>