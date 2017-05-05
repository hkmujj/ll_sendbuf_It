<%@page import="java.text.SimpleDateFormat"%>
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

		String appkey = routeparams.get("appkey");
		if (appkey == null) {
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, appkey is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String appSecret = routeparams.get("appSecret");
		if (appSecret == null) {
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, appSecret is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String url = routeparams.get("url");
		if (url == null) {
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, url is null@" + TimeUtils.getSysLogTimeString());
			break;
		}

		//参数准备, 每个通道不同
		String packagecode = null;
		String packagetype = null;

		if (packageid.indexOf("lt.") > -1) {
			try {
				String[] dts = packageid.split("\\.");
				packagetype = dts[0].toUpperCase();
				packageid = dts[1];
				String pkstr = packageid.substring(0, packageid.length() - 1);
				int pk = Integer.parseInt(pkstr);
				if (packageid.indexOf('G') >= 0) {
					pk *= 1000;
				}
				packageid = "000" + String.valueOf(pk);
				packageid = packageid.substring(packageid.length() - 4);
			} catch (Exception e) {
				logger.warn(e.getMessage(), 0);
			}
			if (routeid.equals("2186")) {
				//福建联通
				packagetype = "818";
				if (!packageid.equals("0500")) {
					packagetype = null;
				}
			} else if (routeid.equals("2185")) {
				//福建联通
				packagetype = "818";
				if (!packageid.equals("0300")) {
					packagetype = null;
				}
			} else if (routeid.equals("2184")) {
				//福建联通
				packagetype = "818";
				if (!packageid.equals("0200")) {
					packagetype = null;
				}
			} else if (routeid.equals("2183")) {
				//福建联通
				packagetype = "818";
				if (!packageid.equals("0100")) {
					packagetype = null;
				}
			} else if (routeid.equals("2182")) {
				//福建联通
				packagetype = "818";
				if (!packageid.equals("0050")) {
					packagetype = null;
				}
			} else if (routeid.equals("2181")) {
				//福建联通
				packagetype = "818";
				if (!packageid.equals("0030")) {
					packagetype = null;
				}
			} else if (routeid.equals("2180")) {
				//福建联通
				packagetype = "818";
				if (!packageid.equals("0020")) {
					packagetype = null;
				}
			} else if (routeid.equals("2191")) {
				//辽宁联通
				packagetype = "819";
				if (!packageid.equals("0500")) {
					packagetype = null;
				}
			} else if (routeid.equals("2190")) {
				//辽宁联通
				packagetype = "819";
				if (!packageid.equals("0300")) {
					packagetype = null;
				}
			} else if (routeid.equals("2189")) {
				//辽宁联通
				packagetype = "819";
				if (!packageid.equals("0200")) {
					packagetype = null;
				}
			} else if (routeid.equals("2188")) {
				//辽宁联通
				packagetype = "819";
				if (!packageid.equals("0100")) {
					packagetype = null;
				}
			} else if (routeid.equals("2187")) {
				//辽宁联通
				packagetype = "819";
				if (!packageid.equals("0050")) {
					packagetype = null;
				}
			} else if (routeid.equals("2198")) {
				//黑龙江联通
				packagetype = "821";
				if (!packageid.equals("0500")) {
					packagetype = null;
				}
			} else if (routeid.equals("2197")) {
				//黑龙江联通
				packagetype = "821";
				if (!packageid.equals("0300")) {
					packagetype = null;
				}
			} else if (routeid.equals("2196")) {
				//黑龙江联通
				packagetype = "821";
				if (!packageid.equals("0200")) {
					packagetype = null;
				}
			} else if (routeid.equals("2195")) {
				//黑龙江联通
				packagetype = "821";
				if (!packageid.equals("0100")) {
					packagetype = null;
				}
			} else if (routeid.equals("2194")) {
				//黑龙江联通
				packagetype = "821";
				if (!packageid.equals("0050")) {
					packagetype = null;
				}
			} else if (routeid.equals("2193")) {
				//黑龙江联通
				packagetype = "821";
				if (!packageid.equals("0030")) {
					packagetype = null;
				}
			} else if (routeid.equals("2192")) {
				//黑龙江联通
				packagetype = "821";
				if (!packageid.equals("0020")) {
					packagetype = null;
				}
			} else if (routeid.equals("2205")) {
				//河北联通
				packagetype = "807";
				if (!packageid.equals("1000")) {
					packagetype = null;
				}
			} else if (routeid.equals("2204")) {
				//河北联通
				packagetype = "807";
				if (!packageid.equals("0500")) {
					packagetype = null;
				}
			} else if (routeid.equals("2203")) {
				//河北联通
				packagetype = "807";
				if (!packageid.equals("0300")) {
					packagetype = null;
				}
			} else if (routeid.equals("2202")) {
				//河北联通
				packagetype = "807";
				if (!packageid.equals("0200")) {
					packagetype = null;
				}
			} else if (routeid.equals("2201")) {
				//河北联通
				packagetype = "807";
				if (!packageid.equals("0100")) {
					packagetype = null;
				}
			} else if (routeid.equals("2200")) {
				//河北联通
				packagetype = "807";
				if (!packageid.equals("0050")) {
					packagetype = null;
				}
			} else if (routeid.equals("2199")) {
				//河北联通
				packagetype = "807";
				if (!packageid.equals("0030")) {
					packagetype = null;
				}
			} else if (routeid.equals("2213")) {
				//江西联通
				packagetype = "816";
				if (!packageid.equals("1000")) {
					packagetype = null;
				}

			} else if (routeid.equals("2212")) {
				//江西联通
				packagetype = "816";
				if (!packageid.equals("0500")) {
					packagetype = null;
				}
			} else if (routeid.equals("2211")) {
				//江西联通
				packagetype = "816";
				if (!packageid.equals("0300")) {
					packagetype = null;
				}
			} else if (routeid.equals("2210")) {
				//江西联通
				packagetype = "816";
				if (!packageid.equals("0200")) {
					packagetype = null;
				}
			} else if (routeid.equals("2209")) {
				//江西联通
				packagetype = "816";
				if (!packageid.equals("0100")) {
					packagetype = null;
				}
			} else if (routeid.equals("2208")) {
				//江西联通
				packagetype = "816";
				if (!packageid.equals("0050")) {
					packagetype = null;
				}
			} else if (routeid.equals("2207")) {
				//江西联通
				packagetype = "816";
				if (!packageid.equals("0030")) {
					packagetype = null;
				}
			} else if (routeid.equals("2206")) {
				//江西联通
				packagetype = "816";
				if (!packageid.equals("0020")) {
					packagetype = null;
				}
			} else if (routeid.equals("2214")) {
				//江苏联通
				packagetype = "814";
			} else if (routeid.equals("2215")) {
				//江苏联通
				packagetype = "814";
				if (!packageid.equals("1000")) {
					packagetype = null;
				}
			} else if (routeid.equals("2216")) {
				//山东联通
				packagetype = "809";
			} else if (routeid.equals("2217")) {
				//河南联通
				packagetype = "808";
			} else if (routeid.equals("2218")) {
				//安徽联通
				packagetype = "815";
			} else if (routeid.equals("2219")) {
				//重庆联通
				packagetype = "804";
			} else if (routeid.equals("2220")) {
				//海南联通
				packagetype = "824";
			} else if (routeid.equals("2221")) {
				//成都联通
				packagetype = "832";
			} else if (routeid.equals("2295")) {
				//陕西联通
				packagetype = "811";
			} /* else if (routeid.equals("")) {
				//云南联通
				packagetype = "823";
				}  */
			packagecode = packagetype + packageid;
		}
		logger.info("xinyun routid=" + routeid + "&packagecod=" + packagecode);
		if (packagecode == null || packagetype == null) {
			request.setAttribute("result", "S." + routeid + ":unrecognized package@" + TimeUtils.getSysLogTimeString());
			break;
		}

		SimpleDateFormat df = new SimpleDateFormat("yyyy-MM-dd hh:mm:ss");
		String time = df.format(new Date());
		String signbef = appkey + phone + packagecode + time + taskid + appSecret;
		logger.info("xinyun signbef" + signbef);
		String sign = MD5Util.getLowerMD5(signbef);
		Map<String, String> parm = new HashMap<String, String>();
		parm.put("appkey", appkey);
		parm.put("phone", phone);
		parm.put("productid", packagecode);
		parm.put("time", time);
		parm.put("tradeno", taskid);
		parm.put("sign", sign);
		url = url + "order";
		//在执行请求前先获取连接, 防止访问通道线程超量
		Cache.getConnection(routeid);
		try {
			ret = HttpAccess.postNameValuePairRequest(url, parm, "utf-8", "xinyun");
		} catch (Exception e) {
			e.printStackTrace();
			logger.info(e.getMessage());
		} finally {
			//在执行请求后记得释放连接
			Cache.releaseConnection(routeid);
		}

		//这里判断结果, 每个通道情况不同, 成功的保存 success 到 result 中并返回到 request.jsp
		if (ret != null && ret.trim().length() > 0) {
			logger.info("yimei send ret = " + ret);
			try {
				JSONObject retjson = JSONObject.fromObject(ret);
				String code = retjson.getString("status");
				if (code.equals("1")) {
					request.setAttribute("result", "success");
				} else {
					request.setAttribute("code", 1);
					request.setAttribute("result", "R." + routeid + ":" + code + retjson.getString("message") + "@" + TimeUtils.getSysLogTimeString());
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