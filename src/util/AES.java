package util;

import java.security.InvalidAlgorithmParameterException;
import java.security.InvalidKeyException;
import java.security.NoSuchAlgorithmException;

import javax.crypto.BadPaddingException;
import javax.crypto.Cipher;
import javax.crypto.IllegalBlockSizeException;
import javax.crypto.NoSuchPaddingException;
import javax.crypto.spec.IvParameterSpec;
import javax.crypto.spec.SecretKeySpec;

public class AES {
	
	static final String KEY_ALGORITHM = "AES";  

    static final String CIPHER_ALGORITHM_CBC = "AES/CBC/PKCS5Padding";  
    
	public static String aesEncode(String str, String password, String vector){
		try {
			
			Cipher cipher = Cipher.getInstance(CIPHER_ALGORITHM_CBC);           
			SecretKeySpec key = new SecretKeySpec(password.getBytes(), "AES");
			cipher.init(Cipher.ENCRYPT_MODE, key, new IvParameterSpec(vector.getBytes()));
			byte[] encrypt = cipher.doFinal(str.getBytes());
			return encodeBytes(encrypt);
			
		} catch (NoSuchAlgorithmException e1) {
			e1.printStackTrace();
		} catch (NoSuchPaddingException e1) {
			e1.printStackTrace();
		} catch (InvalidKeyException e) {
			e.printStackTrace();
		} catch (InvalidAlgorithmParameterException e) {
			e.printStackTrace();
		} catch (IllegalBlockSizeException e) {
			e.printStackTrace();
		} catch (BadPaddingException e) {
			e.printStackTrace();
		} 
        
		return null;
	}
	
	public static String encodeBytes(byte[] bytes) {
		StringBuffer buffer = new StringBuffer();
		for (int i = 0; i < bytes.length; i++) {
			buffer.append((char) (((bytes[i] >> 4) & 0xF) + ((int) 'a')));
			buffer.append((char) (((bytes[i]) & 0xF) + ((int) 'a')));
		}
		return buffer.toString();
	}
	
	public static String ymAesEncrypt(String str, String password) {
		if (str == null || password == null)
			return null;
		try {
			Cipher cipher = Cipher.getInstance("AES/ECB/PKCS5Padding");
			cipher.init(Cipher.ENCRYPT_MODE,
					new SecretKeySpec(password.getBytes("utf-8"), "AES"));
			byte[] bytes = cipher.doFinal(str.getBytes("utf-8"));
			return org.apache.commons.codec.binary.Base64.encodeBase64String(bytes);
		} catch (Exception e) {
			e.printStackTrace();
			return null;
		}
	}
}
