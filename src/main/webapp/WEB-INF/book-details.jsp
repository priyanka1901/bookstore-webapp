<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title><c:out value="${book.title}" /></title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <style>
        .details-container {
            max-width: 800px;
            margin: 20px auto;
            padding: 20px;
            background: #fff;
            border-radius: 8px;
            box-shadow: 0 4px 10px rgba(0, 0, 0, 0.1);
            text-align: left;
        }
        .details-container h1 {
            text-align: center;
        }
        .details-container ul {
            list-style-type: none;
            padding-left: 0;
        }
        .details-container li {
            font-size: 1.1rem;
            line-height: 1.6;
        }
        .back-link {
            display: inline-block;
            margin-top: 20px;
            color: #007bff;
            text-decoration: none;
        }
        .back-link:hover {
            text-decoration: underline;
        }
    </style>
</head>
<body>

    <div class="home-container">
        <!-- We can reuse the same navigation bar from the other pages -->
        <nav>
            <ul>
                <c:if test="${sessionScope.userRole == 'admin'}">
                    <li><a href="${pageContext.request.contextPath}/">Manage Books</a></li>
                    <li><a href="${pageContext.request.contextPath}/authorList">Manage Authors</a></li>
                </c:if>
                <li><a href="#">Search Books</a></li>
                <c:if test="${empty sessionScope.customerName}">
                    <li><a href="${pageContext.request.contextPath}/customer?action=showLogin">Customer Login</a></li>
                </c:if>
                <c:if test="${not empty sessionScope.customerName}">
                    <li><a href="${pageContext.request.contextPath}/customer?action=logout">Logout (<c:out value="${sessionScope.customerName}" />)</a></li>
                </c:if>
            </ul>
        </nav>
    </div>

    <div class="details-container">
        
        <!-- Check if the book was found -->
        <c:if test="${empty book}">
            <h1>Book Not Found</h1>
            <p>The book you requested could not be found.</p>
        </c:if>
        
        <!-- If book is found, display its details -->
        <c:if test="${not empty book}">
            <h1><c:out value="${book.title}" /></h1>
            
            <h3>By:
                <c:forEach var="author" items="${authors}" varStatus="status">
                    <c:out value="${author.authorName}" />
                    <c:if test="${not status.last}">, </c:if>
                </c:forEach>
            </h3>
            
            <ul>
                <li><strong>ISBN:</strong> <c:out value="${book.isbn}" /></li>
                <li><strong>Price:</strong> $<c:out value="${book.price}" /></li>
                <li><strong>Quantity in Stock:</strong> <c:out value="${book.quantityInStock}" /></li>
            </ul>
            
            <!-- This is where we will add the "Add to Cart" and "Write Review" buttons later -->
            
        </c:if>
        
        <a href="${pageContext.request.contextPath}/" class="back-link">&larr; Back to Book List</a>
        
    </div>

</body>
</html>