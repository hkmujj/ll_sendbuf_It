<%@page import="org.dom4j.DocumentHelper"%>
<%@page import="org.dom4j.Element"%>
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
	out.clearBuffer();
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
		String userid = routeparams.get("userid");
		if(userid == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, userid is null@" + TimeUtils.getSysLogTimeString());
			break;
		}

		//发送请求前先准备好参数
		String[] idarray = ids.split(",");
		JSONObject obj = new JSONObject();

		for(int i = 0; i < idarray.length; i++){
					HashMap<String, String> param=new LinkedHashMap<String, String>();
					param.put("userid", userid);
					param.put("sporderid", idarray[i]);
			//发送查询/获取状态前先获取连接, 防止访问线程超量
			Cache.getStatusConnection(routeid);
			try{
				ret = HttpAccess.postNameValuePairRequest(rp_url, param, "utf-8",  "zonghe");
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
				logger.info("zonghe status ret = " + ret);
				try{
					Document document = DocumentHelper.parseText(ret);
					Element root = document.getRootElement();
					Element resultno = root.element("resultno");
					String retCode=resultno.getText();
						if(retCode.equals("1")){
							JSONObject rp = new JSONObject();
							rp.put("code", 0);
							rp.put("message", "success");
							rp.put("resp", ret);
							obj.put(idarray[i], rp);
						}else if(retCode.equals("9")){
							JSONObject rp = new JSONObject();
							rp.put("code", retCode);
							rp.put("message", "充值失败");
							rp.put("resp", ret);
							obj.put(idarray[i], rp);
						}else{
					logger.info("zonghe status : [" + idarray[i] + "]充值中@" + TimeUtils.getSysLogTimeString());
						}
				
				}catch(Exception e){
					logger.warn(e.getMessage(), e);
					logger.info("zonghe status : " + e.getMessage() + ", ret = " + ret + "@" + TimeUtils.getSysLogTimeString());
				}
			}else{
				logger.info("zonghe status : " + "fail@" + TimeUtils.getSysLogTimeString());
			}
		}

		request.setAttribute("retjson", obj.toString());
		request.setAttribute("result", "success");

		break;
	}

	request.getRequestDispatcher("request.jsp").forward(request, response);
%>