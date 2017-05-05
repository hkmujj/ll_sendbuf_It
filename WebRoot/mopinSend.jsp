<%@page import="org.apache.http.util.EntityUtils"%>
<%@page import="org.apache.http.HttpResponse"%>
<%@page import="org.apache.http.entity.StringEntity"%>
<%@page import="org.apache.http.client.methods.HttpPost"%>
<%@page import="org.apache.http.impl.client.DefaultHttpClient"%>
<%@page import="java.security.NoSuchAlgorithmException"%>
<%@page import="org.apache.commons.httpclient.methods.PostMethod"%>
<%@page import="org.apache.commons.httpclient.HttpClient"%>
<%@page import="com.alibaba.fastjson.JSON"%>
<%@page import="com.alibaba.fastjson.JSONObject"%>
<%@page import="java.io.IOException"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.security.MessageDigest"%>
<%@page import="java.io.InputStreamReader"%>
<%@page import="java.net.URLConnection"%>
<%@page import="java.net.URL"%>
<%@page import="java.io.BufferedReader"%>
<%@page import="cache.Cache"%>
<%@page import="util.TimeUtils"%>
<%@page import="org.apache.logging.log4j.LogManager"%>
<%@page import="org.apache.logging.log4j.Logger"%>
<%@page import="org.bouncycastle.util.encoders.Hex"%>
<%@page import="org.bouncycastle.crypto.paddings.PaddedBufferedBlockCipher"%>
<%@page import="org.bouncycastle.crypto.modes.CBCBlockCipher"%>
<%@page import="org.bouncycastle.crypto.engines.AESFastEngine"%>
<%@page import="org.bouncycastle.crypto.CipherParameters"%>
<%@page import="org.bouncycastle.crypto.params.ParametersWithIV"%>
<%@page import="org.bouncycastle.crypto.params.KeyParameter"%>

<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%
	boolean logflag = true;
	Logger logger = LogManager.getLogger();

	logger.info("mopin entry1");

	//获取公共参数
	String taskid = request.getAttribute("taskid").toString();
	String routeid = request.getAttribute("routeid").toString();
	String phone = request.getAttribute("phone").toString();
	String packageid = request.getAttribute("package").toString();

	logger.info("mopin entry2");

	try {
		while (true) {
			String ret = null;

			Map<String, String> routeparams = Cache
					.getRouteParams(routeid);
			if (routeparams == null) {
				request.setAttribute("result",
						"S." + routeid + ":wrong routeparams@"
								+ TimeUtils.getSysLogTimeString());
				break;
			}

			String url = routeparams.get("url");
			if (url == null) {
				request.setAttribute("result", "S." + routeid
						+ ":wrong routeparams, url is null@"
						+ TimeUtils.getSysLogTimeString());
				break;
			}

			String notifyUrl = routeparams.get("notifyUrl");
			if (notifyUrl == null) {
				request.setAttribute("result", "S." + routeid
						+ ":wrong routeparams, notifyUrl  is null@"
						+ TimeUtils.getSysLogTimeString());
				break;
			}

			String cp_user = routeparams.get("cp_user");
			if (cp_user == null) {
				request.setAttribute("result", "S." + routeid
						+ ":wrong routeparams, cp_user  is null@"
						+ TimeUtils.getSysLogTimeString());
				break;
			}
			String api_key = routeparams.get("api_key");
			if (api_key == null) {
				request.setAttribute("result", "S." + routeid
						+ ":wrong routeparams, api_key  is null@"
						+ TimeUtils.getSysLogTimeString());
				break;
			}
			String secret_key = routeparams.get("secret_key");
			if (secret_key == null) {
				request.setAttribute("result", "S." + routeid
						+ ":wrong routeparams, secret_key  is null@"
						+ TimeUtils.getSysLogTimeString());
				break;
			}

			String resultTxt = "";
			//KB流量大小
			String flow = "";
			//检查通道参数, 每个通道有不同参数, 对应 ll_routes.api_param
			String packagecodeArray[] = packageid.split("\\.");
			flow = packagecodeArray[1];
			if (flow.contains("G")) {
				flow = Integer.parseInt(flow.substring(0,
						flow.length() - 1)) * 1024 + "M";
			}
			flow = flow.replace("M", "");
			flow = Integer.parseInt(flow) * 1024 + "";
			
			/* 
			if (productId == null | ("").equals(productId)) {
				request.setAttribute("result", "R." + routeid
						+ ":没有对应产品@" + TimeUtils.getSysLogTimeString());
				return;
			}
			 */
			 
			 
			/************************************/
			//request.setAttribute("result", "success");
			//break;
			/************************************/

			//在执行请求前先获取连接, 防止访问通道线程超量
			
			String a = cp_user;
			String d = "";
			String t = "" + System.currentTimeMillis();
			String channelOrderId = t + getFixLenthString(5);
			String content = "";
			String createTime = (new SimpleDateFormat("yyyyMMddHHmmss"))
					.format(new Date());
			int type = 1;
			int amount = Integer.parseInt(flow);
			//0全国1省
			int range = 0;
			String mobile = phone;
			JSONObject jb = new JSONObject();
			jb.put("cpUser", cp_user);
			jb.put("channelOrderId", channelOrderId);
			jb.put("content", content);
			jb.put("createTime", createTime);
			jb.put("type", type);
			jb.put("amount", amount);
			jb.put("range", range);
			jb.put("mobile", mobile);
			jb.put("notifyUrl", notifyUrl);
			System.out.println("@@" + jb.toJSONString());
			String dAES = encrypt(jb.toJSONString(), api_key);
			d = mmd5(dAES);

			String digest = d;

			List<String> srcList = new ArrayList<String>();
			srcList.add(cp_user);
			srcList.add(secret_key);
			srcList.add(digest);
			srcList.add(t);
			Collections.sort(srcList, String.CASE_INSENSITIVE_ORDER);
			Collections.reverse(srcList);
			String s = "";
			for (String listStr : srcList) {
				s += listStr;
			}
			System.out.println(s);
			s = SHA1(s);
			System.out.println(s);

			url += "/recharge/order?a=" + a + "&d=" + d + "&t=" + t + "&s=" + s;

			logger.info("mopin entry2 Test01:");
			Cache.getConnection(routeid);
			try {
				HttpClient hc = new HttpClient();
				PostMethod mt = new PostMethod(url);
				mt.setRequestHeader("Content-Type",
						"application/octet-stream;charset=UTF-8");
				mt.setRequestBody(dAES);
				logger.info("mopin entry2 Test03:"+url+"\r\n"+dAES);
				int stat = hc.executeMethod(mt);
				if (stat == 200) {
					resultTxt = mt.getResponseBodyAsString();
					System.out.println("resutl:" + resultTxt);
				} else {
					System.out.println("HttpError:" + stat);
				}

			} catch (Exception e) {
				e.printStackTrace();
				logger.info(e.getMessage());
			} finally {
				//在执行请求后记得释放连接
				Cache.releaseConnection(routeid);
			}
			logger.info("mopin entry2 Test02:" + resultTxt);
			JSONObject jbn = JSON.parseObject(resultTxt);
			String statusCode = jbn.getString("statusCode");
			String message = jbn.getString("message");
			JSONObject dataJson = jbn.getJSONObject("data");
			System.out.println("End.");
			if(dataJson!=null|!"".equals(dataJson)){
				String orderId= dataJson.getString("orderId");
				String channelOrderIdRes= dataJson.getString("channelOrderId");
				String status= dataJson.getString("status");
				String failReason= dataJson.getString("failReason");
				if("200".equals(statusCode)&"0000".equals(status)&!("").equals(orderId)){
					request.setAttribute("result", "success");
					request.setAttribute("reportid", orderId);
					request.setAttribute("orgreturn", status + ":" + failReason);
				}else{
				request.setAttribute("result",
						"R." + routeid + ":" + statusCode + ":" + message+"_"+ status + ":" + failReason + "@"
									+ TimeUtils.getSysLogTimeString());
				}
		}else{
			request.setAttribute("result",
						"R." + routeid + ":" + statusCode + ":" + message + "@"
									+ TimeUtils.getSysLogTimeString());
			}
		
			//JSONObject jbn = JSON.parseObject(result);
			//String status = jbn.getString("status");
			// msgid = jbn.getString("msgid");
			//String description = jbn.getString("description");

			break;

		}
	} catch (Exception e) {
		e.printStackTrace();
		logger.info(e.toString());
		request.setAttribute(
				"result",
				"R." + routeid + ":" + e.toString() + "@"
						+ TimeUtils.getSysLogTimeString());
	}

	request.getRequestDispatcher("request.jsp").forward(request,
			response);
%>

<%!/**
	 * SHA加密
	 *
	 * @param inputStr
	 * @return
	 */
	public static String shaEncrypt(String inputStr) {
		byte[] inputData = inputStr.getBytes();
		String returnString = "";
		try {
			inputData = encryptSHA(inputData);
			for (int i = 0; i < inputData.length; i++) {
				returnString += byteToHexString(inputData[i]);
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		return returnString;
	}

	/**
	 * SHA加密字节
	 *
	 * @param data
	 * @return
	 * @throws Exception
	 */
	public static byte[] encryptSHA(byte[] data) throws Exception {
		MessageDigest sha = MessageDigest.getInstance("SHA");
		sha.update(data);
		return sha.digest();
	}

	private static String byteToHexString(byte ib) {
		char[] Digit = { '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'a',
				'b', 'c', 'd', 'e', 'f' };
		char[] ob = new char[2];
		ob[0] = Digit[(ib >>> 4) & 0X0F];
		ob[1] = Digit[ib & 0X0F];

		String s = new String(ob);

		return s;
	}%>

<%!public static String getFixLenthString(int strLength) {

		Random rm = new Random();

		// 获得随机数
		double pross = (1 + rm.nextDouble()) * Math.pow(10, strLength);

		// 将获得的获得随机数转化为字符串
		String fixLenthString = String.valueOf(pross);

		// 返回固定的长度的随机数
		return fixLenthString.substring(1, strLength + 1);
	}

	public static String encrypt(String content, String apiKey)
			throws Exception {
		return encrypt(content, apiKey, INIT_VECTOR);
	}

	private static final byte[] INIT_VECTOR = { 0x31, 0x37, 0x36, 0x35, 0x34,
			0x33, 0x32, 0x31, 0x38, 0x27, 0x36, 0x35, 0x33, 0x23, 0x32, 0x33 };

	private static byte[] cipherData(PaddedBufferedBlockCipher cipher,
			byte[] data) throws Exception {
		int minSize = cipher.getOutputSize(data.length);
		byte[] outBuf = new byte[minSize];
		int length1 = cipher.processBytes(data, 0, data.length, outBuf, 0);
		int length2 = cipher.doFinal(outBuf, length1);
		int actualLength = length1 + length2;
		byte[] result = new byte[actualLength];
		System.arraycopy(outBuf, 0, result, 0, result.length);
		return result;
	}

	private static byte[] encrypt(byte[] plain, byte[] key, byte[] iv)
			throws Exception {
		PaddedBufferedBlockCipher aes = new PaddedBufferedBlockCipher(
				new CBCBlockCipher(new AESFastEngine()));
		CipherParameters ivAndKey = new ParametersWithIV(new KeyParameter(key),
				INIT_VECTOR);
		aes.init(true, ivAndKey);
		return cipherData(aes, plain);
	}

	public static String encrypt(String content, String apiKey, byte[] iv)
			throws Exception {
		if (apiKey == null) {
			throw new IllegalArgumentException("Key cannot be null!");
		}
		String encrypted = null;
		byte[] keyBytes = apiKey.getBytes();
		if (keyBytes.length != 32 && keyBytes.length != 24
				&& keyBytes.length != 16) {
			throw new IllegalArgumentException(
					"Key length must be 128/192/256 bits!");
		}
		byte[] encryptedBytes = null;
		encryptedBytes = encrypt(content.getBytes(), keyBytes, iv);
		encrypted = new String(Hex.encode(encryptedBytes));
		return encrypted;
	}

	private static final char HEX_DIGITS[] = { '0', '1', '2', '3', '4', '5',
			'6', '7', '8', '9', 'a', 'b', 'c', 'd', 'e', 'f' };

	public static String toHexString(byte[] b) {
		// String to byte
		StringBuilder sb = new StringBuilder(b.length * 2);
		for (int i = 0; i < b.length; i++) {
			sb.append(HEX_DIGITS[(b[i] & 0xf0) >>> 4]);
			sb.append(HEX_DIGITS[b[i] & 0x0f]);
		}
		return sb.toString();
	}

	public static String mmd5(String s) {
		try {
			// Create MD5 Hash
			MessageDigest digest = java.security.MessageDigest
					.getInstance("MD5");
			digest.update(s.getBytes());
			byte messageDigest[] = digest.digest();

			return toHexString(messageDigest);
		} catch (NoSuchAlgorithmException e) {
			e.printStackTrace();
		}

		return "";
	}

	public static String SHA1(String decript) {
		try {
			MessageDigest digest = java.security.MessageDigest
					.getInstance("SHA-1");
			digest.update(decript.getBytes());
			byte messageDigest[] = digest.digest();
			// Create Hex String
			StringBuffer hexString = new StringBuffer();
			// 字节数组转换为 十六进制 数
			for (int i = 0; i < messageDigest.length; i++) {
				String shaHex = Integer.toHexString(messageDigest[i] & 0xFF);
				if (shaHex.length() < 2) {
					hexString.append(0);
				}
				hexString.append(shaHex);
			}
			return hexString.toString();

		} catch (NoSuchAlgorithmException e) {
			e.printStackTrace();
		}
		return "";
	}%>