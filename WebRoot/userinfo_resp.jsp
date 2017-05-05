<%@page import="database.DatabaseUtils"%>
<%@page import="http.HttpAccess"%>
<%@page import="org.dom4j.io.XMLWriter"%>
<%@page import="org.dom4j.io.OutputFormat"%>
<%@page import="java.io.StringWriter"%>

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
		private static class StatusUnit {
		public String productid;
		public String productname;
		public String productdiscount;
		public String packageid;
		public String packagename;
		public String packagenet;
		public String packagembytes;
		public String packageprice;
		public String mytype;
		public String province;
	}
	private static String getStatusUnits(String userid) {
		Connection conn = null;
		PreparedStatement psm = null;
		ResultSet rs = null;
		HashMap<String, ArrayList<StatusUnit>> maps=new LinkedHashMap<String, ArrayList<StatusUnit>>();
		try {
			conn =DatabaseUtils.getLLMainDBConnByJNDI();
			if (conn == null) {
			}
			StringBuffer sqlbuf = new StringBuffer();
			sqlbuf.append("select * from llv_uprp  where UP_USERID  =  ");
			sqlbuf.append(Integer.parseInt(userid));
			sqlbuf.append(" order by PRODUCTID,package_net,package_price");
			psm = conn.prepareStatement(sqlbuf.toString());			
//			logger.info("sql1 = " + psm.toString());
			rs = psm.executeQuery();
			ArrayList<StatusUnit> unitlist=null;
			HashMap<String, String> provincemap	=new HashMap<String, String>();
			provincemap.put("11","北京市");
			provincemap.put("43","湖南省");
			provincemap.put("12","天津市");
			provincemap.put("44","广东省");
			provincemap.put("13","河北省");
			provincemap.put("45","广西壮族自治区");
			provincemap.put("14","山西省");
			provincemap.put("46","海南省");
			provincemap.put("15","内蒙古自治区");
			provincemap.put("50","重庆市");
			provincemap.put("21","辽宁省");
			provincemap.put("51","四川省");
			provincemap.put("22","吉林省");
			provincemap.put("52","贵州省");
			provincemap.put("23","黑龙江省");
			provincemap.put("53","云南省");
			provincemap.put("31","上海市");
			provincemap.put("54","西藏自治区");
			provincemap.put("32","江苏省");
			provincemap.put("61","陕西省");
			provincemap.put("33","浙江省");
			provincemap.put("62","甘肃省");
			provincemap.put("34","安徽省");
			provincemap.put("63","青海省");
			provincemap.put("35","福建省");
			provincemap.put("64","宁夏回族自治区");
			provincemap.put("36","江西省");
			provincemap.put("65","新疆维吾尔自治区");
			provincemap.put("37","山东省");
			provincemap.put("71","台湾省");
			provincemap.put("41","河南省");
			provincemap.put("81","香港特别行政区");
			provincemap.put("42","湖北省");
			provincemap.put("82","澳门特别行政区");
			while(rs.next()){
				StatusUnit unit=new StatusUnit();
				unit.productid=rs.getString("PRODUCTID");
				unit.productname=rs.getString("PRODUCT_NAME");
				unit.productdiscount=rs.getString("UP_DISCOUNT");
				unit.packageid=rs.getString("packageid");
				unit.packagename=rs.getString("package_name");
				unit.packagenet=rs.getString("package_net");
				unit.packagembytes=rs.getString("package_mbytes");
				unit.packageprice=rs.getString("package_price");
				unit.mytype=rs.getString("route_mytype");
				if (unit.mytype.equals("0")) {
					unit.mytype="全国";
				}
//				unit.province=rs.getString("route_province");
				if (rs.getString("route_province").equals("")||rs.getString("route_province")==null||rs.getString("route_province").equals("0")) {
					unit.province="全国";
				}
				else  {
					String province=rs.getString("route_province");
					String[] proStrs=province.split("\\|");
					unit.province="";
					for (int i = 0; i < proStrs.length; i++) {
						unit.province=unit.province+provincemap.get(proStrs[i]);
						if(proStrs.length-1!=i){
						unit.province+="/";}
					}
					
				}
					
				
					
				
				unitlist=maps.get(unit.productid);
				if (unitlist==null) {
					unitlist=new ArrayList<StatusUnit>();
					maps.put(unit.productid,unitlist);
				}
				unitlist.add(unit);	
			}

			rs.close();
			rs = null;
			psm.close();
			psm = null;
			conn.close();
			conn = null;
			
		} catch (Exception e) {
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
		Iterator it = maps.keySet().iterator();  
		 String ret="";
	    while(it.hasNext()) {  
	        String key = (String)it.next(); 
	        Document document=DocumentHelper.createDocument();
	        Element product=document.addElement("product");
	        product.addAttribute("id", key);
	        product.addAttribute("name", maps.get(key).get(1).productname);
	        product.addAttribute("discount", maps.get(key).get(1).productdiscount);
	        
	        for (int i = 0; i < maps.get(key).size(); i++) {
	        	Element pakge=product.addElement("package");
	        	pakge.addAttribute("id", maps.get(key).get(i).packageid);
	        	pakge.addAttribute("name", maps.get(key).get(i).packagename);
	        	pakge.addAttribute("net", maps.get(key).get(i).packagenet);
	        	pakge.addAttribute("mbytes", maps.get(key).get(i).packagembytes);
	        	pakge.addAttribute("price", maps.get(key).get(i).packageprice);
	        	pakge.addAttribute("mytype", maps.get(key).get(i).mytype);
	        	pakge.addAttribute("province", maps.get(key).get(i).province);
	        	} StringWriter out=new StringWriter(); 
	        OutputFormat format = new OutputFormat();  
	        format.setEncoding("gbk");  
	        format.setNewlines(true);  
	        XMLWriter writer = new XMLWriter(out, format);  
	        try {
				writer.write(document.getRootElement());
			} catch (Exception e) {
				e.printStackTrace();
			} 
	        ret=ret+out.toString();
	    }
		return ret;	
	}
%><%	

		if(session.getAttribute("admin") != null && session.getAttribute("admin").equals("yes")){
	   		//session.setAttribute("admin", "yes");
	   	}else{
	   		out.println("~");
	  		return;
	   	}
	   	
		logger.info("here");
		String ret=getStatusUnits(request.getParameter("userid"));
		out.print("<xmp>" +"<products>"+ret+"</products>"+"</xmp>" );
		
%>