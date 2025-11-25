<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Book Form</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    
    <style>
        .auth-container {
            max-width: 500px; /* Make it match the login/author form width */
            margin-top: 30px;
        }
    </style>
    </head>
<body>
    <%@ include file="common/navigation.jspf" %>
    
    <div class="auth-container">
            
        <c:if test="${book == null}">
            <h1>Add New Book</h1>
            <form action="${pageContext.request.contextPath}/insert" method="post">
        </c:if>
        <c:if test="${book != null}">
            <h1>Edit Book</h1>
            <form action="${pageContext.request.contextPath}/update" method="post">
        </c:if>

            <label for="isbn">ISBN</label>
            <input type="text" name="isbn" value="<c:out value='${book.isbn}' />"
                   ${book != null ? 'readonly' : ''} required>
            
            <label for="title">Title</label>
            <input type="text" name="title" value="<c:out value='${book.title}' />" required>
            
            <label for="price">Price</label>
            <input type="number" name="price" value="<c:out value='${book.price}' />"
                   step="0.01" min="0" required>
            
            <label for="quantity">Quantity in Stock</label>
            <input type="number" name="quantity" value="<c:out value='${book.quantityInStock}' />"
                   step="1" min="0" required>
            
            <c:if test="${book == null}">
                <button type="submit">Save Book</button>
            </c:if>
            <c:if test="${book != null}">
                <button type="submit">Update Book</button>
            </c:if>
            
        </form>
        
        <a href="${pageContext.request.contextPath}/" class="home-link" style="text-align: center; display: block;">Back to Book List</a>
        
    </div> </body>
</html>