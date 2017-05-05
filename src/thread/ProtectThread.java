package thread;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

public class ProtectThread extends Thread{
	
	private static Logger logger = LogManager.getLogger(ProtectThread.class.getName());
	
	public ProtectThread(){
		this.setName("LL_SendBufProtectThread");
		this.start();
	}
	
	@Override
	public void run(){
		while(true){
			if(LL_SendBufThread.updateThread == null || !LL_SendBufThread.updateThread.isAlive()){
				LL_SendBufThread.updateThread = new UpdateThread();
				logger.warn("protect thread : updateThread restart");
			}
			
			mysleep(1000);
			logger.info("ll_sendbuf protect thread work");
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
