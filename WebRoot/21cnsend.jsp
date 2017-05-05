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
		
		String url = routeparams.get("url");
		if(url == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, url is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String clientId = routeparams.get("clientId");
		if(clientId == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, clientId is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String clientIp = routeparams.get("clientIp");
		if(clientIp == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, clientIp is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String clientType = routeparams.get("clientType");
		if(clientType == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, clientType is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String secret = routeparams.get("secret");
		if(secret == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, secret is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String version = routeparams.get("version");
		if(version == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, version is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		
		//参数准备, 每个通道不同
		String packagecode = null;
		if(routeid.equals("9007")){ 
			if(packageid.equals("yd.30M")){
				packagecode = "100002943";
			}else if(packageid.equals("yd.70M")){
				packagecode = "100002942";
			}else if(packageid.equals("lt.100M")){
				packagecode = "100002941";
			}else if(packageid.equals("dx.100M")){
				packagecode = "100002940";
			}
		}else if(packageid.equals("lt.20M")){
			packagecode = "100005586";
		}else if(packageid.equals("lt.50M")){
			packagecode = "100005591";
		}else if(packageid.equals("lt.100M")){
			packagecode = "100005596";
		}else if(packageid.equals("lt.200M")){
			packagecode = "100005601";
		}else if(packageid.equals("lt.500M")){
			packagecode = "100005606";
		}
		else if(packageid.equals("yd.10M")){
			packagecode = "100005696";
		}else if(packageid.equals("yd.30M")){
			packagecode = "100005701";
		}else if(packageid.equals("yd.70M")){
			packagecode = "100005706";
		}else if(packageid.equals("yd.150M")){
			packagecode = "100005711";
		}else if(packageid.equals("yd.500M")){
			packagecode = "100005716";
		}else if(packageid.equals("yd.1G")){
			packagecode = "100005721";
		}else if(packageid.equals("yd.2G")){
			packagecode = "100005926";
		}else if(packageid.equals("yd.3G")){
			packagecode = "100005931";
		}else if(packageid.equals("yd.4G")){
			packagecode = "100005936";
		}else if(packageid.equals("yd.6G")){
			packagecode = "100005941";
		}else if(packageid.equals("yd.11G")){
			packagecode = "100005946";
		}
		else{
			if(routeid.equals("3024")){ 
				if(packageid.equals("dx.5M")){
					packagecode = "100006036";
				}else if(packageid.equals("dx.10M")){
					packagecode = "100006041";
				}else if(packageid.equals("dx.30M")){
					packagecode = "100006046";
				}else if(packageid.equals("dx.50M")){
					packagecode = "100006051";
				}else if(packageid.equals("dx.100M")){
					packagecode = "100006071";
				}else if(packageid.equals("dx.200M")){
					packagecode = "100006056";
				}else if(packageid.equals("dx.500M")){
					packagecode = "100006061";
				}else if(packageid.equals("dx.1G")){
					packagecode = "100006066";
				}
			}else if(routeid.equals("3052") || routeid.equals("3053")){
				 if(packageid.equals("dx.5M")){
					packagecode = "100006161";
				}else if(packageid.equals("dx.10M")){
					packagecode = "100006166";
				}else if(packageid.equals("dx.30M")){
					packagecode = "100006171";
				}else if(packageid.equals("dx.50M")){
					packagecode = "100006176";
				}else if(packageid.equals("dx.100M")){
					packagecode = "100006181";
				}else if(packageid.equals("dx.200M")){
					packagecode = "100006186";
				}else if(packageid.equals("dx.500M")){
					packagecode = "100006191";
				}else if(packageid.equals("dx.1G")){
					packagecode = "100006196";
				}
			}else if(routeid.equals("3149")){
				if(packageid.equals("dx.5M")){
					packagecode = "100002657";
				}else if(packageid.equals("dx.10M")){
					packagecode = "100002658";
				}else if(packageid.equals("dx.30M")){
					packagecode = "100002659";
				}else if(packageid.equals("dx.50M")){
					packagecode = "100002932";
				}else if(packageid.equals("dx.100M")){
					packagecode = "100003376";
				}else if(packageid.equals("dx.200M")){
					packagecode = "100003377";
				}else if(packageid.equals("dx.500M")){
					packagecode = "100003378";
				}else if(packageid.equals("dx.1G")){
					packagecode = "100003379";
				}
			}
		}
		
		if(packagecode == null){
			request.setAttribute("result", "S." + routeid + ":unrecognized package@" + TimeUtils.getSysLogTimeString());
			break;
		}
		
		String taskId = packagecode;
		
		Map<String,String> requestData = new HashMap<String,String>();
		
		requestData.put("clientId", clientId);
		requestData.put("clientIp", clientIp);
		requestData.put("clientType",clientType );
		
		long t = System.currentTimeMillis();
		String timeStamp = String.valueOf(t);//时间戳
		requestData.put("timeStamp", timeStamp);			
		requestData.put("version",version );
		//私有请求参数
		requestData.put("taskId", taskId);
		requestData.put("mobile", phone);
		
		requestData.put("ticketTypeId", "");
		requestData.put("counts", "1");
		
		String rd = "00000" + new Random().nextInt(100000);
		rd = rd.substring(rd.length() - 5);
		int mod = (int)(t % 100);
		String markup = "";
		if(mod < 10){
			markup = "0";
		}
		String uuid = TimeUtils.getTimeStamp() + markup + mod + rd;
		//String uuid = String.valueOf(System.currentTimeMillis() * 100000 + new Random().nextInt(100000));
		requestData.put("uuid", uuid);
		
		
		//在执行请求前先获取连接, 防止访问通道线程超量
		//Cache.getConnection(routeid);
		try {
			//ret = HttpAccess.postNameValuePairRequest(url, params, "utf-8", "mysend");
			//ret = HttpAccess.postJsonRequest(url, json.toString(), "utf-8", "dianxingufen");
			OauthRequestUtil.initComParam(requestData, clientId , version);
			ret =OauthRequestUtil.signPostOpenAPIServer(url, requestData, secret);
		} catch (Exception e) {
			e.printStackTrace();
			logger.info(e.getMessage());
		} finally {
			//在执行请求后记得释放连接
			//Cache.releaseConnection(routeid);
		}
	
		//这里判断结果, 每个通道情况不同, 成功的保存 success 到 result 中并返回到 request.jsp
		if (ret != null && ret.trim().length() > 0) {
			logger.info("21cn send ret = " + ret);
			try {
				JSONObject retjson = JSONObject.fromObject(ret);
				String code = retjson.getString("result");
				if(code.equals("0")){
					request.setAttribute("result", "success");
					request.setAttribute("reportid", uuid);
					
					String ticketInfoUrl = retjson.getString("ticketInfoUrl");
					LLTempDatabase.putMap("21cn", uuid, ticketInfoUrl, "01");
					
					WebClient webClient = new WebClient(BrowserVersion.CHROME);
					
					webClient.getOptions().setJavaScriptEnabled(true);
					webClient.getOptions().setCssEnabled(false);
					webClient.getOptions().setThrowExceptionOnScriptError(false);
			        HtmlPage _21cnpage = null;
			        HtmlPage pageResponse = null;
			
			        try {
			        	_21cnpage = webClient.getPage(ticketInfoUrl);
			        	HtmlAnchor link = null;
			        	try{
				        	link = _21cnpage.getAnchorByText("兑换");
				        }catch(Exception e){
							logger.error("[" + routeid + "]兑换 ret = " + e.getMessage());
						}
				        if(link == null){
					        try{
					        	link = _21cnpage.getAnchorByText("立即兑换");
							}catch(Exception e){
								logger.error("[" + routeid + "]立即兑换 ret = " + e.getMessage());
							}
				        }
				        link.click();
						Thread.sleep(1500);
					} catch (Exception e) {
						logger.error(e.getMessage(), e);
					}
			        
			        webClient.close();
				}else{
					request.setAttribute("code", code);
					request.setAttribute("result", "R." + routeid + ":" + code + "." + retjson.getString("msg") + "@" + TimeUtils.getSysLogTimeString());
				}
				request.setAttribute("orgreturn", ret);
			} catch (Exception e) {
				e.printStackTrace();
				logger.info(e.getMessage());
				request.setAttribute("result", "R." + routeid + ":" + e.getMessage() + "@" + TimeUtils.getSysLogTimeString());
			}
		} else {
			request.setAttribute("result", "R." + routeid + ":fail@" + TimeUtils.getSysLogTimeString());
		}
		
		
		
		
		break;
	}

	request.getRequestDispatcher("request.jsp").forward(request,response);
%>