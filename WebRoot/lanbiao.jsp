<%@ page language="java" import="java.util.*,http.HttpAccess,util.TimeUtils" pageEncoding="UTF-8"%><%
	String path = request.getContextPath();
	String basePath = request.getScheme()+"://"+request.getServerName()+":"+request.getServerPort()+path+"/";

	String acr = request.getParameter("acr");
   	if((session.getAttribute("admin") != null && session.getAttribute("admin").equals("yes")) || (acr != null && acr.equals("mchuanx"))){
   		session.setAttribute("admin", "yes");
   	}else{
   		out.println("~");
  		return;
   	}
   
   	String orderid = request.getParameter("orderid");
	String code = request.getParameter("code");
	String message = request.getParameter("message");
	String linkid = request.getParameter("linkid");
	
   	String xml = "<root><status taskid=\"" 
				+ orderid
				+ "\" code=\"" 
				+ code
				+ "\" message=\"" 
				+ message 
				+ "\" time=\"" 
				+ TimeUtils.getTimeString() 
				+ "\" linkid=\"" 
				+ linkid
				+ "\"/></root>";
					
		String url = "http://127.0.0.1:9302/ll_sendbuf/lanbiaoreturn.jsp";
		String ret = HttpAccess.postXmlRequest(url, xml, "utf-8", "www");
		out.println("ret = " + ret);
%>