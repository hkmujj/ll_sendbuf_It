<%@page import="java.text.SimpleDateFormat"%>
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
		String key = routeparams.get("key");
		if(key == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, key is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String account = routeparams.get("account");
		if(account == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, account is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		
		//发送请求前先准备好参数
		String[] idarray = ids.split(",");
		JSONObject obj = new JSONObject();
		
		
		for(int i = 0; i < idarray.length; i++){
			String value = idarray[i];
			String timestamp = TimeUtils.getTimeStamp();
			String nonce = MyBase64.base64Encode(account+","+timestamp);
			String signature = sign(key, timestamp, account);
			
			HashMap<String, String> param = new HashMap<String, String>();
			param.put("nonce", nonce);
			param.put("signature", signature);
			url=url+"query/orderNo/"+value;
			//发送查询/获取状态前先获取连接, 防止访问线程超量
			Cache.getStatusConnection(routeid);
			try {
				//ret = HttpAccess.postNameValuePairRequest(url, params, "utf-8", "ltkuandai");
				ret = HttpAccess.getNameValuePairRequest(url, param, "utf-8", "gzyunsheng");
			} catch (Exception e) {
				e.printStackTrace();
				logger.info(e.getMessage());
			} finally {
				//发送查询/获取状态后释放连接
				Cache.releaseStatusConnection(routeid);
			}
			
			//这里判断结果, 每个通道情况不同, 成功的节点ID对应success, 失败的对应失败信息
			if (ret != null && ret.trim().length() > 0) {
				//request.setAttribute("result", "success");
				logger.info("gzyunsheng status ret = " + ret);
				HashMap<String, String> errmap = new HashMap<String, String>();
				errmap.put("00001","下单/订购失败");
				errmap.put("10001","黑名单号码");
				errmap.put("10002","空号/号码不存在");
				errmap.put("10003","号码归属地错误");
				errmap.put("10004","欠费/停机");
				errmap.put("10005","号码已冻结或注销");
				errmap.put("10006","业务互斥");
				errmap.put("10007","业务受限");
				errmap.put("10008","没有合适的产品");
				errmap.put("10009","没有合适的通道");
				errmap.put("10010","通道被停用");
				errmap.put("10011","通道余额不足");
				errmap.put("10012","号码充值过于频繁");
				errmap.put("20000","签名认证失败");
				errmap.put("20001","请求已过期");
				errmap.put("20002","参数格式错误");
				errmap.put("20003","附加参数超长");
				errmap.put("20004","运营商错误");
				errmap.put("20005","产品类型错误");
				errmap.put("20006","客户不存在");
				errmap.put("20007","客户被停用");
				errmap.put("20008","客户IP非法");
				errmap.put("20009","客户余额不足");
				errmap.put("20010","产品不存在");
				errmap.put("20011","环行任务");
				errmap.put("20012","任务不存在，请稍候再试");
				errmap.put("99998","未知错误");
				errmap.put("99999","系统内部错误");
				
				logger.info("gzyunsheng status pos 1 " + value);
				try {
					JSONObject retjson = JSONObject.fromObject(ret);
					logger.info("gzyunsheng status pos 2 " + value);
					String retCode = retjson.getString("status");
					Object odobj = retjson.get("orderNo");
					logger.info("gzyunsheng status pos 3 " + value);
					if(retCode.equals("00000") && odobj != null){
						logger.info("gzyunsheng status pos 4 " + value);
						JSONObject rp = new JSONObject();
						rp.put("code", 0);
						rp.put("message", "success");
						rp.put("resp", ret);
						obj.put(idarray[i], rp);
					}else if(retCode.equals("00002") || retCode.equals("20012")){
						logger.info("gzyunsheng status : [" + idarray[i] + "]充值中@" + TimeUtils.getSysLogTimeString());
					}else if(retCode.equals("00001")){
						logger.info("gzyunsheng status pos 5 " + value);
					   String ordertime=("20"+idarray[i].substring(1)).substring(0, 14);
					   SimpleDateFormat df = new SimpleDateFormat("yyyyMMddHHmmss");
					   Date date=df.parse(ordertime);
					   long l=System.currentTimeMillis()-date.getTime();
					   if(l>=720000){
					    	JSONObject rp = new JSONObject();
							rp.put("code", 1);
							String message = errmap.get(retCode);
							if(message == null){
								message = retCode;
							}
							rp.put("message", message);
							rp.put("resp", ret);
							obj.put(idarray[i], rp);
							logger.info("gzyunsheng status : [" + idarray[i] + "]状态码" + retCode + ":" + message + "@" + TimeUtils.getSysLogTimeString());
						}else{
							logger.info("gzyunsheng status : [" + idarray[i] + "]未查询到订单信息@" + TimeUtils.getSysLogTimeString());							
						}
					}else {
						logger.info("gzyunsheng status pos 6 " + value);
						JSONObject rp = new JSONObject();
						rp.put("code", 1);
						String message = errmap.get(retCode);
						if(message == null){
							message = retCode;
						}
						rp.put("message", message);
						rp.put("resp", ret);
						obj.put(idarray[i], rp);
						logger.info("gzyunsheng status : [" + idarray[i] + "]状态码" + retCode + ":" + message + "@" + TimeUtils.getSysLogTimeString());
					}
					logger.info("gzyunsheng status pos 7 " + value);
				} catch (Exception e) {
					logger.warn(e.getMessage(), e);
					logger.info("gzyunsheng status : " + e.getMessage() + ", ret = " + ret + "@" + TimeUtils.getSysLogTimeString());
				}
			} else {
				logger.info("gzyunsheng status : " + "fail@" + TimeUtils.getSysLogTimeString());
			}
		}
	
		request.setAttribute("retjson", obj.toString());
		request.setAttribute("result", "success");
		
		break;
	}
	
	request.getRequestDispatcher("request.jsp").forward(request,response);
%>