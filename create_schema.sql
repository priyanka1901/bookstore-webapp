-- Create the bookstore database
CREATE DATABASE IF NOT EXISTS bookstore_db;
USE bookstore_db;

-- Drop tables if they exist (in reverse order of dependencies)
DROP TABLE IF EXISTS OrderItems;
DROP TABLE IF EXISTS Orders;
DROP TABLE IF EXISTS Reviews;
DROP TABLE IF EXISTS BookAuthors;
DROP TABLE IF EXISTS Books;
DROP TABLE IF EXISTS Authors;
DROP TABLE IF EXISTS Customers;

-- Authors table
CREATE TABLE Authors (
    author_id INT AUTO_INCREMENT PRIMARY KEY,
    author_name VARCHAR(255) NOT NULL,
    bio TEXT NOT NULL
);

-- Books table
CREATE TABLE Books (
    ISBN VARCHAR(13) PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    quantity_in_stock INT NOT NULL DEFAULT 0,
    CHECK (price >= 0),
    CHECK (quantity_in_stock >= 0)
);

-- BookAuthors junction table (many-to-many relationship)
CREATE TABLE BookAuthors (
    ISBN VARCHAR(13) NOT NULL,
    author_id INT NOT NULL,
    PRIMARY KEY (ISBN, author_id),
    FOREIGN KEY (ISBN) REFERENCES Books(ISBN) ON DELETE CASCADE,
    FOREIGN KEY (author_id) REFERENCES Authors(author_id) ON DELETE CASCADE
);

-- Customers table
CREATE TABLE Customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    address TEXT NOT NULL
);

-- Reviews table
CREATE TABLE Reviews (
    review_id INT AUTO_INCREMENT PRIMARY KEY,
    ISBN VARCHAR(13) NOT NULL,
    customer_id INT NOT NULL,
    rating INT NOT NULL,
    review_text TEXT NOT NULL,
    review_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (ISBN) REFERENCES Books(ISBN) ON DELETE CASCADE,
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id) ON DELETE CASCADE,
    CHECK (rating >= 1 AND rating <= 5)
);

-- Orders table
CREATE TABLE Orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    order_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    total_amount DECIMAL(10, 2) NOT NULL,
    status VARCHAR(50) NOT NULL DEFAULT 'Pending',
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id) ON DELETE CASCADE,
    CHECK (total_amount >= 0)
);

-- OrderItems table
CREATE TABLE OrderItems (
    order_item_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    ISBN VARCHAR(13) NOT NULL,
    quantity INT NOT NULL,
    price_at_purchase DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES Orders(order_id) ON DELETE CASCADE,
    FOREIGN KEY (ISBN) REFERENCES Books(ISBN) ON DELETE CASCADE,
    CHECK (quantity > 0),
    CHECK (price_at_purchase >= 0)
);

-- Create indexes for better query performance
CREATE INDEX idx_books_title ON Books(title);
CREATE INDEX idx_customers_email ON Customers(email);
CREATE INDEX idx_orders_customer ON Orders(customer_id);
CREATE INDEX idx_orders_date ON Orders(order_date);
CREATE INDEX idx_reviews_book ON Reviews(ISBN);
CREATE INDEX idx_reviews_customer ON Reviews(customer_id);
CREATE INDEX idx_orderitems_order ON OrderItems(order_id);
