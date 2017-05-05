<%@page import="util.MD5Util"%>
<%@page
	import="test.TestThread,
				test.TestCache,
				util.TimeUtils,
				http.HttpAccess,
				cache.Cache,
				net.sf.json.JSONException,
				net.sf.json.JSONObject,
				java.util.*,
				util.MyStringUtils,
				java.net.URLDecoder,
				org.apache.logging.log4j.LogManager,
				org.apache.logging.log4j.Logger"
	language="java" pageEncoding="UTF-8"%>
<%
	String url = "http://nllb.fengspace.com/gateway/flowservice/makeorder.ws";
	String appsecret = "f48650b91a5d4cc1bd2647d30eb07992";
	String version = "V1.1";
	String timestamp = TimeUtils.getTimeStamp();
	String seqno = timestamp;
	String appid = "mingzhuanwuxianqgdp";
	String secertkey = "";// header
	String sign = "";
	String ordertype = "1";
	String user = "15626149425";
	String packageid = "LT30";
	String extorder = "170421254dfdadf5454455";
	String note = "";// body

	// secertkey
	secertkey = MD5Util.getUpperMD5(timestamp + seqno + appid + appsecret);
	sign = MD5Util.getUpperMD5(appsecret + user + packageid + ordertype + extorder);
	out.print("feng secertkey=" + secertkey + "&sign=" + sign);
	JSONObject json = new JSONObject();
	JSONObject obj = new JSONObject();
	JSONObject bodyjson = new JSONObject();
	JSONObject bodyobj = new JSONObject();

	obj.put("VERSION", version);
	obj.put("TIMESTAMP", timestamp);
	obj.put("SEQNO", seqno);
	obj.put("APPID", appid);
	obj.put("SECERTKEY", secertkey);

	bodyjson.put("SIGN", sign);
	bodyjson.put("ORDERTYPE", ordertype);
	bodyjson.put("USER", user);
	bodyjson.put("PACKAGEID", packageid);
	bodyjson.put("EXTORDER", extorder);
	bodyjson.put("NOTE", note);

	bodyobj.put("CONTENT", bodyjson);
	json.put("HEADER", obj);
	json.put("MSGBODY", bodyobj);
	out.print("json=" + json.toString());
	String ret = HttpAccess.postJsonRequest(url, json.toString(), "utf-8", "fengshou");
	out.print("ret=" + ret);
%>