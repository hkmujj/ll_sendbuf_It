package database;

import java.sql.Connection;

import javax.naming.InitialContext;
import javax.sql.DataSource;

public class DatabaseUtils {
	
	public static Connection getLLMainDBConnByJNDI() throws Exception{
		InitialContext ctx = new InitialContext(); 
		return ((DataSource)ctx.lookup("java:comp/env/jdbc/llmain")).getConnection();
	}

	public static Connection getLLTempDBConnByJNDI()  throws Exception{
		InitialContext ctx = new InitialContext(); 
		return ((DataSource)ctx.lookup("java:comp/env/jdbc/lltemp")).getConnection();
	}
	
}
