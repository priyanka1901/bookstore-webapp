package com.bookstore.dao;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

import com.bookstore.model.Customer;
import com.bookstore.util.DatabaseConnection;

/**
 * DAO for Customer table.
 * Handles registration (with password hashing) and login checks.
 */
public class CustomerDAO {

    /**
     * Hashes a plain-text password using SHA-256.
     * @param password The plain-text password.
     * @return A hex string representation of the hashed password.
     */
    private String hashPassword(String password) {
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            byte[] encodedhash = digest.digest(password.getBytes(StandardCharsets.UTF_8));
            
            // Convert byte array to hex string
            StringBuilder hexString = new StringBuilder(2 * encodedhash.length);
            for (int i = 0; i < encodedhash.length; i++) {
                String hex = Integer.toHexString(0xff & encodedhash[i]);
                if (hex.length() == 1) {
                    hexString.append('0');
                }
                hexString.append(hex);
            }
            return hexString.toString();
        } catch (NoSuchAlgorithmException e) {
            System.err.println("Error: SHA-256 algorithm not found.");
            e.printStackTrace();
            throw new RuntimeException("SHA-256 error", e); // Fail fast
        }
    }

    /**
     * Registers a new customer in the database.
     * Hashes the password before storing.
     * @param customer A Customer object with a plain-text password.
     * @return true if registration is successful, false otherwise (e.g., email exists).
     */
    public boolean registerCustomer(Customer customer) {
        String sql = "INSERT INTO Customers (name, email, password_hash, address) VALUES (?, ?, ?, ?)";
        System.out.println("[CustomerDAO] Attempting to register new customer: " + customer.getEmail());

        // Hash the password before storing
        String hashedPassword = hashPassword(customer.getPasswordHash());

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            pstmt.setString(1, customer.getName());
            pstmt.setString(2, customer.getEmail());
            pstmt.setString(3, hashedPassword);
            pstmt.setString(4, customer.getAddress());

            int rowsAffected = pstmt.executeUpdate();
            return rowsAffected > 0;

        } catch (SQLException e) {
            System.err.println("SQL Error in registerCustomer(): " + e.getMessage());
            // This error (e.g., code 1062) will trigger if the email (UNIQUE) already exists
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Checks if a customer's login credentials are valid.
     * @param email The customer's email.
     * @param plainTextPassword The plain-text password to check.
     * @return A Customer object if the login is valid, otherwise null.
     */
    public Customer checkLogin(String email, String plainTextPassword) {
        String sql = "SELECT * FROM Customers WHERE email = ?";
        System.out.println("[CustomerDAO] Checking login for: " + email);

        String hashedPasswordToCheck = hashPassword(plainTextPassword);

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, email);

            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    // Email found, now check the password
                    String storedHash = rs.getString("password_hash");

                    if (hashedPasswordToCheck.equals(storedHash)) {
                        // Password matches!
                        System.out.println("[CustomerDAO] Password match for: " + email);
                        return new Customer(
                            rs.getInt("customer_id"),
                            rs.getString("name"),
                            rs.getString("email"),
                            storedHash, // Don't return the plain text pass
                            rs.getString("address")
                        );
                    } else {
                        // Password does not match
                        System.out.println("[CustomerDAO] Password mismatch for: " + email);
                    }
                } else {
                    // No user found with that email
                    System.out.println("[CustomerDAO] No customer found with email: " + email);
                }
            }
        } catch (SQLException e) {
            System.err.println("SQL Error in checkLogin(): " + e.getMessage());
            e.printStackTrace();
        }

        return null; // Return null if login fails for any reason
    }
}
