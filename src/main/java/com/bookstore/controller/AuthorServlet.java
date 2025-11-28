package com.bookstore.controller;

import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

import com.bookstore.dao.AuthorDAO; // We need to import the new DAO
import com.bookstore.model.Author; // We need to import the new Model

/**
 * Servlet controller for all Author-related C.R.U.D. actions.
 */
@WebServlet(urlPatterns = {
    "/authorList", 
    "/newAuthor", 
    "/insertAuthor", 
    "/editAuthor", 
    "/updateAuthor", 
    "/deleteAuthor"
})
public class AuthorServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private AuthorDAO authorDAO;

    public void init() {
        authorDAO = new AuthorDAO();
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String action = request.getServletPath();
        System.out.println("[AuthorServlet] (doPost) Received request for action: " + action);
        
        try {
            switch (action) {
                case "/insertAuthor":
                    insertAuthor(request, response);
                    break;
                case "/updateAuthor":
                    updateAuthor(request, response);
                    break;
            }
        } catch (Exception e) {
            throw new ServletException(e);
        }
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String action = request.getServletPath();
        System.out.println("[AuthorServlet] (doGet) Received request for action: " + action);

        try {
            switch (action) {
                case "/newAuthor":
                    showNewForm(request, response);
                    break;
                case "/editAuthor":
                    showEditForm(request, response);
                    break;
                case "/deleteAuthor":
                    deleteAuthor(request, response);
                    break;
                case "/authorList":
                default:
                    listAuthors(request, response);
                    break;
            }
        } catch (Exception e) {
            throw new ServletException(e);
        }
    }

    // --- C.R.U.D. Action Methods ---

    private void listAuthors(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        System.out.println("[AuthorServlet] Executing action: listAuthors");
        List<Author> authorList = authorDAO.listAllAuthors();
        request.setAttribute("authorList", authorList);
        RequestDispatcher dispatcher = request.getRequestDispatcher("author-list.jsp");
        dispatcher.forward(request, response);
    }

    private void showNewForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        System.out.println("[AuthorServlet] Executing action: showNewForm");
        RequestDispatcher dispatcher = request.getRequestDispatcher("author-form.jsp");
        dispatcher.forward(request, response);
    }

    private void showEditForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        System.out.println("[AuthorServlet] Executing action: showEditForm");
        int authorId = Integer.parseInt(request.getParameter("id"));
        Author existingAuthor = authorDAO.findAuthorById(authorId);
        
        request.setAttribute("author", existingAuthor);
        RequestDispatcher dispatcher = request.getRequestDispatcher("author-form.jsp");
        dispatcher.forward(request, response);
    }

    private void insertAuthor(HttpServletRequest request, HttpServletResponse response)
            throws IOException, ServletException {
        System.out.println("[AuthorServlet] Executing action: insertAuthor");

        String authorName = request.getParameter("authorName");
        String bio = request.getParameter("bio");

        Author newAuthor = new Author(authorName, bio);
        authorDAO.addAuthor(newAuthor);
        
        response.sendRedirect(request.getContextPath() + "/authorList");
    }

    private void updateAuthor(HttpServletRequest request, HttpServletResponse response)
            throws IOException, ServletException {
        System.out.println("[AuthorServlet] Executing action: updateAuthor");
        
        int authorId = Integer.parseInt(request.getParameter("authorId"));
        String authorName = request.getParameter("authorName");
        String bio = request.getParameter("bio");

        Author authorToUpdate = new Author(authorId, authorName, bio);
        authorDAO.updateAuthor(authorToUpdate);
        
        response.sendRedirect(request.getContextPath() + "/authorList");
    }

    private void deleteAuthor(HttpServletRequest request, HttpServletResponse response)
            throws IOException, ServletException {
        System.out.println("[AuthorServlet] Executing action: deleteAuthor");
        
        int authorId = Integer.parseInt(request.getParameter("id"));
        
        if (authorDAO.hasBooks(authorId)) {
            request.setAttribute("errorMessage", "Cannot delete author. They have associated books in the database.");
            listAuthors(request, response);
            return;
        }

        authorDAO.deleteAuthor(authorId);
        
        response.sendRedirect(request.getContextPath() + "/authorList");
    }
}