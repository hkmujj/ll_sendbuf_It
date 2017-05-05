<%@page import="com.gargoylesoftware.htmlunit.BrowserVersion,
				com.gargoylesoftware.htmlunit.html.HtmlAnchor,
				com.gargoylesoftware.htmlunit.html.HtmlPage,
				com.gargoylesoftware.htmlunit.WebClient,
				database.LLTempDatabase,
				util.SHA1,
				util.MD5Util,
				net.sf.json.JSONArray,
				util.TimeUtils,
				http.HttpAccess,
				cache.Cache,
				net.sf.json.JSONException,
				net.sf.json.JSONObject,
				java.util.*,
				util.MyStringUtils,
				java.net.URLDecoder,
				java.text.SimpleDateFormat,
				org.apache.logging.log4j.LogManager,
				org.apache.logging.log4j.Logger" 
		language="java" pageEncoding="UTF-8"
%><%!
	private static byte[] vlock = new byte[0];
%><%
	boolean logflag = true;
	Logger logger = LogManager.getLogger();
	
	while(true){
		String ret = null;
		
		//获取公共参数
		String routeid = request.getAttribute("routeid").toString();
		
		Object idsobj = request.getAttribute("ids");
		if(idsobj == null){
			request.setAttribute("result", "S." + routeid + ":ids are needed to get status@" + TimeUtils.getSysLogTimeString());
			break;
		}
		
		String ids = idsobj.toString(); 
		
		logger.info("ids = " + ids + ", routeid = " + routeid);
		
		//获取通道参数, 每个通道不同
		Map<String, String> routeparams = Cache.getRouteParams(routeid);
		if(routeparams == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams@" + TimeUtils.getSysLogTimeString());
			break;
		}
		
		//发送请求前先准备好参数
		String[] idarray = ids.split(",");
		JSONObject obj = new JSONObject();
		for(int i = 0; i < idarray.length; i++){
			String rpurl = LLTempDatabase.getMapValue("21cn", idarray[i], "01"); 
			if(rpurl == null){
				continue;
			}
		
			WebClient webClient = null;
	
	        try {
		        webClient = new WebClient(BrowserVersion.CHROME);
				webClient.getOptions().setJavaScriptEnabled(true);
				webClient.getOptions().setCssEnabled(false);
				webClient.getOptions().setThrowExceptionOnScriptError(false);
		        HtmlPage _21cnpage = null;
		        HtmlPage pageResponse = null;
	        
	        	_21cnpage = webClient.getPage(rpurl);
	        	Thread.sleep(200);
				String pagestr = _21cnpage.getBody().asText();	
				if(pagestr.indexOf("流量兑换处理中") > -1){
	        		//System.out.println("info = " + "流量兑换处理中");
	        		synchronized(vlock){
		        		String rpv = LLTempDatabase.getMapValue("21cn", idarray[i], "03");
		        		if(rpv == null || rpv.equals("")){
		        			LLTempDatabase.putMap("21cn",  idarray[i], "ing", "03");
		        		}else {
		        			//
						}
					}
	        		logger.info("uuid = " + idarray[i] + ",info = " + "流量兑换处理中");
		        }else if(pagestr.indexOf("流量兑换成功") > -1){
		        	System.out.println("uuid = " + idarray[i] + ", info = " + "流量兑换成功");
		        	JSONObject rp = new JSONObject();
					rp.put("code", 0);
					rp.put("message", "success");
					rp.put("resp", "");
					obj.put(idarray[i], rp);
					
					//LLTempDatabase.deleteMapData("21cn", idarray[i], "01");
		        }else if(pagestr.indexOf("流量兑换失败") > -1){
		        	//System.out.println("info = " + "流量兑换成功");
		        	JSONObject rp = new JSONObject();
					rp.put("code", 1);
					rp.put("message", "失败");
					rp.put("resp", "");
					obj.put(idarray[i], rp);
					//LLTempDatabase.deleteMapData("21cn", idarray[i], "01");
		        }else{
					synchronized(vlock){
						String rpv = LLTempDatabase.getMapValue("21cn", idarray[i], "03");
						logger.info("rpv = " + rpv );
						if(rpv == null || rpv.equals("")){
						
		        		}else if(rpv.equals("ing")){
							String ddtime = idarray[i].substring(0, 14);
							SimpleDateFormat df = new SimpleDateFormat("yyyyMMddHHmmss");
							long l = System.currentTimeMillis() - df.parse(ddtime).getTime();
							if(l > 1200000){
								//充值失败
								LLTempDatabase.deleteMapData("21cn", idarray[i], "03");
								
								JSONObject rp = new JSONObject();
								rp.put("code", 1);
								rp.put("message", "失败");
								rp.put("resp", "");
								obj.put(idarray[i], rp);
							}else {
								//充值中	        		
								logger.info("uuid = " + idarray[i] + ",info = " + "流量兑换处理中");
							}
						}
					}
		        }
			} catch (Exception e) {
				logger.error(e.getMessage(), e);
			} finally {
				if(webClient != null){
					try{
						webClient.close();
					} catch (Exception e) {
						logger.error(e.getMessage(), e);
					}
				}
			}
		}
	
		request.setAttribute("retjson", obj.toString());
		request.setAttribute("result", "success");
		
		break;
	}
	
	request.getRequestDispatcher("request.jsp").forward(request,response);
%>