package database;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.HashMap;
import java.util.LinkedHashMap;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import cache.Cache;
import cache.Route;

public class LLMainDatabase {
	
	private static Logger logger = LogManager.getLogger(LLMainDatabase.class.getName());

	public static void updateRoutes() {
		Connection conn = null;
		PreparedStatement psm = null;
		ResultSet rs = null;
		try {
			
			conn = DatabaseUtils.getLLMainDBConnByJNDI();
			if(conn == null){
				return;
			}
			
			StringBuffer sqlbuf = new StringBuffer();
			sqlbuf.append("select ");
			sqlbuf.append("id,mt_maxthread,rp_maxspeed,rp_maxthread,api_type,api_params,api_mturl,api_rpurl,monitor,mt_maxdaycount,status");
			sqlbuf.append(" from ll_routes");
			psm = conn.prepareStatement(sqlbuf.toString());
			rs = psm.executeQuery();
			
			HashMap<String, Route> routemap = new HashMap<String, Route>();
			while(rs.next()){
				String id = rs.getString("id");
				
				Route route = null;
				if(Cache.routemap != null){
					route = Cache.routemap.get(id);
				}
				
				if(route == null){
					route = new Route();
				}
				
				route.id = Integer.parseInt(id);
				
				route.mt_maxthread = rs.getInt("mt_maxthread");
				route.rp_maxspeed = rs.getInt("rp_maxspeed");
				route.rp_maxthread = rs.getInt("rp_maxthread");
				
				route.api_type = rs.getString("api_type");
				
				route.api_mturl = rs.getString("api_mturl");
				route.api_rpurl = rs.getString("api_rpurl");
				
				route.monitor = rs.getInt("monitor");
				route.mt_maxdaycount = rs.getInt("mt_maxdaycount");

				route.status = rs.getInt("status");
				
				String api_params = rs.getString("api_params");
				HashMap<String, String> paramsmap = new LinkedHashMap<String, String>();
				if(api_params != null && api_params.trim().length() > 0){
					paramsmap = new LinkedHashMap<String, String>();
					api_params = api_params.replace("\r", "\n");
					api_params = api_params.replace("\n\n", "\n");
					String[] strs = api_params.split("\n");
					for(int i = 0; i < strs.length; i++){
						/*
						String[] entry = strs[i].split("=");
						if(entry.length <= 1){
							continue;
						}
						paramsmap.put(entry[0], entry[1]);
						*/
						int idx = strs[i].indexOf('=');
						if(idx >= 0){
							paramsmap.put(strs[i].substring(0, idx), strs[i].substring(idx + 1, strs[i].length()));
						}
					}
				}
				route.api_params = paramsmap;
				/*
				tmap = packagesmap.get(id);
				if(tmap != null){
					route.api_packagecode = tmap;
				}else{
					route.api_packagecode = new HashMap<String, String>();
				}
				*/
				routemap.put(String.valueOf(route.id), route);
			}
			
			Cache.routemap = routemap;
			
			rs.close();
			rs = null;
			psm.close();
			psm = null;
			conn.close();
			conn = null;
		} catch (Exception e) {
			logger.warn("LLMainDatabase updateRoutes error", e);
			e.printStackTrace();
		} finally {
			try {
				if(rs!=null){
					rs.close();
					rs=null;
				}  
				if(psm!=null){
					psm.close();
					psm=null;
				} 				  
				if(conn != null){
					if(!conn.isClosed()){
						conn.close();
					}
				}
			} catch (Exception e2) {
			}
        }	
		logger.info("route size = " + Cache.routemap.size());
	}
	
}
