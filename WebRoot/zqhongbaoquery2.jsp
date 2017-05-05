<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%
	String path = request.getContextPath();
	String basePath = request.getScheme() + "://"
			+ request.getServerName() + ":" + request.getServerPort()
			+ path + "/";

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
	if (window.XMLHttpRequest) {// code for IE7+, Firefox, Chrome, Opera, Safari
		xmlhttp = new XMLHttpRequest();
		xmlhttp1 = new XMLHttpRequest();
	} else {// code for IE6, IE5
		xmlhttp = new ActiveXObject("Microsoft.XMLHTTP");
		xmlhttp1 = new ActiveXObject("Microsoft.XMLHTTP");
	}

	xmlhttp.onreadystatechange = function() {
		if (xmlhttp.readyState == 4 && xmlhttp.status == 200) {
			document.getElementById("statuses").innerHTML = xmlhttp.responseText;//在对应的div中填入返回的信息
		}
	};

	function trim(str) {
		return str.replace(/(^\s*)|(\s*$)/g, "");
	}

	function querystatus() {
		xmlhttp.open("POST", "zqhongbaoquery_resp2.jsp?userid="
				+ encodeURIComponent(document.getElementById("numbers").value));
		xmlhttp.send(null);
	}

	xmlhttp1.onreadystatechange = function() {
		if (xmlhttp1.readyState == 4 && xmlhttp1.status == 200) {
			if (xmlhttp1.responseText.indexOf("success") >= 0) {
				alert("修改状态成功");
			} else if (xmlhttp1.responseText.indexOf("fail") >= 0) {
				alert("修改状态失败");
			} else if (xmlhttp1.responseText.indexOf("订单号为空") >= 0) {
				alert("订单号为空");

			}

		}
	};

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
		for (var i = 0; i < items.length; ++i) {
			if (items[i].checked) {
				if (ids.length > 0) {
					ids = ids + ",";
				}
				ids = ids + items[i].value;
			}
		}
		alert(ids);
		var cdt = getRadioBoxValue("radiobutton");
		xmlhttp1.open("POST", "zqhongbaoquery_resp2.jsp?act=pushstatus&ids="
				+ ids + "&cdt=" + cdt);
		xmlhttp1.send(null);
	}

	function CheckAll() {
		var div = document.getElementById('center');
		var CheckBox = div.getElementsByTagName('input');
		for (i = 0; i < CheckBox.length; i++) {
			CheckBox[i].checked = true;
		}
		;
	}

	function othercheck() {
		var div = document.getElementById('center');
		var CheckBox = div.getElementsByTagName('input');
		for (i = 0; i < CheckBox.length; i++) {
			if (CheckBox[i].checked == true) {
				CheckBox[i].checked = false;
			} else {
				CheckBox[i].checked = true
			}

		}
		;
	}
</script>
</head>

<body>
	<h2>肇庆订单查询</h2>
	<input type="radio" name="radiobutton" value="hongbao"
		checked="checked">红包
	<input type="radio" name="radiobutton" value="zqydhongbao">肇庆红包

	<div
		style="width:180px;height:620px; border:1px solid #555;float: left;">
		<textarea id="numbers"
			style="width:180px; height: 600px; overflow-x:hidden; overflow-y:auto; border:none; outline:none;resize: none;"></textarea>
		<input type="button" value="查询订单状态" onclick="querystatus()"
			style="float:right; margin-right:20px; margin-top:20px; height:30px;" />

	</div>
	<div id="center"
		style="width-right:80%; height:620px; border:1px solid #555; overflow:auto; word-wrap:break-word;float: center;">
		<div id="statuses"
			style="width:100%; height:90%; overflow:auto; overflow-y:auto;font-size:20px">
			<h2>订单状态</h2>
		</div>
		<input type="button" value="修改状态" onclick="sendstatus()"
			style="float:right; margin-right:20px; margin-top:20px; height:30px;" />
		<input type="button" value="反选" onclick="othercheck()"
			style="float:right; margin-right:20px; margin-top:20px; height:30px; width: 80px;" />&nbsp;&nbsp;
		<input type="button" value="全选" onclick="CheckAll()"
			style="float:right; margin-right:20px; margin-top:20px; height:30px;width: 80px;" />&nbsp;&nbsp;
	</div>

</body>
</html>
