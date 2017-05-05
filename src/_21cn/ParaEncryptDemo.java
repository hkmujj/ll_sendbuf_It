package _21cn;

import http.HttpAccess;

import java.util.HashMap;
import java.util.Map;
import java.util.Map.Entry;

/**
 *@author: XiXiaoyu
 *@date：2016年4月21日 下午3:06:59
 *@version 1.0
 */
public class ParaEncryptDemo {
	
	/**
	 * 对参数进行加密以及签名
	 * @param params
	 * @param appId
	 * @param clientType
	 * @param appSecret
	 * @param signSecret
	 * @return
	 */
	public static Map<String, Object> generatePostSecurityOpenApiRequestUrl(
			String params, String appId, String clientType, String appSecret, String signSecret) {
		Map<String, Object> map = new HashMap<String, Object>();
		map.put("appId", appId);
		map.put("clientType", clientType);
		String format = "json";
		String version = "1.5";
		map.put("format", format);
		map.put("version", version);
		try {
			String ciperParas = XXTea.encrypt(params, "UTF-8", ByteFormat.toHex(appSecret.getBytes()));
			String signPlainText = appId + clientType + format + version + ciperParas;
			byte[] data = StringUtil.hex2Bytes(ByteFormat.toHex(signPlainText.getBytes()));
			byte[] key = StringUtil.hex2Bytes(ByteFormat.toHex(signSecret.getBytes()));
			String signature = MACTool.encodeHmacMD5(data, key);
			map.put("paras", ciperParas);
			map.put("sign", signature);
		} catch (Exception e) {
			e.printStackTrace();
		}
		return map;
	}
	
	public static void main(String[] args) {
		String appId="8013818507";
		String clientType="1";
		String params="mobile=18999999999";
		String appSecret ="yLmrAVi8kny8VFTI3NpeUpcHthODinNU";
		String signSecret="yLmrAViHtrkuAFvPPO754MHHcHthO";
		String url="http://nb.189.cn/portal/open/enterCoinExchange.do";

		Map<String, Object> map = generatePostSecurityOpenApiRequestUrl(params, appId, clientType, appSecret, signSecret);
		HashMap<String, String> paras = new HashMap<String, String>();
		for(Entry<String, Object> entry : map.entrySet()){
			paras.put(entry.getKey(), entry.getValue().toString());
		}
		
		HttpAccess.getNameValuePairRequest(url, paras, "utf-8", "21cncoin");
	}
}
