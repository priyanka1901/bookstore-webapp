# Online Bookstore Web Application

A Java-based web application for an online bookstore, featuring customer registration, book browsing, reviews, and shopping cart functionality.

## Technologies Used
- **Backend:** Java Servlet API, JSP, JDBC
- **Database:** MySQL 8.0
- **Build Tool:** Maven
- **Server:** Apache Tomcat 10.1 (Jakarta EE 10)
- **Frontend:** HTML, CSS, JSTL

## Prerequisites
- Linux (Ubuntu/Debian recommended for the install script)
- Internet connection (to download dependencies)

## Quick Start (One-Step Installation)

We have provided an automated script that sets up Java 11, MySQL, Maven, and Tomcat, and then builds and deploys the application.

1.  **Clone the repository:**
    ```bash
    git clone <your-repo-url>
    cd bookstore-webapp
    ```

2.  **Run the installation script:**
    ```bash
    chmod +x install.sh
    ./install.sh
    ```

3.  **Access the Application:**
    Open your browser and go to: **[http://localhost:8080/bookstore-webapp/](http://localhost:8080/bookstore-webapp/)**

## Manual Setup (If not using the script)

1.  **Database:**
    - Ensure MySQL is running.
    - Create the database `bookstore_db`.
    - Run the `schema.sql` script to create tables and data.
    - Ensure root user password is `mysql_pass`.

2.  **Build:**
    - Run `mvn clean install` in the project root.

3.  **Run:**
    - Deploy the generated `target/bookstore-webapp.war` to your Tomcat 10 `webapps` folder.
    - Ensure your Tomcat is running with **Java 11**.

## Features
- **User Accounts:** Register and Login.
- **Book Catalog:** Browse books and view details.
- **Search:** Search for books by Title, ISBN, or Author.
- **Reviews:** Add, Edit, and Delete reviews for books.
- **Shopping Cart:** Add books to cart and checkout.
- **Admin:** Special access via `admin@bookstore.com`.

## Project Structure
- `src/main/java`: Java source code (Models, DAOs, Servlets).
- `src/main/webapp`: JSP files, CSS, and web configuration.
- `schema.sql`: Database schema and sample data.
- `pom.xml`: Maven dependencies.
