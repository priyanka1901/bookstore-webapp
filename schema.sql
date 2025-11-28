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

-- ============================================
-- INSERT SAMPLE DATA (20 entries per table)
-- ============================================

-- Insert 20 Authors
INSERT INTO Authors (author_name, bio) VALUES
('J.K. Rowling', 'British author best known for the Harry Potter series.'),
('George Orwell', 'English novelist and essayist, known for 1984 and Animal Farm.'),
('F. Scott Fitzgerald', 'American novelist of the Jazz Age, author of The Great Gatsby.'),
('Harper Lee', 'American novelist known for To Kill a Mockingbird.'),
('J.R.R. Tolkien', 'English writer and philologist, creator of Middle-earth.'),
('Jane Austen', 'English novelist known for her social commentary and romantic fiction.'),
('Gabriel García Márquez', 'Colombian novelist and Nobel Prize winner.'),
('Yuval Noah Harari', 'Israeli historian and author of Sapiens.'),
('Michelle Obama', 'Former First Lady of the United States and author.'),
('Tara Westover', 'American memoirist and historian.'),
('Stephen King', 'American author of horror, supernatural fiction, and suspense.'),
('Agatha Christie', 'British mystery writer known for Hercule Poirot and Miss Marple.'),
('Ernest Hemingway', 'American novelist and short-story writer, Nobel Prize winner.'),
('Margaret Atwood', 'Canadian poet and novelist, author of The Handmaid''s Tale.'),
('J.D. Salinger', 'American writer known for The Catcher in the Rye.'),
('Suzanne Collins', 'American author of The Hunger Games trilogy.'),
('Dan Brown', 'American author of thriller novels including The Da Vinci Code.'),
('Khaled Hosseini', 'Afghan-American novelist and physician.'),
('John Green', 'American author of young adult fiction.'),
('Markus Zusak', 'Australian writer known for The Book Thief.');

-- Insert 20 Books
INSERT INTO Books (ISBN, title, price, quantity_in_stock) VALUES
('9780439708180', 'Harry Potter and the Sorcerer''s Stone', 12.99, 50),
('9780451524935', '1984', 14.99, 45),
('9780743273565', 'The Great Gatsby', 10.99, 60),
('9780060935467', 'To Kill a Mockingbird', 13.99, 40),
('9780547928227', 'The Hobbit', 15.99, 35),
('9780141439518', 'Pride and Prejudice', 11.99, 55),
('9780060114183 ', 'One Hundred Years of Solitude', 16.99, 30),
('9780062316110', 'Sapiens: A Brief History of Humankind', 18.99, 42),
('9781524763138', 'Becoming', 19.99, 38),
('9780399590504', 'Educated: A Memoir', 17.99, 33),
('9780439064873', 'Harry Potter and the Chamber of Secrets', 12.99, 48),
('9780547928203', 'The Lord of the Rings', 22.99, 28),
('9781501175466', 'It', 16.99, 25),
('9780062073488', 'And Then There Were None', 13.99, 37),
('9780684830490', 'The Old Man and the Sea', 12.99, 44),
('9780385490818', 'The Handmaid''s Tale', 14.99, 52),
('9780316769174', 'The Catcher in the Rye', 13.99, 41),
('9780439023528', 'The Hunger Games', 14.99, 46),
('9780307474278', 'The Da Vinci Code', 15.99, 39),
('9781594631931', 'The Kite Runner', 14.99, 36);

-- Insert 20 BookAuthors (connecting books to authors)
INSERT INTO BookAuthors (ISBN, author_id) VALUES
('9780439708180', 1),  -- Harry Potter 1 by J.K. Rowling
('9780439064873', 1),  -- Harry Potter 2 by J.K. Rowling
('9780451524935', 2),  -- 1984 by George Orwell
('9780743273565', 3),  -- The Great Gatsby by F. Scott Fitzgerald
('9780060935467', 4),  -- To Kill a Mockingbird by Harper Lee
('9780547928227', 5),  -- The Hobbit by J.R.R. Tolkien
('9780547928203', 5),  -- LOTR by J.R.R. Tolkien
('9780141439518', 6),  -- Pride and Prejudice by Jane Austen
('9780307474278', 7),  -- One Hundred Years by García Márquez
('9780062316110', 8),  -- Sapiens by Yuval Noah Harari
('9781524763138', 9),  -- Becoming by Michelle Obama
('9780399590504', 10), -- Educated by Tara Westover
('9781501175466', 11), -- It by Stephen King
('9780062073488', 12), -- And Then There Were None by Agatha Christie
('9780684830490', 13), -- The Old Man and the Sea by Ernest Hemingway
('9780385490818', 14), -- The Handmaid's Tale by Margaret Atwood
('9780316769174', 15), -- The Catcher in the Rye by J.D. Salinger
('9780439023528', 16), -- The Hunger Games by Suzanne Collins
('9780307474278', 17), -- The Da Vinci Code by Dan Brown
('9781594631931', 18); -- The Kite Runner by Khaled Hosseini

-- Insert 20 Customers
INSERT INTO Customers (name, email, password_hash, address) VALUES
('Alice Johnson', 'alice.johnson@email.com', '$2a$10$abcdefghijklmnopqrstuv', '123 Oak Street, San Jose, CA 95112'),
('Bob Smith', 'bob.smith@email.com', '$2a$10$wxyzabcdefghijklmnopqr', '456 Maple Avenue, San Francisco, CA 94102'),
('Carol Williams', 'carol.w@email.com', '$2a$10$lmnopqrstuvwxyzabcdefg', '789 Pine Road, Los Angeles, CA 90001'),
('David Brown', 'david.brown@email.com', '$2a$10$hijklmnopqrstuvwxyzabc', '321 Elm Boulevard, San Diego, CA 92101'),
('Emma Davis', 'emma.davis@email.com', '$2a$10$defghijklmnopqrstuvwxy', '654 Cedar Lane, Sacramento, CA 95814'),
('Frank Miller', 'frank.miller@email.com', '$2a$10$abcdefghijklmnopqrstuv', '987 Birch Drive, Oakland, CA 94601'),
('Grace Lee', 'grace.lee@email.com', '$2a$10$wxyzabcdefghijklmnopqr', '246 Willow Court, Berkeley, CA 94704'),
('Henry Taylor', 'henry.taylor@email.com', '$2a$10$lmnopqrstuvwxyzabcdefg', '135 Spruce Avenue, Fresno, CA 93701'),
('Iris Anderson', 'iris.anderson@email.com', '$2a$10$hijklmnopqrstuvwxyzabc', '864 Redwood Street, Pasadena, CA 91101'),
('Jack Wilson', 'jack.wilson@email.com', '$2a$10$defghijklmnopqrstuvwxy', '579 Cypress Lane, Santa Clara, CA 95050'),
('Kate Martinez', 'kate.martinez@email.com', '$2a$10$abcdefghijklmnopqrstuv', '753 Walnut Way, Sunnyvale, CA 94086'),
('Liam Garcia', 'liam.garcia@email.com', '$2a$10$wxyzabcdefghijklmnopqr', '159 Hickory Place, Mountain View, CA 94040'),
('Mia Rodriguez', 'mia.rodriguez@email.com', '$2a$10$lmnopqrstuvwxyzabcdefg', '357 Chestnut Road, Palo Alto, CA 94301'),
('Noah Martinez', 'noah.martinez@email.com', '$2a$10$hijklmnopqrstuvwxyzabc', '951 Poplar Street, Cupertino, CA 95014'),
('Olivia Hernandez', 'olivia.hernandez@email.com', '$2a$10$defghijklmnopqrstuvwxy', '246 Magnolia Drive, Milpitas, CA 95035'),
('Peter Lopez', 'peter.lopez@email.com', '$2a$10$abcdefghijklmnopqrstuv', '864 Sycamore Avenue, Santa Cruz, CA 95060'),
('Quinn Gonzalez', 'quinn.gonzalez@email.com', '$2a$10$wxyzabcdefghijklmnopqr', '753 Ash Boulevard, San Mateo, CA 94401'),
('Ruby Perez', 'ruby.perez@email.com', '$2a$10$lmnopqrstuvwxyzabcdefg', '159 Beech Lane, Redwood City, CA 94061'),
('Sam Torres', 'sam.torres@email.com', '$2a$10$hijklmnopqrstuvwxyzabc', '357 Dogwood Court, Fremont, CA 94536'),
('Tina Rivera', 'tina.rivera@email.com', '$2a$10$defghijklmnopqrstuvwxy', '951 Sequoia Way, Hayward, CA 94541');

-- Insert 20 Reviews
INSERT INTO Reviews (ISBN, customer_id, rating, review_text, review_date) VALUES
('9780439708180', 1, 5, 'Absolutely magical! A timeless classic that both kids and adults will love.', '2024-10-15 14:30:00'),
('9780439708180', 2, 5, 'Best book series ever! Started a whole generation of readers.', '2024-10-20 09:15:00'),
('9780451524935', 3, 5, 'Disturbingly prophetic. A must-read in today''s world.', '2024-11-01 16:45:00'),
('9780743273565', 1, 4, 'Beautiful prose and a fascinating look at the American Dream.', '2024-10-25 11:20:00'),
('9780060935467', 4, 5, 'A powerful story about justice, racism, and moral courage.', '2024-11-05 13:10:00'),
('9780547928227', 2, 5, 'An adventure that never gets old. Perfect for all ages.', '2024-10-18 10:30:00'),
('9780062316110', 5, 5, 'Mind-blowing perspective on human history. Changed how I see the world.', '2024-11-10 15:00:00'),
('9781524763138', 3, 5, 'Inspiring and honest. Michelle Obama''s story is truly remarkable.', '2024-11-08 12:40:00'),
('9780399590504', 4, 5, 'Incredible memoir about the power of education. Couldn''t put it down.', '2024-11-12 17:25:00'),
('9780141439518', 5, 4, 'Witty and charming. Jane Austen''s best work in my opinion.', '2024-10-30 14:15:00'),
('9781501175466', 6, 5, 'Terrifying and brilliant. Stephen King at his best!', '2024-11-02 15:20:00'),
('9780062073488', 7, 5, 'The queen of mystery delivers again. Couldn''t guess the ending!', '2024-10-28 11:45:00'),
('9780684830490', 8, 4, 'A short but powerful tale about determination and dignity.', '2024-11-06 10:15:00'),
('9780385490818', 9, 5, 'Chilling and relevant. More important now than ever.', '2024-11-09 14:30:00'),
('9780316769174', 10, 4, 'Classic coming-of-age story. Holden is unforgettable.', '2024-10-22 16:00:00'),
('9780439023528', 11, 5, 'Couldn''t put it down! Thrilling from start to finish.', '2024-11-11 13:20:00'),
('9780307474278', 12, 4, 'Great thriller with fascinating historical puzzles.', '2024-10-26 09:30:00'),
('9781594631931', 13, 5, 'Heartbreaking and beautiful. A story of redemption.', '2024-11-13 12:10:00'),
('9780547928203', 14, 5, 'Epic fantasy at its finest. A masterpiece of world-building.', '2024-10-19 15:45:00'),
('9780439064873', 15, 5, 'Just as good as the first! The series keeps getting better.', '2024-11-07 11:00:00');

-- Insert 20 Orders
INSERT INTO Orders (customer_id, order_date, total_amount, status) VALUES
(1, '2024-11-01 10:30:00', 39.97, 'Delivered'),
(2, '2024-11-03 14:20:00', 28.98, 'Delivered'),
(3, '2024-11-05 09:15:00', 52.96, 'Shipped'),
(4, '2024-11-10 16:45:00', 31.98, 'Processing'),
(5, '2024-11-14 11:00:00', 45.97, 'Pending'),
(1, '2024-11-15 13:30:00', 22.99, 'Pending'),
(6, '2024-11-02 08:45:00', 29.98, 'Delivered'),
(7, '2024-11-04 12:15:00', 38.97, 'Delivered'),
(8, '2024-11-06 15:30:00', 27.98, 'Shipped'),
(9, '2024-11-08 10:20:00', 33.98, 'Shipped'),
(10, '2024-11-09 14:00:00', 25.98, 'Processing'),
(11, '2024-11-11 09:30:00', 41.97, 'Processing'),
(12, '2024-11-12 16:15:00', 30.98, 'Pending'),
(13, '2024-11-13 11:45:00', 32.98, 'Pending'),
(14, '2024-11-14 13:00:00', 45.98, 'Pending'),
(15, '2024-11-15 10:00:00', 25.98, 'Pending'),
(16, '2024-11-07 14:30:00', 28.98, 'Delivered'),
(17, '2024-11-08 09:00:00', 42.97, 'Shipped'),
(18, '2024-11-09 16:20:00', 29.98, 'Processing'),
(19, '2024-11-10 12:30:00', 37.97, 'Processing');

-- Insert 20 OrderItems
INSERT INTO OrderItems (order_id, ISBN, quantity, price_at_purchase) VALUES
(1, '9780439708180', 1, 12.99),  -- Order 1
(1, '9780439064873', 1, 12.99),
(1, '9780451524935', 1, 14.99),
(2, '9780547928227', 1, 15.99),  -- Order 2
(2, '9780743273565', 1, 12.99),
(3, '9780062316110', 1, 18.99),  -- Order 3
(3, '9781524763138', 1, 19.99),
(3, '9780451524935', 1, 13.98),
(4, '9780060935467', 1, 13.99),  -- Order 4
(4, '9780399590504', 1, 17.99),
(5, '9780141439518', 1, 11.99),  -- Order 5
(5, '9780307474278', 1, 16.99),
(5, '9780547928203', 1, 16.99),
(6, '9780547928203', 1, 22.99),  -- Order 6
(7, '9781501175466', 1, 16.99),  -- Order 7
(7, '9780062073488', 1, 12.99),
(8, '9780684830490', 1, 12.99),  -- Order 8
(8, '9780385490818', 1, 14.99),
(8, '9780316769174', 1, 10.99),
(9, '9780439023528', 1, 14.99);  -- Order 9