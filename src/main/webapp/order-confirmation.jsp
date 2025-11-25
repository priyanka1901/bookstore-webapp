<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Order Confirmed!</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>
    
    <div class="home-container" style="text-align: center;">

        <!-- *** THIS IS THE FIX *** -->
        <!-- Replace the old <nav> block with the include -->
        <%@ include file="common/navigation.jspf" %>
        <!-- *** END OF FIX *** -->
        
        <div class="auth-container" style="margin-top: 30px;">
            <h1>Thank You For Your Order!</h1>
            <p style="font-size: 1.2rem;">
                Your order (ID: <c:out value="${orderId}" />) has been successfully placed.
            </p>
            <p>We will process it shortly.</p>
            
            <a href="${pageContext.request.contextPath}/" class="home-link" style="margin-top: 20px;">&larr; Back to Home</a>
        </div>

    </div> <!-- End of .home-container -->

</body>
</html>