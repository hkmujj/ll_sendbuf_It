<%@page import="org.dom4j.Element"%>
<%@page import="org.dom4j.DocumentHelper"%>
<%@page import="org.dom4j.Document"%>
<%@page import="java.rmi.RemoteException"%>
<%@page import="javax.xml.rpc.ParameterMode"%>
<%@page import="javax.xml.rpc.ServiceException"%>
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
				java.io.UnsupportedEncodingException,
				org.apache.axis.client.Call,
				org.apache.axis.client.Service,
				org.apache.axis.encoding.XMLType"
		language="java" pageEncoding="UTF-8"
%><%!
	public static String orderResult(String url, String pkey, String seqId, String code){
		String endpoint = url;
		String result = "no result!";
		Service service = new Service();
		Call call = null;
		Object[] object = new Object[3];
		object[0] = pkey;
		object[1] = seqId;
		object[2] = code;
		
		try{
			try{
				call = (Call) service.createCall();
			}catch(ServiceException e){
				e.printStackTrace();
			}
			call.setTargetEndpointAddress(endpoint);// 远程调用路径
			call.setOperationName("orderResult");// 调用的方法名
			call.addParameter("pkey", XMLType.XSD_STRING,ParameterMode.IN);
			call.addParameter("seqId", XMLType.XSD_STRING,ParameterMode.IN);
			call.addParameter("code", XMLType.XSD_STRING,ParameterMode.IN);
			// 设置返回值类型：
			call.setReturnType(XMLType.XSD_STRING);// 返回值类型：String
			result = (String)call.invoke(object);
		}catch(RemoteException e){
			e.printStackTrace();
		}
		return result;
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
		
		String url = routeparams.get("url");
		if(url == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, url is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String pkey = routeparams.get("pkey");
		if(pkey == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, pkey is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String pSecret = routeparams.get("pSecret");
		if(pSecret == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, pSecret is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		
		//发送请求前先准备好参数
		String[] idarray = ids.split(",");
		JSONObject obj = new JSONObject();
		
		for(int i = 0; i < idarray.length; i++){
			String taskid = idarray[i];
			String sign = taskid + pkey + pSecret;
			String code = MD5Util.getUpperMD5(sign);
			logger.info("gdliantongcf status data = " + taskid + ":" + pkey + ":" + pSecret);

			//发送查询/获取状态前先获取连接, 防止访问线程超量
			Cache.getStatusConnection(routeid);
			try {
				  ret = orderResult(url, pkey, taskid, code);
			} catch (Exception e) {
				e.printStackTrace();
				logger.info(e.getMessage());
			} finally {
				Cache.releaseStatusConnection(routeid);
			}
			
			//这里判断结果, 每个通道情况不同, 成功的节点ID对应success, 失败的对应失败信息
			if (ret != null && ret.trim().length() > 0) {
			logger.info("gdliantongcf status ret = " + ret);
				
				try {
					Document retDocument = DocumentHelper.parseText(ret);
					Element responseElement = retDocument.getRootElement();
					Element resultCodeElement = responseElement.element("ResultCode");
					Element resultDescElement = responseElement.element("ResultDesc");
					
					String resultCode = resultCodeElement.getText();
					String descMessage = resultDescElement.getText();
					logger.info("gdliantongcf status ResultCode = " + resultCode + ";" + "gdliantongcf status ResultDesc = " + descMessage);
					
					if(resultCode.equals("0")){
						JSONObject rp = new JSONObject();
						rp.put("code", 0);
						rp.put("message", "success");
						rp.put("resp", ret);
						obj.put(idarray[i], rp);
					}else if(resultCode.equals("9")){
						logger.info("gdliantongcf status : [" + idarray[i] + "]充值中@" + TimeUtils.getSysLogTimeString());
					}else if(resultCode.equals("10")){
						logger.info("gdliantongcf status : [" + idarray[i] + "]没有找到相关的记录@" + TimeUtils.getSysLogTimeString());
					}else if(resultCode.equals("11")){
						logger.info("gdliantongcf status : [" + idarray[i] + "]订购接口延时@" + TimeUtils.getSysLogTimeString());
					}else {
						JSONObject rp = new JSONObject();
						rp.put("code", 1);
						rp.put("message", descMessage);
						rp.put("resp", ret);
						obj.put(idarray[i], rp);
						logger.info("gdliantongcf status : [" + idarray[i] + "]状态码" + resultCode + ":" + descMessage + "@" + TimeUtils.getSysLogTimeString());
					}
				} catch (Exception e) {
					logger.warn(e.getMessage(), e);
					logger.info("gdliantongcf status : " + e.getMessage() + ", ret = " + ret + "@" + TimeUtils.getSysLogTimeString());
				}
			} else {
				logger.info("gdliantongcf status : " + "fail@" + TimeUtils.getSysLogTimeString());
			}
		}
	
		request.setAttribute("retjson", obj.toString());
		request.setAttribute("result", "success");
		
		break;
	}
	
	request.getRequestDispatcher("request.jsp").forward(request,response);
%>