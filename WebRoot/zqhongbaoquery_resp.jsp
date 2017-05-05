<%@page import="com.aspire.portal.web.security.client.GenerateSignature"%>
<%@page import="net.sf.json.JSONObject"%>
<%@page import="util.TimeUtils"%>
<%@page import="database.LLTempDatabase"%>
<%@page import="database.DatabaseUtils"%>
<%@page import="http.HttpAccess"%>
<%@page import="org.dom4j.io.XMLWriter"%>
<%@page import="org.dom4j.io.OutputFormat"%>
<%@page import="java.io.StringWriter"%>
<%@page import="key.Key"%>

<%@ page language="java" import="java.util.*,
								org.apache.logging.log4j.LogManager,
								org.apache.logging.log4j.Logger,
								java.util.Map.Entry,
							
								org.dom4j.Element,
								org.dom4j.DocumentHelper,
								org.dom4j.Document,
								java.sql.Connection,
								java.sql.PreparedStatement,
								java.sql.ResultSet,
								java.util.HashMap,
								java.util.LinkedHashMap"
					pageEncoding="UTF-8"
%><%!
	private static boolean logflag = true;
	private static Logger logger = LogManager.getLogger();
	
	private static String getStatus(String userid){
		String ids = LLTempDatabase.getMapValue("zqydhongbao", userid, "06");
		logger.info("letian ids="+ ids);
		if(ids == null||ids.trim().length() <= 0 ){
		return "S.@查询不到订单号";
		}
			Map<String, String> parm = new HashMap<String, String>();
			parm.put("portalType", ids.substring(0,3));
			parm.put("portalID", ids.substring(3,13));
			String t = String.valueOf(System.currentTimeMillis());
			parm.put("transactionID", TimeUtils.getTimeStamp().substring(2) + t.substring(0, 8));
			parm.put("method", "companyDonateFlow");
			parm.put("mobile", ids.substring(ids.length() - 11));
			parm.put("sequence", ids.substring(0, ids.length() - 11));
			StringBuffer sb = new StringBuffer();

			sb.append("method=");
			sb.append(parm.get("method"));
			sb.append("&mobile=");
			sb.append(parm.get("mobile"));
			sb.append("&portalID=");
			sb.append(parm.get("portalID"));
			sb.append("&portalType=");
			sb.append(parm.get("portalType"));
			sb.append("&sequence=");
			sb.append(parm.get("sequence"));
			sb.append("&transactionID=");
			sb.append(parm.get("transactionID"));
			logger.info("zqhongbaostatus2 sign string=" + sb.toString());
			GenerateSignature gs = new GenerateSignature();
			String path = Key.keypath + "liulianghongbao/rasPrivateKey.txt";
			if(ids.substring(0,3).equals("WWW")){
			 path = Key.keypath + "liulianghongbao/private.key";
			}
			String sign = gs.sign(sb.toString(), path);
			parm.put("sign", sign);

			String ret ="";
			//发送查询/获取状态前先获取连接, 防止访问线程超量
			try{
				 ret = http.HttpAccess.postNameValuePairRequest("http://gd.liuliangjia.cn:20811/openapi/v2.0", parm, "utf-8", "zqhongbaostatus2");
			}catch(Exception e){
				e.printStackTrace();
				logger.info(e.getMessage());
				return userid + ":查询失败@查询错误，查询错误";
				
			}finally{
				//发送查询/获取状态后释放连接
			}

			//这里判断结果, 每个通道情况不同, 成功的节点ID对应success, 失败的对应失败信息
			if(ret != null && ret.trim().length() > 0){
				//request.setAttribute("result", "success");
				logger.info("zqydhongbao  status ret = " + ret);
				try{
					JSONObject robj = JSONObject.fromObject(ret);
					String retCode = robj.getString("code");
					if(retCode.equals("0")){
						JSONObject jsondata = robj.getJSONObject("result");
						String staus = jsondata.getString("retCode");
						if(staus.equals("0")){
						return userid+":"+"充值成功";
						}else if(staus.trim().length() == 0){
						return userid+":"+"充值中";
						}else if(staus.trim().length() > 0){
							String msg = "失败";
							if(jsondata.get("reqMsg") != null){
								msg = jsondata.getString("reqMsg");
							}
							return userid + ":充值失败, 失败码:"+staus+", 失败原因:" + msg;
						}else{
							logger.info("zqydhongbao  status : [" + ret + "]充值中@" + TimeUtils.getSysLogTimeString());
							return userid + ":查询失败@查询返回 : [" + ret + "]";

						}
					}else{
						logger.info("zqydhongbao  status : [" + ret + "]状态码" + retCode + "@" + TimeUtils.getSysLogTimeString());
						return userid + ":查询失败@查询返回 : [" + ret + "]";
					}
				}catch(Exception e){
					logger.warn(e.getMessage(), e);
					logger.info("zqydhongbao  status : " + e.getMessage() + ", ret = " + ret + "@" + TimeUtils.getSysLogTimeString());
					return userid + ":查询失败@查询返回 : [" + ret + "]";
					
				}
			}else{
				logger.info("zqydhongbao  status : " + "fail@" + TimeUtils.getSysLogTimeString());
				return userid + ":查询失败@查询没有返回 ";
				
			}
	}

%><%	
		logger.info("here");
		out.print("");
		String ret=getStatus(request.getParameter("userid"));
		out.print(ret);
		Thread.sleep(1000);
%>