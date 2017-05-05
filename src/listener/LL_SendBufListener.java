package listener;

import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;

import thread.LL_SendBufThread;
import thread.ProtectThread;

public class LL_SendBufListener implements ServletContextListener{

	@Override
	public void contextDestroyed(ServletContextEvent sce) {
		//
	}

	@Override
	public void contextInitialized(ServletContextEvent sce) {
		System.out.println("ll_sendbuf contextInitialized ~~~~~~~~~~~~~~~~~~~~~~~");
		
		LL_SendBufThread.protectThread = new ProtectThread();
		
		System.setProperty("sun.net.client.defaultConnectTimeout", "3000");
		
		System.setProperty("sun.net.client.defaultReadTimeout", "180000");
		
		System.out.println("ll_sendbuf contextInitialized over ~~~~~~~~~~~~~~~~~~");
	}
}
