package test;

public class TestThread {
	
	public static void mysleep(long t){
		try {
			Thread.sleep(t);
		} catch (InterruptedException e) {
			e.printStackTrace();
		}
	}
	
}
