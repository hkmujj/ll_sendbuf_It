<%@page import="java.text.SimpleDateFormat"%>
<%@page import="util.TimeUtils"%>
<%@page import="java.util.Random"%>
<%@ page language="java" import="http.HttpAccess,
						 		java.sql.Connection,
						 		java.sql.DriverManager,
						 		java.sql.PreparedStatement,
						 		java.sql.ResultSet,
						 		java.util.HashMap,
						 		java.io.*,
						 		jxl.*,
						 		java.util.Date,
						 		java.net.URLDecoder,
						 		jxl.write.*,
						 		org.apache.logging.log4j.LogManager,
								org.apache.logging.log4j.Logger,
						 		net.sf.json.JSONObject"
					pageEncoding="UTF-8"
%><%!
	private static boolean logflag = true;
	private static Logger logger = LogManager.getLogger();
	
	
	public static Date getDate(String datestr){
		SimpleDateFormat formatter = new SimpleDateFormat("yyyyMMdd");
		Date date = null;
		try {
			date = formatter.parse(datestr);
		} catch (Exception e) {
			e.printStackTrace();
		}
		return date;
	}
	
	
	
	public static String getDateString(long t){
		SimpleDateFormat formatter = new SimpleDateFormat("yyyyMMdd");
		Date date = new Date(t);
		return formatter.format(date);
	}
	
	
	public static String CreateXLS(String dataStart , String dataEnd , String routeid) {
		Connection conn = null;
		PreparedStatement psm = null;
		ResultSet rs = null;
		
		Date date = getDate(dataStart);
		long base = 0;
		if(date != null){
			base = date.getTime();
		}
		
		if(base == 0){
			return "";
		}
		
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
		try{ 
			//打开文件 
			//WritableWorkbook book=Workbook.createWorkbook(new File("C:/Users/Administrator/Desktop/" + userid + "-" + dataStart + "-" + dataEnd + ".xls"));
			path2 = "routedata/" + routeid + "-" + dataStart + "-" + dataEnd + new Random().nextInt(1000) +".xls";
			path1 = newpath + path2;
			WritableWorkbook book=Workbook.createWorkbook(new File(path1));
			//生成名为“第一页”的工作表，参数0表示这是第一页 
			WritableSheet sheet=book.createSheet("第一页",0);
			//在Label对象的构造子中指名单元格位置是第一列第一行(0,0) 
			//以及单元格内容为test 
			Label label1 = new Label(0,0,"状态");
			Label label2 = new Label(1,0,"用户ID");
			Label label3 = new Label(2,0,"手机号");
			Label label4 = new Label(3,0,"产品ID");
			Label label5 = new Label(4,0,"通道ID");
			Label label6 = new Label(5,0,"运营商:1移动|2联通|3电信");
			Label label7 = new Label(6,0,"省代码");
			Label label8 = new Label(7,0,"流量包ID");
			Label label9 = new Label(8,0,"流量数");
			Label label10 = new Label(9,0,"用户折扣");
			Label label11 = new Label(10,0,"通道折扣");
			Label label12 = new Label(11,0,"标准价");
			Label label13 = new Label(12,0,"折扣价");
			Label label14 = new Label(13,0,"成本价");
			Label label15 = new Label(14,0,"到平台时间");
			Label label16 = new Label(15,0,"mt成功时间");
			Label label17 = new Label(16,0,"mt状态");
			Label label18 = new Label(17,0,"mt返回值");
			Label label19 = new Label(18,0,"rp时间");
			Label label20 = new Label(19,0,"rp状态");
			Label label21 = new Label(20,0,"rp信息");
			//将定义好的单元格添加到工作表中 
			sheet.addCell(label1);
			sheet.addCell(label2);
			sheet.addCell(label3);
			sheet.addCell(label4);
			sheet.addCell(label5);
			sheet.addCell(label6);
			sheet.addCell(label7);
			sheet.addCell(label8);
			sheet.addCell(label9);
			sheet.addCell(label10);
			sheet.addCell(label11);
			sheet.addCell(label12);
			sheet.addCell(label13);
			sheet.addCell(label14);
			sheet.addCell(label15);
			sheet.addCell(label16);
			sheet.addCell(label17);
			sheet.addCell(label18);
			sheet.addCell(label19);
			sheet.addCell(label20);
			sheet.addCell(label21);
			/*生成一个保存数字的单元格 
			必须使用Number的完整包路径，否则有语法歧义 
			单元格位置是第二列，第一行，值为789.123*/
			Class.forName("com.mysql.jdbc.Driver");
			String url="jdbc:mysql://120.24.229.19:9939/llmain";
			String userName="llmain";
			String passwd="ll2016";
			
//			String url="jdbc:mysql://192.168.2.244:3306/llmain";
//			String userName="root";
//			String passwd="123456";
			conn=DriverManager.getConnection(url,userName,passwd);//连接数据库了。
			if(conn == null){
				return null;
			}
			
			StringBuffer sqlbuf = new StringBuffer();
			
			long dayint = 24 * 3600 * 1000;
			String curdate = null;
			while(true){
				curdate = getDateString(base);
				if(curdate.compareTo(dataEnd) > 0){
					break;
				}
				if(sqlbuf.length() > 0){
					sqlbuf.append("union all \r\n");
				}
				sqlbuf.append("(select ");
				sqlbuf.append("if(status=3,'成功',if(status=4,'失败','未知')),sd_userid,sd_phone,sd_productid,mt_routeid,if(sdx_net=3,'电信',if(sdx_net=1,'移动','联通')),sdx_province,sd_packageid,sdx_mbytes,cast((sdx_money*10/sdx_price) as decimal(10,4)),mt_discont,sdx_price,sdx_money,sdx_price*mt_discont/10,sds_time,mt_time,mt_code,mt_resp,rp_time,rp_code,rp_info");
				sqlbuf.append(" from rec_task"+curdate);
				sqlbuf.append(" where mt_routeid=" + routeid + ") ");
				base += dayint;
			}
			
			psm = conn.prepareStatement(sqlbuf.toString());
			System.out.println(sqlbuf);
			rs = psm.executeQuery();
			int row = 0;
			while (rs.next()) {
				row++;
				if(row <= 65535){
				String status = rs.getString("if(status=3,'成功',if(status=4,'失败','未知'))");
				String sd_userid = rs.getString("sd_userid");
				String sd_phone = rs.getString("sd_phone");
				String sd_productid = rs.getString("sd_productid");
				String mt_routeid = rs.getString("mt_routeid");
				String sdx_net = rs.getString("if(sdx_net=3,'电信',if(sdx_net=1,'移动','联通'))");
				String sdx_province = rs.getString("sdx_province");
				String sd_packageid = rs.getString("sd_packageid");
				
				String sdx_mbytes = rs.getString("sdx_mbytes");
				String cast = rs.getString("cast((sdx_money*10/sdx_price) as decimal(10,4))");
				String mt_discont = rs.getString("mt_discont");
				String sdx_price = rs.getString("sdx_price");
				String sdx_money = rs.getString("sdx_money");
				String cost = rs.getString("sdx_price*mt_discont/10");
				String sds_time = rs.getString("sds_time");
				String mt_time = rs.getString("mt_time");
				String mt_code = rs.getString("mt_code");
				String mt_resp = rs.getString("mt_resp");
				String rp_time = rs.getString("rp_time");
				String rp_code = rs.getString("rp_code");
				String rp_info = rs.getString("rp_info");
				Label lab1 = new Label(0,row,status);
				Label lab2 = new Label(1,row,sd_userid);
				Label lab3 = new Label(2,row,sd_phone);
				Label lab4 = new Label(3,row,sd_productid);
				Label lab5 = new Label(4,row,mt_routeid);
				Label lab6 = new Label(5,row,sdx_net);
				Label lab7 = new Label(6,row,sdx_province);
				Label lab8 = new Label(7,row,sd_packageid);
				Label lab9 = new Label(8,row,sdx_mbytes);
				Label lab10 = new Label(9,row,cast);
				Label lab11 = new Label(10,row,mt_discont);
				Label lab12 = new Label(11,row,sdx_price);
				Label lab13 = new Label(12,row,sdx_money);
				Label lab14 = new Label(13,row,cost);
				Label lab15 = new Label(14,row,sds_time);
				Label lab16 = new Label(15,row,mt_time);
				Label lab17 = new Label(16,row,mt_code);
				Label lab18 = new Label(17,row,mt_resp);
				Label lab19 = new Label(18,row,rp_time);
				Label lab20 = new Label(19,row,rp_code);
				Label lab21 = new Label(20,row,rp_info);
				sheet.addCell(lab1);
				sheet.addCell(lab2);
				sheet.addCell(lab3);
				sheet.addCell(lab4);
				sheet.addCell(lab5);
				sheet.addCell(lab6);
				sheet.addCell(lab7);
				sheet.addCell(lab8);
				sheet.addCell(lab9);
				sheet.addCell(lab10);
				sheet.addCell(lab11);
				sheet.addCell(lab12);
				sheet.addCell(lab13);
				sheet.addCell(lab14);
				sheet.addCell(lab15);
				sheet.addCell(lab16);
				sheet.addCell(lab17);
				sheet.addCell(lab18);
				sheet.addCell(lab19);
				sheet.addCell(lab20);
				sheet.addCell(lab21);
				}else {
					rs.close();
					rs = null;
					psm.close();
					psm = null;
					conn.close();
					conn = null;
					//写入数据并关闭文件 
					book.close();
					return "数据条数超出最大值";
				}
			}
				
			rs.close();
			rs = null;
			psm.close();
			psm = null;
			conn.close();
			conn = null;
			//写入数据并关闭文件 
			book.write(); 
			book.close(); 
			
			path = path2;
			}catch(Exception e) { 
				//System.out.println(e); 
				e.printStackTrace();
		}finally {
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
        if(path != null){
        	//path = "<input type=\"button\" value=\"下载\" onclick=\"window.location.href='" + "http://120.24.156.98:9302/ll_sendbuf" + path1 + "'\" />";
        	path = path2;
        	return path;
        }else{
        	return "下载失败";
        }
	} 
%><%
		String routeid = request.getParameter("routeid");
		String startdate = request.getParameter("startdate");
		String enddate = request.getParameter("enddate");
		
		//int dataStart = Integer.parseInt(startdate);
		//int dataEnd = Integer.parseInt(enddate);
		
		out.clearBuffer();
		out.print(CreateXLS(startdate, enddate , routeid));
%>