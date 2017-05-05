<%@page import="ec.check.CheckBatch"%>
<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%
	Map<String, String> infoMap = new HashMap<String, String>();
	infoMap.put("ECCode", "2000906460");
	infoMap.put("ECUserName", "Admin");
	infoMap.put("ECUserPwd", "MWiPOuTIPhAbhnw252htM4dKHnL1eYEt");
	infoMap.put("Areacode", "ZQ");
	infoMap.put("checkBatchLogPath",
			"Logs/Channel-ZQYD-2000906460/checkReportBatchBackTxt.txt");
	infoMap.put("CRMApplyCodes", "80010552205541,80010552195945,80010552187126,80010552182489,80010552177115,80010552162160,80010552157589,80010552152560,80010552151097,80010552147713,80010552140897");


	Map<String, String> resutlMap=CheckBatch.checkReportBatchRun(infoMap);
	String resutlTxt="";
	for(String key:resutlMap.keySet()){
	resutlTxt+="@"+key+":"+resutlMap.get(key);
	}
	System.out.println("resutlTxt:"+resutlTxt);
	out.print("resutlTxt:"+resutlTxt);
%>

