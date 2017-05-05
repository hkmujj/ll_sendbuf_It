<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.text.NumberFormat"%>
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
<%!public static String getDateString() {
		long currentTime = System.currentTimeMillis();
		SimpleDateFormat formatter = new SimpleDateFormat("yyyyMMdd");
		Date date = new Date(currentTime);
		return formatter.format(date);
	}

	public static HashMap<String, ArrayList<Float>> route_change = new HashMap<String, ArrayList<Float>>();
	public static HashMap<String, String> route_cache = new HashMap<String, String>();%>

<%
	out.clearBuffer();
	//报警线
	double YY_YX_successrate = 0.15;//行业+营销
	double YY_successrate = 0.10;//行业
	double YX_successrate = 0.20;//营销
	String num = "1000";//检测通道基数
	int change_num = 100;//通道短信变化基数
	String[] point_route = { "4019","2001","3009","3001","3004","3007","1060","1069","1055","1022","1050","1068","1061","1006","1059" };//重点监测通道号

//通道缓存sql语句生成
	StringBuffer sb = new StringBuffer();
	for(int i = 0; i < point_route.length; i++){
		sb.append("(select ");
		sb.append(point_route[i]);
		sb.append(",guid from sendpool_");
		sb.append(point_route[i]);
		sb.append(" limit 1)union all");
	}
	sb.delete(sb.length() - 9, sb.length());

	Connection conn = null;
	PreparedStatement psm = null;
	ResultSet rs = null;
	String route;
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

		JSONObject route_rate = new JSONObject();
		route_rate.put("item", "route_rate");
		JSONArray rateary = new JSONArray();

		JSONObject unkown_status = new JSONObject();
		unkown_status.put("item", "unkown_status");
		JSONArray statusary = new JSONArray();

		JSONObject routecache_obj = new JSONObject();
		routecache_obj.put("item", "route_cache");
		JSONArray routecacheary = new JSONArray();

		NumberFormat nFromat = NumberFormat.getPercentInstance();
		nFromat.setMaximumFractionDigits(2);

		if(route_change.get(getDateString()) != null){

		}else{
			route_change.clear();
			route_change.put(getDateString(), new ArrayList<Float>());
		}

		//通道成功率报警实例
		try{
			InitialContext ctx = new InitialContext();
			conn = ((DataSource) ctx.lookup("java:comp/env/jdbc/main")).getConnection();
			if(conn == null){
				return;
			}
			String sql = "select a.routeid,sum(a.totalsended) as totalsended,sum(a.totalsuccess) as totalsuccess,sum(a.totalfail) as totalfail,b.name from sms_dayreport as a left join sms_routes as b on a.routeid=b.routeid where a.rdate="
					+ getDateString() + " and a.totalsended>" + num + " group by a.routeid";
			psm = conn.prepareStatement(sql);
			rs = psm.executeQuery();
			while(rs.next()){
				String routeid = rs.getString("routeid");
				float totalsended = rs.getFloat("totalsended");
				float totalsuccess = rs.getFloat("totalsuccess");
				float totalfail = rs.getFloat("totalfail");
				float routesu_rate = totalsuccess / totalsended;
				float routefa_rate = totalfail / totalsended;
				String name = rs.getString("name");

				//状态未知 通道卡死   arr[0,1,2] 发送数，成功数，失败数
			if(name.indexOf("行业+营销") >= 0 || name.indexOf("行业") >= 0){
				JSONObject status_json = new JSONObject();
				ArrayList<Float> routearr = route_change.get(routeid);
				if(routearr != null){
					if((totalsended - routearr.get(0)) > change_num){
						if(routearr.get(1) == totalsuccess && routearr.get(2) == totalfail){
							status_json.put("routeid", routeid);
							status_json.put("totalsended", totalsended);
							status_json.put("unknow_status", totalsended - routearr.get(0));
							statusary.add(status_json);
						}else{
							routearr.set(0, totalsended);
							routearr.set(1, totalsuccess);
							routearr.set(2, totalfail);
						}
					}else if(routearr.get(1) == totalsuccess && routearr.get(2) == totalfail){
					}else{
						routearr.set(0, totalsended);
						routearr.set(1, totalsuccess);
						routearr.set(2, totalfail);
					}
				}else{
					ArrayList<Float> arr = new ArrayList<Float>();
					arr.add(totalsended);
					arr.add(totalsuccess);
					arr.add(totalfail);
					route_change.put(routeid, arr);
				}
			}
				//通道成功率
				JSONObject node = new JSONObject();
				if(name.indexOf("行业+营销") >= 0){
					if(routefa_rate > YY_YX_successrate){
						node.put("routeid", rs.getString("routeid"));
						node.put("name", "行业+营销");
						node.put("totalsended", totalsended);
						/* 				node.put("totalsuccess_rate", nFromat.format(routesu_rate));
						 node.put("totalfail_rate", nFromat.format(routefa_rate)); */
						node.put("standard_rate", nFromat.format(YY_YX_successrate));
						rateary.add(node);
					}
				}else if(name.indexOf("行业") >= 0){
					if(routefa_rate > YY_successrate){
						node.put("routeid", rs.getString("routeid"));
						node.put("name", "行业");
						node.put("totalsended", totalsended);
						/*	 					node.put("totalsuccess_rate", nFromat.format(routesu_rate));
						 node.put("totalfail_rate", nFromat.format(routefa_rate));   */
						node.put("standard_rate", nFromat.format(YY_successrate));
						rateary.add(node);
					}
				}else if(name.indexOf("营销") >= 0){
					if(routefa_rate > YX_successrate){
						node.put("routeid", rs.getString("routeid"));
						node.put("name", "营销");
						node.put("totalsended", totalsended);
						/* 						node.put("totalsuccess_rate", nFromat.format(routesu_rate));
						 node.put("totalfail_rate", nFromat.format(routefa_rate)); */
						node.put("standard_rate", nFromat.format(YX_successrate));
						rateary.add(node);
					}
				}else{
					if(routesu_rate < YY_successrate){
						node.put("routeid", rs.getString("routeid"));
						node.put("name", rs.getString("name"));
						node.put("totalsended", totalsended);
						/* 						node.put("totalsuccess_rate", nFromat.format(routesu_rate));
						 node.put("totalfail_rate", nFromat.format(routefa_rate)); */
						node.put("standard_rate", nFromat.format(YY_successrate));
						rateary.add(node);
					}
				}

			}
			for(int y = 0; y < rateary.size(); y++){
				JSONObject node = rateary.getJSONObject(y);
				String routeid = node.getString("routeid");
				String name = node.getString("name");
				String totalsended = node.getString("totalsended");
				String totalsuccess_rate = node.getString("totalsuccess_rate");
				String totalfail_rate = node.getString("totalfail_rate");
				int lv = 2;
				if(alarmlevel < lv){
					alarmlevel = lv;
				}
				alarmreason.add("【" + routeid + "】" + name + "失败率过高");
			}

			for(int y = 0; y < statusary.size(); y++){
				JSONObject node = statusary.getJSONObject(y);
				String routeid = node.getString("routeid");
				int lv = 2;
				if(alarmlevel < lv){
					alarmlevel = lv;
				}
				alarmreason.add("【" + routeid + "】未知状态超过100条");
			}

			rs.close();
			rs = null;
			psm.close();
			psm = null;
			conn.close();
			conn = null;
		}catch(NamingException e){
			e.printStackTrace();
		}finally{
			try{
				if(rs != null){
					rs.close();
					rs = null;
				}
				if(psm != null){
					psm.close();
					psm = null;
				}
				if(conn != null){
					if(!conn.isClosed()){
						conn.close();
					}
				}
			}catch(Exception e2){
			}
		}

		//通道缓存池报警
		try{
			InitialContext ctx = new InitialContext();
			conn = ((DataSource) ctx.lookup("java:comp/env/jdbc/work")).getConnection();
			if(conn == null){
				return;
			}
			String sql = sb.toString();
			psm = conn.prepareStatement(sql);
			rs = psm.executeQuery();
			while(rs.next()){
				String routeid = rs.getString(point_route[0]);
				String guid = rs.getString("guid");
				JSONObject routecache_json = new JSONObject();
				if(route_cache.get(routeid) != null){
					if(route_cache.get(routeid).equals(guid)){
						routecache_json.put("routeid", routeid);
						routecache_json.put("guid", guid);
						routecacheary.add(routecache_json);
					}else{
						route_cache.put(routeid, guid);
					}
				}
				{
					route_cache.put(routeid, guid);
				}
			}

			for(int y = 0; y < routecacheary.size(); y++){
				JSONObject node = routecacheary.getJSONObject(y);
				String routeid = node.getString("routeid");
				String guid = node.getString("guid");
				int lv = 2;
				if(alarmlevel < lv){
					alarmlevel = lv;
				}
				alarmreason.add("【" + routeid + "】短信发送卡在缓存池");
			}

			rs.close();
			rs = null;
			psm.close();
			psm = null;
			conn.close();
			conn = null;
		}catch(NamingException e){
			e.printStackTrace();
		}finally{
			try{
				if(rs != null){
					rs.close();
					rs = null;
				}
				if(psm != null){
					psm.close();
					psm = null;
				}
				if(conn != null){
					if(!conn.isClosed()){
						conn.close();
					}
				}
			}catch(Exception e2){
			}
		}
		route_rate.put("ary", rateary);

		unkown_status.put("ary", statusary);

		routecache_obj.put("ary", routecacheary);
		
		JSONArray ary = new JSONArray();
		ary.add(route_rate);
		ary.add(unkown_status);
		ary.add(routecache_obj);

		retjson.put("spots", ary);

	}catch(Exception e){
		e.printStackTrace();
	}

	retjson.put("alarmlevel", "" + alarmlevel);

	retjson.put("alarmreason", alarmreason);

	out.print(retjson.toJSONString());
%>