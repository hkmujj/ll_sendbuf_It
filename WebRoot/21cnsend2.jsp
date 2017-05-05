<%@page import="com._21cn.open.openapi.common.OauthRequestUtil,
				java.net.URLEncoder,
				util.MD5Util,
				util.SHA1,
				util.AES,
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
		language="java" pageEncoding="UTF-8"
%><%
	boolean logflag = true;
	Logger logger = LogManager.getLogger();
	
	String clientId = "8013818507" ;  //这里改成你们应用的appKey
	String clientIp = "120.24.156.98";//这里要改成你们的IP
	String clientType = "10010";//10020代表PC客户端（具体各不同类型详见文档说明中的“客户端类型”）
	String timeStamp = String.valueOf(System.currentTimeMillis());//时间戳
	String secret =  "yLmrAVi8kny8VFTI3NpeUpcHthODinNU" ;//综合平台颁发给你们应用的密钥 
	String version = "1.5" ; //你们的版本号
	
	String url = "https://open.e.189.cn/api/oauth2/llb/grantTicket.do";
	
	//String interfaceUrl = "https://open.e.189.cn/api/oauth2/llb/grantCoin.do";

	
	Map<String,String> requestData = new HashMap<String,String>();
	try {
		//将入参放入map中
		requestData.put("clientId", clientId);
		requestData.put("clientIp", clientIp);
		requestData.put("clientType",clientType );
		requestData.put("timeStamp", timeStamp);			
		requestData.put("version",version );
		//私有请求参数
		requestData.put("taskId", "100004707");
		requestData.put("mobile", "18924231943");
		
		requestData.put("ticketTypeId", "");
		requestData.put("counts", "1");
		
		String uuid = String.valueOf(System.currentTimeMillis() * 100000 + new Random().nextInt(100000));
		requestData.put("uuid", uuid);

		System.out.println("uuid = " + uuid);
		//此处要对map中的元素进行按key升序排序
		OauthRequestUtil.initComParam(requestData, clientId , version);
		
		//根据文档说明要对请求参数进行加密处理再调用接口
		//result就是调用后的结果
		String result =OauthRequestUtil.signPostOpenAPIServer(url, requestData, secret);
		System.err.println(result);
	} catch (Exception e) {
		e.printStackTrace();
	}

%>