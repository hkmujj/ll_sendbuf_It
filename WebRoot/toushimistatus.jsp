<%@page import="java.text.SimpleDateFormat"%>
<%@page import="org.dom4j.DocumentHelper"%>
<%@page import="org.dom4j.Element"%>
<%@page import="org.dom4j.Document"%>
<%@page import="util.SHA1,
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
		language="java" pageEncoding="UTF-8"
%><%boolean logflag = true;
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
		if (rp_url == null) {
			request.setAttribute("result",
					"S." + routeid + ":wrong routeparams, rp_url is null@"
							+ TimeUtils.getSysLogTimeString());
			break;
		}
		String userid = routeparams.get("userid");
		if (userid == null) {
			request.setAttribute("result", "S." + routeid
					+ ":wrong routeparams, userid is null@"
					+ TimeUtils.getSysLogTimeString());
			break;
		}
		String pwd = routeparams.get("pwd");
		if (pwd == null) {
			request.setAttribute("result",
					"S." + routeid + ":wrong routeparams, pwd is null@"
							+ TimeUtils.getSysLogTimeString());
			break;
		}
		String key = routeparams.get("key");
		if (key == null) {
			request.setAttribute("result", "S." + routeid
					+ ":wrong routeparams, key is null@"
					+ TimeUtils.getSysLogTimeString());
			break;
		}
		//发送请求前先准备好参数
				String[] idarray = ids.split(",");
				JSONObject obj = new JSONObject();		
				for(int i = 0; i < idarray.length; i++){	
					Map<String, String> parms=new LinkedHashMap<String, String>();
					parms.put("userid", userid);
					parms.put("pwd", pwd);
					parms.put("orderid", idarray[i]);
					Iterator iter=parms.entrySet().iterator();
					String akey="";
					String burl="";
					while (iter.hasNext()) {
						Map.Entry entry=(Map.Entry)iter.next();
						akey=akey+entry.getKey()+entry.getValue();
					}
					String userkey=MD5Util.getUpperMD5(akey+key);
					
					parms.put("userkey", userkey);
					
					Iterator itera=parms.entrySet().iterator();
			
					while (itera.hasNext()) {
						Map.Entry entry=(Map.Entry)itera.next();
						burl=burl+"&"+entry.getKey()+"="+entry.getValue();
					}
					burl = "?" + burl.substring(1);
					String url = rp_url + burl;
					logger.info("toushimi status url = "+url);
					//发送查询/获取状态前先获取连接, 防止访问线程超量
					Cache.getStatusConnection(routeid);
					try {
		 			 ret=HttpAccess.postNameValuePairRequest(url, new HashMap(), "utf-8", "toushimi");
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
						logger.info("toushimi status ret = " + ret);
						try {
							Document document = DocumentHelper.parseText(ret);
							Element root=document.getRootElement();
							Element	errele=root.element("error");
							Element staele=root.element("state");
							String error=errele.getText();
							String state=staele.getText();
							if(error.equals("0")){
								if (state.equals("1")) {
									JSONObject rp = new JSONObject();
									rp.put("code", 0);
									rp.put("message", "success");
									rp.put("resp", ret);
									obj.put(idarray[i], rp);
								} else if(state.equals("2"))  {
									JSONObject rp = new JSONObject();
									rp.put("code", state);
									rp.put("message", "充值失败");
									rp.put("resp", ret);
									obj.put(idarray[i], rp);
								}else {
									logger.info("toushimi status : [" + idarray[i]+ "]充值中@"+ TimeUtils.getSysLogTimeString());	
								}
							}else if(error.equals("1007")){
								String ordertime=("20"+idarray[i]).substring(0, 14);
								SimpleDateFormat df = new SimpleDateFormat("yyyyMMddHHmmss");
								Date date=df.parse(ordertime);
								long l=System.currentTimeMillis()-date.getTime();
 								 if(l>=720000){
								    JSONObject rp = new JSONObject();
									rp.put("code", "1007");
									rp.put("message", "充值失败");
									rp.put("resp", ret);
									obj.put(idarray[i], rp);
									}else{
										logger.info("zhixin status : [" + idarray[i] + "]未查询到订单信息@" + TimeUtils.getSysLogTimeString());							
									}							   
							}else{
								logger.info("toushimi status : [" + idarray[i]+ "]充值中@"+ TimeUtils.getSysLogTimeString());
							}
						} catch (Exception e) {
							logger.warn(e.getMessage(), e);
							logger.info("toushimi status : " + e.getMessage()
									+ ", ret = " + ret + "@"
									+ TimeUtils.getSysLogTimeString());
						}
					} else {
						logger.info("toushimi status : " + "fail@"
								+ TimeUtils.getSysLogTimeString());
					}
				}

				request.setAttribute("retjson", obj.toString());
				request.setAttribute("result", "success");

				break;
			}

			request.getRequestDispatcher("request.jsp").forward(request,
					response);%>