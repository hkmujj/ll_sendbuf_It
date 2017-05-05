<%@page import="net.sf.json.JSONArray"%>
<%@page import="util.MD5Util"%>
<%@page
	import="util.TimeUtils,
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

		String mt_url = routeparams.get("mt_url");
		if(mt_url == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, mt_url is null@" + TimeUtils.getSysLogTimeString());
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

		//参数准备, 每个通道不同
		String packagecode = null;
		try{
			packageid = packageid.split("\\.")[1];
		}catch(Exception e){
			logger.warn(e.getMessage(), 0);
		}

		if(packagecode == null){
			request.setAttribute("result", "S." + routeid + ":unrecognized package@" + TimeUtils.getSysLogTimeString());
			break;
		}

		String timestamp = TimeUtils.getTimeStamp();
		String secertKey = MD5Util.getUpperMD5(appKey + timestamp + appsecert);
		JSONArray arr = new JSONArray();
		JSONObject obj = new JSONObject();
		obj.put("productName", packagecode);
		obj.put("mobile", phone);
		obj.put("orderid", taskid);
		arr.add(obj);
		JSONObject json = new JSONObject();
		json.put("appKey", appKey);
		json.put("secertKey", secertKey);
		json.put("timestamp", timestamp);
		json.put("orderList", arr);

		//在执行请求前先获取连接, 防止访问通道线程超量
		Cache.getConnection(routeid);
		try{
			//ret = HttpAccess.postNameValuePairRequest(url, params, "utf-8", "mysend");
			//ret = HttpAccess.postJsonRequest(url, json.toString(), "utf-8", "weikesend");
			ret = HttpAccess.postJsonRequest(mt_url, json.toString(), "utf-8", "yifenxiangsend");

		}catch(Exception e){
			e.printStackTrace();
			logger.info(e.getMessage());
		}finally{
			//在执行请求后记得释放连接
			Cache.releaseConnection(routeid);
		}

		//这里判断结果, 每个通道情况不同, 成功的保存 success 到 result 中并返回到 request.jsp
		if(ret != null && ret.trim().length() > 0){
			logger.info("phone="+phone+",yifenxiang send ret = " + ret);
			try{
				JSONObject retjson = JSONObject.fromObject(ret);
				String code = retjson.getString("code");
				if(code.equals("000")){
					JSONArray resultarr = retjson.getJSONArray("result");
					JSONObject msgidjson = resultarr.getJSONObject(0);
					String msgid = msgidjson.getString("msgid");
					request.setAttribute("result", "success");
					request.setAttribute("reportid", msgid);
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
					request.setAttribute("code", code);
					String resultMsg = map.get(code);
					if(resultMsg == null){
						resultMsg = "失败";
					}
					request.setAttribute("result", "R." + routeid + ":" + code + ":" + resultMsg + "@" + TimeUtils.getSysLogTimeString());

				}

			}catch(Exception e){
				e.printStackTrace();
				logger.info(e.getMessage());
				request.setAttribute("result", "R." + routeid + ":" + e.getMessage() + "@" + TimeUtils.getSysLogTimeString());
			}
		}else{
			request.setAttribute("result", "R." + routeid + ":fail@" + TimeUtils.getSysLogTimeString());
		}

		break;
	}

	request.getRequestDispatcher("request.jsp").forward(request, response);
%>