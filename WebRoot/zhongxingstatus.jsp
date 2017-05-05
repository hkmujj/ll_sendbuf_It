<%@page
	import="java.text.SimpleDateFormat,
				util.SHA1,
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

	while (true) {
		String ret = null;

		//获取公共参数
		String routeid = request.getAttribute("routeid").toString();

		Object idsobj = request.getAttribute("ids");
		if (idsobj == null) {
			request.setAttribute("result", "S." + routeid + ":ids are needed to get status@" + TimeUtils.getSysLogTimeString());
			break;
		}

		String ids = idsobj.toString();

		logger.info("ids = " + ids + ", routeid = " + routeid);

		//获取通道能数, 每个通道不同
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

		//发送请求前先准备好参数
		String[] idarray = ids.split(",");
		JSONObject obj = new JSONObject();

		for (int i = 0; i < idarray.length; i++) {
			String nonce = "" + System.currentTimeMillis();
			String signstr = "agent_id=" + agent_id + "&nonce=" + nonce.substring(0, 10) + "&user=" + user + "&key=" + key;
			System.out.println(signstr);
			String sign = "";
			sign = MD5Util.getLowerMD5(signstr);
			JSONObject parmjson = new JSONObject();
			parmjson.put("agent_id", agent_id);
			parmjson.put("user", user);
			parmjson.put("order_no", idarray[i]);
			parmjson.put("nonce", nonce.substring(0, 10));
			parmjson.put("sign", sign);
			url = url + "order_info";

			//发送查询/获取状态前先获取连接, 防止访问线程超量
			Cache.getStatusConnection(routeid);
			try {
				ret = http.HttpAccess.postJsonRequest(url, parmjson.toString(), "utf-8", "zhongxing");
			} catch (Exception e) {
				e.printStackTrace();
				logger.info(e.getMessage());
			} finally {
				//发送查询/获取状态后释放连接
				Cache.releaseStatusConnection(routeid);
			}

			//这里判断结果, 每个通道情况不同, 成功的节点ID对应success, 失败的对应失败信息
			if (ret != null && ret.trim().length() > 0) {
				//request.setAttribute("result", "success");
				logger.info("zhongxing status ret = " + ret);
				try {
					JSONObject robj = JSONObject.fromObject(ret);
					String retCode = robj.getString("code");
					if (retCode.equals("0")) {
						JSONObject jsondata = robj.getJSONObject("data");
						String staus = jsondata.getString("status");
						if (staus.equals("1")) {
							JSONObject rp = new JSONObject();
							rp.put("code", 0);
							rp.put("message", "success");
							rp.put("resp", ret);
							obj.put(idarray[i], rp);
						} else if (staus.equals("2") || staus.equals("3")) {
							JSONObject rp = new JSONObject();
							rp.put("code", staus);
							String msg = "失败";
							if (jsondata.get("msg") != null && !robj.getString("msg").equals("success")) {
								msg = jsondata.getString("msg");
							}
							rp.put("message", msg);
							rp.put("resp", ret);
							obj.put(idarray[i], rp);
						} else {
							logger.info("zhongxing status : [" + idarray[i] + "]充值中@" + TimeUtils.getSysLogTimeString());
						}
					} else {
						String msg = robj.getString("msg");
						logger.info("zhongxing status : [" + idarray[i] + "]查询失败@" + msg + "@状态码" + retCode + "@"
								+ TimeUtils.getSysLogTimeString());
					}
				} catch (Exception e) {
					logger.warn(e.getMessage(), e);
					logger.info("zhongxing status : " + e.getMessage() + ", ret = " + ret + "@" + TimeUtils.getSysLogTimeString());
				}
			} else {
				logger.info("zhongxing status : " + "fail@" + TimeUtils.getSysLogTimeString());
			}
		}

		request.setAttribute("retjson", obj.toString());
		request.setAttribute("result", "success");

		break;
	}

	request.getRequestDispatcher("request.jsp").forward(request, response);
%>