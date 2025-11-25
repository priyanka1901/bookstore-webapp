package com.bookstore.model;

/**
 * Model class (JavaBean) to represent an Author.
 */
public class Author {

    private int authorId;
    private String authorName;
    private String bio;

    // Default constructor
    public Author() {
    }

    // Constructor for creating a new author (ID is auto-generated)
    public Author(String authorName, String bio) {
        this.authorName = authorName;
        this.bio = bio;
    }
    
    // Constructor for fetching an existing author from DB
    public Author(int authorId, String authorName, String bio) {
        this.authorId = authorId;
        this.authorName = authorName;
        this.bio = bio;
    }

    // --- Getters and Setters ---
    
    public int getAuthorId() {
        return authorId;
    }

    public void setAuthorId(int authorId) {
        this.authorId = authorId;
    }

    public String getAuthorName() {
        return authorName;
    }

    public void setAuthorName(String authorName) {
        this.authorName = authorName;
    }

    public String getBio() {
        return bio;
    }

    public void setBio(String bio) {
        this.bio = bio;
    }

    @Override
    public String toString() {
        return "Author [authorId=" + authorId + ", authorName=" + authorName + "]";
    }
}