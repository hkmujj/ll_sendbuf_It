package test;

import java.util.ArrayList;
import java.util.HashMap;

import javax.sound.midi.MidiDevice.Info;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import database.LLMainDatabase;

public class TestCache {
	
	private static Logger logger = LogManager.getLogger(LLMainDatabase.class.getName());
	
	private static byte[] listlock = new byte[0];
	private static HashMap<String,TestList> idlists = new HashMap<String,TestList>();
	public static void saveid(String routeid, String id){
		TestList list = null;
		synchronized (listlock) {
			list = idlists.get(routeid);
			if(list == null){
				list = new TestList();
				idlists.put(routeid, list);
			}
		}
		synchronized (list) {
			list.add(new TestOrder(id, System.currentTimeMillis() + 0 * 1000));
		}
	}
	
	public static ArrayList<TestOrder> getids(String routeid){
		ArrayList<TestOrder> ret = new ArrayList<TestOrder>();
		TestList list = idlists.get(routeid);
		if(list == null){
			return ret;
		}
		long t = System.currentTimeMillis();
		synchronized (list) {
			int i = 0;
			for(; i < 300 && i < list.size(); i++){
				if(list.get(i).validtime > t){
					break;
				}
				ret.add(list.get(i));
			}
			list.removeUnits(i);
		}
		return ret;
	}
	
	public static ArrayList<TestOrder> getids(String routeid, String ids){
		ArrayList<TestOrder> ret = new ArrayList<TestOrder>();
		TestList list = idlists.get(routeid);
		if(list == null){
			return ret;
		}
		long t = System.currentTimeMillis();
		String[] idarray = ids.split(",");
		Object obj = new Object();
		HashMap<String, Object> map = new HashMap<String, Object>();
		for(int i = 0; i < idarray.length; i++){
			logger.info("mapid = " + idarray[i]);
			map.put(idarray[i], obj);
		}
		
		synchronized (list) {
			for(int i = list.size() - 1; i >= 0; i--){
				logger.info("taskid = " + list.get(i).id);
				if(map.get(list.get(i).id) != null){
					ret.add(list.get(i));
					list.remove(i);
				}
			}
		}
		
		logger.info("query status : map size = " + map.size() + ", ret size = " + ret.size());
		
		return ret;
	}
}
