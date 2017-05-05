package util;

import java.text.SimpleDateFormat;
import java.util.Date;

public class TimeUtils {
		
	public static String getTimeString(){
		Date b = new Date();
		SimpleDateFormat format = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");  
        String sb = format.format(b.getTime()); 
		return sb;
	}
	
	public static String getSysLogTimeString(){
		Date b = new Date();
		SimpleDateFormat format = new SimpleDateFormat("dd-HH:mm:ss");  
        String sb = format.format(b.getTime()); 
		return sb;
	}
	
	public static String getTimeString(long v){
		Date b = new Date();
		SimpleDateFormat format = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");  
        String sb = format.format(b.getTime() + v * 1000); 
		return sb;
	}
	
	public static String getDateString(){
		long currentTime = System.currentTimeMillis();
		SimpleDateFormat formatter = new SimpleDateFormat("yyyyMMdd");
		Date date = new Date(currentTime);
		return formatter.format(date);
	}
	
	public static String getTimeStamp(){
		Date b = new Date();
		SimpleDateFormat format = new SimpleDateFormat("yyyyMMddHHmmss");  
        String sb = format.format(b.getTime()); 
		return sb;
	}
	
	public static Date getDate(String datestr){
		SimpleDateFormat formatter = new SimpleDateFormat("yyyyMMdd");
		Date date = null;
		try {
			date = formatter.parse(datestr);
		} catch (Exception e) {
			e.printStackTrace();
		}
		return date;
	}

	public static String getDateString(long t){
		SimpleDateFormat formatter = new SimpleDateFormat("yyyyMMdd");
		Date date = new Date(t);
		return formatter.format(date);
	}
}
