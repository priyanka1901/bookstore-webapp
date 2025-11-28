package com.bookstore.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

import com.bookstore.dao.ReviewDAO;
import com.bookstore.model.Review;

@WebServlet("/review")
public class ReviewServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private ReviewDAO reviewDAO;

    public void init() {
        reviewDAO = new ReviewDAO();
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String action = request.getParameter("action");
        if (action == null) {
            response.sendRedirect(request.getContextPath() + "/");
            return;
        }

        // Ensure user is logged in
        HttpSession session = request.getSession(false);
        Integer customerId = (Integer) session.getAttribute("customerId");
        
        if (customerId == null) {
            response.sendRedirect(request.getContextPath() + "/customer?action=showLogin");
            return;
        }

        try {
            switch (action) {
                case "add":
                    addReview(request, response, customerId);
                    break;
                case "edit":
                    editReview(request, response, customerId);
                    break;
                case "delete":
                    deleteReview(request, response, customerId);
                    break;
                default:
                    response.sendRedirect(request.getContextPath() + "/");
                    break;
            }
        } catch (Exception e) {
            throw new ServletException(e);
        }
    }

    private void addReview(HttpServletRequest request, HttpServletResponse response, int customerId)
            throws IOException {
        String isbn = request.getParameter("isbn");
        int rating = Integer.parseInt(request.getParameter("rating"));
        String reviewText = request.getParameter("reviewText");

        Review review = new Review();
        review.setIsbn(isbn);
        review.setCustomerId(customerId);
        review.setRating(rating);
        review.setReviewText(reviewText);

        reviewDAO.addReview(review);
        
        response.sendRedirect(request.getContextPath() + "/viewBook?isbn=" + isbn);
    }

    private void editReview(HttpServletRequest request, HttpServletResponse response, int customerId)
            throws IOException {
        int reviewId = Integer.parseInt(request.getParameter("reviewId"));
        String isbn = request.getParameter("isbn"); // Needed for redirect
        int rating = Integer.parseInt(request.getParameter("rating"));
        String reviewText = request.getParameter("reviewText");

        Review review = new Review();
        review.setReviewId(reviewId);
        review.setCustomerId(customerId); // Security: used in WHERE clause
        review.setRating(rating);
        review.setReviewText(reviewText);

        reviewDAO.updateReview(review);
        
        response.sendRedirect(request.getContextPath() + "/viewBook?isbn=" + isbn);
    }

    private void deleteReview(HttpServletRequest request, HttpServletResponse response, int customerId)
            throws IOException {
        int reviewId = Integer.parseInt(request.getParameter("reviewId"));
        String isbn = request.getParameter("isbn"); // Needed for redirect

        reviewDAO.deleteReview(reviewId, customerId);
        
        response.sendRedirect(request.getContextPath() + "/viewBook?isbn=" + isbn);
    }
}