package test;

import http.HttpAccess;
import http.VResponseHandler;

import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.net.URLDecoder;
import java.net.URLEncoder;
import java.security.GeneralSecurityException;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Map.Entry;

import net.sf.json.JSONArray;
import net.sf.json.JSONObject;

import org.apache.commons.lang3.time.DateFormatUtils;
import org.apache.http.HttpResponse;
import org.apache.http.client.HttpClient;
import org.apache.http.client.ResponseHandler;
import org.apache.http.client.config.RequestConfig;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.entity.StringEntity;
import org.apache.http.impl.client.CloseableHttpClient;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.impl.client.HttpClients;
import org.apache.http.util.EntityUtils;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.dom4j.Document;
import org.dom4j.DocumentException;
import org.dom4j.DocumentHelper;
import org.dom4j.Element;
import org.eclipse.jetty.util.UrlEncoded;

import com.sun.jndi.url.iiopname.iiopnameURLContextFactory;
import com.sun.mail.handlers.text_html;
import com.taobao.api.Constants;

import sun.misc.BASE64Decoder;
import util.AES;
import util.MD5Util;
import util.MyBase64;
import util.SHA1;
import util.TimeUtils;

import javax.crypto.Cipher;
import javax.crypto.spec.IvParameterSpec;
import javax.crypto.spec.SecretKeySpec;
import javax.xml.bind.DatatypeConverter;
import javax.xml.rpc.ParameterMode;

import org.apache.axis.client.Call;
import org.apache.axis.client.Service;
import org.apache.axis.encoding.XMLType;
import org.bouncycastle.jcajce.provider.asymmetric.rsa.DigestSignatureSpi.MD5;

public class CzxTest {
	private static Logger logger = LogManager.getLogger(CzxTest.class.getName());

	public static void main(String[] args) {
		// createXml();
		// testmd5();
		// hualeihuiTest();
		// xichuantianxiaTest();
		// huaxinTest();
		// huizhoudx();
		// yunlingTest();
		// shuallTest();
		// bs64decode();
		// gdliantongcfTest();
		// aosaiTest();
		// shandongllTest();
		// chenxiangllTest();
		// zhangyitongTest();
		// getcut();
		// xunzhongTest();
		// mandaoTest();
		// jxrtTest();
		// quxunTest();
		// erheiTest();
		// bjjiehengTest();
		// yizunTest();
/*String content = "451263263【danyuan】";
if (content.indexOf("【") == 0) {
	content = content.substring(content.indexOf("】") + 1);
} else if (content.indexOf("【") < 0) {
} else {
	content=content.substring(0, content.indexOf("【"));

}
System.out.print(content);*/
}

	

	private static void yizunTest() {
		String sendurl = "http://api2.adsl.cn/unicomAync/buy.do";
		String privatekey = "e767a219f12fb8dff180f4d38f9b8e1a3e01d6f024ebadc89d48d2fb6b0e8ca9";
		String userId = "481";
		String itemId = "15822";// 商品编号
		String uid = "15087056061";// phone
		String serialno = "201612221140";// taskid
		String dtCreate = TimeUtils.getTimeStamp();// time
		String sig = dtCreate + itemId + serialno + uid + userId + privatekey;
		String sign = MD5Util.getLowerMD5(sig);
		System.out.println("加密前: " + sig);
		System.out.println("加密后: " + sign);

		HashMap<String, String> map = new HashMap<String, String>();
		map.put("userId", userId);
		map.put("itemId", itemId);
		map.put("uid", uid);
		map.put("serialno", serialno);
		map.put("dtCreate", dtCreate);
		map.put("sign", sign);
		System.out.println("参数: " + map);

		String ret = HttpAccess.getNameValuePairRequest(sendurl, map, "utf-8", "yizunsend");

	}

	private static void bjjiehengTest() {
		String sendurl = "http://101.200.204.67/flowAgent";
		String appKey = "test";
		String appSecret = "098F6BCD4621D373CADE4E832627B4F6";
		String phoneNo = "18998299214";
		String prodCode = "CTQW10";
		String backUrl = "http://120.24.156.98:9302/ll_sendbuf/bjjiehengreturn.jsp";
		String transNo = "201612151354";

		HashMap<String, String> map = new HashMap<String, String>();
		map.put("appKey", appKey);
		map.put("appSecret", appSecret);
		map.put("phoneNo", phoneNo);
		map.put("prodCode", prodCode);
		map.put("backUrl", backUrl);
		map.put("transNo", transNo);

		String ret = HttpAccess.postNameValuePairRequest(sendurl, map, "utf-8", "bjjiehengsend");

	}

	private static void erheiTest() {
		String url = "http://openapi.ap.ngrok.io/api/rest";
		String secretkey = "755E822DAEE13F0EFB09373493EB94E4";
		String business_id = "ycNo9eBx";
		String timestamp = TimeUtils.getTimeStamp();
		String method = "rw.open.dataflow.order";
		String sign = "";

		String trans_no = "201612131654";// taskid
		String package_size = "50";
		String phone_num = "15626149425";
		String roam_type = "0";// 全国

		JSONObject obj = new JSONObject();
		obj.put("trans_no", trans_no);
		obj.put("package_size", package_size);
		obj.put("phone_num", phone_num);
		obj.put("roam_type", roam_type);

		String befsign = secretkey + "business_id" + business_id + "method" + method + "timestamp" + timestamp + obj + secretkey;
		System.out.println("befsign = " + befsign);
		sign = MD5Util.getUpperMD5(befsign);
		System.out.println("sign = " + sign);

		String sendurl = url + "?business_id=" + business_id + "&method=" + method + "&timestamp=" + timestamp + "&sign=" + sign;

		String ret = HttpAccess.postJsonRequest(sendurl, obj.toString(), "utf-8", "erheisend");

	}

	private static void quxunTest() {
		String sendurl = "http://test.e7chong.com:8899/data/order";
		String partner_no = "700288";
		String request_no = "201612071055";// taskid
		String contract_id = "100001";
		String order_id = "201612071055";
		String plat_offer_id = "TBC00000050B";
		String phone_id = "18998299214";
		String facevalue = "1";// 订单面值
		long timestamp = System.currentTimeMillis() / 1000;
		String effect_type = "1";

		String password = "SHnllIc84C2IbKWr";
		String vi = "7449922719108364";
		JSONObject obj = new JSONObject();
		obj.put("plat_offer_id", plat_offer_id);
		obj.put("phone_id", phone_id);
		obj.put("facevalue", facevalue);
		obj.put("order_id", order_id);
		obj.put("request_no", request_no);
		obj.put("contract_id", contract_id);
		obj.put("timestamp", timestamp);
		obj.put("effect_type", effect_type);

		System.out.println(obj.toString());
		String code;
		try {
			code = encrypt(obj.toString(), password, vi);
			JSONObject req = new JSONObject();
			req.put("partner_no", partner_no);
			req.put("code", code);
			String ret = HttpAccess.postJsonRequest(sendurl, req.toString(), "utf-8", "quxunsend");
			System.out.println(req.toString());
		} catch (Exception e) {
			e.printStackTrace();
		}

	}

	public static String encrypt(String input, String key, String vi) throws Exception {
		try {
			Cipher cipher = Cipher.getInstance("AES/CBC/PKCS5Padding");
			cipher.init(Cipher.ENCRYPT_MODE, new SecretKeySpec(key.getBytes(), "AES"), new IvParameterSpec(vi.getBytes()));
			byte[] encrypted = cipher.doFinal(input.getBytes("utf-8"));
			// 此处使用 BASE64 做转码。
			return DatatypeConverter.printBase64Binary(encrypted);
		} catch (Exception ex) {
			return null;
		}
	}

	private static void jxrtTest() {
		String sendurl = "http://121.40.100.34:8989/api/rechChannel";
		String account = "mingchuan";
		String password = "123456";
		password = MD5Util.get16LowerMD5(password);
		String mobile = "13587064951";
		String packageSize = "10";
		String outTradeNo = "20161130153805";// taskid
		String expdate = "30";// 有效期30天
		String range = "1";// 是否漫游1：漫游，2：非漫游
		String apiKey = "88b000ab3da84f99b163546a51a8f860";
		String sign = "";

		String bef = "account=" + account + "&expdate=" + expdate + "&mobile=" + mobile + "&outTradeNo=" + outTradeNo + "&packageSize=" + packageSize + "&password=" + password + "&range=" + range + "&apiKey=" + apiKey;
		System.out.println("加密前sign:" + bef);
		sign = MD5Util.getLowerMD5(bef);
		System.out.println("加密后sign:" + sign);

		HashMap<String, String> param = new HashMap<String, String>();
		param.put("account", account);
		param.put("password", password);
		param.put("mobile", mobile);
		param.put("packageSize", packageSize);
		param.put("outTradeNo", outTradeNo);
		param.put("expdate", expdate);
		param.put("range", range);
		param.put("sign", sign);
		System.out.println("提交参数:" + param);

		String ret = HttpAccess.postNameValuePairRequest(sendurl, param, "utf-8", "jxrtsend");
		System.out.println("ret = " + ret);

	}

	private static void mandaoTest() {
		String sendurl = "http://flow.zucp.net:9100/action/TrafficAmount";
		String rpurl = "http://flow.zucp.net:9105/api/OrderQuery/QueryAction";
		String username = "gzdyxx";
		String password = "h6ZWwtLn";
		String mobile = "18998299214";
		String amount = "5";
		String msgid = "4838108058149177169";
		// String token = MD5Util.getUpperMD5(username + mobile + amount+
		// password);
		String token = MD5Util.getUpperMD5(username + password + msgid + mobile);

		// HashMap<String, String> param = new HashMap<String, String>();
		// param.put("username", username);
		// param.put("mobile", mobile);
		// param.put("amount", amount);
		// param.put("token", token);

		HashMap<String, String> param = new HashMap<String, String>();
		param.put("username", username);
		param.put("mobile", mobile);
		param.put("msgid", msgid);
		param.put("token", token);

		String ret = HttpAccess.postNameValuePairRequest(rpurl, param, "utf-8", "mandao");
		System.out.println("ret = " + ret);

	}

	private static void xunzhongTest() {
		String accountSID = "b5a9efd0c7864641884a14ef55ad711b";
		String authToken = "b92ff30f5fee4e9f852f1cda80d5b337";
		String version = "201512";
		String func = "traffic";
		String funcURL = "Traffic.wx";
		String time = TimeUtils.getTimeStamp();
		String Authorization = MyBase64.base64Encode(accountSID + "|" + time);
		String Sign = MD5Util.getLowerMD5(accountSID + authToken + time);
		String sendurl = "http://sandbox.commchina.net/" + version + "/sid/" + accountSID + "/" + func + "/" + funcURL + "?Sign=" + Sign;
		System.out.println("sendurl =" + sendurl);

		// String action = "flowOrder";
		String action = "getTrafficResult";
		String appid = "64690e94fc5c4189a047a1eaacbf6dab";
		String phone = "18998293014";
		String flowValue = "10";
		String effectStartTime = "1";
		String effectTime = "1";
		String customParm = "20161124113300";// taskid

		// JSONObject obj = new JSONObject();
		// obj.put("action", action);
		// obj.put("appid", appid);
		// obj.put("phone", phone);
		// obj.put("flowValue", flowValue);
		// obj.put("effectStartTime", effectStartTime);
		// obj.put("effectTime", effectTime);
		// obj.put("customParm", customParm);
		// System.out.println("obj = " + obj.toString());

		JSONObject jsobj = new JSONObject();
		jsobj.put("action", action);
		jsobj.put("appid", appid);
		jsobj.put("requestId", "2016110000471085");
		logger.info("xunzhong status jsobj =" + jsobj.toString());

		LinkedHashMap<String, String> header = new LinkedHashMap<String, String>();
		header.put("Authorization", Authorization);

		String ret = HttpAccess.postJsonRequest(sendurl, jsobj.toString(), "utf-8", header, "xunzhongstatus");
		System.out.println("ret = " + ret);
		JSONObject retjson = JSONObject.fromObject(ret);
		String retCode = retjson.getString("trafficSts");
		System.out.println("retCode = " + retCode);

	}

	private static void getcut() {
		String value = null;
		String recvtime = TimeUtils.getTimeString();
		Element retXML;
		retXML = DocumentHelper.createElement("<?xml version=\"1.0\" encoding=\"utf-8\"?>");
		retXML = DocumentHelper.createElement("root");
		retXML.addAttribute("return", "0");
		retXML.addAttribute("info", "成功");
		HashMap<String, String> retmap = new HashMap<String, String>();
		String ret = "id=11231004036039061921&src=13500010777&dst=031&err=DELIVRD";
		String ret1 = "src=13622218418&dst=&msg=%d1%e0%bd%e3%bd%e3&mo=";
		try {
			ret1 = URLDecoder.decode(ret1, "GBK");
		} catch (UnsupportedEncodingException e) {
			e.printStackTrace();
		}
		String status = "1";

		String[] strs = ret1.split("&");
		for (int i = 0; i < strs.length; i++) {
			int idx = strs[i].indexOf('=');
			if (idx >= 0) {
				retmap.put(strs[i].substring(0, idx), strs[i].substring(idx + 1, strs[i].length()));
			}
		}
		System.out.println(retmap.toString());

		// String[] statusArr = ret1.split("&");
		// for (int i = 0; i < statusArr.length; i++) {
		// String[] statuses = statusArr[i].split("=");
		// for(int j = 0; j < statuses.length; j++){
		// if(statuses[++j] == null){
		// value = "1";
		// }
		// retmap.put(statuses[j], value);
		// }
		// }
		// System.out.println(retmap.toString());
		// String err = retmap.get("err");
		// if(err.equals("0") || err.equals("DELIVRD")){
		// status = "0";
		// }
		// retXML.addElement("report")
		// .addAttribute("sid", retmap.get("id"))
		// .addAttribute("status", status)
		// .addAttribute("info", err)
		// .addAttribute("recvtime", recvtime);
		// System.out.println(retXML.asXML());

		retXML.addElement("deliver").addAttribute("sendtime", recvtime).addAttribute("phone", retmap.get("src")).addAttribute("spnumber", "106900007500031").addAttribute("realspnumber", "106900007500031").addAttribute("content", retmap.get("msg"));
		System.out.println(retXML.asXML());
	}

	private static void zhangyitongTest() {
		String sendurl = "http://218.207.183.156:8080/flow/order.do";
		String channelNo = "danyuan_dx";
		String key = "FMPEL8TTT4QDS3T8";
		String msisdn = "18998299214";// phone
		String productid = "QGDXSJL10M";
		String requesttime = TimeUtils.getTimeStamp();
		String orderno = "2016111715061111";// taskid
		String sign = "";

		String sig = "channelNo=" + channelNo + "&msisdn=" + msisdn + "&orderno=" + orderno + "&productid=" + productid + "&requesttime=" + requesttime + "&key=" + key;

		System.out.println("加密前sign = " + sig);
		sign = MD5Util.getLowerMD5(sig);
		sign = MyBase64.base64Encode(sign);
		System.out.println("加密后sign = " + sign);

		HashMap<String, String> param = new HashMap<String, String>();
		param.put("channelNo", channelNo);
		param.put("msisdn", msisdn);
		param.put("productid", productid);
		param.put("requesttime", requesttime);
		param.put("orderno", orderno);
		param.put("sign", sign);
		System.out.println("param = " + param);
		String ret = HttpAccess.postNameValuePairRequest(sendurl, param, "utf-8", "zhangyitongsend");
	}

	// 绑定了98的ip
	private static void chenxiangllTest() {
		String url = "http://120.77.1.169/api/rest/1.0/order";
		String appkey = "danyuan01";
		String securityKey = "HUDnfgew.rf25";
		String phoneNo = "18998299214";
		String timeStamp = TimeUtils.getTimeStamp();
		String productId = "LTGDY000010";// 产品编号
		String cstmOrderNo = "201611171109112";// taskid
		String sig = "";

		String sign = "appkey" + appkey + "cstmOrderNo" + cstmOrderNo + "phoneNo" + phoneNo + "productId" + productId + "timeStamp" + timeStamp + securityKey;
		System.out.println("加密前sign = " + sign);

		sig = SHA1.sha1Encode(sign);
		sig = sig.toLowerCase();

		System.out.println("加密后sign = " + sig);

		JSONObject obj = new JSONObject();
		obj.put("sig", sig);
		obj.put("appkey", appkey);
		obj.put("timeStamp", timeStamp);
		obj.put("phoneNo", phoneNo);
		obj.put("productId", productId);
		obj.put("cstmOrderNo", cstmOrderNo);
		System.out.println("obj = " + obj);

		// String ret = HttpAccess.postJsonRequest(url, obj.toString(), "utf-8",
		// "chenxiangsend");

		DefaultHttpClient httpClient = new DefaultHttpClient();
		HttpPost method = new HttpPost(url);
		try {
			if (null != obj) {
				// 解决中文乱码问题
				StringEntity entity = new StringEntity(obj.toString(), "utf-8");
				entity.setContentEncoding("utf-8");
				entity.setContentType("application/json");
				method.setEntity(entity);
			}
			HttpResponse result = httpClient.execute(method);
			/** 请求发送成功，并得到响应 **/
			if (result.getStatusLine().getStatusCode() == 200) {
				String str = "";
				try {
					/** 读取服务器返回过来的json字符串数据 **/
					str = EntityUtils.toString(result.getEntity(), "utf-8");
					/** 把json字符串转换成json对象 **/
					System.out.println(str);
				} catch (Exception e) {
					e.printStackTrace();
				}
			}
		} catch (IOException e) {
			e.printStackTrace();
		}
	}

	public static String Encrypt(String strSrc) {
		MessageDigest md = null;
		String strDes = null;

		byte[] bt = strSrc.getBytes();
		try {
			md = MessageDigest.getInstance("SHA-256");
			md.update(bt);
			strDes = bytes2Hex(md.digest()); // to HexString
		} catch (Exception e) {
			return null;
		}
		return strDes;
	}

	public static String bytes2Hex(byte[] bts) {
		String des = "";
		String tmp = null;
		for (int i = 0; i < bts.length; i++) {
			tmp = (Integer.toHexString(bts[i] & 0xFF));
			if (tmp.length() == 1) {
				des += "0";
			}
			des += tmp;
		}
		return des;
	}

	private static void shandongllTest() {
		String url = "http://shandongtest.4ggogo.com/sd-web-in/auth.html";
		String sendurl = "http://shandongtest.4ggogo.com/sd-web-in/boss/charge.html";
		String appKey = "ad90e4ef5d6241d4899e82cc17cf185f";
		String appSecret = "ae3235e752004356a62439ecf22a51d5";
		String sign = "";
		String mobile = "18998299214";
		String productId = "979";
		String serialNum = "201612010937";// taskid

		SimpleDateFormat s = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSSz");
		try {
			String time = s.format(new Date());
			String time1 = time.substring(0, 23);
			System.out.println("time = " + time);
			String time2 = time.substring(26, 32);
			String time3 = time1 + time2;
			System.out.println(time3);

			sign = appKey + time3 + appSecret;
			System.out.println("前sign = " + sign);
			sign = Encrypt(sign);

			System.out.println("后sign = " + sign);

			Document document = DocumentHelper.createDocument();
			Element requestElement = document.addElement("Request");

			Element datetimeElement = requestElement.addElement("Datetime");
			Element authorizationElement = requestElement.addElement("Authorization");

			Element appKeyElement = authorizationElement.addElement("AppKey");
			Element signElement = authorizationElement.addElement("Sign");

			datetimeElement.setText(time3);
			appKeyElement.setText(appKey);
			signElement.setText(sign);
			System.out.println(document.asXML());

			Document document1 = DocumentHelper.createDocument();
			Element requestElement1 = document1.addElement("Request");

			Element datetimeElement1 = requestElement1.addElement("Datetime");
			Element chargeDataElement = requestElement1.addElement("ChargeData");

			Element mobileElement = chargeDataElement.addElement("Mobile");
			Element productIdElement = chargeDataElement.addElement("ProductId");
			Element serialNumElement = chargeDataElement.addElement("SerialNum");

			datetimeElement1.setText(time3);
			mobileElement.setText(mobile);
			productIdElement.setText(productId);
			serialNumElement.setText(serialNum);
			System.out.println(document1.asXML());

			LinkedHashMap<String, String> header = new LinkedHashMap<String, String>();
			header.put("HTTP-X-4GGOGO-Signature", sign);

			String ret = postXmlRequest(url, document.asXML(), "utf-8", header, "shandongll");

			Document doc = DocumentHelper.parseText(ret);
			Element responseElement = doc.getRootElement();

			Element autElement = responseElement.element("Authorization");
			Element tokenElement = autElement.element("Token");
			String token = tokenElement.getText();
			System.out.println("token = " + token);

			LinkedHashMap<String, String> tokenheader = new LinkedHashMap<String, String>();
			tokenheader.put("4GGOGO-Auth-Token", token);
			// String sendret = postXmlRequest(sendurl, document1.asXML(),
			// "utf-8", tokenheader, "shandongllsend");

		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	private static void aosaiTest() {
		String sendurl = "http://120.27.33.13:8080/api/traffic/recharge.do";
		String AppId = "danyuan1001";
		String AppSecret = "danyuan1001yfregfyeug453627t4gr6";
		String OutOrderNum = "201611111040";// taskid
		String Mobile = "18998299214";
		String ProductNum = "DX100005";// 产品编码
		String Sig = "";// 签名

		Sig = "AppId=" + AppId + "Mobile=" + Mobile + "OutOrderNum=" + OutOrderNum + "ProductNum=" + ProductNum + AppSecret;
		System.out.println("加密前" + Sig);

		Sig = MD5Util.getUpperMD5(Sig);
		System.out.println("加密后sig=" + Sig);

		HashMap<String, String> param = new HashMap<String, String>();
		param.put("AppId", AppId);
		param.put("OutOrderNum", OutOrderNum);
		param.put("Mobile", Mobile);
		param.put("ProductNum", ProductNum);
		param.put("Sig", Sig);

		String ret = HttpAccess.postNameValuePairRequest(sendurl, param, "utf-8", "aosaisend");
		System.out.println("ret = " + ret);

	}

	public static String productOpen(String pkey, String seqId, String loginName, String phoneNo, String productCode, String code) {
		String endpoint = "http://211.95.193.67/axis/services/IMBackwardProductService?wsdl";
		String result = "no result!";
		Service service = new Service();
		Call call = null;
		Object[] object = new Object[6];
		object[0] = pkey;
		object[1] = seqId;
		object[2] = loginName;
		object[3] = phoneNo;
		object[4] = productCode;
		object[5] = code;

		try {
			try {
				call = (Call) service.createCall();
			} catch (Exception e) {
				e.printStackTrace();
			}
			call.setTargetEndpointAddress(endpoint);// 远程调用路径
			call.setOperationName("productOpen");// 调用的方法名
			call.addParameter("pkey", XMLType.XSD_STRING, ParameterMode.IN);
			call.addParameter("seqId", XMLType.XSD_STRING, ParameterMode.IN);
			call.addParameter("loginName", XMLType.XSD_STRING, ParameterMode.IN);
			call.addParameter("phoneNo", XMLType.XSD_STRING, ParameterMode.IN);
			call.addParameter("productCode", XMLType.XSD_STRING, ParameterMode.IN);
			call.addParameter("code", XMLType.XSD_STRING, ParameterMode.IN);
			// 设置返回值类型：
			call.setReturnType(XMLType.XSD_STRING);// 返回值类型：String
			result = (String) call.invoke(object);
		} catch (Exception e) {
			e.printStackTrace();
		}
		return result;
	}

	private static void gdliantongcfTest() {
		String url = "";
		String pkey = "1031";
		String pSecret = "bb880c16d06289c8a8439d69c985a199";
		String seqId = "201611091443";// taskid
		String loginName = "dyxx";
		String phoneNo = "18998299214";
		String productCode = "00000001";
		String code = "";// 签名sign

		String sign = seqId + productCode + pkey + phoneNo + loginName + pSecret;
		code = MD5Util.getUpperMD5(sign);

		System.out.println("加密前签名 = " + sign);
		System.out.println("加密后签名 = " + code);

		String ret = productOpen(pkey, seqId, loginName, phoneNo, productCode, code);
		System.out.println("ret = " + ret);
	}

	private static void bs64decode() {
		JSONArray jsonArray = new JSONArray();
		JSONObject jsonObject = new JSONObject();
		jsonObject.put("resCode", "0000");
		jsonObject.put("resDscp", "充值成功");
		jsonObject.put("status", "S");
		jsonObject.put("mobile", "15823564859");
		jsonArray.add(jsonObject);

		JSONObject reqObject = new JSONObject();
		reqObject.put("orderNo", "111111");
		reqObject.put("result", jsonArray);

		try {
			// String base64 = MyBase64.base64Encode(reqObject.toString());
			String base64 = "eyJvcmRlck5vIjoiMTYxMTI0MTY0OTQ2NjYxNzY4MCIsInJlc3VsdCI6W3sibW9iaWxlIjoiMTg5NjUxMTEzNzQiLCJyZXNDb2RlIjoiIiwicmVzRHNjcCI6Ijk5LFtoenNrXeivt+axgui/kOiQpeWVhuaOpeWPo+i2heaXtiIsInN0YXR1cyI6IkYifV19";
			String retdata = getFromBASE64(base64);
			System.out.println("retdata = " + retdata);

			JSONObject obj = JSONObject.fromObject(retdata);

			String taskid = obj.getString("orderNo");

			JSONObject retobj = new JSONObject();
			JSONArray retarr = JSONArray.fromObject(obj.getString("result"));
			for (int i = 0; i < retarr.size(); i++) {
				retobj = retarr.getJSONObject(i);
			}

			String resCode = retobj.getString("resCode");
			String resDscp = retobj.getString("resDscp");
			String status = retobj.getString("status");

			System.out.println("taskid = " + taskid);
			System.out.println("resCode = " + resCode);
			System.out.println("resDscp = " + resDscp);
			System.out.println("status = " + status);
		} catch (Exception e) {
			System.out.println(e.getMessage());
		}
	}

	private static void shuallTest() {
		String appId = "Rb81FyWC";
		String appSecret = "Ta8tvSIxKuZmt5";
		String orderNo = "wwerertytgbr432SDFG";
		String uuid = "dsfgsertyefds556";
		String url = "http://api.91n.cc/flow/recharge.do";
		String strmd5 = null;
		String reqData1 = null;

		// 组装请求充值流量的手机数组
		JSONArray jsonArray = new JSONArray();
		JSONObject jsonObject = new JSONObject();
		jsonObject.put("flowSize", "10");
		jsonObject.put("mobile", "18856049462");
		jsonArray.add(jsonObject);

		// 组装请求参数 reqData
		JSONObject reqObject = new JSONObject();
		reqObject.put("mobile_list", jsonArray);
		reqObject.put("orderNo", orderNo);
		reqObject.put("uuid", uuid);

		System.out.println("reqData加密前的最终字符串： " + reqObject.toString());

		try {
			reqData1 = MyBase64.base64Encode(reqObject.toString());
			System.out.println("reqData：" + reqData1);
		} catch (Exception e) {
			e.printStackTrace();
		}

		// 构造签名
		StringBuffer sb = new StringBuffer();
		sb.append(appSecret).append(reqObject.toString()).append(appSecret);
		System.out.println("sign加密前的最终字符串：" + sb.toString());

		try {
			String str64 = MyBase64.base64Encode(sb.toString());
			strmd5 = MD5Util.getUpperMD5(str64);

			System.out.println("64: " + str64);
			System.out.println("MD5: " + strmd5);
		} catch (Exception e) {
			System.out.println("MD5, Error");
			e.printStackTrace();
		}

		// JSONObject reqData = new JSONObject();
		// reqData.put("appId", appId);
		// reqData.put("reqData", reqData1);
		// reqData.put("sign", strmd5);

		HashMap<String, String> reqData = new HashMap<String, String>();
		reqData.put("appId", appId);
		reqData.put("reqData", reqData1);
		reqData.put("sign", strmd5);

		System.out.println("请求数据  = " + reqData);
		String ret = HttpAccess.postNameValuePairRequest(url, reqData, "utf-8", "shuall");
		System.out.println("ret = " + ret);
	}

	private static void yunlingTest() {
		String url = "http://api.51llgo.com:8080/v1/api/orders/submit";
		String account = "15017556283";
		String key = "EAZvBsLuqLqeWUAZ";
		String mobile = "15017556283";
		String product_id = "CMP-GD-LL-10M";// packgecode
		String query_code = "20161102";// taskid
		// String callback_url = "";
		String sign = "account" + account + "mobile" + mobile + "product_id" + product_id + "query_code" + query_code + "key" + key;

		sign = MD5Util.getLowerMD5(sign);
		JSONObject obj = new JSONObject();
		obj.put("account", account);
		obj.put("mobile", mobile);
		obj.put("product_id", product_id);
		obj.put("query_code", query_code);
		obj.put("sign", sign);
		// obj.put("callback_url", callback_url);

		String ret = HttpAccess.postJsonRequest(url, obj.toString(), "utf-8", "yunlingsend");
		System.out.println("ret = " + ret);

	}

	private static void huizhoudx() {
		HashMap<String, String> param = new HashMap<String, String>();
		String ret = null;

		param.put("rpurl", "http://14.31.15.251:8081/WSInterface_cdmcs/services/CDMCSService?wsdl");
		param.put("account", "hz_dykj");
		param.put("password", "dykj5678");
		param.put("sessionId", "20161101175651.4675951");

		ret = HttpAccess.postNameValuePairRequest("http://120.24.80.29:9122/ll_client/statusret.jsp", param, "utf-8", "xichuantianxiastatus");
		System.out.println("ret = " + ret);
	}

	private static void huaxinTest() {
		String ret = null;
		String url = "http://sandboxapi.huaxincloud.com:8081/custom/CI2016000011/flowPackage/flowRecharge";
		String timestamp = TimeUtils.getTimeString();
		String secret = "06603be8cdb6443791ec9de4eb1a4f4c";
		// String key = secret + "callbackUrl" + "" + "phone" + "18998299214" +
		// "productId" + "B2016000029"
		// + "reqId" + "HF1112185427301215" + "sign_method"
		// + "md5" + "standardfeeid" + "300001" + "timestamp" + timestamp +
		// secret;

		String key = secret + "phone" + "18998299214" + "productId" + "B2016000029" + "reqId" + "HF1112185427301215" + "sign_method" + "md5" + "standardfeeid" + "300001" + "timestamp" + timestamp + secret;

		System.out.println(key);
		/*
		 * try{ key = URLEncoder.encode(key, "utf-8");
		 * }catch(UnsupportedEncodingException e){ e.printStackTrace(); }
		 */
		// String sign = MD5Util.getUpperMD5(key);

		String sign = null;
		try {
			sign = byte2hex(encryptMD5(key));
		} catch (IOException e) {
			e.printStackTrace();
		}

		System.out.println("sign = " + sign);
		JSONObject jsonParam = new JSONObject();
		jsonParam.put("sign", sign);
		jsonParam.put("timestamp", timestamp);
		jsonParam.put("sign_method", "md5");
		jsonParam.put("phone", "18998299214");
		jsonParam.put("standardfeeid", "300001");
		jsonParam.put("productId", "B2016000029");
		jsonParam.put("reqId", "HF1112185427301215");
		jsonParam.put("callbackUrl", "null");

		// ret = HttpAccess.postJsonRequest(url, jsonParam.toString(), "utf-8",
		// "huaxin");
		System.out.println("ret = " + ret);

	}

	public static byte[] encryptMD5(String data) throws IOException {
		byte[] bytes = null;
		try {
			MessageDigest md = MessageDigest.getInstance("MD5");
			bytes = md.digest(data.getBytes(Constants.CHARSET_UTF8));
		} catch (GeneralSecurityException gse) {
			System.out.println(gse.getMessage());
		}
		return bytes;
	}

	public static String byte2hex(byte[] bytes) {
		StringBuilder sign = new StringBuilder();
		for (int i = 0; i < bytes.length; i++) {
			String hex = Integer.toHexString(bytes[i] & 0xFF);
			if (hex.length() == 1) {
				sign.append("0");
			}
			sign.append(hex.toUpperCase());
		}
		return sign.toString();
	}

	private static void xichuantianxiaTest() {
		String ret = null;
		HashMap<String, String> param = new HashMap<String, String>();
		param.put("taskid", "20161015");
		param.put("sendurl", "http://14.31.15.251:8081/WSInterface_cdmcs/services/CDMCSService?wsdl");
		param.put("account", "hz_dykj");
		param.put("password", "dykj5678");
		param.put("phone", "18998299214");
		param.put("productCode", "100017125");
		param.put("flowType", "3");
		param.put("isRepeatOrder", "0");
		param.put("smsid", "123");

		String rxurl = "http://120.24.80.29:9122/ll_client/sendret.jsp";
		ret = HttpAccess.postNameValuePairRequest(rxurl, param, "utf-8", "xichuantianxiasend");
		System.out.println("ret = " + ret);

	}

	private static void hualeihuiTest() {
		hualeihui();
	}

	private static void hualeihui() {
		String url = "http://www.hualeihui.com/order/order_unified.do";
		String phone = "18998299214";
		String channelId = "34";
		String packagecode = "17";
		String privateChannel = "mchuan";
		String key = "mcwx@hlh";
		String sign = phone + channelId + packagecode + privateChannel + key;
		sign = MD5Util.getLowerMD5(sign);
		HashMap<String, String> param = new HashMap<String, String>();
		param.put("channelId", channelId);
		param.put("productbingdingId", packagecode);
		param.put("phone", phone);
		param.put("privateChannel", privateChannel);
		param.put("notifyUrl", "http://120.24.156.98:9302/ll_sendbuf/hualeihuireturn.jsp");
		param.put("sign", sign);

		String ret = HttpAccess.getNameValuePairRequest(url, param, "utf-8", "hualeihuisend");
		System.out.println("ret = " + ret);

	}

	private static void testmd5() {
		System.out.println(myMD5("aaabbbcccddd111222333444"));

	}

	private static void createXml() {
		// 使用 DocumentHelper 类创建一个文档实例。
		Document document = DocumentHelper.createDocument();
		// 使用 addElement() 方法创建根元素 <request> 。 addElement() 用于向 XML 文档中增加元素。
		Element requestElement = document.addElement("request");

		Element headElement = requestElement.addElement("head");

		Element custInteIdElement = headElement.addElement("custInteId");
		Element echoElement = headElement.addElement("echo");
		Element orderIdElement = headElement.addElement("orderId");
		Element timestampElement = headElement.addElement("timestamp");
		Element orderTypeElement = headElement.addElement("orderType");
		Element versionElement = headElement.addElement("version");
		Element chargeSignElement = headElement.addElement("chargeSign");

		custInteIdElement.setText("123");
		echoElement.setText("23");
		orderIdElement.setText("16012311123");
		timestampElement.setText("20161012143310");
		orderTypeElement.setText("1");
		versionElement.setText("1");
		chargeSignElement.setText("223");

		Element bodyElement = requestElement.addElement("body");
		Element itemElement = bodyElement.addElement("item");

		Element packCodeElement = itemElement.addElement("packCode");
		Element mobileElement = itemElement.addElement("mobile");
		Element effectTypeElement = itemElement.addElement("effectType");

		packCodeElement.setText("101024");
		mobileElement.setText("18998299214");
		effectTypeElement.setText("1");
		System.out.println("xml = " + document.asXML());
	}

	public final static String myMD5(String s) {
		String ret = null;
		try {
			byte[] btInput = s.getBytes("utf-8");
			// 获得MD5摘要算法的 MessageDigest 对象
			MessageDigest mdInst = MessageDigest.getInstance("MD5");
			// 使用指定的字节更新摘要
			mdInst.update(btInput);
			// 获得密文
			byte[] md = mdInst.digest();
			// 把密文转换成十六进制的字符串形式
			ret = new org.apache.commons.codec.binary.Base64().encodeToString(md);
		} catch (Exception e) {
			e.printStackTrace();
			return null;
		}

		return ret;
	}

	public static String getFromBASE64(String s) {
		if (s == null)
			return null;
		try {
			byte[] b = new org.apache.commons.codec.binary.Base64().decode(s);
			return new String(b, "utf-8");
		} catch (Exception e) {
			return null;
		}
	}

	public static String postXmlRequest(String url, String xml, String encode, Map<String, String> header, String mark) {
		String bacTxt = null;
		HttpPost httppost = null;
		CloseableHttpClient httpclient = HttpClients.createDefault();
		try {
			httppost = new HttpPost(url);

			RequestConfig requestConfig = RequestConfig.custom().setSocketTimeout(90000).setConnectTimeout(5000).build();
			httppost.setConfig(requestConfig);

			ResponseHandler<String> responseHandler = new VResponseHandler(mark);

			for (Entry<String, String> entry : header.entrySet()) {
				httppost.setHeader(entry.getKey(), entry.getValue());
			}

			StringEntity entity = new StringEntity(xml, encode);
			entity.setContentEncoding(encode);
			entity.setContentType("text/xml");

			httppost.setEntity(entity);

			bacTxt = httpclient.execute(httppost, responseHandler);

		} catch (Exception e) {
			StringBuffer sb = new StringBuffer();
			sb.append('[');
			sb.append(mark);
			sb.append("] Exception : ");
			sb.append(e.getMessage());
			logger.warn(sb.toString(), e);
		} finally {
			try {
				httppost.releaseConnection();
				httpclient.close();
			} catch (IOException e) {
				StringBuffer sb = new StringBuffer();
				sb.append('[');
				sb.append(mark);
				sb.append("] close httplicent Exception : ");
				sb.append(e.getMessage());
				logger.warn(sb.toString(), e);
			}
		}

		StringBuffer sb = new StringBuffer();
		sb.append('[');
		sb.append(mark);
		sb.append("] response text = ");
		sb.append(bacTxt);

		logger.info(sb.toString());

		return bacTxt;
	}
}
