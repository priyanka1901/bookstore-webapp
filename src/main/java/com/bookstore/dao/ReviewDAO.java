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

    // List all reviews for a specific book, ordered by most recent
    public List<Review> listReviewsForBook(String isbn) {
        List<Review> reviews = new ArrayList<>();
        String sql = "SELECT r.*, c.name as customer_name " +
                     "FROM Reviews r " +
                     "JOIN Customers c ON r.customer_id = c.customer_id " +
                     "WHERE r.isbn = ? " +
                     "ORDER BY r.review_date DESC";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setString(1, isbn);
            ResultSet rs = pstmt.executeQuery();

            while (rs.next()) {
                Review review = mapResultSetToReview(rs);
                review.setCustomerName(rs.getString("customer_name"));
                reviews.add(review);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return reviews;
    }

    // Add a new review
    public boolean addReview(Review review) {
        String sql = "INSERT INTO Reviews (isbn, customer_id, rating, review_text, review_date) " +
                     "VALUES (?, ?, ?, ?, CURRENT_TIMESTAMP)";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setString(1, review.getIsbn());
            pstmt.setInt(2, review.getCustomerId());
            pstmt.setInt(3, review.getRating());
            pstmt.setString(4, review.getReviewText());
            
            int rowsAffected = pstmt.executeUpdate();
            return rowsAffected > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // Update an existing review
    public boolean updateReview(Review review) {
        String sql = "UPDATE Reviews SET rating = ?, review_text = ?, review_date = CURRENT_TIMESTAMP " +
                     "WHERE review_id = ? AND customer_id = ?";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, review.getRating());
            pstmt.setString(2, review.getReviewText());
            pstmt.setInt(3, review.getReviewId());
            pstmt.setInt(4, review.getCustomerId()); // Security check: ensure user owns the review
            
            int rowsAffected = pstmt.executeUpdate();
            return rowsAffected > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // Delete a review
    public boolean deleteReview(int reviewId, int customerId) {
        String sql = "DELETE FROM Reviews WHERE review_id = ? AND customer_id = ?";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, reviewId);
            pstmt.setInt(2, customerId); // Security check
            
            int rowsAffected = pstmt.executeUpdate();
            return rowsAffected > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // Find a specific review by a customer for a book (to check if they already reviewed it)
    public Review findReviewByCustomerAndBook(int customerId, String isbn) {
        String sql = "SELECT * FROM Reviews WHERE customer_id = ? AND isbn = ?";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, customerId);
            pstmt.setString(2, isbn);
            ResultSet rs = pstmt.executeQuery();

            if (rs.next()) {
                return mapResultSetToReview(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    // Get average rating for a book
    public double getAverageRating(String isbn) {
        String sql = "SELECT AVG(rating) FROM Reviews WHERE isbn = ?";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setString(1, isbn);
            ResultSet rs = pstmt.executeQuery();

            if (rs.next()) {
                return rs.getDouble(1); // Returns 0.0 if NULL
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0.0;
    }

    // Get total number of reviews for a book
    public int getReviewCount(String isbn) {
        String sql = "SELECT COUNT(*) FROM Reviews WHERE isbn = ?";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setString(1, isbn);
            ResultSet rs = pstmt.executeQuery();

            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    // Helper method to map ResultSet to Review object
    private Review mapResultSetToReview(ResultSet rs) throws SQLException {
        Review review = new Review();
        review.setReviewId(rs.getInt("review_id"));
        review.setIsbn(rs.getString("isbn"));
        review.setCustomerId(rs.getInt("customer_id"));
        review.setRating(rs.getInt("rating"));
        review.setReviewText(rs.getString("review_text"));
        review.setReviewDate(rs.getTimestamp("review_date"));
        return review;
    }
}