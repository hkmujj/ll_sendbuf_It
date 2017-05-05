<%@page import="java.text.SimpleDateFormat,
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
					"S." + routeid + ":wrong routeparams, mrch_no is null@"
							+ TimeUtils.getSysLogTimeString());
			break;
		}
		String mrch_no = routeparams.get("mrch_no");
		if (mrch_no == null) {
			request.setAttribute("result", "S." + routeid
					+ ":wrong routeparams, mrch_no is null@"
					+ TimeUtils.getSysLogTimeString());
			break;
		}
		String serect = routeparams.get("serect");
		if (serect == null) {
			request.setAttribute("result",
					"S." + routeid + ":wrong routeparams, serect is null@"
							+ TimeUtils.getSysLogTimeString());
			break;
		}
		
		//发送请求前先准备好参数
		String[] idarray = ids.split(",");
		JSONObject obj = new JSONObject();
		
		for(int i = 0; i < idarray.length; i++){
				String  request_time=TimeUtils.getTimeStamp();
		
	Map<String, String> map = new HashMap<String, String>();  
	        map.put("mrch_no", mrch_no);  
	        map.put("client_order_no", idarray[i]);  
	        map.put("request_time", request_time);  
	        map.put("order_time", "20"+idarray[i].substring(0,12));  
	        


	          String a="";
	        List<Map.Entry<String, String>> infoIds = new ArrayList<Map.Entry<String, String>>(map.entrySet());  
	          
	        //排序方法  
	        Collections.sort(infoIds, new Comparator<Map.Entry<String, String>>() {     
	            public int compare(Map.Entry<String, String> o1, Map.Entry<String, String> o2) {        
	                return (o1.getKey()).toString().compareTo(o2.getKey());  
	            }  
	        });  
	          
	        //排序后  
		        for(Map.Entry<String, String> m : infoIds){  
		         a=a+m.getKey()+ m.getValue();
		        } 
		        a=a+serect;
		        System.out.println(a);
			    String sign= MD5Util.getLowerMD5(a);
			   JSONObject json=new JSONObject();
			   json.put("mrch_no", mrch_no);
			   json.put("request_time", request_time);
			   json.put("client_order_no",idarray[i] );
			   json.put("order_time", "20"+idarray[i].substring(0,12));
		
			   json.put("sign", sign);
						//发送查询/获取状态前先获取连接, 防止访问线程超量
						Cache.getStatusConnection(routeid);
						try {
						ret = HttpAccess.postJsonRequest(rp_url, json.toString(), "utf-8","zhixin");
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
						logger.info("zhixin status ret = " + ret);
						try {
							JSONObject robj = JSONObject.fromObject(ret);
							String retCode=robj.getString("code");
							if(retCode.equals("2")){
								JSONObject jsondata = robj.getJSONObject("data");
								String staus=jsondata.getString("recharge_status");
								if (staus.equals("2")) {
									JSONObject rp = new JSONObject();
									rp.put("code", 0);
									rp.put("message", "success");
									rp.put("resp", ret);
									obj.put(idarray[i], rp);
								} else  if(staus.equals("6")){
									JSONObject rp = new JSONObject();
									rp.put("code", staus);
									String msg = "失败";
									if(jsondata.get("desc") != null){
										msg = jsondata.getString("desc");
									}
									rp.put("message", msg);
									rp.put("resp", ret);
									obj.put(idarray[i], rp);
								}else if(staus.equals("1")){
 									logger.info("zhixin status : [" + idarray[i] + "]充值中@" + TimeUtils.getSysLogTimeString());				
								}}
							else if(retCode.equals("626")){
								String ordertime=("20"+idarray[i]).substring(0, 14);
								SimpleDateFormat df = new SimpleDateFormat("yyyyMMddHHmmss");
								Date now=df.parse(request_time);
								Date date=df.parse(ordertime);
								long l=now.getTime()-date.getTime();
								   if(l>=720000){
								    JSONObject rp = new JSONObject();
									rp.put("code", "626");
									rp.put("message", robj.getString("message"));
									rp.put("resp", ret);
									obj.put(idarray[i], rp);
									}else{
									logger.info("zhixin status : [" + idarray[i] + "]未查询到订单信息@" + TimeUtils.getSysLogTimeString());							
									}
								} else{
								logger.info("zhixin status : [" + idarray[i] + "]状态码" + retCode+"@" + TimeUtils.getSysLogTimeString());
								
								}
						}catch (Exception e) {
							logger.warn(e.getMessage(), e);
							logger.info("zhixin status : " + e.getMessage()
									+ ", ret = " + ret + "@"
									+ TimeUtils.getSysLogTimeString());
						}
					} else {
						logger.info("zhixin status : " + "fail@"
								+ TimeUtils.getSysLogTimeString());
					}
				}

				request.setAttribute("retjson", obj.toString());
				request.setAttribute("result", "success");

				break;
			}

			request.getRequestDispatcher("request.jsp").forward(request,
					response);%>