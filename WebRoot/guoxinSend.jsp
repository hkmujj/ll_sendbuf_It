<%@page import="org.apache.http.util.EntityUtils"%>
<%@page import="org.apache.http.HttpResponse"%>
<%@page import="org.apache.http.entity.StringEntity"%>
<%@page import="org.apache.http.client.methods.HttpPost"%>
<%@page import="org.apache.http.impl.client.DefaultHttpClient"%>
<%@page import="java.security.NoSuchAlgorithmException"%>
<%@page import="org.apache.commons.httpclient.methods.PostMethod"%>
<%@page import="org.apache.commons.httpclient.HttpClient"%>
<%@page import="com.alibaba.fastjson.JSON"%>
<%@page import="com.alibaba.fastjson.JSONObject"%>
<%@page import="java.io.IOException"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.security.MessageDigest"%>
<%@page import="java.io.InputStreamReader"%>
<%@page import="java.net.URLConnection"%>
<%@page import="java.net.URL"%>
<%@page import="java.io.BufferedReader"%>
<%@page import="cache.Cache"%>
<%@page import="util.TimeUtils"%>
<%@page import="org.apache.logging.log4j.LogManager"%>
<%@page import="org.apache.logging.log4j.Logger"%>
<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%
	boolean logflag = true;
	Logger logger = LogManager.getLogger();

	logger.info("guoxin entry1");

	//获取公共参数
	String taskid = request.getAttribute("taskid").toString();
	String routeid = request.getAttribute("routeid").toString();
	String phone = request.getAttribute("phone").toString();
	String packageid = request.getAttribute("package").toString();

	logger.info("guoxin entry2");

	Map<String, HashMap<String, String>> productMap = new HashMap<String, HashMap<String, String>>();
	HashMap<String, String> productLtMap = new HashMap<String, String>();
	productLtMap.put("20", "LTAL300020");
	productLtMap.put("50", "LTAL300050");
	productLtMap.put("100", "LTAL300100");
	productLtMap.put("200", "LTAL300200");
	productLtMap.put("500", "LTAL300500");
	productMap.put("lt", productLtMap);
	HashMap<String, String> productDxMap = new HashMap<String, String>();
	productDxMap.put("5", "DXAL100005");
	productDxMap.put("10", "DXAL100010");
	productDxMap.put("30", "DXAL100030");
	productDxMap.put("50", "DXAL100050");
	productDxMap.put("100", "DXAL100100");
	productDxMap.put("200", "DXAL100200");
	productDxMap.put("500", "DXAL100500");
	productDxMap.put("1024", "DXAL101024");
	productMap.put("dx", productDxMap);

	try{
		while(true){
			String ret = null;

			Map<String, String> routeparams = Cache.getRouteParams(routeid);
			if(routeparams == null){
				request.setAttribute("result", "S." + routeid + ":wrong routeparams@" + TimeUtils.getSysLogTimeString());
				break;
			}

			String url = routeparams.get("url");
			if(url == null){
				request.setAttribute("result", "S." + routeid + ":wrong routeparams, url is null@" + TimeUtils.getSysLogTimeString());
				break;
			}

			String APPKEY = routeparams.get("APPKEY");
			if(APPKEY == null){
				request.setAttribute("result", "S." + routeid + ":wrong routeparams, APPKEY  is null@" + TimeUtils.getSysLogTimeString());
				break;
			}

			String SECURITY_KEY = routeparams.get("SECURITY_KEY");
			if(SECURITY_KEY == null){
				request.setAttribute("result", "S." + routeid + ":wrong routeparams, SECURITY_KEY  is null@" + TimeUtils.getSysLogTimeString());
				break;
			}

			String resultTxt = "";

			String productId = "";
			String flow = "";
			//检查通道参数, 每个通道有不同参数, 对应 ll_routes.api_param
			String packagecodeArray[] = packageid.split("\\.");
			flow = packagecodeArray[1];
			if(flow.contains("G")){
				flow = Integer.parseInt(flow.substring(0, flow.length() - 1)) * 1024 + "M";
			}
			flow = flow.replace("M", "");
			if(packagecodeArray[0].equals("lt")){
				HashMap<String, String> proMap = productMap.get("lt");
				productId = proMap.get(flow);
			}else if(packagecodeArray[0].equals("dx")){
				HashMap<String, String> proMap = productMap.get("dx");
				productId = proMap.get(flow);
			}
			if(productId == null | ("").equals(productId)){
				request.setAttribute("result", "R." + routeid + ":没有对应产品@" + TimeUtils.getSysLogTimeString());
				return;
			}

			SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMddHHmmss");
			String time = sdf.format(new Date());
			String cstmOrderNo = time + (new Random()).nextInt(100000) + "";

			String paramsSort = "appkey" + APPKEY + "cstmOrderNo" + cstmOrderNo + "phoneNo" + phone + "productId" + productId + "timeStamp" + time;
			String sig = shaEncrypt(paramsSort + SECURITY_KEY);

			JSONObject jsb = new JSONObject();
			jsb.put("appkey", APPKEY);
			jsb.put("cstmOrderNo", cstmOrderNo);
			jsb.put("phoneNo", phone);
			jsb.put("productId", productId);
			jsb.put("sig", sig);
			jsb.put("timeStamp", time);

			/************************************/
			//request.setAttribute("result", "success");
			//break;
			/************************************/

			//在执行请求前先获取连接, 防止访问通道线程超量

			logger.info("guoxin entry2 Test01:");
			Cache.getConnection(routeid);
			try{
				DefaultHttpClient httpClient = new DefaultHttpClient();
				HttpPost method = new HttpPost(url + "/api/rest/1.0/order");
				StringEntity entity = new StringEntity(jsb.toJSONString(), "utf-8");
				entity.setContentEncoding("utf-8");
				entity.setContentType("application/json");
				method.setEntity(entity);

				HttpResponse result = httpClient.execute(method);
				/** 请求发送成功，并得到响应 **/
				if(result.getStatusLine().getStatusCode() == 200){
					try{
						/** 读取服务器返回过来的json字符串数据 **/
						resultTxt = EntityUtils.toString(result.getEntity(), "utf-8");
						/** 把json字符串转换成json对象 **/
						System.out.println(resultTxt);
					}catch(Exception e){
						e.printStackTrace();
					}
				}

			}catch(Exception e){
				e.printStackTrace();
				logger.info(e.getMessage());
			}finally{
				//在执行请求后记得释放连接
				Cache.releaseConnection(routeid);
			}
			logger.info("guoxin entry2 Test02:" + resultTxt);

			JSONObject jbn = JSON.parseObject(resultTxt);
			String code = jbn.getString("code");
			String msg = jbn.getString("msg");
			JSONObject dataJson = jbn.getJSONObject("data");
			if(code.equals("0000") & dataJson != null){
				request.setAttribute("result", "success");
				request.setAttribute("reportid", cstmOrderNo);
			}else{
				request.setAttribute("result", "R." + routeid + ":" + code + ":" + msg + "@" + TimeUtils.getSysLogTimeString());
			}
			request.setAttribute("orgreturn", code + ":" + msg);
			//JSONObject jbn = JSON.parseObject(result);
			//String status = jbn.getString("status");
			// msgid = jbn.getString("msgid");
			//String description = jbn.getString("description");

			break;

		}
	}catch(Exception e){
		e.printStackTrace();
		logger.info(e.toString());
		request.setAttribute("result", "R." + routeid + ":" + e.toString() + "@" + TimeUtils.getSysLogTimeString());
	}

	request.getRequestDispatcher("request.jsp").forward(request, response);
%>

<%!/**
	 * SHA加密
	 *
	 * @param inputStr
	 * @return
	 */
	public static String shaEncrypt(String inputStr){
		byte[] inputData = inputStr.getBytes();
		String returnString = "";
		try{
			inputData = encryptSHA(inputData);
			for(int i = 0; i < inputData.length; i++){
				returnString += byteToHexString(inputData[i]);
			}
		}catch(Exception e){
			e.printStackTrace();
		}
		return returnString;
	}

	/**
	 * SHA加密字节
	 *
	 * @param data
	 * @return
	 * @throws Exception
	 */
	public static byte[] encryptSHA(byte[] data) throws Exception{
		MessageDigest sha = MessageDigest.getInstance("SHA");
		sha.update(data);
		return sha.digest();
	}

	private static String byteToHexString(byte ib){
		char[] Digit = { '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'a', 'b', 'c', 'd', 'e', 'f' };
		char[] ob = new char[2];
		ob[0] = Digit[(ib >>> 4) & 0X0F];
		ob[1] = Digit[ib & 0X0F];

		String s = new String(ob);

		return s;
	}%>

