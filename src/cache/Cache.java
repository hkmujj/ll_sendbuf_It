package cache;

import java.util.HashMap;
import java.util.Map;

public class Cache {
	
	//private static Logger logger = LogManager.getLogger(Cache.class.getName());
	
	public static HashMap<String, Route> routemap = new HashMap<String, Route>();

	public static void getConnection(String routeid){
		Route route = routemap.get(routeid);
		if(route == null){
			return;
		}
		while(true){
			if(route.addConnection()){
				break;
			}
			mysleep(1);
		}
	}
	
	public static void getStatusConnection(String routeid){
		Route route = routemap.get(routeid);
		if(route == null){
			return;
		}
		while(true){
			if(route.addStatusConnection()){
				break;
			}
			mysleep(1);
		}
	}
	
	public static void releaseConnection(String routeid){
		Route route = routemap.get(routeid);
		if(route == null){
			return;
		}
		route.releaseConnection();
	}
	
	public static void releaseStatusConnection(String routeid){
		Route route = routemap.get(routeid);
		if(route == null){
			return;
		}
		route.releaseStatusConnection();
	}
	
	public static boolean getRouteStatus(String routeid){
		Route route = routemap.get(routeid);
		if(route == null){
			return false;
		}
		if(route.status == 0 || route.status == 2){
			return true;
		}
		return false;
	}
	
	public static boolean needRouteStatus(String routeid){
		Route route = routemap.get(routeid);
		if(route == null){
			return false;
		}
		if(route.status == 0 || route.status == 2){
			return true;
		}
		return false;
	}
	
	public static Map<String, String> getRouteParams(String routeid){
		Route route = routemap.get(routeid);
		if(route == null){
			return null;
		}
		return route.api_params;
	}
	
	public static String getSendJsp(String routeid){
		Route route = routemap.get(routeid);
		if(route == null){
			return null;
		}
		return route.api_mturl;
	}
	
	public static String getRouteStatusJsp(String routeid){
		Route route = routemap.get(routeid);
		if(route == null){
			return null;
		}
		return route.api_rpurl;
	}
	
	/*
	public static String getPackageCode(String routeid, String packageid){
		Route route = routemap.get(routeid);
		if(route == null){
			return null;
		}
		return route.api_packagecode.get(packageid);
	}
	*/
	
	public static boolean checkNumber(String routeid, String num){
		Route route = routemap.get(routeid);
		if(route == null){
			return false;
		}
		long phone = 0;
		try {
			phone = Long.parseLong(num);
		} catch (Exception e) {
		}
		if(phone == 0){
			return false;
		}
		return route.checkNumber(phone);
	}
	
	public static void addNumberCount(String routeid, String num){
		Route route = routemap.get(routeid);
		if(route == null){
			return;
		}
		long phone = 0;
		try {
			phone = Long.parseLong(num);
		} catch (Exception e) {
		}
		if(phone == 0){
			return;
		}
		route.addNumberCount(phone);
	}
	
	private static void mysleep(long t){
		try {
			Thread.sleep(t);
		} catch (InterruptedException e) {
			e.printStackTrace();
		}
	}
}
