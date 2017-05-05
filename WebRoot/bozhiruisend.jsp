<%@page import="org.dom4j.DocumentHelper"%>
<%@page import="org.dom4j.Element"%>
<%@page import="org.dom4j.Document"%>
<%@page import="org.apache.http.HttpEntity"%>
<%@page import="org.apache.http.util.EntityUtils"%>
<%@page import="java.io.IOException"%>
<%@page import="org.apache.http.client.ClientProtocolException"%>
<%@page import="org.apache.http.HttpResponse"%>
<%@page import="org.apache.http.client.ResponseHandler"%>
<%@page import="org.apache.http.client.config.RequestConfig"%>
<%@page import="java.net.URLEncoder"%>
<%@page import="org.apache.http.impl.client.HttpClients"%>
<%@page import="java.util.Map.Entry"%>
<%@page import="org.apache.http.impl.client.CloseableHttpClient"%>
<%@page import="org.apache.http.client.methods.HttpGet"%>
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
<%!
		private static Logger logger = LogManager.getLogger(HttpAccess.class.getName());

	public static String getNameValuePairRequest(String url, Map<String, String> params, String encode, String mark){
		String bacTxt = null;
		HttpGet httpget = null;
		CloseableHttpClient httpclient = HttpClients.createDefault();
		try {
			String paramstr = "";
			try {
				for(Entry<String, String> entry : params.entrySet()){
					if(paramstr.length() > 0){
						paramstr = paramstr + "&";
					}
					paramstr = paramstr + entry.getKey() + "=" + URLEncoder.encode(entry.getValue(), encode);
				}
			} catch (Exception e) {
			}System.out.println(url + "?" + paramstr);
			httpget = new HttpGet(url  + "?" + paramstr);

			RequestConfig requestConfig = RequestConfig.custom().setSocketTimeout(90000).setConnectTimeout(5000).build();
			httpget.setConfig(requestConfig);

			//logger.info("get url = " + url + "?" + paramstr);

			//ResponseHandler<String> responseHandler = new VResponseHandler(mark);
			ResponseHandler<String> responseHandler = new MyResponseHandler(mark, "gbk");
			httpget.addHeader("Content-Type", "text/xml");

            bacTxt = httpclient.execute(httpget, responseHandler);

		} catch (Exception e) {
			StringBuffer sb = new StringBuffer();
			sb.append('[');
			sb.append(mark);
			sb.append("] Exception : ");
			sb.append(e.getMessage());
			logger.warn(sb.toString(), e);
		} finally {
			try {
				httpget.releaseConnection();
				httpclient.close();
			} catch (Exception e) {
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
	private static class MyResponseHandler implements ResponseHandler<String>{
		private String mark = null;
		private String enc = null;
		public MyResponseHandler(String str, String encstr){
			mark = str;
			enc = encstr;
		}
		@Override
		public String handleResponse(HttpResponse response) throws ClientProtocolException, IOException {
			 int status = response.getStatusLine().getStatusCode();
	         if (status >= 200 && status < 300){
	             HttpEntity entity = response.getEntity();
	             return entity !=null ? EntityUtils.toString(entity, enc) : null;
	         }else{
	        	 StringBuffer sb = new StringBuffer();
	        	 sb.append('[');
	        	 sb.append(mark);
	        	 sb.append("] unexpected response status : ");
	        	 sb.append(status);
	             throw new ClientProtocolException(sb.toString());
	         }
		}
		}%>
<%
	//准备参数
	boolean logflag = true;
	Logger logger = LogManager.getLogger();
	out.clearBuffer();
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
		String sellerId = routeparams.get("sellerId");
		if (sellerId == null) {
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, sellerId is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String password = routeparams.get("password");
		if (password == null) {
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, password is null@" + TimeUtils.getSysLogTimeString());
			break;
		}

		//参数准备, 每个通道不同
		String packagecode = null;
		if (packageid.indexOf("yd.") > -1) {
			try {
				packageid = packageid.split("\\.")[1];
			} catch (Exception e) {
				logger.warn(e.getMessage(), 0);
			}
			if (packageid.equals("2M")) {
				packagecode = "00002CMFA";
			} else if (packageid.equals("10M")) {
				packagecode = "10001CMFA";
			} else if (packageid.equals("30M")) {
				packagecode = "10002CMFA";
			} else if (packageid.equals("50M")) {
				packagecode = "1000050CMFA";
			} else if (packageid.equals("70M")) {
				packagecode = "10003CMFA";
			} else if (packageid.equals("100M")) {
				packagecode = "100100TMFA";
			} else if (packageid.equals("150M")) {
				packagecode = "10004CMFA";
			} else if (packageid.equals("200M")) {
				packagecode = "100200CMFA";
			} else if (packageid.equals("300M")) {
				packagecode = "100300TMFA";
			} else if (packageid.equals("500M")) {
				packagecode = "10005CMFA";
			} else if (packageid.equals("700M")) {
				packagecode = "00700CMFA";
			} else if (packageid.equals("1G")) {
				packagecode = "10006CMFA";
			} else if (packageid.equals("2G")) {
				packagecode = "10007CMFA";
			} else if (packageid.equals("3G")) {
				packagecode = "10008CMFA";
			} else if (packageid.equals("4G")) {
				packagecode = "10009CMFA";
			} else if (packageid.equals("6G")) {
				packagecode = "10010CMFA";
			} else if (packageid.equals("11G")) {
				packagecode = "10011CMFA";
			}
		}/*  else if (packageid.indexOf("lt.") > -1) {
			packagetype = "cucc";
			try {
				packageid = packageid.split("\\.")[1];
			} catch (Exception e) {
				logger.warn(e.getMessage(), 0);
			}
			if (packageid.equals("20M")) {
				packagecode = "24";
			} else if (packageid.equals("50M")) {
				packagecode = "9";
			} else if (packageid.equals("100M")) {
				packagecode = "25";
			}
		} */
		if (packagecode == null) {
			request.setAttribute("result", "S." + routeid + ":unrecognized package@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String bizType = "E_FLOW";
		String notifyUrl = "http://120.24.156.98:9302/ll_sendbuf/bozhiruireturn.jsp";
		String timeStmp = System.currentTimeMillis() + "";
		String unitPrice = "0";
		String signbef = "accountVal=" + phone + "&bizType=" + bizType + "&notifyUrl=" + notifyUrl + "&productNo=" + packagecode + "&sellerId=" + sellerId + "&tbOrderNo=" + taskid + "&timeStmp=" + timeStmp + "&unitPrice=" + unitPrice + "||" + password;
		logger.info("bozhirui signbef="+signbef);
		String sign = MD5Util.getLowerMD5(signbef);
		logger.info("bozhirui sign="+sign);

		//将参数转成和厂商的一致;存入map
		Map<String, String> parm = new HashMap<String, String>();
		parm.put("accountVal", phone);
		parm.put("bizType", bizType);
		parm.put("notifyUrl", notifyUrl);
		parm.put("tbOrderNo", taskid);
		parm.put("sellerId", sellerId);
		parm.put("unitPrice", unitPrice);
		parm.put("productNo", packagecode);
		parm.put("timeStmp", timeStmp);
		parm.put("sign", sign);
		url = url + "/thirddeposit.act";

		//在执行请求前先获取连接, 防止访问通道线程超量
		Cache.getConnection(routeid);
		try {
			ret = getNameValuePairRequest(url, parm, "utf-8", "bozhirui");
		} catch (Exception e) {
			e.printStackTrace();
			logger.info(e.getMessage());
		} finally {
			//在执行请求后记得释放连接
			Cache.releaseConnection(routeid);
		}

		//这里判断结果, 每个通道情况不同, 成功的保存 success 到 result 中并返回到 request.jsp
		if (ret != null && ret.trim().length() > 0) {
			logger.info("bozhirui send ret = " + ret);
			try {
			Document doc = DocumentHelper.parseText(ret);
			Element root = doc.getRootElement();
			String code = root.elementText("errCode");
			String desc = root.elementText("errDesc");
				if (code != null && code.equals("0000")) {
					request.setAttribute("result", "success");
				} else {
					request.setAttribute("code", 1);
					request.setAttribute("result", "R." + routeid + ":" + code+desc + "@" + TimeUtils.getSysLogTimeString());
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