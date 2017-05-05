<%@page import="com.gargoylesoftware.htmlunit.html.HtmlElement"%>
<%@page import="java.util.Map.Entry"%>
<%@page import="_21cn.MACTool"%>
<%@page import="_21cn.StringUtil"%>
<%@page import="_21cn.ByteFormat"%>
<%@page import="_21cn.XXTea"%>
<%@page import="com.gargoylesoftware.htmlunit.html.HtmlAnchor,
				com.gargoylesoftware.htmlunit.html.HtmlPage,
				com.gargoylesoftware.htmlunit.BrowserVersion,
				com.gargoylesoftware.htmlunit.WebClient,
				database.LLTempDatabase,
				com._21cn.open.openapi.common.OauthRequestUtil,
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
	out.clearBuffer();	
	
	String acr = request.getParameter("acr");
   	if((session.getAttribute("admin") != null && session.getAttribute("admin").equals("yes")) || (acr != null && acr.equals("mchuanx"))){
   		session.setAttribute("admin", "yes");
   	}else{
   		out.println("~");
  		return;
   	}
   	
	WebClient webClient = null;
		
	try {
		String c_bossmobile = "18925024504";
		String url = "http://nb.189.cn/portal/open/enterCoinExchange.do";
		String appId = "8013818507";
		String appSecret = "yLmrAVi8kny8VFTI3NpeUpcHthODinNU";
		String clientType = "2";
		String signSecret = "yLmrAViHtrkuAFvPPO754MHHcHthO";

		Map<String, String> map = new HashMap<String, String>();
		map.put("appId", appId);
		map.put("clientType", clientType);
		String format = "html";
		String version = "v1.0";
		map.put("format", format);
		map.put("version", version);
		
		String params="mobile=" + c_bossmobile;
		
		String ciperParas = XXTea.encrypt(params, "UTF-8", ByteFormat.toHex(appSecret.getBytes()));
		String signPlainText = appId + clientType + format + version + ciperParas;
		byte[] data = StringUtil.hex2Bytes(ByteFormat.toHex(signPlainText.getBytes()));
		byte[] key = StringUtil.hex2Bytes(ByteFormat.toHex(signSecret.getBytes()));
		String signature = MACTool.encodeHmacMD5(data, key);

		map.put("paras", ciperParas);
		map.put("sign", signature);
		
		String paramstr = "";
		for(Entry<String, String> entry : map.entrySet()){
			if(paramstr.length() > 0){
				paramstr = paramstr + "&";
			}
			paramstr = paramstr + entry.getKey() + "=" + URLEncoder.encode(entry.getValue(), "utf-8");
		}
		
		url=url + "?" + paramstr;
		
		System.out.println("url = " + url);
		
		webClient = new WebClient(BrowserVersion.CHROME);
		webClient.getOptions().setJavaScriptEnabled(true);
		webClient.getOptions().setCssEnabled(false);
		webClient.getOptions().setThrowExceptionOnScriptError(false);
        HtmlPage _21cnpage = null;
        
        HtmlPage pageResponse = null;
       
       	_21cnpage = webClient.getPage(url);
       	int money = Integer.parseInt(_21cnpage.getHtmlElementById("mycoin").asText());
       	
		//Thread.sleep(500);
		out.println("coin = " + money);
	} catch (Exception e) {
		e.printStackTrace();
		out.println("query fail : " + e.getMessage());
	}finally {
		if(webClient != null){
			try{
				webClient.close();
			}catch (Exception e) {
			}
		}
    }
%>