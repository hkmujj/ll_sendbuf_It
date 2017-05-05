<%@page import="org.dom4j.DocumentHelper,
				org.dom4j.Document,
				util.MD5Util,
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
		String account = routeparams.get("account");
		if(account == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, account is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String password = routeparams.get("password");
		if(password == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, password is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String type = routeparams.get("type");
		if(type == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, type is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String range = routeparams.get("range");
		if(range == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, range is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		//参数准备, 每个通道不同
		
		String packagecode = null;
		if(range.equals("全国")){
			if(packageid.equals("yd.30M")){
				packagecode = "QG1008610030";
			}else if(packageid.equals("yd.70M")){
				packagecode = "QG1008610070";
			}else if(packageid.equals("yd.150M")){
				packagecode = "QG1008610150";
			}else if(packageid.equals("yd.500M")){
				packagecode = "QG1008610500";
			}else if(packageid.equals("yd.1G")){
				packagecode = "QG1008611024";
			}else if(packageid.equals("yd.2G")){
				packagecode = "QG1008612048";
			}else if(packageid.equals("yd.3G")){
				packagecode = "QG1008613072";
			}else if(packageid.equals("yd.4G")){
				packagecode = "QG1008614096";
			}else if(packageid.equals("yd.6G")){
				packagecode = "QG10086126144";
			}else if(packageid.equals("yd.11G")){
				packagecode = "QG100861211264";
			}
		}else if(range.equals("北京")){
			if(packageid.equals("yd.10M")){
				packagecode = "BJ1008600010";
			}else if(packageid.equals("yd.30M")){
				packagecode = "BJ1008600030";
			}else if(packageid.equals("yd.70M")){
				packagecode = "BJ1008600070";
			}else if(packageid.equals("yd.150M")){
				packagecode = "BJ1008600150";
			}else if(packageid.equals("yd.500M")){
				packagecode = "BJ1008600500";
			}else if(packageid.equals("yd.1G")){
				packagecode = "BJ1008601024";
			}else if(packageid.equals("yd.2G")){
				packagecode = "BJ1008602048";
			}else if(packageid.equals("yd.3G")){
				packagecode = "BJ1008603072";
			}else if(packageid.equals("yd.4G")){
				packagecode = "BJ1008604096";
			}else if(packageid.equals("yd.6G")){
				packagecode = "BJ1008606144";
			}else if(packageid.equals("yd.11G")){
				packagecode = "BJ1008611264";
			} 
		}else if(range.equals("安徽")){
		    if(packageid.equals("yd.10M")){
				packagecode = "AH1008600010";
			}else if(packageid.equals("yd.30M")){
				packagecode = "AH1008600030";
			}else if(packageid.equals("yd.70M")){
				packagecode = "AH1008600070";
			}else if(packageid.equals("yd.150M")){
				packagecode = "AH1008600150";
			}else if(packageid.equals("yd.500M")){
				packagecode = "AH1008600500";
			}else if(packageid.equals("yd.1G")){
				packagecode = "AH1008601024";
			}else if(packageid.equals("yd.2G")){
				packagecode = "AH1008602048";
			}else if(packageid.equals("yd.3G")){
				packagecode = "AH1008603072";
			}else if(packageid.equals("yd.4G")){
				packagecode = "AH1008604096";
			}else if(packageid.equals("yd.6G")){
				packagecode = "AH1008606144";
			}else if(packageid.equals("yd.11G")){
				packagecode = "AH1008611264";
			}
		}else if(range.equals("山西")){
			if(packageid.equals("yd.10M")){
				packagecode = "SHX1008600010";
			}else if(packageid.equals("yd.30M")){
				packagecode = "SHX1008600030";
			}else if(packageid.equals("yd.70M")){
				packagecode = "SHX1008600070";
			}else if(packageid.equals("yd.150M")){
				packagecode = "SHX1008600150";
			}else if(packageid.equals("yd.500M")){
				packagecode = "SHX1008600500";
			}else if(packageid.equals("yd.1G")){
				packagecode = "SHX1008601024";
			}else if(packageid.equals("yd.2G")){
				packagecode = "SHX1008602048";
			}else if(packageid.equals("yd.3G")){
				packagecode = "SHX1008603072";
			}else if(packageid.equals("yd.4G")){
				packagecode = "SHX1008604096";
			}else if(packageid.equals("yd.6G")){
				packagecode = "SHX1008606144";
			}else if(packageid.equals("yd.11G")){
				packagecode = "SHX1008611264";
			}
		}
		
		if(packagecode == null){
			request.setAttribute("result", "S." + routeid + ":unrecognized package@" + TimeUtils.getSysLogTimeString());
			break;
		}
		
		Map<String, String> params = new HashMap<String, String>();
		params.put("LoginName", account);
		params.put("Password",  MD5Util.getUpperMD5(password).substring(8, 24));
        params.put("SmsKind", type);
        params.put("ProCode", packagecode);
        params.put("SendSim", phone);
            
		
		//在执行请求前先获取连接, 防止访问通道线程超量
		Cache.getConnection(routeid);
		try {
			ret = HttpAccess.postNameValuePairRequest(url, params, "utf-8", "yituosend");
		} catch (Exception e) {
			e.printStackTrace();
			logger.info(e.getMessage());
		} finally {
			//在执行请求后记得释放连接
			Cache.releaseConnection(routeid);
		}
	
		//这里判断结果, 每个通道情况不同, 成功的保存 success 到 result 中并返回到 request.jsp
		if (ret != null && ret.trim().length() > 0) {
			logger.info("yituo send ret = " + ret);
			try {
				Document doc = DocumentHelper.parseText(ret);
				String code = doc.getRootElement().elementText("Code");
				if(code.equals("0")){
					request.setAttribute("result", "success");
					request.setAttribute("reportid", doc.getRootElement().elementText("TransIDO"));
				}else{
					request.setAttribute("code", code);
					String responseMsg = code;
					request.setAttribute("result", "R." + routeid + ":" + responseMsg + "@" + TimeUtils.getSysLogTimeString());
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
	//Log.logout("String = " + str, 0);
	//out.print((new MsgBufQuerier()).jsonRpc(str));
	//out.print("hello");
%>