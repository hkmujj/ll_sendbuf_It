<%@page
	import="com.huawei.webservice.wb.company.CompanyServiceStub.GetFlowResultResponse"%>
<%@page
	import="com.huawei.webservice.wb.company.CompanyServiceStub.GetFlowResult"%>
<%@page
	import="com.huawei.webservice.wb.company.CompanyServiceStub.GetFlowCodesResponse"%>
<%@page
	import="com.huawei.webservice.wb.company.CompanyServiceStub.ResponseWbVo"%>
<%@page
	import="com.huawei.webservice.wb.company.CompanyServiceStub.GetFlowCodes"%>
<%@page import="java.rmi.RemoteException"%>
<%@page import="org.apache.commons.codec.binary.Base64"%>
<%@page import="javax.crypto.Cipher"%>
<%@page import="javax.crypto.spec.SecretKeySpec"%>
<%@page
	import="com.huawei.webservice.wb.company.CompanyServiceStub.GiveFlowResponse"%>
<%@page
	import="com.huawei.webservice.wb.company.CompanyServiceStub.GiveFlow"%>
<%@page import="com.huawei.webservice.wb.company.CompanyServiceStub"%>

<%@page
	import="util.SHA1,
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
	language="java" pageEncoding="UTF-8"%>
<%!public static boolean logflag = true;
	public static Logger logger = LogManager.getLogger();

	protected static String Encrypt(String sSrc, String sKey, StringBuffer log) {
		String result = "";
		try{
			byte[] raw = sKey.getBytes("utf-8");
			SecretKeySpec skeySpec = new SecretKeySpec(raw, "AES");
			Cipher cipher = Cipher.getInstance("AES/ECB/PKCS5Padding");// "算法/模式/补码方式"
			cipher.init(Cipher.ENCRYPT_MODE, skeySpec);
			byte[] encrypted = cipher.doFinal(sSrc.getBytes("utf-8"));
			result = new Base64().encodeToString(encrypted);// 此处使用BASE64做转码功能，同时能起到2次加密的作用。
		}catch(Exception e){
			logger.info("，wobei生成沃贝秘钥错误，错误原因：" + e);
		}

		return result;
	}

	public static String getFlowResult(String flowOrderId, String channel, String uName, String key, String url, StringBuffer log) throws RemoteException {
		GetFlowResult getFlowResult = new GetFlowResult();
		getFlowResult.setChannel(channel);
		getFlowResult.setUName(uName);
		getFlowResult.setFlowOrderId(flowOrderId);
		String getflowresult = "channel=" + channel + "|serviceName=getFlowResult|";
		getFlowResult.setSecretKey(Encrypt(getflowresult, key, log));

		GetFlowResultResponse getFlowResultResponse = new CompanyServiceStub(url).getFlowResult(getFlowResult);

		ResponseWbVo responseWbVo = getFlowResultResponse.get_return();
		return JSONObject.fromObject(responseWbVo).toString();
	}%>>
<%

	out.clearBuffer();
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
		String uName = routeparams.get("uName");
		if(uName == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, uName is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String channel = routeparams.get("channel");
		if(channel == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, channel is null@" + TimeUtils.getSysLogTimeString());
			break;
		}

		//发送请求前先准备好参数
		String[] idarray = ids.split(",");
		JSONObject obj = new JSONObject();

		for(int i = 0; i < idarray.length; i++){

			//发送查询/获取状态前先获取连接, 防止访问线程超量
			Cache.getStatusConnection(routeid);
			try{
				ret = getFlowResult(idarray[i], channel, uName, key, url, new StringBuffer(0));
			}catch(Exception e){
				e.printStackTrace();
				logger.info(e.getMessage());
			}finally{
				//发送查询/获取状态后释放连接
				Cache.releaseStatusConnection(routeid);
			}

			//这里判断结果, 每个通道情况不同, 成功的节点ID对应success, 失败的对应失败信息
			if(ret != null && ret.trim().length() > 0){
				//request.setAttribute("result", "success");
				logger.info("wobei status ret = " + ret);
				try{
					JSONObject retjson = JSONObject.fromObject(ret);
					JSONArray ary = retjson.getJSONArray("datas");
					String code = retjson.getString("code");
					String msg = retjson.getString("msg");
					if(code.equals("1")){
						JSONObject datajson = ary.getJSONObject(0);
						String isSuccess = datajson.getString("isSuccess");
						String message = datajson.getString("msg");
						if(isSuccess.equals("失败")){
							JSONObject rp = new JSONObject();
							rp.put("code", "1");
							rp.put("message", message);
							rp.put("resp", ret);
							obj.put(idarray[i], rp);
						}else if(isSuccess.equals("成功")){
							JSONObject rp = new JSONObject();
							rp.put("code", 0);
							rp.put("message", "success");
							rp.put("resp", ret);
							obj.put(idarray[i], rp);
						}else{
							logger.info("wobei status : [" + idarray[i] + "]充值中@" + "@" + TimeUtils.getSysLogTimeString());
						}

					}else{
						logger.info("wobei status : [" + idarray[i] + "]充值中@" + TimeUtils.getSysLogTimeString());
					}
				}catch(Exception e){
					logger.warn(e.getMessage(), e);
					logger.info("wobei status : " + e.getMessage() + ", ret = " + ret + "@" + TimeUtils.getSysLogTimeString());
				}
			}else{
				logger.info("wobei status : " + "fail@" + TimeUtils.getSysLogTimeString());
			}
		}

		request.setAttribute("retjson", obj.toString());
		request.setAttribute("result", "success");

		break;
	}

	request.getRequestDispatcher("request.jsp").forward(request, response);
%>