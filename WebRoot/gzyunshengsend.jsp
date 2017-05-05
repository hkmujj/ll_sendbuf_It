<%@page
	import="util.TimeUtils,
				http.HttpAccess,
				util.MD5Util,
				cache.Cache,
				net.sf.json.JSONException,
				net.sf.json.JSONObject,
				java.util.*,
				util.MyStringUtils,
				java.net.URLDecoder,
				org.apache.logging.log4j.LogManager,
				org.apache.logging.log4j.Logger,
				util.MyBase64,
				java.security.MessageDigest,
				java.security.NoSuchAlgorithmException,
				java.io.UnsupportedEncodingException"
	language="java" pageEncoding="UTF-8"%><%!private static String sign(String key, String timestamp, String account) {
		String[] arr = new String[] { key, timestamp, account };
		Arrays.sort(arr);
		StringBuilder content = new StringBuilder();
		for (int i = 0; i < arr.length; i++) {
			content.append(arr[i]);
		}
		String signature = null;
		try {
			MessageDigest md = MessageDigest.getInstance("SHA-1");
			byte[] digest = md.digest(content.toString().getBytes("utf-8"));
			signature = toHexString(digest);
		} catch (NoSuchAlgorithmException e) {
			e.printStackTrace();
		} catch (UnsupportedEncodingException e) {
			e.printStackTrace();
		}
		return signature;
	}

	public static final char HEX_DIGITS[] = { '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'a', 'b', 'c', 'd', 'e', 'f' };

	public static String toHexString(byte[] bytes) {
		StringBuilder sb = new StringBuilder(bytes.length * 2);
		for (int i = 0; i < bytes.length; i++) {
			sb.append(HEX_DIGITS[(bytes[i] & 0xf0) >>> 4]);
			sb.append(HEX_DIGITS[bytes[i] & 0x0f]);
		}
		return sb.toString();
	}%>
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

		//检查通道参数, 每个通道有不同参数, 对应 ll_routes.api_params(私有参数)
		Map<String, String> routeparams = Cache.getRouteParams(routeid);
		if (routeparams == null) {
			request.setAttribute("result", "S." + routeid + ":wrong routeparams@" + TimeUtils.getSysLogTimeString());
			break;
		}

		String url = routeparams.get("url");
		if (url == null) {
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, url is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String productType = routeparams.get("productType");//a为全国包 p为省包
		if (productType == null) {
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, productType is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String key = routeparams.get("key");
		if (key == null) {
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, key is null@" + TimeUtils.getSysLogTimeString());
			break;
		}
		String account = routeparams.get("account");
		if (account == null) {
			request.setAttribute("result", "S." + routeid + ":wrong routeparams, account is null@" + TimeUtils.getSysLogTimeString());
			break;
		}

		//参数准备, 每个通道不同
		String packagecode = null;
		if (routeid.equals("3070")) {
			//全国电信
			if (packageid.equals("dx.5M")) {
				packagecode = "f8ab469b63834bc4ba97f3bda7b5071a";
			} else if (packageid.equals("dx.10M")) {
				packagecode = "9440db03c96a40778bdd71c1e8d26ea7";
			} else if (packageid.equals("dx.30M")) {
				packagecode = "2dcf19561ce145f0b7dd9426a13bdbb7";
			} else if (packageid.equals("dx.50M")) {
				packagecode = "8cfa0259033f4260afd276b48a0244e5 ";
			} else if (packageid.equals("dx.100M")) {
				packagecode = "c0350f44333e4e659d12eed788a1a841";
			} else if (packageid.equals("dx.200M")) {
				packagecode = "4052c35271554d8aaf7958515d3f8474";
			} else if (packageid.equals("dx.300M")) {
				packagecode = "d4ea9447ac3f44cc840c10f31d5eec3b";
			} else if (packageid.equals("dx.500M")) {
				packagecode = "6f9f3489da194c5fad8c3cf637584d1e";
			} else if (packageid.equals("dx.1G")) {
				packagecode = "f41e25abf4284a6b83df55eae2c2dbfe";
			} else if (packageid.equals("dx.2G")) {
				packagecode = "5f321ecc43714adb92f4c6c321988b17";
			} else if (packageid.equals("dx.3G")) {
				packagecode = "eb2420b9e7cc487c9b8a0e9788d14dbe";
			}
		}else if (routeid.equals("3291")) {
			//全国电信
			if (packageid.equals("dx.1G")) {
				packagecode = "f41e25abf4284a6b83df55eae2c2dbfe";
			}
		} else if (routeid.equals("1287")) {
			//广西移动
			if (packageid.equals("yd.10M")) {
				packagecode = "08b1fa25eac2473b9a364bb4bb47a5e7";
			} else if (packageid.equals("yd.30M")) {
				packagecode = "aeb43c40f8624ab3ad0c1797a2c8d871";
			} else if (packageid.equals("yd.70M")) {
				packagecode = "ab7284c6962d46f0bed0fed5922db8d5";
			} else if (packageid.equals("yd.100M")) {
				packagecode = "d65da6b01f694dff9bd011aa2bf30335";
			} else if (packageid.equals("yd.150M")) {
				packagecode = "a24bbd5cd1c64e64853054ea71086dff";
			} else if (packageid.equals("yd.300M")) {
				packagecode = "44189c76e03b4d31b240700ea3fee14f";
			} else if (packageid.equals("yd.500M")) {
				packagecode = "ff022a54899a49ac927f3cf3a7f5610e";
			} else if (packageid.equals("yd.1G")) {
				packagecode = "6f291f19acf74887ae6770c3101d985b";
			} else if (packageid.equals("yd.2G")) {
				packagecode = "6139a712f05a4a6695d3e4041b0e6a38";
			} else if (packageid.equals("yd.3G")) {
				packagecode = "bd702a5d7b854b7ca56e818675f1db85";
			} else if (packageid.equals("yd.4G")) {
				packagecode = "28985374f3b4496b93693603fa2fd63c";
			} else if (packageid.equals("yd.6G")) {
				packagecode = "d2b768bf771d4b4583b3de13b143b043";
			} else if (packageid.equals("yd.11G")) {
				packagecode = "ceb7223d733e48e5a9225171ac6ed5fe";
			}
		} else if (routeid.equals("1286")) {
			//湖南移动
			if (packageid.equals("yd.10M")) {
				packagecode = "0b24c46c2f704dce9a00cf15534dc645";
			} else if (packageid.equals("yd.30M")) {
				packagecode = "8a09f8daa1544d488fe906ccb763140b";
			} else if (packageid.equals("yd.70M")) {
				packagecode = "82be4f1d5c454d11ace82e9a171c6f59";
			} else if (packageid.equals("yd.100M")) {
				packagecode = "06b981951a4946bfa710e7d967056088";
			} else if (packageid.equals("yd.150M")) {
				packagecode = "95cb8932d2c146be97a6d2e7f9c90f68";
			} else if (packageid.equals("yd.300M")) {
				packagecode = "0df38fd11a6c485ba4f437929a287b4f";
			} else if (packageid.equals("yd.500M")) {
				packagecode = "15dd278b27f749e3addbfaad6ea21e5b";
			} else if (packageid.equals("yd.1G")) {
				packagecode = "9d221fdbb6b44bda8e37fdf3f92bdb64";
			} else if (packageid.equals("yd.2G")) {
				packagecode = "00947f9123db4d7c81e7004f0707d0b1";
			} else if (packageid.equals("yd.3G")) {
				packagecode = "677a92e9c35c4a709cc081d32f933870";
			} else if (packageid.equals("yd.4G")) {
				packagecode = "b7fd3d91e670498591e68359db8f6a88";
			} else if (packageid.equals("yd.6G")) {
				packagecode = "77f6606d478b4f36bc75a30ef112f13f";
			} else if (packageid.equals("yd.11G")) {
				packagecode = "16e5827902fd4701aa4a92088eef4850";
			}
		} else if (routeid.equals("3068")) {
			//湖南电信
			if (packageid.equals("dx.5M")) {
				packagecode = "556e1b3de9d74a5e99346c806fc790db";
			} else if (packageid.equals("dx.10M")) {
				packagecode = "f90ec3990c534d35912f87d4602aa5a2";
			} else if (packageid.equals("dx.30M")) {
				packagecode = "69dfe8b8fdb04f379d3410642fa28ea9";
			} else if (packageid.equals("dx.50M")) {
				packagecode = "2f844a9d2fab46eea57d1a7de05597f0";
			} else if (packageid.equals("dx.100M")) {
				packagecode = "c7253f8a39674807930109e59ec92ff1";
			} else if (packageid.equals("dx.200M")) {
				packagecode = "994a1ed6b20a44f5ac99f5a397b85fba";
			} else if (packageid.equals("dx.500M")) {
				packagecode = "f5687e2c26434d2faedc636d0fc0e082";
			} else if (packageid.equals("dx.1G")) {
				packagecode = "cc7dcfd8f6ea4af2b3696fa9141ea937";
			}
		} else if (routeid.equals("3067")) {
			//广西电信
			if (packageid.equals("dx.5M")) {
				packagecode = "6f9ce0598a944dcbbe0dad3256aa9353";
			} else if (packageid.equals("dx.10M")) {
				packagecode = "3d7cf07ed2a0451d94da026b7230b76e";
			} else if (packageid.equals("dx.30M")) {
				packagecode = "e5525427cf9a4a17934284737a137ff3";
			} else if (packageid.equals("dx.50M")) {
				packagecode = "ed0ec003c3ce49afafc4b564a517ec4c";
			} else if (packageid.equals("dx.100M")) {
				packagecode = "35693c6caf1f4fbc873e1a5ff6a85cf4";
			} else if (packageid.equals("dx.200M")) {
				packagecode = "539ca8ec20d64b1cbbcd7839820c6fdf";
			} else if (packageid.equals("dx.500M")) {
				packagecode = "77fde51389364d02833fc557634ea6f3";
			} else if (packageid.equals("dx.1G")) {
				packagecode = "630398f0040542398a9fa7da22802f77";
			}
		} else if (routeid.equals("3065")) {
			//云南电信
			if (packageid.equals("dx.5M")) {
				packagecode = "884fd1d928cd4cb7bdb782e12d567156";
			} else if (packageid.equals("dx.10M")) {
				packagecode = "7ae8855b8c28413e8b473cd5ddb813a6";
			} else if (packageid.equals("dx.30M")) {
				packagecode = "bf1a03a27a1b420ca2c5cef533ee4e1a";
			} else if (packageid.equals("dx.50M")) {
				packagecode = "7be56132a5b8448a9e1562b9716ddb76";
			} else if (packageid.equals("dx.100M")) {
				packagecode = "3ae5542d38434338a94a127a959fb7d4";
			} else if (packageid.equals("dx.200M")) {
				packagecode = "8c893f6b92da4070829b146ca4010f7d";
			} else if (packageid.equals("dx.500M")) {
				packagecode = "0e9aba4e06724cdfaebc1234816a881c";
			} else if (packageid.equals("dx.1G")) {
				packagecode = "1eb29e4ebb6944159bc2df9f1fa06fe1";
			}
		} else if (routeid.equals("3064")) {
			//上海电信
			if (packageid.equals("dx.5M")) {
				packagecode = "ad8cd88a2f084551bde8977fc7cd342c";
			} else if (packageid.equals("dx.10M")) {
				packagecode = "d2cf0072b9a843f7af01f87593068613";
			} else if (packageid.equals("dx.30M")) {
				packagecode = "8188383630fe49dd8c53c7957d8ac29d";
			} else if (packageid.equals("dx.50M")) {
				packagecode = "370996bb45194b8da7867c41bee49208";
			} else if (packageid.equals("dx.100M")) {
				packagecode = "b566fcdda51b4d23a79b8c853cc06790";
			} else if (packageid.equals("dx.200M")) {
				packagecode = "693b1bf275de48f78b080e21317dd242";
			} else if (packageid.equals("dx.500M")) {
				packagecode = "2264875fc0f54b3e8ca4c8dca36d7e3d";
			} else if (packageid.equals("dx.1G")) {
				packagecode = "e4ea8ae2afb342ef903e2a35035fa0b2";
			}
		} else if (routeid.equals("3063")) {
			//辽宁电信
			if (packageid.equals("dx.5M")) {
				packagecode = "cfb62b3b7a834ca8adce20dd1dc5223e";
			} else if (packageid.equals("dx.10M")) {
				packagecode = "c3a255401f6c4ee5a662ee7b8680d1f0";
			} else if (packageid.equals("dx.30M")) {
				packagecode = "9abc1da352184df78539ade28e149194";
			} else if (packageid.equals("dx.50M")) {
				packagecode = "5f08e5bd53d241dbb36876866dbad1ca";
			} else if (packageid.equals("dx.100M")) {
				packagecode = "16ce99302723484a9eebfafb5006fb43";
			} else if (packageid.equals("dx.200M")) {
				packagecode = "6ff91d15b75f4d5782cdf0ae2428faf7";
			} else if (packageid.equals("dx.500M")) {
				packagecode = "bceda61fa33e48a0b4a4ba9c524f2e44";
			} else if (packageid.equals("dx.1G")) {
				packagecode = "c76a3fbb47db4e11b4032e726fd9ed5e";
			}
		} else if (routeid.equals("3062")) {
			//吉林电信
			if (packageid.equals("dx.10M")) {
				packagecode = "580f805256db4ef1b5d055cb3b698303";
			} else if (packageid.equals("dx.30M")) {
				packagecode = "7e9b6367de164cca84780c4149f1f17e";
			} else if (packageid.equals("dx.5M")) {
				packagecode = "3fc7028dd253484485c75679b236621f";
			} else if (packageid.equals("dx.100M")) {
				packagecode = "daccaf5adced4fc5852d422dfbb818c6";
			} else if (packageid.equals("dx.200M")) {
				packagecode = "88b55efe218b432db73d48bff3ed6807";
			} else if (packageid.equals("dx.500M")) {
				packagecode = "ab607d0c74a24d5a9ee71265cf39704f";
			} else if (packageid.equals("dx.1G")) {
				packagecode = "b251bec01b5641c288ca81826c126db1";
			}
		} else if (routeid.equals("3061")) {
			//湖北电信
			if (packageid.equals("dx.5M")) {
				packagecode = "606aeb1a2faf463d8f9c8f8ac2364b64";
			} else if (packageid.equals("dx.10M")) {
				packagecode = "01c3b155109f47dd8b445ed6206d44b8";
			} else if (packageid.equals("dx.30M")) {
				packagecode = "7764f6bfb8d445d58e929b6443c2d915";
			} else if (packageid.equals("dx.50M")) {
				packagecode = "4bab9c597af041bbb9ff697fa5534781";
			} else if (packageid.equals("dx.100M")) {
				packagecode = "18feee3cbebd4205a62c220288bfeb33";
			} else if (packageid.equals("dx.200M")) {
				packagecode = "60a6a1624c1246a8b5a1416a51d753df";
			} else if (packageid.equals("dx.500M")) {
				packagecode = "4c756aed87f24b99a8fa198eca770526";
			} else if (packageid.equals("dx.1G")) {
				packagecode = "25d15e759fe3460babd6566c8ae2ca02";
			}
		} else if (routeid.equals("3060")) {
			//福建电信
			if (packageid.equals("dx.5M")) {
				packagecode = "0f644d857419448abfa8717b04071901";
			} else if (packageid.equals("dx.10M")) {
				packagecode = "dfe2edc8226d44b7b8cbfa2df5e986af";
			} else if (packageid.equals("dx.30M")) {
				packagecode = "c5a3d0b1cfdf4b7aa7a2ee14a6468bf9";
			} else if (packageid.equals("dx.50M")) {
				packagecode = "34ba6249510c4c748f0f23e93f53fb90";
			} else if (packageid.equals("dx.100M")) {
				packagecode = "04c276f1713f48b3a37f4c1dd6ca55a0";
			} else if (packageid.equals("dx.200M")) {
				packagecode = "d8c0437943934b52bf00be38ae17a770";
			} else if (packageid.equals("dx.500M")) {
				packagecode = "10409805d24e445abd70aa24bb50db5e";
			} else if (packageid.equals("dx.1G")) {
				packagecode = "43511a73ad0f4fe6a696b742689d2e86";
			}
		} else if (routeid.equals("3059")) {
			//山东电信
			if (packageid.equals("dx.5M")) {
				packagecode = "627aa33ef19348ea9b751ca7ac6ca4d0";
			} else if (packageid.equals("dx.10M")) {
				packagecode = "9dbe7ff69afb411cb942b328c0b29213";
			} else if (packageid.equals("dx.30M")) {
				packagecode = "8231c4dc6a3445d5b20b0b0b1440953f";
			} else if (packageid.equals("dx.50M")) {
				packagecode = "56cb36d8516949108a2b6ac20ab73cd0";
			} else if (packageid.equals("dx.100M")) {
				packagecode = "a6125688554c4c40990568242a39b511";
			} else if (packageid.equals("dx.200M")) {
				packagecode = "83031cd9d474429791c815a541260b7d";
			} else if (packageid.equals("dx.500M")) {
				packagecode = "7bc385de4f41470b8b3ea17e668fdc1e";
			} else if (packageid.equals("dx.1G")) {
				packagecode = "074360dc58444456bf44ddc54614e30d";
			}
		} else if (routeid.equals("3058")) {
			//河南电信
			if (packageid.equals("dx.5M")) {
				packagecode = "f71aa8110e2143018c0ef38d73125135";
			} else if (packageid.equals("dx.10M")) {
				packagecode = "4b7d212a568645398664532de722ff21";
			} else if (packageid.equals("dx.30M")) {
				packagecode = "f7af3fee646c47fab030e44e2ba9823c";
			} else if (packageid.equals("dx.50M")) {
				packagecode = "7184f2c1086b44f3bb2ad9f0ed63f6a1";
			} else if (packageid.equals("dx.100M")) {
				packagecode = "44979f7075734513839f66a18d4f54fc";
			} else if (packageid.equals("dx.200M")) {
				packagecode = "863c9be727d44b319e43bf79c544d213";
			} else if (packageid.equals("dx.500M")) {
				packagecode = "8694ed775c6149fba3025cc8f417b560";
			} else if (packageid.equals("dx.1G")) {
				packagecode = "036e63a4a7984f65a8c8c5c30ee35de4";
			}
		} else if (routeid.equals("3057")) {
			//安徽电信
			if (packageid.equals("dx.5M")) {
				packagecode = "393bb65282c44b55b47bbb9b660896e2";
			} else if (packageid.equals("dx.10M")) {
				packagecode = "84d7a002513e4fb6a2c526441c8104c0";
			} else if (packageid.equals("dx.30M")) {
				packagecode = "c787fa74814f461eb131f2cebd546fcc";
			} else if (packageid.equals("dx.50M")) {
				packagecode = "f1608451dd6248caa94501561cca1faa";
			} else if (packageid.equals("dx.100M")) {
				packagecode = "2af0afdfb7bf45168f060d4ca4f45952";
			} else if (packageid.equals("dx.200M")) {
				packagecode = "92f06fefc35b4a77954473b9e3248d4f";
			} else if (packageid.equals("dx.500M")) {
				packagecode = "a8ca85ab1ee440e08cea5b9ebec7d1eb";
			} else if (packageid.equals("dx.1G")) {
				packagecode = "4f6b5625251646628e42a52a2486cf58";
			}
		} else if (routeid.equals("3055")) {
			//浙江电信
			if (packageid.equals("dx.5M")) {
				packagecode = "0e373e4501914cd9b0c6a79ebe8a8ce5";
			} else if (packageid.equals("dx.10M")) {
				packagecode = "925169bfa9b0429ab41da01534f266a9";
			} else if (packageid.equals("dx.30M")) {
				packagecode = "431a13a34a0f49b8b3f40fb20c0e2dbc";
			} else if (packageid.equals("dx.50M")) {
				packagecode = "7d8b05eeabbb44cc9110cf3f1a2605fe";
			} else if (packageid.equals("dx.100M")) {
				packagecode = "e1d23adace3f4bcfa92b8f5b86f8bc7b";
			} else if (packageid.equals("dx.200M")) {
				packagecode = "a263ebaa1845469eafc46add65aeab10";
			} else if (packageid.equals("dx.500M")) {
				packagecode = "639c9d2d58344da985fa3620a89b406a";
			} else if (packageid.equals("dx.1G")) {
				packagecode = "be3c71c533fe47bab30485b5f75153c9";
			}
		} else if (routeid.equals("3054")) {
			//江苏电信
			if (packageid.equals("dx.5M")) {
				packagecode = "879ffeda9c454d228f2cc1b4c77f7d7a";
			} else if (packageid.equals("dx.10M")) {
				packagecode = "950335cd5acb4050abbab78a6cf8bd0d";
			} else if (packageid.equals("dx.30M")) {
				packagecode = "1bde44283ab34fa8883b69116cdbbc86";
			} else if (packageid.equals("dx.100M")) {
				packagecode = "ac3628faf99545e2b3721817649bcbd8";
			} else if (packageid.equals("dx.200M")) {
				packagecode = "245cf98aabe44a89ad047622cd06c521";
			} else if (packageid.equals("dx.50M")) {
				packagecode = "5961afe7913d4504882b73f6786c7ed3";
			} else if (packageid.equals("dx.500M")) {
				packagecode = "64f2064c0d1b4b95aa6edb3d9a78abe7";
			} else if (packageid.equals("dx.1G")) {
				packagecode = "7ab2f7950ffb40c68b02894d32702ecd";
			}
		} else if (routeid.equals("3050")) {
			//广东电信
			if (packageid.equals("dx.5M")) {
				packagecode = "30ef463570a84902a57a47012a05203c";
			} else if (packageid.equals("dx.10M")) {
				packagecode = "8eaed4a104994f1c9e0d93ca39a3c7e9";
			} else if (packageid.equals("dx.30M")) {
				packagecode = "2f5b6000b34442c5acc0b15f9dd50695";
			} else if (packageid.equals("dx.50M")) {
				packagecode = "1fb55adcd89647f480c06197e4309ca9";
			} else if (packageid.equals("dx.100M")) {
				packagecode = "1852394753424c888006948751fb9168";
			} else if (packageid.equals("dx.200M")) {
				packagecode = "6c96d85225154ee7b6f9cf4d0cc3670b";
			} else if (packageid.equals("dx.500M")) {
				packagecode = "1bb06ede23a24f6d99fbfb2016139039";
			} else if (packageid.equals("dx.1G")) {
				packagecode = "99b6a8a26b24405880d8b5a1daa4c4cf";
			}
		} else if (routeid.equals("1229")) {
			//全国移动
			if (packageid.equals("yd.10M")) {
				packagecode = "2b3877fc1ae44c2ea98ac52835e3b336";
			} else if (packageid.equals("yd.30M")) {
				packagecode = "15c06767be50475bae661b58c52c0792";
			} else if (packageid.equals("yd.70M")) {
				packagecode = "e77086a9afcb4cc0b2d2b6aca3d4513d";
			} else if (packageid.equals("yd.150M")) {
				packagecode = "ca692f2cb9764a05b5dff60498b9380f";
			} else if (packageid.equals("yd.500M")) {
				packagecode = "2b6083e374c5472aaeb3245f8e5dea12";
			} else if (packageid.equals("yd.1G")) {
				packagecode = "195f1b2d940b47e2ba7ad01449b38e72";
			} else if (packageid.equals("yd.2G")) {
				packagecode = "431b65c63fa040ba8ef89d678cabd6ba";
			} else if (packageid.equals("yd.3G")) {
				packagecode = "20044754524340fba457ca4551c617a3";
			} else if (packageid.equals("yd.4G")) {
				packagecode = "25db649675e44acc9d6fe4f7368099e8";
			} else if (packageid.equals("yd.6G")) {
				packagecode = "0f382e6abcdd4a679532b526699e89bf";
			} else if (packageid.equals("yd.11G")) {
				packagecode = "f56cc0ed2fc94855bb167e92fd77c9bd";
			}
		} else if (routeid.equals("1211")) {
			//山东移动
			if (packageid.equals("yd.10M")) {
				packagecode = "8bd0c645e55e43ea9f1034e5c043887d";
			} else if (packageid.equals("yd.30M")) {
				packagecode = "3cdacd0656c6461ebc6af92547a6fe45";
			} else if (packageid.equals("yd.70M")) {
				packagecode = "94447a36480d4877a26a236befe6c3b2";
			} else if (packageid.equals("yd.150M")) {
				packagecode = "8d96ae69b6f2422687e90e06ff89606d";
			} else if (packageid.equals("yd.500M")) {
				packagecode = "59f50f543c214d4b91c2ca6ba1a9106b";
			} else if (packageid.equals("yd.1G")) {
				packagecode = "21470b8910f24cfd8e891c614de695b9";
			} else if (packageid.equals("yd.2G")) {
				packagecode = "bcf4fcb7f1b640839945245159d2f8db";
			} else if (packageid.equals("yd.3G")) {
				packagecode = "66dbab7edecc47b39c0e7a1e5dc08742";
			} else if (packageid.equals("yd.4G")) {
				packagecode = "ae1681275fc948868ee9f3ab0f45fc5f";
			} else if (packageid.equals("yd.6G")) {
				packagecode = "a0353bf49a764d6e9bcac78aa17c4044";
			} else if (packageid.equals("yd.11G")) {
				packagecode = "8048c5add67d43fa9a2f3ea8c0869f11";
			}
		} else if (routeid.equals("1240")) {
			//河南移动
			if (packageid.equals("yd.10M")) {
				packagecode = "407556bffd0943b586f7994a8b94ad82";
			} else if (packageid.equals("yd.30M")) {
				packagecode = "64695ddc30fa4789adb2f69878e87e3f";
			} else if (packageid.equals("yd.70M")) {
				packagecode = "8a9e70389a524353a6d6db4d9b3db9ce";
			} else if (packageid.equals("yd.100M")) {
				packagecode = "4ff8479fdca54250b0be5bf809ef5770";
			} else if (packageid.equals("yd.150M")) {
				packagecode = "1dbf774a522648109333833603180679";
			} else if (packageid.equals("yd.300M")) {
				packagecode = "768ae969fb8048abb57b9c38ec07cf2c";
			} else if (packageid.equals("yd.500M")) {
				packagecode = "a1aa49ba242a42a28b10e77fada4a189";
			} else if (packageid.equals("yd.1G")) {
				packagecode = "7857c1d870694da18f40dc08dd105131";
			} else if (packageid.equals("yd.2G")) {
				packagecode = "63d76011b2534f3c9339e691b8535509";
			} else if (packageid.equals("yd.3G")) {
				packagecode = "bc4c0de1552845e196022462c247c31f";
			} else if (packageid.equals("yd.4G")) {
				packagecode = "280be3ac01f343af8e44693e34cb02f2";
			} else if (packageid.equals("yd.6G")) {
				packagecode = "822370e7c15e4a9697fe987ea22659e1";
			} else if (packageid.equals("yd.11G")) {
				packagecode = "85a790ffbce34256bfbe111f6afd10c4";
			}
		} else if (routeid.equals("1100")) {
			//广东移动
			if (packageid.equals("yd.10M")) {
				packagecode = "e7c45e3e47df4c119a63df4e87e7d02c";
			} else if (packageid.equals("yd.30M")) {
				packagecode = "350c0629c3b44a099689fa6a01a59591";
			} else if (packageid.equals("yd.70M")) {
				packagecode = "b02c9b5a70ca4909bd11fa4d6d22f163";
			} else if (packageid.equals("yd.150M")) {
				packagecode = "e03cb75be8e64b288e23fb20db0970ed";
			} else if (packageid.equals("yd.500M")) {
				packagecode = "d7bce7a940eb4b2a9d4bd8028c9bd712";
			} else if (packageid.equals("yd.1G")) {
				packagecode = "598e9e3bbbc94f87ac7a54efdafc98c6";
			} else if (packageid.equals("yd.2G")) {
				packagecode = "97376820b3604e6f8fd1cd08ea6499c2";
			} else if (packageid.equals("yd.3G")) {
				packagecode = "8cece47a837744d89b391199e02620b6";
			} else if (packageid.equals("yd.4G")) {
				packagecode = "f58780b3d68c4faeb9ba3d262cd668a4";
			} else if (packageid.equals("yd.6G")) {
				packagecode = "eb14ada7a7594089824f678d2af3f42b";
			} else if (packageid.equals("yd.11G")) {
				packagecode = "e9b3fc3332aa494a9b31740d8a26c6c5";
			}
		}

		if (packagecode == null) {
			request.setAttribute("result", "S." + routeid + ":unrecognized package@" + TimeUtils.getSysLogTimeString());
			break;
		}

		String timestamp = TimeUtils.getTimeStamp();
		String nonce = MyBase64.base64Encode(account + "," + timestamp);
		String signature = sign(key, timestamp, account);

		//HashMap<String, String> param = new HashMap<String, String>();
		//param.put("mobile", phone);
		//param.put("flowValue", packagecode);
		//param.put("productType", productType);
		//param.put("nonce", nonce);
		//param.put("signature", signature);
		//param.put("otherParam", taskid);//附加参数
		//param.put("json", json.toString());
		//System.out.println("json = " + json.toString());

		url = url + "recharge?" + "mobile=" + phone + "&productCode=" + packagecode + "&productType=" + productType + "&nonce=" + nonce + "&signature=" + signature + "&otherParam=" + taskid;
		logger.info("gzyunsheng url = " + url);
		//在执行请求前先获取连接, 防止访问通道线程超量
		Cache.getConnection(routeid);
		try {
			//ret = HttpAccess.postNameValuePairRequest(url, params, "utf-8", "mysend");
			//ret = HttpAccess.postJsonRequest(url, json.toString(), "utf-8", "weikesend");
			ret = HttpAccess.getNameValuePairRequest(url, new HashMap<String, String>(), "utf-8", "gzyunshengsend");
		} catch (Exception e) {
			e.printStackTrace();
			logger.info(e.getMessage());
		} finally {
			//在执行请求后记得释放连接
			Cache.releaseConnection(routeid);
		}

		//这里判断结果, 每个通道情况不同, 成功的保存 success 到 result 中并返回到 request.jsp(ret为返回的结果)
		if (ret != null && ret.trim().length() > 0) {
			logger.info("gzyunsheng send ret = " + ret);
			HashMap<String, String> errmap = new HashMap<String, String>();
			errmap.put("00001", "下单/订购失败");
			errmap.put("00002", "任务处理中");
			errmap.put("10001", "黑名单号码");
			errmap.put("10002", "空号/号码不存在");
			errmap.put("10003", "号码归属地错误");
			errmap.put("10004", "欠费/停机");
			errmap.put("10005", "号码已冻结或注销");
			errmap.put("10006", "业务互斥");
			errmap.put("10007", "业务受限");
			errmap.put("10008", "没有合适的产品");
			errmap.put("10009", "没有合适的通道");
			errmap.put("10010", "通道被停用");
			errmap.put("10011", "通道余额不足");
			errmap.put("10012", "号码充值过于频繁");
			errmap.put("20000", "签名认证失败");
			errmap.put("20001", "请求已过期");
			errmap.put("20002", "参数格式错误");
			errmap.put("20003", "附加参数超长");
			errmap.put("20004", "运营商错误");
			errmap.put("20005", "产品类型错误");
			errmap.put("20006", "客户不存在");
			errmap.put("20007", "客户被停用");
			errmap.put("20008", "客户IP非法");
			errmap.put("20009", "客户余额不足");
			errmap.put("20010", "产品不存在");
			errmap.put("20011", "环行任务");
			errmap.put("20012", "任务不存在，请稍候再试");
			errmap.put("99998", "未知错误");
			errmap.put("99999", "系统内部错误");

			try {
				JSONObject retjson = JSONObject.fromObject(ret);
				String retCode = retjson.getString("status"); //":"00000" 下单/订购成功
				String orderNo = retjson.getString("orderNo");

				if (retCode.equals("00000")) {
					request.setAttribute("result", "success");
					request.setAttribute("reportid", orderNo);
				} else {
					request.setAttribute("code", 1);
					String message = errmap.get(retCode);
					if (message == null) {
						message = "未知错误";
					}
					request.setAttribute("result", "R." + routeid + ":" + retCode + ":" + message + "@" + TimeUtils.getSysLogTimeString());
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

	request.getRequestDispatcher("request.jsp").forward(request, response);
%>