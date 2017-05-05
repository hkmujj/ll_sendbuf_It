<%@page import="org.dom4j.DocumentHelper"%>
<%@page import="org.dom4j.Element"%>
<%@page import="org.dom4j.Document"%>
<%@page import="java.util.Map.Entry"%>
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

		String mt_url = routeparams.get("mt_url");
		if(mt_url == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, mt_url is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String userid = routeparams.get("userid");
		if(userid == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, userid is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String key = routeparams.get("key");
		if(key == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, key is null@" + TimeUtils.getSysLogTimeString());
			break;
		}


		//参数准备, 每个通道不同
		String packagecode = null;
		String price = null;

		if(routeid.equals("3165")||routeid.equals("3165")){
			//四川
			if(packageid.equals("dx.5M")){
				packagecode = "30000000226";
				price = "1";
			}else if(packageid.equals("dx.10M")){
				packagecode = "30000000232";
				price = "2";
			}else if(packageid.equals("dx.30M")){
				packagecode = "30000000230";
				price = "5";
			}else if(packageid.equals("dx.50M")){
				packagecode = "30000000227";
				price = "7";
			}else if(packageid.equals("dx.100M")){
				packagecode = "30000000225";
				price = "10";
			}else if(packageid.equals("dx.200M")){
				packagecode = "30000000231";
				price = "15";
			}else if(packageid.equals("dx.500M")){
				packagecode = "30000000229";
				price = "30";
			}
		}else if(routeid.equals("3166")){
			//全国
			if(packageid.equals("dx.5M")){
				packagecode = "10000000398";
				price = "1";
			}else if(packageid.equals("dx.10M")){
				packagecode = "10000000078";
				price = "2";
			}else if(packageid.equals("dx.30M")){
				packagecode = "10000000077";
				price = "5";
			}else if(packageid.equals("dx.50M")){
				packagecode = "10000000399";
				price = "7";
			}else if(packageid.equals("dx.100M")){
				packagecode = "10000000076";
				price = "10";
			}else if(packageid.equals("dx.200M")){
				packagecode = "10000000075";
				price = "15";
			}else if(packageid.equals("dx.300M")){
				packagecode = "10000000501";
				price = "20";
			}else if(packageid.equals("dx.500M")){
				packagecode = "10000000597";
				price = "30";
			}else if(packageid.equals("dx.1G")){
				packagecode = "10000000400";
				price = "50";
			}else if(packageid.equals("dx.2G")){
				packagecode = "10000000502";
				price = "70";
			}
		}else if(routeid.equals("3238")){
			//福建电信
			if(packageid.equals("dx.10M")){
				packagecode = "30000000240";
				price = "2";
			}else if(packageid.equals("dx.50M")){
				packagecode = "30000000235";
				price = "7";
			}else if(packageid.equals("dx.100M")){
				packagecode = "30000000233";
				price = "10";
			}else if(packageid.equals("dx.200M")){
				packagecode = "30000000239";
				price = "15";
			}else if(packageid.equals("dx.300M")){
				packagecode = "10000000647";
				price = "20";
			}else if(packageid.equals("dx.500M")){
				packagecode = "30000000237";
				price = "30";
			}
		}else if(routeid.equals("3240")){
			//福建电信
			if(packageid.equals("dx.1G")){
				packagecode = "10000000754";
				price = "50";
			}
		}else if(routeid.equals("3233")){
			//四川
			if(packageid.equals("dx.5M")){
				packagecode = "10000000850";
				price = "1";
			}else if(packageid.equals("dx.10M")){
				packagecode = "10000000851";
				price = "2";
			}else if(packageid.equals("dx.30M")){
				packagecode = "10000000852";
				price = "5";
			}else if(packageid.equals("dx.50M")){
				packagecode = "10000000853";
				price = "7";
			}else if(packageid.equals("dx.100M")){
				packagecode = "10000000854";
				price = "10";
			}else if(packageid.equals("dx.200M")){
				packagecode = "10000000855";
				price = "15";
			}else if(packageid.equals("dx.300M")){
				packagecode = "10000000861";
				price = "20";
			}else if(packageid.equals("dx.500M")){
				packagecode = "10000000856";
				price = "30";
			}
		}else if(routeid.equals("3221")){
			//广东
			if(packageid.equals("dx.5M")){
				packagecode = "30000000178";
				price = "1";
			}else if(packageid.equals("dx.10M")){
				packagecode = "30000000184";
				price = "2";
			}else if(packageid.equals("dx.30M")){
				packagecode = "30000000182";
				price = "5";
			}else if(packageid.equals("dx.50M")){
				packagecode = "30000000179";
				price = "7";
			}else if(packageid.equals("dx.100M")){
				packagecode = "30000000177";
				price = "10";
			}else if(packageid.equals("dx.200M")){
				packagecode = "30000000183";
				price = "15";
			}else if(packageid.equals("dx.500M")){
				packagecode = "30000000181";
				price = "30";
			}else if(packageid.equals("dx.1G")){
				packagecode = "30000000180";
				price = "50";
			}
		}else if(routeid.equals("1166")){
			//安徽移动
			if(packageid.equals("yd.30M")){
				packagecode = "40000000084";
				price = "5";
			}else if(packageid.equals("yd.100M")){
				packagecode = "10000000595";
				price = "10";
			}else if(packageid.equals("yd.300M")){
				packagecode = "10000000596";
				price = "20";
			}else if(packageid.equals("yd.500M")){
				packagecode = "40000000071";
				price = "30";
			}else if(packageid.equals("yd.1G")){
				packagecode = "40000000074";
				price = "50";
			}else if(packageid.equals("yd.2G")){
				packagecode = "40000000075";
				price = "70";
			}else if(packageid.equals("yd.3G")){
				packagecode = "40000000076";
				price = "100";
			}else if(packageid.equals("yd.4G")){
				packagecode = "40000000077";
				price = "130";
			}else if(packageid.equals("yd.6G")){
				packagecode = "40000000078";
				price = "180";
			}else if(packageid.equals("yd.11G")){
				packagecode = "40000000079";
				price = "280";
			}
		}else if(routeid.equals("1217")||routeid.equals("1317")){
			//福建移动
			if(packageid.equals("yd.30M")){
				packagecode = "40000000406";
				price = "5";
			}else if(packageid.equals("yd.10M")){
				packagecode = "40000000403";
				price = "3";
			}else if(packageid.equals("yd.70M")){
				packagecode = "40000000394";
				price = "10";
			}else if(packageid.equals("yd.150M")){
				packagecode = "40000000395";
				price = "20";
			}else if(packageid.equals("yd.500M")){
				packagecode = "40000000393";
				price = "30";
			}else if(packageid.equals("yd.1G")){
				packagecode = "40000000396";
				price = "50";
			}else if(packageid.equals("yd.2G")){
				packagecode = "40000000397";
				price = "70";
			}else if(packageid.equals("yd.3G")){
				packagecode = "40000000398";
				price = "100";
			}else if(packageid.equals("yd.4G")){
				packagecode = "40000000399";
				price = "130";
			}else if(packageid.equals("yd.6G")){
				packagecode = "40000000400";
				price = "180";
			}else if(packageid.equals("yd.11G")){
				packagecode = "40000000401";
				price = "280";
			}
		}

		if(packagecode == null){
			request.setAttribute("result", "S." + routeid + ":unrecognized package@" + TimeUtils.getSysLogTimeString());
			break;
		}

		HashMap<String, String> param = new LinkedHashMap<String, String>();
		param.put("userid", userid);
		param.put("productid", packagecode);
		param.put("price", price);
		param.put("num", "1");
		param.put("mobile", phone);
		param.put("spordertime", TimeUtils.getTimeString());
		param.put("sporderid", taskid);
		String str = "";
		Iterator iter = param.entrySet().iterator();
		while(iter.hasNext()){
			Entry entry = (Entry) iter.next();
			str = str + entry.getKey() + "=" + entry.getValue() + "&";
		}

		//		param.put("key", key);
		String sign = MD5Util.getLowerMD5(str + "key=" + key);
		param.put("sign", sign);
		logger.info("zonghe request = " + param.toString());

		//在执行请求前先获取连接, 防止访问通道线程超量
		Cache.getConnection(routeid);
		try{
			//ret = HttpAccess.postNameValuePairRequest(url, params, "utf-8", "mysend");
			//ret = HttpAccess.postJsonRequest(url, json.toString(), "utf-8", "weikesend");
			ret = HttpAccess.postNameValuePairRequest(mt_url, param, "utf-8", "zonghe");

		}catch(Exception e){
			e.printStackTrace();
			logger.info(e.getMessage());
		}finally{
			//在执行请求后记得释放连接
			Cache.releaseConnection(routeid);
		}

		//这里判断结果, 每个通道情况不同, 成功的保存 success 到 result 中并返回到 request.jsp
		if(ret != null && ret.trim().length() > 0){
			logger.info("zonghe send ret = " + ret);
			try{
				Document document = DocumentHelper.parseText(ret);
				Element root = document.getRootElement();
				String resultno = root.element("resultno").getText();
				//":"MOB00001"
				if(resultno.equals("0") || resultno.equals("1")){
					request.setAttribute("result", "success");
				}else{
					HashMap<String, String> map = new HashMap();
					map.put("2", "充值中");
					map.put("5001", "代理商不存在");
					map.put("5002", "代理商余额不足");
					map.put("5003", "此商品暂时不可购买");
					map.put("5004", "充值号码与所选商品不符");
					map.put("5005", "充值请求验证错误");
					map.put("5006", "代理商订单号重复");
					map.put("5007", "所查询的订单不存在");
					map.put("5008", "交易亏损不能充值");
					map.put("5009", "Ip不符");
					map.put("5010", "商品编号与充值金额不符");
					map.put("5011", "商品数量不支持");
					map.put("5012", "缺少必要参数或参数值不合法");
					map.put("9999", "未知错误,需进入平台查询核实");
					request.setAttribute("code", resultno);
					String resultMsg = map.get(resultno);
					request.setAttribute("result", "R." + routeid + ":" + resultno + ":" + resultMsg + "@" + TimeUtils.getSysLogTimeString());
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