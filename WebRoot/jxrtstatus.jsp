<%@page import="util.SHA1,
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
				org.apache.logging.log4j.LogManager,
				org.apache.logging.log4j.Logger,
				util.MyBase64,
				java.security.MessageDigest,
				java.security.NoSuchAlgorithmException,
				java.io.UnsupportedEncodingException"
		language="java" pageEncoding="UTF-8"
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
		
		//获取通道能数, 每个通道不同
		Map<String, String> routeparams = Cache.getRouteParams(routeid);
		if(routeparams == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams@" + TimeUtils.getSysLogTimeString());
			break;
		}
		
		String rpurl = routeparams.get("rpurl");
		if(rpurl == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, rpurl is null@" + TimeUtils.getSysLogTimeString());
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
		String apiKey = routeparams.get("apiKey");
		if(apiKey == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, apiKey is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		password = MD5Util.get16LowerMD5(password);
		
		//发送请求前先准备好参数
		String[] idarray = ids.split(",");
		JSONObject obj = new JSONObject();
		
		for(int i = 0; i < idarray.length; i++){
			String value = idarray[i];
			String bef = "account=" + account + "&outTradeNo=" + value + "&password=" 
						+ password + "&apiKey=" + apiKey;
			logger.info("jxrtstatus加密前:" + bef);
			String sign = MD5Util.getLowerMD5(bef);
			
			HashMap<String, String> param = new HashMap<String, String>();
			param.put("account", account);
			param.put("password", password);
			param.put("outTradeNo", value);
			param.put("sign", sign);

			//发送查询/获取状态前先获取连接, 防止访问线程超量
			Cache.getStatusConnection(routeid);
			try {
				logger.info("jxrt status param =" + param);
				ret = HttpAccess.postNameValuePairRequest(rpurl, param, "utf-8", "jxrtstatus");
				//ret = HttpAccess.getNameValuePairRequest(url, param, "utf-8", "gzyunsheng");
			} catch (Exception e) {
				e.printStackTrace();
				logger.info(e.getMessage());
			} finally {
				//发送查询/获取状态后释放连接
				Cache.releaseStatusConnection(routeid);
			}
			
			//这里判断结果, 每个通道情况不同, 成功的节点ID对应success, 失败的对应失败信息
			if (ret != null && ret.trim().length() > 0) {
			logger.info("jxrt status ret = " + ret);
				
				try {
					JSONObject retjson = JSONObject.fromObject(ret);
					String code = retjson.getString("code");
					String errorMsg = retjson.getString("message");
					JSONObject orderjson = retjson.getJSONArray("orders").getJSONObject(0);
					String retCode = orderjson.getString("stat");
					if(code.equals("000")){
						if(retCode.equals("0")){
							JSONObject rp = new JSONObject();
							rp.put("code", 0);
							rp.put("message", "success");
							rp.put("resp", ret);
							obj.put(idarray[i], rp);
						}else if(retCode.equals("1")){
							JSONObject rp = new JSONObject();
							rp.put("code", 1);
							String message = orderjson.getString("desc");
							rp.put("message", message);
							rp.put("resp", ret);
							obj.put(idarray[i], rp);
							logger.info("jxrt status : [" + idarray[i] + "]状态码" + retCode + ":" + message + "@" + TimeUtils.getSysLogTimeString());
						}else {
							logger.info("jxrt status : [" + idarray[i] + "]充值中@" + TimeUtils.getSysLogTimeString());
						}
					}else{
						logger.info("jxrt error : " + errorMsg);
					}
				} catch (Exception e) {
					logger.warn(e.getMessage(), e);
					logger.info("jxrt status : " + e.getMessage() + ", ret = " + ret + "@" + TimeUtils.getSysLogTimeString());
				}
			} else {
				logger.info("jxrt status : " + "fail@" + TimeUtils.getSysLogTimeString());
			}
		}
	
		request.setAttribute("retjson", obj.toString());
		request.setAttribute("result", "success");
		
		break;
	}
	
	request.getRequestDispatcher("request.jsp").forward(request,response);
%>