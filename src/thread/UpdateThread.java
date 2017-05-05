package thread;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import database.LLMainDatabase;

public class UpdateThread extends Thread{
	
	private static Logger logger = LogManager.getLogger(UpdateThread.class.getName());
	
	public UpdateThread(){
		this.setName("LL_SendBufUpdateThread");
		this.start();
	}
	
	@Override
	public void run(){
		while(true){
			logger.info("ll_sendbuf update thread work");
			LLMainDatabase.updateRoutes();
			
			mysleep(60 * 1000);
		}
	}

	private void mysleep(long t){
		try {
			Thread.sleep(t);
		} catch (InterruptedException e) {
			e.printStackTrace();
		}
	}
	
}
