<%@page import="util.TimeUtils"%>
<%@page import="java.net.URLDecoder"%>
<%@page import="jxl.write.WritableSheet"%>
<%@page import="jxl.write.Label"%>
<%@page import="jxl.write.WritableWorkbook"%>
<%@page import="java.io.File"%>
<%@page import="jxl.Workbook"%>
<%@ page language="java" import="java.util.*,
								org.apache.logging.log4j.LogManager,
								org.apache.logging.log4j.Logger,
								java.util.Map.Entry,
								http.HttpAccess,
								org.dom4j.Element,
								org.dom4j.DocumentHelper,
								org.dom4j.Document,
								java.sql.Connection,
								java.sql.PreparedStatement,
								java.sql.ResultSet,
								java.util.HashMap,
								java.util.LinkedHashMap,
								database.DatabaseUtils
					" 
					pageEncoding="UTF-8"
%><%!
	private static boolean logflag = true;
	private static Logger logger = LogManager.getLogger();
	
	private static class StatusUnit {
		
		public String taskid;
		public String userid;
		public String code;
		public String info;
		public String linkid;
		public String phone;
		public String createtime;
		public String statustime;
		public String packagecode;
	
	}
	
	private static HashMap<String, StatusUnit> statusmap = null;
	
	private static boolean pushOneStatuses(String url, ArrayList<StatusUnit> statuslist){
		 String ret = null;
	     for(int i = 0; i < statuslist.size(); i++)
	     {
	     	Document document = DocumentHelper.createDocument();  
	     	Element root = document.addElement("root");//生成根节点<root>
	     
	    	StatusUnit statusUnit = statuslist.get(i);
		     
		    Element status = root.addElement("status");//生成子节点<status>
		     
		    status.addAttribute("taskid", statusUnit.taskid);//子节点status的属性<status taskid="" ...>
		    status.addAttribute("linkid", statusUnit.linkid);
		    status.addAttribute("code", statusUnit.code);
		    status.addAttribute("message", statusUnit.info);
		    status.addAttribute("time", statusUnit.statustime);
		    
		    String xml=root.asXML();
	     
			logger.info("\n--push cc status--\nurl=" + url + "\n" + xml + "\n--push status over--\n");
		 
	     	ret = HttpAccess.postXmlRequest(url, xml, "utf-8", "mark");//提交xml内容
	     	
	     	if(ret.indexOf("success") < 0){
	     	
				logger.error("push one status fail : " + ret);
			}
	     }
	     
	     return true;
	}
	
	private static String outdata(ArrayList<StatusUnit> statuslist){
		String path1 = null;
		String path2 = null;
		String path = HttpAccess.class.getResource("").getPath();
		try {
			path = URLDecoder.decode(path,"UTF-8");
		} catch (Exception e) {
			System.out.println(e.getMessage());;
		}
		//String path = "D:/software/tomcat7/apache-tomcat-7.0.57-windows-x64/apache-tomcat-7.0.57/webapps/ll_sendbuf/";
		logger.info("path = " + path);

		String newpath = path.split("WEB-INF")[0];
		logger.info("newpath = " + newpath);
		path = null;
		String time = TimeUtils.getTimeStamp();
		String uid = statuslist.get(0).userid;
		try{ 
			path2 = "data/" + uid + "_" + time + new Random().nextInt(1000) +".xls";
			path1 = newpath + path2;
			//打开文件 
			WritableWorkbook book=Workbook.createWorkbook(new File(path1));
			//生成名为“第一页”的工作表，参数0表示这是第一页 
			WritableSheet sheet=book.createSheet("第一页", 0);
			//在Label对象的构造子中指名单元格位置是第一列第一行(0,0) 
			//以及单元格内容为test 
			Label label1 = new Label(0,0,"平台订单号");
			Label label2 = new Label(1,0,"用户账号");
			Label label3 = new Label(2,0,"充值手机号");	
			Label label4 = new Label(3,0,"下单时间");
			Label label5 = new Label(4,0,"客户订单号");
			Label label6 = new Label(5,0,"包规格");
			Label label7 = new Label(6,0,"状态值");
			Label label8 = new Label(7,0,"状态说明");
			//将定义好的单元格添加到工作表中 
			sheet.addCell(label1);
			sheet.addCell(label2);
			sheet.addCell(label3);
			sheet.addCell(label4);
			sheet.addCell(label5);
			sheet.addCell(label6);
			sheet.addCell(label7);
			sheet.addCell(label8);

			for(int i = 0;i < statuslist.size(); i++){
				int row = 1;
				String taskid = statuslist.get(i).taskid;
				String userid = statuslist.get(i).userid;
				String phone = statuslist.get(i).phone;
				String createtime = statuslist.get(i).createtime;
				String linkid = statuslist.get(i).linkid;
				String packagecode = statuslist.get(i).packagecode;
				String code = statuslist.get(i).code;
				String info = statuslist.get(i).info;
				
				Label lab1 = new Label(0,row,taskid);
				Label lab2 = new Label(1,row,userid);
				Label lab3 = new Label(2,row,phone);
				Label lab4 = new Label(3,row,createtime);
				Label lab5 = new Label(4,row,linkid);
				Label lab6 = new Label(5,row,packagecode);
				Label lab7 = new Label(6,row,code);
				Label lab8 = new Label(7,row,info);
				sheet.addCell(lab1);
				sheet.addCell(lab2);
				sheet.addCell(lab3);
				sheet.addCell(lab4);
				sheet.addCell(lab5);
				sheet.addCell(lab6);
				sheet.addCell(lab7);
				sheet.addCell(lab8);
			}
			//写入数据并关闭文件 
			book.write(); 
			book.close(); 
			}catch(Exception e) { 
				e.printStackTrace();
		}	
		return path2;
	}
	
	
	
	
	private static boolean pushStatuses(String url, ArrayList<StatusUnit> statuslist){
		 Document document = DocumentHelper.createDocument();  
	     Element root = document.addElement("root");//生成根节点<root>
	     for(int i=0;i<statuslist.size();i++)
	     {
	    	 StatusUnit statusUnit = statuslist.get(i);
		     
		     Element status = root.addElement("status");//生成子节点<status>
		     
		     status.addAttribute("taskid", statusUnit.taskid);//子节点status的属性<status taskid="" ...>
		     status.addAttribute("linkid", statusUnit.linkid);
		     status.addAttribute("code", statusUnit.code);
		     status.addAttribute("message", statusUnit.info);
		     status.addAttribute("time", statusUnit.statustime);
		    
	     }
	     String xml=root.asXML();
	     
		 logger.info("\n--push status--\n" + xml + "\n--push status over--\n");
		 
	     String ret = HttpAccess.postXmlRequest(url, xml, "utf-8", "mark");//提交xml内容
	     
		if(ret.indexOf("success") >= 0){
			return true;
		}else{
			logger.error("push status fail : " + ret);
		}
	     
	     return false;
	}
	
	private static ArrayList<StatusUnit> getStatusUnits(String userid, String qdate, String cdt, ArrayList<String> cdtval) {
		Connection conn = null;
		PreparedStatement psm = null;
		ResultSet rs = null;
		
		ArrayList<StatusUnit> ret = new ArrayList<StatusUnit>();
		try {
			conn = DatabaseUtils.getLLMainDBConnByJNDI();
			if(conn == null){
				return ret;
			}
			
			StringBuffer sql = new StringBuffer();
			sql.append("select id,sd_linkid,sd_phone,sd_packageid,sds_time,rp_code,rp_info,rp_time from rec_task");
			sql.append(Integer.parseInt(qdate));
			sql.append(" where sd_userid=? and rp_code is not null and ");
			sql.append(cdt);
			sql.append(" in (");
			for(int i = 0; i < cdtval.size(); i++){
				if(i > 0){
					sql.append(",");
				}
				sql.append("?");
			}
			sql.append(")");
			
			psm = conn.prepareStatement(sql.toString());
			psm.setInt(1, Integer.parseInt(userid));
			for(int i = 0; i < cdtval.size(); i++){
				psm.setString(2 + i, cdtval.get(i));
			}
			
			logger.info("status_query.jsp psm = " + psm.toString());
			rs = psm.executeQuery();
			
			while(rs.next()){
				StatusUnit unit = new StatusUnit();
				
				unit.taskid = rs.getString("id");
				unit.userid = userid;
				unit.code = rs.getString("rp_code");
				unit.info = rs.getString("rp_info");
				unit.linkid = rs.getString("sd_linkid");
				if(unit.linkid == null){
					unit.linkid = "";
				}
				unit.phone = rs.getString("sd_phone");
				unit.createtime = rs.getString("sds_time").substring(0, 19);
				unit.packagecode = rs.getString("sd_packageid").substring(3);
				unit.statustime = rs.getString("rp_time").substring(0, 19);
				
				ret.add(unit);
			}
			rs.close();
			rs = null;
			psm.close();
			psm = null;
			conn.close();
			conn = null;
		} catch (Exception e) {
			logger.warn("status_query.jsp getStatusUnits error", e);
			e.printStackTrace();
		} finally {
			try {
				if(rs!=null){
					rs.close();
					rs=null;
				}  
				if(psm!=null){
					psm.close();
					psm=null;
				} 				  
				if(conn != null){
					if(!conn.isClosed()){
						conn.close();
					}
				}
			} catch (Exception e2) {
			}
        }	
        
		return ret;
	}
	
	private static String getUrl(String userid) {
		Connection conn = null;
		PreparedStatement psm = null;
		ResultSet rs = null;
		
		String ret = null;
		
		try {
			conn = DatabaseUtils.getLLMainDBConnByJNDI();
			if(conn == null){
				return ret;
			}
			
			StringBuffer sql = new StringBuffer();
			sql.append("select api_callback from ll_users where id=?");
			psm = conn.prepareStatement(sql.toString());
			psm.setInt(1, Integer.parseInt(userid));
			
			rs = psm.executeQuery();
			
			if(rs.next()){
				ret = rs.getString("api_callback");
			}
			rs.close();
			rs = null;
			psm.close();
			psm = null;
			conn.close();
			conn = null;
		} catch (Exception e) {
			logger.warn("status_query.jsp getUrl error", e);
			e.printStackTrace();
		} finally {
			try {
				if(rs!=null){
					rs.close();
					rs=null;
				}  
				if(psm!=null){
					psm.close();
					psm=null;
				} 				  
				if(conn != null){
					if(!conn.isClosed()){
						conn.close();
					}
				}
			} catch (Exception e2) {
			}
        }	
        
		return ret;
	}
%><%
	String path = request.getContextPath();
	String basePath = request.getScheme()+"://"+request.getServerName()+":"+request.getServerPort()+path+"/";

	String acr = request.getParameter("acr");
   	if((session.getAttribute("admin") != null && session.getAttribute("admin").equals("yes"))){
   		session.setAttribute("admin", "yes");
   	}else{
   		out.println("~");
  		return;
   	}
   	
   	Map<String, String[]> paramMap = request.getParameterMap();
   	
	if(paramMap != null){
		for(Entry<String, String[]> param : paramMap.entrySet()){
			logger.info("query key = " + param.getKey() + ", value = " + param.getValue()[0]);
		}
	}
	
	String act = paramMap.get("act")[0].toString();
	if(act.equals("pushstatus")){
		String ids = paramMap.get("ids")[0].toString();
		if(ids.trim().length() <= 0){
			out.print("没有选中要推送状态的订单");
			return;
		}
		
		String[] idarr = ids.split(",");
		ArrayList<StatusUnit> statuslist = new ArrayList<StatusUnit>();
		for(int i = 0; i < idarr.length; i++){
			StatusUnit unit = statusmap.get(idarr[i]);
			statuslist.add(unit);
		}
		
		if(statuslist.size() <= 0){
			out.print("没有符合的订单号");
			return;
		}
		
		String url = getUrl(statuslist.get(0).userid);
		if(url == null || url.trim().length() <= 0){
			out.print("用户没有配置回调地址");
			return;
		}
		
		boolean retb = pushStatuses(url, statuslist);
		
		if(retb){
			out.print("success");
		}else{
			out.print("fail");
		}
		
		return;
	}else if(act.equals("outdata")){
		String ids = paramMap.get("ids")[0].toString();
		if(ids.trim().length() <= 0){
			out.print("没有选中要导出的订单");
			return;
		}
		
		String[] idarr = ids.split(",");
		ArrayList<StatusUnit> statuslist = new ArrayList<StatusUnit>();
		for(int i = 0; i < idarr.length; i++){
			StatusUnit unit = statusmap.get(idarr[i]);
			statuslist.add(unit);
		}
		
		if(statuslist.size() <= 0){
			out.print("没有符合的订单号");
			return;
		}
		
		String url = getUrl(statuslist.get(0).userid);
		if(url == null || url.trim().length() <= 0){
			out.print("用户没有配置回调地址");
			return;
		}
		
		out.clearBuffer();
		out.print(outdata(statuslist));
		
		return;
	}else if(act.equals("pushonestatus")){
		String ids = paramMap.get("ids")[0].toString();
		if(ids.trim().length() <= 0){
			out.print("没有选中要推送状态的订单");
			return;
		}
		
		String[] idarr = ids.split(",");
		ArrayList<StatusUnit> statuslist = new ArrayList<StatusUnit>();
		for(int i = 0; i < idarr.length; i++){
			StatusUnit unit = statusmap.get(idarr[i]);
			statuslist.add(unit);
		}
		
		if(statuslist.size() <= 0){
			out.print("没有符合的订单号");
			return;
		}
		
		String url = getUrl(statuslist.get(0).userid);
		if(url == null || url.trim().length() <= 0){
			out.print("用户没有配置回调地址");
			return;
		}
		
		boolean retb = pushOneStatuses(url, statuslist);
		
		if(retb){
			out.print("success");
		}else{
			out.print("fail");
		}
		
		return;
	}
	
	
	
	String userid = paramMap.get("userid")[0].toString();
	String qdate = paramMap.get("qdate")[0].toString();
	String cdt = paramMap.get("cdt")[0].toString();
	String cdtval = paramMap.get("cdtval")[0].toString();
	
	String vtip = "";
	if(cdt.equals("phone")){
		cdt = "sd_phone";
		vtip = "充值手机号";
	}else if(cdt.equals("linkid")){
		cdt = "sd_linkid";
		vtip = "客户订单号";
	}else if(cdt.equals("taskid")){
		cdt = "id";
		vtip = "平台订单号";
	}else{
		return;
	}
	
	String[] vals = cdtval.replace("\r", "\n").replace("\n\n", "\n").split("\n");
	ArrayList<String> vallist = new ArrayList<String>();
	for(int i = 0; i < vals.length; i++){
		String val = vals[i].trim();
		if(val.length() > 0){
			vallist.add(val);
			logger.info("legal param : " + val);
		}
	}
	
	if(vallist.size() <= 0){
		out.print("请输入需要查询的" + vtip);
		return;
	}
	
	ArrayList<StatusUnit> ret = getStatusUnits(userid, qdate, cdt, vallist);
	
	if(ret == null || ret.size() <= 0){
		out.print("没有搜索到相关数据");
		return;
	}
	
	statusmap = new HashMap<String, StatusUnit>();
	for(int i = 0; i < ret.size(); i++){
		statusmap.put(ret.get(i).taskid, ret.get(i));
	}
					
	out.print("<div>");
	out.print("<table class=\"gridtable\">");
	out.print("<tr>");
	out.print("<td style=\"background:#eee; width:5%; border-bottom:1px solid #555; border-right:1px solid #555;\">选择</td>");
	out.print("<td style=\"background:#eee; width:16%; border-bottom:1px solid #555; border-right:1px solid #555;\">平台订单号</td>");
	out.print("<td style=\"background:#eee; width:8%; border-bottom:1px solid #555; border-right:1px solid #555;\">用户账号</td>");
	out.print("<td style=\"background:#eee; width:12%; border-bottom:1px solid #555; border-right:1px solid #555;\">充值手机号</td>");
	out.print("<td style=\"background:#eee; width:15%; border-bottom:1px solid #555; border-right:1px solid #555;\">下单时间</td>");
	out.print("<td style=\"background:#eee; width:16%; border-bottom:1px solid #555; border-right:1px solid #555;\">客户订单号</td>");
	out.print("<td style=\"background:#eee; width:6%; border-bottom:1px solid #555; border-right:1px solid #555;\">包规格</td>");
	out.print("<td style=\"background:#eee; width:6%; border-bottom:1px solid #555; border-right:1px solid #555;\">状态值</td>");
	out.print("<td style=\"background:#eee; width:16%; border-bottom:1px solid #555; border-right:1px solid #555;\">状态说明</td>");
	out.print("</tr>");
	out.print("</table>");
	out.print("</div>");
	
	out.print("<div style=\"height:440px; overflow:auto; word-wrap:break-word;\">");
	out.print("<table class=\"gridtable\">");
	
	for(int i = 0; i < ret.size(); i++){
		StatusUnit unit = ret.get(i);
		out.print("<tr>");
		String color = "";
		if((i & 1) != 0){
			color = "background:#eee;";
		}
		out.print("<td style=\"");out.print(color);out.print("width:5%;\">");
		out.print("<input type=\"checkbox\" name=\"pushids\" value=\"");
		out.print(unit.taskid);
		out.print("\"/>");
		out.print("</td><td style=\"");out.print(color);out.print("width:16%;\">");
		out.print(unit.taskid);
		out.print("</td><td style=\"");out.print(color);out.print("width:8%;\">");
		out.print(unit.userid);
		out.print("</td><td style=\"");out.print(color);out.print("width:12%;\">");
		out.print(unit.phone);
		out.print("</td><td style=\"");out.print(color);out.print("width:15%;\">");
		out.print(unit.createtime);
		out.print("</td><td style=\"");out.print(color);out.print("width:16%;\">");
		out.print(unit.linkid);
		out.print("</td><td style=\"");out.print(color);out.print("width:6%;\">");
		out.print(unit.packagecode);
		out.print("</td><td style=\"");out.print(color);out.print("width:6%;\">");
		out.print(unit.code);
		out.print("</td><td style=\"");out.print(color);out.print("width:16%;\">");
		out.print(unit.info);
		out.print("</td></tr>");
	}
	
	out.print("</table>");
	out.print("</div>");
%>