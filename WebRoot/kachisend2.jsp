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

	while (true) {
		String ret = null;

		//检查通道参数, 每个通道有不同参数, 对应 ll_routes.api_params
		Map<String, String> routeparams = Cache.getRouteParams(routeid);
		if (routeparams == null) {
			request.setAttribute("result", "S." + routeid + ":wrong routeparams@" + TimeUtils.getSysLogTimeString());
			break;
		}

		String mt_url = routeparams.get("mt_url");
		if (mt_url == null) {
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, mt_url is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String sign = routeparams.get("sign");
		if (sign == null) {
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, sign is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String userid = routeparams.get("userid");
		if (userid == null) {
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, userid is null@" + TimeUtils.getSysLogTimeString());
			break;
		}

		//参数准备, 每个通道不同
		String packagecode = null;
		String packagebac = null;
		String packagebef = null;
		try {
			packageid = packageid.split("\\.")[1];
			String pkstr = packageid.substring(0, packageid.length() - 1);
			int pk = Integer.parseInt(pkstr);
			if (packageid.indexOf('G') >= 0) {
				pk *= 1024;
			}
			packagebac = String.valueOf(pk);
		} catch (Exception e) {
			logger.warn(e.getMessage(), 0);
		}

		if (routeid.equals("3198")) {
			//西藏电信
			packagebef = "003011900";
		} else if (routeid.equals("3136")) {
			//山东电信
			packagebef = "003011200";
		} else if (routeid.equals("3138")) {
			//重庆电信
			packagebef = "003010500";
		} else if (routeid.equals("3151")) {
			//内蒙古电信
			packagebef = "003011400";
		} else if (routeid.equals("3217")) {
			//天津电信
			packagebef = "003010300";
		} else if (routeid.equals("1157")) {
			//西藏移动
			packagebef = "001011900";
		} else if (routeid.equals("1096")) {
			//浙江移动
			packagebef = "001010700";
		} else if (routeid.equals("1076")) {
			//安徽移动
			packagebef = "001010800";
		} else if (routeid.equals("1074")) {
			//山西移动
			packagebef = "001012500";
		} else if (routeid.equals("1078")||routeid.equals("1312")) {
			//广东移动
			packagebef = "001011800";
		}
		packagecode = packagebef +packagebac;

		if (packagecode == null || packagebef == null) {
			request.setAttribute("result", "S." + routeid + ":unrecognized package@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String key = MD5Util.getLowerMD5(userid + phone + packagecode + sign);//MD5.digest(userid + mobile + productid + sign);
		Map<String, String> params = new HashMap<String, String>();//请求参数集合
		params.put("userid", userid);
		params.put("mobile", phone);
		params.put("bizid", taskid);
		params.put("productid", packagecode);
		params.put("key", key);
		params.put("notifyurl", "http://120.24.156.98:9302/ll_sendbuf/kachi2return.jsp");

		//在执行请求前先获取连接, 防止访问通道线程超量
		Cache.getConnection(routeid);
		try {
			//ret = HttpAccess.postNameValuePairRequest(url, params, "utf-8", "mysend");
			//ret = HttpAccess.postJsonRequest(url, json.toString(), "utf-8", "weikesend");
			ret = HttpAccess.postNameValuePairRequest(mt_url, params, "utf-8", "kachi2");
		} catch (Exception e) {
			e.printStackTrace();
			logger.info(e.getMessage());
		} finally {
			//在执行请求后记得释放连接
			Cache.releaseConnection(routeid);
		}

		//这里判断结果, 每个通道情况不同, 成功的保存 success 到 result 中并返回到 request.jsp
		if (ret != null && ret.trim().length() > 0) {
			logger.info("kachi2 send ret = " + ret);
			try {
				JSONObject retjson = JSONObject.fromObject(ret);
				String rescode = retjson.getString("resultCode"); //":"MOB00001"
				String result = retjson.getString("resultMsg"); //":"MOB00001"
				if (rescode.equals("T00001")) {
					request.setAttribute("result", "success");
				} else {
					request.setAttribute("code", rescode);
					String resultMsg = result;
					request.setAttribute("result", "R." + routeid + ":" + rescode + ":" + resultMsg + "@" + TimeUtils.getSysLogTimeString());
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

	request.getRequestDispatcher("request.jsp").forward(request, response);
%>