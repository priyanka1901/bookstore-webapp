<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Manage Authors - Online Bookstore</title>
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
        
        /* This style helps shorten the bio text */
        .bio-excerpt {
            max-width: 400px; /* Or whatever width you prefer */
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }
    </style>
</head>
<body>
    
    <div class="home-container">

        <%@ include file="common/navigation.jspf" %>

        <h1>Author Management</h1>

        <!-- Error Message Display -->
        <c:if test="${not empty errorMessage}">
            <div style="color: #721c24; background-color: #f8d7da; border-color: #f5c6cb; padding: 10px; margin-bottom: 15px; border: 1px solid transparent; border-radius: .25rem;">
                <c:out value="${errorMessage}" />
            </div>
        </c:if>

        <a href="${pageContext.request.contextPath}/newAuthor" class="add-button">+ Add New Author</a>
        
        <c:if test="${empty authorList}">
            <p style="margin-top: 20px;">No authors found in the database.</p>
        </c:if>
    
        <c:if test="${not empty authorList}">
            <table>
                <thead>
                    <tr>
                        <th>Author ID</th>
                        <th>Name</th>
                        <th>Bio (excerpt)</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="author" items="${authorList}">
                        <tr>
                            <td><c:out value="${author.authorId}" /></td>
                            
                            <td><c:out value="${author.authorName}" /></td>
                            
                            <td>
                            	<div class="bio-excerpt">
           							<c:out value="${author.bio}" />
        						</div>
                            </td>
                            
                            <td class="actions-cell">
                                <a href="${pageContext.request.contextPath}/editAuthor?id=${author.authorId}" class="edit-link">Edit</a>
                                <a href="${pageContext.request.contextPath}/deleteAuthor?id=${author.authorId}" class="delete-link" 
                                   onclick="return confirm('Are you sure you want to delete this author? This may fail if they are linked to existing books.')">Delete</a>
                            </td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>
        </c:if>

    </div> </body>
</html>