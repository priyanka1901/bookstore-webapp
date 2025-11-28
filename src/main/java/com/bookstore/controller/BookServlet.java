package com.bookstore.controller;

import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession; // Import HttpSession
import java.io.IOException;
import java.util.List;

import com.bookstore.dao.AuthorDAO; 
import com.bookstore.dao.BookDAO;
import com.bookstore.dao.ReviewDAO; // Import ReviewDAO
import com.bookstore.model.Author;
import com.bookstore.model.Book;
import com.bookstore.model.Review; // Import Review model

/**
 * Servlet controller for all Book-related C.R.U.D. and Search actions.
 * This servlet handles multiple URL patterns.
 */
@WebServlet(urlPatterns = {
    "/home",            // Main page (list books or welcome message)
    "/new",         // Show "add book" form
    "/insert",      // Handle "add book" form submission
    "/edit",        // Show "edit book" form
    "/update",      // Handle "edit book" form submission
    "/delete",      // Handle delete book action
    "/viewBook"     // Show the book details page
})
public class BookServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    private BookDAO bookDAO;
    private AuthorDAO authorDAO;
    private ReviewDAO reviewDAO; // Add ReviewDAO

    public void init() {
        bookDAO = new BookDAO();
        authorDAO = new AuthorDAO();
        reviewDAO = new ReviewDAO(); // Initialize ReviewDAO
    }

    /**
     * Handles POST requests, which are for C.R.U.D. actions (insert/update).
     */
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // We use request.getServletPath() to get the clean URL pattern (e.g., "/insert")
        String action = request.getServletPath();
        System.out.println("[BookServlet] (doPost) Action: " + action);
        
        try {
            switch (action) {
                case "/insert":
                    insertBook(request, response);
                    break;
                case "/update":
                    updateBook(request, response);
                    break;
            }
        } catch (Exception e) {
            throw new ServletException(e);
        }
    }

    /**
     * Handles GET requests, which are for showing pages or simple actions (delete).
     */
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // request.getServletPath() is more reliable than getParameter("action") for this design.
        // For the home page "/", it will be "/".
        // For search, we will look for a parameter.
        
        String action = request.getServletPath();
        
        // Check for search action separately
        String searchAction = request.getParameter("action");
        if (searchAction != null && searchAction.equals("search")) {
            action = "search";
        }
        
        System.out.println("[BookServlet] (doGet) Action: " + action);

        try {
            switch (action) {
                case "/new":
                    showNewForm(request, response);
                    break;
                case "/edit":
                    showEditForm(request, response);
                    break;
                case "/delete":
                    deleteBook(request, response);
                    break;
                case "/viewBook":
                    viewBookDetails(request, response);
                    break;
                case "search":
                case "/":
                default:
                    // Both the root URL ("/") and search will call listBooks
                    listBooks(request, response);
                    break;
            }
        } catch (Exception e) {
            throw new ServletException(e);
        }
    }

    // --- C.R.U.D. Action Methods ---

    /**
     * Handles both listing all books AND searching.
     * It checks for a "query" parameter.
     */
    private void listBooks(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String query = request.getParameter("query");
        List<Book> bookList;

        if (query != null && !query.trim().isEmpty()) {
            // This is a search
            System.out.println("[BookServlet] Executing action: searchBooks for query: " + query);
            bookList = bookDAO.searchBooks(query);
        } else {
            // This is a normal "list all"
            System.out.println("[BookServlet] Executing action: listBooks");
            bookList = bookDAO.listAllBooks();
        }
        
        request.setAttribute("bookList", bookList);
        RequestDispatcher dispatcher = request.getRequestDispatcher("book-list.jsp");
        dispatcher.forward(request, response);
    }
    
    /**
     * Shows the book details page.
     * This method needs to fetch BOTH the book, its authors, AND its reviews.
     */
    private void viewBookDetails(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String isbn = request.getParameter("isbn");
        System.out.println("[BookServlet] Executing action: viewBookDetails for ISBN " + isbn);
        
        // 1. Fetch Book & Authors
        Book book = bookDAO.findBookByIsbn(isbn);
        List<Author> authors = authorDAO.getAuthorsForBook(isbn);
        
        // 2. Fetch Reviews & Stats
        List<Review> reviews = reviewDAO.listReviewsForBook(isbn);
        double avgRating = reviewDAO.getAverageRating(isbn);
        int reviewCount = reviewDAO.getReviewCount(isbn);
        
        // 3. Check if current user has a review (for Edit form)
        HttpSession session = request.getSession(false);
        Review userReview = null;
        if (session != null && session.getAttribute("customerId") != null) {
            int customerId = (int) session.getAttribute("customerId");
            userReview = reviewDAO.findReviewByCustomerAndBook(customerId, isbn);
        }
        
        // 4. Set Attributes
        request.setAttribute("book", book);
        request.setAttribute("authors", authors);
        request.setAttribute("reviews", reviews);
        request.setAttribute("avgRating", avgRating);
        request.setAttribute("reviewCount", reviewCount);
        request.setAttribute("userReview", userReview);
        
        RequestDispatcher dispatcher = request.getRequestDispatcher("book-details.jsp");
        dispatcher.forward(request, response);
    }

    /**
     * Forwards to the book-form.jsp for creating a new book.
     */
    private void showNewForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        System.out.println("[BookServlet] Executing action: showNewForm");
        RequestDispatcher dispatcher = request.getRequestDispatcher("book-form.jsp");
        dispatcher.forward(request, response);
    }

    /**
     * Forwards to the book-form.jsp for editing an existing book.
     * It pre-populates the form by finding the book first.
     */
    private void showEditForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        System.out.println("[BookServlet] Executing action: showEditForm");
        String isbn = request.getParameter("isbn");
        Book existingBook = bookDAO.findBookByIsbn(isbn);
        
        request.setAttribute("book", existingBook);
        RequestDispatcher dispatcher = request.getRequestDispatcher("book-form.jsp");
        dispatcher.forward(request, response);
    }

    /**
     * Reads form data and inserts a new book into the database.
     */
    private void insertBook(HttpServletRequest request, HttpServletResponse response)
            throws IOException, ServletException {
        System.out.println("[BookServlet] Executing action: insertBook");

        String isbn = request.getParameter("isbn");
        String title = request.getParameter("title");
        double price = Double.parseDouble(request.getParameter("price"));
        int quantity = Integer.parseInt(request.getParameter("quantity"));

        Book newBook = new Book(isbn, title, price, quantity);
        bookDAO.addBook(newBook);
        
        // Redirect back to the main list page
        response.sendRedirect(request.getContextPath() + "/");
    }

    /**
     * Reads form data and updates an existing book in the database.
     */
    private void updateBook(HttpServletRequest request, HttpServletResponse response)
            throws IOException, ServletException {
        System.out.println("[BookServlet] Executing action: updateBook");
        
        String isbn = request.getParameter("isbn");
        String title = request.getParameter("title");
        double price = Double.parseDouble(request.getParameter("price"));
        int quantity = Integer.parseInt(request.getParameter("quantity"));

        Book bookToUpdate = new Book(isbn, title, price, quantity);
        bookDAO.updateBook(bookToUpdate);
        
        response.sendRedirect(request.getContextPath() + "/");
    }

    /**
    * Deletes a book from the database.
    */
    private void deleteBook(HttpServletRequest request, HttpServletResponse response)
            throws IOException, ServletException {
        System.out.println("[BookServlet] Executing action: deleteBook");
        
        String isbn = request.getParameter("isbn");
        bookDAO.deleteBook(isbn);
        
        response.sendRedirect(request.getContextPath() + "/");
    }
}