package test;

import com.gargoylesoftware.htmlunit.BrowserVersion;
import com.gargoylesoftware.htmlunit.WebClient;
import com.gargoylesoftware.htmlunit.html.HtmlAnchor;
import com.gargoylesoftware.htmlunit.html.HtmlElement;
import com.gargoylesoftware.htmlunit.html.HtmlPage;


public class BaiQian {
	public static void main(String[] args) {
		/*
		//String url = "http://112.74.139.4:8002/sms3_api/xmlapi/send.jsp";
		String url = "http://192.168.1.14:8121/sms3_api/xmlapi/send.jsp";
		String xml = "<root userid=\"200400\" password=\"b8d27169b177376ef2f8d278a7bbf4fb\"><submit phone=\"18680453390\" content=\"测速内容【单元科技】\" /></root>";
		String ret = HttpAccess.postXmlRequest(url, xml, "utf-8", "send");
		System.out.println("ret = " + ret);
		*/
		test21cnIII();
	}
	
	private static void test21cnIII() {
		WebClient webClient = new WebClient(BrowserVersion.CHROME);
		webClient.getOptions().setJavaScriptEnabled(true);
		webClient.getOptions().setCssEnabled(false);
		webClient.getOptions().setThrowExceptionOnScriptError(false);
		webClient.getOptions().setPrintContentOnFailingStatusCode(false);
        HtmlPage page = null;
        HtmlPage pageResponse = null;

        try {
        	page = webClient.getPage("http://nb.189.cn/ticketRecharge/jumpTicketInfoWap.do?appId=flow&clientType=9&format=json&version=v1.1&paras=8EF36DE3C3A25D3F32D0CCFD488AB2D952FB6E12C544FC25572C8374CF276EB816BB2B1FED6E5258A7303132C77F9FBE668B913021B53D9EEBDFA9B58D514C66F7B49C89A3FBE774D45BE8BD6AAA5921&sign=C9F51B977B06A28BB60AA6FB4BCB695576ED3D16");
		} catch (Exception e) {
			//
		}
        
        HtmlAnchor link = null;
        try{
        	link = page.getAnchorByText("兑换");
		}catch(Exception e){
			System.out.println("兑换 ret = " + e.getMessage());
		}
        if(link != null){
        	return;
        }
        try{
        	link = page.getAnchorByText("立即兑换");
		}catch(Exception e){
			System.out.println("立即兑换 ret = " + e.getMessage());
		}
        if(link != null){
        	System.out.println("last = " + link.asText());
        }
        /*
        if(page == null){
        	return;
        }
        
        HtmlElement ele = page.getHtmlElementById("j-load");
        System.out.println("good = " + ele.getAttribute("style"));
       
        String pagestr = page.getBody().asText();
        
        if(pagestr.indexOf("流量兑换处理中") > -1){
        	System.out.println("info = " + "流量兑换处理中");
        }if(pagestr.indexOf("流量兑换成功") > -1){
        	System.out.println("info = " + "流量兑换成功");
        }else{
	        HtmlAnchor link = null;
	        try {
	        	link = page.getAnchorByText("兑换");
			} catch (Exception e) {
				// TODO: handle exception
			}
	        		
	        if(link != null){
	        	try {
	        		pageResponse = link.click();
	        		System.out.println("page = " + pageResponse.toString());
				} catch (Exception e) {
					// TODO: handle exception
				}
	        }
        }
        */
        
        webClient.close();
        
    }
}
