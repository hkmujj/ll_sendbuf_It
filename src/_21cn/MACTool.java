package _21cn;

import javax.crypto.Mac;
import javax.crypto.SecretKey;
import javax.crypto.spec.SecretKeySpec;
import javax.xml.bind.annotation.adapters.HexBinaryAdapter;

public class MACTool {  
 
    public static String encodeHmacMD5(byte[] data, byte[] key) throws Exception {  
        // 还原密钥  
        SecretKey secretKey = new SecretKeySpec(key, "HmacMD5");  
        // 实例化Mac  
        Mac mac = Mac.getInstance(secretKey.getAlgorithm());  
        //初始化mac  
        mac.init(secretKey);  
        //执行消息摘要  
        byte[] digest = mac.doFinal(data);  
        return new HexBinaryAdapter().marshal(digest);//转为十六进制的字符串
    }  
    
	public static String encodeHmacMD5(String sigPlainText, String appSecret) throws Exception {
		byte[] data = StringUtil.hex2Bytes(ByteFormat.toHex(sigPlainText.getBytes()));
		byte[] key = StringUtil.hex2Bytes(ByteFormat.toHex(appSecret.getBytes()));
		return encodeHmacMD5(data, key);
	}
}