<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%
	String path = request.getContextPath();
	String basePath = request.getScheme()+"://"+request.getServerName()+":"+request.getServerPort()+path+"/";

	String acr = request.getParameter("acr");
   	if((session.getAttribute("admin") != null && session.getAttribute("admin").equals("yes")) || (acr != null && acr.equals("routedata"))){
   		session.setAttribute("admin", "yes");
   	}else{
   		out.println("~");
  		return;
   	}
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
  <head>
    <title>通道数据</title>
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
				alert(xmlhttp.responseText);
			}
		}
			
		function trim(str){
			return str.replace(/(^\s*)|(\s*$)/g, "");
		}
		
		function createExcl() {
			var routeid = trim(document.getElementById("routeid").value);
			if (routeid.length <= 0) {
				alert("通道编号不能为空");
				return;
			}
			var startdate = trim(document.getElementById("startdate").value);
			if (startdate.length <= 0) {
				alert("开始日期不能为空");
				return;
			}
			var enddate = trim(document.getElementById("enddate").value);
			if (enddate.length <= 0) {
				alert("结束日期不能为空");
				return;
			}
			xmlhttp.open("POST", "route_data_info.jsp?routeid=" + routeid
					+ "&startdate=" + startdate + "&enddate=" + enddate);
			xmlhttp.send(null);
			
			alert("ok");
			
		}
		function download(){
			var path = xmlhttp.responseText;
			if(path == null || path.length<=0){
				alert("先点击生成按钮");
			}
			window.location.href=xmlhttp.responseText;
		}
	</script>
  </head>
  
  <body>
    <h2>导通道数据主页面</h2>
    	<div style="width:450px;height:620px; border:1px solid #555;float: left;">
    		 <div  style="margin-top:20px;">
			 通道编号：<input type="text" id="routeid" size="21" name="routeid"><br/><br/>
			 </div>
	    	开始日期：<input type="text" id="startdate" size="21" name="startdate">(例如20170101)<br/><br/>
	    	结束日期：<input type="text" id="enddate" size="21" name="enddate">(例如20170131)<br/><br/>
	    	<input type="button" value="下载" onclick="download()" style="float:right; margin-right:20px; margin-top:20px; height:30px;"/>
    		<input type="button" value="生成" onclick="createExcl()" style="float:right; margin-right:20px; margin-top:20px; height:30px;"/>
    		<div  style="margin-top:20px;">
			注意：(先点击生成，再点击下载)<br/><br/>如果想导一天的数据则将开始日期，结束日期都写成该日期。<br/><br/>
			例如想导2016年09月01号的数据则开始日期和结束日期都写成20160901。
			</div>
	</div>
    	
  </body>
</html>
