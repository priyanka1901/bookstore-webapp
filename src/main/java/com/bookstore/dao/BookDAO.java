package com.bookstore.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

import com.bookstore.model.Book;
import com.bookstore.util.DatabaseConnection;

/**
 * DAO for the 'Books' table.
 */
public class BookDAO {

    /**
     * Retrieves a list of all books from the database.
     */
    public List<Book> listAllBooks() {
        List<Book> bookList = new ArrayList<>();
        String sql = "SELECT * FROM Books";
        System.out.println("[BookDAO] Attempting to connect and run query: " + sql);

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {

            while (rs.next()) {
                Book book = new Book();
                book.setIsbn(rs.getString("isbn"));
                book.setTitle(rs.getString("title"));
                book.setPrice(rs.getDouble("price"));
                book.setQuantityInStock(rs.getInt("quantity_in_stock"));
                bookList.add(book);
                System.out.println("[BookDAO] ---> Found book: " + book.getTitle());
            }

        } catch (SQLException e) {
            System.err.println("[BookDAO] SQL Error: " + e.getMessage());
            e.printStackTrace();
        }
        System.out.println("[BookDAO] Query complete. Found " + bookList.size() + " books.");
        return bookList;
    }

    /**
     * *** NEW METHOD ***
     * Searches for books where the title or ISBN matches the query.
     */
    public List<Book> searchBooks(String query) {
        List<Book> bookList = new ArrayList<>();
        String sql = "SELECT * FROM Books WHERE title LIKE ? OR isbn LIKE ?";
        String searchQuery = "%" + query + "%";
        
        System.out.println("[BookDAO] Attempting to search for: " + query);

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, searchQuery);
            stmt.setString(2, searchQuery);
            
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Book book = new Book();
                    book.setIsbn(rs.getString("isbn"));
                    book.setTitle(rs.getString("title"));
                    book.setPrice(rs.getDouble("price"));
                    book.setQuantityInStock(rs.getInt("quantity_in_stock"));
                    bookList.add(book);
                    System.out.println("[BookDAO] ---> Found match: " + book.getTitle());
                }
            }

        } catch (SQLException e) {
            System.err.println("[BookDAO] SQL Error during search: " + e.getMessage());
            e.printStackTrace();
        }
        System.out.println("[BookDAO] Search complete. Found " + bookList.size() + " books.");
        return bookList;
    }


    /**
     * Adds a new book to the database.
     */
    public void addBook(Book book) {
        String sql = "INSERT INTO Books (isbn, title, price, quantity_in_stock) VALUES (?, ?, ?, ?)";
        System.out.println("[BookDAO] Executing: " + sql);
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, book.getIsbn());
            stmt.setString(2, book.getTitle());
            stmt.setDouble(3, book.getPrice());
            stmt.setInt(4, book.getQuantityInStock());
            
            stmt.executeUpdate();
            System.out.println("[BookDAO] New book added successfully.");

        } catch (SQLException e) {
            System.err.println("[BookDAO] SQL Error adding book: " + e.getMessage());
            e.printStackTrace();
        }
    }

    /**
     * Retrieves a single book by its ISBN.
     */
    public Book findBookByIsbn(String isbn) {
        Book book = null;
        String sql = "SELECT * FROM Books WHERE isbn = ?";
        System.out.println("[BookDAO] Finding book by ISBN: " + isbn);

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, isbn);
            
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    book = new Book();
                    book.setIsbn(rs.getString("isbn"));
                    book.setTitle(rs.getString("title"));
                    book.setPrice(rs.getDouble("price"));
                    book.setQuantityInStock(rs.getInt("quantity_in_stock"));
                    System.out.println("[BookDAO] Found book: " + book.getTitle());
                }
            }
        } catch (SQLException e) {
            System.err.println("[BookDAO] SQL Error finding book: " + e.getMessage());
            e.printStackTrace();
        }
        return book;
    }
    
    /**
     * Updates an existing book's details in the database.
     */
    public void updateBook(Book book) {
        String sql = "UPDATE Books SET title = ?, price = ?, quantity_in_stock = ? WHERE isbn = ?";
        System.out.println("[BookDAO] Executing update for ISBN: " + book.getIsbn());
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, book.getTitle());
            stmt.setDouble(2, book.getPrice());
            stmt.setInt(3, book.getQuantityInStock());
            stmt.setString(4, book.getIsbn());
            
            stmt.executeUpdate();
            System.out.println("[BookDAO] Book updated successfully.");

        } catch (SQLException e) {
            System.err.println("[BookDAO] SQL Error updating book: " + e.getMessage());
            e.printStackTrace();
        }
    }
    
    /**
     * Deletes a book from the database by its ISBN.
     * Note: This will fail if the book is part of an order (foreign key constraint).
     * We should add logic to handle this, e.g., by deleting from OrderItems first.
     */
    public void deleteBook(String isbn) {
        // First, we must delete this book from any "Pending" order items
        String deleteOrderItemsSql = "DELETE FROM OrderItems WHERE isbn = ? AND order_id IN (SELECT order_id FROM Orders WHERE status = 'Pending')";
        String deleteBookSql = "DELETE FROM Books WHERE isbn = ?";
        
        System.out.println("[BookDAO] Attempting to delete book: " + isbn);

        try (Connection conn = DatabaseConnection.getConnection()) {
            // Start a transaction
            conn.setAutoCommit(false);
            
            try {
                // 1. Delete from pending cart items
                try (PreparedStatement stmt1 = conn.prepareStatement(deleteOrderItemsSql)) {
                    stmt1.setString(1, isbn);
                    int itemsRemoved = stmt1.executeUpdate();
                    System.out.println("[BookDAO] Removed " + itemsRemoved + " items from pending carts.");
                }
                
                // 2. Delete the book itself
                try (PreparedStatement stmt2 = conn.prepareStatement(deleteBookSql)) {
                    stmt2.setString(1, isbn);
                    stmt2.executeUpdate();
                    System.out.println("[BookDAO] Book deleted successfully.");
                }
                
                // If both steps succeeded, commit the transaction
                conn.commit();
                
            } catch (SQLException e) {
                // If anything fails, roll back
                conn.rollback();
                System.err.println("[BookDAO] TRANSACTION FAILED. Rolling back. Error: " + e.getMessage());
                e.printStackTrace();
            } finally {
                // Always set auto-commit back to true
                conn.setAutoCommit(true);
            }

        } catch (SQLException e) {
            System.err.println("[BookDAO] SQL Error deleting book: " + e.getMessage());
            e.printStackTrace();
        }
    }
}