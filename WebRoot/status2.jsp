<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%
	String path = request.getContextPath();
	String basePath = request.getScheme()+"://"+request.getServerName()+":"+request.getServerPort()+path+"/";

	String acr = request.getParameter("acr");
   	if((session.getAttribute("admin") != null && session.getAttribute("admin").equals("yes")) || (acr != null && acr.equals("mchuanx_012"))){
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
    
    <title>流酷重推送状态</title>
	<meta http-equiv="pragma" content="no-cache">
	<meta http-equiv="cache-control" content="no-cache">
	<meta http-equiv="expires" content="0">    
	<meta http-equiv="keywords" content="keyword1,keyword2,keyword3">
	<meta http-equiv="description" content="This is my page">
	<!--
	<link rel="stylesheet" type="text/css" href="styles.css">
	-->
	<style type="text/css">
	table.gridtable
	  {
	   border-collapse: collapse;
	   width:1130px;
	  }
		table.gridtable td {
		text-align:center;
			border-width: 1px;
			padding: 8px;
			border-style: solid;
			border-color: #ccc;
			background-color: #ffffff;
			margin:0px;
		}
	</style>
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
				document.getElementById("statuses").innerHTML=xmlhttp.responseText;
			}
		};
		
		xmlhttp1.onreadystatechange=function(){
			if (xmlhttp1.readyState==4 && xmlhttp1.status==200){
				if(xmlhttp1.responseText.indexOf("success") >= 0){
					alert("推送状态成功");
				}else{
					alert("推送状态失败:" + xmlhttp1.responseText);
				}
			}
		};

		function trim(str){
			return str.replace(/(^\s*)|(\s*$)/g, "");
		}
		
		Date.prototype.format = function(format) {
			var o = {
				"M+" : this.getMonth() + 1, //month 
				"d+" : this.getDate(), //day 
				"h+" : this.getHours(), //hour 
				"m+" : this.getMinutes(), //minute 
				"s+" : this.getSeconds(), //second 
				"q+" : Math.floor((this.getMonth() + 3) / 3), //quarter 
				"S" : this.getMilliseconds()
			//millisecond 
			}

			if (/(y+)/i.test(format)) {
				format = format.replace(RegExp.$1, (this.getFullYear() + "")
						.substr(4 - RegExp.$1.length));
			}

			for ( var k in o) {
				if (new RegExp("(" + k + ")").test(format)) {
					format = format.replace(RegExp.$1,
							RegExp.$1.length == 1 ? o[k] : ("00" + o[k])
									.substr(("" + o[k]).length));
				}
			}
			return format;
		}
		
		function getRadioBoxValue(radioName) {
			var obj = document.getElementsByName(radioName); //这个是以标签的name来取控件
			for (i = 0; i < obj.length; i++) {

				if (obj[i].checked) {
					return obj[i].value;
				}
			}
			return "undefined";
		}

		function sendstatus() {
			//alert("aawww");
			var items = document.getElementsByName("pushids");
			//alert("wwpw");
			var ids = "";
		    for (var i = 0; i < items.length; ++i){
		        if (items[i].checked){
		            if(ids.length > 0){
		            	ids = ids + ",";
		            }
		            ids = ids + items[i].value;
		        }
		    }
		    //alert("www");
			xmlhttp1.open("POST", "status_resp.jsp?act=pushstatus&ids=" + ids);
			xmlhttp1.send(null);
		}
		
		function CheckAll() {
		var div=document.getElementById('content');
 	    var CheckBox=div.getElementsByTagName('input');
		for(i=0;i<CheckBox.length;i++){
		    CheckBox[i].checked=true;
	                 };
		}
		
		function othercheck() {
		var div=document.getElementById('content');
 	    var CheckBox=div.getElementsByTagName('input');
		for(i=0;i<CheckBox.length;i++){
                     if(CheckBox[i].checked==true){
                             CheckBox[i].checked=false;
                        }
                    else{
                        CheckBox[i].checked=true
                        }
                    
                 };
		}


		function querystatus() {
			var userid = trim(document.getElementById("userid").value);
			if (userid.length <= 0) {
				alert("用户账号不能为空");
				return;
			}
			var qdate = trim(document.getElementById("qdate").value);
			if (qdate.length <= 0) {
				alert("查询日期不能为空");
				return;
			}
			//var cdt = $("[name='radiobutton']").filter(":checked");
			var cdt = getRadioBoxValue("radiobutton");
			
			xmlhttp.open("POST", "status_resp.jsp?act=query&userid=" + userid
					+ "&qdate=" + qdate + "&cdt=" + cdt + "&cdtval=" + encodeURIComponent(document.getElementById("numbers").value));
			xmlhttp.send(null);
		}
	</script>
  </head>
  
  <body>
    <h3>流酷重推送状态</h3>
	用户账号：<input type="text" id="userid" size="16" name="name" value="10001">&nbsp;&nbsp;
	查询日期：<input type="text" id="qdate" size="16" name="name">(例:20160831)&nbsp;&nbsp;&nbsp;
	查询条件:
	<input type="radio" name="radiobutton" value="phone" checked="checked">充值手机号
	<input type="radio" name="radiobutton" value="linkid">客户订单号
	<input type="radio" name="radiobutton" value="taskid">平台订单号<br><br>
	<div style="width:180px;height:540px; border:1px solid #555;float: left;">
		 <textarea id="numbers" style="width:180px; height: 480px; overflow-x:hidden; overflow-y:auto; border:none; outline:none;resize: none;"></textarea>
		 <input type="button" value="查询订单状态" onclick="querystatus()" style="float:right; margin-right:20px; margin-top:20px; height:30px;"/>
	</div>
	<div id="content" style="width:1150px; height:540px; border:1px solid #555; overflow:auto; word-wrap:break-word;float: left;margin-left: 15px;">
		<div id="statuses" style="width:1150px; height:480px; overflow:auto;"></div>
		<input type="button" value="推送状态" onclick="sendstatus()" style="float:right; margin-right:20px; margin-top:20px; height:30px;"/>
		<input type="button" value="反选" onclick="othercheck()" style="float:right; margin-right:20px; margin-top:20px; height:30px; width: 80px;"/>&nbsp;&nbsp;		
		<input type="button" value="全选" onclick="CheckAll()" style="float:right; margin-right:20px; margin-top:20px; height:30px;width: 80px;"/>&nbsp;&nbsp;	
	</div>
  </body>
  <script>
	document.getElementById("qdate").value = new Date().format("yyyyMMdd");
  </script>
</html>