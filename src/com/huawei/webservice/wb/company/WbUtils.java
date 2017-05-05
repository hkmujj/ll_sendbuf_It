package com.huawei.webservice.wb.company;

import java.rmi.RemoteException;

import javax.crypto.Cipher;
import javax.crypto.spec.SecretKeySpec;

import net.sf.json.JSONObject;

import org.apache.commons.codec.binary.Base64;

import com.huawei.webservice.wb.company.CompanyServiceStub.GetEUserWobeiInfo;
import com.huawei.webservice.wb.company.CompanyServiceStub.GetEUserWobeiInfoResponse;
import com.huawei.webservice.wb.company.CompanyServiceStub.GetFlowCodes;
import com.huawei.webservice.wb.company.CompanyServiceStub.GetFlowCodesResponse;
import com.huawei.webservice.wb.company.CompanyServiceStub.GetFlowResult;
import com.huawei.webservice.wb.company.CompanyServiceStub.GetFlowResultResponse;
import com.huawei.webservice.wb.company.CompanyServiceStub.GetUserNetType;
import com.huawei.webservice.wb.company.CompanyServiceStub.GetUserNetTypeResponse;
import com.huawei.webservice.wb.company.CompanyServiceStub.GiveFlow;
import com.huawei.webservice.wb.company.CompanyServiceStub.GiveFlowResponse;
import com.huawei.webservice.wb.company.CompanyServiceStub.ResponseWbVo;

/**
 * 工具类
 * @author ChenXY
 *
 */
public class WbUtils
{
	public static final String URL = "http://119.6.201.36/services/CompanyService";// 服务器地址
	
	private static final String CHANNEL = "WB_dyxx_000001"; //渠道
	
	private static final String KEY = "dMfcN3V2O2WB0xOq"; //16位秘钥
	
	private static final String UNAME = "GZdyxx"; //沃贝平台企业用户名
	
	private static final String GETUSERNETTYPESRC = "channel=" + CHANNEL + "|serviceName=getUserNetType|";
	
	private static final String GETEUSERWOBEIINFOSRC = "channel=" + CHANNEL + "|serviceName=getEUserWobeiInfo|";
	
	private static final String GIVEFLOWSRC = "channel=" + CHANNEL + "|serviceName=giveFlow|";
	
	private static final String GETFLOWRESULTSRC = "channel=" + CHANNEL + "|serviceName=getFlowResult|";
	
	private static final String GETFLOWCODES = "channel=" + CHANNEL + "|serviceName=getFlowCodes|";
	
	/**
	 * 企业用户沃贝详情查询
	 * @param log
	 * @throws RemoteException
	 * 
	 * @return void
	 */
	public static ResponseWbVo getEUserWobeiInfo(StringBuffer log) throws RemoteException
	{
		GetEUserWobeiInfo getEUserWobeiInfo = new GetEUserWobeiInfo();
		getEUserWobeiInfo.setChannel(CHANNEL);
		getEUserWobeiInfo.setUName(UNAME);
		getEUserWobeiInfo.setSecretKey(Encrypt(GETEUSERWOBEIINFOSRC, KEY, log));
		
		GetEUserWobeiInfoResponse getEUserWobeiInfoResponse = new CompanyServiceStub(URL).getEUserWobeiInfo(getEUserWobeiInfo);
		
		ResponseWbVo responseWbVo = getEUserWobeiInfoResponse.get_return();
		System.out.println(",返回参数："+ JSONObject.fromObject(responseWbVo).toString());
		return responseWbVo;
	}
	
	/**
	 * 用户网别查询
	 * @param phone 手机号
	 * @param log
	 * @throws RemoteException
	 * 
	 * @return void
	 */
	public static ResponseWbVo getUserNetType(String phone[], StringBuffer log) throws RemoteException
	{
		GetUserNetType getUserNetType = new GetUserNetType();
		getUserNetType.setChannel(CHANNEL);
		getUserNetType.setPhone(phone);
		getUserNetType.setUName(UNAME);
		getUserNetType.setSecretKey(Encrypt(GETUSERNETTYPESRC, KEY, log));
		
		GetUserNetTypeResponse getUserNetTypeResponse = new CompanyServiceStub(URL).getUserNetType(getUserNetType);
		
		ResponseWbVo responseWbVo = getUserNetTypeResponse.get_return();
		log.append(",返回参数："+ JSONObject.fromObject(responseWbVo).toString());
		return responseWbVo;
	}
	
	/**
	 * 流量赠送
	 * @param uName
	 * @param phone 手机号
	 * @param flowCode 产品号
	 * @param msgId 短信模版id-需后台申请，审批后可用，默认不发送
	 * @param log
	 * @throws RemoteException
	 * 
	 * @return void
	 */
	public static ResponseWbVo giveFlow(String phone[], String flowCode,String msgId,StringBuffer log) throws RemoteException
	{
		GiveFlow giveFlow = new GiveFlow();
		giveFlow.setChannel(CHANNEL);
		giveFlow.setUName(UNAME);
		giveFlow.setPhone(phone);
		giveFlow.setFlowCode(flowCode);
		giveFlow.setMsgId(msgId);
		giveFlow.setSecretKey(Encrypt(GIVEFLOWSRC, KEY, log));
		
		GiveFlowResponse giveFlowResponse = new CompanyServiceStub(URL).giveFlow(giveFlow);
		
		ResponseWbVo responseWbVo = giveFlowResponse.get_return();
		log.append(",返回参数："+ JSONObject.fromObject(responseWbVo).toString());
		return responseWbVo;
	}
	
	/**
	 * 查看流量赠送结果
	 * @param flowOrderId-批次号
	 * @param log
	 * @throws RemoteException
	 * 
	 * @return void
	 */
	public static ResponseWbVo getFlowResult(String flowOrderId, StringBuffer log) throws RemoteException
	{
		GetFlowResult getFlowResult = new GetFlowResult();
		getFlowResult.setChannel(CHANNEL);
		getFlowResult.setUName(UNAME);
		getFlowResult.setFlowOrderId(flowOrderId);
		getFlowResult.setSecretKey(Encrypt(GETFLOWRESULTSRC, KEY, log));
		
		GetFlowResultResponse getFlowResultResponse = new CompanyServiceStub(URL).getFlowResult(getFlowResult);
		
		ResponseWbVo responseWbVo = getFlowResultResponse.get_return();
		log.append(",返回参数："+ JSONObject.fromObject(responseWbVo).toString());
		return responseWbVo;
	}
	
	/**
	 * 查看企业流量编码接口
	 * @param log
	 * @throws RemoteException
	 * 
	 * @return void
	 */
	public static ResponseWbVo getFlowCodes(StringBuffer log) throws RemoteException
	{
		GetFlowCodes getFlowCodes = new GetFlowCodes();
		getFlowCodes.setChannel(CHANNEL);
		getFlowCodes.setUName(UNAME);
		getFlowCodes.setSecretKey(Encrypt(GETFLOWCODES, KEY, log));
		
		GetFlowCodesResponse getFlowCodesResponse = new CompanyServiceStub(URL).getFlowCodes(getFlowCodes);
		
		ResponseWbVo responseWbVo = getFlowCodesResponse.get_return();
		log.append(",返回参数："+ JSONObject.fromObject(responseWbVo).toString());
		return responseWbVo;
	}
	
	/**
	 * 秘钥算法
	 * @param sSrc
	 * @param sKey
	 * @return
	 * 
	 * @return String
	 */
	protected static String Encrypt(String sSrc, String sKey, StringBuffer log) {
		String result = "";
		try
		{
			byte[] raw = sKey.getBytes("utf-8");
			SecretKeySpec skeySpec = new SecretKeySpec(raw, "AES");
			Cipher cipher = Cipher.getInstance("AES/ECB/PKCS5Padding");// "算法/模式/补码方式"
			cipher.init(Cipher.ENCRYPT_MODE, skeySpec);
			byte[] encrypted = cipher.doFinal(sSrc.getBytes("utf-8"));
			result = new Base64().encodeToString(encrypted);// 此处使用BASE64做转码功能，同时能起到2次加密的作用。
		} 
		catch (Exception e)
		{
			log.append("，生成沃贝秘钥错误，错误原因：" + e);
		} 
		
		return result;
	}
	
	public static void main(String[] args) {
		try {
			StringBuffer log = new StringBuffer();
		//	String[] phones = {"13000000000"};
			ResponseWbVo responseWbVo = null;
			
			//企业用户沃贝详情查询
//			responseWbVo = getEUserWobeiInfo(log);
			
			// 用户网别查询
//			responseWbVo = getUserNetType(phones,log);
			
			//流量赠送
//			String flowCode = "";
//			String msgId = "0";
//			responseWbVo = giveFlow(phones,  flowCode, msgId, log);
			
			//查看流量赠送结果
//			String flowOrderId = "";
//			responseWbVo = getFlowResult(flowOrderId,  log);
			
			//查看企业流量编码接口
			responseWbVo = getFlowCodes(log);
			
			System.out.println(log.toString());
			System.out.println("code="+responseWbVo.getCode());
			System.out.println("msg="+responseWbVo.getMsg());
			System.out.println("datas="+responseWbVo.getDatas());
		} catch (Exception e) {
			System.err.println("error="+e);
		}
	}
}
