<%@page
	import="util.MD5Util,
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
		String url = routeparams.get("url");
		if (url == null) {
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, url is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String user = routeparams.get("user");
		if (user == null) {
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, user is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String agent_id = routeparams.get("agent_id");
		if (agent_id == null) {
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, agent_id is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String key = routeparams.get("key");
		if (key == null) {
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, key is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String product = routeparams.get("product");
		if (product == null) {
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, product is null@" + TimeUtils.getSysLogTimeString());
			break;
		}

		//参数准备, 每个通道不同
		String packagecode = null;

		String operator = packageid.split("\\.")[0];
		packageid = packageid.split("\\.")[1];
		if (operator.equals("dx")) {
			packagecode = "ZGDX" + product + "_" + packageid;
		} else if (operator.equals("lt")) {
			packagecode = "ZGLT" + product + "_" + packageid;
		} else if (operator.equals("yd")) {
			packagecode = "ZGYD" + product + "_" + packageid;
		}

		if (packagecode == null) {
			request.setAttribute("result", "S." + routeid + ":unrecognized package@" + TimeUtils.getSysLogTimeString());
			break;
		}

		String nonce = "" + System.currentTimeMillis();
		url = url + "buy_flow";
		String signstr = "agent_id=" + agent_id + "&nonce=" + nonce.substring(0, 10) + "&user=" + user + "&key=" + key;
		System.out.println(signstr);
		String sign = "";
		sign = MD5Util.getLowerMD5(signstr);
		JSONObject obj = new JSONObject();
		obj.put("agent_id", agent_id);
		obj.put("user", user);
		obj.put("mobile", phone);
		obj.put("flow_id", packagecode);
		obj.put("third_no", taskid);
		obj.put("nonce", nonce.substring(0, 10));
		obj.put("sign", sign);

		//在执行请求前先获取连接, 防止访问通道线程超量
		Cache.getConnection(routeid);
		try {
			logger.info("zhongxing org json = " + obj.toString());
			ret = http.HttpAccess.postJsonRequest(url, obj.toString(), "utf-8", "zhongxing");

		} catch (Exception e) {
			e.printStackTrace();
			logger.info(e.getMessage());
		} finally {
			//在执行请求后记得释放连接
			Cache.releaseConnection(routeid);
		}

		//这里判断结果, 每个通道情况不同, 成功的保存 success 到 result 中并返回到 request.jsp
		if (ret != null && ret.trim().length() > 0) {
			logger.info("zhongxing send ret = " + ret);
			try {
				JSONObject retjson = JSONObject.fromObject(ret);
				String resultCode = retjson.getString("code"); //":"MOB00001"
				if (resultCode.equals("0")) {
					JSONObject datajson = retjson.getJSONObject("data");
					if (datajson != null) {
						String reportid = datajson.getString("order_no");
						request.setAttribute("result", "success");
						request.setAttribute("reportid", reportid);

					} else {
						request.setAttribute("code", resultCode);
						String resultMsg = retjson.getString("msg");
						if (resultMsg == null) {
							resultMsg = "@S充值提交失败";
						}
						request.setAttribute("result",
								"R." + routeid + ":" + resultCode + ":" + resultMsg + "@" + TimeUtils.getSysLogTimeString());
					}
				} else {
					request.setAttribute("code", resultCode);
					String resultMsg = retjson.getString("msg");
					if (resultMsg == null) {
						resultMsg = "@S充值提交失败";
					}
					request.setAttribute("result",
							"R." + routeid + ":" + resultCode + ":" + resultMsg + "@" + TimeUtils.getSysLogTimeString());
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