package cache;

import java.util.HashMap;
import java.util.Iterator;
import java.util.LinkedHashMap;
import java.util.Map.Entry;

public class Route {	

	public int id = 0;
	
	public int mt_maxthread = 1;
	
	public int rp_maxspeed = 1;
	public int rp_maxthread = 1;
	
	public int mt_maxdaycount = 1;

	public String api_type = null;
	
	public HashMap<String, String> api_params = null;
	
	//public HashMap<String, String> api_packagecode = null;
	
	private long datetime = 0;
	private HashMap<Long, Integer> count = new HashMap<Long, Integer>();
	
	public String api_mturl = null;
	public String api_rpurl = null;

	//0不监控,1监控
	public int monitor = 0;
	
	//0正常,1.停用，2暂停
	public int status = 0;
	
	private int conncnt = 0;
	private HashMap<String, Long> connectcount = new LinkedHashMap<String, Long>();
	private byte[] connectlock = new byte[0];
	public boolean addConnection() {
		synchronized (connectlock) {
			if(connectcount.size() + 1 <= mt_maxthread){
				conncnt++;
				connectcount.put(String.valueOf(conncnt), System.currentTimeMillis());
				return true;
			}else{
				Entry<String, Long> entry = null;
				Iterator<Entry<String, Long>> iterator = connectcount.entrySet().iterator();
				long t = System.currentTimeMillis() - 10L * 60 * 1000;
				while (iterator.hasNext()) {
					entry = iterator.next();
					if(entry.getValue() < t){
						iterator.remove();
					}else{
						break;
					}
				}
				if(connectcount.size() + 1 <= mt_maxthread){
					conncnt++;
					connectcount.put(String.valueOf(conncnt), System.currentTimeMillis());
					return true;
				}
			}
		}
		return false;
	}

	public void releaseConnection(){
		synchronized (connectlock) {
			Iterator<Entry<String, Long>> iterator = connectcount.entrySet().iterator();
			if (iterator.hasNext()) {
				iterator.next();
				iterator.remove();
			}
		}
	}
	
	private byte[] checklock = new byte[0];
	public boolean checkNumber(Long num){
		synchronized (checklock) {
			long t = System.currentTimeMillis();
			long itv = 24 * 60 * 60 * 1000;
			t = t / itv * itv;
			
			if(t != datetime){
				datetime = t;
				count = new HashMap<Long, Integer>();
			}
			/*
			if(count.get(num) == null){
				count.put(num, 1);
			}else if(count.get(num) < mt_maxdaycount){
				count.put(num, count.get(num) + 1);
			}else{
				return false;
			}
			*/
			if(count.get(num) == null || count.get(num) < mt_maxdaycount){
				return true;
			}
		}	
		return false;
	}
	
	public void addNumberCount(Long num){
		synchronized (checklock) {
			long t = System.currentTimeMillis();
			long itv = 24 * 60 * 60 * 1000;
			t = t / itv * itv;
			
			if(t != datetime){
				datetime = t;
				count = new HashMap<Long, Integer>();
			}
			
			if(count.get(num) == null){
				count.put(num, 1);
			}else{
				count.put(num, count.get(num) + 1);
			}
		}
	}

	private int statusconnectcount = 0;
	private byte[] statusconnectlock = new byte[0];
	public boolean addStatusConnection() {
		synchronized (statusconnectlock) {
			if(statusconnectcount + 1 <= rp_maxthread){
				statusconnectcount++;
				return true;
			}
		}
		return false;
	}
	
	public void releaseStatusConnection(){
		synchronized (statusconnectlock) {
			if(statusconnectcount > 0){
				statusconnectcount--;
			}
		}
	}
}
