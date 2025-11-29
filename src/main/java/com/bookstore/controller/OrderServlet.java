package com.bookstore.controller;

import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;

import com.bookstore.dao.OrderDAO;
import com.bookstore.model.Order;
import com.bookstore.model.OrderItem;

/**
 * Servlet controller for Shopping Cart (Orders) actions.
 */
@WebServlet("/cart")
public class OrderServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private OrderDAO orderDAO;

    public void init() {
        orderDAO = new OrderDAO();
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");
        if (action == null) action = "";
        
        System.out.println("[OrderServlet] (doPost) Action: " + action);

        try {
            switch (action) {
                case "add":
                    addToCart(request, response);
                    break;
                // We will add "update" case later
                default:
                    doGet(request, response);
                    break;
            }
        } catch (Exception e) {
            throw new ServletException(e);
        }
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");
        if (action == null) action = "view"; // Default action is to view the cart
        
        System.out.println("[OrderServlet] (doGet) Action: " + action);

        try {
            switch (action) {
                case "view":
                    viewCart(request, response);
                    break;
                case "remove":
                    removeFromCart(request, response);
                    break;
                case "checkout":
                    checkout(request, response);
                    break;
                default:
                    viewCart(request, response);
                    break;
            }
        } catch (Exception e) {
            throw new ServletException(e);
        }
    }

    // --- Action Methods ---

    private void viewCart(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        Integer customerId = (Integer) session.getAttribute("customerId");

        if (customerId == null) {
            response.sendRedirect(request.getContextPath() + "/customer?action=showLogin");
            return;
        }

        System.out.println("[OrderServlet] Executing: viewCart for customer " + customerId);
        
        Order cart = orderDAO.findOrCreateCart(customerId);
        List<OrderItem> cartItems = orderDAO.getCartItems(cart.getOrderId());
        
        request.setAttribute("cart", cart);
        request.setAttribute("cartItems", cartItems);
        
        RequestDispatcher dispatcher = request.getRequestDispatcher("cart.jsp");
        dispatcher.forward(request, response);
    }

    private void addToCart(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        Integer customerId = (Integer) session.getAttribute("customerId");

        if (customerId == null) {
            response.sendRedirect(request.getContextPath() + "/customer?action=showLogin");
            return;
        }
        
        String isbn = request.getParameter("isbn");
        double price = Double.parseDouble(request.getParameter("price"));
        
        System.out.println("[OrderServlet] Executing: addToCart for customer " + customerId + ", ISBN: " + isbn);

        boolean success = orderDAO.addBookToCart(customerId, isbn, price);
        
        if (success) {
            response.sendRedirect(request.getContextPath() + "/");
        } else {
            System.out.println("[OrderServlet] Add to cart FAILED (out of stock).");
            response.sendRedirect(request.getContextPath() + "/viewBook?isbn=" + isbn + "&error=stock");
        }
    }
    
    private void removeFromCart(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        int orderItemId = Integer.parseInt(request.getParameter("id"));
        
        System.out.println("[OrderServlet] Executing: removeFromCart for item " + orderItemId);

        orderDAO.removeItemFromCart(orderItemId);
        
        response.sendRedirect(request.getContextPath() + "/cart?action=view");
    }
    
    /**
     * Handles the final checkout process.
     */
    private void checkout(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        Integer customerId = (Integer) session.getAttribute("customerId");

        if (customerId == null) {
            response.sendRedirect(request.getContextPath() + "/customer?action=showLogin");
            return;
        }
        
        System.out.println("[OrderServlet] Executing: checkout for customer " + customerId);
        
        // Find the user's cart
        Order cart = orderDAO.findOrCreateCart(customerId);
        
        // Attempt to place the order
        boolean success = orderDAO.placeOrder(cart.getOrderId());
        
        if (success) {
            // Success! Show confirmation page.
            System.out.println("[OrderServlet] Checkout SUCCESS");
            request.setAttribute("orderId", cart.getOrderId());
            RequestDispatcher dispatcher = request.getRequestDispatcher("order-confirmation.jsp");
            dispatcher.forward(request, response);
        } else {
            // Failure (e.g., out of stock)
            System.out.println("[OrderServlet] Checkout FAILED");
            // Redirect back to the cart with an error message
            response.sendRedirect(request.getContextPath() + "/cart?action=view&error=checkout_failed");
        }
    }
}
