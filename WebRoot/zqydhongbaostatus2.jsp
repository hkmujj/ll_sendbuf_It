<%@page import="java.util.regex.Pattern"%>
<%@page import="key.Key"%>
<%@page import="com.aspire.portal.web.security.client.GenerateSignature"%>
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

		String portaltype = routeparams.get("portaltype");
		if(portaltype == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, portaltype is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String portalid = routeparams.get("portalid");
		if(portalid == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, portalid is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String url = routeparams.get("url");
		if(url == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, url is null@" + TimeUtils.getSysLogTimeString());
			break;
		}

		//发送请求前先准备好参数
		String[] idarray = ids.split(",");
		JSONObject obj = new JSONObject();

		for(int i = 0; i < idarray.length; i++){
			Map<String, String> parm = new HashMap<String, String>();
			parm.put("portalType", portaltype);
			parm.put("portalID", portalid);
			String t = String.valueOf(System.currentTimeMillis());
			parm.put("transactionID", TimeUtils.getTimeStamp().substring(2) + t.substring(0, 8));
			parm.put("method", "companyDonateFlow");
			parm.put("mobile", idarray[i].substring(idarray[i].length() - 11));
			parm.put("sequence", idarray[i].substring(0, idarray[i].length() - 11));
			StringBuffer sb = new StringBuffer();

			sb.append("method=");
			sb.append(parm.get("method"));
			sb.append("&mobile=");
			sb.append(parm.get("mobile"));
			sb.append("&portalID=");
			sb.append(parm.get("portalID"));
			sb.append("&portalType=");
			sb.append(parm.get("portalType"));
			sb.append("&sequence=");
			sb.append(parm.get("sequence"));
			sb.append("&transactionID=");
			sb.append(parm.get("transactionID"));
			logger.info("zqhongbaostatus2 sign string=" + sb.toString());
			GenerateSignature gs = new GenerateSignature();
			String path = Key.keypath + "liulianghongbao/rasPrivateKey.txt";
			String sign = gs.sign(sb.toString(), path);
			parm.put("sign", sign);

			//发送查询/获取状态前先获取连接, 防止访问线程超量
			Cache.getStatusConnection(routeid);
			try{
				ret = http.HttpAccess.postNameValuePairRequest(url, parm, "utf-8", "zqhongbaostatus2");
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
				logger.info("zqydhongbao  status ret = " + ret);
				try{
					JSONObject robj = JSONObject.fromObject(ret);
					String retCode = robj.getString("code");
					if(retCode.equals("0")){
						JSONObject jsondata = robj.getJSONObject("result");
						String staus = jsondata.getString("retCode");
						if(staus.equals("0")){
							JSONObject rp = new JSONObject();
							rp.put("code", 0);
							rp.put("message", "success");
							rp.put("resp", ret);
							obj.put(idarray[i], rp);
						}else if(staus.trim().length() == 0){
							logger.info("zqydhongbao  status : [" + idarray[i] + "]充值中@" + TimeUtils.getSysLogTimeString());
						}else if(staus.trim().length() > 0){
							JSONObject rp = new JSONObject();
							rp.put("code", staus);
							String msg = "失败";
							if(jsondata.get("desc") != null){
								msg = jsondata.getString("reqMsg");
							}
							rp.put("message", msg);
							rp.put("resp", ret);
							obj.put(idarray[i], rp);
						}else{
							logger.info("zqydhongbao  status : [" + idarray[i] + "]充值中@" + TimeUtils.getSysLogTimeString());
						}
					}else{
						logger.info("zqydhongbao  status : [" + idarray[i] + "]状态码" + retCode + "@" + TimeUtils.getSysLogTimeString());

					}
				}catch(Exception e){
					logger.warn(e.getMessage(), e);
					logger.info("zqydhongbao  status : " + e.getMessage() + ", ret = " + ret + "@" + TimeUtils.getSysLogTimeString());
				}
			}else{
				logger.info("zqydhongbao  status : " + "fail@" + TimeUtils.getSysLogTimeString());
			}
		}

		request.setAttribute("retjson", obj.toString());
		request.setAttribute("result", "success");

		break;
	}

	request.getRequestDispatcher("request.jsp").forward(request, response);
%>