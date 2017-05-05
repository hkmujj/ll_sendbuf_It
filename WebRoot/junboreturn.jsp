<%@page import="database.LLTempDatabase"%>
<%@page
	import="util.Utility,
				java.util.Map.Entry,
				net.sf.json.JSONArray,
				util.TimeUtils,
				net.sf.json.JSONException,
				net.sf.json.JSONObject,
				java.util.*,
				java.net.URLDecoder,
				org.apache.logging.log4j.LogManager,
				org.apache.logging.log4j.Logger"
	language="java" pageEncoding="UTF-8"%><%!private static boolean logflag = true;
	private static Logger logger = LogManager.getLogger();

	public static String CallBack(String v, String k, String c) {

		String privateKey = "MIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQDXLRqRB44aSSfr" + "4JkrYxM7ufLiEfK/Mz38bqHKieqfoT63MGqtAzyl/CaCXFl+aU0ptmBgHiUsX9kZ" + "ks4FmjNoutRu6solR+Ax5cuZBACqWafUHM5lyIkzmDIvwxYArn5ybHF7Qk19RVJ4" + "kLkmQq7ECs9ZVDb4mleTi05ivbldVLDVmcJWexxWot9ffd16E1eyntvnxvAOo77z" + "FVC/7JLZmpfi7jWKziVJX3Sy/0CTMShKYaRe+C5DqWIETmPeQGNd5D/Q/wA5SSXG" + "/v6KvXy7MJ5dN9PgHiB1sRPWZjyNVlvcbMacmTqaQ7gKUmLJGG2KUAg21cfwQr1K" + "8U8fiTzfAgMBAAECggEBAMD8COmuFvroRc+9/mH1V9ina3jqlAZ71MpEBwN6Ml28" + "5lyyJdrKHmjX/0nHvdQsaTJSCZnrL3fe9v2Ctxg7NoRlnAVmuqo5DpByAupXtqkS" + "A/2vYEXVV4hYphpEI8W0ul+xdw4PZyRFOjQ7yHLSN6BH+bOqXisVcho4RLM2abuT" + "hjt+9BL+uD8aKHfVsmpo9DiIxYj6goFXcfdKHrhpnzeaSEx3ekFeYEnE5gS4WV02" + "2RldLwA8EecyAZqCZRv9VhF9mMyfsfjVlTmUR5PzSXHRGkSkHI9rthNrb+HOJdw2"
				+ "QKnvaflRTppoEg4lO5m9/jBtfEG0s8+lpbRvq/99ATECgYEA9BCVAOUNakyct9MG" + "aV0lV40J1IhDloPbdKip2P8YtLsv2Cjhz7oKJ+zJ5f0W4+vbNSukiZ28McA81SNb" + "WKTSMmex2KNk+9+UO8MfLs2tV8vMXeQ0ROd0Aig/HK3GlboJfNMRDApbvRXgL8oQ" + "7kYXBU5mbrkfRnUvI6jsE8NAIK0CgYEA4bLecpo1b6NQXPjCAfnGoBHN748bvxe0" + "ee0ycn1YEECkx8N0/j/yXf98wkejA+2NVwXMcUo0wYBVBOSgFZsaH6ZdSOYMqA7L" + "1y1tOa+wNPDPH6JjZcWFx4MxTMngc8vaI2ORAQvzJzZdHn4xMXp0DK6rUtDM7eka" + "s8PG+6deKTsCgYEAiUm+l1dBGZdo3JqO07v6omoKqovQAR3A17l8eTzdp+RXwG8W" + "vqO2zMiMtZuNQb5Ne3ZGQscAsrehQH94BcAJISNlTihzSJ92obtbkhdON8HC/tm8" + "cToE7qW3AqnZuCWC6r1LrIszGYTxq9Atf+rbTjfQtN3bcuW+E4AU8/Tz4K0CgYB1" + "sI3qeJswsZpwQI759MMsKNyX9KnlRXkosxVBOjc3kl3ahQN2qOW7OkRWEoDgxXiU" + "TkPDN4y28jJjMMyBN7Wxl1DBeKRU5hJJDDkOgZyCnqeCuWzXXt5ZoQGOJx7RgxUm"
				+ "qv6r6w1J/0Eja24/fLkS++n+bz7NOGZiIs6Z3zZsjQKBgAp9LjtCFQSK+NVVgOPT" + "9DSSoPwuKo9djs+n+E1sfOazhORLytfSIQJrOt/gl/ilp4sKcCmvgHj6CuILqpY6" + "Zi6vYvTBAehqXcitZrvjPGJKiRa49HY++Q5dRw5ujvVu0WThTTFfrZ8w009Ja3Ar" + "p7bUwcPJTxOHNa1P6zN594Y2";

		byte[] aesKey = null;
		try {
			aesKey = Utility.decrypt(Utility.loadPrivateKey(privateKey), Utility.basedecode(k));
			byte[] iv = new byte[16];
			if (aesKey != null) {
				for (int i = 0; i < 16; i++) {
					iv[i] = aesKey[i];
				}
			}
			return new String(Utility.aesdecrypt(Utility.basedecode(c), aesKey, iv));
		} catch (Exception e) {
			e.printStackTrace();
			return "";
		}

	}%>
<%
	String ret = null;
	logger.info("junbo return entry1");

	Map<String, String[]> paramMap = request.getParameterMap();
	if (paramMap != null) {
		for (Entry<String, String[]> param : paramMap.entrySet()) {
			logger.info("junbo return key = " + param.getKey() + ", value = " + param.getValue()[0]);
		}
	}

	String k = request.getParameter("K");
	String v = request.getParameter("V");
	String c = request.getParameter("C");

	if (k == null || k.trim().length() <= 0 || v == null || v.trim().length() <= 0 || c == null || c.trim().length() <= 0) {
		out.print("bad request data");
		return;
	}

	ret = CallBack(v, k, c);
	logger.info("junbo return ret=" + ret);
	if (ret == null || ret.trim().length() <= 0) {
		out.print("bad request data");
		return;
	}

	logger.info("junbo ret=" + ret);
	String status = null;
	String info = null;
	String mark = "junbo";

	JSONObject retjson = null;

	try {
		retjson = JSONObject.fromObject(ret);
		String retCode = retjson.getJSONObject("RC").getString("ResultCode"); //":"MOB00001"
		String taskid = retjson.getJSONObject("RC").getString("OrderId");
		String ErrorMsg = null;

		if (retjson.getJSONObject("RC").get("ErrorMsg") != null) {
			ErrorMsg = retjson.getJSONObject("RC").getString("ErrorMsg");
		}

		HashMap<String, String> errmap = new HashMap<String, String>();
		errmap.put("0101", "手机号码错误");
		errmap.put("0102", "套餐编码错误");
		errmap.put("0103", "区域编码错误");
		errmap.put("0104", "区域未开通");
		errmap.put("0105", "账号余额不足");
		errmap.put("0106", "区域编码与套餐编码对应关系错误");
		errmap.put("0107", "套餐已经下架");
		errmap.put("0108", "套餐不可用");
		errmap.put("0109", "访问过于频繁 接口访问在一定时间内过于频繁");
		errmap.put("0110", "订单创建失败 ，订购接口内部发生错误");
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

		if (retCode.equals("0200")) {
			status = "0";
			info = "成功";
		} else {
			status = "1";
			if (ErrorMsg == null || ErrorMsg.trim().length() <= 0) {
				if (errmap.get("retCode") != null) {
					info = errmap.get("retCode");
				} else {
					info = "未知错误";
				}
			} else {
				info = URLDecoder.decode(ErrorMsg, "utf-8");
			}
		}
		LLTempDatabase.addReport(mark, taskid, status, info, "01");
		out.clearBuffer();
		out.print("1");
	} catch (Exception e) {
		out.print("err");
	}
%>