<%@page import="org.apache.http.client.methods.HttpGet"%>
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
<%@page import="util.SHA1,
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
	
	while(true){
		String ret = null;
		
		//获取公共参数
		
		String routeid = request.getAttribute("routeid").toString();

		
		Object idsobj = request.getAttribute("ids");
		if(idsobj == null){
			request.setAttribute("result", "S." + routeid + ":ids are needed to get status@" + TimeUtils.getSysLogTimeString());
			break;
		}
		
		String ids = idsobj.toString(); 
		
		logger.info("ids = " + ids + ", routeid = " + routeid);
		
		//获取通道能数, 每个通道不同
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
		
		String char_set = "00";
		String sign_typ = "MD5";
		String itf_code = "flx_result_query";
		String inq_req_dt = TimeUtils.getDateString();
		
		//发送请求前先准备好参数
		String[] idarray = ids.split(",");
		JSONObject obj = new JSONObject();
		
		for(int i = 0; i < idarray.length; i++){
			String value = idarray[i];
			String signData = char_set + merc_id + value + value + inq_req_dt + sign_typ + itf_code + ver_no;	
			
		 	HiiposmUtil util = new HiiposmUtil();
            String hmac = util.MD5Sign(signData, signKey);
            
            String buf = "char_set=" + char_set + "&merc_id=" + merc_id + "&req_id=" + value
                       + "&inq_req_id=" + value + "&inq_req_dt=" + inq_req_dt + "&sign_typ=" +sign_typ
                       + "&itf_code=" + itf_code + "&ver_no=" + ver_no
                       + "&hmac=" + hmac;
                       
            HashMap<String, String> param = new HashMap<String, String>();
			param.put("char_set", char_set);
			param.put("merc_id", merc_id);
			param.put("req_id", value);
			param.put("inq_req_id", value);
			param.put("inq_req_dt", inq_req_dt);
			param.put("sign_typ", sign_typ);
			param.put("itf_code", itf_code);
			param.put("ver_no", ver_no);
			param.put("hmac", hmac);
			
			//发送查询/获取状态前先获取连接, 防止访问线程超量
			Cache.getStatusConnection(routeid);
			try {
				//ret = HttpAccess.postNameValuePairRequest(rpurl, param, "utf-8", "gdshangtongstatus.jsp");
				//ret = HttpAccess.getNameValuePairRequest(url, param, "utf-8", "gzyunsheng");
				ret = getNameValuePairRequest(url, param, "utf-8", "gbk", "tuobangstatus");
			} catch (Exception e) {
				e.printStackTrace();
				logger.info(e.getMessage());
			} finally {
				//发送查询/获取状态后释放连接
				Cache.releaseStatusConnection(routeid);
			}
			
			//这里判断结果, 每个通道情况不同, 成功的节点ID对应success, 失败的对应失败信息
			if (ret != null && ret.trim().length() > 0) {
			logger.info("tuobang status ret = " + ret);
				
				try {
					HashMap<String, String> paramsmap = new LinkedHashMap<String, String>();
					if(ret != null && ret.trim().length() > 0){
						paramsmap = new LinkedHashMap<String, String>();
						String[] strs = ret.split("&");
						for(int y = 0; y < strs.length; y++){
							int idx = strs[y].indexOf('=');
							if(idx >= 0){
								paramsmap.put(strs[y].substring(0, idx), strs[y].substring(idx + 1, strs[y].length()));
							}
						}
					}	
					String chgSts  = paramsmap.get("chg_sts");
					if(chgSts.equals("S")){
						JSONObject rp = new JSONObject();
						rp.put("code", 0);
						rp.put("message", "success");
						rp.put("resp", ret);
						obj.put(idarray[i], rp);
					}else if(chgSts.equals("P")){
						logger.info("tuobang status : [" + idarray[i] + "]充值中@" + TimeUtils.getSysLogTimeString());
					}else if(chgSts.equals("U")){
						logger.info("tuobang status : [" + idarray[i] + "]待充值@" + TimeUtils.getSysLogTimeString());
					}else {
						JSONObject rp = new JSONObject();
						rp.put("code", 1);
						String message = "充值失败";
						rp.put("message", message);
						rp.put("resp", ret);
						obj.put(idarray[i], rp);
					}
				} catch (Exception e) {
					logger.warn(e.getMessage(), e);
					logger.info("tuobang status : " + e.getMessage() + ", ret = " + ret + "@" + TimeUtils.getSysLogTimeString());
				}
			} else {
				logger.info("tuobang status : " + "fail@" + TimeUtils.getSysLogTimeString());
			}
		}
	
		request.setAttribute("retjson", obj.toString());
		request.setAttribute("result", "success");
		
		break;
	}
	
	request.getRequestDispatcher("request.jsp").forward(request,response);
%>