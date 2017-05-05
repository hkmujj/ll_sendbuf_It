<%@page
	import="java.util.Map.Entry,
				database.LLTempDatabase,
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
	language="java" pageEncoding="UTF-8"%>
<%
	boolean logflag = true;
	Logger logger = LogManager.getLogger();

	logger.info("yijiayun return entry1");

	String str = MyStringUtils.inputStringToString(request.getInputStream());
	if (str == null || str.length() <= 0) {
		str = request.getParameter("json");
	}
	if (str == null || str.length() <= 0) {
		if (request.getQueryString() != null) {
			str = URLDecoder.decode(request.getQueryString(), "utf-8");
		}
	}

	if (str == null) {
		logger.info("yijiayun no request data");
		out.print("no request data");
		return;
	}

	logger.info("yijiayun return str = " + str);

	JSONArray objarr = null;
	try {
		objarr = JSONArray.fromObject(str);
		logger.info("yijiayun return =" + objarr.toString());
	} catch (Exception e) {
		logger.warn(e.getMessage(), 0);
		out.print("bad json data");
		return;
	}

	for (int i = 0; i < objarr.size(); i++) {
		JSONObject obj = objarr.getJSONObject(i);
		String taskid = obj.getString("otherParam");
		String result = obj.getString("status");

		String status = null;
		String info = "";
		String mark = "yijiayun";
		if (result.equals("00000")) {
			status = "0";
			info = "充值成功";
		} else {
			status = "1";
			Map<String, String> errmap = new HashMap<String, String>();
			errmap.put("00000", "下单/订购成功");
			errmap.put("00001", "下单/订购失败");
			errmap.put("00002", "任务处理中");
			errmap.put("10001", "黑名单号码");
			errmap.put("10002", "空号/号码不存在");
			errmap.put("10003", "号码归属地错误");
			errmap.put("10004", "欠费/停机");
			errmap.put("10005", "号码已冻结或注销");
			errmap.put("10006", "业务互斥");
			errmap.put("10007", "业务受限");
			errmap.put("10008", "没有合适的产品");
			errmap.put("10009", "没有合适的通道");
			errmap.put("10010", "通道被停用");
			errmap.put("10011", "通道余额不足");
			errmap.put("10012", "号码充值过于频繁");
			errmap.put("10013", "检测到异常任务");
			errmap.put("20000", "签名认证失败");
			errmap.put("20001", "请求已过期");
			errmap.put("20002", "参数格式错误");
			errmap.put("20003", "附加参数超长");
			errmap.put("20004", "运营商错误");
			errmap.put("20005", "产品类型错误");
			errmap.put("20006", "客户不存在");
			errmap.put("20007", "客户被停用");
			errmap.put("20008", "客户IP非法");
			errmap.put("20009", "客户余额不足");
			errmap.put("20010", "产品不存在");
			errmap.put("20011", "环行任务");
			errmap.put("20012", "任务不存在，请稍候再试");
			errmap.put("99998", "未知错误");
			errmap.put("99999", "系统内部错误");
			info = "充值失败";
			if (errmap.get(result) != null) {
				info = errmap.get(result);
			}
		}
		LLTempDatabase.addReport(mark, taskid, status, info, "01");
	}
	out.clearBuffer();
	out.print("OK");
%>