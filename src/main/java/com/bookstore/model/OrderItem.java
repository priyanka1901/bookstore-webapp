package com.bookstore.model;

/**
 * Model class (JavaBean) to represent the 'OrderItems' table.
 * This links an Order to a Book.
 */
public class OrderItem {

    private int orderItemId;
    private int orderId;
    private String isbn;
    private int quantity;
    private double priceAtPurchase;
    
    // --- We also add these fields to hold JOINED data ---
    // These are not in the 'OrderItems' table but are useful
    // when we fetch the cart details (e.g., to show the book's title).
    private String bookTitle;

    // Default constructor
    public OrderItem() {
    }
    
    // Constructor for adding a new item
    public OrderItem(int orderId, String isbn, int quantity, double priceAtPurchase) {
        this.orderId = orderId;
        this.isbn = isbn;
        this.quantity = quantity;
        this.priceAtPurchase = priceAtPurchase;
    }

    // --- Getters and Setters ---

    public int getOrderItemId() {
        return orderItemId;
    }

    public void setOrderItemId(int orderItemId) {
        this.orderItemId = orderItemId;
    }

    public int getOrderId() {
        return orderId;
    }

    public void setOrderId(int orderId) {
        this.orderId = orderId;
    }

    public String getIsbn() {
        return isbn;
    }

    public void setIsbn(String isbn) {
        this.isbn = isbn;
    }

    public int getQuantity() {
        return quantity;
    }

    public void setQuantity(int quantity) {
        this.quantity = quantity;
    }

    public double getPriceAtPurchase() {
        return priceAtPurchase;
    }

    public void setPriceAtPurchase(double priceAtPurchase) {
        this.priceAtPurchase = priceAtPurchase;
    }
    
    // --- Getters/Setters for JOINED data ---
    
    public String getBookTitle() {
        return bookTitle;
    }

    public void setBookTitle(String bookTitle) {
        this.bookTitle = bookTitle;
    }
}