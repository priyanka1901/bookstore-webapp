<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
    
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Login - Online Bookstore</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <style>
        .auth-container {
            max-width: 500px;
            margin-top: 30px;
        }
    </style>
</head>
<body>

    <!-- *** THIS IS THE FIX *** -->
    <!-- Add the centralized navigation bar -->
    <%-- <div class="home-container">
        <%@ include file="common/navigation.jspf" %>
    </div> --%>
    <!-- *** END OF FIX *** -->

    <div class="auth-container">
    
        <form action="${pageContext.request.contextPath}/customer?action=login" method="post">
        
            <h1>Customer Login</h1>
            
            <!-- Display success/error messages -->
            <c:if test="${not empty message}">
                <p style="color: green;"><c:out value="${message}" /></p>
            </c:if>
            <c:if test="${not empty error}">
                <p style="color: red;"><c:out value="${error}" /></p>
            </c:if>

            <label for="email">Email</label>
            <input type="email" name="email" required>
            
            <label for="password">Password</label>
            <input type="password" name="password" required>
            
            <button type="submit">Login</button>
        </form>
        
        <p style="margin-top: 15px;">
            New to the store? 
            <a href="${pageContext.request.contextPath}/customer?action=showRegister" class="home-link">Register here</a>
        </p>
        
    </div>

</body>
</html>