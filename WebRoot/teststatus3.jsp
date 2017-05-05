<%@page import="test.TestOrder,
				test.TestCache,
				test.TestList,
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
%><%
	boolean logflag = true;
	Logger logger = LogManager.getLogger();
	
	String routeid = request.getAttribute("routeid").toString();
	
	if(request.getAttribute("ids") == null){
		request.setAttribute("result", "S." + routeid + ":parameter `ids` is needed@" + TimeUtils.getSysLogTimeString());
		request.getRequestDispatcher("request.jsp").forward(request,response);
		return;
	}
	
	String ids = request.getAttribute("ids").toString();
	
	
	while(true){
		JSONObject obj = new JSONObject();
		
		ArrayList<TestOrder> list = null;
		
		Cache.getStatusConnection(routeid);
		
		try {
			list = TestCache.getids(routeid, ids);
		} catch (Exception e) {
			e.printStackTrace();
			logger.info(e.getMessage());
		} finally {
			Cache.releaseStatusConnection(routeid);
		}
			
		Random rd = new Random();
		for(int i = 0; list != null && i < list.size(); i++){
			if(rd.nextInt(10) > -1){
				JSONObject rp = new JSONObject();
				rp.put("code", 1);
				rp.put("message", "R." + routeid + ":random fail@" + TimeUtils.getSysLogTimeString());
				rp.put("resp", "org fail");
				obj.put(list.get(i).id, rp);
				//obj.put(list.get(i).id, "R." + routeid + ":random fail@" + TimeUtils.getSysLogTimeString());
			}else{
				JSONObject rp = new JSONObject();
				rp.put("code", 0);
				rp.put("message", "success");
				rp.put("resp", "org success");
				obj.put(list.get(i).id, rp);
				//obj.put(list.get(i).id, "success");
			}
		}
	
		request.setAttribute("result", "success");
		request.setAttribute("retjson", obj.toString());
		
		break;
	}
	
	request.getRequestDispatcher("request.jsp").forward(request,response);
	//Log.logout("String = " + str, 0);
	//out.print((new MsgBufQuerier()).jsonRpc(str));
	//out.print("hello");%>