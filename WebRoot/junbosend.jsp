

<%@page import="http.HttpAccess"%>
<%@page import="java.util.HashMap"%>
<%@page import="java.io.UnsupportedEncodingException"%>
<%@page import="java.io.IOException"%>
<%@page import="java.io.InputStreamReader"%>
<%@page import="java.net.URLConnection"%>
<%@page import="java.net.URL"%>
<%@page import="java.io.PrintWriter"%>
<%@page import="java.io.BufferedReader"%>
<%@page import="java.util.Date"%>
<%@page import="util.Utility"%>
<%@page import="net.sf.json.JSONObject"%>
<%@page import="util.TimeUtils"%>
<%@page import="java.util.Map"%>
<%@page import="cache.Cache"%>
<%@page import="java.net.URLDecoder,
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
		String privateKey = "MIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQDXLRqRB44aSSfr"
				+ "4JkrYxM7ufLiEfK/Mz38bqHKieqfoT63MGqtAzyl/CaCXFl+aU0ptmBgHiUsX9kZ"
				+ "ks4FmjNoutRu6solR+Ax5cuZBACqWafUHM5lyIkzmDIvwxYArn5ybHF7Qk19RVJ4"
				+ "kLkmQq7ECs9ZVDb4mleTi05ivbldVLDVmcJWexxWot9ffd16E1eyntvnxvAOo77z"
				+ "FVC/7JLZmpfi7jWKziVJX3Sy/0CTMShKYaRe+C5DqWIETmPeQGNd5D/Q/wA5SSXG"
				+ "/v6KvXy7MJ5dN9PgHiB1sRPWZjyNVlvcbMacmTqaQ7gKUmLJGG2KUAg21cfwQr1K"
				+ "8U8fiTzfAgMBAAECggEBAMD8COmuFvroRc+9/mH1V9ina3jqlAZ71MpEBwN6Ml28"
				+ "5lyyJdrKHmjX/0nHvdQsaTJSCZnrL3fe9v2Ctxg7NoRlnAVmuqo5DpByAupXtqkS"
				+ "A/2vYEXVV4hYphpEI8W0ul+xdw4PZyRFOjQ7yHLSN6BH+bOqXisVcho4RLM2abuT"
				+ "hjt+9BL+uD8aKHfVsmpo9DiIxYj6goFXcfdKHrhpnzeaSEx3ekFeYEnE5gS4WV02"
				+ "2RldLwA8EecyAZqCZRv9VhF9mMyfsfjVlTmUR5PzSXHRGkSkHI9rthNrb+HOJdw2"
				+ "QKnvaflRTppoEg4lO5m9/jBtfEG0s8+lpbRvq/99ATECgYEA9BCVAOUNakyct9MG"
				+ "aV0lV40J1IhDloPbdKip2P8YtLsv2Cjhz7oKJ+zJ5f0W4+vbNSukiZ28McA81SNb"
				+ "WKTSMmex2KNk+9+UO8MfLs2tV8vMXeQ0ROd0Aig/HK3GlboJfNMRDApbvRXgL8oQ"
				+ "7kYXBU5mbrkfRnUvI6jsE8NAIK0CgYEA4bLecpo1b6NQXPjCAfnGoBHN748bvxe0"
				+ "ee0ycn1YEECkx8N0/j/yXf98wkejA+2NVwXMcUo0wYBVBOSgFZsaH6ZdSOYMqA7L"
				+ "1y1tOa+wNPDPH6JjZcWFx4MxTMngc8vaI2ORAQvzJzZdHn4xMXp0DK6rUtDM7eka"
				+ "s8PG+6deKTsCgYEAiUm+l1dBGZdo3JqO07v6omoKqovQAR3A17l8eTzdp+RXwG8W"
				+ "vqO2zMiMtZuNQb5Ne3ZGQscAsrehQH94BcAJISNlTihzSJ92obtbkhdON8HC/tm8"
				+ "cToE7qW3AqnZuCWC6r1LrIszGYTxq9Atf+rbTjfQtN3bcuW+E4AU8/Tz4K0CgYB1"
				+ "sI3qeJswsZpwQI759MMsKNyX9KnlRXkosxVBOjc3kl3ahQN2qOW7OkRWEoDgxXiU"
				+ "TkPDN4y28jJjMMyBN7Wxl1DBeKRU5hJJDDkOgZyCnqeCuWzXXt5ZoQGOJx7RgxUm"
				+ "qv6r6w1J/0Eja24/fLkS++n+bz7NOGZiIs6Z3zZsjQKBgAp9LjtCFQSK+NVVgOPT"
				+ "9DSSoPwuKo9djs+n+E1sfOazhORLytfSIQJrOt/gl/ilp4sKcCmvgHj6CuILqpY6"
				+ "Zi6vYvTBAehqXcitZrvjPGJKiRa49HY++Q5dRw5ujvVu0WThTTFfrZ8w009Ja3Ar" + "p7bUwcPJTxOHNa1P6zN594Y2";

		//检查通道参数, 每个通道有不同参数, 对应 ll_routes.api_params
		Map<String, String> routeparams = Cache.getRouteParams(routeid);
		if (routeparams == null) {
			request.setAttribute("result", "S." + routeid + ":wrong routeparams@" + TimeUtils.getSysLogTimeString());
			break;
		}

		String AreaCode = routeparams.get("AreaCode");
		if (AreaCode == null) {
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, AreaCode is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		HashMap<String, String> param = new HashMap<String, String>();
		param.put("taskid", taskid);
		param.put("routeid", routeid);
		param.put("phone", phone);
		param.put("package", packageid);
		param.put("AreaCode", AreaCode);
		String sendurl = "http://10.170.165.150:8164/junbo/junbosend.jsp";
		logger.info("junbosend parm = " + param.toString());

		Cache.getConnection(routeid);
		try {
			ret = HttpAccess.postNameValuePairRequest(sendurl, param, "utf-8", "junbo");
		} catch (Exception e) {
			e.printStackTrace();
			logger.info(e.getMessage());
		} finally {
			//在执行请求后记得释放连接
			Cache.releaseConnection(routeid);
		}
		if (ret != null && ret.trim().length() > 0) {
			logger.info("junbo send ret = " + ret);
			if (ret.indexOf("unrecognized") >= 0) {
				request.setAttribute("result", "S." + routeid + ":unrecognized package@" + TimeUtils.getSysLogTimeString());
				break;
			}
			HashMap<String, String> errmap = new HashMap<String, String>();
			errmap.put("100", "接口调用成功 ");
			errmap.put("101", "服务器内部错误 流量雷锋订购接口错误或数据库错误");
			errmap.put("102", "服务器繁忙 数据库连接超时");
			errmap.put("112", "RSA 解密失败 RSA 密钥不正确");
			errmap.put("113", "AES 解密失败 接口请求消息中的 AESKey 错误或 AES 解密错误");
			errmap.put("121", "接口调用端时间戳错错误");
			errmap.put("123", "接口调用端参数格式错误");
			errmap.put("131", "没有操作权限 合作伙伴无进行当前操作的权限");
			errmap.put("0101", "手机号码错误");
			errmap.put("0102", "套餐编码错误");
			errmap.put("0103", "区域编码错误");
			errmap.put("0104", "区域未开通");
			errmap.put("0105", "账号余额不足");
			errmap.put("0106", "区域编码与套餐编码对应关系错误");
			errmap.put("0107", "套餐已经下架");
			errmap.put("0108", "套餐不可用");
			errmap.put("0109", "访问过于频繁 接口访问在一定时间内过于频繁");
			errmap.put("0110", "订单创建失败 流量雷锋订购接口内部发生错误");
			errmap.put("0111", "流水号不合法 流水号为空或是超出文档中定义最大长度");
			errmap.put("0200", "流量订购成功 流量已经充值到用户手机");
			errmap.put("0201", "流量订购部分成功 流量已经部分充值到用户手机");
			errmap.put("0202", "流量订购失败 当用户订购组合套餐时，套餐内所有供应商产品全部订购失败或充值失败");
			errmap.put("1200", "手机号码欠费停机");
			errmap.put("1201", "手机号码是黑名单用户");
			errmap.put("1202", "手机号码不存在");
			errmap.put("1203", "该用户不符合订购条件");
			errmap.put("1204", "该用户有正在处理的订单，无法订购");
			errmap.put("1205", "该用户号码不允许重复订购");
			errmap.put("1206", "运营商系统错误 运营商系统问题导致订购失败");
			errmap.put("1301", "订单不存在");
			errmap.put("1302", "订单待提交");
			errmap.put("1303", "订单正在处理中");
			errmap.put("1320", "参数输入不合法 输入参数为空会出现此错误");
			errmap.put("1321", "C 打包参数错误");
			errmap.put("1322", "RC 打包参数错误");
			errmap.put("1323", "客户端 AES 加密错误");
			errmap.put("1324", "客户端 RSA 密钥无效");
			errmap.put("1325", "客户端 RSA 加密错误");
			errmap.put("1327", "服务器错误 网络可用但 SDK 无法访问服务");
			errmap.put("1328", "服务返回空");
			errmap.put("1329", "服务返回数据错误 未按照安全接口来定义请求数据");
			errmap.put("1330", "AES 解密服务数据错误 无法解释服务返回数据");
			errmap.put("1334", "网络不可用 http 请求时网络出错");
			errmap.put("1335", "系统内部错误 SDK 内部未知结果码");
			errmap.put("1340", "未知错误 未知原因的错误");

			try {
				JSONObject retjson = JSONObject.fromObject(ret);
				logger.info("junbo 0=" + retjson.toString());
				String message = null;
				if (retjson.getString("S").equals("100")) {
					String retCode = retjson.getJSONObject("C").getString("ResultCode"); //":"MOB00001"
					logger.info("junbo 2=" + retCode);
					message = errmap.get(retCode);
					if (message == null) {
						message = "充值失败";
					}
					if (retCode.equals("0100")) {
						Object odobj = retjson.getJSONObject("C").get("OrderId");
						String rpid = null;
						if (odobj != null) {
							rpid = odobj.toString();
						}
						request.setAttribute("result", "success");
						request.setAttribute("reportid", rpid);
						logger.info("junbo 6=" + rpid);

					} else {
						request.setAttribute("code", retCode);
						request.setAttribute("result", "R." + routeid + ":" + retCode + ":" + message + "@" + TimeUtils.getSysLogTimeString());
					}
				} else {

					message = errmap.get(retjson.getString("S"));
					if (message == null) {
						message = "充值失败";
					}
					request.setAttribute("code", retjson.getString("S"));
					request.setAttribute("result",
							"R." + routeid + ":" + retjson.getString("S") + ":" + message + "@" + TimeUtils.getSysLogTimeString());
				}

				request.setAttribute("orgreturn", ret);
				logger.info("junbo 4");
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