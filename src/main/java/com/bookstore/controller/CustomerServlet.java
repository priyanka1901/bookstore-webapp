package com.bookstore.controller;

import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

import com.bookstore.dao.CustomerDAO;
import com.bookstore.model.Customer;

/**
 * Servlet controller for Customer-related actions:
 * - Login
 * - Register
 * - Logout
 * - View Account
 */
@WebServlet("/customer") // All customer actions will go through /customer
public class CustomerServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private CustomerDAO customerDAO;

    public void init() {
        customerDAO = new CustomerDAO();
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");
        if (action == null) action = "";
        
        System.out.println("[CustomerServlet] (doPost) Action: " + action);
        
        try {
            switch (action) {
                case "login":
                    loginCustomer(request, response);
                    break;
                case "register":
                    registerCustomer(request, response);
                    break;
                default:
                    response.sendRedirect(request.getContextPath() + "/");
                    break;
            }
        } catch (Exception e) {
            throw new ServletException(e);
        }
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");
        if (action == null) action = "";
        
        System.out.println("[CustomerServlet] (doGet) Action: " + action);

        try {
            switch (action) {
                case "showLogin":
                    showLoginPage(request, response, null, null);
                    break;
                case "showRegister":
                    showRegisterPage(request, response, null);
                    break;
                case "logout":
                    logoutCustomer(request, response);
                    break;
                default:
                    response.sendRedirect(request.getContextPath() + "/");
                    break;
            }
        } catch (Exception e) {
            throw new ServletException(e);
        }
    }

    // --- Action Methods ---

    private void showLoginPage(HttpServletRequest request, HttpServletResponse response, String message, String error) 
            throws ServletException, IOException {
        request.setAttribute("message", message); // For success messages (like "Registration successful!")
        request.setAttribute("error", error);     // For error messages (like "Invalid login")
        RequestDispatcher dispatcher = request.getRequestDispatcher("login.jsp");
        dispatcher.forward(request, response);
    }
    
    private void showRegisterPage(HttpServletRequest request, HttpServletResponse response, String error) 
            throws ServletException, IOException {
        request.setAttribute("error", error); // For errors (like "Email already exists")
        RequestDispatcher dispatcher = request.getRequestDispatcher("register.jsp");
        dispatcher.forward(request, response);
    }

    private void loginCustomer(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String email = request.getParameter("email");
        String password = request.getParameter("password");

        Customer customer = customerDAO.checkLogin(email, password);

        if (customer != null) {
            // Login successful!
            System.out.println("[CustomerServlet] Login successful for: " + customer.getEmail());
            HttpSession session = request.getSession();
            session.setAttribute("customerName", customer.getName());
            session.setAttribute("customerId", customer.getCustomerId());
            
            // *** THIS IS THE KEY FOR ADMIN vs CUSTOMER ***
            // We can assign a "role" based on email or a database field.
            // For now, let's hardcode one email as the admin.
            if (customer.getEmail().equals("admin@bookstore.com")) {
                session.setAttribute("userRole", "admin");
            } else {
                session.setAttribute("userRole", "customer");
            }
            
            response.sendRedirect(request.getContextPath() + "/"); // Redirect to home page
            
        } else {
            // Login failed
            System.out.println("[CustomerServlet] Login failed for: " + email);
            showLoginPage(request, response, null, "Invalid email or password. Please try again.");
        }
    }

    private void registerCustomer(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String name = request.getParameter("name");
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String address = request.getParameter("address");

        Customer newCustomer = new Customer(name, email, password, address);

        boolean isRegistered = customerDAO.registerCustomer(newCustomer);

        if (isRegistered) {
            // Registration successful! Send to login page with a success message.
            System.out.println("[CustomerServlet] Registration successful for: " + email);
            showLoginPage(request, response, "Registration successful! Please login.", null);
        } else {
            // Registration failed (probably because email already exists)
            System.out.println("[CustomerServlet] Registration failed for: " + email);
            showRegisterPage(request, response, "Registration failed. An account with this email already exists.");
        }
    }
    
    private void logoutCustomer(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        HttpSession session = request.getSession(false); // Get session, but don't create a new one
        if (session != null) {
            session.invalidate(); // Invalidate the session, logging the user out
        }
        System.out.println("[CustomerServlet] User logged out.");
        response.sendRedirect(request.getContextPath() + "/customer?action=showLogin"); // Redirect to login page
    }
}