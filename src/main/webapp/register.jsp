<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Register - Online Bookstore</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <style>
        /* Small style to make the form look a bit better */
        .auth-container {
            max-width: 500px; /* Make the form a bit narrower */
            margin-top: 30px;
        }
    </style>
</head>
<body>

    <%-- <!-- *** THIS IS THE FIX *** -->
    <!-- Add the centralized navigation bar -->
    <div class="home-container">
        <%@ include file="common/navigation.jspf" %>
    </div> --%>
    <!-- *** END OF FIX *** -->

    <div class="auth-container">
    
        <form action="${pageContext.request.contextPath}/customer?action=register" method="post">
        
            <h1>Create an Account</h1>
            
            <!-- Display any error messages -->
            <c:if test="${not empty error}">
                <p style="color: red;"><c:out value="${error}" /></p>
            </c:if>

            <label for="name">Full Name</label>
            <input type="text" name="name" required>
            
            <label for="email">Email</label>
            <input type="email" name="email" required>
            
            <label for="password">Password</label>
            <input type="password" name="password" required>
            
            <label for="address">Address</label>
            <input type="text" name="address" required>
            
            <button type="submit">Register</button>
        </form>
        
        <p style="margin-top: 15px;">
            Already have an account? 
            <a href="${pageContext.request.contextPath}/customer?action=showLogin" class="home-link">Login here</a>
        </p>
        
    </div>

</body>
</html>