<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %> <!-- For formatting numbers -->

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Your Shopping Cart</title>
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
        .cart-total {
            text-align: right;
            margin-top: 20px;
            margin-right: 10%;
            font-size: 1.5rem;
            font-weight: bold;
        }
        .checkout-button {
            text-decoration: none;
            padding: 10px 20px;
            border-radius: 5px;
            font-size: 1.2rem;
            background-color: #28a745;
            color: white;
            display: inline-block;
            margin-top: 20px;
        }
        
        .remove-link {
            text-decoration: none;
            padding: 4px 8px;
            border-radius: 4px;
            background-color: #dc3545; /* Red */
            color: white;
        }
        
        .checkout-error {
            color: #dc3545; /* Red */
            font-weight: bold;
            font-size: 1.1rem;
            margin-top: 15px;
            padding: 10px;
            border: 1px solid #dc3545;
            border-radius: 5px;
            background-color: #f8d7da;
        }
    </style>
</head>
<body>
    
    <div class="home-container">

        <!-- *** THIS IS THE UPDATE *** -->
        <!-- Include the centralized navigation bar -->
        <%@ include file="common/navigation.jspf" %>
        <!-- *** END OF UPDATE *** -->
        
        <h1>Your Shopping Cart</h1>

        <c:if test="${param.error == 'checkout_failed'}">
            <p class="checkout-error">
                Could not place order. An item in your cart may have gone out of stock. Please review your cart.
            </p>
        </c:if>

        <c:if test="${empty cartItems}">
            <p style="margin-top: 20px;">Your cart is empty.</p>
            <a href="${pageContext.request.contextPath}/" class="home-link">&larr; Continue Shopping</a>
        </c:if>
    
        <c:if test="${not empty cartItems}">
            <table>
                <thead>
                    <tr>
                        <th>Book Title</th>
                        <th>Price</th>
                        <th>Quantity</th>
                        <th>Subtotal</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="item" items="${cartItems}">
                        <tr>
                            <td><c:out value="${item.bookTitle}" /></td>
                            <td>$<fmt:formatNumber type="number" minFractionDigits="2" maxFractionDigits="2" value="${item.priceAtPurchase}" /></td>
                            <td><c:out value="${item.quantity}" /></td>
                            <td>$<fmt:formatNumber type="number" minFractionDigits="2" maxFractionDigits="2" value="${item.priceAtPurchase * item.quantity}" /></td>
                            <td>
                                <a href="${pageContext.request.contextPath}/cart?action=remove&id=${item.orderItemId}" class="remove-link">Remove</a>
                            </td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>
            
            <div class="cart-total">
                Total: $<fmt:formatNumber type="number" minFractionDigits="2" maxFractionDigits="2" value="${cart.totalAmount}" />
            </div>
            
            <a href="${pageContext.request.contextPath}/cart?action=checkout" class="checkout-button">Proceed to Checkout</a>
            
        </c:if>

    </div> <!-- End of .home-container -->

</body>
</html>