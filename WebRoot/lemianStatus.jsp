<%@page import="com.alibaba.fastjson.JSONObject"%>
<%@page import="com.alibaba.fastjson.JSON"%>
<%@page import="com.alibaba.fastjson.JSONArray"%>
<%@page import="java.io.IOException"%>
<%@page import="java.io.InputStreamReader"%>
<%@page import="java.net.URLConnection"%>
<%@page import="java.net.URL"%>
<%@page import="java.io.BufferedReader"%>
<%@page import="java.security.MessageDigest"%>
<%@page import="util.TimeUtils"%>
<%@page import="cache.Cache"%>
<%@page import="org.apache.logging.log4j.LogManager"%>
<%@page import="org.apache.logging.log4j.Logger"%>
<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%
	boolean logflag = true;
	Logger logger = LogManager.getLogger();
	//获取公共参数
	String routeid = request.getAttribute("routeid").toString();
	logger.info("root "+routeid+"");

	try {
		while (true) {
			String ret = null;
			
			Map<String, String> routeparams = Cache.getRouteParams(routeid);
			if(routeparams == null){
				request.setAttribute("result", "S." + routeid + ":wrong routeparams@" + TimeUtils.getSysLogTimeString());
				break;
			}
			
			String UserId = routeparams.get("UserId");
			if(UserId == null){
				request.setAttribute("result", "S." + routeid + ":wrong routeparams, UserId is null@" + TimeUtils.getSysLogTimeString());
				break;
			}	
			
			String Password  = routeparams.get("Password");
			if(Password  == null){
				request.setAttribute("result", "S." + routeid + ":wrong routeparams, Password  is null@" + TimeUtils.getSysLogTimeString());
				break;
			}
			
			String UserName = routeparams.get("UserName");
			if(UserName == null){
				request.setAttribute("result", "S." + routeid + ":wrong routeparams, UserName is null@" + TimeUtils.getSysLogTimeString());
				break;
			}
			String CheckOneUrl = routeparams.get("CheckOneUrl");
			if(CheckOneUrl == null){
				request.setAttribute("result", "S." + routeid + ":wrong routeparams, CheckOneUrl is null@" + TimeUtils.getSysLogTimeString());
				break;
			}
			
			String checkBatchLogPath = routeparams.get("checkBatchLogPath");
			if(checkBatchLogPath == null){
				request.setAttribute("result", "S." + routeid + ":wrong routeparams, checkBatchLogPath is null@" + TimeUtils.getSysLogTimeString());
				break;
			}
			
			//
			String result="";
			UserName=java.net.URLEncoder.encode(UserName,"utf-8");//我公司提供用户名
	        Password=md5(Password);//我公司提供密码
	        String strParam = String.format("UserId=%s&UserName=%s&Password=%s",UserId, UserName, Password);
			logger.info("lemian "+routeid+" strParam = " + strParam);
			
			//发送查询/获取状态前先获取连接, 防止访问线程超量
			Cache.getStatusConnection(routeid);
			try {
			logger.info("status "+routeid+" status");
				result= sendGet(CheckOneUrl,strParam);
				//dyresponse = client.execute(dyrequest);
				logger.info("status "+routeid+" result = " + result);
			} catch (Exception e) {
				e.printStackTrace();
				logger.info(e.getMessage());
			} finally {
				//发送查询/获取状态后释放连接
				Cache.releaseStatusConnection(routeid);
			}
		JSONObject obj = new JSONObject();
		
		JSONObject jbn = JSON.parseObject(result);
		String status=jbn.getString("status");
		String description=jbn.getString("description");
		String reports=jbn.getString("reports");
		if(status.equals("1")){
		JSONArray reportsJsonArray= JSON.parseArray(reports);
		for(int i=0;i<reportsJsonArray.size();i++){
		JSONObject arrayjson=reportsJsonArray.getJSONObject(i);
			String mobile=arrayjson.getString("mobile");
			String msgid=arrayjson.getString("msgid");
			String time=arrayjson.getString("time");
			String statu=arrayjson.getString("status");
			String backTxt=mobile+","+msgid+","+time+","+statu;
			System.out.println(backTxt);
			JSONObject rp = new JSONObject();
			rp.put("resp", backTxt);
			if(statu.equals("00000")){
			rp.put("message", "success");
			rp.put("code", "0");
			}else{
			rp.put("message", statu);
			rp.put("code", "11");
			}
			obj.put(msgid, rp);
		}
		}
		request.setAttribute("retjson", obj.toString());
		request.setAttribute("result", "success");
		break;
		}
		
		logger.info(""+routeid+"stausTest");
	} catch (Exception e) {
		e.printStackTrace();
		logger.info("root "+routeid+""+e.toString());
		request.setAttribute(
				"result",
				"R." + routeid + ":" + e.toString() + "@"
						+ TimeUtils.getSysLogTimeString());
	}
	request.getRequestDispatcher("request.jsp").forward(request,
			response);
%>

<%!private final static String md5(String s) {
		    char hexDigits[] = { '0', '1', '2', '3', '4', '5', '6', '7', '8', '9',   
		            'A', 'B', 'C', 'D', 'E', 'F' };
		    try {   
		        byte[] strTemp = s.getBytes();   
		        MessageDigest mdTemp = MessageDigest.getInstance("MD5");   
		        mdTemp.update(strTemp);   
		        byte[] md = mdTemp.digest();   
				int j = md.length;   
		        char str[] = new char[j * 2];   
		        int k = 0;   
		        for (int i = 0; i < j; i++) {   
		           byte byte0 = md[i];   
		            str[k++] = hexDigits[byte0 >>> 4 & 0xf];   
		            str[k++] = hexDigits[byte0 & 0xf];   
		        }   
		        return new String(str);   
		    } catch (Exception e) {   
		        e.printStackTrace();   
		        return null;   
		    }   
		} 
    /**
     * 向指定URL发送GET方法的请求
     * 
     * @param url
     *            发送请求的URL
     * @param param
     *            请求参数，请求参数应该是 name1=value1&name2=value2 的形式。
     * @return URL 所代表远程资源的响应结果
     */
    public static String sendGet(String url, String param) throws Exception {
		String result = "";
		BufferedReader in = null;
		String urlNameString = url + "?" + param;
		try {
			URL realUrl = new URL(urlNameString);
			// 打开和URL之间的连接
			URLConnection connection = realUrl.openConnection();
			// 设置通用的请求属性
			connection.setRequestProperty("accept", "*/*");
			connection.setRequestProperty("connection", "Keep-Alive");
			connection.setRequestProperty("user-agent",
					"Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1;SV1)");
			// 建立实际的连接
			connection.connect();
			// 获取所有响应头字段
			Map<String, List<String>> map = connection.getHeaderFields();
			// 遍历所有的响应头字段
			for (String key : map.keySet()) {
				System.out.println(key + "--->" + map.get(key));
			}
			// 定义 BufferedReader输入流来读取URL的响应
			in = new BufferedReader(new InputStreamReader(
					connection.getInputStream()));
			String line;
			while ((line = in.readLine()) != null) {
				result += line;
			}
			// 使用finally块来关闭输入流
		} catch (Exception e) {
			// TODO: handle exception
			// e.printStackTrace();
			throw e;
		} finally {
			try {
				if (in != null) {
					in.close();
				}
			} catch (IOException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}

		return result;
	}%>
