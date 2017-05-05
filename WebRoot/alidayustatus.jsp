<%@page import="net.sf.json.JSONArray,
				com.taobao.api.response.AlibabaAliqinFlowWalletQueryChargeResponse,
				com.taobao.api.request.AlibabaAliqinFlowWalletQueryChargeRequest,
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
				com.taobao.api.request.AlibabaAliqinFlowWalletQueryChargeRequest,
				com.taobao.api.request.AlibabaAliqinFcFlowQueryRequest,
				com.taobao.api.ApiException,
				com.taobao.api.DefaultTaobaoClient,
				com.taobao.api.TaobaoClient,
				com.taobao.api.response.AlibabaAliqinFlowWalletQueryChargeResponse,
				com.taobao.api.response.AlibabaAliqinFcFlowQueryResponse
				" 
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
		
		//发送请求前先准备好参数
		TaobaoClient client = new DefaultTaobaoClient(url, appkey, secret);
		AlibabaAliqinFcFlowQueryRequest req = new AlibabaAliqinFcFlowQueryRequest();
		//req.setOutId("3216549870004");
		AlibabaAliqinFcFlowQueryResponse rsp = null;

		String[] idarray = ids.split(",");
		JSONObject obj = new JSONObject();
		for(int i = 0; i < idarray.length; i++){
			//dyrequest.setOutRechargeId(idarray[i]);		
			req.setOutId(idarray[i]);
			//发送查询/获取状态前先获取连接, 防止访问线程超量
			Cache.getStatusConnection(routeid);
			try {
				rsp = client.execute(req);
				ret = rsp.getBody();
			} catch (Exception e) {
				e.printStackTrace();
				logger.info(e.getMessage());
			} finally {
				//发送查询/获取状态后释放连接
				Cache.releaseStatusConnection(routeid);
			}
			
			//这里判断结果, 每个通道情况不同, 成功的节点ID对应success, 失败的对应失败信息
			if (ret != null && ret.trim().length() > 0) {
				logger.info("alidayu status ret = " + ret);
				try {
					JSONObject retjson = JSONObject.fromObject(ret);
					
					String str = retjson.getJSONObject("alibaba_aliqin_fc_flow_query_response").getJSONObject("value").getString("model");
					String message = str;
					int idx = str.indexOf("status");
					if(idx >= 0){
						str = str.substring(idx + 7, str.indexOf(",", idx)).trim();
					}
					
					int idx2 = message.indexOf("reason");
					if(idx2 >= 0){
						int v = message.indexOf("=", idx2 + 7);
						if(v < 0){
							v = message.indexOf("}", idx2);
						}
						message = message.substring(idx2 + 7, v).trim();
						v = message.lastIndexOf(",");
						if(v >= 0){
							message = message.substring(0, v);
						}
					}else{
						message = str;
					}
		
					if(str.equals("3")){
						JSONObject rp = new JSONObject();
						rp.put("code", 0);
						rp.put("message", "success");
						rp.put("resp", ret);
						obj.put(idarray[i], rp);
					}else if(str.equals("4")){
						JSONObject rp = new JSONObject();
						rp.put("code", str);
						rp.put("message", message);
						rp.put("resp", ret);
						obj.put(idarray[i], rp);
					}else{
						logger.info("alidayu status : [" + idarray[i] + "]状态码 : " + str + "@" + TimeUtils.getSysLogTimeString());
					}
				} catch (Exception e) {
					logger.warn(e.getMessage(), e);
					logger.info("alidayu status : " + e.getMessage() + ", ret = " + ret + "@" + TimeUtils.getSysLogTimeString());
				}
			} else {
				logger.info("alidayu status : " + "fail@" + TimeUtils.getSysLogTimeString());
			}
			
		}
	
		request.setAttribute("retjson", obj.toString());
		request.setAttribute("result", "success");
		
		break;
	}
	
	request.getRequestDispatcher("request.jsp").forward(request,response);
%>