<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ include file="header.jsp" %>
<%@ include file="/WEB-INF/jspf/db-connection.jsp" %>
<style>
    .notice-board {
        background: #ffffff;
        border-radius: 10px;
        box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
        padding: 15px;
        animation: fadeIn 1s ease-in;
    }
    .btn-secondary {
        background: linear-gradient(90deg, #ff7e5f, #feb47b);
        border: none;
        transition: all 0.3s ease;
    }
    .btn-secondary:hover {
        background: linear-gradient(90deg, #feb47b, #ff7e5f);
        transform: scale(1.05);
    }
</style>
<div class="container mt-4">
    <div class="notice-board">
        <button type="button" class="btn btn-secondary btn-lg w-100">Notice Board</button>
        <div class="list-group mt-3">
            <%
                Connection conn = null;
                Statement stmt = null;
                ResultSet rs = null;
                try {
                    conn = getConnection();
                    stmt = conn.createStatement();
                    String sql = "SELECT n.n_title, n.n_description, n.publish_date, u.u_name " +
                                "FROM notices n JOIN users u ON n.created_by = u.u_id " +
                                "ORDER BY n.publish_date DESC";
                    rs = stmt.executeQuery(sql);
                    while (rs.next()) {
                        String title = rs.getString("n_title");
                        String description = rs.getString("n_description");
                        String publishDate = rs.getString("publish_date");
                        String createdBy = rs.getString("u_name");
            %>
            <a class="list-group-item list-group-item-action">
                <div>
                    <h4 class="text-primary">⇛ <%= title %></h4>
                    <p class="text-muted">Description: <%= description != null ? description : "No description available" %></p>
                    <small class="text-secondary">Publish Date: <%= publishDate %> | Posted by: <%= createdBy %></small>
                </div>
            </a>
            <%
                    }
                } catch (Exception e) {
                    out.println("<p class='text-danger'>Error fetching notices: " + e.getMessage() + "</p>");
                } finally {
                    closeResources(conn, stmt, rs);
                }
            %>
        </div>
    </div>
</div>
<%@ include file="footer.jsp" %>