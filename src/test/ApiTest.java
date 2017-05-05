package test;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.io.UnsupportedEncodingException;
import java.net.URL;
import java.net.URLConnection;
import java.util.Date;

import com.alibaba.fastjson.JSONObject;

import util.Utility;



/*调用FlowOrder接口示例*/
public class ApiTest {

	public static void main(String[] args) throws Exception {

		//流量订购
		System.out.println("letian ret = " + FlowOrder());
/*
		//回调接口实现
		// 测试数据v，k，c，正常情况下v，k，c的值来源回调接口接收到的Post数据
		String v = "1.0.1.12345678";
        String k = "ig5IPNRxODljNmmUHVn4JKrxXwSZJqk1ihfsET3ftXFbYxxltBpkheLh76xMI5YP+sijeszbCqOH/pIvBsreL5M7Ilz2W07qxbgam3u9zAiSpL5lKrmT/F/oiKHvKO+AkEATL3vZtMNBpiQ1Dl++xhl0IKwLRZ8HpW2FsR5/rJ4Df17mwDbeCjM2S6+2QrKDt1sibfkHZzdRtbvu6cs+hO39PRyM1caOH0tT9hDZNvabCeiZZ3KoKVO6qJpyZw+jv8g5HaYRUE8/KDlNs3mHUShmKzMxj0SFzXPMdVSsCptsNTz1QkM3pUMGoFSHRHNbkMvg8ZWKfYmLO74077fG0g==";
        String c = "Wt2kIHVFnTikJ6T2HphRq24qfZVr+eNNI8bQeIQkx7uxl24ZhY/ybbBHB1colkoGZVN9WF7lRqzjR3t1KuTdmXDuagoH5pQmW+rksmKJTn6XIHnk4Jw7dhK3Op2Jbjsgjow7Uqaqt/6mokKTK6Ldu7KGzAESCgf8WpzxCMgZrM78O/Hd2wYlePvijRYhbS54KeA6Ys7FtOVNnNc3nhxz9tW082g6sE97RFJ8jIB4bnY4FZg/CnhfInRjhhQNd6EUEqNj1OTvppZybj26UyptZg==";

		System.out.println(CallBack(v, k, c));
		*/
	}

	// 需赋值生成的Rsa私钥
	
	public static String privateKey = "MIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQDXLRqRB44aSSfr"
			+ "4JkrYxM7ufLiEfK/Mz38bqHKieqfoT63MGqtAzyl/CaCXFl+aU0ptmBgHiUsX9kZ"
			+ "ks4FmjNoutRu6solR+Ax5cuZBACqWafUHM5lyIkzmDIvwxYArn5ybHF7Qk19RVJ4"
			+ "kLkmQq7ECs9ZVDb4mleTi05ivbldVLDVmcJWexxWot9ffd16E1eyntvnxvAOo77z"
			+ "FVC/7JLZmpfi7jWKziVJX3Sy/0CTMShKYaRe+C5DqWIETmPeQGNd5D/Q/wA5SSXG"
			+ "/v6KvXy7MJ5dN9PgHiB1sRPWZjyNVlvcbMacmTqaQ7gKUmLJGG2KUAg21cfwQr1K"
			+ "8U8fiTzfAgMBAAECggEBAMD8COmuFvroRc+9/mH1V9ina3jqlAZ71MpEBwN6Ml28"
			+ "5lyyJdrKHmjX/0nHvdQsaTJSCZnrL3fe9v2Ctxg7NoRlnAVmuqo5DpByAupXtqkS"
			+ "A/2vYEXVV4hYphpEI8W0ul+xdw4PZyRFOjQ7yHLSN6BH+bOqXisVcho4RLM2abuT"
			+ "hjt+9BL+uD8aKHfVsmpo9DiIxYj6goFXcfdKHrhpnzeaSEx3ekFeYEnE5gS4WV02"
			+ "2RldLwA8EecyAZqCZRv9VhF9mMyfsfjVlTmUR5PzSXHRGkSkHI9rthNrb+HOJdw2"
			+ "QKnvaflRTppoEg4lO5m9/jBtfEG0s8+lpbRvq/99ATECgYEA9BCVAOUNakyct9MG"
			+ "aV0lV40J1IhDloPbdKip2P8YtLsv2Cjhz7oKJ+zJ5f0W4+vbNSukiZ28McA81SNb"
			+ "WKTSMmex2KNk+9+UO8MfLs2tV8vMXeQ0ROd0Aig/HK3GlboJfNMRDApbvRXgL8oQ"
			+ "7kYXBU5mbrkfRnUvI6jsE8NAIK0CgYEA4bLecpo1b6NQXPjCAfnGoBHN748bvxe0"
			+ "ee0ycn1YEECkx8N0/j/yXf98wkejA+2NVwXMcUo0wYBVBOSgFZsaH6ZdSOYMqA7L"
			+ "1y1tOa+wNPDPH6JjZcWFx4MxTMngc8vaI2ORAQvzJzZdHn4xMXp0DK6rUtDM7eka"
			+ "s8PG+6deKTsCgYEAiUm+l1dBGZdo3JqO07v6omoKqovQAR3A17l8eTzdp+RXwG8W"
			+ "vqO2zMiMtZuNQb5Ne3ZGQscAsrehQH94BcAJISNlTihzSJ92obtbkhdON8HC/tm8"
			+ "cToE7qW3AqnZuCWC6r1LrIszGYTxq9Atf+rbTjfQtN3bcuW+E4AU8/Tz4K0CgYB1"
			+ "sI3qeJswsZpwQI759MMsKNyX9KnlRXkosxVBOjc3kl3ahQN2qOW7OkRWEoDgxXiU"
			+ "TkPDN4y28jJjMMyBN7Wxl1DBeKRU5hJJDDkOgZyCnqeCuWzXXt5ZoQGOJx7RgxUm"
			+ "qv6r6w1J/0Eja24/fLkS++n+bz7NOGZiIs6Z3zZsjQKBgAp9LjtCFQSK+NVVgOPT"
			+ "9DSSoPwuKo9djs+n+E1sfOazhORLytfSIQJrOt/gl/ilp4sKcCmvgHj6CuILqpY6"
			+ "Zi6vYvTBAehqXcitZrvjPGJKiRa49HY++Q5dRw5ujvVu0WThTTFfrZ8w009Ja3Ar"
			+ "p7bUwcPJTxOHNa1P6zN594Y2";
			
	/*
	public static String privateKey = "MIIEpAIBAAKCAQEA1y0akQeOGkkn6+CZK2MTO7ny4hHyvzM9/G6hyonqn6E+tzBq"
	+ "rQM8pfwmglxZfmlNKbZgYB4lLF/ZGZLOBZozaLrUburKJUfgMeXLmQQAqlmn1BzO"
	+ "ZciJM5gyL8MWAK5+cmxxe0JNfUVSeJC5JkKuxArPWVQ2+JpXk4tOYr25XVSw1ZnC"
	+ "VnscVqLfX33dehNXsp7b58bwDqO+8xVQv+yS2ZqX4u41is4lSV90sv9AkzEoSmGk"
	+ "XvguQ6liBE5j3kBjXeQ/0P8AOUklxv7+ir18uzCeXTfT4B4gdbET1mY8jVZb3GzG"
	+ "nJk6mkO4ClJiyRhtilAINtXH8EK9SvFPH4k83wIDAQABAoIBAQDA/Ajprhb66EXP"
	+ "vf5h9VfYp2t46pQGe9TKRAcDejJdvOZcsiXayh5o1/9Jx73ULGkyUgmZ6y933vb9"
	+ "grcYOzaEZZwFZrqqOQ6QcgLqV7apEgP9r2BF1VeIWKYaRCPFtLpfsXcOD2ckRTo0"
	+ "O8hy0jegR/mzql4rFXIaOESzNmm7k4Y7fvQS/rg/Gih31bJqaPQ4iMWI+oKBV3H3"
	+ "Sh64aZ83mkhMd3pBXmBJxOYEuFldNtkZXS8APBHnMgGagmUb/VYRfZjMn7H41ZU5"
	+ "lEeT80lx0RpEpByPa7YTa2/hziXcNkCp72n5UU6aaBIOJTuZvf4wbXxBtLPPpaW0"
	+ "b6v/fQExAoGBAPQQlQDlDWpMnLfTBmldJVeNCdSIQ5aD23Soqdj/GLS7L9go4c+6"
	+ "CifsyeX9FuPr2zUrpImdvDHAPNUjW1ik0jJnsdijZPvflDvDHy7NrVfLzF3kNETn"
	+ "dAIoPxytxpW6CXzTEQwKW70V4C/KEO5GFwVOZm65H0Z1LyOo7BPDQCCtAoGBAOGy"
	+ "3nKaNW+jUFz4wgH5xqARze+PG78XtHntMnJ9WBBApMfDdP4/8l3/fMJHowPtjVcF"
	+ "zHFKNMGAVQTkoBWbGh+mXUjmDKgOy9ctbTmvsDTwzx+iY2XFhceDMUzJ4HPL2iNj"
	+ "kQEL8yc2XR5+MTF6dAyuq1LQzO3pGrPDxvunXik7AoGBAIlJvpdXQRmXaNyajtO7"
	+ "+qJqCqqL0AEdwNe5fHk83afkV8BvFr6jtszIjLWbjUG+TXt2RkLHALK3oUB/eAXA"
	+ "CSEjZU4oc0ifdqG7W5IXTjfBwv7ZvHE6BO6ltwKp2bglguq9S6yLMxmE8avQLX/q"
	+ "20430LTd23LlvhOAFPP08+CtAoGAdbCN6nibMLGacECO+fTDLCjcl/Sp5UV5KLMV"
	+ "QTo3N5Jd2oUDdqjluzpEVhKA4MV4lE5DwzeMtvIyYzDMgTe1sZdQwXikVOYSSQw5"
	+ "DoGcgp6ngrls117eWaEBjice0YMVJqr+q+sNSf9BI2tuP3y5Evvp/m8+zThmYiLO"
	+ "md82bI0CgYAKfS47QhUEivjVVYDj0/Q0kqD8LiqPXY7Pp/hNbHzms4TkS8rX0iEC"
	+ "azrf4Jf4paeLCnApr4B4+griC6qWOmYur2L0wQHoal3IrWa74zxiSokWuPR2PvkO"
	+ "XUcObo71btFk4U0xX62fMNNPSWtwK6e21MHDyU8ThzWtT+szefeGNg==";
	*/

	// FlowOrder
	public static String FlowOrder() throws Exception {
		// 需赋值提供的流量订购版本号
		String version = "1.0.301.2016090210413237000081";
		// 需赋值提供的流量订购UId
		String Uid = "2016090210420952600083";
		// 构造流量订购信息（手机号码，AreaCode，SetCode），F为自定义流水号，根据实际情况做定义
		JSONObject obj  = new JSONObject();
		obj.put("T", (new Date()).getTime());
		obj.put("UId", Uid);
		obj.put("F", "123456555");
		
		JSONObject task = new JSONObject();
		task.put("Phone", "15017556283");
		task.put("SetCode", "Junbo2");
		task.put("AreaCode", "0000");
		
		obj.put("RC", task);
		
		String Cno = obj.toString();
		
		System.out.println("cno = " + Cno);
		
		// 流量订购接口
		String url = "http://api.liulianglf.com/FlowOrder.aspx";

		String versionC = version + Cno;
		PrintWriter out = null;
		BufferedReader in = null;
		String result = "";
		byte[] aesKey = Utility.sha256(versionC);

		System.out.println("aesKey.len = " + aesKey.length);
		
		// AES 向量
		byte[] iv = new byte[16];
		if (aesKey != null) {
			for (int i = 0; i < 16; i++) {
				iv[i] = aesKey[i];
			}
		}

		String K = Utility.base64(Utility.encrypt(Utility.loadPrivateKey(privateKey), aesKey));
		K = java.net.URLEncoder.encode(K, "utf-8");
		byte[] data = Utility.aseEncrypt(Cno, aesKey, iv);
		
		System.out.println("data.len = " + data.length);
		
		String C = Utility.base64(data);
		C = java.net.URLEncoder.encode(C, "utf-8");
		String param = "V=" + version + "&K=" + K + "&C=" + C;
		try {
			URL realUrl = new URL(url);
			// 打开和URL之间的连接
			URLConnection conn = realUrl.openConnection();
			// 设置通用的请求属性
			conn.setRequestProperty("accept", "*/*");
			conn.setRequestProperty("connection", "Keep-Alive");
			conn.setRequestProperty("user-agent", "Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1;SV1)");
			// 发送POST请求必须设置如下两行
			conn.setDoOutput(true);
			conn.setDoInput(true);
			// 获取URLConnection对象对应的输出流
			out = new PrintWriter(conn.getOutputStream());
			// 发送请求参数
			// String params = java.net.URLEncoder.encode(param);
			out.print(param);
			// flush输出流的缓冲
			out.flush();
			// 定义BufferedReader输入流来读取URL的响应
			in = new BufferedReader(new InputStreamReader(conn.getInputStream()));
			String line;
			while ((line = in.readLine()) != null) {
				result += line;
			}
		} catch (Exception e) {
			System.out.println("发送 POST 请求出现异常！" + e);
			e.printStackTrace();
		}
		// 使用finally块来关闭输出流、输入流
		finally {
			try {
				if (out != null) {
					out.close();
				}
				if (in != null) {
					in.close();
				}
			} catch (IOException ex) {
				ex.printStackTrace();
			}
		}

		return getResultDecode(result, aesKey, iv);
	}

	public static String getResultDecode(String result, byte[] aesKey, byte[] iv) {

		String resultdecode = null;
		
		System.out.println("result.len = " + result.length());

		byte[] baseResult = Utility.basedecode(result);

		byte[] aesResult = Utility.aesdecrypt(baseResult, aesKey, iv);

		try {
			resultdecode = new String(aesResult, "UTF-8");
		} catch (UnsupportedEncodingException e) {
			e.printStackTrace();
		}

		return resultdecode;
	}
	/*
	public static String CallBack(String v, String k, String c) throws Exception {
		
		byte[] aesKey = Utility.decrypt(Utility.loadPrivateKey(privateKey), Utility.basedecode(k));

		// AES 向量
		byte[] iv = new byte[16];
		if (aesKey != null) {
			for (int i = 0; i < 16; i++) {
				iv[i] = aesKey[i];
			}
		}
		return new String(Utility.aesdecrypt(Utility.basedecode(c), aesKey, iv));
		
	}
	*/
}
