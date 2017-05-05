package test;

import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.net.URL;
import java.net.URLDecoder;
import java.net.URLEncoder;
import java.nio.charset.Charset;
import java.security.GeneralSecurityException;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.security.cert.CertificateException;
import java.security.cert.X509Certificate;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.Collections;
import java.util.HashMap;
import java.util.Iterator;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.Random;
import java.util.Map.Entry;

import javax.net.ssl.SSLContext;

import key.Key;
import http.HttpAccess;
import http.KeyValuePair;
import net.sf.json.JSONArray;
import net.sf.json.JSONObject;

import org.apache.commons.codec.binary.Base64;
import org.apache.commons.codec.language.bm.Rule.RPattern;
import org.apache.http.HttpEntity;
import org.apache.http.HttpStatus;
import org.apache.http.client.methods.CloseableHttpResponse;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.conn.ssl.SSLConnectionSocketFactory;
import org.apache.http.entity.StringEntity;
import org.apache.http.impl.client.CloseableHttpClient;
import org.apache.http.impl.client.HttpClients;
import org.apache.http.ssl.SSLContextBuilder;
import org.apache.http.ssl.TrustStrategy;
import org.apache.http.util.EntityUtils;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.dom4j.Attribute;
import org.dom4j.Document;
import org.dom4j.DocumentHelper;
import org.dom4j.Element;

import util.AES;
import util.MyBase64;
import util.MD5Util;
import util.SHA1;
import util.TimeUtils;

import com._21cn.open.openapi.common.OauthRequestUtil;
import com.aspire.portal.web.security.client.GenerateSignature;
import com.gargoylesoftware.htmlunit.AjaxController;
import com.gargoylesoftware.htmlunit.BrowserVersion;
import com.gargoylesoftware.htmlunit.NicelyResynchronizingAjaxController;
import com.gargoylesoftware.htmlunit.WebClient;
import com.gargoylesoftware.htmlunit.WebRequest;
import com.gargoylesoftware.htmlunit.html.DomElement;
import com.gargoylesoftware.htmlunit.html.HtmlForm;
import com.gargoylesoftware.htmlunit.html.HtmlPage;
import com.gargoylesoftware.htmlunit.html.HtmlSubmitInput;
import com.gargoylesoftware.htmlunit.html.HtmlTextInput;
import com.gargoylesoftware.htmlunit.javascript.host.html.HTMLHRElement;
import com.gargoylesoftware.htmlunit.javascript.host.html.HTMLLinkElement;
import com.taobao.api.internal.tmc.Message;
import com.taobao.api.internal.tmc.MessageHandler;
import com.taobao.api.internal.tmc.MessageStatus;
import com.taobao.api.internal.tmc.TmcClient;
import com.taobao.api.internal.toplink.LinkException;
import com.taobao.api.request.AlibabaAliqinFcFlowGradeRequest;
import com.taobao.api.request.AlibabaAliqinFcFlowChargeRequest;
import com.taobao.api.response.AlibabaAliqinFcFlowChargeResponse;
import com.taobao.api.response.AlibabaAliqinFcFlowGradeResponse;
import com.taobao.api.request.AlibabaAliqinFlowWalletQueryChargeRequest;
import com.taobao.api.request.AlibabaAliqinFcFlowQueryRequest;
import com.taobao.api.ApiException;
import com.taobao.api.DefaultTaobaoClient;
import com.taobao.api.TaobaoClient;
import com.taobao.api.response.AlibabaAliqinFlowWalletQueryChargeResponse;
import com.taobao.api.response.AlibabaAliqinFcFlowQueryResponse;


public class MainTest {
	
	private static Logger logger = LogManager.getLogger(MainTest.class.getName());
	
	public static void main(String[] args) {
		//testManyJsonRequest();
		//testJsonRequest();
		//teststatus();
		//testJsonRequest();
		//testString();
		//testmap();
		//alibaba.aliqin.flow.wallet.query
		//testali();
		//testresult();
		//testequal();
		//testRequest();
		//testwangsu();
		//testsharp();
		//testmaiersi();
		//testmaiersistatus();
		//testmaiersistatusII();
		//testjson();
		//testrp();
		//testsplit();
		//testtimesub();
		//teststr();
		//testltkd();
		//testjsonII();
		//testgdlt();
		//testxml();
		//testhh();
		//testbyte();
		//testjsonIII();
		//testjsonIV();
		//testmaiyi();
		//testbase64();
		//testsubstr();
		
		//teststr22();
		//testhzy();
		//testhzyzt();
		
		//testreturn();
		//testgdlt();
		
		//testaldy();
		//testaldyII();
		//testaldyIII();
		//testaldyIV();
		//testaldyV();
		//testaldyVI();
		//testyt();
		
		//testmyrp();
		//testnull();
		//testmatch();
		//testyimei();
		//testyimeiII();
		//testdxgf();
		testapi();
		
		//testmopin();
		//test21cn();
		//test21cnII();
		//test21cnIII();
		
		//testjiaxun();
		//testjiaxunII();
		//testjiaxunIII();
		//testjsonVV();
		//testmd5vv();
		//testweicheng();
		//testmd5vs();
		
		//testreturn();
		
		//testrd();
		
		//lanbiaostatus();
		
		//testweinaier();
		
		//testjutongda();
		
		//testjunbo();
		
		//testapi();
		
		//testpost();
		
		//testjiaxunIII();
		
		//testjiaxun4();
	}
	
	private static void testjiaxun4(){
		String url = "http://120.24.156.98:9302/ll_sendbuf/myreturn2.jsp";
		//String json = "{\"id\":634678,\"method\":\"status\",\"params\":{\"routeid\":\"1043\",\"ids\":\"1608011630000120410\"}}";
		String routeid = "3051";
		String array = "{\"Code\":\"0\",\"Message\":\"OK\",\"Reports\":[{\"TaskID\":25534973,\"Mobile\":\"13331103307\",\"Status\":5,\"ReportTime\":\"2016-10-29 15:41:24\",\"ReportCode\":\"5：5：2011：2011\",\"OutTradeNo\":\"\"}]}";
		JSONObject obj = new JSONObject();
		obj.put("routeid", routeid);
		obj.put("array", array);
		String ret = HttpAccess.postJsonRequest(url, obj.toString(), "utf-8", "www");
		System.out.println("ret = " + ret);
	}

	private static void testpost() {
		String url = "http://nb.189.cn/portal/open/exchangeCoinResult.do?sign=A913AA5CC959B624B1AF18ECC6326F30&appId=8013818507&paras=CDBAE1D88FC6B6FAE643F973C65BFCD9C320FCF14F946F2F&format=html&version=v1.0&clientType=2&orderId=201610091344351349792";
		System.out.println(HttpAccess.postNameValuePairRequest(url, new HashMap<String, String>(), "utf-8", "www"));
	}

	private static String sign (String key, String timestamp, String account) {
	    String[] arr = new String[]{key, timestamp, account };
	    Arrays.sort(arr);
	    StringBuilder content = new StringBuilder();
	    for (int i = 0; i < arr.length; i++) {
	        content.append(arr[i]);
	    }
	    String signature = null;
	    try {
	        MessageDigest md = MessageDigest.getInstance("SHA-1");
	        byte[] digest = md.digest(content.toString().getBytes("utf-8"));
	        signature =toHexString(digest);
	    } catch (NoSuchAlgorithmException e) {
	        e.printStackTrace();
	    } catch (UnsupportedEncodingException e) {
	        e.printStackTrace();
	    }
	    return signature;
	}
	public static final char HEX_DIGITS[] = {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9',
	    'a', 'b', 'c', 'd', 'e', 'f'};
	public static String toHexString(byte[] bytes) {
	    StringBuilder sb = new StringBuilder(bytes.length * 2);
	    for (int i = 0; i < bytes.length; i++) {
	        sb.append(HEX_DIGITS[(bytes[i] & 0xf0) >>> 4]);
	        sb.append(HEX_DIGITS[bytes[i] & 0x0f]);
	    }
	    return sb.toString();
	}
	
	private static void testys() {
		String key="c10721daa33e45f49e586654e2056435";
		String account="gzdy";
		String timestamp = TimeUtils.getTimeStamp();
		String nonce = MyBase64.base64Encode(account+","+timestamp);
		String signature = sign(key, timestamp, account);
		
		HashMap<String, String> params = new HashMap<String, String>();
		params.put("nonce", nonce);
		params.put("signature", signature);
		System.out.println(HttpAccess.getNameValuePairRequest("http://120.24.209.153/client-api/api/v3/query/orderNo/A1609071407209056770",
				params, "utf-8", "www"));
	}


	private static void testjunbo() {
		System.out.println(System.getProperty("user.dir"));
		System.out.println(System.getProperty("java.library.path"));
	}

	private static void testjutongda() {
		String username = "dyxx";
		String appId = "2";
		String appSecret = "a123b83cd1498c817d9918e1a144d2b8";
		String url = "http://sms.weiyingjia.cn:8080/ytx/data/getProductAll2.jsp";
		
		
		String transId = "008002";
		
		String sign = MD5Util.getLowerMD5(transId + appSecret);
		System.out.println("sign = " + sign);
		
		
		
		String params = "?" + "username=" + username + "&transId=" + transId + "&appId=" + appId + "&sign=" + sign;
		url = url + params;
		String ret = HttpAccess.postNameValuePairRequest(url, new HashMap<String, String>(), "utf-8", "www");
		System.out.println("ret = " + ret);
	}


	private static void testweinaier() {
		String url = "http://202.102.72.8:8890/flow/submit.aspx" ;
		String account = "danyuankeji";
		String password = "A6DFADB21DB2B5679067E2F5BAD8CFFA";
		String callbackURL = "http://120.24.156.98:9302/ll_sendbuf/weinaierreturn.jsp";
		String sign = "E9778B6BC0DA7939DBAD4A01B298FB9";
		
		
		String orderno = "16012455537";
		String timestamp = TimeUtils.getTimeStamp();
		String flow = "10";
		String mobile = "15017556283";
		
		sign = MD5Util.getLowerMD5(account + password + sign + timestamp + orderno + mobile + flow);
		
		url = url + "?orderno=" + orderno + "&account=" + account 
				+ "&password=" + password + "&timestamp=" + timestamp 
				+ "&flow=" + flow + "&Mobile=" + mobile 
				 + "&sign=" + sign + "&callbackURL=";
		
		try {
			url = url + URLEncoder.encode(callbackURL, "GBK");
		} catch (UnsupportedEncodingException e) {
			e.printStackTrace();
		}
		
		String ret = HttpAccess.postNameValuePairRequest(url, new HashMap<String, String>(), "utf-8", "www");
		
		System.out.println("ret = " + ret + ", url = " + url);
	}


	private static void lanbiaostatus() {
		String orderid = "1608262002332843200";
		String code = "0";
		String message = "success";
		String linkid = "8000256933903482";
		String xml = "<root><status taskid=\"" 
					+ orderid
					+ "\" code=\"" 
					+ code
					+ "\" message=\"" 
					+ message 
					+ "\" time=\"" 
					+ TimeUtils.getTimeString() 
					+ "\" linkid=\"" 
					+ linkid
					+ "\"/></root>";
		
		String url = "http://120.24.156.98:9302/ll_sendbuf/lanbiaoreturn.jsp";
		String ret = HttpAccess.postXmlRequest(url, xml, "utf-8", "www");
		System.out.println("ret = " + ret);
	}


	private static void testrd() {
		String rd = "00000" + new Random().nextInt(100000);
		rd = rd.substring(rd.length() - 5);
		String uuid = TimeUtils.getTimeStamp() + (158 % 100) + rd;
		System.out.println("uuid = " + uuid);
	}


	private static void testmd5vs() {
		//md5(seqid + md5(password))
		String password = "123456";
		String seqid = "160615134758000001";
		System.out.println("md5 = " + MD5Util.getLowerMD5(seqid + MD5Util.getLowerMD5(password)));
	}


	private static void test21cnIII() {
		WebClient webClient = new WebClient(BrowserVersion.CHROME);
		webClient.getOptions().setJavaScriptEnabled(true);
		webClient.getOptions().setCssEnabled(false);
		webClient.getOptions().setThrowExceptionOnScriptError(false);
        HtmlPage page = null;
        HtmlPage pageResponse = null;

        try
        {
        	/*
            WebRequest request = new WebRequest(new URL("http://yun.mchuan.com/doc/liucool_flow"));
            webClient.setAjaxController(ajaxController);
            webClient.waitForBackgroundJavaScript(10000);
            page = webClient.getPage(request);
            ajaxController.processSynchron(page, request, true);
			*/
        	page = webClient.getPage("http://www.baidu.com/");
        	//page = webClient.getPage("http://nb.189.cn/ticketRecharge/jumpTicketInfoWap.do?appId=flow&clientType=9&format=json&version=v1.1&paras=4CBF30BB59758E696B38B17053070C1437CFEA17255278D62B4B03FD532E5F9B6FB350A0122AF0AAF0E30C1618CE7C3BE43A66EAADF861396D465109E83A457CA9074CA801155EF5E86117F4FAA8C71A&sign=BD013F89543AFFA69235EFF7DD74389F175F4956");
        }
        catch(IOException e)
        {
            e.printStackTrace();
        }
        /*
        HtmlForm form = page.getFormByName("f");
        HtmlTextInput kw = form.getInputByName("wd");
        kw.setText("小时代");
        HtmlSubmitInput formSubmit = form.getInputByValue("百度一下");
        */
        DomElement link = page.getElementById("denglu");
        //page.getHtmlElementById(elementId)
       // page.get
        //HtmlSubmitInput formSubmit = page.getElementById("denglu");
        try
        {
            pageResponse = link.click();
        }
        catch(IOException e)
        {
            System.out.println("Form Button" + e.getMessage());
        }
        
        webClient.close();
        
        System.out.println(pageResponse.asXml());
    }


	private static void test21cnII() {
		String str = "4CBF30BB59758E696B38B17053070C1437CFEA17255278D62B4B03FD532E5F9B6FB350A0122AF0AAF0E30C1618CE7C3BE43A66EAADF861396D465109E83A457CA9074CA801155EF5E86117F4FAA8C71A";
		byte[] rstr = rstr(str);
		String abc = "";
		try {
			abc = new String(rstr);
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		System.out.println(abc);
		
		HashMap<String, String> ttt = new HashMap<String, String>();
		ttt.put("abc", "xyz");
		System.out.println(com._21cn.open.openapi.common.PartnerAESUtil.genAESParasData(ttt, "www"));
	}
	
	public static byte[] rstr(String hex){
		int length = hex.length();
		byte[] bHex = new byte[length/2];
		String temp = null;
		int t = 0;
		for (int i=0; i<length; i++) {
			temp = "" + hex.charAt(i) + hex.charAt(++i);
			bHex[t++] = (byte)Integer.parseInt(temp, 16);
		}
		return bHex;
	}


	private static void testweicheng() {
		
		String taskid = "20160803";
		String phone = "15017556283";
		String packagecode = "10";
		
		
		String app_secret = "9bf7ca73e21c9b4e8c66795dd5ab5f02";
		
		
		String url = "http://120.24.173.64:7001/index.do?action=api_order_traffic_submit&";
		String app_key = "441771";
		String order_agent_bill = taskid;
		String timestamp = String.valueOf(System.currentTimeMillis());
		String order_agent_id = "7012605554";
		String app_sign = MD5Util.getUpperMD5(app_key + app_secret + order_agent_id + timestamp+ order_agent_bill);
		
		String order_agent_back_url = "http://120.24.173.64:7001/index.do";
		String order_tel = phone;
		String traffic_size = packagecode;
		
		String str = "app_key=" + app_key + "&order_agent_bill=" + order_agent_bill + "&timestamp="
			 + timestamp + "&order_agent_id=" + order_agent_id + "&app_sign=" + app_sign + "&order_agent_back_url="
			  + enc(order_agent_back_url) + "&order_tel=" + order_tel + "&traffic_size=" + traffic_size;
	
		url = url + str;
		
		String ret = HttpAccess.postEntity(url, "", "", "utf-8", "www");
		System.out.println("ret = " + ret + ", url = " + url);
	}
	
	private static String enc(String str){
		String ret = "";
		try {
			ret = URLEncoder.encode(str, "utf-8");
		} catch (Exception e) {
		}
		return ret;
	}


	private static void test21cn() {
		String clientId = "8013818507" ;  //这里改成你们应用的appKey
		String clientIp = "120.24.156.98";//这里要改成你们的IP
		String clientType = "10010";//10020代表PC客户端（具体各不同类型详见文档说明中的“客户端类型”）
		long t = System.currentTimeMillis();
		String timeStamp = String.valueOf(t);//时间戳
		String secret =  "yLmrAVi8kny8VFTI3NpeUpcHthODinNU" ;//综合平台颁发给你们应用的密钥 
		String version = "1.5" ; //你们的版本号
		
		String url = "https://open.e.189.cn/api/oauth2/llb/grantTicket.do";
		
		//String interfaceUrl = "https://open.e.189.cn/api/oauth2/llb/grantCoin.do";

		
		Map<String,String> requestData = new HashMap<String,String>();
		try {
			//将入参放入map中
			requestData.put("clientId", clientId);
			requestData.put("clientIp", clientIp);
			requestData.put("clientType",clientType );
			requestData.put("timeStamp", timeStamp);			
			requestData.put("version",version );
			//私有请求参数
			requestData.put("taskId", "100004707");
			requestData.put("mobile", "18924231943");
			
			requestData.put("ticketTypeId", "");
			requestData.put("counts", "1");
			
			String rd = "00000" + new Random().nextInt(100000);
			String uuid = TimeUtils.getTimeStamp() + (t % 100) + rd.substring(rd.length() - 5);
			requestData.put("uuid", uuid);

			System.out.println("uuid = " + uuid);
			//此处要对map中的元素进行按key升序排序
			OauthRequestUtil.initComParam(requestData, clientId , version);
			
			//根据文档说明要对请求参数进行加密处理再调用接口
			//result就是调用后的结果
			String result =OauthRequestUtil.signPostOpenAPIServer(url, requestData, secret);
			System.err.println(result);
		} catch (Exception e) {
			e.printStackTrace();
		}
	}
	

	public static String md5Util(String paramStr)
    {
        char hexDigits[] = { '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F' };
        try
        {
            byte[] btInput = paramStr.getBytes();
            // 获得MD5摘要算法的 MessageDigest 对象
            MessageDigest mdInst = MessageDigest.getInstance("MD5");
            // 使用指定的字节更新摘要
            mdInst.update(btInput);
            // 获得密文
            byte[] md = mdInst.digest();
            // 把密文转换成十六进制的字符串形式
            int j = md.length;
            char str[] = new char[j * 2];
            int k = 0;
            for (int i = 0; i < j; i++)
            {
                byte byte0 = md[i];
                str[k++] = hexDigits[byte0 >>> 4 & 0xf];
                str[k++] = hexDigits[byte0 & 0xf];
            }
            String sign = new String(str);
            logger.info("genSign:" + sign);
            return sign;
        }
        catch (Exception e)
        {
            e.printStackTrace();
            return "";
        }
    }
	
	private static void testmd5vv() {
		System.out.println(md5Util("264"));
		System.out.println(MD5Util.getUpperMD5("264"));
	}

	private static void testjiaxunIII() {
		String url = "http://120.24.156.98:9302/ll_sendbuf/request.jsp";
		//String json = "{\"id\":634678,\"method\":\"status\",\"params\":{\"routeid\":\"1043\",\"ids\":\"1608011630000120410\"}}";
		String json = "{\"id\":375266,\"method\":\"status\",\"params\":{\"routeid\":\"3049\",\"ids\":\"1610211212101673020,1610211112301627830,1610211212171673050,1610211237541677110,1610211212171673060,1610211112321627870,1610211112311627860,1610211112401627990,1610211112381627940,1610211112451628020\"}}";
		String ret = HttpAccess.postJsonRequest(url, json, "utf-8", "www");
		System.out.println("ret = " + ret);
	}

	private static void testjsonVV() {
		JSONObject obj = new JSONObject();
		obj.put("www", "yyyxxx");
		System.out.println("obj = " + obj.toString());
		
		String str = obj.toString();
		String key = "www";
		JSONObject newobj = JSONObject.fromObject(str);
		String value = newobj.getString(key);
		System.out.println("value = " + value);
	}

	private static void testjiaxunII() {
		String taskid = "1602120024590529180";
		
		String url = "http://124.172.160.225:39090";
		
		url = url + "/queryOrderInfo";
		
		String username = "username";
		String password = "password";
		String timestamp = TimeUtils.getTimeStamp();
		String echo = "dy" + new Random().nextInt(8888);
		String digest = MD5Util.getLowerMD5(username + MD5Util.getLowerMD5(password) + timestamp + echo);
		String month = "20" + taskid.substring(0, 4);
		String orderIds = taskid;
		
		HashMap<String, String> params = new LinkedHashMap<String, String>();
		params.put("username", username);
		params.put("password", password);
		params.put("timestamp", timestamp);
		params.put("echo", echo);
		params.put("digest", digest);
		params.put("month", month);
		params.put("orderIds", orderIds);
		
		String ret = HttpAccess.postNameValuePairRequest(url, params, "utf-8", "www");
		System.out.println("ret = " + ret);
	}

	private static void testjiaxun() {
		String taskid = "";
		String packagecode = "";
		String phone = "15017556283";
		
		String url = "";
		
		String username = "username";
		String password = "password";
		String timestamp = TimeUtils.getTimeStamp();
		String transId = taskid;
		String echo = "dy" + new Random().nextInt(8888);
		String digest = MD5Util.getLowerMD5(username + MD5Util.getLowerMD5(password)+ timestamp + echo);
		String flow = packagecode;
		String mobile = phone;
		String transType = "1";
		String effectType = "1";
		
		HashMap<String, String> params = new LinkedHashMap<String, String>();
		params.put("username", username);
		params.put("password", password);
		params.put("timestamp", timestamp);
		params.put("transId", transId);
		params.put("echo", echo);
		params.put("digest", digest);
		params.put("flow", flow);
		params.put("mobile", mobile);
		params.put("transType", transType);
		params.put("effectType", effectType);
		
		HttpAccess.postNameValuePairRequest(url, params, "utf-8", "www");
	}

	private static void testmopin() {
		String a = "";
		String d = null;
		String t = String.valueOf(System.currentTimeMillis());
		String s = null;
		String url = "";
		
		String cp_user = "a";
		String secert_key = "b";
		String digest = "c";
		
		ArrayList<String> orderstr = new ArrayList<String>();
		orderstr.add(cp_user);
		orderstr.add(secert_key);
		orderstr.add(digest);
		orderstr.add(t);
		Collections.sort(orderstr);
		
		s = orderstr.get(3) + orderstr.get(2) + orderstr.get(1) + orderstr.get(0); 
		
		s = SHA1.sha1Encode(s);
		
		

		String packageid = "yd.10M";
		
		int packagecode = 0;
		try{
			packageid = packageid.split("\\.")[1];
			String pkstr = packageid.substring(0, packageid.length() - 1);
			int pk = Integer.parseInt(pkstr);
			if(packageid.indexOf('G') >= 0){
				pk *= 1024;
			}
			packagecode = pk * 1024;
		} catch (Exception e) {
			logger.warn(e.getMessage(), 0);
		}
		String phone = "15017556283";
		String returnurl = "";
		
		String cpUser = cp_user;
		String taskid = "";
		String channelOrderId = taskid;
		String content = "";
		String createTime = "";
		int type = 1;
		int amount = packagecode;
		int range = 0;
		String mobile = phone;
		String notifyUrl = returnurl;
		
		JSONObject jo = new JSONObject();
		jo.put("cpUser", cpUser);
		jo.put("taskid", taskid);
		jo.put("channelOrderId", channelOrderId);
		jo.put("content", content);
		jo.put("createTime", createTime);
		jo.put("type", type);
		jo.put("amount", amount);
		jo.put("range", range);
		jo.put("mobile", mobile);
		jo.put("notifyUrl", notifyUrl);
		
		String vector = "";
		String aes = AES.aesEncode(jo.toString(), secert_key, vector);
		
		d = MD5Util.getLowerMD5(aes);
		url = url + "?a=" + a + "&d=" + d + "&t=" + t + "&s=" + s;
		
		String ret = HttpAccess.postEntity(url, aes, "", "utf-8", "www");
		System.out.println("ret = " + ret);
	}

	private static void testapi() {
		String userid = "10017";
		String password = "1";
		String sign = "1";
		sign = MD5Util.getLowerMD5(sign);
		long t = System.currentTimeMillis();
		//String seqid = new SimpleDateFormat("yyMMddHHmmss124000").format(t);
		String seqid = "161115103900";
		sign = MD5Util.getLowerMD5(seqid + sign);
		
		
		String action = "charge";
		String phone = "13587064961";
		String mbytes = "1024";
		String linkid = "20161209";
		
		HashMap<String, String> params = new HashMap<String, String>();
		params.put("userid", userid);
		params.put("password", password);
		//params.put("seqid", seqid);
		
		//System.out.println("seqid = " + seqid);
		
		//params.put("sign", sign);
		params.put("linkid", linkid);
		params.put("action", action);
		params.put("phone", phone);
		params.put("mbytes", mbytes);
		
		String url = "http://192.168.2.14:9681/lcll/xml/api.jsp";
		String ret = HttpAccess.postNameValuePairRequest(url, params, "utf-8", "czx");
		
		System.out.println("ret = " + ret);
	}

	private static void testdxgf() {
		String packagecode = null;
		String packageid = "dx.5M";
		try{
			packageid = packageid.split("\\.")[1];
		} catch (Exception e) {
			logger.warn(e.getMessage(), 0);
		}
		
		if(packageid.equals("5M")){
			packagecode = "104365";
		}else if(packageid.equals("10M")){
			packagecode = "104366";
		}else if(packageid.equals("30M")){
			packagecode = "104367";
		}else if(packageid.equals("50M")){
			packagecode = "104368";
		}else if(packageid.equals("100M")){
			packagecode = "104369";
		}else if(packageid.equals("200M")){
			packagecode = "104370";
		}else if(packageid.equals("500M")){
			packagecode = "104371";
		}else if(packageid.equals("1G")){
			packagecode = "104372";
		}
		
		if(packagecode == null){
			logger.error("unrecognized package");
		}
		
		String url = "http://api.800.21cn.com/fps/flowService.do";
		String service_code="FS0001";
		String 	contract_id="101620";
		String 	activity_id="103575";
		String 	order_type="1";
		String 	effect_type="0";
		String partner_no="102036305";
		String aespassword="pMSvcwZMQIgZTK5O";
		String aesvector="6679306121781605";
		
		String phone = "18924231943";
		JSONObject jsonParam = new JSONObject();  
		jsonParam.put("request_no", "123781962339");
		jsonParam.put("service_code", service_code);
		jsonParam.put("contract_id", contract_id);
		jsonParam.put("activity_id", activity_id);
		jsonParam.put("phone_id", phone);
		jsonParam.put("order_type", order_type);
		jsonParam.put("plat_offer_id", packagecode);
		jsonParam.put("effect_type", effect_type);

		String param = AES.aesEncode(jsonParam.toString(), aespassword, aesvector);
		
		JSONObject json = new JSONObject();
		json.put("partner_no", partner_no);
		json.put("code", param);
		
		logger.info("dianxingufen send json = " + json.toString());
		
		//在执行请求前先获取连接, 防止访问通道线程超量
		String ret = null;
		try {
			//ret = HttpAccess.postNameValuePairRequest(url, params, "utf-8", "mysend");
			ret = HttpAccess.postJsonRequest(url, json.toString(), "utf-8", "dianxingufen");
		} catch (Exception e) {
			// TODO: handle exception
		}
		System.out.println("ret = " + ret);
	}

	private static void testyimeiII() {
		String str = "{\"failCount\":0,\"errorlist\":[],\"batchNo\":\"1606011607131141230\",\"successCount\":1}";
		/*
		JSONObject jsonobj = null;
		try{
			jsonobj = JSONObject.fromObject(str);
		} catch (Exception e) {
			logger.warn(e.getMessage(), e);
			return;
		}

		String taskid = jsonobj.getString("batchNo");
		JSONArray ary = null;
		
		try{
			ary = jsonobj.getJSONArray("errorlist");
		} catch (Exception e) {
			logger.warn(e.getMessage(), e);
		}
		
		String mark = "yimei";
		String status = "1";
		String info = "成功";
		if(ary == null || ary.size() <= 0){
			status = "0";
		}else{
			try{
				info = ary.getJSONObject(0).getString("message");
			} catch (Exception e) {
				e.printStackTrace();
				info = "失败";
				logger.warn(e.getMessage(), e);
			}
		}
		
		System.out.println("status = " + status + ", info = " + info);
		*/
		Map<String, String> params = new HashMap<String, String>();
		params.put("data", str);
		String ret = HttpAccess.postNameValuePairRequest("http://120.24.156.98:9302/ll_sendbuf/yimeireturn.jsp", params, "utf-8", "yimei");
		System.out.println("ret = " + ret);
	}

	private static void testyimei() {
		// 赠送流量接口
		String url = "http://123.57.210.65:80/outerservice/request";
		// 电话号码，最多50个，必选
		String mobiles = "15017556283";
		//批次唯一标识
		String taskNo = "20160527092359039002";
		// 移动套餐编号，根据提供套餐列表选择，必选
		String cmcc = "11";
		// 生肖类型：0-立即生效，1-下月生效，选填(默认立即生效)【我们会发送给运营商，但是不保证运营商受理】
		String etype = "0";
		// 分配给您的准入TOKEN，必选
		String token = "d91bed60f5374e9d";
		// 分配给您的准入APPID，必选
		String appId = "62e8ec22-fc97-492e-9b0d-85f25fe07c9c";

		StringBuffer buffer = new StringBuffer();
		buffer.append("mobiles=" + mobiles).append("&taskNo=" + taskNo).append("&cmcc=" + cmcc).append("&etype=" + etype);

		String code = buffer.toString();
		String key = MD5Util.getLowerMD5(code);
		
		String value = AES.ymAesEncrypt(code, token);
		
		Map<String, String> params = new HashMap<String, String>();
		params.put("key", key);
		params.put("value", value);
		params.put("appId", appId);
		
		String ret = HttpAccess.postNameValuePairRequest(url, params, "utf-8", "yimei");
		
/*
		HttpClient client = new HttpClient(10, 10, true);

		HttpRequestBody body;
		try {
			body = new HttpRequestBody(url, "UTF-8", HttpMethod.POST, null, null, params);
		} catch (HttpErrorException e) {
			//url is null
			e.printStackTrace();
			return;
		}

		HttpResponseBody res = client.service(body);

		if (res.isSuccess() && res.getCode() == 200) {
			String rs = res.getResultString();
			System.out.println(rs);
		}
*/
		System.out.println("key = " + key + ", value = " + value);
		System.out.println("ret = " + ret);
	}

	private static void testmatch() {
		String rPROVINCE = "0";
		
		int mPROVINCE = 56;
		
		if(mPROVINCE != 0 && !rPROVINCE.equals("0") && !String.valueOf(mPROVINCE).matches(rPROVINCE)){
			//不在所定的省份范围
			System.out.println("no");
		}else{
			System.out.println("yes");
		}
	}

	private static void testnull() {
		System.out.println("abc" + null);
	}

	private static void testmyrp() {
		String routeid = "1003";
		JSONObject obj = new JSONObject();
		String ret = "{\"Code\":\"0\",\"Message\":\"OK\",\"Reports\":[{\"TaskID\":3929526,\"Mobile\":\"15228168072\",\"Status\":4,\"ReportTime\":\"2016-05-09 12:03:03\",\"ReportCode\":\"4：4：4：：success\",\"OutTradeNo\":\"\"},{\"TaskID\":3930729,\"Mobile\":\"15808404002\",\"Status\":5,\"ReportTime\":\"2016-05-09 12:03:08\",\"ReportCode\":\"5：5：5：S:ERR:<html>\\r\\n<head><title>502 Bad Gateway</title></head>\\r\\n<body bgcolor=\\\"white\\\">\\r\\n<center><h1>502 Bad Gateway</h1></center>\\r\\n<hr><center>nginx</center>\\r\\n</body>\\r\\n</html>\\r\\n<!-- a padding to disable MSIE and Chrome friendly error page -->\\r\\n<!-- a padding to disable MSIE and Chrome friendly error page -->\\r\\n<!-- a padding to disable MSIE and Chrome friendly error page -->\\r\\n<!-- a padding to dis……\",\"OutTradeNo\":\"\"},{\"TaskID\":3930748,\"Mobile\":\"13540756578\",\"Status\":5,\"ReportTime\":\"2016-05-09 12:03:08\",\"ReportCode\":\"5：5：5：S:ERR:<html>\\r\\n<head><title>502 Bad Gateway</title></head>\\r\\n<body bgcolor=\\\"white\\\">\\r\\n<center><h1>502 Bad Gateway</h1></center>\\r\\n<hr><center>nginx</center>\\r\\n</body>\\r\\n</html>\\r\\n<!-- a padding to disable MSIE and Chrome friendly error page -->\\r\\n<!-- a padding to disable MSIE and Chrome friendly error page -->\\r\\n<!-- a padding to disable MSIE and Chrome friendly error page -->\\r\\n<!-- a padding to dis……\",\"OutTradeNo\":\"\"},{\"TaskID\":3930749,\"Mobile\":\"18728661216\",\"Status\":5,\"ReportTime\":\"2016-05-09 12:03:08\",\"ReportCode\":\"5：5：5：S:ERR:<html>\\r\\n<head><title>502 Bad Gateway</title></head>\\r\\n<body bgcolor=\\\"white\\\">\\r\\n<center><h1>502 Bad Gateway</h1></center>\\r\\n<hr><center>nginx</center>\\r\\n</body>\\r\\n</html>\\r\\n<!-- a padding to disable MSIE and Chrome friendly error page -->\\r\\n<!-- a padding to disable MSIE and Chrome friendly error page -->\\r\\n<!-- a padding to disable MSIE and Chrome friendly error page -->\\r\\n<!-- a padding to dis……\",\"OutTradeNo\":\"\"},{\"TaskID\":3930827,\"Mobile\":\"13808045442\",\"Status\":5,\"ReportTime\":\"2016-05-09 12:03:13\",\"ReportCode\":\"5：5：5：S:ERR:<html>\\r\\n<head><title>502 Bad Gateway</title></head>\\r\\n<body bgcolor=\\\"white\\\">\\r\\n<center><h1>502 Bad Gateway</h1></center>\\r\\n<hr><center>nginx</center>\\r\\n</body>\\r\\n</html>\\r\\n<!-- a padding to disable MSIE and Chrome friendly error page -->\\r\\n<!-- a padding to disable MSIE and Chrome friendly error page -->\\r\\n<!-- a padding to disable MSIE and Chrome friendly error page -->\\r\\n<!-- a padding to dis……\",\"OutTradeNo\":\"\"},{\"TaskID\":3930828,\"Mobile\":\"15082334371\",\"Status\":5,\"ReportTime\":\"2016-05-09 12:03:13\",\"ReportCode\":\"5：5：5：S:ERR:<html>\\r\\n<head><title>502 Bad Gateway</title></head>\\r\\n<body bgcolor=\\\"white\\\">\\r\\n<center><h1>502 Bad Gateway</h1></center>\\r\\n<hr><center>nginx</center>\\r\\n</body>\\r\\n</html>\\r\\n<!-- a padding to disable MSIE and Chrome friendly error page -->\\r\\n<!-- a padding to disable MSIE and Chrome friendly error page -->\\r\\n<!-- a padding to disable MSIE and Chrome friendly error page -->\\r\\n<!-- a padding to dis……\",\"OutTradeNo\":\"\"},{\"TaskID\":3930847,\"Mobile\":\"18227335447\",\"Status\":5,\"ReportTime\":\"2016-05-09 12:03:13\",\"ReportCode\":\"5：5：5：S:ERR:<html>\\r\\n<head><title>502 Bad Gateway</title></head>\\r\\n<body bgcolor=\\\"white\\\">\\r\\n<center><h1>502 Bad Gateway</h1></center>\\r\\n<hr><center>nginx</center>\\r\\n</body>\\r\\n</html>\\r\\n<!-- a padding to disable MSIE and Chrome friendly error page -->\\r\\n<!-- a padding to disable MSIE and Chrome friendly error page -->\\r\\n<!-- a padding to disable MSIE and Chrome friendly error page -->\\r\\n<!-- a padding to dis……\",\"OutTradeNo\":\"\"},{\"TaskID\":3930859,\"Mobile\":\"13708229430\",\"Status\":5,\"ReportTime\":\"2016-05-09 12:03:13\",\"ReportCode\":\"5：5：5：S:ERR:<html>\\r\\n<head><title>502 Bad Gateway</title></head>\\r\\n<body bgcolor=\\\"white\\\">\\r\\n<center><h1>502 Bad Gateway</h1></center>\\r\\n<hr><center>nginx</center>\\r\\n</body>\\r\\n</html>\\r\\n<!-- a padding to disable MSIE and Chrome friendly error page -->\\r\\n<!-- a padding to disable MSIE and Chrome friendly error page -->\\r\\n<!-- a padding to disable MSIE and Chrome friendly error page -->\\r\\n<!-- a padding to dis……\",\"OutTradeNo\":\"\"},{\"TaskID\":3930925,\"Mobile\":\"13882420509\",\"Status\":5,\"ReportTime\":\"2016-05-09 12:03:13\",\"ReportCode\":\"5：5：5：S:ERR:<html>\\r\\n<head><title>502 Bad Gateway</title></head>\\r\\n<body bgcolor=\\\"white\\\">\\r\\n<center><h1>502 Bad Gateway</h1></center>\\r\\n<hr><center>nginx</center>\\r\\n</body>\\r\\n</html>\\r\\n<!-- a padding to disable MSIE and Chrome friendly error page -->\\r\\n<!-- a padding to disable MSIE and Chrome friendly error page -->\\r\\n<!-- a padding to disable MSIE and Chrome friendly error page -->\\r\\n<!-- a padding to dis……\",\"OutTradeNo\":\"\"}]}";
		if (ret != null && ret.trim().length() > 0) {
			logger.info("my status ret = " + ret);
			try {
				JSONObject retjson = JSONObject.fromObject(ret);
				String code = retjson.getString("Code");
				String message = retjson.getString("Message");
				if(code.equals("0")){
					JSONArray array = retjson.getJSONArray("Reports");
					for(int i = 0; i < array.size(); i++){
						JSONObject sobj = array.getJSONObject(i);
						JSONObject vobj = JSONObject.fromObject(sobj.toString().replaceAll("\\\\u", "\\u"));
						if(sobj.getString("Status").equals("4")){
							//成功
							JSONObject rp = new JSONObject();
							rp.put("code", 0);
							rp.put("message", "success");
							rp.put("resp", vobj.getString("ReportCode"));
							obj.put(sobj.getString("TaskID"), rp);
						}else if(sobj.getString("Status").equals("5")){
							//失败
							JSONObject rp = new JSONObject();
							rp.put("code", 1);
							rp.put("message", "R." + routeid + ":" + vobj.getString("ReportCode") + "@" + TimeUtils.getSysLogTimeString());
							rp.put("resp", vobj.getString("ReportCode"));
							obj.put(sobj.getString("TaskID"), rp);
						}
					}
				}
				//request.setAttribute("orgreturn", ret);
			} catch (Exception e) {
				e.printStackTrace();
				//logger.info(e.getMessage());
				logger.info("result", "R." + routeid + ":" + e.getMessage() + "@" + TimeUtils.getSysLogTimeString());
				//request.setAttribute("result", "R." + routeid + ":" + e.getMessage() + "@" + TimeUtils.getSysLogTimeString());
			}
		} else {
			//request.setAttribute("result", "R." + routeid + ":fail@" + TimeUtils.getSysLogTimeString());
			logger.info("result", "R." + routeid + ":fail@" + TimeUtils.getSysLogTimeString());
		}
		System.out.println("json = " + obj.toString());
	}

	private static void testyt() {
		System.out.println(MD5Util.getUpperMD5("dyxx0907").substring(8, 24));
	}

	private static void testaldyVI() {
		String str = "{id=1604271427470004130, time=2016-04-27 14:27:54, phone=18187861727, status=4, flow=100, operator=中国电信, reason=10063:用户状态异常;10063}";
		int idx = str.indexOf("reason");
		if(idx >= 0){
			int v = str.indexOf("=", idx + 7);
			if(v < 0){
				v = str.indexOf("}", idx);
			}
			str = str.substring(idx + 7, v).trim();
			v = str.lastIndexOf(",");
			if(v >= 0){
				str = str.substring(0, v);
			}
		}
		System.out.println("str = " + str);
	}

	private static void testaldyV() {
		String str = "{id=3216549870004, time=2016-04-26 14:29:05, phone=15017556283, reason=null, status=3, flow=10, operator=中国移动}";
		int idx = str.indexOf("status");
		if(idx >= 0){
			str = str.substring(idx + 7, str.indexOf(",", idx)).trim();
		}
		System.out.println("str = " + str);
	}
	
	/*
	private static void testaldyIV() {
		String url = "http://gw.api.taobao.com/router/rest";
		String appkey = "23292235";
		String secret = "036cd33e03ee85d1a8429ed061b77be1";
		TaobaoClient client = new DefaultTaobaoClient(url, appkey, secret);
		AlibabaAliqinFcFlowGradeRequest req = new AlibabaAliqinFcFlowGradeRequest();
		AlibabaAliqinFcFlowGradeResponse rsp = null;
		try {
			rsp = client.execute(req);
		} catch (ApiException e) {
			e.printStackTrace();
		}
		if(rsp != null){
			System.out.println(rsp.getBody());
		}else{
			System.out.println("rsp is null");
		}
	}

*/
	private static void testaldyIII() {
		String url = "http://gw.api.taobao.com/router/rest";
		String appkey = "23292235";
		String secret = "036cd33e03ee85d1a8429ed061b77be1";
		TaobaoClient client = new DefaultTaobaoClient(url, appkey, secret);
		AlibabaAliqinFcFlowQueryRequest req = new AlibabaAliqinFcFlowQueryRequest();
		req.setOutId("3216549870004");
		AlibabaAliqinFcFlowQueryResponse rsp = null;
		try {
			rsp = client.execute(req);
		} catch (ApiException e) {
			e.printStackTrace();
		}
		if(rsp != null){
			System.out.println(rsp.getBody());
		}else{
			System.out.println("rsp is null");
		}
	}
/*
	private static void testaldyII() {
		String url = "http://gw.api.taobao.com/router/rest";
		String appkey = "23292235";
		String secret = "036cd33e03ee85d1a8429ed061b77be1";
		String channelid = "";
		TaobaoClient client = new DefaultTaobaoClient(url, appkey, secret);
		AlibabaAliqinFcFlowChargeRequest req = new AlibabaAliqinFcFlowChargeRequest();
		req.setPhoneNum("15017556283");
		req.setGrade("10");
		//req.setPhoneNum("18924231943");
		//req.setGrade("5");
		req.setOutRechargeId("3216549870004");
		AlibabaAliqinFcFlowChargeResponse rsp = null;
		try {
			rsp = client.execute(req);
		} catch (ApiException e) {
			e.printStackTrace();
		}
		if(rsp != null){
			System.out.println(rsp.getBody());
		}else{
			System.out.println("rsp is null");
		}
	}
	*/
/*
	private static void testaldy() {
		TmcClient client = new TmcClient("23292235", "036cd33e03ee85d1a8429ed061b77be1", "default"); // 关于default参考消息分组说明
		client.setMessageHandler(new MessageHandler() {
		    public void onMessage(Message message, MessageStatus status) {
		        try {
		            System.out.println(message.getContent());
		            System.out.println(message.getTopic());
		        } catch (Exception e) {
		            e.printStackTrace();
		            status.fail(); // 消息处理失败回滚，服务端需要重发
		        }
		    }
		});
		try {
			client.connect("ws://mc.api.taobao.com");
		} catch (LinkException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} // 消息环境地址：ws://mc.api.tbsandbox.com/
		mysleep(10000);
	}
*/
	private static void testhzyzt() {
		String url = "http://180.168.61.83:17880/mobileBBC/bbc/queryOrder.action";
		JSONObject json = new JSONObject();
		
		String merchId = "TEST_MER_DY";
		String orderId = "321654987004";
		String settleDate = TimeUtils.getTimeStamp();
		String key = "674DED38C6A1C69BB00024202B69F115";
		
		json.put("merchId", merchId);
		json.put("orderId", orderId);
		json.put("settleDate", settleDate);
		String sign = MD5Util.getUpperMD5(merchId + orderId + settleDate + key);
		json.put("sign", sign);
		
		Map<String, String> param = new HashMap<String, String>();
		param.put("json", json.toString());
		System.out.println("json = " + json.toString());
		
		String ret = null;
		try {
			ret = URLDecoder.decode(HttpAccess.postNameValuePairRequest(url, param, "utf-8", "www"), "utf-8");
		} catch (UnsupportedEncodingException e) {
			e.printStackTrace();
		}
		System.out.println("ret = " + ret);
	}

	private static void testhzy() {
		String url = "http://180.168.61.83:17880/mobileBBC/bbc/flowOrder.action";
		JSONObject json = new JSONObject();
		
		String merchId = "TEST_MER_DY";
		String orderId = "321654987004";
		String settleDate = TimeUtils.getTimeStamp();
		String phone = "18924231943";
		String parval = "30";
		String range = "1";
		String key = "674DED38C6A1C69BB00024202B69F115";
		
		json.put("merchId", merchId);
		json.put("orderId", orderId);
		json.put("settleDate", settleDate);
		json.put("phone", phone);
		json.put("parval", parval);
		json.put("range", range);
		String sign = MD5Util.getUpperMD5(merchId + orderId + settleDate + phone + parval + range + key);
		json.put("sign", sign);
		
		Map<String, String> param = new HashMap<String, String>();
		param.put("json", json.toString());
		System.out.println("json = " + json.toString());
		
		String ret = null;
		try {
			ret = URLDecoder.decode(HttpAccess.postNameValuePairRequest(url, param, "utf-8", "www"), "utf-8");
		} catch (UnsupportedEncodingException e) {
			e.printStackTrace();
		}
		System.out.println("ret = " + ret);
	}

	private static void teststr22() {
		String abc = "116.23.126.244";
		String str = "120.26.78.209|116.23.126.244";
		System.out.println("ret = " + (abc.matches(str)));
	}

	private static void testreturn() {
		StringBuffer sb = new StringBuffer();
		sb.append("<root>");
		sb.append("<status taskid=\"1603281036532657970\" linkid=\"635947582155780434222\" code=\"3\" message=\"success\" time=\"2016-03-28 13:43:12\" />");
		sb.append("</root>");
		System.out.println("xml = " + sb.toString());
		//String ret = HttpAccess.postXmlRequest("http://183.232.132.143:9912/api/gzxx/notify.html", sb.toString(), "utf-8", "www");
		String url = "http://llhy.sharera.net:8089/huayicc/notify";
		String ret = HttpAccess.postXmlRequest(url, sb.toString(), "utf-8", "www");
		System.out.println("ret = " + ret);
	}

	private static void testsubstr() {
		String str = "{error=false, errorCode=null, value=4, class=com.alicom.flow.domain.TopResultDO, errorMsg=10;充值失败}";
		int vdx = str.indexOf("errorMsg");
		int kdx = str.indexOf(", ", vdx);
		if(kdx < 0){
			kdx = str.indexOf('}', vdx);
		}
		String abc = str.substring(vdx + 9, kdx);
		System.out.println("abc = " + abc);
	}

	private static void testbase64() {
		String abc = MyBase64.base64Encode("abc");
		System.out.println("abc = " + abc);
	}

	private static void testmaiyi() {
		String url = "http://van.mye.hk/flowpack/query/123456789";
		String t = TimeUtils.getTimeStamp();
		String account = "dykj";
		String password = "dYi#k2Z";
		String nonce = MyBase64.base64Encode(account + ":" + t);
		String sign = MD5Util.getLowerMD5(account + password + t);
	}

	private static void testjsonIV() {
		String str = "{\"Code\":\"0\",\"Message\":\"OK\",\"Reports\":[{\"TaskID\":2406417,\"Mobile\":\"13161109832\",\"Status\":5,\"ReportTime\":\"2016-02-29 09:59:59\",\"ReportCode\":\"error：10032\\u53e0\\u52a0\\u4e0a\\u9650\",\"OutTradeNo\":\"\"}]}";
		try {
			JSONObject retjson = JSONObject.fromObject(str);
			String code = retjson.getString("Code");
			String message = retjson.getString("Message");
			if(code.equals("0")){
				JSONArray array = retjson.getJSONArray("Reports");
				for(int i = 0; i < array.size(); i++){
					JSONObject sobj = array.getJSONObject(i);
					JSONObject vobj = JSONObject.fromObject(sobj.toString().replaceAll("\\\\u", "\\u"));
					if(sobj.getString("Status").equals("4")){
						//成功
						JSONObject rp = new JSONObject();
						rp.put("code", 0);
						rp.put("message", "success");
						rp.put("resp", vobj.getString("ReportCode"));
						//obj.put(sobj.getString("TaskID"), rp);
					}else if(sobj.getString("Status").equals("5")){
						//失败
						JSONObject rp = new JSONObject();
						rp.put("code", 1);
						//rp.put("message", "R." + routeid + ":" + sobj.getString("ReportCode") + "@" + TimeUtils.getSysLogTimeString());
						rp.put("resp", vobj.getString("ReportCode"));
						//obj.put(sobj.getString("TaskID"), rp);
						System.out.println("rp = " + rp.toString());
					}
				}
			}
			//request.setAttribute("orgreturn", ret);
		} catch (Exception e) {
			e.printStackTrace();
			//logger.info(e.getMessage());
			//logger.info("result", "R." + routeid + ":" + e.getMessage() + "@" + TimeUtils.getSysLogTimeString());
			//request.setAttribute("result", "R." + routeid + ":" + e.getMessage() + "@" + TimeUtils.getSysLogTimeString());
		}
	}

	private static void testjsonIII() {
		String str = "{\"abc\":\"\\\\u53e0\\\\u52a0\\\\u4e0a\\\\u9650\"}";
		System.out.println("str1 = " + str);
		str = str.replaceAll("\\\\u", "\\u");
		System.out.println("str = " + str);
		JSONObject obj = JSONObject.fromObject(str);
		System.out.println("abc = " + obj.getString("abc"));
	}

	private static void testbyte() {
		byte[] bytearr = {
							(byte)0xc2, (byte)0xa8, (byte)0xc2, (byte)0xa8, (byte)0x3f, (byte)0x3f, (byte)0xc2, (byte)0xa8, 
							(byte)0xc2, (byte)0xa8, (byte)0x3f, (byte)0x3f, (byte)0x3f, (byte)0x3f, (byte)0x3f, (byte)0x3f, 
							(byte)0x3f, (byte)0xc2, (byte)0xa1, (byte)0xe6, (byte)0xbd, (byte)0xbf, (byte)0x3f, (byte)0x3f, 
							(byte)0x3f, (byte)0x3f
						 };
		String abc = "";
		String[] charset = {"ASCII", "ISO-8859-1", "GB2312", "GBK", "UTF-8", "UTF-16"};
		try {
			//ASCII、ISO-8859-1、GB2312、GBK、UTF-8、UTF-16
			for(int v = 0; v < 6; v++){
				for(int i = 0; i < 6; i++){
					for(int j = 0; j < 6; j++){
						abc = new String((new String(bytearr, charset[v])).getBytes(charset[i]), charset[j]);
						System.out.println("v abc = " + abc + ", v = " + charset[v] + ", i = " + charset[i] + ", j = " + charset[j]);
					}
				}
			}
			
			abc = new String(bytearr, "ASCII");
			System.out.println("abc = " + abc);
			abc = new String(bytearr, "ISO-8859-1");
			System.out.println("abc = " + abc);
			abc = new String(bytearr, "GB2312");
			System.out.println("abc = " + abc);
			abc = new String(bytearr, "GBK");
			System.out.println("abc = " + abc);
			abc = new String(bytearr, "UTF-8");
			System.out.println("abc = " + abc);
			abc = new String(bytearr, "UTF-16");
			System.out.println("abc = " + abc);
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	private static void testhh() {
		String url = "http://api.52mb.com:10052/index.php/Api/Recharge/index/type/json";
		
		String order_id = "1883664545454";
		String uname = "gzmc";
		
		String t = String.valueOf(System.currentTimeMillis());
		String timestamp = t.substring(0, t.length() - 3);
		
		System.out.println("timestamp = " + timestamp);
		
		String noncestr = t.substring(t.length() - 6);
		String mobile = "15017556283";
		String amount = "00010";
		
		String key = "ba9382004aec4edcd7a272f4fdb1a6f9";
		
		String signstr = "amount=" + amount + "&mobile=" + mobile + "&noncestr=" + noncestr + 
				"&order_id=" + order_id + "&timestamp=" + timestamp + "&uname=" + uname + "&key=" + key;
		System.out.println("signstr = " + signstr);
		String signature = SHA1.sha1Encode(signstr);
		
		JSONObject json = new JSONObject();
		json.put("order_id", order_id);
		json.put("uname", uname);
		json.put("timestamp", timestamp);
		json.put("noncestr", noncestr);
		json.put("mobile", mobile);
		json.put("amount", amount);
		json.put("signature", signature);
		
		String ret = HttpAccess.postJsonRequest(url, json.toString(), "utf-8", "www");
		
		json = JSONObject.fromObject(ret);
		
		System.out.println(json.getString("msg"));
		
		System.out.println("ret = " + ret);
	}
	
	public static String decodeUnicode(final String dataStr) {
		int start = 0;
		int end = 0;
		final StringBuffer buffer = new StringBuffer();
		while (start > -1) {
			end = dataStr.indexOf("\\u", start + 2);
			String charStr = "";
			if (end == -1) {
				charStr = dataStr.substring(start + 2, dataStr.length());
			} else {
				charStr = dataStr.substring(start + 2, end);
			}
			char letter = (char) Integer.parseInt(charStr, 16); // 16进制parse整形字符串。
			buffer.append(new Character(letter).toString());
			start = end;
		}
		return buffer.toString();
	}

	private static void testxml() {
		String xmlstr = "<?xml version=\"1.0\" encoding=\"utf-8\" ?><Response><Code>0</Code><SuccessCount>1</SuccessCount><FailCount>1</FailCount><ErrorMobiles>xxxxx, xxxxxx</ErrorMobiles><TransIDO>xxxxxxxxxxxx</TransIDO></Response>";
		try {
			Document doc = DocumentHelper.parseText(xmlstr);
			String code = doc.getRootElement().elementText("Code");
			System.out.println("code = " + code);
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	private static void testgdlt() {
		//String json = "{\"id\":46631,\"method\":\"status\",\"params\":{\"routeid\":\"2004\",\"ids\":\"201602191625330362865\"}}";
		String json = "{\"id\":604222,\"method\":\"status\",\"params\":{\"routeid\":\"3012\"}}";
		String url = "http://120.24.156.98:9302/ll_sendbuf/request.jsp";
		HttpAccess.postJsonRequest(url, json, "utf-8", "www");
	}

	private static void testjsonII() {
		String str = "{\"list\":[{\"msisdn\":\"15017556283\",\"product_id\":\"10001\",\"product_value\":\"10\"}]}";
		JSONObject obj = JSONObject.fromObject(str);
		System.out.println("json = " + obj.toString());
	}

	private static void testltkd() {
		//String url = "http://113.57.243.18/flowAgent";
		String url = "http://61.50.245.139/flowAgent";
		//String AppKey = "4aea47a6465e3de901465e68c8100000";
		String appSecret = "unicom";
		
		String action = "orderPkg";
		String appKey = "4aea47a6465e3de901465e68c8100000";
		String pkgNo = "002000";
		String phoneNo = "15622245832";
		String timeStamp = TimeUtils.getTimeStamp();
		
		
		StringBuffer sb = new StringBuffer();
		sb.append("action");
		sb.append(action);
		sb.append("appKey");
		sb.append(appKey);
		sb.append("phoneNo");
		sb.append(phoneNo);
		sb.append("pkgNo");
		sb.append(pkgNo);
		sb.append("timeStamp");
		sb.append(timeStamp);
		String sign = SHA1.sha1Encode(appSecret + sb.toString() + appSecret);
		
		System.out.println("sign = " + sign);
		
		Map<String, String> params = new HashMap<String, String>();
		params.put("action", action);
		params.put("appKey", appKey);
		params.put("phoneNo", phoneNo);
		params.put("pkgNo", pkgNo);
		params.put("timeStamp", timeStamp);
		params.put("sign", sign);
		
		String ret = HttpAccess.postNameValuePairRequest(url, params, "utf-8", "www");
		System.out.println("ret = " + ret);
	}

	private static void teststr() {
		String str = "abc=";
		int idx = str.indexOf('=');
		System.out.println("key = " + str.substring(0, idx) + ", value = " + str.substring(idx + 1, str.length()));
		String dd = str.substring(idx + 1, str.length());
		if(dd == null){
			System.out.println("dd is null");
		}else{
			System.out.println("dd is blank");
		}
	}

	private static void testtimesub() {
		String t = String.valueOf(System.currentTimeMillis());
		String str = t.substring(t.length() - 6);
		System.out.println("str = " + str);
	}

	private static void testsplit() {
		String packageid = "yd.10M";
		packageid = packageid.split("\\.")[1];
		packageid = packageid.substring(0, packageid.length() - 1);
		System.out.println("packageid = " + packageid);
	}

	private static void testrp() {
		String url = "http://210.75.5.247:46666/openapi/v2.0";
		//method=getTicket&portalID=LLH&portalType=Android&
		//transactionID=2014092211000065535&transType=1&signType=MD5abce$OO7&+-*22L
		
		LinkedHashMap<String, String> param = new LinkedHashMap<String, String>();
		param.put("portalType", "WWW");
		param.put("portalID", "001");
		param.put("transactionID", "1234567876543210");
		param.put("method", "companyFlowPkgHandsel");
		param.put("sequence", "WWW10501080520160217143600888888");
		param.put("company_code", "105010805");
		param.put("activity_code", "1001880893");
		param.put("oper_data_list", "{\"list\":[{\"msisdn\":\"13475416283\",\"product_id\":\"10001\",\"product_value\":\"10\"}]}");
		param.put("oper_time", "20160217143600");
		param.put("notify_url", "http://120.24.156.98:9302/ll_sendbuf/maiersireturn.jsp");
		//param.put("signType", "MD5");

		StringBuffer sb = new StringBuffer();
		sb.append("activity_code=1001880893&");
		sb.append("company_code=105010805&");
		sb.append("method=companyFlowPkgHandsel&");
		sb.append("notify_url=http://120.24.156.98:9302/ll_sendbuf/maiersireturn.jsp&");
		sb.append("oper_data_list={\"list\":[{\"msisdn\":\"13475416283\",\"product_id\":\"10001\",\"product_value\":\"10\"}]}&");
		sb.append("oper_time=20160217143600&");
		sb.append("portalID=001&");
		sb.append("portalType=WWW&");
		sb.append("sequence=WWW10501080520160217143600888888&");
		//sb.append("signType=MD5&");
		sb.append("transactionID=1234567876543210");
		
		//sb.append("B029AE4ECF812B1C0651FBB9228F65D4");
		
		//param.put("sign", MD5Util.getLowerMD5(sb.toString()));
		
		
		GenerateSignature gs = new GenerateSignature();
		String path = Key.keypath + "liulianghongbao/private.key";
		System.out.println("path = " + path);
		String sign = gs.sign(sb.toString(), path);
		
		System.out.println("sb = " + sb.toString());
		
		System.out.println("sign = " + sign);
		
		param.put("sign", sign);
		
		//sb2.append("&sign=");
		//sb2.append(sign);
		/*
		String taskid = "123456787654321012";
		String portaltype = "WWW";
		String portalid = "001";
		String company_code = "105010805";
		String activity_code = "abc";
		String returnurl = "http://120.24.156.98:9302/ll_sendbuf/maiersireturn.jsp";
		String phone = "13475416283";
		String packagecode = "10001";
		String packageid = "10";
		
		LinkedHashMap<String, String> param = new LinkedHashMap<String, String>();
		param.put("portalType", portaltype);
		param.put("portalID", portalid);
		param.put("transactionID", taskid);
		param.put("method", "companyFlowPkgHandsel");
		String t = String.valueOf(System.currentTimeMillis());
		String timestamp = TimeUtils.getTimeStamp();
		String sequence = portaltype + portalid + timestamp + t.substring(t.length() - 6);
		param.put("sequence", sequence);
		param.put("company_code", company_code);
		if(activity_code.length() > 0){
			param.put("activity_code", activity_code);
		}
		String oper_data_list = "{\"list\":[{\"msisdn\":\"" + phone + "\",\"product_id\":\"" + packagecode + "\",\"product_value\":\"" + packageid + "\"}]}";
		param.put("oper_data_list", oper_data_list);
		param.put("oper_time", timestamp);
		param.put("notify_url", returnurl);
		//param.put("signType", "MD5");

		StringBuffer sb = new StringBuffer();
		if(activity_code.length() > 0){
			sb.append("activity_code=");
			sb.append(activity_code);
			sb.append("&");
		}
		sb.append("company_code=");
		sb.append(company_code);
		sb.append("&method=companyFlowPkgHandsel");
		sb.append("&notify_url=");
		sb.append(returnurl);
		sb.append("&oper_data_list=");
		sb.append(oper_data_list);
		sb.append("&oper_time=");
		sb.append(timestamp);
		sb.append("&portalID=");
		sb.append(portalid);
		sb.append("&portalType=");
		sb.append(portaltype);
		sb.append("&sequence=");
		sb.append(sequence);
		//sb.append("signType=MD5&");
		sb.append("&transactionID=");
		sb.append(taskid);
		
		//sb.append("B029AE4ECF812B1C0651FBB9228F65D4");
		
		//param.put("sign", MD5Util.getLowerMD5(sb.toString()));
		
		
		GenerateSignature gs = new GenerateSignature();
		String path = Key.keypath + "liulianghongbao/private.key";
		String sign = gs.sign(sb.toString(), path);
		//logger.info("sign string = " + sb.toString());
		System.out.println("sign string = " + sb.toString());
		System.out.println("sign = " + sign);
	
		param.put("sign", sign);
		*/
		//String ret = HttpAccess.postEntity(url, sb2.toString(), "application/x-www-form-urlencoded", "utf-8", "www");
		String ret = HttpAccess.postNameValuePairRequest(url, param, "application/x-www-form-urlencoded", "utf-8", "www");
		System.out.println("ret = " + ret);
		
		//System.out.println(getEncodeString("{\"list\":[{\"msisdn\":\"15017556283\",\"product_id\":\"10001\",”product_value”:”10”}]}"));
		//System.out.println(getEncodeString("http://120.24.156.98:9302/ll_sendbuf/maiersireturn.jsp"));
	}
	
	private static String getEncodeString(String org){
		String str = null;
		try {
			str = URLEncoder.encode(org, "utf-8");
		} catch (UnsupportedEncodingException e) {
			e.printStackTrace();
		}
		return str;
	}

	private static void testjson() {
		JSONObject obj = new JSONObject();
		testjsonv(obj);
		System.out.println("obj = " + obj.toString());
	}
	
	private static void testjsonv(JSONObject objv) {
		objv.put("abc", "www");
		System.out.println("objv = " + objv.toString());
	}

	private static void testmaiersistatusII() {
		String request = "{\"id\":897939,\"method\":\"status\",\"params\":{\"routeid\":\"1006\",\"ids\":\"80009949644261\"}}";
		String url = "http://120.24.156.98:9302/ll_sendbuf/request.jsp";
		String ret = HttpAccess.postJsonRequest(url, request, "utf-8", "rrr");
		System.out.println("ret = " + ret);
	}

	private static void testmaiersistatus() {
		String url = "http://120.24.156.98:9302/ll_sendbuf/maiersireturn.jsp";
		LinkedHashMap<String, String> param = new LinkedHashMap<String, String>();
		param.put("tradeNo", "123456879");
		param.put("result", "s");
		String ret = HttpAccess.postNameValuePairRequest(url, param, "utf-8", "vvv");
		System.out.println("ret = " + ret);
	}

	private static void testmaiersi() {
		String url = "http://182.92.181.48:9000/pf/api/1.0/account/balance";
		String account = "dyxx";
		String key = "873f6d0c27664265928709ae5c629d52";
		JSONObject json = new JSONObject();
		json.put("username", account);
		long t = System.currentTimeMillis();
		json.put("timestamp", t);
		json.put("signature", MD5Util.getLowerMD5(String.valueOf(t) + key));
		String ret = HttpAccess.postJsonRequest(url, json.toString(), "utf-8", "www");
		System.out.println("ret = " + ret);
	}

	private static void testsharp() {
		String str = "abc#xyz";
		String[] ww = str.split("#");
		for(int i = 0; i < ww.length; i++){
			System.out.println(ww[i]);
		}
	}

	private static void testwangsu() {
		String url = "https://capi.fdn.chinanetcenter.com/user/queryOrder";
		String key = "541658954d584beeb6434ed30711e42f0cfdccab94d54e688f7ee50da9295";
		JSONObject json = new JSONObject();
		json.put("phone", "15017556283");
		json.put("cpOrderNos", "YD_e526aa86940340a6b95c747cace290");
		json.put("cpUserName", "mingchuan");
		json.put("timestamp", TimeUtils.getTimeStamp());
		json.put("transNo", "123456789789");
		
		LinkedHashMap<String, String> header = new LinkedHashMap<String, String>();
		header.put("X-FDN-Auth", MD5Util.getLowerMD5(json.toString() + key));
		String ret = HttpAccess.postJsonRequest(url, json.toString(), "utf-8", header, "www");
		System.out.println("ret = " + ret);
	}

	private static void testRequest() {
		String str = "{\"id\":893614,\"method\":\"charge\",\"params\":{\"phone\":\"13928935507\",\"routeid\":\"2024\",\"taskid\":\"1601251126130000050\",\"package\":\"yd.30M\"}}";
		
		String ret = HttpAccess.postJsonRequest("http://120.24.156.98:9302/ll_sendbuf/request.jsp", str, "utf-8", "www");
		
		//String jsstr = "{\"id\":849907,\"method\":\"charge\",\"params\":{\"phone\":\"18676777287\",\"routeid\":\"9001\",\"taskid\":\"1601131733300100570\",\"package\":\"lt.20M\"}}";
		//String ret = HttpAccess.postJsonRequest("http://127.0.0.1/ll_sendbuf/request.jsp", jsstr, "utf-8", "www");
		
		System.out.println("ret = " + ret);
	}

	private static void testequal() {
		String str = "appkey=23292235";
		int idx = str.indexOf('=');
		System.out.println("key = " + str.substring(0, idx));
		System.out.println("value = " + str.substring(idx + 1, str.length()));
	}

	private static void testManyJsonRequest() {
		for(int i = 0; i < 20; i++){
			testJsonRequest();
		}
	}

	private static void teststatus() {
		JSONObject jo = new JSONObject();
		jo.put("method", "status");
		JSONObject params = new JSONObject();
		
		params.put("ids", "123486321");
		params.put("routeid", "1001");
		jo.put("params", params);
		jo.put("id", 0);
		
		String ret = HttpAccess.postJsonRequest("http://127.0.0.1/ll_sendbuf/request.jsp", jo.toString(), "utf-8", "www");
		
		System.out.println("ret = " + ret);
	}

	private static void testresult() {
		String ret = "{\"alibaba_aliqin_flow_wallet_charge_response\":{\"charge\":\"{error=false, errorCode=null, value=true, class=com.alicom.flow.domain.TopResultDO, errorMsg=null}\",\"request_id\":\"ish1y2glgdxd\"}}";
		JSONObject retjson = JSONObject.fromObject(ret);
		if(retjson.get("alibaba_aliqin_flow_wallet_charge_response") != null){
			String retstr = retjson.getJSONObject("alibaba_aliqin_flow_wallet_charge_response").get("charge").toString();
			if(retstr.trim().equals("true")){
				//request.setAttribute("result", "success");
				System.out.println("retstr is true");
			}else{
				System.out.println("alidayu charge = " + retstr);
				int idx = retstr.indexOf("error") + 6;
				String error = retstr.substring(idx, retstr.indexOf(",", idx));
				if(error.equals("false")){
					System.out.println("error is false");
				}else{
					//String info = JSONObject.fromObject(retstr).get("errorMsg").toString();
					String info = retstr.substring(retstr.indexOf("errorMsg") + 9, retstr.lastIndexOf("}"));
					//request.setAttribute("result", "R." + ing_routeid + ":" + info + "@" + TimeUtils.getSysLogTimeString());
					System.out.println("info = " + info);
				}
			}
		}
	}

	private static void testali() {
		TaobaoClient client = new DefaultTaobaoClient("http://gw.api.taobao.com/router/rest", "23292235", "036cd33e03ee85d1a8429ed061b77be1");
		AlibabaAliqinFlowWalletQueryChargeRequest request = new AlibabaAliqinFlowWalletQueryChargeRequest();
		request.setChannelId("0000049_DYKJ_F3E3F5E9542F7EB0");
		request.setOutRechargeId("15017556283");
		AlibabaAliqinFlowWalletQueryChargeResponse response = null;
		try {
			response = client.execute(request, "6101407c73af9171a3f00c3fcaa10084d5510b47a67e96f1794374007");
		} catch (ApiException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		System.out.println(response.getBody());
	}

	private static void testmap() {
		HashMap<Long, Integer> count = new HashMap<Long, Integer>();
		count.put(5L, 6);
		count.put(10L, 7);
		
		System.out.println(checkNum(count, 8L));
		System.out.println(checkNum(count, 10L));
		System.out.println(checkNum(count, 5L));
		
		for(Entry<Long, Integer> entry : count.entrySet()){
			System.out.println("key = " + entry.getKey() + ", value = " + entry.getValue());
		}
	}
	
	private static boolean checkNum(HashMap<Long, Integer> count, Long num){
		if(count.get(num) == null){
			count.put(num, 1);
		}else if(count.get(num) < 7){
			count.put(num, count.get(num) + 1);
		}else{
			return false;
		}
		return true;
	}

	private static void testString() {
		String abc = "abc\r\ndef\nopq\rxyz";
		String[] as = abc.split("\r");
		String[] bs = abc.split("\n");
		String[] cs = abc.split("\r\n");
		printstr(as);
		printstr(bs);
		printstr(cs);
		
		abc = abc.replace("\r", "\n");
		abc = abc.replace("\n\n", "\n");
		String[] ds = abc.split("\n");
		printstr(ds);
	}

	private static void printstr(String[] as) {
		System.out.println("out print strings");
		for(int i = 0; i < as.length; i++){
			System.out.println("#" + as[i]);
		}
		System.out.println("out print strings over");
	}

	private static void testJsonRequest() {
		JSONObject jo = new JSONObject();
		jo.put("method", "charge");
		JSONObject params = new JSONObject();
		
		params.put("taskid", 123456789 + new Random().nextInt(1000000));
		params.put("routeid", "9001");
		params.put("phone", 15017556283L + new Random().nextInt(1000000));
		params.put("package", "dx.30M");
		jo.put("params", params);
		jo.put("id", 0);
		
		System.out.println("json = " + jo.toString());
		
		String ret = HttpAccess.postJsonRequest("http://127.0.0.1/ll_sendbuf/request.jsp", jo.toString(), "utf-8", "www");
		
		//String jsstr = "{\"id\":849907,\"method\":\"charge\",\"params\":{\"phone\":\"18676777287\",\"routeid\":\"9001\",\"taskid\":\"1601131733300100570\",\"package\":\"lt.20M\"}}";
		//String ret = HttpAccess.postJsonRequest("http://127.0.0.1/ll_sendbuf/request.jsp", jsstr, "utf-8", "www");
		
		System.out.println("ret = " + ret);
	}
	
	private static void mysleep(long t){
		try {
			Thread.sleep(t);
		} catch (InterruptedException e) {
			e.printStackTrace();
		}
	}
	
}
