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
	boolean logflag = true;
	Logger logger = LogManager.getLogger();
	
	//获取公共参数
	String taskid = request.getAttribute("taskid").toString(); 
	String routeid = request.getAttribute("routeid").toString();
	String phone = request.getAttribute("phone").toString();
	String packageid = request.getAttribute("package").toString();
	
	while(true){
		String ret = null;
		
		//检查通道参数, 每个通道有不同参数, 对应 ll_routes.api_params
		Map<String, String> routeparams = Cache.getRouteParams(routeid);
		if(routeparams == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String c_clientId = routeparams.get("c_clientId");
		if(c_clientId == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, c_clientId is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String c_clientIp = routeparams.get("c_clientIp");
		if(c_clientIp == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, c_clientIp is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String c_clientType = routeparams.get("c_clientType");
		if(c_clientType == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, c_clientType is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String c_secret = routeparams.get("c_secret");
		if(c_secret == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, c_secret is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String c_version = routeparams.get("c_version");
		if(c_version == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, c_version is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String c_interfaceUrl = routeparams.get("c_interfaceUrl");
		if(c_interfaceUrl == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, c_interfaceUrl is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String c_taskid = routeparams.get("c_taskid");
		if(c_taskid == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, c_taskid is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String c_bossmobile = routeparams.get("c_bossmobile");
		if(c_bossmobile == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, c_bossmobile is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String url = routeparams.get("url");
		if(url == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, url is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String resulturl = routeparams.get("resulturl");
		if(resulturl == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, resulturl is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String appId = routeparams.get("appId");
		if(appId == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, appId is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String appSecret = routeparams.get("appSecret");
		if(appSecret == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, appSecret is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String clientType = routeparams.get("clientType");
		if(clientType == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, clientType is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String signSecret = routeparams.get("signSecret");
		if(signSecret == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, signSecret is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		
		String c_timeStamp = String.valueOf(System.currentTimeMillis());//时间戳
		
		//参数准备, 每个通道不同
		String packagecode = null;
		String packagecode2 = "10G";
		int c_coin = 0;
		try{
			packageid = packageid.split("\\.")[1];
			String pkstr = packageid.substring(0, packageid.length() - 1);
			int pk = Integer.parseInt(pkstr);
			if(packageid.indexOf('G') >= 0){
				pk *= 1024;
			}
			c_coin = pk;
			packagecode = String.valueOf(pk);
			packagecode2 = packagecode + "M";
		} catch (Exception e) {
			logger.warn(e.getMessage(), 0);
		}
		
		if(packagecode == null){
			request.setAttribute("result", "S." + routeid + ":unrecognized package@" + TimeUtils.getSysLogTimeString());
			break;
		}
		
		if(c_coin == 5){
			c_coin = 10;
		}else if(c_coin == 10){
			c_coin = 19;
		}
		
		
		WebClient webClient = null;
		
		try {
			/*
			Map<String,String> requestData = new HashMap<String,String>();
			//将入参放入map中
			requestData.put("clientId", c_clientId);
			requestData.put("clientIp", c_clientIp);
			requestData.put("clientType",c_clientType );
			requestData.put("timeStamp", c_timeStamp);			
			requestData.put("version", c_version);
			//私有请求参数
			requestData.put("taskId", c_taskid);
			requestData.put("mobile", c_bossmobile);
			requestData.put("coin", "" + c_coin);
			
			String rd = "000000" + new Random().nextInt(1000000);
			rd = rd.substring(rd.length() - 6);
			String uuid = TimeUtils.getTimeStamp();
			uuid = uuid.substring(2, uuid.length()) + rd;
		
			requestData.put("uuid", uuid);
			requestData.put("serialNum", taskid);

			//此处要对map中的元素进行按key升序排序
			OauthRequestUtil.initComParam(requestData, c_clientId , c_version);
			
			ret = OauthRequestUtil.signPostOpenAPIServer(c_interfaceUrl,requestData, c_secret);
			
			JSONObject obj = JSONObject.fromObject(ret);
			if(obj.get("result") != null && obj.getString("result").trim().equals("0") && obj.getString("msg").indexOf("向你赠送") > -1){
				//成功
			}else{
				//request.setAttribute("result", "R." + routeid + ":" + obj.getString("msg") + "@" + TimeUtils.getSysLogTimeString());
				logger.info("R." + routeid + ":" + "coin recharge ret = " + ret + "@" + TimeUtils.getSysLogTimeString());
				//break;
				if(obj.getString("msg").indexOf("订单已处理") > -1){
					request.setAttribute("result", "R." + routeid + ":" + obj.getString("msg") + "@" + TimeUtils.getSysLogTimeString());
					break;
				}
			}
			*/
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
			
			logger.info("21cn coin url = " + url);
			
			webClient = new WebClient(BrowserVersion.CHROME);
			webClient.getOptions().setJavaScriptEnabled(true);
			webClient.getOptions().setCssEnabled(false);
			webClient.getOptions().setThrowExceptionOnScriptError(false);
	        HtmlPage _21cnpage = null;
	        
	        HtmlPage pageResponse = null;
        
        	_21cnpage = webClient.getPage(url);
        	int money = Integer.parseInt(_21cnpage.getHtmlElementById("mycoin").asText());
        	if(money >= c_coin){
					//System.out.println("success");
			}else{
				//充值提交失败，没有足够余额
				request.setAttribute("result", "R." + routeid + ":" + "账号余额不足,剩余" + money + ",需要" + c_coin + "@" + TimeUtils.getSysLogTimeString());
				logger.info("R." + routeid + ":账号余额不足,剩余" + money + ",需要" + c_coin + "@" + TimeUtils.getSysLogTimeString());
				break;
			}
			
			logger.info("21cn coin j-phone, packagecode2 = " + packagecode2);
			
			_21cnpage.getHtmlElementById("j-phone").setAttribute("value", phone);
			
			_21cnpage.executeJavaScript("$('#j-phone').trigger('keyup')");
			
			//System.out.println(_21cnpage.getHtmlElementById("j-phone").asText());
			
			//System.out.println(_21cnpage.getHtmlElementById("j-notice").asText());
			
			_21cnpage.getHtmlElementById("j-notice").click();
			
			Thread.sleep(500);
        	
			List dnl = _21cnpage.getByXPath("//*[@id=\"j-liuliang\"]/li");
			for(int i = 0; i < dnl.size(); i++){
				HtmlElement link = (HtmlElement)dnl.get(i);
				if(link.asText().equals(packagecode2)){
					logger.info("21cn coin link.click();");
					link.click();
					Thread.sleep(500);
					link.click();
				}
				//System.out.println(link.asText());
			}
			
			Thread.sleep(250);
			
			logger.info("21cn coin price");
			
			String price = _21cnpage.getHtmlElementById("price").asText();
			price = price.substring(0, price.length() - 1);
			if(Integer.parseInt(price) != c_coin){
				//System.out.println("price = " + price + ", c_coin = " + c_coin);
				logger.info("21cn coin 选择对应流量包错误price=" + price + ", c_coin=" + c_coin);
				request.setAttribute("result", "R." + routeid + ":选择对应流量包错误price=" + price + ", c_coin=" + c_coin + "@" + TimeUtils.getSysLogTimeString());
				break;
			}
			
			String duihan = _21cnpage.getHtmlElementById("duihuan-btn").getAttribute("class");
			//System.out.println("21cncoinsend.jsp btn class = " + duihan);
			if(duihan != null && duihan.equals("disabled")){
				logger.info("21cn coin btn disabled");
				request.setAttribute("result", "R." + routeid + ":btn disabled" + "@" + TimeUtils.getSysLogTimeString());
				break;
			}
			
			//ScriptResult sr = _21cnpage.executeJavaScript("exchangeCoinToFlow()");
			StringBuffer sb = new StringBuffer();
			sb.append("$.post('/portal/open/exchangeCoinToFlow.do' + search + '&typeId='+typeId + '&toMobile=' + toMobile, function(data){");
			sb.append("    var mydiv = document.createElement('div');");
			sb.append("    mydiv.setAttribute('id', 'cubeluzr');");
			sb.append("    if (data.result === 0) {");
			sb.append("        if (data.state === 1) {");
			sb.append("            mydiv.innerHTML = data.orderId;");
			sb.append("        }");
			sb.append("    }else {");
			sb.append("        mydiv.innerHTML = 'fail';");
			sb.append("    }");
			sb.append("    document.body.appendChild(mydiv);");
			sb.append("},'json');");
			
			_21cnpage.executeJavaScript(sb.toString());
			 
			Thread.sleep(500);
			
			logger.info("21cn coin executeJavaScript over");
			
			String tag = null;
			
			for(int i = 0; i < 20; i++){
				try {
					tag = _21cnpage.getHtmlElementById("cubeluzr").asText();
					break;
				} catch (Exception e) {
					//System.out.println(e.getMessage() + ", no such tag");
					logger.info("R." + routeid + ":" + e.getMessage() + ", no such tag" + "@" + TimeUtils.getSysLogTimeString());
				}
				
				Thread.sleep(500);
			}
			
			//System.out.println("tag = " + tag);
			logger.info("R." + routeid + ":" + "tag = " + tag + "@" + TimeUtils.getSysLogTimeString());
			
			if(tag == null || tag.indexOf("fail") > -1){
				request.setAttribute("code", 1);
				request.setAttribute("result", "R." + routeid + ":" + "tag=" + tag + "@" + TimeUtils.getSysLogTimeString());
			}else{
				request.setAttribute("result", "success");
				tag = tag.trim();
				request.setAttribute("reportid", tag);
				resulturl = resulturl + "?" + paramstr + "&orderId=" + tag;
				LLTempDatabase.putMap("21cncoin", tag, resulturl, "04");
			}
			if(tag == null){
				tag = "";
			}
			request.setAttribute("orgreturn", tag);
			//Thread.sleep(500);
		} catch (Exception e) {
			e.printStackTrace();
			logger.error(e.getMessage(), e);
			request.setAttribute("result", "S." + routeid + ":fail@" + TimeUtils.getSysLogTimeString());
		}finally {
			if(webClient != null){
				try{
					webClient.close();
				}catch (Exception e) {
				}
			}
        }
        
		break;
	}

	request.getRequestDispatcher("request.jsp").forward(request,response);
%>