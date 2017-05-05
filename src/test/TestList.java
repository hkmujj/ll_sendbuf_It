package test;

import java.util.ArrayList;

import net.sf.json.JSONObject;


public class TestList extends ArrayList<TestOrder> {

	private static final long serialVersionUID = 1844084462519154296L;

	public boolean add(TestOrder b){
		return super.add(b);
	}
	
	public void removeUnits(int b){
		b = b > this.size() ? this.size() : b;
		super.removeRange(0, b);
	}

	public static void main(String[] args) {
		JSONObject obj = JSONObject.fromObject("{\"exec_result\": \"0\", \"channel_no\": \"0441001\", \"province_no\": \"44\", \"sp_type\": \"0\", \"request_id\": \"\", \"guid\": \"5bc84f1b-e41f-4901-9a85-13ff2445f3c9\", \"result_desc\": \"\", \"msg_id\": \"20160902141118665877\", \"city_no\": \"441800\", \"result_code\": \"\u6210\u529f\"}");
		System.out.println(obj.getString("result_code"));
	}
}
