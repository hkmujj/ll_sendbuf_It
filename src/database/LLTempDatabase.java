package database;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import util.TimeUtils;
import net.sf.json.JSONObject;

public class LLTempDatabase {
	
	private static Logger logger = LogManager.getLogger(LLTempDatabase.class.getName());
	
	public static void getStatus(String mark, String[] ids, JSONObject obj, String idx){
		if(ids.length <= 0){
			return;
		}
		
		StringBuffer idsb = new StringBuffer();
		for(int i = 0; i < ids.length; i++){
			if(i > 0){
				idsb.append(",'");
			}else{
				idsb.append("'");
			}
			idsb.append(ids[i]);
			idsb.append("'");
		}
		
		Connection conn = null;
		PreparedStatement psm = null;
		ResultSet rs = null;
		try {
			conn = DatabaseUtils.getLLTempDBConnByJNDI();
			if(conn == null){
				return;
			}
			
			StringBuffer sqlbuf = new StringBuffer();
			sqlbuf.append("select taskid,status,info from ll_reports");
			sqlbuf.append(idx);
			sqlbuf.append(" where mark=? and taskid in(");
			sqlbuf.append(idsb.toString());
			sqlbuf.append(")");
			psm = conn.prepareStatement(sqlbuf.toString());
			psm.setString(1, mark);
			
			logger.info("sql1 = " + psm.toString());
			
			rs = psm.executeQuery();
			
			StringBuffer sb = new StringBuffer();
			while(rs.next()){
				String taskid = rs.getString("taskid");
				
				if(sb.length() > 0){
					sb.append(",'");
				}else{
					sb.append("'");
				}
				sb.append(taskid);
				sb.append("'");
				
				String status = rs.getString("status");
				String info = rs.getString("info");
				
				JSONObject rp = new JSONObject();
				if(status.equals("0")){
					rp.put("code", 0);
					rp.put("message", "success");
				}else{
					rp.put("code", status);
					rp.put("message", info);
				}
				rp.put("resp", "");
				obj.put(taskid, rp);
			}			
			
			rs.close();
			rs = null;
			psm.close();
			psm = null;
			
			if(sb.length() > 0){
				sqlbuf.delete(0, sqlbuf.length());
				sqlbuf.append("delete from ll_reports");
				sqlbuf.append(idx);
				sqlbuf.append(" where mark=? and taskid in(");
				sqlbuf.append(sb.toString());
				sqlbuf.append(")");
				psm = conn.prepareStatement(sqlbuf.toString());
				psm.setString(1, mark);
				
				logger.info("sql2 = " + psm.toString());
				
				psm.executeUpdate();
				
				psm.close();
				psm = null;
			}
			
			conn.close();
			conn = null;
		} catch (Exception e) {
			logger.warn("LLTempDatabase getStatus error", e);
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
	}
	
	public static void addReport(String mark, String taskid, String status, String info, String idx){
		for(int k = 0; k < 4; k++){
			Connection conn = null;
			PreparedStatement psm = null;
			StringBuffer sb = new StringBuffer();
			try {
				conn = DatabaseUtils.getLLTempDBConnByJNDI();
				if(conn == null){
					mysleep(100);
					continue;
				}			
				sb.append("insert into ll_reports");
				sb.append(idx);
				sb.append(" (mark,taskid,status,info)");  //11
				sb.append(" values");
				sb.append("(?,?,?,?)");
				psm = conn.prepareStatement(sb.toString());

				psm.setString(1, mark);
				psm.setString(2, taskid);
				psm.setString(3, status);
				psm.setString(4, info);

				psm.executeUpdate();
				
				psm.close();
				psm = null;
				conn.close();
				conn = null;
				
				break;
			} catch (Exception e) {
				logger.warn(e.getMessage(), e);
				e.printStackTrace();
				mysleep(100);
			} finally {
				try { 
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
		}
	}
	
	public static void putMap(String mark, String linkkey, String linkvalue, String idx){
		for(int k = 0; k < 4; k++){
			Connection conn = null;
			PreparedStatement psm = null;
			StringBuffer sb = new StringBuffer();
			try {
				conn = DatabaseUtils.getLLTempDBConnByJNDI();
				if(conn == null){
					mysleep(100);
					continue;
				}			
				sb.append("insert into ll_map");
				sb.append(idx);
				sb.append(" (mark,linkkey,linkvalue,createtime)");  //11
				sb.append(" values");
				sb.append("(?,?,?,?)");
				psm = conn.prepareStatement(sb.toString());

				psm.setString(1, mark);
				psm.setString(2, linkkey);
				psm.setString(3, linkvalue);
				psm.setString(4, TimeUtils.getTimeString());

				psm.executeUpdate();
				
				psm.close();
				psm = null;
				conn.close();
				conn = null;
				
				break;
			} catch (Exception e) {
				logger.warn(e.getMessage(), e);
				e.printStackTrace();
				mysleep(100);
			} finally {
				try { 
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
		}
	}
	
	public static String getMapValue(String mark, String linkkey, String idx){
		Connection conn = null;
		PreparedStatement psm = null;
		ResultSet rs = null;
		
		String ret = null;
		try {
			conn = DatabaseUtils.getLLTempDBConnByJNDI();
			if(conn == null){
				return null;
			}
			
			StringBuffer sqlbuf = new StringBuffer();
			sqlbuf.append("select linkvalue from ll_map");
			sqlbuf.append(idx);
			sqlbuf.append(" where mark=? and linkkey=?");
			psm = conn.prepareStatement(sqlbuf.toString());
			psm.setString(1, mark);
			psm.setString(2, linkkey);
			
			logger.info("getMapValue sql = " + psm.toString());
			
			rs = psm.executeQuery();
			
			while(rs.next()){
				ret = rs.getString("linkvalue");
			}
			
			rs.close();
			rs=null;
			
			psm.close();
			psm=null;
		
			conn.close();
			conn = null;
		} catch (Exception e) {
			logger.warn("LLTempDatabase getMapValue error", e);
			e.printStackTrace();
		} finally {
			try {
				if(rs != null){
					if(!rs.isClosed()){
						rs.close();
					}
					rs = null;
				}  
				if(psm != null){
					if(!psm.isClosed()){
						psm.close();
					}
					psm = null;
				} 				  
				if(conn != null){
					if(!conn.isClosed()){
						conn.close();
					}
					conn = null;
				}
			} catch (Exception e2) {
			}
        }	
		return ret;
	}
	
	public static void deleteMapData(String mark, String linkkey, String idx){
		Connection conn = null;
		PreparedStatement psm = null;
		try {
			conn = DatabaseUtils.getLLTempDBConnByJNDI();
			if(conn == null){
				return;
			}
			
			StringBuffer sqlbuf = new StringBuffer();
			sqlbuf.append("delete from ll_map");
			sqlbuf.append(idx);
			sqlbuf.append(" where mark=? and linkkey=?");
			psm = conn.prepareStatement(sqlbuf.toString());
			psm.setString(1, mark);
			psm.setString(2, linkkey);
			
			logger.info("deleteMapData sql = " + psm.toString());
			
			psm.executeUpdate();
			
			psm.close();
			psm=null;
		
			conn.close();
			conn = null;
		} catch (Exception e) {
			logger.warn("LLTempDatabase deleteMapData error", e);
			e.printStackTrace();
		} finally {
			try {
				if(psm != null){
					if(!psm.isClosed()){
						psm.close();
					}
					psm = null;
				} 				  
				if(conn != null){
					if(!conn.isClosed()){
						conn.close();
					}
					conn = null;
				}
			} catch (Exception e2) {
			}
        }	
	}
	
	private static void mysleep(long t){
		try {
			Thread.sleep(t);
		} catch (InterruptedException e) {
			e.printStackTrace();
		}
	}
	
}
