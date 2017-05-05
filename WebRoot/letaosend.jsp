<%@page import="net.sf.json.JSONObject,
				java.util.Map,
				util.TimeUtils,
				cache.Cache,
				org.apache.http.impl.client.HttpClients,
				org.apache.http.impl.client.CloseableHttpClient,
				java.net.URLDecoder,
				org.apache.logging.log4j.LogManager,
				java.io.BufferedReader,
				java.io.IOException,
				java.io.InputStream,
				java.io.InputStreamReader,
				java.io.UnsupportedEncodingException,
				java.nio.charset.Charset,
				java.util.ArrayList,
				java.util.List,
				org.apache.http.client.methods.HttpPost,
				org.apache.http.HttpResponse,
				org.apache.http.NameValuePair,
				org.apache.http.client.HttpClient,
				org.apache.http.client.entity.UrlEncodedFormEntity,
				org.apache.http.client.methods.HttpPost,
				org.apache.http.message.BasicNameValuePair,
				org.apache.http.protocol.HTTP,
				util.MD5Util,
				org.apache.logging.log4j.Logger"
		language="java" pageEncoding="UTF-8"
%><%!
	private static boolean logflag = true;
	private static Logger logger = LogManager.getLogger();
	
	private static String execute(HttpPost post){
		CloseableHttpClient http_client = null;
        try {
            http_client = HttpClients.createDefault();
            HttpResponse response = http_client.execute(post);
            if(response.getStatusLine().getStatusCode() == 404){
                throw new IOException("Network Error");
            };
            InputStream is = response.getEntity().getContent();
            BufferedReader br = new BufferedReader(new InputStreamReader(is, Charset.forName("UTF-8")));
            StringBuilder sb = new StringBuilder();
            String line = null;
            while ((line = br.readLine()) != null) {
                sb.append(line);
            }
            return sb.toString();
        } catch (IOException e) {
            return "";
        } finally {
        	try{
				http_client.close();
			} catch (Exception e) {
				logger.warn(e.getMessage(), 0);
			}
        }
	}
%><%
	//获取公共参数
	String taskid = request.getAttribute("taskid").toString(); 
	String routeid = request.getAttribute("routeid").toString();
	String phone = request.getAttribute("phone").toString();
	String packageid = request.getAttribute("package").toString();
	
	while(true){
		String ret = null;
		
		//检查通道参数, 每个通道有不同参数, 对应 ll_routes.api_params
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
		String cert = routeparams.get("cert");
		if(cert == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, cert is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String user_name = routeparams.get("user_name");
		if(user_name == null){
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, user_name is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		
		//参数准备, 每个通道不同
		String packagecode = null;
		
		if(routeid.equals("3027")){
			//河南
			if(packageid.equals("dx.5M")){
				packagecode = "59";
			}else if(packageid.equals("dx.10M")){
				packagecode = "60";
			}else if(packageid.equals("dx.30M")){
				packagecode = "61";
			}else if(packageid.equals("dx.50M")){
				packagecode = "62";
			}else if(packageid.equals("dx.100M")){
				packagecode = "63";
			}else if(packageid.equals("dx.200M")){
				packagecode = "64";
			}else if(packageid.equals("dx.500M")){
				packagecode = "70";
			}else if(packageid.equals("dx.1G")){
				packagecode = "71";
			}
		}else if(routeid.equals("1187")){
			//广东省内
			if(packageid.equals("yd.200M")){
				packagecode = "164";
			}
		}else if(routeid.equals("3028")){
			//浙江
			if(packageid.equals("dx.5M")){
				packagecode = "72";
			}else if(packageid.equals("dx.10M")){
				packagecode = "73";
			}else if(packageid.equals("dx.30M")){
				packagecode = "74";
			}else if(packageid.equals("dx.50M")){
				packagecode = "75";
			}else if(packageid.equals("dx.100M")){
				packagecode = "76";
			}else if(packageid.equals("dx.200M")){
				packagecode = "77";
			}else if(packageid.equals("dx.500M")){
				packagecode = "78";
			}else if(packageid.equals("dx.1G")){
				packagecode = "79";
			}
		}else if(routeid.equals("3029")){
			//江苏
			if(packageid.equals("dx.5M")){
				packagecode = "80";
			}else if(packageid.equals("dx.10M")){
				packagecode = "81";
			}else if(packageid.equals("dx.30M")){
				packagecode = "82";
			}else if(packageid.equals("dx.50M")){
				packagecode = "83";
			}else if(packageid.equals("dx.100M")){
				packagecode = "84";
			}else if(packageid.equals("dx.200M")){
				packagecode = "85";
			}else if(packageid.equals("dx.500M")){
				packagecode = "86";
			}else if(packageid.equals("dx.1G")){
				packagecode = "87";
			}
		}else if(routeid.equals("3030")){
			//湖北
			if(packageid.equals("dx.5M")){
				packagecode = "88";
			}else if(packageid.equals("dx.10M")){
				packagecode = "89";
			}else if(packageid.equals("dx.30M")){
				packagecode = "90";
			}else if(packageid.equals("dx.50M")){
				packagecode = "91";
			}else if(packageid.equals("dx.100M")){
				packagecode = "92";
			}else if(packageid.equals("dx.200M")){
				packagecode = "93";
			}else if(packageid.equals("dx.500M")){
				packagecode = "94";
			}else if(packageid.equals("dx.1G")){
				packagecode = "95";
			}
		}else if(routeid.equals("3031")){
			//福建
			if(packageid.equals("dx.5M")){
				packagecode = "96";
			}else if(packageid.equals("dx.10M")){
				packagecode = "97";
			}else if(packageid.equals("dx.30M")){
				packagecode = "98";
			}else if(packageid.equals("dx.50M")){
				packagecode = "99";
			}else if(packageid.equals("dx.100M")){
				packagecode = "100";
			}else if(packageid.equals("dx.200M")){
				packagecode = "101";
			}else if(packageid.equals("dx.500M")){
				packagecode = "102";
			}else if(packageid.equals("dx.1G")){
				packagecode = "103";
			}
		}else if(routeid.equals("3032")){
			//上海
			if(packageid.equals("dx.5M")){
				packagecode = "104";
			}else if(packageid.equals("dx.10M")){
				packagecode = "105";
			}else if(packageid.equals("dx.30M")){
				packagecode = "106";
			}else if(packageid.equals("dx.50M")){
				packagecode = "107";
			}else if(packageid.equals("dx.100M")){
				packagecode = "108";
			}else if(packageid.equals("dx.200M")){
				packagecode = "109";
			}else if(packageid.equals("dx.500M")){
				packagecode = "110";
			}else if(packageid.equals("dx.1G")){
				packagecode = "111";
			}
		}else if(routeid.equals("3033")){
			//辽宁
			if(packageid.equals("dx.5M")){
				packagecode = "112";
			}else if(packageid.equals("dx.10M")){
				packagecode = "113";
			}else if(packageid.equals("dx.30M")){
				packagecode = "114";
			}else if(packageid.equals("dx.50M")){
				packagecode = "115";
			}else if(packageid.equals("dx.100M")){
				packagecode = "116";
			}else if(packageid.equals("dx.200M")){
				packagecode = "117";
			}else if(packageid.equals("dx.500M")){
				packagecode = "118";
			}else if(packageid.equals("dx.1G")){
				packagecode = "119";
			}
		}else if(routeid.equals("3034")){
			//吉林
			if(packageid.equals("dx.5M")){
				packagecode = "120";
			}else if(packageid.equals("dx.10M")){
				packagecode = "121";
			}else if(packageid.equals("dx.30M")){
				packagecode = "122";
			}else if(packageid.equals("dx.50M")){
				packagecode = "123";
			}else if(packageid.equals("dx.100M")){
				packagecode = "124";
			}else if(packageid.equals("dx.200M")){
				packagecode = "125";
			}else if(packageid.equals("dx.500M")){
				packagecode = "126";
			}else if(packageid.equals("dx.1G")){
				packagecode = "127";
			}
		}else if(routeid.equals("3035")){
			//安徽
			if(packageid.equals("dx.5M")){
				packagecode = "128";
			}else if(packageid.equals("dx.10M")){
				packagecode = "129";
			}else if(packageid.equals("dx.30M")){
				packagecode = "130";
			}else if(packageid.equals("dx.50M")){
				packagecode = "131";
			}else if(packageid.equals("dx.100M")){
				packagecode = "132";
			}else if(packageid.equals("dx.200M")){
				packagecode = "133";
			}else if(packageid.equals("dx.500M")){
				packagecode = "134";
			}else if(packageid.equals("dx.1G")){
				packagecode = "135";
			}
		}else if(routeid.equals("3036")){
			//云南
			if(packageid.equals("dx.1G")){
				packagecode = "143";
			}else if(packageid.equals("dx.500M")){
				packagecode = "142";
			}else if(packageid.equals("dx.200M")){
				packagecode = "141";
			}else if(packageid.equals("dx.100M")){
				packagecode = "140";
			}else if(packageid.equals("dx.300M")){
				packagecode = "160";
			}else if(packageid.equals("dx.2G")){
				packagecode = "161";
			}else if(packageid.equals("dx.3G")){
				packagecode = "162";
			}
		}else if(routeid.equals("3037")){
			//四川
			if(packageid.equals("dx.5M")){
				packagecode = "144";
			}else if(packageid.equals("dx.10M")){
				packagecode = "145";
			}else if(packageid.equals("dx.30M")){
				packagecode = "146";
			}else if(packageid.equals("dx.50M")){
				packagecode = "147";
			}else if(packageid.equals("dx.100M")){
				packagecode = "148";
			}else if(packageid.equals("dx.200M")){
				packagecode = "149";
			}else if(packageid.equals("dx.500M")){
				packagecode = "150";
			}else if(packageid.equals("dx.1G")){
				packagecode = "151";
			}
		}else if(routeid.equals("3038")){
			//广西
			if(packageid.equals("dx.5M")){
				packagecode = "152";
			}else if(packageid.equals("dx.10M")){
				packagecode = "153";
			}else if(packageid.equals("dx.30M")){
				packagecode = "154";
			}else if(packageid.equals("dx.50M")){
				packagecode = "155";
			}else if(packageid.equals("dx.100M")){
				packagecode = "156";
			}else if(packageid.equals("dx.200M")){
				packagecode = "157";
			}else if(packageid.equals("dx.500M")){
				packagecode = "158";
			}else if(packageid.equals("dx.1G")){
				packagecode = "159";
			}
		}else if(routeid.equals("3039")){
			//广东
			if(packageid.equals("dx.5M")){
				packagecode = "17";
			}else if(packageid.equals("dx.10M")){
				packagecode = "16";
			}else if(packageid.equals("dx.30M")){
				packagecode = "18";
			}else if(packageid.equals("dx.50M")){
				packagecode = "19";
			}else if(packageid.equals("dx.100M")){
				packagecode = "20";
			}else if(packageid.equals("dx.200M")){
				packagecode = "21";
			}else if(packageid.equals("dx.500M")){
				packagecode = "22";
			}else if(packageid.equals("dx.1G")){
				packagecode = "23";
			}
		}else if(routeid.equals("1094")){
			//山东移动
			if(packageid.equals("yd.10M")){
				packagecode = "200";
			}else if(packageid.equals("yd.30M")){
				packagecode = "201";
			}else if(packageid.equals("yd.70M")){
				packagecode = "202";
			}else if(packageid.equals("yd.150M")){
				packagecode = "203";
			}else if(packageid.equals("yd.500M")){
				packagecode = "204";
			}else if(packageid.equals("yd.1G")){
				packagecode = "205";
			}else if(packageid.equals("yd.2G")){
				packagecode = "206";
			}else if(packageid.equals("yd.3G")){
				packagecode = "207";
			}else if(packageid.equals("yd.4G")){
				packagecode = "208";
			}else if(packageid.equals("yd.6G")){
				packagecode = "209";
			}else if(packageid.equals("yd.11G")){
				packagecode = "210";
			}
		}else if(routeid.equals("1181")){
			//广东移动
			if(packageid.equals("yd.10M")){
				packagecode = "2";
			}else if(packageid.equals("yd.30M")){
				packagecode = "3";
			}else if(packageid.equals("yd.70M")){
				packagecode = "4";
			}else if(packageid.equals("yd.150M")){
				packagecode = "5";
			}else if(packageid.equals("yd.500M")){
				packagecode = "6";
			}else if(packageid.equals("yd.1G")){
				packagecode = "7";
			}else if(packageid.equals("yd.2G")){
				packagecode = "8";
			}else if(packageid.equals("yd.3G")){
				packagecode = "9";
			}else if(packageid.equals("yd.4G")){
				packagecode = "10";
			}else if(packageid.equals("yd.6G")){
				packagecode = "11";
			}else if(packageid.equals("yd.11G")){
				packagecode = "12";
			}
		}else if(routeid.equals("3184")){
			//全国电信
			if(packageid.equals("dx.5M")){
				packagecode = "505";
			}else if(packageid.equals("dx.10M")){
				packagecode = "506";
			}else if(packageid.equals("dx.30M")){
				packagecode = "507";
			}else if(packageid.equals("dx.50M")){
				packagecode = "508";
			}else if(packageid.equals("dx.100M")){
				packagecode = "509";
			}else if(packageid.equals("dx.200M")){
				packagecode = "510";
			}else if(packageid.equals("dx.500M")){
				packagecode = "511";
			}else if(packageid.equals("dx.1G")){
				packagecode = "512";
			}
		}else if(routeid.equals("2056")){
			//全国联通
			if(packageid.equals("lt.20M")){
				packagecode = "28";
			}else if(packageid.equals("lt.50M")){
				packagecode = "29";
			}else if(packageid.equals("lt.100M")){
				packagecode = "30";
			}else if(packageid.equals("lt.200M")){
				packagecode = "31";
			}else if(packageid.equals("lt.500M")){
				packagecode = "32";
			}else if(packageid.equals("lt.300M")){
				packagecode = "199";
			}
		}
		if(packagecode == null){
			request.setAttribute("result", "S." + routeid + ":unrecognized package@" + TimeUtils.getSysLogTimeString());
			break;
		}
		
		String call_name = "OrderCreate";
        long timestamp = System.currentTimeMillis()/1000L;
        String signature = MD5Util.getLowerMD5(timestamp + cert);
        HttpPost post = new HttpPost(url);
        post.setHeader("API-USER-NAME", user_name);
        post.setHeader("API-NAME",call_name);
        post.setHeader("API-TIMESTAMP", timestamp + "");
        post.setHeader("API-SIGNATURE", signature);
        List<NameValuePair> param = new ArrayList <NameValuePair>();  
        param.add(new BasicNameValuePair("phone_number", phone));
        param.add(new BasicNameValuePair("product_id", packagecode));
		
		//在执行请求前先获取连接, 防止访问通道线程超量
		Cache.getConnection(routeid);
		try {
			//ret = HttpAccess.postNameValuePairRequest(url, params, "utf-8", "mysend");
			//ret = HttpAccess.postJsonRequest(url, json.toString(), "utf-8", "weikesend");
		 	//post.setEntity(new UrlEncodedFormEntity(param, HTTP.UTF_8));
		 	post.setEntity(new UrlEncodedFormEntity(param, "utf-8"));
            ret = execute(post);
		} catch (Exception e) {
			e.printStackTrace();
			logger.info(e.getMessage());
		} finally {
			//在执行请求后记得释放连接
			Cache.releaseConnection(routeid);
		}
	
		//这里判断结果, 每个通道情况不同, 成功的保存 success 到 result 中并返回到 request.jsp
		if (ret != null && ret.trim().length() > 0) {
			logger.info("letao send ret = " + ret);
			try {
				JSONObject retjson = JSONObject.fromObject(ret);
				String retCode = retjson.getString("ack"); //":"MOB00001"
				Object obj = retjson.get("order_number");
				String rpid = null;
				if(obj != null && obj.toString().trim().length() > 0){
					rpid = obj.toString();
				}
				String message = retjson.getString("message");
				if(retCode.equals("success") && rpid != null){
					request.setAttribute("result", "success");
					request.setAttribute("reportid", rpid);
				}else{
					request.setAttribute("code", 1);
					request.setAttribute("result", "R." + routeid + ":" + message + "@" + TimeUtils.getSysLogTimeString());
				}
				request.setAttribute("orgreturn", ret);
			} catch (Exception e) {
				e.printStackTrace();
				logger.info(e.getMessage());
				request.setAttribute("result", "R." + routeid + ":" + e.getMessage() + "@" + TimeUtils.getSysLogTimeString());
			}
		} else {
			request.setAttribute("result", "R." + routeid + ":fail@" + TimeUtils.getSysLogTimeString());
		}
		
		break;
	}

	request.getRequestDispatcher("request.jsp").forward(request,response);
%>