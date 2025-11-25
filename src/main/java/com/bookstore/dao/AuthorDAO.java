package com.bookstore.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

import com.bookstore.model.Author;
import com.bookstore.util.DatabaseConnection;

/**
 * DAO for Author and BookAuthors tables.
 * Handles all C.R.U.D. for Authors and the linking/unlinking of authors to books.
 */
public class AuthorDAO {

    // --- C.R.U.D. Methods for Authors Table ---

    /**
     * Adds a new author to the Authors table.
     * Assumes author_id is auto-incrementing.
     * @param author The Author object to add (without an ID).
     * @return The generated author_id, or -1 if failed.
     */
    public int addAuthor(Author author) {
        String sql = "INSERT INTO Authors (author_name, bio) VALUES (?, ?)";
        System.out.println("[AuthorDAO] Adding new author: " + author.getAuthorName());
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            pstmt.setString(1, author.getAuthorName());
            pstmt.setString(2, author.getBio());
            
            int rowsAffected = pstmt.executeUpdate();

            if (rowsAffected > 0) {
                // Get the generated author_id
                try (ResultSet rs = pstmt.getGeneratedKeys()) {
                    if (rs.next()) {
                        int generatedId = rs.getInt(1);
                        System.out.println("[AuthorDAO] Author added with ID: " + generatedId);
                        return generatedId;
                    }
                }
            }
        } catch (SQLException e) {
            System.err.println("SQL Error in addAuthor(): " + e.getMessage());
            e.printStackTrace();
        }
        return -1; // Return -1 on failure
    }

    /**
     * Fetches all authors from the Authors table.
     * @return A list of all Author objects.
     */
    public List<Author> listAllAuthors() {
        List<Author> authorList = new ArrayList<>();
        String sql = "SELECT * FROM Authors";
        System.out.println("[AuthorDAO] Listing all authors");
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {

            while (rs.next()) {
                Author author = new Author(
                    rs.getInt("author_id"),
                    rs.getString("author_name"),
                    rs.getString("bio")
                );
                authorList.add(author);
            }
        } catch (SQLException e) {
            System.err.println("SQL Error in listAllAuthors(): " + e.getMessage());
            e.printStackTrace();
        }
        System.out.println("[AuthorDAO] Found " + authorList.size() + " authors.");
        return authorList;
    }
    
    /**
     * Fetches a single author by their ID.
     * @param authorId The ID of the author to find.
     * @return An Author object, or null if not found.
     */
    public Author findAuthorById(int authorId) {
        String sql = "SELECT * FROM Authors WHERE author_id = ?";
        System.out.println("[AuthorDAO] Finding author by ID: " + authorId);
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, authorId);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return new Author(
                        rs.getInt("author_id"),
                        rs.getString("author_name"),
                        rs.getString("bio")
                    );
                }
            }
        } catch (SQLException e) {
            System.err.println("SQL Error in findAuthorById(): " + e.getMessage());
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Updates an existing author in the Authors table.
     * @param author The Author object with updated information.
     * @return true if successful, false otherwise.
     */
    public boolean updateAuthor(Author author) {
        String sql = "UPDATE Authors SET author_name = ?, bio = ? WHERE author_id = ?";
        System.out.println("[AuthorDAO] Updating author ID: " + author.getAuthorId());
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, author.getAuthorName());
            pstmt.setString(2, author.getBio());
            pstmt.setInt(3, author.getAuthorId());
            
            int rowsAffected = pstmt.executeUpdate();
            return rowsAffected > 0;

        } catch (SQLException e) {
            System.err.println("SQL Error in updateAuthor(): " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Deletes an author. This is a transaction:
     * 1. Deletes all links from BookAuthors.
     * 2. Deletes the author from Authors.
     * @param authorId The ID of the author to delete.
     * @return true if successful, false otherwise.
     */
    public boolean deleteAuthor(int authorId) {
        String deleteLinksSQL = "DELETE FROM BookAuthors WHERE author_id = ?";
        String deleteAuthorSQL = "DELETE FROM Authors WHERE author_id = ?";
        System.out.println("[AuthorDAO] Deleting author ID: " + authorId);
        
        Connection conn = null;
        try {
            conn = DatabaseConnection.getConnection();
            conn.setAutoCommit(false); // Start transaction

            // 1. Delete links from junction table
            try (PreparedStatement pstmtLinks = conn.prepareStatement(deleteLinksSQL)) {
                pstmtLinks.setInt(1, authorId);
                pstmtLinks.executeUpdate();
                System.out.println("[AuthorDAO] Deleted author links from BookAuthors.");
            }
            
            // 2. Delete author from main table
            try (PreparedStatement pstmtAuthor = conn.prepareStatement(deleteAuthorSQL)) {
                pstmtAuthor.setInt(1, authorId);
                int rowsAffected = pstmtAuthor.executeUpdate();
                
                if (rowsAffected > 0) {
                    conn.commit(); // Commit transaction
                    System.out.println("[AuthorDAO] Successfully deleted author.");
                    return true;
                } else {
                    conn.rollback(); // Rollback if author deletion failed
                    return false;
                }
            }

        } catch (SQLException e) {
            System.err.println("SQL Error in deleteAuthor() transaction: " + e.getMessage());
            e.printStackTrace();
            if (conn != null) {
                try {
                    conn.rollback(); // Rollback on error
                } catch (SQLException se) {
                    se.printStackTrace();
                }
            }
            return false;
        } finally {
            if (conn != null) {
                try {
                    conn.setAutoCommit(true); // Restore default
                    conn.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
        }
    }

    // --- Methods for BookAuthors Junction Table ---

    /**
     * Gets a list of all authors for a specific book.
     * @param isbn The book's ISBN.
     * @return A list of Author objects.
     */
    public List<Author> getAuthorsForBook(String isbn) {
        List<Author> authorList = new ArrayList<>();
        String sql = "SELECT a.* FROM Authors a " +
                     "JOIN BookAuthors ba ON a.author_id = ba.author_id " +
                     "WHERE ba.ISBN = ?";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setString(1, isbn);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    Author author = new Author(
                        rs.getInt("author_id"),
                        rs.getString("author_name"),
                        rs.getString("bio")
                    );
                    authorList.add(author);
                }
            }
        } catch (SQLException e) {
            System.err.println("SQL Error in getAuthorsForBook(): " + e.getMessage());
            e.printStackTrace();
        }
        return authorList;
    }

    /**
     * Links an author to a book in the BookAuthors table.
     * @param isbn The book's ISBN.
     * @param authorId The author's ID.
     * @return true if successful, false otherwise.
     */
    public boolean linkAuthorToBook(String isbn, int authorId) {
        String sql = "INSERT INTO BookAuthors (ISBN, author_id) VALUES (?, ?)";
        System.out.println("[AuthorDAO] Linking author " + authorId + " to book " + isbn);
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setString(1, isbn);
            pstmt.setInt(2, authorId);
            
            int rowsAffected = pstmt.executeUpdate();
            return rowsAffected > 0;
            
        } catch (SQLException e) {
            System.err.println("SQL Error in linkAuthorToBook(): " + e.getMessage());
            // It might fail if the link already exists, which is fine.
            return false;
        }
    }
    
    /**
     * Unlinks an author from a book in the BookAuthors table.
     * @param isbn The book's ISBN.
     * @param authorId The author's ID.
     * @return true if successful, false otherwise.
     */
    public boolean unlinkAuthorFromBook(String isbn, int authorId) {
        String sql = "DELETE FROM BookAuthors WHERE ISBN = ? AND author_id = ?";
        System.out.println("[AuthorDAO] Unlinking author " + authorId + " from book " + isbn);
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setString(1, isbn);
            pstmt.setInt(2, authorId);
            
            int rowsAffected = pstmt.executeUpdate();
            return rowsAffected > 0;
            
        } catch (SQLException e) {
            System.err.println("SQL Error in unlinkAuthorFromBook(): " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
}