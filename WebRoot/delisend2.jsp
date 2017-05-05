<%@page
	import="util.MD5Util,
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

	while(true){
		String ret = null;
		String sign = null;

		//检查通道参数, 每个通道有不同参数, 对应 ll_routes.api_params
		Map<String, String> routeparams = Cache.getRouteParams(routeid);
		if(routeparams == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams@" + TimeUtils.getSysLogTimeString());
			break;
		}

		String mt_url = routeparams.get("mt_url");
		if(mt_url == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, mt_url is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String account = routeparams.get("account");
		if(account == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, account is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String password = routeparams.get("password");
		if(password == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, password is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String key = routeparams.get("key");
		if(key == null){
			request.setAttribute("result", "S." + routeid + ":wrong key, key is null@" + TimeUtils.getSysLogTimeString());
			break;
		}

		//参数准备, 每个通道不同
		String packagecode = null;
		String operators = null;
		String provinces=null;
		try{
		 if(account.equals("danyuanqg")||account.equals("danyuanqgNO")){//全国
			provinces="10";
		}else if(routeid.equals("3152")){//河北
			provinces="13";
		}else if(routeid.equals("3130")){//浙江
			provinces="33";
		}else if(routeid.equals("3129")||routeid.equals("2043")||routeid.equals("2042")||routeid.equals("2041")){//福建
			provinces="35";
		}else if(routeid.equals("3128")||routeid.equals("2030")){//江苏
			provinces="32";
		}else if(routeid.equals("3127")){//安徽
			provinces="34";
		}else if(routeid.equals("3126")){//云南
			provinces="53";
		}else if(routeid.equals("3125")||routeid.equals("1124")){//山东
			provinces="37";
		}else if(routeid.equals("3124")){//吉林
			provinces="22";
		}else if(routeid.equals("3123")){//重庆
			provinces="50";
		}else if(routeid.equals("3113")||routeid.equals("1079")){//湖南
			provinces="43";
		}else if(routeid.equals("3106")){//上海
			provinces="31";
		}else if(routeid.equals("1087")){//陕西
			provinces="61";
		}else if(routeid.equals("1073")){//广东
			provinces="44";
		}else if(routeid.equals("1123")){//青海
			provinces="63";
		}else if(routeid.equals("1122")){//内蒙古
			provinces="15";
		}else if(routeid.equals("3179")){//辽宁
			provinces="21";
		} 
		if(packageid.indexOf("dx.")>=0){
			operators="D";
		}else if(packageid.indexOf("yd.")>=0){
			operators="Y";
		}else if(packageid.indexOf("lt.")>=0){
			operators="L";
		}
		if(operators!=null&&provinces!=null){
			packageid = packageid.split("\\.")[1];
			String pkstr = packageid.substring(0, packageid.length() - 1);
			int pk = Integer.parseInt(pkstr);
			if(packageid.indexOf('G') >= 0){
				pk *= 1024;
			}
			packagecode =operators+provinces+"Y"+ String.valueOf(pk);
		}
		}catch(Exception e){
			logger.warn(e.getMessage(), 0);
		}

		if(packagecode == null){
			request.setAttribute("result", "S." + routeid + ":unrecognized package@" + TimeUtils.getSysLogTimeString());
			break;
		}
		
	    sign = MD5Util.getUpperMD5( MD5Util.getLowerMD5(password) + phone + packagecode + taskid + key);
		Map<String, String> parms = new LinkedHashMap<String, String>();
		parms.put("account", account);
		parms.put("sign", sign);
		parms.put("account", account);
		parms.put("flowCode", packagecode);
		parms.put("mobile", phone);
		parms.put("orderNumber", taskid);
		logger.info("deli2 send parms= "+ parms.toString());
		//在执行请求前先获取连接, 防止访问通道线程超量
		Cache.getConnection(routeid);
		try{
			//ret = HttpAccess.postNameValuePairRequest(url, params, "utf-8", "mysend");
			//ret = HttpAccess.postJsonRequest(url, json.toString(), "utf-8", "weikesend");
		 ret = HttpAccess.postNameValuePairRequest(mt_url,parms, "utf-8", "deli2");
		}catch(Exception e){
			e.printStackTrace();
			logger.info(e.getMessage());
		}finally{
			//在执行请求后记得释放连接
			Cache.releaseConnection(routeid);
		}

		//这里判断结果, 每个通道情况不同, 成功的保存 success 到 result 中并返回到 request.jsp
		if(ret != null && ret.trim().length() > 0){
			logger.info("deli2 send ret = " + ret);
			try{
				JSONObject retjson = JSONObject.fromObject(ret);
				String resultCode = retjson.getString("code"); //":"2000"
				if(resultCode.equals("2000") ){
					request.setAttribute("result", "success");
					request.setAttribute("reportid", taskid);
				}else{
					request.setAttribute("code", resultCode);
					HashMap<String , String> wrparms = new HashMap<String,String>();
					wrparms.put("2000","充值成功");
					wrparms.put("5000","系统错误");
					wrparms.put("5001","用户名不能为空");
					wrparms.put("5002","订单号不能为空");
					wrparms.put("5003","签名不能为空");
					wrparms.put("5004","产品编号不能为空");
					wrparms.put("5005","手机号码为空或者格式错误");
					wrparms.put("5006","请传入平台订单号或用户订单号");
					wrparms.put("5101","用户名不存在");
					wrparms.put("5102","用户已被禁用");
					wrparms.put("5103","签名错误");
					wrparms.put("5104","手机号码无效");
					wrparms.put("5105","该手机号码被列入黑名单");
					wrparms.put("5106","产品编码不存在");
					wrparms.put("5107","产品编码的省份与手机所属省份不对应");
					wrparms.put("5108","产品编码的运营商与手机所属运营商不对应");
					wrparms.put("5109","IP地址未授权");
					wrparms.put("5110","订单号已存在，请提供新订单号");
					wrparms.put("5201","没有合适的流量产品");
					wrparms.put("5202","用户余额不足");
					wrparms.put("5301","订单生成失败");
					wrparms.put("5302","扣除用户余额失败");
					wrparms.put("5303","订单设置失败");
					wrparms.put("5304","未配置供应商接口参数");
					wrparms.put("5305","供应商接口，充值失败");
					wrparms.put("6001","订单不存在");
					String resultMsg = retjson.getString("msg");
					if(wrparms.get(resultCode)!=null){
					 resultMsg = wrparms.get(resultCode);
					}
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