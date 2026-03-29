package com.doit.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.util.Properties;

public class DBConn {

	private static Connection conn = null;
	
	private static final String URL = "jdbc:oracle:thin:@192.168.10.2:1521/FREE";
	private static final String USER = "ufunny";
	private static final String PASSWORD = "yh0905";
	
	private DBConn() {}
	
	public static Connection getConnection() {
		if(conn==null) {
			try {
				
				Class.forName("oracle.jdbc.driver.OracleDriver");
				conn = DriverManager.getConnection(URL, USER, PASSWORD);
				
			} catch (Exception e) {
				e.printStackTrace();
			}
		}
		
		return conn;
	}
	
	public static Connection getConnection(String url, String user, String pwd, String internal_logon) {
		if(conn==null) {
			
			try {
				Properties info = new Properties();
				info.put("user", user);
				info.put("pwd", pwd);
				info.put("internal_logon", internal_logon);
				
				
				Class.forName("oracle.jdbc.driver.OracleDriver");
				conn = DriverManager.getConnection(url, info);
				
			} catch (Exception e) {
				e.printStackTrace();
			}
			
		}
		return conn;
	}
	
	
	public static void close() {
		
		if(conn==null)
			return;
		
		try {
			if(!conn.isClosed())
				conn.close();
			
		} catch (Exception e) {
			e.printStackTrace();
		}
		conn = null;
	}
}
