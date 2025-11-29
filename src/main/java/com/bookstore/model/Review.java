package com.bookstore.model;

// Use java.sql.Timestamp to match the DATETIME type
import java.sql.Timestamp; 

public class Review {
    private int reviewId;
    private String isbn;
    private int customerId;
    private int rating;
    private String reviewText;
    private Timestamp reviewDate;

    // Transient field (not in DB, filled by a JOIN)
    private String customerName;

    // Constructors
    public Review() {}

    // Getters and Setters
    public int getReviewId() {
        return reviewId;
    }
    public void setReviewId(int reviewId) {
        this.reviewId = reviewId;
    }
    public String getIsbn() {
        return isbn;
    }
    public void setIsbn(String isbn) {
        this.isbn = isbn;
    }
    public int getCustomerId() {
        return customerId;
    }
    public void setCustomerId(int customerId) {
        this.customerId = customerId;
    }
    public int getRating() {
        return rating;
    }
    public void setRating(int rating) {
        this.rating = rating;
    }
    public String getReviewText() {
        return reviewText;
    }
    public void setReviewText(String reviewText) {
        this.reviewText = reviewText;
    }
    
    // UPDATED Getter/Setter
    public Timestamp getReviewDate() {
        return reviewDate;
    }
    public void setReviewDate(Timestamp reviewDate) {
        this.reviewDate = reviewDate;
    }
    
    public String getCustomerName() {
        return customerName;
    }
    public void setCustomerName(String customerName) {
        this.customerName = customerName;
    }
}
