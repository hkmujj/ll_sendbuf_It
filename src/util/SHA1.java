package util;

import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

public class SHA1 {
    
	public static String sha1Encode(String str){
		try {
            MessageDigest digest = java.security.MessageDigest
                    .getInstance("SHA-1");
            digest.update(str.getBytes());
            byte messageDigest[] = digest.digest();
            StringBuffer hexString = new StringBuffer();
            for (int i = 0; i < messageDigest.length; i++) {
                String shaHex = Integer.toHexString(messageDigest[i] & 0xFF);
                if (shaHex.length() < 2) {
                    hexString.append(0);
                }
                hexString.append(shaHex);
            }
            return hexString.toString().toUpperCase();
 
        } catch (NoSuchAlgorithmException e) {
            e.printStackTrace();
        }
        return "";
	}	
}
