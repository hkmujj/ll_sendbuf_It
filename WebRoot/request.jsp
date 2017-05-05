<%@page import="util.TimeUtils,
				cache.Cache,
				net.sf.json.JSONException,
				net.sf.json.JSONObject,
				java.util.*,
				util.MyStringUtils,
				java.net.URLDecoder,
				org.apache.logging.log4j.LogManager,
				org.apache.logging.log4j.Logger" 
		language="java" pageEncoding="UTF-8"
%><%boolean logflag = true;
	Logger logger = LogManager.getLogger(); 
	
	String str = null;
	//String retstr = "";
	if(request.getAttribute("result") != null){
		String retstr = request.getAttribute("result").toString();
		
		//logger.info("###request result = " + retstr);
		
		JSONObject retjson = new JSONObject();
		retjson.put("id", Integer.parseInt(request.getAttribute("jsonrpcid").toString()));
		if(request.getAttribute("method").toString().equals("charge")){
			//充值结果
			if(retstr.equals("success")){ 
				logger.info("@@@ taskid = " + request.getAttribute("taskid").toString() + ", phone = " + request.getAttribute("phone").toString());
						
				Cache.addNumberCount(request.getAttribute("routeid").toString(), request.getAttribute("phone").toString());
				
				JSONObject obj = new JSONObject();
				obj.put("code", 0);
				if(request.getAttribute("reportid") != null){
					obj.put("rpid", request.getAttribute("reportid").toString());
				}else{
					obj.put("rpid", request.getAttribute("taskid").toString());
				}
				if(request.getAttribute("orgreturn") == null){
					logger.info("[" + request.getAttribute("routeid").toString() + "]orgreturn is null");
				}
				obj.put("resp", request.getAttribute("orgreturn").toString());
				retjson.put("result", obj);
				//out.print(retjson.toString());
			}else{
				//logger.info("retstr = " + retstr);
				logger.info("$$$ taskid = " + request.getAttribute("taskid").toString() + ", phone = " + request.getAttribute("phone").toString());
				if(request.getAttribute("orgreturn") == null){
					//error				
					JSONObject error = new JSONObject();
					error.put("code", 12);
					error.put("message", retstr);
					
					retjson.put("error", error);
					
					//out.print(retjson.toString());
				}else{				
					JSONObject obj = new JSONObject();
					int code = 999;
					if(request.getAttribute("code") != null){
						try{
							code = Integer.parseInt(request.getAttribute("code").toString());
						}catch (Exception e) {
							e.printStackTrace();
						}
					}
					obj.put("code", code);
					obj.put("message", retstr);
					obj.put("resp", request.getAttribute("orgreturn").toString());
					retjson.put("result", obj);
					//out.print(retjson.toString());
				}
			}
		}else{
			//拉状态结果
			if(request.getAttribute("retjson") != null){
				retjson.put("result", request.getAttribute("retjson").toString());
				//logger.info("return status = " + retjson.toString());
				//out.print(retjson.toString());
			}else{
				JSONObject error = new JSONObject();
				error.put("code", 14);
				error.put("message", retstr);
				retjson.put("error", error);
				//out.print(retjson.toString());
				logger.info(retstr);
			}
			//out.print(retjson.toString());
		}
		
		out.print(retjson.toString());
		return;
	}
	
	logger.info("request begin");
	str = MyStringUtils.inputStringToString(request.getInputStream());
	if(str == null || str.length() <= 0){
		//str=new String(request.getParameter("json").getBytes("ISO-8859-1"),"UTF-8");
		str=request.getParameter("json");
	}
	if(str == null || str.length() <= 0){
		if(request.getQueryString() != null){
			str = URLDecoder.decode(request.getQueryString(), "utf-8");
		}
	}
	
	if(str == null){
		out.print("no request data");
		return;
	}
	
	logger.info("request entry : json = " + str);
	
	JSONObject ret = new JSONObject();
	JSONObject error = new JSONObject();
	try{
		JSONObject jb = JSONObject.fromObject(str);
		String method = jb.getString("method");
		JSONObject params = (JSONObject)jb.getJSONObject("params");
		int id = jb.getInt("id");
		ret.put("id", id);
		
		if(method.equals("charge")){
			while(true){
				Object taskidobj = params.get("taskid");
				if(taskidobj == null){
					error.put("code", 1);
					error.put("message", "parameter `taskid` is needed");
					break;
				}
				String taskid = taskidobj.toString();
				if(taskid.trim().length() <= 0){
					error.put("code", 2);
					error.put("message", "parameter `taskid` is blank");
					break;
				}
				Object routeidobj = params.get("routeid");
				if(routeidobj == null){
					error.put("code", 3);
					error.put("message", "parameter `routeid` is needed");
					break;
				}
				String routeid = routeidobj.toString();
				if(routeid.trim().length() <= 0){
					error.put("code", 4);
					error.put("message", "parameter `routeid` is blank");
					break;
				} 
				Object phoneobj = params.get("phone");
				if(phoneobj == null){
					error.put("code", 5);
					error.put("message", "parameter `phone` is needed");
					break;
				}
				String phone = phoneobj.toString();
				if(phone.trim().length() <= 0){
					error.put("code", 6);
					error.put("message", "parameter `phone` is blank");
					break;
				}
				Object packageobj = params.get("package");
				if(packageobj == null){
					error.put("code", 7);
					error.put("message", "parameter `package` is needed");
					break;
				}
				String packageid = packageobj.toString();
				if(packageid.trim().length() <= 0){
					error.put("code", 8);
					error.put("message", "parameter `package` is blank");
					break;
				}
				Object netobj = params.get("net");
				if(netobj == null){
					error.put("code", 15);
					error.put("message", "parameter `net` is needed");
					break;
				}
				String net = netobj.toString();
				if(net.trim().length() <= 0){
					error.put("code", 16);
					error.put("message", "parameter `net` is blank");
					break;
				}
				Object provinceobj = params.get("province");
				if(provinceobj == null){
					error.put("code", 17);
					error.put("message", "parameter `province` is needed");
					break;
				}
				String province = provinceobj.toString();
				if(province.trim().length() <= 0){
					error.put("code", 18);
					error.put("message", "parameter `province` is blank");
					break;
				}
				Object mbytesobj = params.get("mbytes");
				if(mbytesobj == null){
					error.put("code", 19);
					error.put("message", "parameter `mbytes` is needed");
					break;
				}
				String mbytes = mbytesobj.toString();
				if(mbytes.trim().length() <= 0){
					error.put("code", 20);
					error.put("message", "parameter `mbytes` is blank");
					break;
				}
				Object mytypeobj = params.get("mytype");
				if(mytypeobj == null){
					error.put("code", 21);
					error.put("message", "parameter `mytype` is needed");
					break;
				}
				String mytype = mytypeobj.toString();
				if(mytype.trim().length() <= 0){
					error.put("code", 22);
					error.put("message", "parameter `mytype` is blank");
					break;
				}
				
				String userid = "";
				Object useridobj = params.get("userid");
				if(useridobj != null){
					userid = useridobj.toString();
				}
				
				request.setAttribute("taskid", taskid);
				request.setAttribute("routeid", routeid);
				request.setAttribute("phone", phone);
				request.setAttribute("package", packageid);
				
				request.setAttribute("net", net);
				request.setAttribute("province", province);
				request.setAttribute("mbytes", mbytes);
				request.setAttribute("mytype", mytype);
				
				request.setAttribute("userid", userid);
				
				request.setAttribute("jsonrpcid", String.valueOf(id));
				request.setAttribute("method", "charge");
				
				if(logflag){
					logger.info("taskid = " + request.getAttribute("taskid").toString() + 
								", routeid = " + request.getAttribute("routeid").toString() +
								", phone = " + request.getAttribute("phone").toString() +
								", package = " + request.getAttribute("package").toString() + 
								", net = " + request.getAttribute("net").toString() +
								", province = " + request.getAttribute("province").toString() +
								", mbytes = " + request.getAttribute("mbytes").toString() +
								", mytype = " + request.getAttribute("mytype").toString());
				}
				
				break;
			}
		}else if(method.equals("status")){
			while(true){
				Object idsobj = params.get("ids");
				if(idsobj != null){
					String taskids = idsobj.toString();
					request.setAttribute("ids", taskids);
				}
				
				Object routeidobj = params.get("routeid");
				if(routeidobj == null){
					error.put("code", 3);
					error.put("message", "parameter `routeid` is needed");
					break;
				}
				String routeid = routeidobj.toString();
				if(routeid.trim().length() <= 0){
					error.put("code", 4);
					error.put("message", "parameter `routeid` is blank");
					break;
				} 
				
				request.setAttribute("routeid", routeid);
				request.setAttribute("jsonrpcid", String.valueOf(id));
				request.setAttribute("method", "status");
				
				if(logflag){
					if(idsobj != null){
						logger.info("ids = " + request.getAttribute("ids").toString() + 
								", routeid = " + request.getAttribute("routeid").toString()); 
					}else{
						logger.info("routeid = " + request.getAttribute("routeid").toString()); 
					}
				}
				
				break;
			}
		}else{
			error.put("code", 9);
			error.put("message", "unrecognized method");
		}
	} catch (JSONException e) {
		e.printStackTrace();
		logger.warn(e.getMessage(), e);
		error.put("code", 10);
		error.put("message", e.getMessage());
	} catch (Exception e) {
		e.printStackTrace();
		logger.warn(e.getMessage(), e);
		error.put("code", 11);
		error.put("message", e.getMessage());
	}
	
	if(error.get("code") != null){
		ret.put("error", error);
		if(logflag){
			logger.info("error request = " + ret.toString());
		}
		out.print(ret.toString());
		return;
	}
	
	String destjsp = null;
	
	while(true){
		if(request.getAttribute("method").toString().equals("charge")){
			String routeid = request.getAttribute("routeid").toString();
			if(!Cache.getRouteStatus(routeid)){
				request.setAttribute("result", "S." + routeid + ":route not available@" + TimeUtils.getSysLogTimeString());
				break; 			
			}
			
			String phone = request.getAttribute("phone").toString();
			if(!Cache.checkNumber(routeid, phone)){
				request.setAttribute("result", "S." + routeid + ":[" + phone + "]excessive recharge@" + TimeUtils.getSysLogTimeString());
				break;
			}
			
			/*
			String packageid = request.getAttribute("package").toString();
			String packagecode = Cache.getPackageCode(routeid, packageid);
			if(packagecode == null || packagecode.trim().length() <= 0){
				request.setAttribute("result", "S." + routeid + ":unrecognized package@" + TimeUtils.getSysLogTimeString());
				break;
			}
			*/
			
			destjsp = Cache.getSendJsp(routeid);
			if(destjsp == null || destjsp.trim().equals("")){
				request.setAttribute("result", "S." + routeid + ":blank jsp url@" + TimeUtils.getSysLogTimeString());
				break;
			}
			
			logger.info("[" + routeid + "]send jsp = " + destjsp);
					
			//request.setAttribute("packagecode", packagecode);
		}else{
			String routeid = request.getAttribute("routeid").toString();
			if(!Cache.needRouteStatus(routeid)){
				request.setAttribute("result", "S." + routeid + ":route status not available@" + TimeUtils.getSysLogTimeString());
				break; 			
			}
			
			destjsp = Cache.getRouteStatusJsp(request.getAttribute("routeid").toString());
			logger.info("[" + routeid + "]status jsp = " + destjsp);
			if(destjsp == null || destjsp.trim().equals("")){
				request.setAttribute("result", "S." + routeid + ":blank status jsp url@" + TimeUtils.getSysLogTimeString());
			}
		}
		break;
	}
	
	if(request.getAttribute("result") != null){
		String retstr = request.getAttribute("result").toString();

		JSONObject retjson = new JSONObject();
		retjson.put("id", Integer.parseInt(request.getAttribute("jsonrpcid").toString()));
		
		JSONObject err = new JSONObject();
		err.put("code", 13);
		err.put("message", retstr);
		retjson.put("error", err);
		out.print(retjson.toString());
		return;
	}
	
	request.getRequestDispatcher(destjsp).forward(request, response);
%>