package com.bookstore.model;

/**
 * Customer Model Class (JavaBean)
 * This class represents a single customer from the 'Customers' table.
 */
public class Customer {

    private int customerId;
    private String name;
    private String email;
    private String passwordHash; // We only store the HASH of the password
    private String address;
    
    // Default constructor
    public Customer() {
    }

    // Constructor for creating a NEW customer (ID is auto-generated)
    // We take a plain-text password and will hash it in the DAO.
    public Customer(String name, String email, String plainTextPassword, String address) {
        this.name = name;
        this.email = email;
        this.passwordHash = plainTextPassword; // Temporarily hold plain text, DAO will hash
        this.address = address;
    }
    
    // Constructor for fetching an EXISTING customer from DB
    public Customer(int customerId, String name, String email, String passwordHash, String address) {
        this.customerId = customerId;
        this.name = name;
        this.email = email;
        this.passwordHash = passwordHash;
        this.address = address;
    }

    // --- Getters and Setters ---
    
    public int getCustomerId() {
        return customerId;
    }

    public void setCustomerId(int customerId) {
        this.customerId = customerId;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getPasswordHash() {
        return passwordHash;
    }

    public void setPasswordHash(String passwordHash) {
        this.passwordHash = passwordHash;
    }

    public String getAddress() {
        return address;
    }

    public void setAddress(String address) {
        this.address = address;
    }

    @Override
    public String toString() {
        return "Customer [customerId=" + customerId + ", name=" + name + ", email=" + email + "]";
    }
}