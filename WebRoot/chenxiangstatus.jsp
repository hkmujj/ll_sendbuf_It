<%@page import="org.apache.http.util.EntityUtils"%>
<%@page import="org.apache.http.HttpResponse"%>
<%@page import="org.apache.http.entity.StringEntity"%>
<%@page import="org.apache.http.client.methods.HttpPost"%>
<%@page import="org.apache.http.impl.client.DefaultHttpClient"%>
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
	Logger logger = LogManager.getLogger();
	public String postValue(String url, String obj){
		DefaultHttpClient httpClient = new DefaultHttpClient();
		HttpPost method = new HttpPost(url);
        try {
            if (null != obj) {
                //解决中文乱码问题
                StringEntity entity = new StringEntity(obj, "utf-8");
                entity.setContentEncoding("utf-8");
                entity.setContentType("application/json");
                method.setEntity(entity);
            }
            HttpResponse result = httpClient.execute(method);
            /**请求发送成功，并得到响应**/
            if (result.getStatusLine().getStatusCode() == 200) {
                String str = "";
                try {
                    /**读取服务器返回过来的json字符串数据**/
                    str = EntityUtils.toString(result.getEntity(), "utf-8");
                    /**把json字符串转换成json对象**/
                    logger.info("chenxiangstatus str = " + str);
                } catch (Exception e) {
                	e.printStackTrace();
                	return "";
                }
                return str;
            }
            return "";
        } catch (Exception e) {
        	e.printStackTrace();
        	 return "";
        }
	}
 %><%
 	out.clearBuffer();
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
		
		String rpurl = routeparams.get("rpurl");
		if(rpurl == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, rpurl is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String appkey = routeparams.get("appkey");
		if(appkey == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, appkey is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String securityKey = routeparams.get("securityKey");
		if(securityKey == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, securityKey is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		
		//发送请求前先准备好参数
		String[] idarray = ids.split(",");
		JSONObject obj = new JSONObject();
		
		for(int i = 0; i < idarray.length; i++){
			String value = idarray[i];
			String timeStamp = TimeUtils.getTimeStamp();
			String sign = "appkey" + appkey + "cstmOrderNo" + value + "timeStamp" + timeStamp + securityKey;
			String sig = SHA1.sha1Encode(sign);
			sig = sig.toLowerCase();		
			
			JSONObject object = new JSONObject();
			object.put("sig", sig);
			object.put("appkey", appkey);
			object.put("timeStamp", timeStamp);
			object.put("cstmOrderNo", value);
			logger.info("status object = " + object);

			//发送查询/获取状态前先获取连接, 防止访问线程超量
			Cache.getStatusConnection(routeid);
			try {
				ret = postValue(rpurl,object.toString());
				//ret = HttpAccess.postJsonRequest(rpurl, object.toString(), "utf-8", "chenxiangstatus");
				//ret = HttpAccess.postNameValuePairRequest(rpurl, param, "utf-8", "gdshangtongstatus.jsp");
				//ret = HttpAccess.getNameValuePairRequest(url, param, "utf-8", "gzyunsheng");
			} catch (Exception e) {
				e.printStackTrace();
				logger.info(e.getMessage());
			} finally {
				//发送查询/获取状态后释放连接
				Cache.releaseStatusConnection(routeid);
			}
			
			//这里判断结果, 每个通道情况不同, 成功的节点ID对应success, 失败的对应失败信息
			if (ret != null && ret.trim().length() > 0) {
			logger.info("chenxiang status ret = " + ret);
				
				try {
					JSONObject retjson = JSONObject.fromObject(ret);
					String retCode = retjson.getString("code");
					logger.info("chenxiang retCode" + retCode);
					if(retCode.equals("0000")){
						JSONObject odobj = retjson.getJSONObject("data");
						String status = odobj.getString("status");
						logger.info("chenxiang status" + status);
						if(status.equals("7")){
							JSONObject rp = new JSONObject();
							rp.put("code", 0);
							rp.put("message", "success");
							rp.put("resp", ret);
							obj.put(idarray[i], rp);
						}else if(status.equals("1")){
							logger.info("chenxiang status : [" + idarray[i] + "]充值中@" + TimeUtils.getSysLogTimeString());
						}else if(status.equals("0")){
							logger.info("chenxiang status : [" + idarray[i] + "]订单已受理@" + TimeUtils.getSysLogTimeString());
						}else {
							String message = "";
							JSONObject rp = new JSONObject();
							rp.put("code", 1);
							if(status.equals("8")){
								message = odobj.getString("errorDesc");
							}
							rp.put("message", message);
							rp.put("resp", ret);
							obj.put(idarray[i], rp);
							logger.info("chenxiang status : [" + idarray[i] + "]状态码" + retCode + ":" + message + "@" + TimeUtils.getSysLogTimeString());
						}
				}else{
					logger.info("chenxiang return code = " + retCode);
				}
				} catch (Exception e) {
					logger.warn(e.getMessage(), e);
					logger.info("chenxiang status : " + e.getMessage() + ", ret = " + ret + "@" + TimeUtils.getSysLogTimeString());
				}
			} else {
				logger.info("chenxiang status : " + "fail@" + TimeUtils.getSysLogTimeString());
			}
		}
	
		request.setAttribute("retjson", obj.toString());
		request.setAttribute("result", "success");
		
		break;
	}
	
	request.getRequestDispatcher("request.jsp").forward(request,response);
%>