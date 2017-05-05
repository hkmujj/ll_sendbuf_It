<%@page import="util.MD5Util,
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
	request.setAttribute("result","S." + routeid + ":wrong routeparams@"+ TimeUtils.getSysLogTimeString());
	break;
		}

		String url = routeparams.get("url");
		if (url == null) {
	request.setAttribute("result",
	"S." + routeid + ":wrong routeparams, url is null@"
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
		

		//参数准备, 每个通道不同
		String packagecode = null;
		try {
	packageid = packageid.split("\\.")[1];
	String pkstr = packageid.substring(0,
	packageid.length() - 1);
	int pk = Integer.parseInt(pkstr);
	if (packageid.indexOf('G') >= 0) {
		pk *= 1024;
	}
	packagecode = String.valueOf(pk);
		} catch (Exception e) {
	logger.warn(e.getMessage(), 0);
		}

		if (packagecode == null) {
	request.setAttribute("result",
	"S." + routeid + ":unrecognized package@"
	+ TimeUtils.getSysLogTimeString());
	break;
		}

	    String  sign="";
		String  request_time=TimeUtils.getTimeStamp();
		 Map<String, String> map = new HashMap<String, String>();  
	        map.put("mrch_no", mrch_no);  
	        map.put("client_order_no", taskid);  
	        map.put("request_time", request_time);  
	        map.put("product_type", "4");  
	        map.put("phone_no", phone);  
	        map.put("recharge_amount", packagecode);  
	        map.put("recharge_type", "0");  
	        map.put("recharge_desc", "");  
	        map.put("city_code", "");  
	        map.put("cp", "");  
	        map.put("notify_url", "");  


	          String a="";
	        List<Map.Entry<String, String>> infoIds = new ArrayList<Map.Entry<String, String>>(map.entrySet());  
	          
	        //排序方法  
	        Collections.sort(infoIds, new Comparator<Map.Entry<String, String>>() {     
	            public int compare(Map.Entry<String, String> o1, Map.Entry<String, String> o2) {        
	                return (o1.getKey()).toString().compareTo(o2.getKey());  
	            }  
	        });  
	          
	        //排序后  
		for (Map.Entry<String, String> m : infoIds) {
			a = a + m.getKey() + m.getValue();
		}
		a = a + serect;
		sign = MD5Util.getLowerMD5(a);
		JSONObject obj = new JSONObject();
		obj.put("mrch_no", mrch_no);
		obj.put("request_time", request_time);
		obj.put("client_order_no", taskid);
		obj.put("product_type", "4");
		obj.put("phone_no", phone);
		obj.put("recharge_amount", packagecode);
		obj.put("recharge_type", "0");
		obj.put("sign", sign);
		obj.put("recharge_desc", "");
		obj.put("city_code", "");
		obj.put("cp", "");
		obj.put("notify_url", "");

		//在执行请求前先获取连接, 防止访问通道线程超量
		Cache.getConnection(routeid);
		try {
			//ret = HttpAccess.postNameValuePairRequest(url, params, "utf-8", "mysend");
			//ret = HttpAccess.postJsonRequest(url, json.toString(), "utf-8", "weikesend");
		    logger.info("zhixin org json = " + obj.toString());
			ret = HttpAccess.postJsonRequest(url, obj.toString(), "utf-8", "zhixin");

		} catch (Exception e) {
			e.printStackTrace();
			logger.info(e.getMessage());
		} finally {
			//在执行请求后记得释放连接
			Cache.releaseConnection(routeid);
		}

		//这里判断结果, 每个通道情况不同, 成功的保存 success 到 result 中并返回到 request.jsp
		if (ret != null && ret.trim().length() > 0) {
			logger.info("zhixin send ret = " + ret);
			try {
				JSONObject retjson = JSONObject.fromObject(ret);
				String resultCode = retjson.getString("code"); //":"MOB00001"
				if (resultCode.equals("2")) {
					request.setAttribute("result", "success");
				    //request.setAttribute("reportid",taskid);
				} else {
					request.setAttribute("code", resultCode);
					String resultMsg = retjson.getString("message");
					request.setAttribute("result", "R." + routeid + ":"
							+ resultCode + ":" + resultMsg + "@"
							+ TimeUtils.getSysLogTimeString());
				}
				request.setAttribute("orgreturn", ret);
			} catch (Exception e) {
				e.printStackTrace();
				logger.info(e.getMessage());
				request.setAttribute("result",
						"R." + routeid + ":" + e.getMessage() + "@"
								+ TimeUtils.getSysLogTimeString());
			}
		} else {
			request.setAttribute("result", "R." + routeid + ":fail@"
					+ TimeUtils.getSysLogTimeString());
		}

		break;
	}

	request.getRequestDispatcher("request.jsp").forward(request,
			response);
%>