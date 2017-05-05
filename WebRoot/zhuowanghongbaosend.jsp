<%@page import="java.security.MessageDigest"%>
<%@page import="database.LLTempDatabase"%>
<%@page import="util.MD5Util,
				util.TimeUtils,
				http.HttpAccess,
				cache.Cache,
				net.sf.json.JSONException,
				net.sf.json.JSONObject,
				java.util.*,
				util.MyStringUtils,
				java.net.URLDecoder,
				org.apache.logging.log4j.LogManager,
				org.apache.logging.log4j.Logger,
				com.aspire.portal.web.security.client.GenerateSignature,
				key.Key" 
		language="java" pageEncoding="UTF-8"
%><%!
	public static String getSha1(String str) {
		if (str == null || str.length() == 0) {
			return null;
		}
		char hexDigits[] = { '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'a', 'b', 'c', 'd', 'e', 'f' };
		try {
			MessageDigest mdTemp = MessageDigest.getInstance("SHA1");
			mdTemp.update(str.getBytes("UTF-8"));

			byte[] md = mdTemp.digest();
			int j = md.length;
			char buf[] = new char[j * 2];
			int k = 0;
			for (int i = 0; i < j; i++) {
				byte byte0 = md[i];
				buf[k++] = hexDigits[byte0 >>> 4 & 0xf];
				buf[k++] = hexDigits[byte0 & 0xf];
			}
			return new String(buf);
		} catch (Exception e) {
			// TODO: handle exception
			return null;
		}
	} %><%String userName = "GZdykj";
		String mobile = "15626149425";
		String orderMeal = "20";
		String orderTime = "1";
		String msgId = "1701152150415";
		String range = "0";
		String key = "9C234FEE-0FBF-4368-A938-B9C28F89E7C8";
		String url = "http://103.254.76.76:8082/apiFlow/order/singleNumber";
		
		String returnurl = "http://120.24.156.98:9302/ll_sendbuf/baimiaoreturn.jsp";
		String sign = "";
		String timeStamp = System.currentTimeMillis() / 1000 + "";
		String signbef = "userName"+userName+"mobile"+mobile+"orderMeal"+orderMeal+"timeStamp"+timeStamp+"key"+key;
		sign = getSha1(signbef);
		JSONObject json = new JSONObject();
		json.put("userName", userName);
		json.put("mobile",mobile );
		json.put("orderMeal", orderMeal);
		json.put("orderTime",orderTime );
		json.put("msgId", msgId);
		json.put("range", range);
		json.put("sign", sign);
		json.put("returnurl", returnurl);
		json.put("timeStamp",timeStamp );
		String ret = HttpAccess.postJsonRequest(url, json.toString(), "utf-8", "yushuo");
	
		//这里判断结果, 每个通道情况不同, 成功的保存 success 到 result 中并返回到 request.jsp
		if (ret != null && ret.trim().length() > 0) {
						out.print(ret);
			
		} else {
		}
		


	//Log.logout("String = " + str, 0);
	//out.print((new MsgBufQuerier()).jsonRpc(str));
	//out.print("hello");
%>