<%@page import="com._21cn.open.openapi.common.OauthRequestUtil"%>
<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%
	String path = request.getContextPath();
	String basePath = request.getScheme()+"://"+request.getServerName()+":"+request.getServerPort()+path+"/";


		String c_clientId = "8013818507" ;  //8015488431这里改成你们应用的appKey
		String c_clientIp = "120.24.156.98";//这里要改成你们的IP
		String c_clientType = "10020";//10020代表PC客户端（具体各不同类型详见文档说明中的“客户端类型”）
		String c_timeStamp = String.valueOf(System.currentTimeMillis());//时间戳
		String c_secret =  "yLmrAVi8kny8VFTI3NpeUpcHthODinNU" ;//综合平台颁发给你们应用的密钥 
		String c_version = "1.5" ; //你们的版本号
		String c_interfaceUrl = "https://open.e.189.cn/api/oauth2/llb/grantCoin.do";

		
		Map<String,String> requestData = new HashMap<String,String>();
		try {
			//将入参放入map中
			requestData.put("clientId", c_clientId);
			requestData.put("clientIp", c_clientIp);
			requestData.put("clientType",c_clientType );
			requestData.put("timeStamp", c_timeStamp);			
			requestData.put("version", c_version);
			//私有请求参数
			requestData.put("taskId", "100006671");
			requestData.put("mobile", "15626149425");
			requestData.put("coin", "1");
			requestData.put("uuid", "160928164609620113");
			requestData.put("serialNum", "0");

			
			
			//此处要对map中的元素进行按key升序排序
			OauthRequestUtil.initComParam(requestData, c_clientId , c_version);
			
			// 打印完全的请求URL	
			/*
			requestData = OauthRequestUtil.sign(requestData, secret);
			StringBuffer sb1 = new StringBuffer();
			for (Map.Entry<String, String> entry : requestData.entrySet()) {
				String name = entry.getKey().toString();
				String value = entry.getValue();
				sb1.append(name + "=" + value + "&");
			}
			
			String requestUrl = interfaceUrl+"?"+sb1.toString();
			System.err.println(requestUrl);
			*/
			
			//根据文档说明要对请求参数进行加密处理再调用接口
			//result就是调用后的结果 
			
			String result =OauthRequestUtil.signPostOpenAPIServer(c_interfaceUrl,requestData, c_secret);
			out.print(result);
		} catch (Exception e) {
			e.printStackTrace();
		}
%>
