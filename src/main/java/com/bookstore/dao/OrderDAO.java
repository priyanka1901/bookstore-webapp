package com.bookstore.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

import com.bookstore.model.Book;
import com.bookstore.model.Order;
import com.bookstore.model.OrderItem;
import com.bookstore.util.DatabaseConnection;

/**
 * DAO for 'Orders' and 'OrderItems'.
 * Manages shopping cart and order processing.
 */
public class OrderDAO {

    /**
     * Adds a book to a customer's "Pending" order (cart).
     * Checks stock levels before adding.
     *
     * @return true if the book was added/updated, false if out of stock.
     */
    public boolean addBookToCart(int customerId, String isbn, double priceAtPurchase) {
        System.out.println("[OrderDAO] Adding book " + isbn + " to cart for customer " + customerId);

        // 1. Find or create the customer's "Pending" order (their cart).
        Order cart = findOrCreateCart(customerId);
        int orderId = cart.getOrderId();

        String checkItemSql = "SELECT * FROM OrderItems WHERE order_id = ? AND isbn = ?";
        String updateQtySql = "UPDATE OrderItems SET quantity = quantity + 1 WHERE order_id = ? AND isbn = ?";
        String insertItemSql = "INSERT INTO OrderItems (order_id, isbn, quantity, price_at_purchase) VALUES (?, ?, 1, ?)";
        String checkStockSql = "SELECT quantity_in_stock FROM Books WHERE isbn = ?";

        try (Connection conn = DatabaseConnection.getConnection()) {
            
            int currentStock = 0;
            int currentCartQty = 0;
            
            // 2. Get the current stock level for the book
            try (PreparedStatement stockStmt = conn.prepareStatement(checkStockSql)) {
                stockStmt.setString(1, isbn);
                ResultSet rs = stockStmt.executeQuery();
                if (rs.next()) {
                    currentStock = rs.getInt("quantity_in_stock");
                }
            }

            // 3. Check if this item is already in the cart
            try (PreparedStatement checkStmt = conn.prepareStatement(checkItemSql)) {
                checkStmt.setInt(1, orderId);
                checkStmt.setString(2, isbn);
                ResultSet rs = checkStmt.executeQuery();

                if (rs.next()) {
                    // Item exists, get its current quantity
                    currentCartQty = rs.getInt("quantity");
                }
            }
            
            // 4. *** THE INVENTORY CHECK ***
            if ((currentCartQty + 1) > currentStock) {
                System.err.println("[OrderDAO] FAILED to add " + isbn + ". Stock: " + currentStock + ", Cart Qty: " + currentCartQty);
                return false; // Return failure
            }

            // 5. If stock is OK, proceed with insert or update
            if (currentCartQty > 0) {
                System.out.println("[OrderDAO] Item already in cart. Updating quantity.");
                try (PreparedStatement updateStmt = conn.prepareStatement(updateQtySql)) {
                    updateStmt.setInt(1, orderId);
                    updateStmt.setString(2, isbn);
                    updateStmt.executeUpdate();
                }
            } else {
                System.out.println("[OrderDAO] Item not in cart. Inserting new item.");
                try (PreparedStatement insertStmt = conn.prepareStatement(insertItemSql)) {
                    insertStmt.setInt(1, orderId);
                    insertStmt.setString(2, isbn);
                    insertStmt.setDouble(3, priceAtPurchase);
                    insertStmt.executeUpdate();
                }
            }
            
            // 6. Update the total amount for the order
            updateOrderTotal(conn, orderId);
            return true; // Return success
            
        } catch (SQLException e) {
            System.err.println("[OrderDAO] SQL Error adding book to cart: " + e.getMessage());
            e.printStackTrace();
            return false; // Return failure
        }
    }

    /**
     * Finds a customer's "Pending" order (cart). If one doesn't exist,
     * it creates a new one and returns it.
     */
    public Order findOrCreateCart(int customerId) {
        String findSql = "SELECT * FROM Orders WHERE customer_id = ? AND status = 'Pending'";
        String createSql = "INSERT INTO Orders (customer_id, order_date, total_amount, status) VALUES (?, CURDATE(), 0.0, 'Pending')";

        try (Connection conn = DatabaseConnection.getConnection()) {
            
            // 1. Try to find an existing "Pending" order
            try (PreparedStatement findStmt = conn.prepareStatement(findSql)) {
                findStmt.setInt(1, customerId);
                ResultSet rs = findStmt.executeQuery();
                
                if (rs.next()) {
                    // Found an existing cart
                    System.out.println("[OrderDAO] Found existing cart for customer " + customerId);
                    return new Order(
                        rs.getInt("order_id"),
                        rs.getInt("customer_id"),
                        rs.getDate("order_date"),
                        rs.getDouble("total_amount"),
                        rs.getString("status")
                    );
                }
            }
            
            // 2. No "Pending" order found, so create one
            System.out.println("[OrderDAO] No pending cart. Creating new cart for customer " + customerId);
            try (PreparedStatement createStmt = conn.prepareStatement(createSql, Statement.RETURN_GENERATED_KEYS)) {
                createStmt.setInt(1, customerId);
                createStmt.executeUpdate();
                
                // Get the newly generated order_id
                try (ResultSet generatedKeys = createStmt.getGeneratedKeys()) {
                    if (generatedKeys.next()) {
                        int newOrderId = generatedKeys.getInt(1);
                        // Return the new cart object
                        return new Order(newOrderId, customerId, new java.sql.Date(System.currentTimeMillis()), 0.0, "Pending");
                    } else {
                        throw new SQLException("Creating order failed, no ID obtained.");
                    }
                }
            }
            
        } catch (SQLException e) {
            System.err.println("[OrderDAO] SQL Error in findOrCreateCart: " + e.getMessage());
            e.printStackTrace();
            return null; // Return null on failure
        }
    }
    
    /**
     * Retrieves all OrderItems for a specific order, joining with the Books table
     * to get the book title.
     */
    public List<OrderItem> getCartItems(int orderId) {
        List<OrderItem> cartItems = new ArrayList<>();
        // We JOIN with Books to get the title
        String sql = "SELECT oi.*, b.title " +
                     "FROM OrderItems oi " +
                     "JOIN Books b ON oi.isbn = b.isbn " +
                     "WHERE oi.order_id = ?";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, orderId);
            ResultSet rs = stmt.executeQuery();
            
            while (rs.next()) {
                OrderItem item = new OrderItem();
                item.setOrderItemId(rs.getInt("order_item_id"));
                item.setOrderId(rs.getInt("order_id"));
                item.setIsbn(rs.getString("isbn"));
                item.setQuantity(rs.getInt("quantity"));
                item.setPriceAtPurchase(rs.getDouble("price_at_purchase"));
                
                // Add the JOINED data (book title)
                item.setBookTitle(rs.getString("title"));
                
                cartItems.add(item);
            }
        } catch (SQLException e) {
            System.err.println("[OrderDAO] SQL Error getting cart items: " + e.getMessage());
            e.printStackTrace();
        }
        System.out.println("[OrderDAO] Found " + cartItems.size() + " items for order " + orderId);
        return cartItems;
    }

    /**
     * A helper method to recalculate the total price of an order.
     * This is called after adding/removing/updating items.
     */
    private void updateOrderTotal(Connection conn, int orderId) throws SQLException {
        String totalSql = "SELECT SUM(quantity * price_at_purchase) AS subtotal FROM OrderItems WHERE order_id = ?";
        String updateSql = "UPDATE Orders SET total_amount = ? WHERE order_id = ?";
        
        double totalAmount = 0.0;
        
        // 1. Calculate the new total from OrderItems
        try (PreparedStatement totalStmt = conn.prepareStatement(totalSql)) {
            totalStmt.setInt(1, orderId);
            ResultSet rs = totalStmt.executeQuery();
            if (rs.next()) {
                totalAmount = rs.getDouble("subtotal");
            }
        }
        
        // 2. Update the Orders table with the new total
        try (PreparedStatement updateStmt = conn.prepareStatement(updateSql)) {
            updateStmt.setDouble(1, totalAmount);
            updateStmt.setInt(2, orderId);
            updateStmt.executeUpdate();
        }
        System.out.println("[OrderDAO] Updated order " + orderId + " total to: " + totalAmount);
    }
    
    /**
     * Removes an item from the OrderItems table.
     * After removal, it recalculates the order's total amount.
     */
    public void removeItemFromCart(int orderItemId) {
        String findOrderSql = "SELECT order_id FROM OrderItems WHERE order_item_id = ?";
        String deleteSql = "DELETE FROM OrderItems WHERE order_item_id = ?";
        int orderId = -1;

        try (Connection conn = DatabaseConnection.getConnection()) {
            
            // 1. First, find the order_id this item belongs to
            try (PreparedStatement findStmt = conn.prepareStatement(findOrderSql)) {
                findStmt.setInt(1, orderItemId);
                ResultSet rs = findStmt.executeQuery();
                if (rs.next()) {
                    orderId = rs.getInt("order_id");
                }
            }
            
            if (orderId == -1) {
                System.err.println("[OrderDAO] Could not find item with id: " + orderItemId);
                return;
            }

            // 2. Now, delete the item
            try (PreparedStatement deleteStmt = conn.prepareStatement(deleteSql)) {
                deleteStmt.setInt(1, orderItemId);
                int rowsAffected = deleteStmt.executeUpdate();
                System.out.println("[OrderDAO] Removed item " + orderItemId + ". Rows affected: " + rowsAffected);
            }
            
            // 3. Finally, update the order's total amount
            updateOrderTotal(conn, orderId);
            
        } catch (SQLException e) {
            System.err.println("[OrderDAO] SQL Error removing item from cart: " + e.getMessage());
            e.printStackTrace();
        }
    }
    
    /**
     * Places an order. This is a TRANSACTIONAL operation.
     * 1. Verifies stock for all items.
     * 2. Decrements stock from the Books table.
     * 3. Updates the Order status from "Pending" to "Placed".
     *
     * @return true on success, false on failure (e.g., out of stock)
     */
    public boolean placeOrder(int orderId) {
        System.out.println("[OrderDAO] Attempting to place order " + orderId);
        
        String checkStockSql = "SELECT b.quantity_in_stock, oi.quantity FROM OrderItems oi " +
                               "JOIN Books b ON oi.isbn = b.isbn WHERE oi.order_id = ?";
        
        String updateStockSql = "UPDATE Books SET quantity_in_stock = quantity_in_stock - ? " +
                                "WHERE isbn = ?";
        
        String updateOrderStatusSql = "UPDATE Orders SET status = 'Placed', order_date = CURDATE() " +
                                      "WHERE order_id = ?";
        
        Connection conn = null;
        
        try {
            conn = DatabaseConnection.getConnection();
            
            // --- Start Transaction ---
            conn.setAutoCommit(false);
            
            List<OrderItem> items = getCartItems(orderId);
            
            // 1. Verify stock one last time
            System.out.println("[OrderDAO] Verifying stock for order " + orderId);
            try (PreparedStatement checkStmt = conn.prepareStatement(checkStockSql)) {
                checkStmt.setInt(1, orderId);
                ResultSet rs = checkStmt.executeQuery();
                
                while (rs.next()) {
                    int inStock = rs.getInt("quantity_in_stock");
                    int inCart = rs.getInt("quantity");
                    if (inCart > inStock) {
                        System.err.println("[OrderDAO] Checkout FAILED: Not enough stock.");
                        throw new SQLException("Item out of stock. Cannot complete order.");
                    }
                }
            }
            
            // 2. If stock is OK, decrement stock from Books table
            System.out.println("[OrderDAO] Stock OK. Decrementing quantities...");
            try (PreparedStatement updateStockStmt = conn.prepareStatement(updateStockSql)) {
                for (OrderItem item : items) {
                    updateStockStmt.setInt(1, item.getQuantity());
                    updateStockStmt.setString(2, item.getIsbn());
                    updateStockStmt.addBatch();
                }
                updateStockStmt.executeBatch();
            }
            
            // 3. Update the Order status to "Placed"
            System.out.println("[OrderDAO] Updating order status to 'Placed'.");
            try (PreparedStatement updateOrderStmt = conn.prepareStatement(updateOrderStatusSql)) {
                updateOrderStmt.setInt(1, orderId);
                updateOrderStmt.executeUpdate();
            }
            
            // --- All steps successful: Commit Transaction ---
            conn.commit();
            System.out.println("[OrderDAO] Order " + orderId + " placed successfully!");
            return true;
            
        } catch (SQLException e) {
            // Something went wrong! Roll back all changes.
            System.err.println("[OrderDAO] TRANSACTION FAILED: " + e.getMessage());
            if (conn != null) {
                try {
                    conn.rollback();
                    System.err.println("[OrderDAO] Transaction rolled back.");
                } catch (SQLException ex) {
                    ex.printStackTrace();
                }
            }
            return false;
        } finally {
            if (conn != null) {
                try {
                    conn.setAutoCommit(true); // Reset connection to default
                    conn.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
        }
    }
}
