package com.bookstore.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import com.bookstore.model.Review;
import com.bookstore.util.DatabaseConnection;

public class ReviewDAO {

    /**
     * Fetches all reviews for a specific book, joining with the Customer table
     * to get the customer's name.
     */
    public List<Review> getReviewsForBook(String isbn) {
        System.out.println("[ReviewDAO] Getting reviews for book: " + isbn);
        List<Review> reviews = new ArrayList<>();
        String sql = "SELECT r.*, c.name FROM Reviews r " +
                     "JOIN Customers c ON r.customer_id = c.customer_id " +
                     "WHERE r.isbn = ? ORDER BY r.review_date DESC";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, isbn);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Review review = new Review();
                    review.setReviewId(rs.getInt("review_id"));
                    review.setIsbn(rs.getString("isbn"));
                    review.setCustomerId(rs.getInt("customer_id"));
                    review.setRating(rs.getInt("rating"));
                    review.setReviewText(rs.getString("review_text"));
                    // <-- UPDATED to getTimestamp
                    review.setReviewDate(rs.getTimestamp("review_date")); 
                    review.setCustomerName(rs.getString("name")); // From JOIN
                    reviews.add(review);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        System.out.println("[ReviewDAO] Found " + reviews.size() + " reviews.");
        return reviews;
    }

    /**
     * Adds a new review to the database.
     */
    public boolean addReview(Review review) {
        System.out.println("[ReviewDAO] Adding review for: " + review.getIsbn() + " by " + review.getCustomerId());
        
        // <-- UPDATED SQL: Removed review_date, DB will handle it.
        String sql = "INSERT INTO Reviews (isbn, customer_id, rating, review_text) " +
                     "VALUES (?, ?, ?, ?)";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, review.getIsbn());
            ps.setInt(2, review.getCustomerId());
            ps.setInt(3, review.getRating());
            ps.setString(4, review.getReviewText());

            int rowsAffected = ps.executeUpdate();
            return rowsAffected > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Checks if a customer has already reviewed a specific book.
     */
    public boolean checkIfCustomerReviewedBook(int customerId, String isbn) {
        String sql = "SELECT 1 FROM Reviews WHERE customer_id = ? AND isbn = ? LIMIT 1";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, customerId);
            ps.setString(2, isbn);

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next(); // true if a record was found
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Checks if a customer has a "Placed" order for this book.
     */
    public boolean checkIfCustomerPurchasedBook(int customerId, String isbn) {
        String sql = "SELECT 1 FROM Orders o " +
                     "JOIN OrderItems oi ON o.order_id = oi.order_id " +
                     "WHERE o.customer_id = ? AND oi.isbn = ? AND o.status = 'Placed' LIMIT 1";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, customerId);
            ps.setString(2, isbn);

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next(); // true if a record was found
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
}