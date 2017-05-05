<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%
	String path = request.getContextPath();
	String basePath = request.getScheme()+"://"+request.getServerName()+":"+request.getServerPort()+path+"/";

	String acr = request.getParameter("acr");
   	if((session.getAttribute("admin") != null && session.getAttribute("admin").equals("yes")) || (acr != null && acr.equals("mchuanx"))){
   		session.setAttribute("admin", "yes");
   	}else{
   		out.println("~");
  		return;
   	}
    	
%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
  <head>
    <base href="">
    
    <title>21CN链接查询</title>
	<meta http-equiv="pragma" content="no-cache">
	<meta http-equiv="cache-control" content="no-cache">
	<meta http-equiv="expires" content="0">    
	<meta http-equiv="keywords" content="keyword1,keyword2,keyword3">
	<meta http-equiv="description" content="This is my page">
	<!--
	<link rel="stylesheet" type="text/css" href="styles.css">
	-->
	
	<script type="text/javascript"> 
		var xmlhttp;
		if (window.XMLHttpRequest){// code for IE7+, Firefox, Chrome, Opera, Safari
			xmlhttp=new XMLHttpRequest();
		}else{// code for IE6, IE5
			xmlhttp=new ActiveXObject("Microsoft.XMLHTTP");
		}
				
		xmlhttp.onreadystatechange=function(){
			if (xmlhttp.readyState==4 && xmlhttp.status==200){
				document.getElementById("content").innerHTML=xmlhttp.responseText;
			}
		};
		
		
		function query21cnorder(){
			xmlhttp.open("POST","21cnqueryorder.jsp?orderid=" + document.getElementById("orderid").value);
			xmlhttp.send(null);
		}
	</script>
  </head>
  
  <body>
    <h3>21CN链接查询</h3>
		   订单号：<input type="text" id="orderid" size="30" name="name">&nbsp;&nbsp;&nbsp;
		 <input type="button" value="查询" onclick="query21cnorder()"/>
		 <br><br>
		 <div id="content" style="width:400px; height:300px; border: 1px solid #555; overflow:auto; padding:15px; word-wrap:break-word;">	
			</div>
  </body>
</html>
