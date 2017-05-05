package util;

public class MyBase64 {
	
	public static String base64Encode(String orgstr){
		byte[] b = null;  
        String s = null;  
        try {  
            b = orgstr.getBytes("utf-8");  
        } catch (Exception e) {  
            e.printStackTrace();  
        }  
        if (b != null) {  
            s = new org.apache.commons.codec.binary.Base64().encodeToString(b); 
        }  
        return s;
	}
}
