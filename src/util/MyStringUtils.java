package util;

import java.io.InputStream;
import java.util.Random;

public class MyStringUtils {
	
	public static String inputStringToString(InputStream in){
		if(in == null){
			return null;
		}
		try {		
			StringBuffer out = new StringBuffer(); 
			byte[] b = new byte[4096];
			for (int n; (n = in.read(b)) != -1;) {
				out.append(new String(b, 0, n, "utf-8"));
			}
			return out.toString();
		} catch (Exception e) {
			//
		}
		return "";
	}
	
	
	public static String getRandomString(int length) { //length表示生成字符串的长度
	    String base = "abcdefghijklmnopqrstuvwxyz0123456789";  
	    Random random = new Random();   
	    StringBuffer sb = new StringBuffer();   
	    for (int i = 0; i < length; i++) {   
	        int number = random.nextInt(base.length());   
	        sb.append(base.charAt(number));   
	    }   
	    return sb.toString();   
	 }  
	
}
