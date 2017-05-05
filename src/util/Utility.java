package util;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.nio.charset.Charset;
import java.security.KeyFactory;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.security.Security;
import java.security.interfaces.RSAPrivateKey;
import java.security.interfaces.RSAPublicKey;
import java.security.spec.PKCS8EncodedKeySpec;
import java.security.spec.X509EncodedKeySpec;

import javax.crypto.Cipher;
import javax.crypto.spec.IvParameterSpec;
import javax.crypto.spec.SecretKeySpec;

import org.apache.commons.codec.binary.Base64;
import org.bouncycastle.jce.provider.BouncyCastleProvider;

//import sun.misc.BASE64Decoder;
//import sun.misc.BASE64Encoder;

public class Utility {
	
	public static byte[] sha256(String s) {
		
		MessageDigest md = null;
		try {
			md = MessageDigest.getInstance("SHA-256");
		} catch (NoSuchAlgorithmException e) {
			e.printStackTrace();
		}
		md.update(s.getBytes(Charset.forName("UTF-8")));
		byte[] hashed = md.digest();

		return hashed;
	}

	public static RSAPrivateKey loadPrivateKey(String privateKeyStr) throws Exception {

		RSAPrivateKey privateKey = null;
		try {
			//BASE64Decoder base64Decoder = new BASE64Decoder();
			//byte[] buffer = base64Decoder.decodeBuffer(privateKeyStr);
			byte[] buffer = Base64.decodeBase64(privateKeyStr);
			PKCS8EncodedKeySpec keySpec = new PKCS8EncodedKeySpec(buffer);
			KeyFactory keyFactory = KeyFactory.getInstance("RSA");
			privateKey = (RSAPrivateKey) keyFactory.generatePrivate(keySpec);
		} catch (Exception e) {
			throw new Exception("无此算法");
		}
		return privateKey;
	}

	/**
	 * 加密过程
	 * 
	 * @param RSAPrivateKey
	 *            私钥
	 * @param plainTextData
	 *            明文数据
	 * @return
	 * @throws Exception
	 *             加密过程中的异常信息
	 */
	public static byte[] encrypt(RSAPrivateKey privateKey, byte[] plainTextData) throws Exception {
		if (privateKey == null) {
			throw new Exception("加密私钥为空, 请设置");
		}
		Cipher cipher = null;
		try {
			cipher = Cipher.getInstance("RSA");
			cipher.init(Cipher.ENCRYPT_MODE, privateKey);
			byte[] output = cipher.doFinal(plainTextData);
			return output;
		} catch (Exception e) {
			throw new Exception("无此加密算法");
		}
	}

	/**
	 * 从文件中加载私钥
	 * 
	 * @param keyFileName
	 *            私钥文件名
	 * @return 是否成功
	 * @throws Exception
	 */
	public void loadPrivateKey(InputStream in) throws Exception {
		try {
			BufferedReader br = new BufferedReader(new InputStreamReader(in));
			String readLine = null;
			StringBuilder sb = new StringBuilder();
			while ((readLine = br.readLine()) != null) {
				if (readLine.charAt(0) == '-') {
					continue;
				} else {
					sb.append(readLine);
					sb.append('\r');
				}
			}
			loadPrivateKey(sb.toString());
		} catch (IOException e) {
			throw new Exception("私钥数据读取错误");
		} catch (NullPointerException e) {
			throw new Exception("私钥输入流为空");
		}
	}

	/**
	 * 从字符串中加载公钥
	 * 
	 * @param publicKeyStr
	 *            公钥数据字符串
	 * @throws Exception
	 *             加载公钥时产生的异常
	 */
	public RSAPublicKey loadPublicKey(String publicKeyStr) throws Exception {

		RSAPublicKey publicKey = null;

		try {
			//BASE64Decoder base64Decoder = new BASE64Decoder();
			//byte[] buffer = base64Decoder.decodeBuffer(publicKeyStr);
			
			byte[] buffer = Base64.decodeBase64(publicKeyStr);
			
			KeyFactory keyFactory = KeyFactory.getInstance("RSA");
			X509EncodedKeySpec keySpec = new X509EncodedKeySpec(buffer);
			publicKey = (RSAPublicKey) keyFactory.generatePublic(keySpec);
		} catch (NoSuchAlgorithmException e) {
			throw new Exception("无此算法");
		}
		return publicKey;
	}

	public static String base64(byte[] data) {
		// 对字节数组Base64编码
		//BASE64Encoder encoder = new BASE64Encoder();
		//return encoder.encode(data);// 返回Base64编码过的字节数组字符串
		return Base64.encodeBase64String(data);
	}

	/**
	 * 加密
	 * 
	 * @param content
	 *            需要加密的内容
	 * @param password
	 *            加密密码
	 * @return
	 */
	public static byte[] aseEncrypt(String content, byte[] password, byte[] iv) {
		try {

			Security.addProvider(new BouncyCastleProvider());
			SecretKeySpec key = new SecretKeySpec(password, "AES");
			Cipher in = Cipher.getInstance("AES/CBC/PKCS7Padding", "BC");
			in.init(Cipher.ENCRYPT_MODE, key, new IvParameterSpec(iv));
			byte[] enc = in.doFinal(content.getBytes());
			// str = new String(Hex.encode(enc));
			return enc;
		} catch (Exception e) {
			e.printStackTrace();
		}
		return null;
	}

	/**
	 * 解密
	 * 
	 * @param content
	 *            待解密内容
	 * @param password
	 *            解密密钥
	 * @return
	 */
	public static byte[] aesdecrypt(byte[] content, byte[] password, byte[] iv) {
		try {

			Security.addProvider(new BouncyCastleProvider());
			SecretKeySpec key = new SecretKeySpec(password, "AES");

			Cipher out = Cipher.getInstance("AES/CBC/PKCS7Padding", "BC");
			out.init(Cipher.DECRYPT_MODE, key, new IvParameterSpec(iv));
			byte[] dec = out.doFinal(content);
			return dec;
		} catch (Exception e) {
			e.printStackTrace();
		}
		return null;
	}

	/**
	 * 解码
	 * 
	 * @param str
	 * @return string
	 */
	public static byte[] basedecode(String str) {
		byte[] bt = null;
		try {
			//sun.misc.BASE64Decoder decoder = new sun.misc.BASE64Decoder();
			//bt = decoder.decodeBuffer(str);
			bt = Base64.decodeBase64(str);
		} catch (Exception e) {
			e.printStackTrace();
		}
		return bt;
	}

	/**
	 * 解密过程
	 * 
	 * @param privateKey
	 *            私钥
	 * @param cipherData
	 *            密文数据
	 * @return 明文
	 * @throws Exception
	 *             解密过程中的异常信息
	 */
	public static byte[] decrypt(RSAPrivateKey privateKey, byte[] cipherData) throws Exception {
		if (privateKey == null) {
			throw new Exception("解密私钥为空, 请设置");
		}
		Cipher cipher = null;
		try {
			cipher = Cipher.getInstance("RSA/ECB/PKCS1Padding");
			cipher.init(Cipher.DECRYPT_MODE, privateKey);
			byte[] output = cipher.doFinal(cipherData);
			return output;
		} catch (Exception e) {
			throw new Exception("密文数据已损坏");
		}
	}
}
