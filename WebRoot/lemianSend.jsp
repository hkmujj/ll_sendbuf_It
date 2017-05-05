<%@page import="com.alibaba.fastjson.JSON"%>
<%@page import="com.alibaba.fastjson.JSONObject"%>
<%@page import="java.io.IOException"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.security.MessageDigest"%>
<%@page import="java.io.InputStreamReader"%>
<%@page import="java.net.URLConnection"%>
<%@page import="java.net.URL"%>
<%@page import="java.io.BufferedReader"%>
<%@page import="cache.Cache"%>
<%@page import="util.TimeUtils"%>
<%@page import="org.apache.logging.log4j.LogManager"%>
<%@page import="org.apache.logging.log4j.Logger"%>
<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%

	//获取公共参数
	String taskid = request.getAttribute("taskid").toString();
	String routeid = request.getAttribute("routeid").toString();
	String phone = request.getAttribute("phone").toString();
	String packageid = request.getAttribute("package").toString();
	logger.info("lemian"+routeid+" entry1");
	
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
			String SendUrl = routeparams.get("SendUrl");
			if(SendUrl == null){
				request.setAttribute("result", "S." + routeid + ":wrong routeparams, SendUrl is null@" + TimeUtils.getSysLogTimeString());
				break;
			}
			
			String sendLogPath = routeparams.get("sendLogPath");
			if(sendLogPath == null){
				request.setAttribute("result", "S." + routeid + ":wrong routeparams, sendLogPath is null@" + TimeUtils.getSysLogTimeString());
				break;
			}
			String result="";
			
			String flow = ""; 
			//检查通道参数, 每个通道有不同参数, 对应 ll_routes.api_param
			String packagecodeArray[] = packageid.split("\\.");
			flow=packagecodeArray[1];
			if (flow.contains("G")) {
					flow = Integer.parseInt(flow.substring(0,
							flow.length() - 1))
							* 1024 + "M";
			}
			flow=flow.replace("M", "");
			
			String stamp = new SimpleDateFormat("MMddHHmmss").format(new Date());
            UserName=java.net.URLEncoder.encode(UserName,"utf-8");//我公司提供用户名
            Password=md5(Password + stamp);//我公司提供密码
            
            //组合需要加密的字符串
            String strAes= String.format("%s,%s,%s,%s,%s,%s",
            UserId, UserName, Password,phone, flow, stamp);
            //加密
            String secret = md5(strAes);
            String strParam = String.format(
            "UserId=%s&UserName=%s&Password=%s&mobile=%s&flow=%s&stamp=%s&secret=%s",
            UserId, UserName, Password,phone, flow, stamp, secret);
            
            
            
			/************************************/
			//request.setAttribute("result", "success");
			//break;
			/************************************/
			
			//在执行请求前先获取连接, 防止访问通道线程超量
			
			
			Cache.getConnection(routeid);
			try {
				result= sendGet(SendUrl,strParam);
				logger.info("send "+routeid+" result = " + result);
			} catch (Exception e) {
				e.printStackTrace();
				logger.error("err:" + e.getMessage(), e);
			} finally {
				logger.info("lemain pos5");
				//在执行请求后记得释放连接
				Cache.releaseConnection(routeid);
			}
			
			logger.info("lemain pos1");
             JSONObject jbn = JSON.parseObject(result);
		String status=jbn.getString("status");
		String msgid=jbn.getString("msgid");
		String description=jbn.getString("description");
		
		logger.info("lemain pos2");
			if (status.equals("1")) {
				request.setAttribute("result", "success");
				request.setAttribute("reportid", msgid);
				request.setAttribute("orgreturn", status+":"+ new String(description.getBytes("gbk") , "utf-8"));
				logger.info("lemain pos3");
			} else {
				request.setAttribute("result", "R." + routeid + ":"
						+ status+":"+description + "@" + TimeUtils.getSysLogTimeString());
				logger.info("lemain pos4");
			}

			break;
			
		}
	} catch (Exception e) {
		e.printStackTrace();
		logger.error(e.toString(), e);
		request.setAttribute(
				"result",
				"R." + routeid + ":" + e.toString() + "@"
						+ TimeUtils.getSysLogTimeString());
	}
	
	request.getRequestDispatcher("request.jsp").forward(request,response);
%>

<%!
	public static boolean logflag = true;
	public static Logger logger = LogManager.getLogger();
	
private final static String md5(String s) {
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
		
		logger.info("lemain url = " + urlNameString);
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
			logger.error(e.getMessage(), e);
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

