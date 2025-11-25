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
        /* [Internal styles remain the same] */
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
        
        /* --- NEW STYLES FOR ADD TO CART BUTTON --- */
        .cart-form {
            margin-top: 30px;
            text-align: center;
        }
        .cart-button {
            text-decoration: none;
            padding: 12px 25px;
            border-radius: 5px;
            font-size: 1.2rem;
            background-color: #28a745; /* Green */
            color: white;
            border: none;
            cursor: pointer;
            transition: background-color 0.3s;
        }
        .cart-button:hover {
            background-color: #218838;
        }
        
        /* --- NEW STYLE FOR STOCK ERROR --- */
        .stock-error {
            color: #dc3545; /* Red */
            font-weight: bold;
            font-size: 1.1rem;
            margin-top: 15px;
        }
    </style>
</head>
<body>

    <div class="home-container">
        <%@ include file="common/navigation.jspf" %>
        </div>

    <div class="details-container">
        
        <c:if test="${empty book}">
            <h1>Book Not Found</h1>
            <p>The book you requested could not be found.</p>
        </c:if>
        
        <c:if test="${not empty book}">
            <h1><c:out value="${book.title}" /></h1>
            
            <h3>By:
                <%-- *** THIS IS THE CHANGE *** --%>
                <c:if test="${empty authors}">
                    Unknown Author
                </c:if>
                <%-- *** END OF CHANGE *** --%>
            
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
            
            <c:if test="${not empty sessionScope.customerId}">
                <div class="cart-form">
                
                    <c:if test="${param.error == 'stock'}">
                        <%-- Fixed: class="stock-error" --%>
                        <p class="stock-error">
                            Could not add to cart: Not enough items in stock.
                        </p>
                    </c:if>
                
                    <form action="${pageContext.request.contextPath}/cart?action=add" method="post">
                        <input type="hidden" name="isbn" value="<c:out value='${book.isbn}' />" />
                        <input type="hidden" name="price" value="<c:out value='${book.price}' />" />
                        
                        <%-- Fixed: class="cart-button" --%>
                        <button type="submit" class="cart-button">Add to Cart</button>
                    </form>
                </div>
            </c:if>
            
            </c:if>
        
        <%-- Fixed: class="back-link" --%>
        <a href="${pageContext.request.contextPath}/" class="back-link">&larr; Back to Book List</a>
        
    </div>

</body>
</html>