<%@page import="util.MD5Util"%>
<%@page
	import="util.TimeUtils,
				http.HttpAccess,
				cache.Cache,
				net.sf.json.JSONException,
				net.sf.json.JSONObject,
				java.util.*,
				util.MyStringUtils,
				java.net.URLDecoder,
				org.apache.logging.log4j.LogManager,
				org.apache.logging.log4j.Logger"
	language="java" pageEncoding="UTF-8"%>
<%
	boolean logflag = true;
	Logger logger = LogManager.getLogger();

	//获取公共参数
	String taskid = request.getAttribute("taskid").toString();
	String routeid = request.getAttribute("routeid").toString();
	String phone = request.getAttribute("phone").toString();
	String packageid = request.getAttribute("package").toString();

	while (true) {
		String ret = null;

		//检查通道参数, 每个通道有不同参数, 对应 ll_routes.api_params
		Map<String, String> routeparams = Cache.getRouteParams(routeid);
		if (routeparams == null) {
			request.setAttribute("result","S." + routeid + ":wrong routeparams@"+ TimeUtils.getSysLogTimeString());
			break;
		}

		String mt_url = routeparams.get("mt_url");
		if (mt_url == null) {
			request.setAttribute("result",
					"S." + routeid + ":wrong routeparams, mt_url is null@"
							+ TimeUtils.getSysLogTimeString());
			break;
		}
		String sign = routeparams.get("sign");
		if (sign == null) {
			request.setAttribute("result", "S." + routeid
					+ ":wrong routeparams, sign is null@"
					+ TimeUtils.getSysLogTimeString());
			break;
		}
		String userid = routeparams.get("userid");
		if (userid == null) {
			request.setAttribute("result",
					"S." + routeid + ":wrong routeparams, userid is null@"
							+ TimeUtils.getSysLogTimeString());
			break;
		}


		//参数准备, 每个通道不同
		String packagecode = null;
	    if(routeid.equals("3122")){
			//福建
			if(packageid.equals("dx.5M")){
				packagecode = "160618111705582";
			}else if(packageid.equals("dx.10M")){
				packagecode = "160618111351189";
			}else if(packageid.equals("dx.30M")){
				packagecode = "160618111943107";
			}else if(packageid.equals("dx.50M")){
				packagecode = "160618111521819";
			}else if(packageid.equals("dx.100M")){
				packagecode = "160618111816649";
			}else if(packageid.equals("dx.200M")){
				packagecode = "160618111737334";
			}else if(packageid.equals("dx.500M")){
				packagecode = "160618111614189";
			}else if(packageid.equals("dx.1G")){
				packagecode = "160618111446383";
			}
		}else if(routeid.equals("3187")){
			//黑龙江电信
			if(packageid.equals("dx.5M")){
				packagecode = "160618121231969";
			}else if(packageid.equals("dx.10M")){
				packagecode = "160618120814633";
			}else if(packageid.equals("dx.30M")){
				packagecode = "160618121516116";
			}else if(packageid.equals("dx.50M")){
				packagecode = "160618121030624";
			}else if(packageid.equals("dx.100M")){
				packagecode = "160618121431064";
			}else if(packageid.equals("dx.200M")){
				packagecode = "160618121332486";
			}else if(packageid.equals("dx.500M")){
				packagecode = "160618121139293";
			}else if(packageid.equals("dx.1G")){
				packagecode = "160618120921295";
			}
		}else if(routeid.equals("3142")){
			//山西
			if(packageid.equals("dx.5M")){
				packagecode = "161009153051223";
			}else if(packageid.equals("dx.10M")){
				packagecode = "161009152938428";
			}else if(packageid.equals("dx.30M")){
				packagecode = "161009153226709";
			}else if(packageid.equals("dx.50M")){
				packagecode = "161009153334630";
			}else if(packageid.equals("dx.100M")){
				packagecode = "161009153600122";
			}else if(packageid.equals("dx.200M")){
				packagecode = "161009153852808";
			}else if(packageid.equals("dx.500M")){
				packagecode = "161009153959303";
			}else if(packageid.equals("dx.1G")){
				packagecode = "161009154054795";
			}
		}else if(routeid.equals("3141")){
			//陕西
			if(packageid.equals("dx.5M")){
				packagecode = "160618121445876";
			}else if(packageid.equals("dx.10M")){
				packagecode = "160618121244384";
			}else if(packageid.equals("dx.30M")){
				packagecode = "160618121608116";
			}else if(packageid.equals("dx.50M")){
				packagecode = "160618121355867";
			}else if(packageid.equals("dx.100M")){
				packagecode = "160618121544987";
			}else if(packageid.equals("dx.200M")){
				packagecode = "160618121511508";
			}else if(packageid.equals("dx.500M")){
				packagecode = "160618121420944";
			}else if(packageid.equals("dx.1G")){
				packagecode = "160618121326363";
			}
		}else if(routeid.equals("3140")){
			//湖南
			if(packageid.equals("dx.5M")){
				packagecode = "160927163227591";
			}else if(packageid.equals("dx.10M")){
				packagecode = "160927163321343";
			}else if(packageid.equals("dx.30M")){
				packagecode = "160927163420848";
			}else if(packageid.equals("dx.50M")){
				packagecode = "160927163535691";
			}else if(packageid.equals("dx.100M")){
				packagecode = "160927163626764";
			}else if(packageid.equals("dx.200M")){
				packagecode = "160927163702349";
			}else if(packageid.equals("dx.500M")){
				packagecode = "160927163743207";
			}else if(packageid.equals("dx.1G")){
				packagecode = "160927163829731";
			}
		}else if(routeid.equals("3139")){
			//江苏
			if(packageid.equals("dx.5M")){
				packagecode = "160618110749712";
			}else if(packageid.equals("dx.10M")){
				packagecode = "160618105953401";
			}else if(packageid.equals("dx.30M")){
				packagecode = "160618111125775";
			}else if(packageid.equals("dx.50M")){
				packagecode = "160618110512569";
			}else if(packageid.equals("dx.100M")){
				packagecode = "160618111010191";
			}else if(packageid.equals("dx.200M")){
				packagecode = "160618110921589";
			}else if(packageid.equals("dx.500M")){
				packagecode = "160618110636720";
			}else if(packageid.equals("dx.1G")){
				packagecode = "160618110109648";
			}
		}else if(routeid.equals("3138")){
			//重庆
			if(packageid.equals("dx.10M")){
				packagecode = "160618114434345";
			}else if(packageid.equals("dx.30M")){
				packagecode = "160824111318042";
			}else if(packageid.equals("dx.5M")){
				packagecode = "160824111759133";
			}else if(packageid.equals("dx.100M")){
				packagecode = "160824111408302";
			}else if(packageid.equals("dx.200M")){
				packagecode = "160824111500768";
			}else if(packageid.equals("dx.300M")){
				packagecode = "160824111548844";
			}else if(packageid.equals("dx.500M")){
				packagecode = "160824111634492";
			}else if(packageid.equals("dx.1G")){
				packagecode = "160824111851415";
			}
		}else if(routeid.equals("3151")){
			//内蒙古
			if(packageid.equals("dx.10M")){
				packagecode = "161104173304676";
			}else if(packageid.equals("dx.30M")){
				packagecode = "161104173555939";
			}else if(packageid.equals("dx.50M")){
				packagecode = "161104173716741";
			}else if(packageid.equals("dx.100M")){
				packagecode = "161104174127868";
			}else if(packageid.equals("dx.200M")){
				packagecode = "161104174247300";
			}else if(packageid.equals("dx.500M")){
				packagecode = "161104174909803";
			}else if(packageid.equals("dx.1G")){
				packagecode = "161104174622456";
			}
		}else if(routeid.equals("3137")){
			//湖北
			if(packageid.equals("dx.5M")){
				packagecode = "160618115423940";
			}else if(packageid.equals("dx.10M")){
				packagecode = "160618114056020";
			}else if(packageid.equals("dx.30M")){
				packagecode = "160618115745976";
			}else if(packageid.equals("dx.50M")){
				packagecode = "160618115214124";
			}else if(packageid.equals("dx.100M")){
				packagecode = "160618115631858";
			}else if(packageid.equals("dx.200M")){
				packagecode = "160618115532770";
			}else if(packageid.equals("dx.500M")){
				packagecode = "160618115320078";
			}else if(packageid.equals("dx.1G")){
				packagecode = "160618114931811";
			}
		}else if(routeid.equals("3136")){
			//山东
			if(packageid.equals("dx.5M")){
				packagecode = "160517181403879";
			}else if(packageid.equals("dx.10M")){
				packagecode = "160517181634941";
			}else if(packageid.equals("dx.15M")){
				packagecode = "160517182003531";
			}else if(packageid.equals("dx.20M")){
				packagecode = "160517182137534";
			}else if(packageid.equals("dx.30M")){
				packagecode = "160517182242150";
			}else if(packageid.equals("dx.50M")){
				packagecode = "160517182433748";
			}else if(packageid.equals("dx.60M")){
				packagecode = "160517182555891";
			}else if(packageid.equals("dx.100M")){
				packagecode = "160517182751612";
			}else if(packageid.equals("dx.150M")){
				packagecode = "160517182912416";
			}else if(packageid.equals("dx.200M")){
				packagecode = "160517184128655";
			}else if(packageid.equals("dx.250M")){
				packagecode = "160517183029096";
			}else if(packageid.equals("dx.300M")){
				packagecode = "160517183207708";
			}else if(packageid.equals("dx.400M")){
				packagecode = "160517183507723";
			}else if(packageid.equals("dx.600M")){
				packagecode = "160517183731289";
			}else if(packageid.equals("dx.1G")){
				packagecode = "160621164739100";
			}
		}else if(routeid.equals("3135")){
			//上海
			if(packageid.equals("dx.5M")){
				packagecode = "160618111746955";
			}else if(packageid.equals("dx.10M")){
				packagecode = "160618111350825";
			}else if(packageid.equals("dx.30M")){
				packagecode = "160618112317814";
			}else if(packageid.equals("dx.50M")){
				packagecode = "160618111554829";
			}else if(packageid.equals("dx.100M")){
				packagecode = "160618112148827";
			}else if(packageid.equals("dx.200M")){
				packagecode = "160618112011451";
			}else if(packageid.equals("dx.500M")){
				packagecode = "160618111650211";
			}else if(packageid.equals("dx.1G")){
				packagecode = "160618111456665";
			}
		}else if(routeid.equals("3133")){
			//浙江
			if(packageid.equals("dx.5M")){
				packagecode = "160618105021096";
			}else if(packageid.equals("dx.10M")){
				packagecode = "160618103107721";
			}else if(packageid.equals("dx.30M")){
				packagecode = "160618105712825";
			}else if(packageid.equals("dx.50M")){
				packagecode = "160618104212711";
			}else if(packageid.equals("dx.100M")){
				packagecode = "160618105555923";
			}else if(packageid.equals("dx.200M")){
				packagecode = "160618105257167";
			}else if(packageid.equals("dx.500M")){
				packagecode = "160618104746243";
			}else if(packageid.equals("dx.1G")){
				packagecode = "160618103729899";
			}
		}else if(routeid.equals("3134")){
			//安徽
			if(packageid.equals("dx.5M")){
				packagecode = "160616151441582";
			}else if(packageid.equals("dx.10M")){
				packagecode = "160616145907324";
			}else if(packageid.equals("dx.30M")){
				packagecode = "160616151308776";
			}else if(packageid.equals("dx.50M")){
				packagecode = "160616151632725";
			}else if(packageid.equals("dx.100M")){
				packagecode = "160616150256260";
			}else if(packageid.equals("dx.200M")){
				packagecode = "160616151100081";
			}else if(packageid.equals("dx.500M")){
				packagecode = "160616151802372";
			}else if(packageid.equals("dx.1G")){
				packagecode = "160616150453701";
			}
		}else if(routeid.equals("3132")){
			//辽宁
			if(packageid.equals("dx.10M")){
				packagecode = "160824105258574";
			}else if(packageid.equals("dx.30M")){
				packagecode = "160618114823836";
			}else if(packageid.equals("dx.100M")){
				packagecode = "160618114753809";
			}else if(packageid.equals("dx.200M")){
				packagecode = "160618114721288";
			}else if(packageid.equals("dx.300M")){
				packagecode = "160621171519651";
			}else if(packageid.equals("dx.500M")){
				packagecode = "160618114607354";
			}else if(packageid.equals("dx.1G")){
				packagecode = "160618114508427";
			}
		}else if(routeid.equals("3196")){
			//河北电信
			if(packageid.equals("dx.5M")){
				packagecode = "161221144342045";
			}else if(packageid.equals("dx.10M")){
				packagecode = "161221144442297";
			}else if(packageid.equals("dx.30M")){
				packagecode = "161221144522012";
			}else if(packageid.equals("dx.50M")){
				packagecode = "161221144603924";
			}else if(packageid.equals("dx.100M")){
				packagecode = "161221144658164";
			}else if(packageid.equals("dx.200M")){
				packagecode = "161221144740314";
			}else if(packageid.equals("dx.500M")){
				packagecode = "161221144837307";
			}else if(packageid.equals("dx.1G")){
				packagecode = "161221144905861";
			}
		}else if(routeid.equals("3198")){
			//西藏电信
			if(packageid.equals("dx.5M")){
				packagecode = "170103132946639";
			}else if(packageid.equals("dx.10M")){
				packagecode = "170103132502395";
			}else if(packageid.equals("dx.30M")){
				packagecode = "170103133445939";
			}else if(packageid.equals("dx.50M")){
				packagecode = "170103133933646";
			}else if(packageid.equals("dx.100M")){
				packagecode = "170103133059139";
			}else if(packageid.equals("dx.200M")){
				packagecode = "170103133021326";
			}else if(packageid.equals("dx.500M")){
				packagecode = "170103132908771";
			}else if(packageid.equals("dx.1G")){
				packagecode = "170103132727252";
			}
		}else if(routeid.equals("3163")){
			//全国
			if(packageid.equals("dx.5M")){
				packagecode = "151214171346459";
			}else if(packageid.equals("dx.10M")){
				packagecode = "150922145350958";
			}else if(packageid.equals("dx.50M")){
				packagecode = "150922151002067";
			}
		}else if(routeid.equals("1078")){
			//广东移动
			if(packageid.equals("yd.10M")){
				packagecode = "151202221212031";
			}else if(packageid.equals("yd.30M")){
				packagecode = "151202221107318";
			}else if(packageid.equals("yd.70M")){
				packagecode = "151202222130832";
			}else if(packageid.equals("yd.150M")){
				packagecode = "151202221313174";
			}else if(packageid.equals("yd.500M")){
				packagecode = "151202221522450";
			}else if(packageid.equals("yd.1G")){
				packagecode = "151202221615227";
			}else if(packageid.equals("yd.2G")){
				packagecode = "151202221700713";
			}else if(packageid.equals("yd.3G")){
				packagecode = "151202221747970";
			}else if(packageid.equals("yd.4G")){
				packagecode = "151202221939323";
			}else if(packageid.equals("yd.6G")){
				packagecode = "151202222034906";
			}else if(packageid.equals("yd.11G")){
				packagecode = "151202222223968";
			}
		}else if(routeid.equals("1077")){
			//江苏移动
			if(packageid.equals("yd.10M")){
				packagecode = "151201190906567";
			}else if(packageid.equals("yd.30M")){
				packagecode = "151202142652970";
			}else if(packageid.equals("yd.100M")){
				packagecode = "151202142753601";
			}else if(packageid.equals("yd.300M")){
				packagecode = "151202142559458";
			}else if(packageid.equals("yd.500M")){
				packagecode = "151229152821680";
			}else if(packageid.equals("yd.1G")){
				packagecode = "151202142516350";
			}else if(packageid.equals("yd.2G")){
				packagecode = "151202142420211";
			}else if(packageid.equals("yd.3G")){
				packagecode = "151202143106807";
			}else if(packageid.equals("yd.4G")){
				packagecode = "151202143015259";
			}else if(packageid.equals("yd.6G")){
				packagecode = "151202142847334";
			}else if(packageid.equals("yd.11G")){
				packagecode = "151202142937619";
			}
		}else if(routeid.equals("1185")){
			//青海移动
			if(packageid.equals("yd.10M")){
				packagecode = "161129151900330";
			}else if(packageid.equals("yd.30M")){
				packagecode = "161129152005742";
			}else if(packageid.equals("yd.70M")){
				packagecode = "161129152103500";
			}else if(packageid.equals("yd.100M")){
				packagecode = "161114171525087";
			}else if(packageid.equals("yd.150M")){
				packagecode = "161129152150606";
			}else if(packageid.equals("yd.300M")){
				packagecode = "161114171636256";
			}else if(packageid.equals("yd.500M")){
				packagecode = "161114171727847";
			}else if(packageid.equals("yd.1G")){
				packagecode = "161114171810848";
			}else if(packageid.equals("yd.2G")){
				packagecode = "161129152258448";
			}else if(packageid.equals("yd.3G")){
				packagecode = "161129152422304";
			}else if(packageid.equals("yd.4G")){
				packagecode = "161129152619120";
			}else if(packageid.equals("yd.6G")){
				packagecode = "161129152713075";
			}else if(packageid.equals("yd.11G")){
				packagecode = "161129152810933";
			}
		}else if(routeid.equals("1076")){
			//安徽移动
			if(packageid.equals("yd.10M")){
				packagecode = "151218142947619";
			}else if(packageid.equals("yd.30M")){
				packagecode = "151229173133899";
			}else if(packageid.equals("yd.100M")){
				packagecode = "160616112412073";
			}else if(packageid.equals("yd.300M")){
				packagecode = "160616113010018";
			}else if(packageid.equals("yd.500M")){
				packagecode = "151202215336654";
			}else if(packageid.equals("yd.1G")){
				packagecode = "151202215221704";
			}else if(packageid.equals("yd.2G")){
				packagecode = "151202215843890";
			}else if(packageid.equals("yd.3G")){
				packagecode = "151202215719503";
			}else if(packageid.equals("yd.4G")){
				packagecode = "151202215625524";
			}else if(packageid.equals("yd.6G")){
				packagecode = "151229173235539";
			}else if(packageid.equals("yd.11G")){
				packagecode = "151229173045543";
			}
		}else if(routeid.equals("1075")){
			//海南移动
			if(packageid.equals("yd.10M")){
				packagecode = "160606165819807";
			}else if(packageid.equals("yd.30M")){
				packagecode = "160606170045283";
			}else if(packageid.equals("yd.70M")){
				packagecode = "160606170147079";
			}else if(packageid.equals("yd.150M")){
				packagecode = "160606170252510";
			}else if(packageid.equals("yd.500M")){
				packagecode = "160606170507964";
			}else if(packageid.equals("yd.1G")){
				packagecode = "160606170611175";
			}else if(packageid.equals("yd.2G")){
				packagecode = "160606170701591";
			}else if(packageid.equals("yd.3G")){
				packagecode = "160606170807300";
			}else if(packageid.equals("yd.4G")){
				packagecode = "160606170906881";
			}else if(packageid.equals("yd.6G")){
				packagecode = "160606171023414";
			}else if(packageid.equals("yd.11G")){
				packagecode = "160606171142741";
			}
		}else if(routeid.equals("1074")){
			//山西移动
			if(packageid.equals("yd.10M")){
				packagecode = "260626111758484";
			}else if(packageid.equals("yd.30M")){
				packagecode = "260626111343779";
			}else if(packageid.equals("yd.70M")){
				packagecode = "260626112054742";
			}else if(packageid.equals("yd.150M")){
				packagecode = "260626111433588";
			}else if(packageid.equals("yd.500M")){
				packagecode = "260626110501127";
			}else if(packageid.equals("yd.1G")){
				packagecode = "260626111612856";
			}else if(packageid.equals("yd.2G")){
				packagecode = "260626110501128";
			}else if(packageid.equals("yd.3G")){
				packagecode = "260626111901753";
			}else if(packageid.equals("yd.4G")){
				packagecode = "260626111945493";
			}else if(packageid.equals("yd.6G")){
				packagecode = "260626112018041";
			}else if(packageid.equals("yd.11G")){
				packagecode = "260626110659716";
			}
		}else if(routeid.equals("1173")){
			//辽宁移动
			if(packageid.equals("yd.10M")){
				packagecode = "160102180946248";
			}else if(packageid.equals("yd.30M")){
				packagecode = "160102181214510";
			}else if(packageid.equals("yd.70M")){
				packagecode = "160102181523545";
			}else if(packageid.equals("yd.150M")){
				packagecode = "160102181630991";
			}else if(packageid.equals("yd.500M")){
				packagecode = "160102181807324";
			}else if(packageid.equals("yd.700M")){
				packagecode = "161126104404100";
			}else if(packageid.equals("yd.1G")){
				packagecode = "160102182416517";
			}else if(packageid.equals("yd.2G")){
				packagecode = "160102181717034";
			}else if(packageid.equals("yd.3G")){
				packagecode = "160102181856842";
			}else if(packageid.equals("yd.4G")){
				packagecode = "160102182055317";
			}else if(packageid.equals("yd.6G")){
				packagecode = "160102182227673";
			}else if(packageid.equals("yd.11G")){
				packagecode = "160102182330425";
			}
		}else if(routeid.equals("1090")){
			//山东移动
			if(packageid.equals("yd.10M")){
				packagecode = "360626111758484";
			}else if(packageid.equals("yd.30M")){
				packagecode = "360626111343779";
			}else if(packageid.equals("yd.70M")){
				packagecode = "360626112054742";
			}else if(packageid.equals("yd.150M")){
				packagecode = "360626111433588";
			}else if(packageid.equals("yd.500M")){
				packagecode = "360626110501127";
			}else if(packageid.equals("yd.1G")){
				packagecode = "360626111612856";
			}else if(packageid.equals("yd.2G")){
				packagecode = "360626110501128";
			}else if(packageid.equals("yd.3G")){
				packagecode = "360626111901753";
			}else if(packageid.equals("yd.4G")){
				packagecode = "360626111945493";
			}else if(packageid.equals("yd.6G")){
				packagecode = "360626112018041";
			}else if(packageid.equals("yd.11G")){
				packagecode = "360626110659716";
			}
		}else if(routeid.equals("1091")){
			//天津移动
			if(packageid.equals("yd.10M")){
				packagecode = "160421111159106";
			}else if(packageid.equals("yd.30M")){
				packagecode = "160421111317103";
			}else if(packageid.equals("yd.70M")){
				packagecode = "160421111406720";
			}else if(packageid.equals("yd.150M")){
				packagecode = "160421111526171";
			}else if(packageid.equals("yd.500M")){
				packagecode = "160421111552736";
			}else if(packageid.equals("yd.1G")){
				packagecode = "160421111621133";
			}else if(packageid.equals("yd.2G")){
				packagecode = "160421111652278";
			}else if(packageid.equals("yd.3G")){
				packagecode = "160421111721567";
			}else if(packageid.equals("yd.4G")){
				packagecode = "160421111824982";
			}else if(packageid.equals("yd.6G")){
				packagecode = "160421111910769";
			}else if(packageid.equals("yd.11G")){
				packagecode = "160421111950887";
			}
		}else if(routeid.equals("1158")){
			//宁夏移动
			if(packageid.equals("yd.10M")){
				packagecode = "160811144725331";
			}else if(packageid.equals("yd.30M")){
				packagecode = "160811145051812";
			}else if(packageid.equals("yd.70M")){
				packagecode = "160811144457536";
			}else if(packageid.equals("yd.150M")){
				packagecode = "160811144631149";
			}else if(packageid.equals("yd.500M")){
				packagecode = "160811144825996";
			}else if(packageid.equals("yd.1G")){
				packagecode = "160811145130128";
			}else if(packageid.equals("yd.2G")){
				packagecode = "160811145210053";
			}else if(packageid.equals("yd.3G")){
				packagecode = "160811145313924";
			}else if(packageid.equals("yd.4G")){
				packagecode = "160811145415935";
			}else if(packageid.equals("yd.6G")){
				packagecode = "160811145512535";
			}else if(packageid.equals("yd.11G")){
				packagecode = "160811145547581";
			}
		}else if(routeid.equals("1157")){
			//西藏移动
			if(packageid.equals("yd.10M")){
				packagecode = "160224111758484";
			}else if(packageid.equals("yd.30M")){
				packagecode = "160224111343779";
			}else if(packageid.equals("yd.70M")){
				packagecode = "160224112054742";
			}else if(packageid.equals("yd.150M")){
				packagecode = "160224111433588";
			}else if(packageid.equals("yd.500M")){
				packagecode = "160224110501127";
			}else if(packageid.equals("yd.1G")){
				packagecode = "160224111612856";
			}else if(packageid.equals("yd.2G")){
				packagecode = "160224110501128";
			}else if(packageid.equals("yd.3G")){
				packagecode = "160224111901753";
			}else if(packageid.equals("yd.4G")){
				packagecode = "160224111945493";
			}else if(packageid.equals("yd.6G")){
				packagecode = "160224112018041";
			}else if(packageid.equals("yd.11G")){
				packagecode = "160224110659716";
			}
		}/* else if(routeid.equals("3141")){
			//陕西移动
			if(packageid.equals("yd.10M")){
				packagecode = "160101021425424";
			}else if(packageid.equals("yd.30M")){
				packagecode = "160101021519328";
			}else if(packageid.equals("yd.70M")){
				packagecode = "160101021623405";
			}else if(packageid.equals("yd.150M")){
				packagecode = "160101021353073";
			}else if(packageid.equals("yd.500M")){
				packagecode = "160101021454681";
			}else if(packageid.equals("yd.1G")){
				packagecode = "160101021237839";
			}else if(packageid.equals("yd.2G")){
				packagecode = "160101021314519";
			}else if(packageid.equals("yd.3G")){
				packagecode = "160101021557315";
			}else if(packageid.equals("yd.4G")){
				packagecode = "160222111945493";
			}else if(packageid.equals("yd.6G")){
				packagecode = "160222112018041";
			}else if(packageid.equals("yd.11G")){
				packagecode = "160222110659716";
			}else if(packageid.equals("yd.700M")){
				packagecode = "161007094615833";
			}else if(packageid.equals("yd.100M")){
				packagecode = "161207104209508";
			}
		} */else if(routeid.equals("3186")){
			//四川电信
			if(packageid.equals("dx.5M")){
				packagecode = "160618112948797";
			}else if(packageid.equals("dx.10M")){
				packagecode = "160618112705531";
			}else if(packageid.equals("dx.50M")){
				packagecode = "160618112840291";
			}else if(packageid.equals("dx.30M")){
				packagecode = "160618113224977";
			}else if(packageid.equals("dx.100M")){
				packagecode = "160618113142753";
			}else if(packageid.equals("dx.200M")){
				packagecode = "160618113043649";
			}else if(packageid.equals("dx.500M")){
				packagecode = "160618112912548";
			}else if(packageid.equals("dx.1G")){
				packagecode = "160618112749141";
			}
		}else if(routeid.equals("1159")){
			//内蒙古移动
			if(packageid.equals("yd.10M")){
				packagecode = "160413094932084";
			}else if(packageid.equals("yd.30M")){
				packagecode = "160413095447919";
			}else if(packageid.equals("yd.70M")){
				packagecode = "160720145928337";
			}else if(packageid.equals("yd.150M")){
				packagecode = "160720150110762";
			}else if(packageid.equals("yd.500M")){
				packagecode = "160720150218436";
			}else if(packageid.equals("yd.1G")){
				packagecode = "160720150426648";
			}else if(packageid.equals("yd.2G")){
				packagecode = "160720150609559";
			}else if(packageid.equals("yd.3G")){
				packagecode = "160720150756873";
			}else if(packageid.equals("yd.4G")){
				packagecode = "160720150841707";
			}else if(packageid.equals("yd.6G")){
				packagecode = "160720150934871";
			}else if(packageid.equals("yd.100M")){
				packagecode = "160818113720881";
			}else if(packageid.equals("yd.300M")){
				packagecode = "160818113817141";
			}else if(packageid.equals("yd.11G")){
				packagecode = "160720151102762";
			}
		}else if(routeid.equals("1092")){
			//广西移动
			if(packageid.equals("yd.10M")){
				packagecode = "160103153141363";
			}else if(packageid.equals("yd.30M")){
				packagecode = "160103153908356";
			}else if(packageid.equals("yd.70M")){
				packagecode = "160103153827799";
			}else if(packageid.equals("yd.150M")){
				packagecode = "160103153747180";
			}else if(packageid.equals("yd.500M")){
				packagecode = "160103153701208";
			}else if(packageid.equals("yd.1G")){
				packagecode = "160103153616370";
			}else if(packageid.equals("yd.2G")){
				packagecode = "160103153058882";
			}else if(packageid.equals("yd.3G")){
				packagecode = "160103153529324";
			}else if(packageid.equals("yd.4G")){
				packagecode = "160103153449559";
			}else if(packageid.equals("yd.6G")){
				packagecode = "160103153347260";
			}else if(packageid.equals("yd.11G")){
				packagecode = "160103153235100";
			}
		}else if(routeid.equals("1099")){
			//全国移动
			if(packageid.equals("yd.10M")){
				packagecode = "20150626111758484";
			}else if(packageid.equals("yd.30M")){
				packagecode = "20150626111343779";
			}else if(packageid.equals("yd.70M")){
				packagecode = "20150626112054742";
			}else if(packageid.equals("yd.100M")){
				packagecode = "160621094249307";
			}else if(packageid.equals("yd.150M")){
				packagecode = "20150626111433588";
			}else if(packageid.equals("yd.300M")){
				packagecode = "160621094330383";
			}else if(packageid.equals("yd.500M")){
				packagecode = "20150626111226291";
			}else if(packageid.equals("yd.1G")){
				packagecode = "20150626111612856";
			}else if(packageid.equals("yd.2G")){
				packagecode = "20150626110501127";
			}else if(packageid.equals("yd.3G")){
				packagecode = "20150626111901753";
			}else if(packageid.equals("yd.4G")){
				packagecode = "20150626111945493";
			}else if(packageid.equals("yd.6G")){
				packagecode = "20150626112018041";
			}else if(packageid.equals("yd.11G")){
				packagecode = "20150626110659716";
			}
		}else if(routeid.equals("1102")){
			//全国移动
			if(packageid.equals("yd.500M")){
				packagecode = "20150626111226291";
			}else if(packageid.equals("yd.2G")){
				packagecode = "20150626110501127";
			}
		}else if(routeid.equals("1098")){
			//湖南移动
			if(packageid.equals("yd.10M")){
				packagecode = "160103150418279";
			}else if(packageid.equals("yd.30M")){
				packagecode = "160103150518253";
			}else if(packageid.equals("yd.70M")){
				packagecode = "160103151404583";
			}else if(packageid.equals("yd.150M")){
				packagecode = "160103151322722";
			}else if(packageid.equals("yd.500M")){
				packagecode = "160103151011585";
			}else if(packageid.equals("yd.1G")){
				packagecode = "160103151445888";
			}else if(packageid.equals("yd.2G")){
				packagecode = "160103150810252";
			}else if(packageid.equals("yd.3G")){
				packagecode = "160103150705623";
			}else if(packageid.equals("yd.4G")){
				packagecode = "160103150618011";
			}else if(packageid.equals("yd.6G")){
				packagecode = "160103151546853";
			}else if(packageid.equals("yd.11G")){
				packagecode = "160103150920561";
			}
		}else if(routeid.equals("1097")){
			//陕西移动
			if(packageid.equals("yd.10M")){
				packagecode = "160101021425424";
			}else if(packageid.equals("yd.30M")){
				packagecode = "160101021519328";
			}else if(packageid.equals("yd.70M")){
				packagecode = "160101021623405";
			}else if(packageid.equals("yd.150M")){
				packagecode = "160101021353073";
			}else if(packageid.equals("yd.500M")){
				packagecode = "160101021454681";
			}else if(packageid.equals("yd.1G")){
				packagecode = "160101021237839";
			}else if(packageid.equals("yd.2G")){
				packagecode = "160101021314519";
			}else if(packageid.equals("yd.3G")){
				packagecode = "160101021557315";
			}else if(packageid.equals("yd.4G")){
				packagecode = "160222111945493";
			}else if(packageid.equals("yd.6G")){
				packagecode = "160222112018041";
			}else if(packageid.equals("yd.11G")){
				packagecode = "160222110659716";
			}
		}else if(routeid.equals("2051")){
			//河南联通
			if(packageid.equals("lt.20M")){
				packagecode = "160702170601770";
			}else if(packageid.equals("lt.50M")){
				packagecode = "160702170623572";
			}else if(packageid.equals("lt.100M")){
				packagecode = "160702170650962";
			}else if(packageid.equals("lt.200M")){
				packagecode = "160702170818606";
			}else if(packageid.equals("lt.500M")){
				packagecode = "160702170940744";
			}else if(packageid.equals("lt.300M")){
				packagecode = "161019163626206";
			}else if(packageid.equals("lt.1G")){
				packagecode = "161107142528189";
			}
		}else if(routeid.equals("2017")){
			//山东联通
			if(packageid.equals("lt.20M")){
				packagecode = "160517171444202";
			}else if(packageid.equals("lt.50M")){
				packagecode = "160517171901463";
			}else if(packageid.equals("lt.100M")){
				packagecode = "160517171653553";
			}else if(packageid.equals("lt.200M")){
				packagecode = "160517172019115";
			}else if(packageid.equals("lt.500M")){
				packagecode = "160517172507710";
			}else if(packageid.equals("lt.300M")){
				packagecode = "160517172345603";
			}else if(packageid.equals("lt.1G")){
				packagecode = "160517172656839";
			}else if(packageid.equals("lt.30M")){
				packagecode = "161019094940178";
			}
		}else if(routeid.equals("2022")){
			//辽宁联通
			if(packageid.equals("lt.50M")){
				packagecode = "160621151933326";
			}else if(packageid.equals("lt.100M")){
				packagecode = "160621151815606";
			}else if(packageid.equals("lt.200M")){
				packagecode = "160621151649705";
			}else if(packageid.equals("lt.500M")){
				packagecode = "160621150314988";
			}else if(packageid.equals("lt.300M")){
				packagecode = "161019093215475";
			}
		}else if(routeid.equals("1096")){
			//浙江移动
			if(packageid.equals("yd.10M")){
				packagecode = "160512161012787";
			}else if(packageid.equals("yd.30M")){
				packagecode = "151222165449204";
			}else if(packageid.equals("yd.70M")){
				packagecode = "151202210251408";
			}else if(packageid.equals("yd.100M")){
				packagecode = "160621152057165";
			}else if(packageid.equals("yd.150M")){
				packagecode = "151202210205987";
			}else if(packageid.equals("yd.200M")){
				packagecode = "160621151549930";
			}else if(packageid.equals("yd.300M")){
				packagecode = "160623134854917";
			}else if(packageid.equals("yd.500M")){
				packagecode = "160303220501127";
			}else if(packageid.equals("yd.1G")){
				packagecode = "151202210800285";
			}else if(packageid.equals("yd.2G")){
				packagecode = "151202210711226";
			}else if(packageid.equals("yd.3G")){
				packagecode = "151202210622485";
			}else if(packageid.equals("yd.4G")){
				packagecode = "151202210354013";
			}else if(packageid.equals("yd.6G")){
				packagecode = "151202210443413";
			}else if(packageid.equals("yd.11G")){
				packagecode = "151202210528636";
			}
		}
		

		if (packagecode == null) {
			request.setAttribute("result",
					"S." + routeid + ":unrecognized package@"
							+ TimeUtils.getSysLogTimeString());
			break;
		}
		String productnum="1";
		String key = MD5Util.getLowerMD5(userid + packagecode + productnum + phone+ sign);
		Map<String, String> map = new HashMap<String, String>();
		map.put("productid", packagecode);
		map.put("useract", phone);
		map.put("userid", userid);
		map.put("bizid", taskid);
		map.put("productnum", productnum);
		map.put("key", key);

		//在执行请求前先获取连接, 防止访问通道线程超量
		Cache.getConnection(routeid);
		try {
			//ret = HttpAccess.postNameValuePairRequest(url, params, "utf-8", "mysend");
			//ret = HttpAccess.postJsonRequest(url, json.toString(), "utf-8", "weikesend");
			ret=HttpAccess.postNameValuePairRequest(mt_url, map, "utf-8", "kachi");	
		} catch (Exception e) {
			e.printStackTrace();
			logger.info(e.getMessage());
		} finally {
			//在执行请求后记得释放连接
			Cache.releaseConnection(routeid);
		}

		//这里判断结果, 每个通道情况不同, 成功的保存 success 到 result 中并返回到 request.jsp
		if (ret != null && ret.trim().length() > 0) {
			logger.info("kachi send ret = " + ret);
			try {
				JSONObject retjson = JSONObject.fromObject(ret);
				String rescode = retjson.getString("rescode"); //":"MOB00001"
				String result = retjson.getString("result"); //":"MOB00001"
				if (result.equals("ok")&&rescode.equals("1")) {
					request.setAttribute("result", "success");
				} else {
					request.setAttribute("code", rescode);
					String resultMsg=retjson.getString("msg");
					request.setAttribute(
							"result",
							"R." + routeid + ":" + rescode + ":"
									+ resultMsg + "@"
									+ TimeUtils.getSysLogTimeString());
				}
				request.setAttribute("orgreturn", ret);
			} catch (Exception e)    {
				e.printStackTrace();
				logger.info(e.getMessage());
				request.setAttribute("result",
						"R." + routeid + ":" + e.getMessage() + "@"
								+ TimeUtils.getSysLogTimeString());
			}
		} else {
			request.setAttribute("result", "R." + routeid + ":fail@"
					+ TimeUtils.getSysLogTimeString());
		}

		break;
	}

	request.getRequestDispatcher("request.jsp").forward(request,
			response);
%>