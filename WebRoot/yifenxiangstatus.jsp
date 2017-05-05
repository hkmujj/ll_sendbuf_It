<%@page
	import="util.SHA1,
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
	language="java" pageEncoding="UTF-8"%>
<%
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

		String rp_url = routeparams.get("rp_url");
		if(rp_url == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, rp_url is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String appKey = routeparams.get("appKey");
		if(appKey == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, appKey is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String appsecert = routeparams.get("appsecert");
		if(appsecert == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, appsecert is null@" + TimeUtils.getSysLogTimeString());
			break;
		}

		//发送请求前先准备好参数
		String[] idarray = ids.split(",");
		JSONObject obj = new JSONObject();
		String timestamp = TimeUtils.getTimeStamp();
		String secertKey = MD5Util.getUpperMD5(appKey + timestamp + appsecert);
		for(int i = 0; i < idarray.length; i++){

			JSONObject json = new JSONObject();
			json.put("appKey", appKey);
			json.put("secertKey", secertKey);
			json.put("timestamp", timestamp);
			json.put("msgid", idarray[i]);
			logger.info("yifenxiang status parms=" + json.toString());
			//发送查询/获取状态前先获取连接, 防止访问线程超量
			Cache.getStatusConnection(routeid);
			try{
				ret = HttpAccess.postJsonRequest(rp_url, json.toString(), "utf-8", "yifenxiangstatus");
			}catch(Exception e){
				e.printStackTrace();
				logger.info(e.getMessage());
			}finally{
				//发送查询/获取状态后释放连接
				Cache.releaseStatusConnection(routeid);
			}

			//这里判断结果, 每个通道情况不同, 成功的节点ID对应success, 失败的对应失败信息
			if(ret != null && ret.trim().length() > 0){
				//request.setAttribute("result", "success");
				logger.info("yifenxiang status ret = " + ret);
				try{
					JSONObject retjson = JSONObject.fromObject(ret);
					JSONObject resultjson = retjson.getJSONObject("result");
					String rechargeStatus = resultjson.getString("rechargeStatus");
					String code = resultjson.getString("code");
					if(code.equals("000")){
						if(rechargeStatus.equals("0")){
							JSONObject rp = new JSONObject();
							rp.put("code", 0);
							rp.put("message", "success");
							rp.put("resp", ret);
							obj.put(idarray[i], rp);
						}else if(rechargeStatus.equals("2")){
							logger.info("yifenxiang status : [" + idarray[i] + "]充值中@" + TimeUtils.getSysLogTimeString());
						}else if(rechargeStatus.equals("3")){
							logger.info("yifenxiang status : [" + idarray[i] + "]充值中@订单不存在" + TimeUtils.getSysLogTimeString());
						}else{
							JSONObject rp = new JSONObject();
							rp.put("code", rechargeStatus);
							rp.put("message", resultjson.getString("rechargeDesc"));
							rp.put("resp", ret);
							obj.put(idarray[i], rp);
						}
					}else{
						HashMap<String, String> map = new HashMap<String, String>();
						map.put("000", "请求成功 ");
						map.put("001", "用户名或密码错误 ");
						map.put("002", "管理员不允许调用接口 ");
						map.put("003", "调用传入了空参数 ");
						map.put("004", "用户 IP 未绑定 ");
						map.put("005", "用户被锁定 ");
						map.put("006", "已经超过本月最大充值额度 ");
						map.put("007", "已经超过最大充值额度 ");
						map.put("008", "包含黑名单内的号码 ");
						map.put("009", "未知的号码段 ");
						map.put("010", "不支持的流量包 ");
						map.put("011", "解析报文出现异常 ");
						map.put("012", "调用 Order 接口提交失败 ");
						map.put("013", "参数签名错误");
						String resultMsg = map.get(code);
						if(resultMsg == null){
							resultMsg = "失败";
						}
						logger.info("yifenxiang status : [" + idarray[i] + "]充值中@resultMsg=" + resultMsg + "@" + TimeUtils.getSysLogTimeString());

					}
				}catch(Exception e){
					logger.warn(e.getMessage(), e);
					logger.info("yifenxiang status : " + e.getMessage() + ", ret = " + ret + "@" + TimeUtils.getSysLogTimeString());
				}
			}else{
				logger.info("yifenxiang status : " + "fail@" + TimeUtils.getSysLogTimeString());
			}
		}

		request.setAttribute("retjson", obj.toString());
		request.setAttribute("result", "success");

		break;
	}

	request.getRequestDispatcher("request.jsp").forward(request, response);
%>