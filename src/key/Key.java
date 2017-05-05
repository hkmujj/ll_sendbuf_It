package key;

public class Key {

	public static String keypath = null;
	
	static{
		String path = Key.class.getResource("").getPath();
		path = path.substring(1, path.lastIndexOf("key"));
		path = path.replace("%20", " ");
		keypath = path + "key/";
	}
	
}
