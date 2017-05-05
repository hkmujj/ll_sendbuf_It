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

		String rp_url = routeparams.get("rp_url");
		if (rp_url == null) {
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, mrch_no is null@" + TimeUtils.getSysLogTimeString());
			break;
		}

		String apikey = routeparams.get("apikey");
		if (apikey == null) {
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, apikey is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String confId = routeparams.get("confId");
		if (confId == null) {
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, confId is null@" + TimeUtils.getSysLogTimeString());
			break;
		}

		//发送请求前先准备好参数
		String[] idarray = ids.split(",");
		JSONObject obj = new JSONObject();

		for (int i = 0; i < idarray.length; i++) {
			String t = String.valueOf(System.currentTimeMillis() / 1000);
			String beforeMd5 = apikey + confId + idarray[i] + t;
			String sign = MD5Util.getLowerMD5(beforeMd5);
			rp_url = rp_url + "?confId=" + confId + "&seqNo=" + idarray[i] + "&t=" + t + "&sign=" + sign;

			//发送查询/获取状态前先获取连接, 防止访问线程超量
			Cache.getStatusConnection(routeid);
			try {
				ret = HttpAccess.postNameValuePairRequest(rp_url, new HashMap(), "utf-8", "choumou");
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
				logger.info("choumou status ret = " + ret);
				try {
					JSONObject robj = JSONObject.fromObject(ret);
					String retCode = robj.getString("retCode");
					String staus = null;
					if (robj.get("status") != null) {
						staus = robj.getString("status");
						if (staus.equals("3")) {
							JSONObject rp = new JSONObject();
							rp.put("code", 0);
							rp.put("message", "success");
							rp.put("resp", ret);
							obj.put(idarray[i], rp);
						} else if (staus.equals("4")) {
							JSONObject rp = new JSONObject();
							rp.put("code", staus);
							String msg = "失败";
							rp.put("message", msg);
							rp.put("resp", ret);
							obj.put(idarray[i], rp);
						} else {
							logger.info("choumou status : [" + idarray[i] + "]充值中@" + TimeUtils.getSysLogTimeString());
						}
					} else {
						logger.info("choumou status : [" + idarray[i] + "]充值中@" + TimeUtils.getSysLogTimeString());
					}
				} catch (Exception e) {
					logger.warn(e.getMessage(), e);
					logger.info("choumou status : " + e.getMessage() + ", ret = " + ret + "@" + TimeUtils.getSysLogTimeString());
				}
			} else {
				logger.info("choumou status : " + "fail@" + TimeUtils.getSysLogTimeString());
			}
		}

		request.setAttribute("retjson", obj.toString());
		request.setAttribute("result", "success");

		break;
	}

	request.getRequestDispatcher("request.jsp").forward(request, response);
%>