<%@page import="java.text.SimpleDateFormat"%>
<%@page import="sun.misc.BASE64Encoder"%>
<%@page import="org.apache.jasper.tagplugins.jstl.core.Out"%>
<%@page import="javax.xml.bind.DatatypeConverter"%>
<%@page import="javax.crypto.spec.IvParameterSpec"%>
<%@page import="javax.crypto.spec.SecretKeySpec"%>
<%@page import="javax.crypto.Cipher"%>
<%@page
	import="util.TimeUtils,
				http.HttpAccess,
				util.MD5Util,
				cache.Cache,
				net.sf.json.JSONException,
				net.sf.json.JSONObject,
				java.util.*,
				util.MyStringUtils,
				java.net.URLDecoder,
				org.apache.logging.log4j.LogManager,
				org.apache.logging.log4j.Logger,
				util.MyBase64,
				java.security.MessageDigest,
				java.security.NoSuchAlgorithmException,
				java.io.UnsupportedEncodingException"
	language="java" pageEncoding="UTF-8"%><%!public static String sign(String key, String timestamp, String account) {
		String[] arr = new String[] { key, timestamp, account };
		Arrays.sort(arr);
		StringBuilder content = new StringBuilder();
		for (int i = 0; i < arr.length; i++) {
			content.append(arr[i]);
		}
		String signature = null;
		try {
			MessageDigest md = MessageDigest.getInstance("SHA-1");
			byte[] digest = md.digest(content.toString().getBytes("utf-8"));
			signature = toHexString(digest);
		} catch (NoSuchAlgorithmException e) {
			e.printStackTrace();
		} catch (UnsupportedEncodingException e) {
			e.printStackTrace();
		}
		return signature;
	}

	public static final char HEX_DIGITS[] = { '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'a', 'b', 'c', 'd', 'e', 'f' };

	public static String toHexString(byte[] bytes) {
		StringBuilder sb = new StringBuilder(bytes.length * 2);
		for (int i = 0; i < bytes.length; i++) {
			sb.append(HEX_DIGITS[(bytes[i] & 0xf0) >>> 4]);
			sb.append(HEX_DIGITS[bytes[i] & 0x0f]);
		}
		return sb.toString();
	}

	public static String getBase64(String str) {
		byte[] b = null;
		String s = null;
		try {
			b = str.getBytes("utf-8");
		} catch (UnsupportedEncodingException e) {
			e.printStackTrace();
		}
		if (b != null) {
			s = new BASE64Encoder().encode(b);
		}
		return s;
	}%>
<%
	out.clearBuffer();
	boolean logflag = true;
	Logger logger = LogManager.getLogger();

	//获取公共参数
	String taskid = request.getAttribute("taskid").toString();
	String routeid = request.getAttribute("routeid").toString();
	String phone = request.getAttribute("phone").toString();
	String packageid = request.getAttribute("package").toString();

	while (true) {
		String ret = null;

		//检查通道参数, 每个通道有不同参数, 对应 ll_routes.api_params(私有参数)
		Map<String, String> routeparams = Cache.getRouteParams(routeid);
		if (routeparams == null) {
			request.setAttribute("result", "S." + routeid + ":wrong routeparams@" + TimeUtils.getSysLogTimeString());
			break;
		}

		String sendurl = routeparams.get("sendurl");
		if (sendurl == null) {
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, sendurl is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String account = routeparams.get("account");
		if (account == null) {
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, account is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String key = routeparams.get("key");
		if (key == null) {
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, key is null@" + TimeUtils.getSysLogTimeString());
			break;
		}

		//参数准备, 每个通道不同

		String packagecode = null;
 		if(routeid.equals("3225")){
			//全国电信
			if(packageid.equals("dx.5M")){
				packagecode = "b5b8fbf8b2714692a65a46eb41293e64";
			}else if(packageid.equals("dx.10M")){
				packagecode = "d2481cef3ac249ab832cfcd3a7e1e1b0";
			}else if(packageid.equals("dx.30M")){
				packagecode = "684f6432074c4cf1861ce6c871525f99";
			}else if(packageid.equals("dx.50M")){
				packagecode = "17724034398f4911b792dd40ce321035";
			}
		}else if(routeid.equals("3226")){
			//全国电信
			if(packageid.equals("dx.100M")){
				packagecode = "af1cbcc611b143fd981c00fbba76c7b2";
			}else if(packageid.equals("dx.200M")){
				packagecode = "8ad5292f8c814fd793fd0c93e65ab2ae";
			}else if(packageid.equals("dx.500M")){
				packagecode = "bb57348c57bd429db23980dc566f83e3";
			}else if(packageid.equals("dx.1G")){
				packagecode = "3a2f3389b1174df38966b6cf405cf4cb";
			}
		}else if(routeid.equals("3226")){
			//山东电信
			if(packageid.equals("dx.5M")){
				packagecode = "0c4b11a4ac4945cfb0e8ca9aa99d8022";
			}else if(packageid.equals("dx.10M")){
				packagecode = "b6d7a5c8873c47188c7d1e229c15ce4f";
			}else if(packageid.equals("dx.30M")){
				packagecode = "d5a794acd9784fe88f425aff556b5139";
			}else if(packageid.equals("dx.50M")){
				packagecode = "6343271fe8ac459eb02b3123451e47a6";
			}else if(packageid.equals("dx.100M")){
				packagecode = "e72a884d67484c79bac73df51c8dfdc0";
			}else if(packageid.equals("dx.200M")){
				packagecode = "58eae5c7863b4de2ba5961c5cf8f1bc5";
			}else if(packageid.equals("dx.300M")){
				packagecode = "bf78fd70990446d1b44343be79d4fdd4";
			}else if(packageid.equals("dx.500M")){
				packagecode = "7efdbb36d37b4c4c817d5c9bcde692e8";
			}else if(packageid.equals("dx.1G")){
				packagecode = "829ceaad18024209be493c3f7003f7c0";
			}
		}else if(routeid.equals("3227")){
			//内蒙古电信
			if(packageid.equals("dx.5M")){
				packagecode = "7651c4365c50484da420176e22934081";
			}else if(packageid.equals("dx.10M")){
				packagecode = "4f9e3f03721a441e87383cf60de099c4";
			}else if(packageid.equals("dx.30M")){
				packagecode = "ba0d032a234542e88ecf060122889bd2";
			}else if(packageid.equals("dx.50M")){
				packagecode = "15a56a5f891f418a9b29698380316b56";
			}else if(packageid.equals("dx.100M")){
				packagecode = "e2d7cfaf09d14ac5a0cbd38e0d919b61";
			}else if(packageid.equals("dx.200M")){
				packagecode = "5215394003e7416eb9950103b945c239";
			}else if(packageid.equals("dx.500M")){
				packagecode = "420f474035f54ae7932a964334aa68a2";
			}else if(packageid.equals("dx.1G")){
				packagecode = "cc0f280b57334ede8ab8ef9caad8e933";
			}
		}else if(routeid.equals("3300")){
			//上海电信
			if(packageid.equals("dx.10M")){
				packagecode = "9888e2e221ef43dba5143e9d494993da";
			}else if(packageid.equals("dx.30M")){
				packagecode = "e5bcfffe50954e2d8938f985da1191f4";
			}else if(packageid.equals("dx.50M")){
				packagecode = "d6c67e45a4b24d2d9940989a24d7765a";
			}else if(packageid.equals("dx.100M")){
				packagecode = "0cd3eadf273b44cd89eef501ee8e196c";
			}else if(packageid.equals("dx.200M")){
				packagecode = "543eb7227546408d8bd0dfb140802820";
			}else if(packageid.equals("dx.500M")){
				packagecode = "ab57768324ee4ce99d37e1ab10ba7444";
			}else if(packageid.equals("dx.1G")){
				packagecode = "5cf9ed1d91094659876f2740d58b5e96";
			}
		}else if(routeid.equals("3229")){
			//辽宁电信
			if(packageid.equals("dx.5M")){
				packagecode = "161478ca7960478f86f3bda7a93c5555";
			}else if(packageid.equals("dx.10M")){
				packagecode = "46a92feac6df4bde8038e237ca2b3e4a";
			}else if(packageid.equals("dx.30M")){
				packagecode = "0179bf6a58a94e20bbead523c5dac214";
			}else if(packageid.equals("dx.50M")){
				packagecode = "9e76717c77c8482592bd54f596378ced";
			}else if(packageid.equals("dx.100M")){
				packagecode = "e076e209a3544fa9a19bdcfc55c9bfeb";
			}else if(packageid.equals("dx.200M")){
				packagecode = "21f4d4c2bbaf4a8faeba385928900f14";
			}else if(packageid.equals("dx.300M")){
				packagecode = "53e5cd11adc347a0a1f481fbdb606bf8";
			}else if(packageid.equals("dx.500M")){
				packagecode = "b355c0ee359c4dde8397576c6162e9fb";
			}else if(packageid.equals("dx.1G")){
				packagecode = "ad3c8454ec364f57a8652bce68751c74";
			}
		}else if(routeid.equals("3228")){
			//江苏电信
			if(packageid.equals("dx.5M")){
				packagecode = "d3c42d648ffd4fcb9f9bb17478f5b3ec";
			}else if(packageid.equals("dx.10M")){
				packagecode = "81e9beb35cab4024a9d8b428d43a7d11";
			}else if(packageid.equals("dx.30M")){
				packagecode = "e96930de71a14c05841d7f514fa261fc";
			}else if(packageid.equals("dx.50M")){
				packagecode = "0b2f0c958932441a9d7a8c9317ee715e";
			}else if(packageid.equals("dx.100M")){
				packagecode = "b0fd1890bdd14404b6a0bc293ee29ec5";
			}else if(packageid.equals("dx.200M")){
				packagecode = "b296ef0499a643e6be5b557cd244e916";
			}else if(packageid.equals("dx.300M")){
				packagecode = "b4f26752a8434759897376ad2358d452";
			}else if(packageid.equals("dx.500M")){
				packagecode = "ed35a0d28c5b4544aac98593f21bef1f";
			}else if(packageid.equals("dx.1G")){
				packagecode = "196cc78e68184e5f9ecac31e48c6d059	";
			}else if(packageid.equals("dx.2G")){
				packagecode = "923e640df9614809be79b4b34eef0e64	";
			}else if(packageid.equals("dx.3G")){
				packagecode = "bf3369df4a8a4c20aea3870490a8e02b	";
			}
		}
		 
		if (packagecode == null) {
			request.setAttribute("result", "S." + routeid + ":unrecognized package@" + TimeUtils.getSysLogTimeString());
			break;
		}

		Map<String, String> parm = new HashMap<String, String>();
		parm.put("mobile", phone);
		parm.put("productCode", packagecode);
		long lt = System.currentTimeMillis();
		SimpleDateFormat simpleDateFormat = new SimpleDateFormat("yyyyMMddHHmmss");
		Date date = new Date(lt);
		String res = simpleDateFormat.format(date);
		String a = account + "," + res;
		parm.put("nonce", getBase64(a));
		parm.put("otherParam", taskid);
		logger.info("yijiayun signbef="+key+"&" +res+"&"+account);
		String sign = sign(key, res, account);
		logger.info("yijiayun signbac="+sign);
		parm.put("signature", sign);

		//在执行请求前先获取连接, 防止访问通道线程超量
		Cache.getConnection(routeid);
		try {
			//ret = HttpAccess.postNameValuePairRequest(url, params, "utf-8", "mysend");
			//ret = HttpAccess.postJsonRequest(url, json.toString(), "utf-8", "weikesend");
			ret = HttpAccess.getNameValuePairRequest(sendurl, parm, "utf-8", "yijiayun");
		} catch (Exception e) {
			e.printStackTrace();
			logger.info(e.getMessage());
		} finally {
			//在执行请求后记得释放连接
			Cache.releaseConnection(routeid);
		}

		//这里判断结果, 每个通道情况不同, 成功的保存 success 到 result 中并返回到 request.jsp(ret为返回的结果)
		if (ret != null && ret.trim().length() > 0) {
			logger.info("yijiayun send ret = " + ret);

			try {
				JSONObject retjson = JSONObject.fromObject(ret);
				String retCode = retjson.getString("status"); //":"00000" 下单/订购成功

				if (retCode.equals("00000")) {
					request.setAttribute("result", "success");
				} else {
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
					String errmsg = retCode;
					if(errmap.get(errmsg) != null){
					errmsg = errmap.get(retCode);
					}
					request.setAttribute("code", 1);
					request.setAttribute("result", "R." + routeid + ":" + errmsg + "@" + TimeUtils.getSysLogTimeString());
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