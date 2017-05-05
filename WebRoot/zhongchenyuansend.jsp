<%@page import="org.apache.commons.codec.digest.DigestUtils"%>
<%@page
	import="util.AES,
				util.MD5Util,
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
			request.setAttribute("result", "S." + routeid + ":wrong routeparams@" + TimeUtils.getSysLogTimeString());
			break;
		}

		String url = routeparams.get("url");
		if (url == null) {
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, url is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String userName = routeparams.get("userName");
		if (userName == null) {
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, userName is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String userPwd = routeparams.get("userPwd");
		if (userPwd == null) {
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, userPwd is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String interfaceSign = routeparams.get("interfaceSign");
		if (interfaceSign == null) {
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, interfaceSign is null@" + TimeUtils.getSysLogTimeString());
			break;
		}

		//参数准备, 每个通道不同
		String packagecode = null;
		String flowType = null;
		String packagetype = null;
		if (packageid.indexOf("yd.") > -1) {
			packagetype = "CMCC_";
		} else if (packageid.indexOf("lt.") > -1) {
			packagetype = "CUCC_";
		} else if (packageid.indexOf("dx.") > -1) {
			packagetype = "CTCC_";
		}
		try {
			packageid = packageid.split("\\.")[1];
			String pkstr = packageid.substring(0, packageid.length() - 1);
			int pk = Integer.parseInt(pkstr);
			if (packageid.indexOf('G') >= 0) {
				pk *= 1024;
			}
			packagecode = packagetype + String.valueOf(pk) + "M";
		} catch (Exception e) {
			logger.warn(e.getMessage(), 0);
		}
		if (routeid.equals("1274")||routeid.equals("1375")||routeid.equals("3293")||routeid.equals("1374")||routeid.equals("1373")||routeid.equals("1372")||routeid.equals("1371")||routeid.equals("2087")||routeid.equals("3273")) {
			flowType = "AF";//全国
		} else if (routeid.equals("2705")){
			flowType = "RF";//省内
		} else {
			flowType = "SF";
		}
		if (packagecode == null || flowType == null) {
			request.setAttribute("result", "S." + routeid + ":unrecognized package@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String bcallbackUrl = "http://120.24.156.98:9302/ll_sendbuf/zhongchenyuanreturn.jsp";
		String userpwd = DigestUtils.md5Hex(userPwd);
		String signbef = "userName=" + userName + "&userPwd=" + userpwd + interfaceSign + "&mobile=" + phone + "&proKey=" + packagecode + "&orderNo=" + taskid + "&bcallbackUrl=" + bcallbackUrl;
		String Sign = DigestUtils.md5Hex(signbef);
		logger.info("zhongchenyuan sign bef="+signbef+"@flowType="+flowType);
		logger.info("zhongchenyuan sign ="+Sign);
		Map<String, String> parm = new HashMap<String, String>();
		parm.put("orderNo", taskid);
		parm.put("userName", userName);
		parm.put("mobile", phone);
		parm.put("userPwd", userpwd);
		parm.put("proKey", packagecode);
		parm.put("bcallbackUrl", bcallbackUrl);
		parm.put("sign", Sign);
		parm.put("f", "recharge");
		parm.put("flowType", flowType);

		//在执行请求前先获取连接, 防止访问通道线程超量
		Cache.getConnection(routeid);
		try {
			ret = HttpAccess.postNameValuePairRequest(url, parm, "utf-8", "zhongchenyuan");
		} catch (Exception e) {
			e.printStackTrace();
			logger.info(e.getMessage());
		} finally {
			//在执行请求后记得释放连接
			Cache.releaseConnection(routeid);
		}

		//这里判断结果, 每个通道情况不同, 成功的保存 success 到 result 中并返回到 request.jsp
		if (ret != null && ret.trim().length() > 0) {
			try {
				JSONObject retjson = JSONObject.fromObject(ret);
				String code = retjson.getString("code");
				if (code != null && code.equals("100")) {
					request.setAttribute("result", "success");
				} else {
					request.setAttribute("code", 1);
					String msg = code;
					Map<String, String> maps = new HashMap<String, String>();
					maps.put("100", "执行成功");
					maps.put("102", "参数格式不正确");
					maps.put("103", "流量产品不可用");
					maps.put("105", "执行失败");
					maps.put("107", "账户余额不足");
					maps.put("108", "手机号码不支持充值");
					maps.put("120", "公司资金已冻结");
					maps.put("121", "充值通道已关闭");
					maps.put("122", "运营商系统维护，请稍后再试");
					maps.put("205", "用户名或者密码不正确");
					maps.put("203", "没有接入权限或 sign验证失败");
					if (maps.get(code) != null) {
						msg = maps.get(code);
					}
					request.setAttribute("result", "R." + routeid + ":" + msg + "@" + TimeUtils.getSysLogTimeString());
				}
				request.setAttribute("orgreturn", ret);
			} catch (Exception e) {
				e.printStackTrace();
				logger.info(e.getMessage());
				request.setAttribute("result", "R." + routeid + ":" + e.getMessage() + "@" + TimeUtils.getSysLogTimeString());
			}
		} else {
			request.setAttribute("result", "R." + routeid + ":fail@" + TimeUtils.getSysLogTimeString());
		}

		break;
	}

	request.getRequestDispatcher("request.jsp").forward(request, response);
%>