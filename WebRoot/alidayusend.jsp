<%@page import="util.TimeUtils,
				http.HttpAccess,
				cache.Cache,
				net.sf.json.JSONException,
				net.sf.json.JSONObject,
				java.util.*,
				util.MyStringUtils,
				java.net.URLDecoder,
				org.apache.logging.log4j.LogManager,
				org.apache.logging.log4j.Logger,
				com.taobao.api.ApiException,
				com.taobao.api.DefaultTaobaoClient,
				com.taobao.api.TaobaoClient,
				com.taobao.api.request.AlibabaAliqinFcFlowChargeRequest,
				com.taobao.api.request.AlibabaAliqinFlowWalletQueryChargeRequest,
				com.taobao.api.response.AlibabaAliqinFcFlowChargeResponse,
				com.taobao.api.response.AlibabaAliqinFlowWalletQueryChargeResponse
				" 
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
		String appkey = routeparams.get("appkey");
		if(appkey == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, appkey is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String secret = routeparams.get("secret");
		if(secret == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, secret is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		
		//参数准备, 每个通道不同
		String packagecode = null;
		
		try{
			packageid = packageid.split("\\.")[1];
			String pkstr = packageid.substring(0, packageid.length() - 1);
			int pk = Integer.parseInt(pkstr);
			if(packageid.indexOf('G') >= 0){
				pk *= 1024;
			}
			packagecode = String.valueOf(pk);
		} catch (Exception e) {
			logger.warn(e.getMessage(), 0);
		}
		
		if(packagecode == null){
			request.setAttribute("result", "S." + routeid + ":unrecognized package@" + TimeUtils.getSysLogTimeString());
			break;
		}
		
		TaobaoClient client = new DefaultTaobaoClient(url, appkey, secret);
		AlibabaAliqinFcFlowChargeRequest req = new AlibabaAliqinFcFlowChargeRequest();
		req.setPhoneNum(phone);
		req.setGrade(packagecode);
		req.setOutRechargeId(taskid);
		AlibabaAliqinFcFlowChargeResponse rsp = null;	
		
		//在执行请求前先获取连接, 防止访问通道线程超量
		Cache.getConnection(routeid);
		try {
			rsp = client.execute(req);
			ret = rsp.getBody();
		} catch (Exception e) {
			e.printStackTrace();
			logger.info(e.getMessage());
		} finally {
			//在执行请求后记得释放连接
			Cache.releaseConnection(routeid);
		}
	
		//这里判断结果, 每个通道情况不同, 成功的保存 success 到 result 中并返回到 request.jsp
		if (ret != null && ret.trim().length() > 0) {
			logger.info("alidayu send ret = " + ret);
			try {
			
				JSONObject retjson = JSONObject.fromObject(ret);
				if(retjson.get("alibaba_aliqin_fc_flow_charge_response") != null){
					JSONObject obj = retjson.getJSONObject("alibaba_aliqin_fc_flow_charge_response").getJSONObject("value");
					String code = "888";
					Object objc = obj.get("code");
					if(objc != null){
						code = objc.toString();
					}
					String message = obj.getString("msg");
					String success = obj.getString("success");
					if(success.equals("true")){
						request.setAttribute("result", "success");
					}else{
						request.setAttribute("code", code);
						request.setAttribute("result", "R." + routeid + ":" + message + "@" + TimeUtils.getSysLogTimeString());
					}
				}else{
					request.setAttribute("result", "R." + routeid + ":unknown error, retjson = " + ret + "@" + TimeUtils.getSysLogTimeString());
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