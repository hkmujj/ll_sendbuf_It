<%@page import="net.sf.json.JSONArray,
				java.io.InputStreamReader,
				java.net.URL,
				java.net.HttpURLConnection,
				java.io.BufferedReader,
				java.io.OutputStreamWriter,
				sun.misc.BASE64Encoder,
				java.io.UnsupportedEncodingException,
				sun.misc.BASE64Decoder,
				javax.crypto.Cipher,
				javax.crypto.spec.SecretKeySpec,
				java.io.IOException,
				java.security.InvalidKeyException,
				javax.crypto.BadPaddingException,
				javax.crypto.IllegalBlockSizeException,
				javax.crypto.NoSuchPaddingException,
				java.security.NoSuchAlgorithmException,
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
<%! private static final String ALGO = "AES";
	public static String aesDecrypt(String ciphertext, String password) throws NoSuchAlgorithmException, NoSuchPaddingException, IllegalBlockSizeException, BadPaddingException, InvalidKeyException,
			IOException {
		byte[] enCodeFormat =password.getBytes();
		SecretKeySpec key = new SecretKeySpec(enCodeFormat, ALGO);
		Cipher cipher = Cipher.getInstance(ALGO);// 创建密码器
		cipher.init(Cipher.DECRYPT_MODE, key);// 初始化
		byte[] result = cipher.doFinal(new BASE64Decoder().decodeBuffer(ciphertext));
		return new String(result, "UTF-8"); //
	}

	public static String aesEncrypt(String content, String password) {
		byte[] result = null;
		try{
			
			byte[] enCodeFormat = password.getBytes();
			SecretKeySpec key = new SecretKeySpec(enCodeFormat, ALGO);
			Cipher cipher = Cipher.getInstance(ALGO);// 创建密码器
			byte[] byteContent = content.getBytes("UTF-8");
			cipher.init(Cipher.ENCRYPT_MODE, key);// 初始化
			result = cipher.doFinal(byteContent);
		} catch (InvalidKeyException e) {
			e.printStackTrace();
		} catch (NoSuchAlgorithmException e) {
			e.printStackTrace();
		} catch (NoSuchPaddingException e) {
			e.printStackTrace();
		} catch (IllegalBlockSizeException e) {
			e.printStackTrace();
		} catch (BadPaddingException e) {
			e.printStackTrace();
		} catch (UnsupportedEncodingException e) {
			e.printStackTrace();
		}
		return new BASE64Encoder().encode(result); // 加密
	}
	public static String requestFront(String custId, String secretkey,String suffix, String interfaceUrl, String timestamp,String paramsJson) throws Exception {
		String result = "";
		OutputStreamWriter out = null;
		BufferedReader reader = null;
		HttpURLConnection conn = null;
		try {
			URL url = new URL(interfaceUrl);
			conn = (HttpURLConnection) url.openConnection();
			conn.setRequestMethod("POST");
			conn.setDoOutput(true);
			conn.setDoInput(true);
			conn.setConnectTimeout(30 * 1000);
			conn.setReadTimeout(60 * 1000);
			conn.addRequestProperty("Accept", "*/*");
			conn.addRequestProperty("Content-Type", "text/plain");
			conn.addRequestProperty("timestamp", timestamp);
			conn.addRequestProperty("custid", custId);
			String text = encryptedDate(secretkey, paramsJson);
			out = new OutputStreamWriter(conn.getOutputStream());
			out.write(text);
			out.flush();
			reader = new BufferedReader(new InputStreamReader(
					conn.getInputStream(), "utf-8"));
			String line = "";
			while ((line = reader.readLine()) != null) {
				result += line;
			}
		} catch (IOException e) {
			e.printStackTrace();
		} finally {
			try {
				if (out != null) {
					out.close();
				}
				if (reader != null) {
					reader.close();
				}
				if (conn != null) {
					conn.disconnect();
				}
			} catch (IOException ex) {
				ex.printStackTrace();
			}
		}
		return result;
	}

	/**
	 * @Description： 把map转换成json并加密
	 * @param pwd
	 *            密钥
	 * @param paramsJson 要加密的数据JSON数据
	 * @return 已加密的数据
	 * @author: LIZHAOYANG
	 * @since: 2015年6月5日 下午5:37:42
	 */
	public static String encryptedDate(String pwd, String paramsJson)
			throws Exception, NoSuchAlgorithmException, NoSuchPaddingException,
			IllegalBlockSizeException, BadPaddingException,
			UnsupportedEncodingException {
		String result = aesEncrypt(paramsJson, pwd);
		return result;
	}
	 %>
<%
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
		
		
		String rp_url = routeparams.get("rp_url");
		if (rp_url == null) {
			request.setAttribute("result",
					"S." + routeid + ":wrong routeparams, rp_url is null@"
							+ TimeUtils.getSysLogTimeString());
			break;
		}
		String custId = routeparams.get("custId");
		if (custId == null) {
			request.setAttribute("result", "S." + routeid
					+ ":wrong routeparams, custId is null@"
					+ TimeUtils.getSysLogTimeString());
			break;
		}
		String secretkey = routeparams.get("secretkey");
		if (secretkey == null) {
			request.setAttribute("result",
					"S." + routeid + ":wrong routeparams, secretkey is null@"
							+ TimeUtils.getSysLogTimeString());
			break;
		}
		
		//发送请求前先准备好参数
		String[] idarray = ids.split(",");
		JSONObject obj = new JSONObject();
		
		for(int i = 0; i < idarray.length; i++){
					String paramsJson = "";
					JSONObject paramjson = new JSONObject();
					paramjson.put("telPhone", idarray[i].substring(idarray[i].length()-11));
					paramjson.put("orderId", idarray[i].substring(0,idarray[i].length()-11));
					logger.info( "csyunliu paramjson="+paramjson.toString());
					String timestamp = TimeUtils.getTimeStamp();
					//发送查询/获取状态前先获取连接, 防止访问线程超量
					Cache.getStatusConnection(routeid);
					try {
					 ret=requestFront(custId, secretkey,"", rp_url, timestamp, paramjson.toString());
					 
					
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
						logger.info("csyunliusend status ret = " + ret);
						try {
							JSONObject rtjson=JSONObject.fromObject(ret);
						    String errorcode = rtjson.getString("errorcode");
						    String code = rtjson.getString("code");
							JSONArray arr=rtjson.getJSONArray("message");
							if(code.equals("1")&&errorcode.equals("200")){
								JSONObject retjson = arr.getJSONObject(0);
								String rechargeStatus = retjson.getString("rechargeStatus");
								if (rechargeStatus.equals("1")) {
									JSONObject rp = new JSONObject();
									rp.put("code", 0);
									rp.put("message", "success");
									rp.put("resp", ret);
									obj.put(idarray[i], rp);
								} else  if(rechargeStatus.equals("0")){
									String msg = "失败";
									if(retjson.get("failcode") != null){
										msg = retjson.getString("failcode");
									}
									JSONObject rp = new JSONObject();
									rp.put("code", 1);
									rp.put("message", msg);
									rp.put("resp", ret);
									obj.put(idarray[i], rp);
								}else{
								logger.info("csyunliusend status : [" + idarray[i]+ "]充值中@"+ TimeUtils.getSysLogTimeString());
								}
							}else{
								logger.info("csyunliusend status : [" + idarray[i]+ "]充值中@"+ TimeUtils.getSysLogTimeString());
							}
						} catch (Exception e) {
							logger.warn(e.getMessage(), e);
							logger.info("csyunliusend status : " + e.getMessage()
									+ ", ret = " + ret + "@"
									+ TimeUtils.getSysLogTimeString());
						}
					} else {
						logger.info("csyunliusend status : " + "fail@"
								+ TimeUtils.getSysLogTimeString());
					}
				}

				request.setAttribute("retjson", obj.toString());
				request.setAttribute("result", "success");

				break;
			}

			request.getRequestDispatcher("request.jsp").forward(request,
					response);%>