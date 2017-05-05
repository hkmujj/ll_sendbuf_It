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

	logger.info("chuanglan entry1");

	//获取公共参数
	String taskid = request.getAttribute("taskid").toString();
	String routeid = request.getAttribute("routeid").toString();
	String phone = request.getAttribute("phone").toString();
	String packageid = request.getAttribute("package").toString();

	logger.info("chuanglan entry2");

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

			String account = routeparams.get("account");
			if (account == null) {
				request.setAttribute("result", "S." + routeid
						+ ":wrong routeparams, account  is null@"
						+ TimeUtils.getSysLogTimeString());
				break;
			}

			String key = routeparams.get("key");
			if (key == null) {
				request.setAttribute("result", "S." + routeid
						+ ":wrong routeparams, key  is null@"
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
			if (flow.length() == 2) {
				flow = "000" + flow;
			} else if (flow.length() == 3) {
				flow = "00" + flow;
			} else if (flow.length() == 4) {
				flow = "0" + flow;
			} else if (flow.length() == 1) {
				flow = "0000" + flow;
			}

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

			String timestamp = "";
			String noncestr = "";
			String signature = "";
			String extId = "";

			url += "sendDistributor";
			timestamp = System.currentTimeMillis() / 1000 + "";
			noncestr = getFixLenthString(6);
			SimpleDateFormat df = new SimpleDateFormat(
					"yyyyMMddHHmmssSSS");
			extId = df.format(new Date()) + noncestr;

			signature = "account=" + account + "&ext_id=" + extId
					+ "&mobile=" + phone + "&noncestr=" + noncestr
					+ "&package=" + flow + "&timestamp="
					+ timestamp + "&key=" + key;
			signature = SHA1(signature);

			logger.info("chuanglan entry2 Test01:");
			Cache.getConnection(routeid);
			try {

				HttpClient hc = new HttpClient();
				PostMethod mt = new PostMethod(url);
				mt.addParameter("account", account);
				mt.addParameter("timestamp", timestamp);
				mt.addParameter("noncestr", noncestr);
				mt.addParameter("mobile", phone);
				mt.addParameter("package", flow);
				mt.addParameter("signature", signature);
				mt.addParameter("ext_id", extId);
				
				logger.info("url=" + url + ", account=" + account + ", timestamp=" + timestamp + ", noncestr=" + noncestr 
				+ ", mobile=" + phone + ", package=" + flow + ", signature=" + signature + ", ext_id=" + extId);
				
				int sta = hc.executeMethod(mt);
				if (sta == 200) {
					resultTxt = mt.getResponseBodyAsString();
					System.out.println("return:" + resultTxt);
				} else {
					System.out.println("HttpError:" + sta);
				}

			} catch (Exception e) {
				e.printStackTrace();
				logger.info(e.getMessage());
			} finally {
				//在执行请求后记得释放连接
				Cache.releaseConnection(routeid);
			}
			logger.info("chuanglan entry2 Test02:" + resultTxt);
			System.out.println("return:" + resultTxt);
			JSONObject jb = JSON.parseObject(resultTxt);
			String code = jb.getString("code");
			String desc = jb.getString("desc");
			String extidBac = jb.getString("ext_id");
			if (code.equals("0") & !extidBac.equals("")) {
				request.setAttribute("result", "success");
				request.setAttribute("reportid", extidBac);
				request.setAttribute("orgreturn", code + ":" + desc);
			} else {
				request.setAttribute("result",
						"R." + routeid + ":" + code + ":" + desc + "@"
								+ TimeUtils.getSysLogTimeString());
			}
			System.out.println("End.");

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
	}
	

	
	%>