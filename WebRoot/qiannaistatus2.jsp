<%@page import="org.bouncycastle.jcajce.provider.asymmetric.dsa.DSASigner.stdDSA"%>
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
				org.apache.logging.log4j.Logger" 
		language="java" pageEncoding="UTF-8"
%><%	
 
	boolean logfalg=true;
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
		if (rpurl == null) {
			request.setAttribute("result",
					"S." + routeid + ":wrong routeparams, rpurl is null@"
							+ TimeUtils.getSysLogTimeString());
			break;
		}
		String accountId = routeparams.get("accountId");
		if (accountId == null) {
			request.setAttribute("result", "S." + routeid
					+ ":wrong routeparams, accountId is null@"
					+ TimeUtils.getSysLogTimeString());
			break;
		}
	
		
		//发送请求前先准备好参数
		String[] idarray = ids.split(",");
		JSONObject obj = new JSONObject();
		
		
		for(int i = 0; i < idarray.length; i++){
	
					
					String downNum = idarray[i];
					
					JSONObject json = new JSONObject();
				    json.put("accountId", accountId);
				
					json.put("downNum", downNum);
					//发送查询/获取状态前先获取连接, 防止访问线程超量
					//Cache.getStatusConnection(routeid);
					
					try {
						ret = HttpAccess.postJsonRequest(rpurl, json.toString(), "utf-8","qiannai");
					} catch (Exception e) {
						e.printStackTrace();
						logger.info(e.getMessage());
					} finally {
						//发送查询/获取状态后释放连接
						//Cache.releaseStatusConnection(routeid);
					}

					//这里判断结果, 每个通道情况不同, 成功的节点ID对应success, 失败的对应失败信息
					if (ret != null && ret.trim().length() > 0) {
						//request.setAttribute("result", "success");
						logger.info("qiannai status ret = " + ret);
						try {
							JSONObject rejson = JSONObject.fromObject(ret);
								String retCode = rejson.getString("status");
								if (retCode.equals("4")){
									JSONObject rp = new JSONObject();
									rp.put("code", 0);
									rp.put("message", "success");
									rp.put("resp", ret);
									obj.put(idarray[i], rp);
								} else  if(retCode.equals("6")){
									JSONObject rp = new JSONObject();
									rp.put("code", 1);
									
									rp.put("message", "订单失败");
									rp.put("resp", ret);
									obj.put(idarray[i], rp);
								}else  if(retCode.equals("0")){
									//待处理
									logger.info("qiannai status : [" + idarray[i] + "]待处理@" + TimeUtils.getSysLogTimeString());
								}else if(retCode.equals("-99")&&rejson.getString("downNum").equals("没有此订单!")){
									//没有此订单
									logger.info("qiannai status : [" + idarray[i] + "]没有此订单@" + TimeUtils.getSysLogTimeString());
								}else {
									//
									logger.info("qiannai status : [" + idarray[i] + "]状态码" + retCode+"@" + TimeUtils.getSysLogTimeString());
									
								}
							
						}catch (Exception e) {
							logger.warn(e.getMessage(), e);
							logger.info("qiannai status : " + e.getMessage()
									+ ", ret = " + ret + "@"
									+ TimeUtils.getSysLogTimeString());
						}
					} else {
						logger.info("qiannai status : " + "fail@"
								+ TimeUtils.getSysLogTimeString());
					}
				}

				request.setAttribute("retjson", obj.toString());
				request.setAttribute("result", "success");

				break;
			}

			request.getRequestDispatcher("request.jsp").forward(request,
					response);%>