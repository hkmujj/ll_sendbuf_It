package _21cn;

import http.HttpAccess;

import java.net.URLEncoder;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;

import util.TimeUtils;

import com.gargoylesoftware.htmlunit.BrowserVersion;
import com.gargoylesoftware.htmlunit.ScriptResult;
import com.gargoylesoftware.htmlunit.WebClient;
import com.gargoylesoftware.htmlunit.html.HtmlAnchor;
import com.gargoylesoftware.htmlunit.html.HtmlElement;
import com.gargoylesoftware.htmlunit.html.HtmlPage;

public class Testmain {
	public static void main(String[] args) {
		
		String c_bossmobile = "18925024504";
		//String c_bossmobile = "18998299214";
		
		int c_coin = 5;
		
		String packagecode2 = "5M";
		
		String phone = "18998299214";
		
		//String phone = "15017556283";
		
		String appId="8013818507";
		String clientType="2";
		String appSecret ="yLmrAVi8kny8VFTI3NpeUpcHthODinNU";
		String signSecret="yLmrAViHtrkuAFvPPO754MHHcHthO";
		String url="http://nb.189.cn/portal/open/enterCoinExchange.do";
		
		if(c_coin == 5){
			c_coin = 10;
		}else if(c_coin == 10){
			c_coin = 19;
		}
		
		WebClient webClient = null;
		
		try {
			
			Map<String, String> map = new HashMap<String, String>();
			map.put("appId", appId);
			map.put("clientType", clientType);
			String format = "html";
			String version = "v1.0";
			map.put("format", format);
			map.put("version", version);
			
			String params="mobile=" + c_bossmobile;
			
			String ciperParas = XXTea.encrypt(params, "UTF-8", ByteFormat.toHex(appSecret.getBytes()));
			String signPlainText = appId + clientType + format + version + ciperParas;
			byte[] data = StringUtil.hex2Bytes(ByteFormat.toHex(signPlainText.getBytes()));
			byte[] key = StringUtil.hex2Bytes(ByteFormat.toHex(signSecret.getBytes()));
			String signature = MACTool.encodeHmacMD5(data, key);

			map.put("paras", ciperParas);
			map.put("sign", signature);
			
			String paramstr = "";
			for(Entry<String, String> entry : map.entrySet()){
				if(paramstr.length() > 0){
					paramstr = paramstr + "&";
				}
				paramstr = paramstr + entry.getKey() + "=" + URLEncoder.encode(entry.getValue(), "utf-8");
			}
			
			url=url + "?" + paramstr;
			
			System.out.println("url = " + url);
			
			webClient = new WebClient(BrowserVersion.CHROME);
			webClient.getOptions().setJavaScriptEnabled(true);
			webClient.getOptions().setCssEnabled(false);
			webClient.getOptions().setThrowExceptionOnScriptError(false);
	        HtmlPage _21cnpage = null;
	        
	        HtmlPage pageResponse = null;
        
        	_21cnpage = webClient.getPage(url);
        	int money = Integer.parseInt(_21cnpage.getHtmlElementById("mycoin").asText());
        	if(money >= c_coin){
					//System.out.println("success");
			}else{
				//充值提交失败，没有足够余额
				System.out.println("R.账号余额不足,剩余" + money + ",需要" + c_coin + "@" + TimeUtils.getSysLogTimeString());
				return;
			}
			
			_21cnpage.getHtmlElementById("j-phone").setAttribute("value", phone);
			
			_21cnpage.executeJavaScript("$('#j-phone').trigger('keyup')");
			
			System.out.println(_21cnpage.getHtmlElementById("j-phone").asText());
			
			System.out.println(_21cnpage.getHtmlElementById("j-notice").asText());
			
			_21cnpage.getHtmlElementById("j-notice").click();
			
			Thread.sleep(100);
        	
			List dnl = _21cnpage.getByXPath("//*[@id=\"j-liuliang\"]/li");
			for(int i = 0; i < dnl.size(); i++){
				HtmlElement link = (HtmlElement)dnl.get(i);
				if(link.asText().equals(packagecode2)){
					link.click();
				}
				System.out.println(link.asText());
			}
			
			Thread.sleep(100);
			
			String price = _21cnpage.getHtmlElementById("price").asText();
			price = price.substring(0, price.length() - 1);
			if(Integer.parseInt(price) != c_coin){
				System.out.println("price = " + price + ", c_coin = " + c_coin);
				return;
			}
			
			String duihan = _21cnpage.getHtmlElementById("duihuan-btn").getAttribute("class");
			System.out.println("21cncoinsend.jsp btn class = " + duihan);
			if(duihan != null && duihan.equals("disabled")){
				return;
			}
			
			//ScriptResult sr = _21cnpage.executeJavaScript("exchangeCoinToFlow()");
			StringBuffer sb = new StringBuffer();
			sb.append("$.post('/portal/open/exchangeCoinToFlow.do' + search + '&typeId='+typeId + '&toMobile=' + toMobile, function(data){");
			sb.append("    var mydiv = document.createElement('div');");
			sb.append("    mydiv.setAttribute('id', 'cubeluzr');");
			sb.append("    if (data.result === 0) {");
			sb.append("        if (data.state === 1) {");
			sb.append("            mydiv.innerHTML = data.orderId;");
			sb.append("        }");
			sb.append("    }else {");
			sb.append("        mydiv.innerHTML = 'fail';");
			sb.append("    }");
			sb.append("    document.body.appendChild(mydiv);");
			sb.append("},'json');");
			
			_21cnpage.executeJavaScript(sb.toString());
			 
			Thread.sleep(500);
			
			//System.out.println("str = " + sr.toString());
			String tag = null;
			
			for(int i = 0; i < 20; i++){
				//HtmlPage srpage = (HtmlPage)sr.getNewPage();
			
				//System.out.println("get[" + i + "] url = " + srpage.getUrl());
				//System.out.println("get[" + i + "] page = " + _21cnpage.asText());
				try {
					tag = _21cnpage.getHtmlElementById("cubeluzr").asText();
					break;
				} catch (Exception e) {
					//System.out.println(e.getMessage() + ", no such tag");
					System.out.println(e.getMessage() + ", no such tag");
				}
				
				Thread.sleep(500);
			}
			
			System.out.println("tag = " + tag);
			
			//Thread.sleep(500);
		} catch (Exception e) {
			e.printStackTrace();
		}finally {
			if(webClient != null){
				try{
					webClient.close();
				}catch (Exception e) {
				}
			}
        }
	}
}
