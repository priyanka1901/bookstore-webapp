<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Author Form</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    
    <style>
        .auth-container {
            max-width: 500px; 
            margin-top: 30px;
            /* text-align: left; is handled by labels */
        }
    </style>
    </head>
<body>
    <%@ include file="common/navigation.jspf" %>
    
    <div class="auth-container">
            
        <c:if test="${author == null}">
            <h1>Add New Author</h1>
            <form action="${pageContext.request.contextPath}/insertAuthor" method="post">
        </c:if>
        <c:if test="${author != null}">
            <h1>Edit Author</h1>
            <form action="${pageContext.request.contextPath}/updateAuthor" method="post">
                <input type="hidden" name="authorId" value="<c:out value='${author.authorId}' />" />
        </c:if>

            <label for="name">Author Name</label>
            <input type="text" name="name" value="<c:out value='${author.name}' />" required>
            
            <label for="bio">Biography</label>
            <textarea name="bio" required><c:out value='${author.bio}' /></textarea>
            
            <c:if test="${author == null}">
                <button type="submit">Save Author</button>
            </c:if>
            <c:if test="${author != null}">
                <button type="submit">Update Author</button>
            </c:if>
            
        </form>
        
        <a href="${pageContext.request.contextPath}/authorList" class="home-link" style="text-align: center; display: block;">Back to Author List</a>
        
    </div> </body>
</html>