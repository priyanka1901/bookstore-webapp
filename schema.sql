-- 1. Create the Database
CREATE DATABASE IF NOT EXISTS bookstore_db;
USE bookstore_db;

-- 2. Create Tables
CREATE TABLE IF NOT EXISTS Customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    address TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS Authors (
    author_id INT AUTO_INCREMENT PRIMARY KEY,
    author_name VARCHAR(255) NOT NULL,
    bio TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS Books (
    ISBN VARCHAR(13) PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    quantity_in_stock INT NOT NULL
);

CREATE TABLE IF NOT EXISTS BookAuthors (
    ISBN VARCHAR(13) NOT NULL,
    author_id INT NOT NULL,
    PRIMARY KEY (ISBN, author_id),
    FOREIGN KEY (ISBN) REFERENCES Books(ISBN) ON DELETE CASCADE,
    FOREIGN KEY (author_id) REFERENCES Authors(author_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS Orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    order_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    total_amount DECIMAL(10, 2) NOT NULL,
    status VARCHAR(50) NOT NULL DEFAULT 'Pending',
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id)
);

CREATE TABLE IF NOT EXISTS Reviews (
    review_id INT AUTO_INCREMENT PRIMARY KEY,
    ISBN VARCHAR(13) NOT NULL,
    customer_id INT NOT NULL,
    rating INT NOT NULL CHECK (rating >= 1 AND rating <= 5),
    review_text TEXT NOT NULL,
    review_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (ISBN) REFERENCES Books(ISBN) ON DELETE CASCADE,
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id)
);

CREATE TABLE IF NOT EXISTS OrderItems (
    order_item_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    ISBN VARCHAR(13) NOT NULL,
    quantity INT NOT NULL,
    price_at_purchase DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES Orders(order_id) ON DELETE CASCADE,
    FOREIGN KEY (ISBN) REFERENCES Books(ISBN)
);

-- 3. Insert Sample Data (Only if tables are empty)
-- Authors
INSERT IGNORE INTO Authors (author_name, bio) VALUES 
('Frank Herbert', 'An American science-fiction author, best known for the novel Dune.'),
('J.R.R. Tolkien', 'An English writer, poet, philologist, and academic.');

-- Books
INSERT IGNORE INTO Books (ISBN, title, price, quantity_in_stock) VALUES 
('9780441172716', 'Dune', 18.99, 50),
('9780544003415', 'The Hobbit', 14.99, 75),
('9780618640157', 'The Fellowship of the Ring', 16.99, 60);

-- Link Books to Authors
INSERT IGNORE INTO BookAuthors (ISBN, author_id) 
SELECT '9780441172716', author_id FROM Authors WHERE author_name = 'Frank Herbert';

INSERT IGNORE INTO BookAuthors (ISBN, author_id) 
SELECT '9780544003415', author_id FROM Authors WHERE author_name = 'J.R.R. Tolkien';

INSERT IGNORE INTO BookAuthors (ISBN, author_id) 
SELECT '9780618640157', author_id FROM Authors WHERE author_name = 'J.R.R. Tolkien';

-- Create Admin User (Optional)
INSERT IGNORE INTO Customers (name, email, password_hash, address) VALUES
('Admin User', 'admin@bookstore.com', 'admin123', 'Bookstore HQ');
