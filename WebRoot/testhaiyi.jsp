<%@page import="java.security.MessageDigest"%>
<%@page import="java.util.Map.Entry,
				database.LLTempDatabase,
				util.MD5Util,
				net.sf.json.JSONArray,
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
		language="java" pageEncoding="UTF-8"
%>
<%!
	public static String haiyistatus() {
		String url = "http://llw.eatmeng.com/Platform/Flow/queryOrder";
		String appid = "LP14799758";
		String appSecret = "4GSW204zCbxVNfUs";
		String nonceStr = "mcwx";//随机字符串
		String timestamp = "" + System.currentTimeMillis();//14521545
		JSONArray rechargeList = null;
		String clecs = "1";//运营商移动联通电信123
		String mobile = "15017556283";
		String flowCode = "11001";//充值编码
		String orderNum = "123";
		String signstr = "appSecret=" + appSecret + "&appid=" + appid + "&nonceStr=" + nonceStr  + "&orderNum=" + orderNum + "&timestamp=" + timestamp ;
		String sign = shaEncrypt(signstr);
		System.out.println(sign);
		JSONObject json = new JSONObject();
		json.put("nonceStr", nonceStr);
		json.put("timestamp", timestamp);
		json.put("orderNum", orderNum);
		Map<String, String> maps = new HashMap<String, String>();
		maps.put("appid", appid);
		maps.put("sign", sign);
		String ret = HttpAccess.postJsonRequest(url, json.toString(), "utf-8", maps, "haiyi");
		return ret;
	}
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
	}
 %>
<%
	boolean logflag = true;
	Logger logger = LogManager.getLogger();
	
	logger.info("hyllt here");
		out.print(haiyistatus());
%>