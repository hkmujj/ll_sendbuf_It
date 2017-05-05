<%@page import="database.DatabaseUtils"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.PreparedStatement"%>
<%@page import="java.sql.Connection"%>
<%@page import="javax.sql.DataSource"%>
<%@page import="javax.naming.NamingException"%>
<%@page import="org.dom4j.Element"%>
<%@page import="org.dom4j.DocumentException"%>
<%@page import="org.dom4j.io.SAXReader"%>
<%@page import="org.dom4j.Document"%>
<%@page import="com.alibaba.fastjson.JSONArray"%>
<%@page import="java.text.DecimalFormat"%>
<%@page import="java.util.concurrent.ForkJoinPool"%>
<%@page import="java.util.concurrent.ForkJoinTask"%>
<%@page import="java.io.File"%>
<%@page import="java.util.concurrent.RecursiveTask"%>
<%@page import="com.alibaba.fastjson.JSONObject"%>
<%@page import="java.lang.management.ManagementFactory"%>
<%@page import="java.io.InputStreamReader"%>
<%@page import="java.io.BufferedReader"%>
<%@page import="javax.naming.InitialContext"%>
<%@page import="org.apache.tomcat.dbcp.dbcp.BasicDataSource"%>
<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%
	out.clearBuffer();
	
	Connection conn = null;
	PreparedStatement psm = null;
	ResultSet rs = null;

	String acr = request.getParameter("mchuan");
	if((session.getAttribute("admin") != null && session.getAttribute("admin").equals("yes")) || (acr != null && acr.equals("cube_1002"))){
		session.setAttribute("admin", "yes");
	}else{
		out.println("~");
		return;
	}
	
	JSONObject retjson = new JSONObject();
	
	int alarmlevel = 0;
	
	ArrayList<String> alarmreason = new ArrayList<String>();
	
	try{
		
		String directory = request.getServletContext().getRealPath("");
		
		retjson.put("directory", directory);
		
		JSONObject item = new JSONObject();
		
		JSONObject stock = new JSONObject();
		
		SAXReader reader = new SAXReader();
		Document document = null;
		try {
			document = reader.read(directory + "\\META-INF\\context.xml");
		} catch (DocumentException e) {
			e.printStackTrace();
		}
		
		Element root = document.getRootElement();
		ArrayList<String> dbnames = new ArrayList<String>();
		List nodes = root.elements("Resource");
		for (Iterator it = nodes.iterator(); it.hasNext();) {
			Element elm = (Element) it.next();
			 if (elm.attributeValue("type").equals("javax.sql.DataSource")) {
				String name = elm.attributeValue("name");
				dbnames.add(name);
			}
		}
		
		item.put("item", "dbconnection");
		stock.put("item", "stock");
		JSONArray dbary = new JSONArray();
		JSONArray stockary = new JSONArray();
		
		InitialContext ctx=null;
		try {
			ctx = new InitialContext();
	
		    for (int i = 0; i < dbnames.size(); i++) {
		    	try {
			        String name = dbnames.get(i);
			        //System.out.println(name);
			        DataSource bds = (DataSource) ctx.lookup("java:comp/env/" + name);
			        JSONObject node=new JSONObject();
			        if(name.indexOf("jdbc/") == 0){
						name = name.substring(5);
					}
			        node.put("dbname", name);
			        node.put("maxactive", ((BasicDataSource)bds).getMaxActive());
			        node.put("numactive", ((BasicDataSource)bds).getNumActive());
			        //node.put("maxidle", ((BasicDataSource)bds).getMaxIdle());
			        //node.put("minidle", ((BasicDataSource)bds).getMinIdle());
			        //node.put("numidle", ((BasicDataSource)bds).getNumIdle());
			        dbary.add(node);
			        
		    	} catch (NamingException e) {
					e.printStackTrace();
				}
		    }
		} catch (NamingException e) {
			e.printStackTrace();
		}
		
		//货存余额报警实例
    	try {
	        conn = DatabaseUtils.getLLMainDBConnByJNDI();
	        if(conn == null){
				return;
			}		
			String sql = "select * from ll_stocks where balance<warn";
			psm = conn.prepareStatement(sql);
			rs = psm.executeQuery();
			while(rs.next()){
		        JSONObject node=new JSONObject();
		        node.put("stock", rs.getString("STOCK"));
		        node.put("balance", rs.getString("BALANCE"));
		        node.put("warn", rs.getString("WARN"));
		        stockary.add(node);
	        }
	        for(int y = 0; y < stockary.size(); y++){
	        	JSONObject node = stockary.getJSONObject(y);
	        	String stock_value = node.getString("stock");
	        	String balance_value = node.getString("balance");
	        	String warn_value = node.getString("warn");
	        	
        		int lv = 2;
    	    	if(alarmlevel < lv){
    	    		alarmlevel = lv;
    	    	}
  	    			alarmreason.add("[" + stock_value + "]货存余额过低");
	        	retjson.put("balance_value", balance_value);
	        }
	        rs.close();
			rs = null;
			psm.close();
			psm = null;
			conn.close();
			conn = null;
    	} catch (NamingException e) {
			e.printStackTrace();
		}finally {
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
		
		item.put("ary", dbary);
		stock.put("ary", stockary);
		
		JSONArray ary = new JSONArray();
		ary.add(item);
		ary.add(stock);
		retjson.put("spots", ary);
	    
	}catch(Exception e){
		e.printStackTrace();
	}
	
	retjson.put("alarmlevel", "" + alarmlevel);
	
	retjson.put("alarmreason", alarmreason);
    
	System.out.println("vst=" + retjson.toJSONString());
    out.print(retjson.toJSONString());
%>