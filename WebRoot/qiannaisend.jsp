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
				packagecode = "10000405";
			}else if(packageid.equals("dx.30M")){
				packagecode = "10000406";
			}else if(packageid.equals("dx.50M")){
				packagecode = "10000407";
			}else if(packageid.equals("dx.100M")){
				packagecode = "10000408";
			}else if(packageid.equals("dx.200M")){
				packagecode = "10000409";
			}else if(packageid.equals("dx.500M")){
				packagecode = "10000410";
			}else if(packageid.equals("dx.1G")){
				packagecode = "10000411";
			}else if(packageid.equals("dx.2G")){
				packagecode = "10000412";
			}else if(packageid.equals("dx.5G")){
				packagecode = "10000413";
			}else if(packageid.equals("dx.10G")){
				packagecode = "10000414";
			}
		}else if(routeid.equals("3245")){
			//山西电信
			if(packageid.equals("dx.5M")){
				packagecode = "10000551";
			}else if(packageid.equals("dx.10M")){
				packagecode = "10000552";
			}else if(packageid.equals("dx.30M")){
				packagecode = "10000553";
			}else if(packageid.equals("dx.50M")){
				packagecode = "10000554";
			}else if(packageid.equals("dx.100M")){
				packagecode = "10000555";
			}else if(packageid.equals("dx.200M")){
				packagecode = "10000556";
			}else if(packageid.equals("dx.500M")){
				packagecode = "10000557";
			}else if(packageid.equals("dx.1G")){
				packagecode = "10000558";
			}
		}else if(routeid.equals("3246")){
			//全国电信
			if(packageid.equals("dx.2G")){
				packagecode = "10000800";
			}else if(packageid.equals("dx.3G")){
				packagecode = "10000801";
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
		}else if(routeid.equals("3241")){
			//全国
		 if(packageid.equals("dx.2G")){
				packagecode = "10000573";
			}else if(packageid.equals("dx.3G")){
				packagecode = "10000575";
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
		}else if(routeid.equals("3207")){
			//河南
			if(packageid.equals("dx.5M")){
				packagecode = "10000115";
			}else if(packageid.equals("dx.10M")){
				packagecode = "10000116";
			}else if(packageid.equals("dx.30M")){
				packagecode = "10000117";
			}else if(packageid.equals("dx.50M")){
				packagecode = "10000118";
			}else if(packageid.equals("dx.100M")){
				packagecode = "10000119";
			}else if(packageid.equals("dx.200M")){
				packagecode = "10000120";
			}else if(packageid.equals("dx.500M")){
				packagecode = "10000121";
			}else if(packageid.equals("dx.1G")){
				packagecode = "10000122";
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
		}else if(routeid.equals("3220")){
			//山东
			if(packageid.equals("dx.30M")){
				packagecode = "10000426";
			}else if(packageid.equals("dx.50M")){
				packagecode = "10000427";
			}else if(packageid.equals("dx.100M")){
				packagecode = "10000428";
			}else if(packageid.equals("dx.200M")){
				packagecode = "10000429";
			}else if(packageid.equals("dx.500M")){
				packagecode = "10000430";
			}else if(packageid.equals("dx.1G")){
				packagecode = "10000431";
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
		}else if(routeid.equals("1220")){
			//全国移动
			if(packageid.equals("yd.10M")){
				packagecode = "10000020";
			}else if(packageid.equals("yd.30M")){
				packagecode = "10000033";
			}else if(packageid.equals("yd.70M")){
				packagecode = "10000056";
			}else if(packageid.equals("yd.100M")){
				packagecode = "10000702";
			}else if(packageid.equals("yd.150M")){
				packagecode = "10000069";
			}else if(packageid.equals("yd.300M")){
				packagecode = "10000703";
			}else if(packageid.equals("yd.500M")){
				packagecode = "10000083";
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
		}else if(routeid.equals("3235")){
			//安徽电信
			if(packageid.equals("dx.5M")){
				packagecode = "10000007";
			}else if(packageid.equals("dx.10M")){
				packagecode = "10000013";
			}else if(packageid.equals("dx.30M")){
				packagecode = "10000025";
			}else if(packageid.equals("dx.50M")){
				packagecode = "10000041";
			}else if(packageid.equals("dx.100M")){
				packagecode = "10000052";
			}else if(packageid.equals("dx.200M")){
				packagecode = "10000058";
			}else if(packageid.equals("dx.500M")){
				packagecode = "10000080";
			}else if(packageid.equals("dx.1G")){
				packagecode = "10000090";
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
		}else if(routeid.equals("3209")){
			//吉林
			if(packageid.equals("dx.10M")){
				packagecode = "10000252";
			}else if(packageid.equals("dx.30M")){
				packagecode = "10000028";
			}else if(packageid.equals("dx.50M")){
				packagecode = "10000042";
			}else if(packageid.equals("dx.100M")){
				packagecode = "10000048";
			}else if(packageid.equals("dx.200M")){
				packagecode = "10000063";
			}else if(packageid.equals("dx.300M")){
				packagecode = "10000068";
			}else if(packageid.equals("dx.500M")){
				packagecode = "10000078";
			}else if(packageid.equals("dx.1G")){
				packagecode = "10000085";
			}
		}else if(routeid.equals("3278")){
			//广西
			if(packageid.equals("dx.5M")){
				packagecode = "10000383";
			}else if(packageid.equals("dx.10M")){
				packagecode = "10000155";
			}else if(packageid.equals("dx.30M")){
				packagecode = "10000156";
			}else if(packageid.equals("dx.50M")){
				packagecode = "10000384";
			}else if(packageid.equals("dx.100M")){
				packagecode = "10000157";
			}else if(packageid.equals("dx.200M")){
				packagecode = "10000158";
			}else if(packageid.equals("dx.500M")){
				packagecode = "10000385";
			}else if(packageid.equals("dx.1G")){
				packagecode = "10000386";
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
		}else if(routeid.equals("3211")){
			//广东电信1G日包
			if(packageid.equals("dx.1G")){
				packagecode = "10000566";
			}
		}else if(routeid.equals("3212")){
			//河北电信1G日包
			if(packageid.equals("dx.1G")){
				packagecode = "10000567";
			}
		}else if(routeid.equals("3213")){
			//江西电信1G日包
			if(packageid.equals("dx.1G")){
				packagecode = "10000568";
			}
		}else if(routeid.equals("3215")){
			//广东电信1G3日包
			if(packageid.equals("dx.1G")){
				packagecode = "10000569";
			}
		}else if(routeid.equals("3214")){
			//江西电信1G3日包
			if(packageid.equals("dx.1G")){
				packagecode = "10000570";
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