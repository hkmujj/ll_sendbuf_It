<%@page import="javax.crypto.spec.IvParameterSpec"%>
<%@page import="javax.crypto.spec.SecretKeySpec"%>
<%@page import="javax.xml.bind.DatatypeConverter"%>
<%@page import="javax.crypto.Cipher"%>
<%@page import="java.security.MessageDigest"%>
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
<%!public static String aesebcrypt(String input, String key, String vi) {
		try {
			Cipher cipher = Cipher.getInstance("AES/CBC/PKCS5Padding");

			cipher.init(Cipher.ENCRYPT_MODE, new SecretKeySpec(key.getBytes(), "AES"), new IvParameterSpec(vi.getBytes()));
			byte[] encrypted = cipher.doFinal(input.getBytes("utf-8"));
			return DatatypeConverter.printBase64Binary(encrypted);

		} catch (Exception e) {
			return null;
		}

	}%>
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
		String partner_no = routeparams.get("partner_no");
		if (partner_no == null) {
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, partner_no is null@" + TimeUtils.getSysLogTimeString());
			break;
		}

		//发送请求前先准备好参数
		String[] idarray = ids.split(",");
		JSONObject obj = new JSONObject();
		for (int i = 0; i < idarray.length; i++) {
			JSONObject reqjson = new JSONObject();
			reqjson.put("request_no", idarray[i]);
			reqjson.put("contract_id", partner_no);
			reqjson.put("partner_no", partner_no);
			//发送查询/获取状态前先获取连接, 防止访问线程超量
			Cache.getStatusConnection(routeid);
			try {
				ret = HttpAccess.postJsonRequest(rp_url, reqjson.toString(), "utf-8", "leliu");
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
				logger.info("leliu status ret = " + ret);
				try {
					JSONObject robj = JSONObject.fromObject(ret);
					String orderid = robj.getString("order_id");
					if (orderid != null) {
						String status = robj.getString("orderstatus");
						String result = robj.getString("result_code");
						if (status.equals("finish") && !result.equals("77777")) {
							JSONObject rp = new JSONObject();
							rp.put("code", 0);
							rp.put("message", "success");
							rp.put("resp", ret);
							obj.put(idarray[i], rp);
						} else if (status.equals("fail") && !result.equals("77777")) {
							JSONObject rp = new JSONObject();
							rp.put("code", result);
							String msg = "失败";
							if (robj.get("result_desc") != null) {
								msg = robj.getString("result_desc");
							}
							rp.put("message", msg);
							rp.put("resp", ret);
							obj.put(idarray[i], rp);
						} else {
							logger.info("leliu status : [" + idarray[i] + "]充值中@" + TimeUtils.getSysLogTimeString());
						}

					} else {
						logger.info("leliu status : [" + idarray[i] + "]充值中@" + TimeUtils.getSysLogTimeString());
					}

				} catch (Exception e) {
					logger.warn(e.getMessage(), e);
					logger.info("leliu status : " + e.getMessage() + ", ret = " + ret + "@" + TimeUtils.getSysLogTimeString());
				}
			} else {
				logger.info("leliu status : " + "fail@" + TimeUtils.getSysLogTimeString());
			}
		}

		request.setAttribute("retjson", obj.toString());
		request.setAttribute("result", "success");

		break;
	}

	request.getRequestDispatcher("request.jsp").forward(request, response);
%>