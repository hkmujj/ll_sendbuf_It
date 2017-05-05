<%@ page language="java" import="java.util.*,database.LLTempDatabase" pageEncoding="UTF-8"%><%
	String path = request.getContextPath();
	String basePath = request.getScheme()+"://"+request.getServerName()+":"+request.getServerPort()+path+"/";

	String acr = request.getParameter("orderid");
   	if(session.getAttribute("admin") != null && session.getAttribute("admin").equals("yes")){
   		//session.setAttribute("admin", "yes");
   	}else{
   		out.println("~");
  		return;
   	}
    
    if(acr == null || acr.trim().length() <= 0){
    	out.println("订单号为空");
  		return;
    }
    
    acr = acr.trim();
    
    String rpurl = LLTempDatabase.getMapValue("21cn", acr, "01"); 
    
    if(rpurl == null || rpurl.length() <= 0){
    	rpurl = LLTempDatabase.getMapValue("21cncoin", acr, "04"); 
    }
    
    if(rpurl == null || rpurl.length() <= 0){
    	out.println("查询不到对应订单");
    }else{
    	out.println(rpurl.replace("&", "&amp;"));
    }
%>