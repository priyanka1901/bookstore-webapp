package com.bookstore.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

/**
 * DatabaseConnection Utility
 * * This class provides a static method to get a connection to the 
 * MySQL database. We will use this in all our DAO classes.
 * * NOTE: For a real-world production app, you would use a connection pool (like c3p0 or HikariCP)
 * for performance. But for a class project, this direct connection is perfectly fine.
 */
public class DatabaseConnection {


    private static final String JDBC_URL = "jdbc:mysql://localhost:3306/bookstore_db?useSSL=false&allowPublicKeyRetrieval=true";
    private static final String DB_USER = "root";
    private static final String DB_PASSWORD = "mysql_pass";
    // ------------------------------------

    /**
     * Attempts to get a connection to the database.
     * @return A Connection object.
     * @throws SQLException if a database access error occurs.
     */
    public static Connection getConnection() throws SQLException {
        
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            System.err.println("MySQL JDBC Driver not found.");
            e.printStackTrace();
            throw new SQLException("MySQL JDBC Driver not found.", e);
        }
        
        // Etablish the connection
        Connection conn = DriverManager.getConnection(JDBC_URL, DB_USER, DB_PASSWORD);
        
        // --- DIAGNOSTIC TEST ---
        // We are setting the isolation level to read uncommitted data.
        // This will allow our app to see the data from Workbench
        // even if it's not committed.
        //conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
        // -----------------------
        
        return conn;
    }

    /**
     * A simple main method to test the connection.
     */
    public static void main(String[] args) {
        System.out.println("Attempting to connect to database...");
        try (Connection conn = getConnection()) {
            
            if (conn != null && !conn.isClosed()) {
                System.out.println("Connection Successful!");
                System.out.println("Database Product: " + conn.getMetaData().getDatabaseProductName());
                System.out.println("Database Version: " + conn.getMetaData().getDatabaseProductVersion());
            } else {
                System.err.println("Connection failed!");
            }
            
        } catch (SQLException e) {
            System.err.println("Connection failed! Check your URL, username, and password.");
            e.printStackTrace();
        }
    }
}