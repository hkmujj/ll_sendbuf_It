<%@page import="java.util.Collection"%>
<%@page import="util.MD5Util"%>
<%@page import="com.alibaba.fastjson.JSONObject"%>
<%@page
	import="java.net.URLDecoder,
				util.MyStringUtils,
				java.util.Map.Entry,
				java.util.Map,
				org.dom4j.Element,
				org.dom4j.DocumentException,
				org.dom4j.DocumentHelper,
				org.dom4j.Document,
				http.HttpAccess,
				java.util.LinkedHashMap,
				java.util.HashMap,
				database.LLTempDatabase,
				org.apache.commons.codec.binary.Base64,
				javax.crypto.Cipher,
				javax.crypto.spec.SecretKeySpec,
				javax.crypto.SecretKey,
				java.security.SecureRandom,
				javax.crypto.KeyGenerator,
				java.util.Collections,
				java.util.Arrays,
				java.util.ArrayList,
				java.util.List,
				java.io.UnsupportedEncodingException,
				java.security.NoSuchAlgorithmException,
				java.security.MessageDigest,
				org.apache.logging.log4j.LogManager,
				org.apache.logging.log4j.Logger"
	language="java" pageEncoding="UTF-8"%><%!public static Logger logger = LogManager.getLogger();

	private static byte[] vlock = new byte[0];

	// 充值流量类型
	public static String doRecharge(String phone, String mbytes, String orderId, String mytype, String uid) {
		String url = "http://120.25.135.185:9301/lcll/xml/api.jsp";
		String action = "charge";
		String userid = "";
		String password = "";
		if (uid.equals("yunmchuan")) {
			 userid = "10551";
			 password = "f2b9a17600311994efb384f53140ee8f";
		} else if (uid.equals("yunmchuan1")) {
			 userid = "10589";
			 password = "e0a124c4be03ddb62d62303b6017547a";
		}
		// String userid = "10302";
		// String password = "f526bcc0a468b69bb0298c5f4a41eb2a";

		JSONObject reponseObj = new JSONObject();
		String msg = null;
		String status = null;
		synchronized (vlock) {

			String val = LLTempDatabase.getMapValue("ali", orderId, "07");

			if (val == null) {

				HashMap<String, String> params = new LinkedHashMap<String, String>();
				params.put("action", action);
				params.put("userid", userid);
				params.put("password", password);
				params.put("phone", phone);
				params.put("mbytes", mbytes);
				params.put("mytype", mytype);
				params.put("linkid", orderId);

				String ret = HttpAccess.postNameValuePairRequest(url, params, "utf-8", "alisend");
				System.out.println("ret=" + ret);

				Document document;
				try {
					document = DocumentHelper.parseText(ret);
				} catch (DocumentException e) {
					e.printStackTrace();
					return null;
				}
				Element root = document.getRootElement();

				String returnval = root.attribute("return").getText();
				if (returnval.equals("0")) {
					status = "success";
					msg = "成功";
					String taskid = root.attribute("taskid").getText();
					LLTempDatabase.putMap("ali", orderId, taskid + phone, "07");
				} else {
					status = "fail";
					if (returnval.equals("1001002")) {
						msg = "账户余额不足";
					} else if (returnval.equals("1002011")) {
						msg = "所充值的产品不存在";
					} else {
						msg = root.attribute("info").getText();
					}
				}
			} else {
				status = "success";
				msg = "成功";
			}
			reponseObj.put("status", status);
			reponseObj.put("msg", msg);
			logger.info("ali send json=" + reponseObj.toString());
			return reponseObj.toString();
		}
	}%>
<%
	logger.info("ali send entry");

	Map<String, String[]> paramMap = request.getParameterMap();
	if (paramMap != null) {
		for (Entry<String, String[]> param : paramMap.entrySet()) {
			logger.info("ali recharge key = " + param.getKey() + ", value = " + param.getValue()[0]);
		}
	}
	Collection<String> keyset = paramMap.keySet();
	List<String> list = new ArrayList<String>(keyset);

	//对key键值按字典升序排序  
	Collections.sort(list);
	StringBuffer sb = new StringBuffer();
	for (int i = 0; i < list.size(); i++) {
		if (!list.get(i).equals("sign")) {
			sb.append(list.get(i));
			sb.append(paramMap.get(list.get(i))[0]);
		}
	}
	JSONObject json = new JSONObject();
	String orderId = request.getParameter("orderId");
	String phone = request.getParameter("phone");
	String uid = request.getParameter("uid");
	String flow = request.getParameter("flow");
	String operator = request.getParameter("operator");
	String scope = request.getParameter("scope");
	String enable = request.getParameter("enable");
	String sign = request.getParameter("sign");
	if (uid != null && uid.equals("yunmchuan")) {
		if (enable != null && enable.equals("0")) {//&& scope.equals("1") 0全国 1省内
			logger.info("ali send signstr=" + sb.toString());
			String signstr = MD5Util.getLowerMD5(sb.toString());
			logger.info("ali send signstrbac=" + signstr);
			if (sign != null && signstr.equals(sign)) {
				if (phone != null && flow != null && orderId != null && scope != null) {
					String ret = doRecharge(phone, flow, orderId, scope, uid);
					out.print(ret);
				} else {
					json.put("status", "fail");
					json.put("msg", "参数缺失");
					out.print(json.toString());
				}
			} else {
				json.put("status", "fail");
				json.put("msg", "签名认证错误");
				out.print(json.toString());
			}
		} else {
			json.put("status", "fail");
			json.put("msg", "无对应资源可用");
			out.print(json.toString());
		}

	} else if (uid != null && uid.equals("yunmchuan1")) {
		if (enable != null && enable.equals("0")) {//&& scope.equals("1") 0全国 1省内
			logger.info("ali send signstr=" + sb.toString());
			String signstr = MD5Util.getLowerMD5(sb.toString());
			logger.info("ali send signstrbac=" + signstr);
			if (sign != null && signstr.equals(sign)) {
				if (phone != null && flow != null && orderId != null && scope != null) {
					String ret = doRecharge(phone, flow, orderId, scope, uid);
					out.print(ret);
				} else {
					json.put("status", "fail");
					json.put("msg", "参数缺失");
					out.print(json.toString());
				}
			} else {
				json.put("status", "fail");
				json.put("msg", "签名认证错误");
				out.print(json.toString());
			}
		} else {
			json.put("status", "fail");
			json.put("msg", "无对应资源可用");
			out.print(json.toString());
		}

	} else {
		json.put("status", "fail");
		json.put("msg", "客户标识不正确");
		out.print(json.toString());
	}
%>