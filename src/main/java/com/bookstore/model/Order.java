package com.bookstore.model;

import java.sql.Date;

/**
 * Model class (JavaBean) to represent the 'Orders' table.
 * An Order with status "Pending" is a "shopping cart".
 */
public class Order {
    
    private int orderId;
    private int customerId;
    private Date orderDate;
    private double totalAmount;
    private String status; // e.g., "Pending", "Shipped", "Delivered"

    // Default constructor
    public Order() {
    }

    // Constructor for creating a new order
    public Order(int customerId, Date orderDate, double totalAmount, String status) {
        this.customerId = customerId;
        this.orderDate = orderDate;
        this.totalAmount = totalAmount;
        this.status = status;
    }
    
    // Full constructor (when retrieving from DB)
    public Order(int orderId, int customerId, Date orderDate, double totalAmount, String status) {
        this.orderId = orderId;
        this.customerId = customerId;
        this.orderDate = orderDate;
        this.totalAmount = totalAmount;
        this.status = status;
    }

    // --- Getters and Setters ---

    public int getOrderId() {
        return orderId;
    }

    public void setOrderId(int orderId) {
        this.orderId = orderId;
    }

    public int getCustomerId() {
        return customerId;
    }

    public void setCustomerId(int customerId) {
        this.customerId = customerId;
    }

    public Date getOrderDate() {
        return orderDate;
    }

    public void setOrderDate(Date orderDate) {
        this.orderDate = orderDate;
    }

    public double getTotalAmount() {
        return totalAmount;
    }

    public void setTotalAmount(double totalAmount) {
        this.totalAmount = totalAmount;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }
}