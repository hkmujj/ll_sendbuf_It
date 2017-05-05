<%@page import="com.alibaba.fastjson.JSONObject"%>
<%@page import="java.lang.management.ManagementFactory"%>
<%@page import="java.io.InputStreamReader"%>
<%@page import="java.io.BufferedReader"%>
<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%!

	//******************* [  报警值  ] *******************
	
	//最大cpu使用率, > 超过就报警
	private static int maxcpu_p = 100;
	//最大磁盘使用率, > 超过就报警
	private static int maxdisk_p = 90;
	//最小磁盘可用空间, 单位为G, < 小于就报警
	private static int mindiskavl = 5;
	//最大连接数, > 超过就报警
	private static int maxconn_used = 20000;
	//最小内存可用空间, 单位为M, < 小于就报警
	private static int minmemavl = 256;
	//最大内存使用率, > 超过就报警
	private static int maxmem_p = 90;
	
	//************** [  这是一条华丽丽的分割线  ] **************
	
	private static void getExecuteResult(Process proc, ArrayList<String> ret){
		BufferedReader br = null;
		try{
			br = new BufferedReader(new InputStreamReader(proc.getInputStream()));
			String line = null;
			while((line = br.readLine()) != null){
				ret.add(line);
			}
		}catch(Exception e){
			e.printStackTrace();
		}finally{
			if(br != null){
				try{
					br.close();
				}catch(Exception e){
					e.printStackTrace();
				}
			}
		}
	}
	
	public static ArrayList<String> executeCommand(String cmd){
		ArrayList<String> ret = new ArrayList<String>();
		try{
			Process proc = Runtime.getRuntime().exec(cmd);
			getExecuteResult(proc, ret);
		}catch(Exception e){
			e.printStackTrace();
		}
		return ret;
	}
	
	public static ArrayList<String> executeCommand(String[] cmd){
		ArrayList<String> ret = new ArrayList<String>();
		try{
			Process proc = Runtime.getRuntime().exec(cmd);
			getExecuteResult(proc, ret);
		}catch(Exception e){
			e.printStackTrace();
		}
		return ret;
	}
	
	public static ArrayList<HashMap<String, String>> wmicCommand(String cmd){
		ArrayList<HashMap<String, String>> ret = new ArrayList<HashMap<String,String>>();
		ArrayList<String> retstr = executeCommand(cmd);
		if(retstr.size() < 2){
			return ret;
		}
		String capt = retstr.get(0);
		ArrayList<Integer> idxes = new ArrayList<Integer>();
		ArrayList<String> keys = new ArrayList<String>();
		boolean bk = false;
		int idx = 0;
		idxes.add(idx);
		for(int i = 0; ; i++){
			if(capt.charAt(i) == ' '){
				if(!bk){
					keys.add(capt.substring(idx, i));
				}
				if(i >= capt.length() - 1){
					break;
				}
				bk = true;
			}else{
				if(i >= capt.length() - 1){
					keys.add(capt.substring(idx, i));
					break;
				}
				if(bk){
					idx = i;
					idxes.add(idx);
				}
				bk = false;
			}
		}
		for(int i = 1; i < retstr.size(); i++){
			String line = retstr.get(i);
			
			if(line.length() < idxes.get(idxes.size() - 1) || line.length() <= 0){
				continue;
			}
			HashMap<String, String> map = new HashMap<String, String>();
			int end = 0;
			for(int v = 0; v < keys.size(); v++){
				if(v >= idxes.size() - 1){
					end = line.length();
				}else{
					end = idxes.get(v + 1);
				}
				map.put(keys.get(v), line.substring(idxes.get(v), end).trim());
			}
			ret.add(map);
		}
		return ret;
	}
	
	public static void getExecResult(ArrayList<String> retstr, ArrayList<ArrayList<String>> ret, int begin){
	
		String capt = retstr.get(begin - 1);
		ArrayList<Integer> idxes = new ArrayList<Integer>();
		boolean bk = false;
		int idx = 0;
		for(int i = 0; ; i++){
			if(capt.charAt(i) == ' '){
				if(i >= capt.length() - 1){
					break;
				}
				bk = true;
			}else{
				if(i >= capt.length() - 1){
					break;
				}
				if(bk || i == 0){
					idx = i;
					idxes.add(idx);
				}
				bk = false;
			}
		}
		
		for(int i = begin - 1; i < retstr.size(); i++){
			String line = retstr.get(i);
			if(line.length() < idxes.get(idxes.size() - 1) || line.length() <= 0){
				continue;
			}
			ArrayList<String> list = new ArrayList<String>();
			int end = 0;
			for(int v = 0; v < idxes.size(); v++){
				if(v >= idxes.size() - 1){
					end = line.length();
				}else{
					end = idxes.get(v + 1);
				}
				list.add(line.substring(idxes.get(v), end).trim());
			}
			ret.add(list);
		}
	}
	
	public static ArrayList<ArrayList<String>> execCommand(String cmd, int begin){
		ArrayList<ArrayList<String>> ret = new ArrayList<ArrayList<String>>();
		ArrayList<String> retstr = executeCommand(cmd);
		if(retstr.size() < 2){
			return ret;
		}
		
		getExecResult(retstr, ret, begin);
		
		return ret;
	}
	
	public static ArrayList<ArrayList<String>> execCommand(String[] cmd, int begin){
		ArrayList<ArrayList<String>> ret = new ArrayList<ArrayList<String>>();
		ArrayList<String> retstr = executeCommand(cmd);
		if(retstr.size() < 2){
			return ret;
		}
		
		getExecResult(retstr, ret, begin);
		
		return ret;
	}
	
	private static void mysleep(long t){
		try {
			Thread.sleep(t);
		} catch (InterruptedException e) {
			e.printStackTrace();
		}
	}
%><%
	out.clearBuffer();

	String acr = request.getParameter("mchuan");
	if((session.getAttribute("admin") != null && session.getAttribute("admin").equals("yes")) || (acr != null && acr.equals("cube_1002"))){
		session.setAttribute("admin", "yes");
	}else{
		out.println("~");
		return;
	}
	
	JSONObject retjson = new JSONObject();
	
	int alarmlevel = 0;
	
	ArrayList<String> alarmreason = new ArrayList<String>();
	
	try{
		
		String directory = request.getServletContext().getRealPath("");
		
		retjson.put("directory", directory);
		
		String procCmd = "wmic process get Caption,KernelModeTime,UserModeTime,ProcessId,WorkingSetSize";
		
		ArrayList<HashMap<String, String>> prclsit = wmicCommand(procCmd);
		
		long pidletime = 0;
	    long pbusytime = 0;
	    long psetsize = 0;
	    HashMap<String, String> map = null;
	    for(int i = 0; i < prclsit.size(); i++){
	        map = prclsit.get(i);
	        
	        String caption = map.get("Caption");
	        String processid = map.get("ProcessId");
	        String kmt = map.get("KernelModeTime");
	        String umt = map.get("UserModeTime");
	        String setsz = map.get("WorkingSetSize");
	        
	        psetsize += Long.parseLong(setsz);
	        if (caption.equals("System Idle Process") || caption.equals("System") || caption.equalsIgnoreCase("wmic.exe")) {
	            pidletime += Long.parseLong(kmt);
	            pidletime += Long.parseLong(umt);
	        }else{
	        	pbusytime += Long.parseLong(kmt);
	        	pbusytime += Long.parseLong(umt);
	        }
	    }
	    
	    mysleep(20);
	    
	    prclsit = wmicCommand(procCmd);
	    
	    long idletime = 0;
	    long busytime = 0;
	    long setsize = 0;
	    for(int i = 0; i < prclsit.size(); i++){
	        map = prclsit.get(i);
	        
	        String caption = map.get("Caption");
	        String processid = map.get("ProcessId");
	        String kmt = map.get("KernelModeTime");
	        String umt = map.get("UserModeTime");
	        String setsz = map.get("WorkingSetSize");
	        
	        setsize += Long.parseLong(setsz);
	        if (caption.equals("System Idle Process") || caption.equals("System") || caption.equalsIgnoreCase("wmic.exe")) {
	            idletime += Long.parseLong(kmt);
	            idletime += Long.parseLong(umt);
	        }else{
	        	busytime += Long.parseLong(kmt);
	        	busytime += Long.parseLong(umt);
	        }
	    }
	    
	    idletime = idletime - pidletime;
	    busytime = busytime - pbusytime;
	    int cpu_p = 0;
	    if(busytime >= 0 && idletime >= 0){
	    	cpu_p = (int)(100 * busytime / (busytime + idletime));
	    }
	    
	    retjson.put("cpu", cpu_p + "%");
	    
	    if(cpu_p > maxcpu_p){
	    	int lv = 1;
	    	if(alarmlevel < lv){
	    		alarmlevel = lv;
	    	}
	    	alarmreason.add("cpu使用率过高");
	    }
	    
	    setsize = (setsize + psetsize) / 2;
	    
	    procCmd = "wmic memorychip get Capacity";
	    prclsit = wmicCommand(procCmd);
	    if(prclsit.size() > 0){
	    	String capacity = prclsit.get(0).get("Capacity");
	    	if(capacity != null){
	    		long totalmem = Long.parseLong(capacity);
	    		if(totalmem - setsize < (long)minmemavl * 1024 * 1024 || setsize * 100 / totalmem > maxmem_p){
	    			int lv = 2;
	    	    	if(alarmlevel < lv){
	    	    		alarmlevel = lv;
	    	    	}
	    	    	alarmreason.add("内存过满");
	    		}
	    		retjson.put("mem_total", (totalmem / 1024 / 1024) + "M");
	    	}
	    }
	    retjson.put("mem_used", (setsize / 1024 / 1024) + "M");
	    
	    procCmd = "wmic logicaldisk get Caption,FreeSpace,Size";
	    prclsit = wmicCommand(procCmd);
	    for(int i = 0; i < prclsit.size(); i++){
	    	map = prclsit.get(i);
	    	
	    	String caption = map.get("Caption");
	        String freespace = map.get("FreeSpace");
	        String size = map.get("Size");
	        
	        if(caption.length() > 1){
	        	caption = caption.substring(0, 1);
	        }
	        
	        long free = Long.parseLong(freespace);
	        long total = Long.parseLong(size);
	        
	        if(free < (long)mindiskavl * 1024 * 1024 * 1024 || (total - free) * 100 / total > maxdisk_p){
	        	int lv = 3;
		    	if(alarmlevel < lv){
		    		alarmlevel = lv;
		    	}
    	    	alarmreason.add(caption + "盘过满");
	        }
	        retjson.put((caption + "_total").toLowerCase(), total / 1024 / 1024 / 1024 + "G");
	        retjson.put((caption + "_used").toLowerCase(), (total - free) / 1024 / 1024 / 1024 + "G");
	    }
	    
	    ArrayList<ArrayList<String>> retlist = execCommand(new String[] { "Netstat", "-ano" }, 5);
	    ArrayList<String> list = null;
	    int conn_used = 0;
	    for(int i = 0; i < retlist.size(); i++){
	    	list = retlist.get(i);
	    	if(list.size() > 0 && list.get(0).equalsIgnoreCase("tcp")){
	    		conn_used++;
	    	}
	    }
	    if(conn_used > maxconn_used){
	    	int lv = 3;
	    	if(alarmlevel < lv){
	    		alarmlevel = lv;
	    	}
	    	alarmreason.add("连接数过多");
	    }
	    retjson.put("conn_used", "" + conn_used);
	    
	}catch(Exception e){
		e.printStackTrace();
	}
	
	retjson.put("alarmlevel", "" + alarmlevel);
	
	retjson.put("alarmreason", alarmreason);
    
    //JSONObject.parseObject(procCmd);
    out.print(retjson.toString());
%>