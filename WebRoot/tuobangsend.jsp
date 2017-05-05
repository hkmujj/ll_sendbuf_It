<%@page import="org.apache.http.util.EntityUtils"%>
<%@page import="org.apache.http.HttpEntity"%>
<%@page import="java.io.IOException"%>
<%@page import="org.apache.http.client.ClientProtocolException"%>
<%@page import="org.apache.http.HttpResponse"%>
<%@page import="http.VResponseHandler"%>
<%@page import="org.apache.http.client.ResponseHandler"%>
<%@page import="org.apache.http.client.config.RequestConfig"%>
<%@page import="java.util.Map.Entry"%>
<%@page import="org.apache.http.impl.client.HttpClients"%>
<%@page import="org.apache.http.impl.client.CloseableHttpClient"%>
<%@page import="org.apache.http.client.methods.HttpGet"%>
<%@page import="java.net.URLEncoder"%>
<%@page import="org.eclipse.jetty.util.UrlEncoded"%>
<%@page import="com.recharge.crypt.*"%>
<%@page import="util.TimeUtils,
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
		language="java" pageEncoding="UTF-8"
%><%!
	boolean logflag = true;
	public static Logger logger = LogManager.getLogger();
	public static String getNameValuePairRequest(String url, Map<String, String> params, String encode, String retenc, String mark){
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
			}
			if(params.size() > 0){
				httpget = new HttpGet(url + "?" + paramstr);
			}
			
			RequestConfig requestConfig = RequestConfig.custom().setSocketTimeout(90000).setConnectTimeout(5000).build();
			httpget.setConfig(requestConfig);
			
			//logger.info("get url = " + url + "?" + paramstr);
			
			ResponseHandler<String> responseHandler = new MyResponseHandler(mark, retenc);

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
	}
	
	
 %><%
	boolean logflag = true;
	Logger logger = LogManager.getLogger();
	
	//获取公共参数
	String taskid = request.getAttribute("taskid").toString();
	String routeid = request.getAttribute("routeid").toString();
	String phone = request.getAttribute("phone").toString();
	String packageid = request.getAttribute("package").toString();
	
	logger.info("tuobang taskid =" + taskid);
	logger.info("tuobang routeid =" + routeid);
	logger.info("tuobang phone =" + phone);
	logger.info("tuobang packageid =" + packageid);
	while(true){
		String ret = null;
		
		//检查通道参数, 每个通道有不同参数, 对应 ll_routes.api_params(私有参数)
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
		String merc_id = routeparams.get("merc_id");
		if(merc_id == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, merc_id is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String signKey = routeparams.get("signKey");
		if(signKey == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, signKey is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String ver_no = routeparams.get("ver_no");
		if(ver_no == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, ver_no is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String flx_typ = routeparams.get("flx_typ");
		if(flx_typ == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, flx_typ is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String char_set = "00";
		String sign_typ = "MD5";
		String notify_url = "http://120.24.156.98:9302/ll_sendbuf/tuobangreturn.jsp";
		String itf_code = "flx_request";
		
		
		//参数准备, 每个通道不同
		String packagecode = null;
		try{
			packageid = packageid.split("\\.")[1];
			String pkstr = packageid.substring(0, packageid.length() - 1);
			int pk = Integer.parseInt(pkstr);
			if(packageid.indexOf('G') >= 0){
				pk *= 1024;
			}
			packagecode = String.valueOf(pk);
		} catch (Exception e) {
			logger.warn(e.getMessage(), 0);
		}
		logger.info("tuobang packagecode =" + packagecode);
		
		if(packagecode == null){
			request.setAttribute("result", "S." + routeid + ":unrecognized package@" + TimeUtils.getSysLogTimeString());
			break;
		}
		
		String req_dt = TimeUtils.getDateString();
		String signData = char_set + URLEncoder.encode(notify_url, "utf-8") + merc_id + taskid + req_dt + sign_typ +itf_code + ver_no
                        + phone + flx_typ + packagecode+"M";
		
		logger.info("tuobang signData=" + signData);
		HiiposmUtil util = new HiiposmUtil();
		logger.info("tuobang ok123");
        String hmac = util.MD5Sign(signData, signKey);
        logger.info("tuobang hmac=" + hmac);
        logger.info("tuobang url=" + url);

		
		HashMap<String, String> param = new HashMap<String, String>();
		param.put("char_set", char_set);
		param.put("notify_url", URLEncoder.encode(notify_url, "utf-8"));
		param.put("merc_id", merc_id);
		param.put("req_id", taskid);
		param.put("req_dt", req_dt);
		param.put("sign_typ", sign_typ);
		param.put("itf_code", itf_code);
		param.put("ver_no", ver_no);
		param.put("mbl_no", phone);
		param.put("flx_typ", flx_typ);
		param.put("flx_num", packagecode+"M");
		param.put("hmac", hmac);
		
		/*
		String buf = "char_set=" + char_set + "&notify_url=" + URLEncoder.encode(notify_url, "utf-8")
                        + "&merc_id=" + merc_id + "&req_id=" + taskid
                        + "&req_dt=" + req_dt + "&sign_typ="+sign_typ+ "&itf_code=" + itf_code
                        + "&ver_no=" + URLEncoder.encode(ver_no, "utf-8") + "&mbl_no=" + phone
                        + "&flx_typ=" + flx_typ + "&flx_num=" + packagecode
                        + "&hmac=" + hmac;
                        
         */

		//logger.info("tuobang buf =" + buf);

		//在执行请求前先获取连接, 防止访问通道线程超量
		Cache.getConnection(routeid);
		try {
			//ret = HttpAccess.postNameValuePairRequest(url, param,"application/x-www-form-urlencoded", "utf-8", "gdshangtong");
			//ret = HttpAccess.postJsonRequest(url, json.toString(), "utf-8", "weikesend");
			//ret = HttpAccess.getNameValuePairRequest(url, param, "utf-8", "tuobangsend");
			//ret = util.sendAndRecv(url, buf, char_set);
			//ret = getNameValuePairRequest(url + "?" + buf, new HashMap<String, String>(), "utf-8", "gbk", "tuobangsend");
			ret = getNameValuePairRequest(url, param, "utf-8", "gbk", "tuobangsend");
		} catch (Exception e) {
			e.printStackTrace();
			logger.error("tuobangsend&&&",e);
		} finally {
			//在执行请求后记得释放连接
			Cache.releaseConnection(routeid);
		}
	
		//这里判断结果, 每个通道情况不同, 成功的保存 success 到 result 中并返回到 request.jsp(ret为返回的结果)
		if (ret != null && ret.trim().length() > 0) {
			logger.info("tuobang send ret = " + ret);
			try {
				HashMap<String, String> paramsmap = new LinkedHashMap<String, String>();
				if(ret != null && ret.trim().length() > 0){
					paramsmap = new LinkedHashMap<String, String>();
					String[] strs = ret.split("&");
					for(int i = 0; i < strs.length; i++){
						int idx = strs[i].indexOf('=');
						if(idx >= 0){
							paramsmap.put(strs[i].substring(0, idx), strs[i].substring(idx + 1, strs[i].length()));
						}
					}
				}	
                
                String rtnCode = paramsmap.get("msg_code");
                String rtnMsg = paramsmap.get("msg_inf");
                
				String retCode = rtnCode.substring(rtnCode.length() - 5); //最后5位为0表示平台受理成功
				logger.info("retCode = " + retCode);
				if(retCode.equals("00000")){
					request.setAttribute("result", "success");
				}else{
					request.setAttribute("code", rtnCode);
				 	request.setAttribute("result", "R." + routeid + ":" + retCode + ":" + rtnMsg + "@" + TimeUtils.getSysLogTimeString());
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

	request.getRequestDispatcher("request.jsp").forward(request,response);
%>