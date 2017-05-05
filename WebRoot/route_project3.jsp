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
<%!
	public static String getDateString(){
		long currentTime = System.currentTimeMillis();
		SimpleDateFormat formatter = new SimpleDateFormat("yyyyMMdd");
		Date date = new Date(currentTime);
		return formatter.format(date);
	}
 %>>
<%
	out.clearBuffer();
	//报警线
	double YY_YX_successrate = 0.15;//行业+营销
	double YY_successrate = 0.10;//行业
	double YX_successrate = 0.20;//营销
	String num = "1000";

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

		JSONObject item = new JSONObject();

		NumberFormat nFromat = NumberFormat.getPercentInstance();
		nFromat.setMaximumFractionDigits(2);

		item.put("item", "route_rate");
		JSONArray rateary = new JSONArray();

		//通道成功率报警实例
		try{
			InitialContext ctx = new InitialContext();
			conn = ((DataSource)ctx.lookup("java:comp/env/jdbc/main")).getConnection();
			if(conn == null){
				return;
			}
			String sql = "select a.routeid,sum(a.totalsended) as totalsended,sum(a.totalsuccess) as totalsuccess,sum(a.totalfail) as totalfail,b.name from sms_dayreport as a left join sms_routes as b on a.routeid=b.routeid where a.rdate="+getDateString()+" and a.totalsended>"+num+" group by a.routeid";
			psm = conn.prepareStatement(sql);
			rs = psm.executeQuery();
			while(rs.next()){
				JSONObject node = new JSONObject();
				float totalsended = rs.getFloat("totalsended");
				float totalsuccess = rs.getFloat("totalsuccess");
				float totalfail = rs.getFloat("totalfail");
				float routesu_rate = totalsuccess / totalsended;
				float routefa_rate = totalfail / totalsended;
				String name = rs.getString("name");
				if(name.indexOf("行业+营销") >= 0){
					if(routefa_rate > YY_YX_successrate){
						node.put("routeid", rs.getString("routeid"));
						node.put("name", "行业+营销");
						node.put("totalsended", totalsended);
/* 						node.put("totalsuccess_rate", nFromat.format(routesu_rate));
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
				alarmreason.add("[" + routeid + "]" + name + "失败率超过" + node.getString("standard_rate"));
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

		item.put("ary", rateary);
		JSONArray ary = new JSONArray();
		ary.add(item);
		retjson.put("spots", ary);

	}catch(Exception e){
		e.printStackTrace();
	}

	retjson.put("alarmlevel", "" + alarmlevel);

	retjson.put("alarmreason", alarmreason);

	System.out.println("vst=" + retjson.toJSONString());
	out.print(retjson.toJSONString());
%>