package com.bookstore.model;

/**
 * Book Model Class (also known as a JavaBean or POJO)
 * * This class represents a single book from our 'Books' table.
 * The fields here match the columns in the database.
 * * We follow the JavaBean standard:
 * 1. All fields are private.
 * 2. Public getter and setter methods for all fields.
 * 3. A public no-argument (default) constructor.
 * 4. (Optional) A constructor with all fields.
 */
public class Book {

    // Fields corresponding to the 'Books' table columns
    private String isbn;
    private String title;
    private double price;
    private int quantityInStock;
    
    // Default constructor (required for a JavaBean)
    public Book() {
    }

    // Constructor with all fields
    public Book(String isbn, String title, double price, int quantityInStock) {
        this.isbn = isbn;
        this.title = title;
        this.price = price;
        this.quantityInStock = quantityInStock;
    }

    // --- Getters and Setters ---
    
    public String getIsbn() {
        return isbn;
    }

    public void setIsbn(String isbn) {
        this.isbn = isbn;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public double getPrice() {
        return price;
    }

    public void setPrice(double price) {
        this.price = price;
    }

    public int getQuantityInStock() {
        return quantityInStock;
    }

    public void setQuantityInStock(int quantityInStock) {
        this.quantityInStock = quantityInStock;
    }

    // (Optional) A 'toString' method for easy debugging
    @Override
    public String toString() {
        return "Book [isbn=" + isbn + ", title=" + title + ", price=" + price + ", quantityInStock=" + quantityInStock + "]";
    }
}