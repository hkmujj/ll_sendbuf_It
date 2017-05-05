<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%
	String path = request.getContextPath();
	String basePath = request.getScheme()+"://"+request.getServerName()+":"+request.getServerPort()+path+"/";

	String acr = request.getParameter("acr");
   	
   		session.setAttribute("admin", "yes");

%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
  <head>
    <title>肇庆红包</title>
	<meta http-equiv="pragma" content="no-cache">
	<meta http-equiv="cache-control" content="no-cache">
	<meta http-equiv="expires" content="0">    
	<meta http-equiv="keywords" content="keyword1,keyword2,keyword3">
	<meta http-equiv="description" content="This is my page">
	<script type="text/javascript">
		var xmlhttp, xmlhttp1;
		if (window.XMLHttpRequest){// code for IE7+, Firefox, Chrome, Opera, Safari
			xmlhttp=new XMLHttpRequest();
			xmlhttp1 = new XMLHttpRequest();
		}else{// code for IE6, IE5
			xmlhttp=new ActiveXObject("Microsoft.XMLHTTP");
			xmlhttp1=new ActiveXObject("Microsoft.XMLHTTP");
		}
		
		xmlhttp.onreadystatechange=function(){
			if (xmlhttp.readyState==4 && xmlhttp.status==200){
				document.getElementById("statuses").innerHTML=xmlhttp.responseText;//在对应的div中填入返回的信息
			}
		};
		
		function trim(str){
			return str.replace(/(^\s*)|(\s*$)/g, "");
		}
		
		function querystatus() {
			var userid = trim(document.getElementById("userid").value);
			if (userid.length <= 0) {
				alert("用户账号不能为空");
				return;
			}

			
			xmlhttp.open("POST", "zqhongbaoquery_resp.jsp?userid=" + userid);
			xmlhttp.send(null);
		}
	</script>
  </head>
  
  <body>
    <h2>肇庆订单查询</h2>
    	<div style="width:90%; border:1px ;float:center; height: 64px">
			 订单号：<input type="text" id="userid" size="16" name="name" style="width: 180px; ">
    		<input type="button" value="确认" onclick="querystatus()" />
	</div>
	<div id="center" style="width:98%; height:620px; border:1px solid #555; overflow:auto; word-wrap:break-word;float: center;">
		<div id="statuses" style="width:100%; height:100%; overflow:auto; overflow-y:auto;font-size:20px">
		<h2>订单状态</h2>
		</div>
	</div>
    	
  </body>
</html>
