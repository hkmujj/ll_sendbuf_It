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
	
	
	public static String CreateXLS(String dataStart , String dataEnd , String userid) {
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
			path2 = "data/" + userid + "-" + dataStart + "-" + dataEnd + new Random().nextInt(1000) +".xls";
			path1 = newpath + path2;
			WritableWorkbook book=Workbook.createWorkbook(new File(path1));
			//生成名为“第一页”的工作表，参数0表示这是第一页 
			WritableSheet sheet=book.createSheet("第一页",0);
			//在Label对象的构造子中指名单元格位置是第一列第一行(0,0) 
			//以及单元格内容为test 
			Label label1 = new Label(0,0,"账号");
			Label label2 = new Label(1,0,"电话");
			Label label3 = new Label(2,0,"规格");
			Label label4 = new Label(3,0,"省份");
			Label label5 = new Label(4,0,"标准价");
			Label label6 = new Label(5,0,"客户实际扣费");
			Label label7 = new Label(6,0,"通道成本折扣");
			Label label8 = new Label(7,0,"通道实际扣费");
			Label label9 = new Label(8,0,"下单时间");
			Label label10 = new Label(9,0,"状态");
			Label label11 = new Label(10,0,"运营商");
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
				sqlbuf.append("sd_userid,SD_PHONE,SD_PACKAGEID,SHOW_PROVINCE(SDX_PROVINCE) as 省份,SDX_PRICE,SDX_MONEY,MT_DISCONT,SDX_PRICE*MT_DISCONT/10,SDS_TIME,if(RP_CODE='0','成功',if(RP_CODE is null,'充值中','失败')),if(sdx_net=1,'移动',if(sdx_net=2,'联通','电信'))");
				sqlbuf.append(" from rec_task"+curdate);
				sqlbuf.append(" where sd_userid=" + userid + ") ");
				base += dayint;
			}
			
			psm = conn.prepareStatement(sqlbuf.toString());
			System.out.println(sqlbuf);
			rs = psm.executeQuery();
			int row = 0;
			while (rs.next()) {
				row++;
				if(row <= 65535){
				String sd_userid = rs.getString("sd_userid");
				String SD_PHONE = rs.getString("SD_PHONE");
				String SD_PACKAGEID = rs.getString("SD_PACKAGEID");
				String SDX_PROVINCE = rs.getString("省份");
				//String SDX_PRICE = rs.getString("SDX_PRICE");
				//String SDX_MONEY = rs.getString("SDX_MONEY");
				//String MT_DISCONT = rs.getString("MT_DISCONT");
				//String realPrice = rs.getString("SDX_PRICE*MT_DISCONT/10");
				String SDX_PRICE = rs.getString("SDX_PRICE");
				String SDX_MONEY = rs.getString("SDX_MONEY");
				String MT_DISCONT = rs.getString("MT_DISCONT");
				String realPrice = rs.getString("SDX_PRICE*MT_DISCONT/10");
				
				String SDS_TIME = rs.getString("SDS_TIME");
				String status = rs.getString("if(RP_CODE='0','成功',if(RP_CODE is null,'充值中','失败'))");
				String net = rs.getString("if(sdx_net=1,'移动',if(sdx_net=2,'联通','电信'))");
				Label lab1 = new Label(0,row,sd_userid);
				Label lab2 = new Label(1,row,SD_PHONE);
				Label lab3 = new Label(2,row,SD_PACKAGEID);
				Label lab4 = new Label(3,row,SDX_PROVINCE);
				Label lab5 = new Label(4,row,SDX_PRICE);
				Label lab6 = new Label(5,row,SDX_MONEY);
				Label lab7 = new Label(6,row,MT_DISCONT);
				Label lab8 = new Label(7,row,realPrice);
				Label lab9 = new Label(8,row,SDS_TIME);
				Label lab10 = new Label(9,row,status);
				Label lab11 = new Label(10,row,net);
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
				}else {
					row = 1;
					WritableSheet sheet1=book.createSheet("第二页",0);
					Label label1_2 = new Label(0,0,"账号");
					Label label2_2 = new Label(1,0,"电话");
					Label label3_2 = new Label(2,0,"规格");
					Label label4_2 = new Label(3,0,"省份");
					Label label5_2 = new Label(4,0,"标准价");
					Label label6_2 = new Label(5,0,"客户实际扣费");
					Label label7_2 = new Label(6,0,"通道成本折扣");
					Label label8_2 = new Label(7,0,"通道实际扣费");
					Label label9_2 = new Label(8,0,"下单时间");
					Label label10_2 = new Label(9,0,"状态");
					Label label11_2 = new Label(10,0,"运营商");
					//将定义好的单元格添加到工作表中 
					sheet1.addCell(label1_2);
					sheet1.addCell(label2_2);
					sheet1.addCell(label3_2);
					sheet1.addCell(label4_2);
					sheet1.addCell(label5_2);
					sheet1.addCell(label6_2);
					sheet1.addCell(label7_2);
					sheet1.addCell(label8_2);
					sheet1.addCell(label9_2);
					sheet1.addCell(label10_2);
					sheet1.addCell(label11_2);
					
					String sd_userid = rs.getString("sd_userid");
					String SD_PHONE = rs.getString("SD_PHONE");
					String SD_PACKAGEID = rs.getString("SD_PACKAGEID");
					String SDX_PROVINCE = rs.getString("省份");
					//String SDX_PRICE = rs.getString("SDX_PRICE");
					//String SDX_MONEY = rs.getString("SDX_MONEY");
					//String MT_DISCONT = rs.getString("MT_DISCONT");
					//String realPrice = rs.getString("SDX_PRICE*MT_DISCONT/10");
					String SDX_PRICE = rs.getString("SDX_PRICE");
					String SDX_MONEY = rs.getString("SDX_MONEY");
					String MT_DISCONT = rs.getString("MT_DISCONT");
					String realPrice = rs.getString("SDX_PRICE*MT_DISCONT/10");
					
					String SDS_TIME = rs.getString("SDS_TIME");
					String status = rs.getString("if(RP_CODE='0','成功',if(RP_CODE is null,'充值中','失败'))");
					String net = rs.getString("if(sdx_net=1,'移动',if(sdx_net=2,'联通','电信'))");
					Label lab1_2 = new Label(0,row,sd_userid);
					Label lab2_2 = new Label(1,row,SD_PHONE);
					Label lab3_2 = new Label(2,row,SD_PACKAGEID);
					Label lab4_2 = new Label(3,row,SDX_PROVINCE);
					Label lab5_2 = new Label(4,row,SDX_PRICE);
					Label lab6_2 = new Label(5,row,SDX_MONEY);
					Label lab7_2 = new Label(6,row,MT_DISCONT);
					Label lab8_2 = new Label(7,row,realPrice);
					Label lab9_2 = new Label(8,row,SDS_TIME);
					Label lab10_2 = new Label(9,row,status);
					Label lab11_2 = new Label(10,row,net);
					sheet1.addCell(lab1_2);
					sheet1.addCell(lab2_2);
					sheet1.addCell(lab3_2);
					sheet1.addCell(lab4_2);
					sheet1.addCell(lab5_2);
					sheet1.addCell(lab6_2);
					sheet1.addCell(lab7_2);
					sheet1.addCell(lab8_2);
					sheet1.addCell(lab9_2);
					sheet1.addCell(lab10_2);
					sheet1.addCell(lab11_2);
					
					while(rs.next()){
					row++;
					sd_userid = rs.getString("sd_userid");
					SD_PHONE = rs.getString("SD_PHONE");
					SD_PACKAGEID = rs.getString("SD_PACKAGEID");
					SDX_PROVINCE = rs.getString("省份");
					//String SDX_PRICE = rs.getString("SDX_PRICE");
					//String SDX_MONEY = rs.getString("SDX_MONEY");
					//String MT_DISCONT = rs.getString("MT_DISCONT");
					//String realPrice = rs.getString("SDX_PRICE*MT_DISCONT/10");
					SDX_PRICE = rs.getString("SDX_PRICE");
					SDX_MONEY = rs.getString("SDX_MONEY");
					MT_DISCONT = rs.getString("MT_DISCONT");
					realPrice = rs.getString("SDX_PRICE*MT_DISCONT/10");
					
					SDS_TIME = rs.getString("SDS_TIME");
					status = rs.getString("if(RP_CODE='0','成功',if(RP_CODE is null,'充值中','失败'))");
					net = rs.getString("if(sdx_net=1,'移动',if(sdx_net=2,'联通','电信'))");
					lab1_2 = new Label(0,row,sd_userid);
					lab2_2 = new Label(1,row,SD_PHONE);
					lab3_2 = new Label(2,row,SD_PACKAGEID);
					lab4_2 = new Label(3,row,SDX_PROVINCE);
					lab5_2 = new Label(4,row,SDX_PRICE);
					lab6_2 = new Label(5,row,SDX_MONEY);
					lab7_2 = new Label(6,row,MT_DISCONT);
					lab8_2 = new Label(7,row,realPrice);
					lab9_2 = new Label(8,row,SDS_TIME);
					lab10_2 = new Label(9,row,status);
					lab11_2 = new Label(10,row,net);
					sheet1.addCell(lab1_2);
					sheet1.addCell(lab2_2);
					sheet1.addCell(lab3_2);
					sheet1.addCell(lab4_2);
					sheet1.addCell(lab5_2);
					sheet1.addCell(lab6_2);
					sheet1.addCell(lab7_2);
					sheet1.addCell(lab8_2);
					sheet1.addCell(lab9_2);
					sheet1.addCell(lab10_2);
					sheet1.addCell(lab11_2);
					}
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
		String userid = request.getParameter("userid");
		String startdate = request.getParameter("startdate");
		String enddate = request.getParameter("enddate");
		
		//int dataStart = Integer.parseInt(startdate);
		//int dataEnd = Integer.parseInt(enddate);
		
		out.clearBuffer();
		out.print(CreateXLS(startdate, enddate , userid));
%>