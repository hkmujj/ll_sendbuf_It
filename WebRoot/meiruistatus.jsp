<%@page import="org.dom4j.DocumentHelper"%>
<%@page import="org.dom4j.Document"%>
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
		String key = routeparams.get("key");
		if(key == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, key is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String userId = routeparams.get("userId");
		if(userId == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, userId is null@" + TimeUtils.getSysLogTimeString());
			break;
		}

		//发送请求前先准备好参数
		String[] idarray = ids.split(",");
		JSONObject obj = new JSONObject();

		for(int i = 0; i < idarray.length; i++){

			String c = idarray[i] + userId + key;
			String sign = MD5Util.getLowerMD5(c);
			HashMap<String, String> urlparm = new HashMap<String, String>();
			urlparm.put("userId", userId);
			urlparm.put("order_no", idarray[i]);
			urlparm.put("sign", sign);
			//发送查询/获取状态前先获取连接, 防止访问线程超量
			Cache.getStatusConnection(routeid);
			try{
				ret = HttpAccess.getNameValuePairRequest(rp_url, urlparm, "utf-8", "meirui");
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
				logger.info("meirui status ret = " + ret);
				try{
					Document doc = DocumentHelper.parseText(ret);
					String status = doc.getRootElement().element("data").elementText("orderstatus");
					String statusdesc = doc.getRootElement().element("data").elementText("statusdesc");
					if(status.equals("2") && statusdesc.equals("成功")){
						JSONObject rp = new JSONObject();
						rp.put("code", 0);
						rp.put("message", "success");
						rp.put("resp", ret);
						obj.put(idarray[i], rp);
					}else if(status.equals("3") && statusdesc.equals("失败")){
						JSONObject rp = new JSONObject();
						rp.put("code", status);

						rp.put("message", statusdesc);
						rp.put("resp", ret);
						obj.put(idarray[i], rp);
					}else{
						logger.info("meirui status : [" + idarray[i] + "]充值中," +statusdesc+"@"+ TimeUtils.getSysLogTimeString());
					}

				}catch(Exception e){
					logger.warn(e.getMessage(), e);
					logger.info("meirui status : " + e.getMessage() + ", ret = " + ret + "@" + TimeUtils.getSysLogTimeString());
				}
			}else{
				logger.info("meirui status : " + "fail@" + TimeUtils.getSysLogTimeString());
			}
		}

		request.setAttribute("retjson", obj.toString());
		request.setAttribute("result", "success");

		break;
	}

	request.getRequestDispatcher("request.jsp").forward(request, response);
%>