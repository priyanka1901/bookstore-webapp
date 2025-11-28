<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Manage Books - Online Bookstore</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    
    <style>
        /* [Reusing table styles] */
        table {
            width: 80%;
            border-collapse: collapse;
            margin-top: 20px;
            box-shadow: 0 2px 5px rgba(0,0,0,0.1);
        }
        th, td {
            padding: 12px;
            border: 1px solid #ddd;
            text-align: left;
        }
        th {
            background-color: #007bff;
            color: white;
        }
        tr:nth-child(even) {
            background-color: #f9f9f9;
        }
        .actions-cell {
            display: flex;
            gap: 5px;
        }
        .edit-link {
            text-decoration: none;
            padding: 4px 8px;
            border-radius: 4px;
            background-color: #ffc107; /* Yellow */
            color: black;
        }
        .delete-link {
            text-decoration: none;
            padding: 4px 8px;
            border-radius: 4px;
            background-color: #dc3545; /* Red */
            color: white;
        }
        .add-button {
            text-decoration: none;
            padding: 8px 15px;
            border-radius: 5px;
            font-size: 1.1rem;
            background-color: #28a745; /* Green */
            color: white;
            display: inline-block;
            margin-top: 20px;
        }
    </style>
</head>
<body>

    <div class="home-container">

        <!-- Include the centralized navigation bar -->
        <%@ include file="common/navigation.jspf" %>
        
        <!-- *** THIS IS THE SECURITY FIX *** -->
        <!-- 
            We will only show the book list IF a user is logged in.
            Guests (not logged in) will see a welcome message instead.
        -->
        <c:if test="${empty sessionScope.customerName}">
            <div class="auth-container" style="margin-top: 30px;">
                <h1>Welcome to Priyanka & Susan's Online Bookstore</h1>
                <p>Please log in or register to browse our selection.</p>
                <a href="${pageContext.request.contextPath}/customer?action=showLogin" class="add-button" style="background-color: #007bff;">Login / Register</a>
            </div>
        </c:if>
        
        <c:if test="${not empty sessionScope.customerName}">
            
            <!-- Welcome Message -->
            <div style="text-align: center; margin-bottom: 10px;">
                <h1 style="font-size: 2.5rem; color: #007bff; margin-bottom: 0;">Welcome, <c:out value="${sessionScope.customerName}" />!</h1>
            </div>

            <!-- Show a different title based on search -->
            <c:if test="${not empty param.query}">
                <h2 style="margin-top: 10px;">Search Results for: "<c:out value="${param.query}" />"</h2>
            </c:if>
            <c:if test="${empty param.query}">
                <h2 style="margin-top: 10px;">Book Management</h2>
            </c:if>
    
            <!-- "Add New Book" button -->
            <c:if test="${sessionScope.userRole == 'admin'}">
                <a href="${pageContext.request.contextPath}/new" class="add-button">+ Add New Book</a>
            </c:if>
    
            <c:if test="${empty bookList}">
                <p style="margin-top: 20px;">No books found.</p>
            </c:if>
        
            <c:if test="${not empty bookList}">
                <table>
                    <thead>
                        <tr>
                            <th>ISBN</th>
                            <th>Title</th>
                            <th>Price</th>
                            <th>Quantity in Stock</th>
                            
                            <!-- Only show Actions column for Admin -->
                            <c:if test="${sessionScope.userRole == 'admin'}">
                                <th>Actions</th>
                            </c:if>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="book" items="${bookList}">
                            <tr>
                                <td><c:out value="${book.isbn}" /></td>
                                
                                <!-- Make title a link for everyone -->
                                <td>
                                    <a href="${pageContext.request.contextPath}/viewBook?isbn=${book.isbn}">
                                        <c:out value="${book.title}" />
                                    </a>
                                </td>
                                
                                <td>$<c:out value="${book.price}" /></td>
                                <td><c:out value="${book.quantityInStock}" /></td>
                                
                                <!-- Only show Actions links for Admin -->
                                <c:if test="${sessionScope.userRole == 'admin'}">
                                    <td class="actions-cell">
                                        <a href="${pageContext.request.contextPath}/edit?isbn=${book.isbn}" class="edit-link">Edit</a>
                                        <a href="${pageContext.request.contextPath}/delete?isbn=${book.isbn}" class="delete-link" 
                                           onclick="return confirm('Are you sure you want to delete this book? This will also remove it from any pending customer carts.')">Delete</a>
                                    </td>
                                </c:if>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </c:if>
        
        </c:if> <!-- End of "is logged in" check -->
        <!-- *** END OF SECURITY FIX *** -->

    </div> <!-- End of .home-container -->

</body>
</html>