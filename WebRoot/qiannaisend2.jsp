<%@page import="util.MD5Util"%>
<%@page
	import="util.TimeUtils,
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

	//获取公共参数
	String taskid = request.getAttribute("taskid").toString();
	String routeid = request.getAttribute("routeid").toString();
	String phone = request.getAttribute("phone").toString();
	String packageid = request.getAttribute("package").toString();

	while(true){
		String ret = null;

		//检查通道参数, 每个通道有不同参数, 对应 ll_routes.api_params
		Map<String, String> routeparams = Cache.getRouteParams(routeid);
		if(routeparams == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams@" + TimeUtils.getSysLogTimeString());
			break;
		}

		String url = routeparams.get("url");
		if(url == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, url is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String accountId = routeparams.get("accountId");
		if(accountId == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, accountId is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String key = routeparams.get("key");
		if(key == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, key is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String userName = routeparams.get("userName");
		if(userName == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, userName is null@" + TimeUtils.getSysLogTimeString());
			break;
		}

		//参数准备, 每个通道不同
		String packagecode = null;

		if(routeid.equals("3072")){
			//上海
			if(packageid.equals("dx.10M")){
				packagecode = "10000002";
			}else if(packageid.equals("dx.30M")){
				packagecode = "10000011";
			}else if(packageid.equals("dx.50M")){
				packagecode = "10000019";
			}else if(packageid.equals("dx.100M")){
				packagecode = "10000031";
			}else if(packageid.equals("dx.200M")){
				packagecode = "10000047";
			}else if(packageid.equals("dx.500M")){
				packagecode = "10000071";
			}else if(packageid.equals("dx.1G")){
				packagecode = "10000094";
			}
		}else if(routeid.equals("3192")){
			//天津
			if(packageid.equals("dx.5M")){
				packagecode = "10000439";
			}else if(packageid.equals("dx.10M")){
				packagecode = "10000440";
			}else if(packageid.equals("dx.30M")){
				packagecode = "10000441";
			}else if(packageid.equals("dx.50M")){
				packagecode = "10000442";
			}else if(packageid.equals("dx.100M")){
				packagecode = "10000443";
			}else if(packageid.equals("dx.200M")){
				packagecode = "10000444";
			}else if(packageid.equals("dx.500M")){
				packagecode = "10000445";
			}else if(packageid.equals("dx.1G")){
				packagecode = "10000446";
			}
		}else if(routeid.equals("3056")){
			//广东
			if(packageid.equals("dx.5M")){
				packagecode = "10000004";
			}else if(packageid.equals("dx.10M")){
				packagecode = "10000016";
			}else if(packageid.equals("dx.30M")){
				packagecode = "10000032";
			}else if(packageid.equals("dx.50M")){
				packagecode = "10000039";
			}else if(packageid.equals("dx.100M")){
				packagecode = "10000053";
			}else if(packageid.equals("dx.200M")){
				packagecode = "10000064";
			}else if(packageid.equals("dx.500M")){
				packagecode = "10000082";
			}else if(packageid.equals("dx.1G")){
				packagecode = "10000089";
			}
		}else if(routeid.equals("3202")){
			//江苏
			if(packageid.equals("dx.2G")){
				packagecode = "10000577";
			}
		}else if(routeid.equals("3201")){
			//青海
			if(packageid.equals("dx.5M")){
				packagecode = "10000578";
			}else if(packageid.equals("dx.10M")){
				packagecode = "10000579";
			}else if(packageid.equals("dx.30M")){
				packagecode = "10000580";
			}else if(packageid.equals("dx.50M")){
				packagecode = "10000581";
			}else if(packageid.equals("dx.100M")){
				packagecode = "10000582";
			}else if(packageid.equals("dx.200M")){
				packagecode = "10000583";
			}else if(packageid.equals("dx.500M")){
				packagecode = "10000584";
			}else if(packageid.equals("dx.1G")){
				packagecode = "10000585";
			}
		}else if(routeid.equals("3161")){
			//陕西
			if(packageid.equals("dx.5M")){
				packagecode = "10000159";
			}else if(packageid.equals("dx.10M")){
				packagecode = "10000160";
			}else if(packageid.equals("dx.30M")){
				packagecode = "10000161";
			}else if(packageid.equals("dx.50M")){
				packagecode = "10000162";
			}else if(packageid.equals("dx.100M")){
				packagecode = "10000163";
			}else if(packageid.equals("dx.200M")){
				packagecode = "10000164";
			}else if(packageid.equals("dx.500M")){
				packagecode = "10000166";
			}else if(packageid.equals("dx.1G")){
				packagecode = "10000167";
			}
		}else if(routeid.equals("3162")){
			//河北
			if(packageid.equals("dx.5M")){
				packagecode = "10000387";
			}else if(packageid.equals("dx.10M")){
				packagecode = "10000388";
			}else if(packageid.equals("dx.30M")){
				packagecode = "10000389";
			}else if(packageid.equals("dx.50M")){
				packagecode = "10000390";
			}else if(packageid.equals("dx.100M")){
				packagecode = "10000391";
			}else if(packageid.equals("dx.200M")){
				packagecode = "10000392";
			}else if(packageid.equals("dx.500M")){
				packagecode = "10000393";
			}else if(packageid.equals("dx.1G")){
				packagecode = "10000394";
			}
		}else if(routeid.equals("3041")){
			//江苏
			if(packageid.equals("dx.5M")){
				packagecode = "10000168";
			}else if(packageid.equals("dx.10M")){
				packagecode = "10000169";
			}else if(packageid.equals("dx.30M")){
				packagecode = "10000170";
			}else if(packageid.equals("dx.50M")){
				packagecode = "10000171";
			}else if(packageid.equals("dx.100M")){
				packagecode = "10000172";
			}else if(packageid.equals("dx.200M")){
				packagecode = "10000173";
			}else if(packageid.equals("dx.300M")){
				packagecode = "10000174";
			}else if(packageid.equals("dx.500M")){
				packagecode = "10000175";
			}else if(packageid.equals("dx.1G")){
				packagecode = "10000176";
			}
		}else if(routeid.equals("3071")){
			//浙江
			if(packageid.equals("dx.5M")){
				packagecode = "10000541";
			}else if(packageid.equals("dx.10M")){
				packagecode = "10000542";
			}else if(packageid.equals("dx.30M")){
				packagecode = "10000543";
			}else if(packageid.equals("dx.50M")){
				packagecode = "10000546";
			}else if(packageid.equals("dx.100M")){
				packagecode = "10000544";
			}else if(packageid.equals("dx.200M")){
				packagecode = "10000545";
			}else if(packageid.equals("dx.500M")){
				packagecode = "10000547";
			}else if(packageid.equals("dx.1G")){
				packagecode = "10000548";
			}
		}else if(routeid.equals("3049")){
			//全国
		/* 	 if(packageid.equals("dx.100M")){
				packagecode = "10000049";
			}else if(packageid.equals("dx.200M")){
				packagecode = "10000060";
			}else if(packageid.equals("dx.500M")){
				packagecode = "10000075";
			}else if(packageid.equals("dx.1G")){
				packagecode = "10000086";
			} */
			 if(packageid.equals("dx.100M")){
				packagecode = "10000401";
			}else if(packageid.equals("dx.200M")){
				packagecode = "10000402";
			}else if(packageid.equals("dx.500M")){
				packagecode = "10000403";
			}else if(packageid.equals("dx.1G")){
				packagecode = "10000404";
			}
		 	
			/*if(packageid.equals("dx.5M")){
				packagecode = "10000006";
			}else if(packageid.equals("dx.10M")){
				packagecode = "10000015";
			}else if(packageid.equals("dx.30M")){
				packagecode = "10000026";
			}else if(packageid.equals("dx.50M")){
				packagecode = "10000037";
			}else if(packageid.equals("dx.100M")){
				packagecode = "10000049";
			}else if(packageid.equals("dx.200M")){
				packagecode = "10000060";
			}else if(packageid.equals("dx.500M")){
				packagecode = "10000075";
			}else if(packageid.equals("dx.1G")){
				packagecode = "10000086";
			} */
		}else if(routeid.equals("3157")){
			//全国50M
			if(packageid.equals("dx.5M")){
				packagecode = "10000006";
			}else if(packageid.equals("dx.10M")){
				packagecode = "10000015";
			}else if(packageid.equals("dx.30M")){
				packagecode = "10000026";
			}else if(packageid.equals("dx.50M")){
				packagecode = "10000037";
			}
			/* if(packageid.equals("dx.5M")){
				packagecode = "10000397";
			}else if(packageid.equals("dx.10M")){
				packagecode = "10000398";
			}else if(packageid.equals("dx.30M")){
				packagecode = "10000026";
			}else if(packageid.equals("dx.50M")){
				packagecode = "10000400";
			} */
		}else if(routeid.equals("3087")){
			//湖北
			if(packageid.equals("dx.5M")){
				packagecode = "10000297";
			}else if(packageid.equals("dx.10M")){
				packagecode = "10000123";
			}else if(packageid.equals("dx.30M")){
				packagecode = "10000124";
			}else if(packageid.equals("dx.50M")){
				packagecode = "10000125";
			}else if(packageid.equals("dx.100M")){
				packagecode = "10000126";
			}else if(packageid.equals("dx.200M")){
				packagecode = "10000127";
			}else if(packageid.equals("dx.500M")){
				packagecode = "10000128";
			}else if(packageid.equals("dx.1G")){
				packagecode = "10000129";
			}
		}else if(routeid.equals("1072")){
			//安徽移动
			if(packageid.equals("yd.10M")){
				packagecode = "10000344";
			}else if(packageid.equals("yd.30M")){
				packagecode = "10000345";
			}else if(packageid.equals("yd.100M")){
				packagecode = "10000346";
			}else if(packageid.equals("yd.300M")){
				packagecode = "10000347";
			}else if(packageid.equals("yd.500M")){
				packagecode = "10000348";
			}else if(packageid.equals("yd.1G")){
				packagecode = "10000349";
			}else if(packageid.equals("yd.2G")){
				packagecode = "10000350";
			}else if(packageid.equals("yd.3G")){
				packagecode = "10000351";
			}else if(packageid.equals("yd.4G")){
				packagecode = "10000352";
			}else if(packageid.equals("yd.6G")){
				packagecode = "10000353";
			}else if(packageid.equals("yd.11G")){
				packagecode = "10000354";
			}
		}else if(routeid.equals("3144")){
			//福建电信
			if(packageid.equals("dx.10M")){
				packagecode = "10000140";
			}else if(packageid.equals("dx.50M")){
				packagecode = "10000142";
			}else if(packageid.equals("dx.100M")){
				packagecode = "10000143";
			}else if(packageid.equals("dx.200M")){
				packagecode = "10000144";
			}else if(packageid.equals("dx.300M")){
				packagecode = "10000248";
			}else if(packageid.equals("dx.500M")){
				packagecode = "10000145";
			}else if(packageid.equals("dx.1G")){
				packagecode = "10000146";
			}
		}else if(routeid.equals("3171")){
			//辽宁电信
			if(packageid.equals("dx.10M")){
				packagecode = "10000283";
			}else if(packageid.equals("dx.30M")){
				packagecode = "10000284";
			}else if(packageid.equals("dx.50M")){
				packagecode = "10000040";
			}else if(packageid.equals("dx.100M")){
				packagecode = "10000046";
			}else if(packageid.equals("dx.200M")){
				packagecode = "10000062";
			}else if(packageid.equals("dx.500M")){
				packagecode = "10000076";
			}else if(packageid.equals("dx.1G")){
				packagecode = "10000087";
			}
		}else if(routeid.equals("3172")){
			//内蒙电信
			if(packageid.equals("dx.10M")){
				packagecode = "10000448";
			}else if(packageid.equals("dx.5M")){
				packagecode = "10000447";
			}else if(packageid.equals("dx.30M")){
				packagecode = "10000449";
			}else if(packageid.equals("dx.50M")){
				packagecode = "10000450";
			}else if(packageid.equals("dx.100M")){
				packagecode = "10000451";
			}else if(packageid.equals("dx.200M")){
				packagecode = "10000452";
			}else if(packageid.equals("dx.500M")){
				packagecode = "10000453";
			}else if(packageid.equals("dx.1G")){
				packagecode = "10000454";
			}
		}else if(routeid.equals("3176")){
			//黑龙江电信
			if(packageid.equals("dx.5M")){
				packagecode = "10000484";
			}else if(packageid.equals("dx.10M")){
				packagecode = "10000485";
			}else if(packageid.equals("dx.30M")){
				packagecode = "10000486";
			}else if(packageid.equals("dx.50M")){
				packagecode = "10000487";
			}else if(packageid.equals("dx.100M")){
				packagecode = "10000488";
			}else if(packageid.equals("dx.200M")){
				packagecode = "10000489";
			}else if(packageid.equals("dx.300M")){
				packagecode = "10000491";
			}else if(packageid.equals("dx.500M")){
				packagecode = "10000490";
			}else if(packageid.equals("dx.1G")){
				packagecode = "10000492";
			}
		}else if(routeid.equals("3177")){
			//重庆电信
			if(packageid.equals("dx.10M")){
				packagecode = "10000319";
			}else if(packageid.equals("dx.30M")){
				packagecode = "10000377";
			}else if(packageid.equals("dx.50M")){
				packagecode = "10000378";
			}else if(packageid.equals("dx.100M")){
				packagecode = "10000379";
			}else if(packageid.equals("dx.200M")){
				packagecode = "10000380";
			}else if(packageid.equals("dx.300M")){
				packagecode = "10000481";
			}else if(packageid.equals("dx.500M")){
				packagecode = "10000381";
			}else if(packageid.equals("dx.1G")){
				packagecode = "10000382";
			}else if(packageid.equals("dx.2G")){
				packagecode = "10000482";
			}else if(packageid.equals("dx.3G")){
				packagecode = "10000483";
			}
		}else if(routeid.equals("3173")){
			//云南电信
			if(packageid.equals("dx.100M")){
				packagecode = "10000050";
			}else if(packageid.equals("dx.300M")){
				packagecode = "10000067";
			}else if(packageid.equals("dx.500M")){
				packagecode = "10000073";
			}else if(packageid.equals("dx.1G")){
				packagecode = "10000097";
			}else if(packageid.equals("dx.2G")){
				packagecode = "10000395";
			}else if(packageid.equals("dx.3G")){
				packagecode = "10000396";
			}
		}else if(routeid.equals("3182")){
			//四川电信5-100m
			if(packageid.equals("dx.5M")){
				packagecode = "10000147";
			}else if(packageid.equals("dx.10M")){
				packagecode = "10000148";
			}else if(packageid.equals("dx.30M")){
				packagecode = "10000149";
			}else if(packageid.equals("dx.50M")){
				packagecode = "10000150";
			}else if(packageid.equals("dx.100M")){
				packagecode = "10000151";
			}
		}else if(routeid.equals("2026")){
			//全国联通20-500m
			if(packageid.equals("lt.20M")){
				packagecode = "10000022";
			}else if(packageid.equals("lt.50M")){
				packagecode = "10000035";
			}else if(packageid.equals("lt.100M")){
				packagecode = "10000051";
			}else if(packageid.equals("lt.200M")){
				packagecode = "10000065";
			}else if(packageid.equals("lt.500M")){
				packagecode = "10000084";
			}
		}

		if(packagecode == null){
			request.setAttribute("result", "S." + routeid + ":unrecognized package@" + TimeUtils.getSysLogTimeString());
			break;
		}

		String code = MyStringUtils.getRandomString(21);
		String sign = MD5Util.getLowerMD5(key + userName + code);
		//HashMap<String, String> params = new LinkedHashMap<String, String>();
		JSONObject params = new JSONObject();
		params.put("accountId", accountId);
		params.put("productId", packagecode);
		params.put("phone", phone);
		params.put("downNum", taskid);
		params.put("code", code);
		params.put("sign", sign);

		//在执行请求前先获取连接, 防止访问通道线程超量
		//Cache.getConnection(routeid);
		try{
			//ret = HttpAccess.postNameValuePairRequest(url, params, "utf-8", "mysend");
			//ret = HttpAccess.postJsonRequest(url, json.toString(), "utf-8", "weikesend");
			ret = HttpAccess.postJsonRequest(url, params.toString(), "utf-8", "qiannai");

		}catch(Exception e){
			e.printStackTrace();
			logger.info(e.getMessage());
		}finally{
			//在执行请求后记得释放连接
			//Cache.releaseConnection(routeid);
		}

		//这里判断结果, 每个通道情况不同, 成功的保存 success 到 result 中并返回到 request.jsp
		if(ret != null && ret.trim().length() > 0){
			logger.info("qiannai send ret = " + ret);
			try{
				JSONObject retjson = JSONObject.fromObject(ret);
				String resultCode = retjson.getString("code"); //":"MOB00001"
				if(resultCode.equals("00000")){
					request.setAttribute("result", "success");
				}else{
					request.setAttribute("code", resultCode);
					String resultMsg = retjson.getString("sign");
					request.setAttribute("result", "R." + routeid + ":" + resultCode + ":" + resultMsg + "@" + TimeUtils.getSysLogTimeString());
				}
				request.setAttribute("orgreturn", ret);
			}catch(Exception e){
				e.printStackTrace();
				logger.info(e.getMessage());
				request.setAttribute("result", "R." + routeid + ":" + e.getMessage() + "@" + TimeUtils.getSysLogTimeString());
			}
		}else{
			request.setAttribute("result", "R." + routeid + ":fail@" + TimeUtils.getSysLogTimeString());
		}

		break;
	}

	request.getRequestDispatcher("request.jsp").forward(request, response);
%>