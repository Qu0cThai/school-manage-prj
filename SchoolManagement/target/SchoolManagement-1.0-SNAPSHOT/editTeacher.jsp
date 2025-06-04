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
    }
    .mb-3 {
        position: relative;
        margin-bottom: 1.5rem;
    }
    .mb-3 label {
        color: #495057;
        font-weight: bold;
    }
    .mb-3 input, .mb-3 textarea, .mb-3 select {
        border-radius: 8px;
        border: 1px solid #ced4da;
        transition: border-color 0.3s ease;
    }
    .mb-3 input:focus, .mb-3 textarea:focus, .mb-3 select:focus {
        border-color: #4facfe;
        box-shadow: 0 0 5px rgba(79, 172, 254, 0.3);
    }
    .btn-primary {
        background: #4facfe;
        border: none;
        transition: all 0.3s ease;
    }
    .btn-primary:hover {
        transform: scale(1.05);
    }
    .btn-secondary {
        background: linear-gradient(90deg, #ff7e5f, #feb47b);
        border: none;
        transition: all 0.3s ease;
    }
    .btn-secondary:hover {
        transform: scale(1.05);
    }
    .alert-success, .alert-danger {
        border-radius: 8px;
        margin-bottom: 1.5rem;
        text-align: center;
    }
</style>
<div class="container mt-4">
    <%
        String u_id = (String) session.getAttribute("u_id");
        Integer userRId = (Integer) session.getAttribute("userRId");
        if (u_id == null || userRId == null || userRId != 2) {
            response.sendRedirect("index.jsp");
            return;
        }

        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        String message = "";
        String t_name = "", t_email = "", gender = "", phone_number = "", address = "", sub_name = "", join_date = "";

        if ("POST".equalsIgnoreCase(request.getMethod())) {
            try {
                conn = getConnection();
                t_name = request.getParameter("t_name");
                t_email = request.getParameter("t_email");
                gender = request.getParameter("gender");
                phone_number = request.getParameter("phone_number");
                address = request.getParameter("address");
                sub_name = request.getParameter("sub_name");
                join_date = request.getParameter("join_date");

                pstmt = conn.prepareStatement("SELECT 1 FROM teachers WHERE t_id = ?");
                pstmt.setString(1, u_id);
                rs = pstmt.executeQuery();
                boolean exists = rs.next();
                rs.close();
                pstmt.close();

                if (exists) {
                    pstmt = conn.prepareStatement("UPDATE teachers SET t_name = ?, t_email = ?, gender = ?, phone_number = ?, address = ?, sub_name = ?, join_date = ? WHERE t_id = ?");
                    pstmt.setString(1, t_name);
                    pstmt.setString(2, t_email);
                    pstmt.setString(3, gender);
                    pstmt.setString(4, phone_number.isEmpty() ? null : phone_number);
                    pstmt.setString(5, address.isEmpty() ? null : address);
                    pstmt.setString(6, sub_name.isEmpty() ? null : sub_name);
                    pstmt.setString(7, join_date);
                    pstmt.setString(8, u_id);
                } else {
                    pstmt = conn.prepareStatement("INSERT INTO teachers (t_id, t_name, t_email, gender, phone_number, address, sub_name, join_date) VALUES (?, ?, ?, ?, ?, ?, ?, ?)");
                    pstmt.setString(1, u_id);
                    pstmt.setString(2, t_name);
                    pstmt.setString(3, t_email);
                    pstmt.setString(4, gender);
                    pstmt.setString(5, phone_number.isEmpty() ? null : phone_number);
                    pstmt.setString(6, address.isEmpty() ? null : address);
                    pstmt.setString(7, sub_name.isEmpty() ? null : sub_name);
                    pstmt.setString(8, join_date);
                }
                pstmt.executeUpdate();

                pstmt = conn.prepareStatement("UPDATE users SET is_profile_complete = TRUE WHERE u_id = ?");
                pstmt.setString(1, u_id);
                pstmt.executeUpdate();

                message = "<div class='alert alert-success'>Profile updated successfully!</div>";
                response.sendRedirect("index.jsp");
            } catch (Exception e) {
                message = "<div class='alert alert-danger text-center'>Error: " + e.getMessage() + "</div>";
            } finally {
                closeResources(conn, pstmt, rs);
            }
        } else {
            try {
                conn = getConnection();
                pstmt = conn.prepareStatement("SELECT t_name, t_email, gender, phone_number, address, sub_name, join_date FROM teachers WHERE t_id = ?");
                pstmt.setString(1, u_id);
                rs = pstmt.executeQuery();
                if (rs.next()) {
                    t_name = rs.getString("t_name") != null ? rs.getString("t_name") : "";
                    t_email = rs.getString("t_email") != null ? rs.getString("t_email") : "";
                    gender = rs.getString("gender") != null ? rs.getString("gender") : "";
                    phone_number = rs.getString("phone_number") != null ? rs.getString("phone_number") : "";
                    address = rs.getString("address") != null ? rs.getString("address") : "";
                    sub_name = rs.getString("sub_name") != null ? rs.getString("sub_name") : "";
                    join_date = rs.getString("join_date") != null ? rs.getString("join_date") : "";
                }
            } catch (Exception e) {
                message = "<div class='alert alert-danger text-center'>Error loading profile: " + e.getMessage() + "</div>";
            } finally {
                closeResources(conn, pstmt, rs);
            }
        }
    %>
    <%= message %>
    <div class="form-container">
        <h3>Edit Your Profile</h3>
        <form method="POST" action="editTeacher.jsp">
            <div class="mb-3">
                <label for="t_name">Name</label>
                <input type="text" class="form-control" id="t_name" name="t_name" value="<%= t_name %>" required>
            </div>
            <div class="mb-3">
                <label for="t_email">Email</label>
                <input type="email" class="form-control" id="t_email" name="t_email" value="<%= t_email %>" required>
            </div>
            <div class="mb-3">
                <label for="gender">Gender</label>
                <select class="form-control" id="gender" name="gender" required>
                    <option value="Male" <%= "Male".equals(gender) ? "selected" : "" %>>Male</option>
                    <option value="Female" <%= "Female".equals(gender) ? "selected" : "" %>>Female</option>
                    <option value="Other" <%= "Other".equals(gender) ? "selected" : "" %>>Other</option>
                </select>
            </div>
            <div class="mb-3">
                <label for="phone_number">Phone Number</label>
                <input type="text" class="form-control" id="phone_number" name="phone_number" value="<%= phone_number %>" pattern="[0-9]{10}" title="Enter a valid 10-digit phone number">
            </div>
            <div class="mb-3">
                <label for="address">Address</label>
                <textarea class="form-control" id="address" name="address" rows="3"><%= address %></textarea>
            </div>
            <div class="mb-3">
                <label for="sub_name">Subject</label>
                <input type="text" class="form-control" id="sub_name" name="sub_name" value="<%= sub_name %>">
            </div>
            <div class="mb-3">
                <label for="join_date">Join Date</label>
                <input type="date" class="form-control" id="join_date" name="join_date" value="<%= join_date %>" required>
            </div>
            <button type="submit" class="btn btn-primary">Save Profile</button>
            <a href="teacherInformation.jsp" class="btn btn-secondary">Cancel</a>
        </form>
    </div>
</div>
<%@ include file="footer.jsp"%>