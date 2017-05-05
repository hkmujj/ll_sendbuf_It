package test;
import org.apache.commons.codec.binary.Base64; 
import org.apache.commons.codec.binary.Hex;  

import java.security.GeneralSecurityException; 
import java.security.MessageDigest;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.Date;
public class AuthSample {
	  public static void main(String[] args) {         
		  System.out.println(createAuthHead());     
		  }  
		    public static String createAuthHead() { 
		    	Date date = new Date();
		    	SimpleDateFormat simpleDateFormat = new SimpleDateFormat("yyyyMMddHHmmss");
		    	String timestamp = simpleDateFormat.format(date);
				String needHash = "dyfs" +"de2bb78643494a35b1de33fac921a2ce" + timestamp;   
				byte[] md5result = md5(needHash.getBytes());         String sign = encodeHex(md5result);  
				String nameAndTimestamp = "dyfs" + ":" + timestamp;         
				return "sign=\"" + sign + "\",nonce=\"" +encodeBase64(nameAndTimestamp.getBytes()) + "\"";  
				}  
		    public static String encodeBase64(byte[] input) {     
		    return Base64.encodeBase64String(input);    
			}  
		    public static String encodeHex(byte[] input) { 
			return Hex.encodeHexString(input);    
			}  
		    public static byte[] md5(byte[] input) { 
			return digest(input, "MD5", null, 1);     
			}  
		    public static byte[] digest(byte[] input, String algorithm,   byte[] salt, int iterations)
		    {         
			try {             MessageDigest e = MessageDigest.getInstance(algorithm);   
			if (salt != null) {
			e.update(salt);}  
		       byte[] result = e.digest(input); 
		       for (int i = 1; i < iterations; ++i) { 
					e.reset();
					result = e.digest(result);
					}             
					return result;
					} catch (GeneralSecurityException e) {
					throw new RuntimeException(e);         
					}     
					} 
					
}
