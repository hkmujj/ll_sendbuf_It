<%@page import="java.util.Map.Entry"%>
<%@page import="http.VResponseHandler"%>
<%@page import="org.apache.http.client.ResponseHandler"%>
<%@page import="java.net.URLEncoder"%>
<%@page import="org.apache.http.impl.client.HttpClients"%>
<%@page import="org.apache.http.impl.client.CloseableHttpClient"%>
<%@page import="org.apache.http.client.methods.HttpGet"%>
<%@page import="java.security.GeneralSecurityException"%>
<%@page import="java.security.MessageDigest"%>
<%@page import="org.apache.commons.codec.binary.Hex"%>
<%@page import="org.apache.commons.codec.binary.Base64"%>
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
				org.apache.logging.log4j.Logger" 
		language="java" pageEncoding="UTF-8"
%><%!private static boolean logflag = true;
	private static Logger logger = LogManager.getLogger();

	public static String createAuthHead(String username, String authcode) {
		Date date = new Date();
		SimpleDateFormat simpleDateFormat = new SimpleDateFormat("yyyyMMddHHmmss");
		String timestamp = simpleDateFormat.format(date);
		String needHash = username + authcode + timestamp;
		byte[] md5result = md5(needHash.getBytes());
		String sign = encodeHex(md5result);
		String nameAndTimestamp = username + ":" + timestamp;
		return "sign=\"" + sign + "\",nonce=\""
				+ encodeBase64(nameAndTimestamp.getBytes()) + "\"";
	}

	public static String encodeBase64(byte[] input) {
		return Base64.encodeBase64String(input);
	}

	public static String encodeHex(byte[] input) {
		return Hex.encodeHexString(input);
	}

	public static byte[] md5(byte[] input) {
		return digest(input, "MD5", null, 1);
	}

	public static byte[] digest(byte[] input, String algorithm, byte[] salt,int iterations) {
		try {
			MessageDigest e = MessageDigest.getInstance(algorithm);
			if (salt != null) {
				e.update(salt);
			}
			byte[] result = e.digest(input);
			for (int i = 1; i < iterations; ++i) {
				e.reset();
				result = e.digest(result);
			}
			return result;
		} catch (GeneralSecurityException e) {
			throw new RuntimeException(e);
		}
	}

	public static String getNameValuePairRequest(String url, String userid,
			String encode, Map<String, String> header, String mark) {
		String bacTxt = null;
		HttpGet httpget = null;
		String urlstr = null;
		CloseableHttpClient httpclient = HttpClients.createDefault();
		try {
			urlstr = url + "/" + URLEncoder.encode(userid, "utf-8");
			httpget = new HttpGet(urlstr);

			ResponseHandler<String> responseHandler = new VResponseHandler(mark);
			for (Entry<String, String> entry : header.entrySet()) {
				httpget.setHeader(entry.getKey(), entry.getValue());
			}

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

		//logger.info(sb.toString());

		return bacTxt;
	}%><%
	
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
		
		
		String rp_url = routeparams.get("rp_url");
		if (rp_url == null) {
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, rp_url is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String username = routeparams.get("username");
		if (username == null) {
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, username is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String authcode = routeparams.get("authcode");
		if (authcode == null) {
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, authcode is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		
		
		//发送请求前先准备好参数
		String[] idarray = ids.split(",");
		JSONObject obj = new JSONObject();
		
		for(int i = 0; i < idarray.length; i++){
	
					
		Map<String, String> headerlist=new HashMap<String, String>();
		String str = createAuthHead(username,authcode);
		headerlist.put("Content-Type", "application/x-www-form-urlencoded");
		headerlist.put("Authorization", str);
					//发送查询/获取状态前先获取连接, 防止访问线程超量
					Cache.getStatusConnection(routeid);
					try {
					ret = getNameValuePairRequest(rp_url, idarray[i], "utf-8", headerlist, "maiyi");
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
						logger.info("maiyi status ret = " + ret);
						try {
								JSONObject retjson = JSONObject.fromObject(ret);
								String retCode = retjson.getString("status");
								String msg=retjson.getString("message");
								if (retCode.equals("20000")) {
									JSONObject rp = new JSONObject();
									rp.put("code", 0);
									rp.put("message", "success");
									rp.put("resp", ret);
									obj.put(idarray[i], rp);
								}else if(retCode.equals("20000")){
								logger.info("dahan status : [" + idarray[i]+ "]充值中@"+ TimeUtils.getSysLogTimeString());
								} else if(retCode.equals("50100")){
								JSONObject rp = new JSONObject();
									rp.put("code", 1);
									rp.put("message", msg);
									rp.put("resp", ret);
									obj.put(idarray[i], rp);
									
								} 
						} catch (Exception e) {
							logger.warn(e.getMessage(), e);
							logger.info("maiyi status : " + e.getMessage()
									+ ", ret = " + ret + "@"
									+ TimeUtils.getSysLogTimeString());
						}
					} else {
						logger.info("maiyi status : " + "fail@"
								+ TimeUtils.getSysLogTimeString());
					}
				}

				request.setAttribute("retjson", obj.toString());
				request.setAttribute("result", "success");

				break;
			}

			request.getRequestDispatcher("request.jsp").forward(request,
					response);%>