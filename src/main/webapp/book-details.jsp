<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %> <%-- Import FMT for number formatting --%>

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
            margin-bottom: 5px;
        }
        .rating-header {
            text-align: center;
            color: #ffc107; /* Gold color for stars */
            font-size: 1.2rem;
            margin-bottom: 20px;
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
        
        /* --- CART STYLES --- */
        .cart-form {
            margin-top: 30px;
            text-align: center;
            border-top: 1px solid #eee;
            padding-top: 20px;
        }
        .cart-button {
            text-decoration: none;
            padding: 12px 25px;
            border-radius: 5px;
            font-size: 1.2rem;
            background-color: #28a745;
            color: white;
            border: none;
            cursor: pointer;
            transition: background-color 0.3s;
        }
        .cart-button:hover {
            background-color: #218838;
        }
        .stock-error {
            color: #dc3545;
            font-weight: bold;
            font-size: 1.1rem;
            margin-top: 15px;
        }

        /* --- REVIEW SECTION STYLES --- */
        .review-section {
            margin-top: 40px;
            border-top: 2px solid #eee;
            padding-top: 20px;
        }
        .review-card {
            background-color: #f9f9f9;
            border: 1px solid #ddd;
            padding: 15px;
            margin-bottom: 15px;
            border-radius: 5px;
        }
        .review-header {
            display: flex;
            justify-content: space-between;
            margin-bottom: 10px;
            font-size: 0.9rem;
            color: #555;
        }
        .star-rating {
            color: #ffc107;
            font-weight: bold;
        }
        .review-form-container {
            background-color: #f0f8ff;
            padding: 20px;
            border-radius: 5px;
            margin-top: 20px;
        }
        .review-form-container label {
            display: block;
            margin-top: 10px;
            font-weight: bold;
        }
        .review-form-container select, 
        .review-form-container textarea {
            width: 100%;
            padding: 8px;
            margin-top: 5px;
            border: 1px solid #ccc;
            border-radius: 4px;
        }
        .btn-submit {
            background-color: #007bff;
            color: white;
            border: none;
            padding: 10px 20px;
            margin-top: 15px;
            cursor: pointer;
            border-radius: 4px;
        }
        .btn-delete {
            background-color: #dc3545;
            color: white;
            border: none;
            padding: 5px 10px;
            cursor: pointer;
            border-radius: 4px;
            margin-left: 10px;
        }
        .btn-edit {
            background-color: #ffc107;
            color: black;
            border: none;
            padding: 5px 10px;
            cursor: pointer;
            border-radius: 4px;
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
            
            <!-- AVERAGE RATING HEADER -->
            <div class="rating-header">
                <c:choose>
                    <c:when test="${reviewCount > 0}">
                        <span style="font-size: 1.5rem;">
                            <fmt:formatNumber value="${avgRating}" maxFractionDigits="1" /> / 5
                        </span>
                        <span>&#9733;</span> <!-- Star Icon -->
                        <span style="color: #666; font-size: 1rem; margin-left: 10px;">
                            (<c:out value="${reviewCount}" /> reviews)
                        </span>
                    </c:when>
                    <c:otherwise>
                        <span style="color: #666; font-size: 1rem;">No reviews yet</span>
                    </c:otherwise>
                </c:choose>
            </div>

            <h3>By:
                <c:if test="${empty authors}">Unknown Author</c:if>
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
            
            <!-- CART SECTION -->
            <c:if test="${not empty sessionScope.customerId}">
                <div class="cart-form">
                    <c:if test="${param.error == 'stock'}">
                        <p class="stock-error">Could not add to cart: Not enough items in stock.</p>
                    </c:if>
                    <form action="${pageContext.request.contextPath}/cart?action=add" method="post">
                        <input type="hidden" name="isbn" value="<c:out value='${book.isbn}' />" />
                        <input type="hidden" name="price" value="<c:out value='${book.price}' />" />
                        <button type="submit" class="cart-button">Add to Cart</button>
                    </form>
                </div>
            </c:if>

            <!-- REVIEWS SECTION -->
            <div class="review-section">
                <h2>Customer Reviews</h2>

                <!-- 1. LIST ALL REVIEWS -->
                <c:forEach var="review" items="${reviews}">
                    <div class="review-card">
                        <div class="review-header">
                            <strong><c:out value="${review.customerName}" /></strong>
                            <span><fmt:formatDate value="${review.reviewDate}" pattern="MMM d, yyyy" /></span>
                        </div>
                        <div class="star-rating">
                            <c:forEach begin="1" end="${review.rating}">&#9733;</c:forEach>
                            <c:forEach begin="${review.rating + 1}" end="5">&#9734;</c:forEach>
                        </div>
                        <p><c:out value="${review.reviewText}" /></p>
                    </div>
                </c:forEach>
                
                <c:if test="${empty reviews}">
                    <p>Be the first to review this book!</p>
                </c:if>

                <!-- 2. ADD / EDIT REVIEW FORM -->
                <c:choose>
                    <%-- User is NOT logged in --%>
                    <c:when test="${empty sessionScope.customerId}">
                        <p style="margin-top: 20px;">
                            <a href="${pageContext.request.contextPath}/customer?action=showLogin">Login</a> to write a review.
                        </p>
                    </c:when>

                    <%-- User IS logged in --%>
                    <c:otherwise>
                        <div class="review-form-container">
                            
                            <c:choose>
                                <%-- User has ALREADY reviewed this book (Edit Mode) --%>
                                <c:when test="${not empty userReview}">
                                    <h3>Edit Your Review</h3>
                                    <form action="${pageContext.request.contextPath}/review" method="post">
                                        <input type="hidden" name="action" value="edit" />
                                        <input type="hidden" name="reviewId" value="${userReview.reviewId}" />
                                        <input type="hidden" name="isbn" value="${book.isbn}" />
                                        
                                        <label for="rating">Rating:</label>
                                        <select name="rating" required>
                                            <option value="5" ${userReview.rating == 5 ? 'selected' : ''}>5 - Excellent</option>
                                            <option value="4" ${userReview.rating == 4 ? 'selected' : ''}>4 - Very Good</option>
                                            <option value="3" ${userReview.rating == 3 ? 'selected' : ''}>3 - Good</option>
                                            <option value="2" ${userReview.rating == 2 ? 'selected' : ''}>2 - Fair</option>
                                            <option value="1" ${userReview.rating == 1 ? 'selected' : ''}>1 - Poor</option>
                                        </select>
                                        
                                        <label for="reviewText">Review:</label>
                                        <textarea name="reviewText" rows="4" required><c:out value="${userReview.reviewText}" /></textarea>
                                        
                                        <button type="submit" class="btn-submit btn-edit">Update Review</button>
                                    </form>
                                    
                                    <!-- Delete Button -->
                                    <form action="${pageContext.request.contextPath}/review" method="post" style="display:inline;">
                                        <input type="hidden" name="action" value="delete" />
                                        <input type="hidden" name="reviewId" value="${userReview.reviewId}" />
                                        <input type="hidden" name="isbn" value="${book.isbn}" />
                                        <button type="submit" class="btn-delete" onclick="return confirm('Are you sure?');">Delete</button>
                                    </form>
                                </c:when>

                                <%-- User has NOT reviewed this book (Add Mode) --%>
                                <c:otherwise>
                                    <h3>Write a Review</h3>
                                    <form action="${pageContext.request.contextPath}/review" method="post">
                                        <input type="hidden" name="action" value="add" />
                                        <input type="hidden" name="isbn" value="${book.isbn}" />
                                        
                                        <label for="rating">Rating:</label>
                                        <select name="rating" required>
                                            <option value="5">5 - Excellent</option>
                                            <option value="4">4 - Very Good</option>
                                            <option value="3">3 - Good</option>
                                            <option value="2">2 - Fair</option>
                                            <option value="1">1 - Poor</option>
                                        </select>
                                        
                                        <label for="reviewText">Review:</label>
                                        <textarea name="reviewText" rows="4" required></textarea>
                                        
                                        <button type="submit" class="btn-submit">Submit Review</button>
                                    </form>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>
            
        </c:if>
        
        <a href="${pageContext.request.contextPath}/" class="back-link">&larr; Back to Book List</a>
        
    </div>

</body>
</html>