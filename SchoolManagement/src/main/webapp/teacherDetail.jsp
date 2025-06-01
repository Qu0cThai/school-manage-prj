<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ include file="/WEB-INF/jspf/db-connection.jsp" %>
<%@ include file="header.jsp"%>
<style>
    h3 {
        color: #4facfe;
        margin-top: 2rem;
        margin-bottom: 1.5rem;
        text-align: center;
    }
    .form-container {
        background: #ffffff;
        border-radius: 15px;
        box-shadow: 0 8px 16px rgba(0, 0, 0, 0.2);
        padding: 2rem;
        animation: fadeIn 1s ease-in;
        margin-bottom: 2rem;
        max-height: 70vh;
        overflow-y: auto;
    }
    .form-group {
        position: relative;
        margin-bottom: 1.5rem;
    }
    .form-group label {
        color: #495057;
        font-weight: bold;
    }
    .form-group input, .form-group textarea {
        border-radius: 8px;
        border: 1px solid #ced4da;
        transition: border-color 0.3s ease;
    }
    .form-group input[readonly], .form-group textarea[readonly] {
        background-color: #f8f9fa;
        cursor: not-allowed;
    }
    .form-group input:focus, .form-group textarea:focus {
        border-color: #4facfe;
        box-shadow: 0 0 5px rgba(79, 172, 254, 0.3);
    }
    .btn-secondary {
        background: linear-gradient(90deg, #ff7e5f, #feb47b);
        border: none;
        transition: all 0.3s ease;
    }
    .btn-secondary:hover {
        transform: scale(1.05);
        background: linear-gradient(90deg, #ff7e5f, #feb47b);
    }
    .alert-danger {
        border-radius: 8px;
        margin-bottom: 1.5rem;
        text-align: center;
    }
</style>
<div class="container mt-4">
    <div class="form-container">
        <h3>Teacher Details</h3>
        <% 
            Connection conn = null;
            PreparedStatement pstmt = null;
            ResultSet rs = null;
            String t_id = request.getParameter("t_id");
            try {
                conn = getConnection();
                pstmt = conn.prepareStatement("SELECT t_id, t_name, t_email, gender, phone_number, address, sub_name, join_date FROM teachers WHERE t_id = ?");
                pstmt.setString(1, t_id != null ? t_id : "T001");
                rs = pstmt.executeQuery();
                if (rs.next()) {
        %>
        <form class="form-group">
            <div class="form-group">
                <label for="t_id">Teacher ID</label>
                <input class="form-control" id="t_id" name="t_id" type="text" value="<%= rs.getString("t_id") %>" readonly>
            </div>
            <div class="form-group">
                <label for="t_name">Teacher Name</label>
                <input class="form-control" id="t_name" name="t_name" type="text" value="<%= rs.getString("t_name") %>" readonly>
            </div>
            <div class="form-group">
                <label for="t_email">Email</label>
                <input class="form-control" id="t_email" name="t_email" type="text" value="<%= rs.getString("t_email") %>" readonly>
            </div>
            <div class="form-group">
                <label for="gender">Gender</label>
                <input class="form-control" id="gender" name="gender" type="text" value="<%= rs.getString("gender") %>" readonly>
            </div>
            <div class="form-group">
                <label for="phone_number">Phone Number</label>
                <input class="form-control" id="phone_number" name="phone_number" type="text" value="<%= rs.getString("phone_number") %>" readonly>
            </div>
            <div class="form-group">
                <label for="address">Address</label>
                <textarea class="form-control" id="address" name="address" readonly><%= rs.getString("address") %></textarea>
            </div>
            <div class="form-group">
                <label for="sub_name">Subject Name</label>
                <input class="form-control" id="sub_name" name="sub_name" type="text" value="<%= rs.getString("sub_name") %>" readonly>
            </div>
            <div class="form-group">
                <label for="join_date">Join Date</label>
                <input class="form-control" id="join_date" name="join_date" type="text" value="<%= rs.getString("join_date") %>" readonly>
            </div>
            <a href="javascript:history.back()" class="btn btn-secondary">Back</a>
        </form>
        <% 
                } else {
        %>
        <div class="alert alert-danger text-center">Teacher not found.</div>
        <% 
                }
            } catch (Exception e) {
                e.printStackTrace();
        %>
        <div class="alert alert-danger text-center">Error loading teacher details: <%= e.getMessage() %></div>
        <% 
            } finally {
                closeResources(conn, pstmt, rs);
            }
        %>
    </div>
</div>
<%@ include file="footer.jsp"%>