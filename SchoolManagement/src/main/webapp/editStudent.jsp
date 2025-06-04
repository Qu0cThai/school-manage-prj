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
        if (u_id == null || userRId == null || userRId != 3) {
            response.sendRedirect("index.jsp");
            return;
        }

        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        String message = "";
        String s_name = "", gender = "", dob = "", f_name = "", m_name = "", mobile_no = "", present_address = "", permanent_address = "";
        int age = 0;

        if ("POST".equalsIgnoreCase(request.getMethod())) {
            try {
                conn = getConnection();
                s_name = request.getParameter("s_name");
                gender = request.getParameter("gender");
                dob = request.getParameter("dob");
                age = Integer.parseInt(request.getParameter("age"));
                f_name = request.getParameter("f_name");
                m_name = request.getParameter("m_name");
                mobile_no = request.getParameter("mobile_no");
                present_address = request.getParameter("present_address");
                permanent_address = request.getParameter("permanent_address");

                pstmt = conn.prepareStatement("SELECT 1 FROM students WHERE s_id = ?");
                pstmt.setString(1, u_id);
                rs = pstmt.executeQuery();
                boolean exists = rs.next();
                rs.close();
                pstmt.close();

                if (exists) {
                    pstmt = conn.prepareStatement("UPDATE students SET s_name = ?, gender = ?, dob = ?, age = ?, f_name = ?, m_name = ?, mobile_no = ?, present_address = ?, permanent_address = ? WHERE s_id = ?");
                    pstmt.setString(1, s_name);
                    pstmt.setString(2, gender);
                    pstmt.setString(3, dob);
                    pstmt.setInt(4, age);
                    pstmt.setString(5, f_name.isEmpty() ? null : f_name);
                    pstmt.setString(6, m_name.isEmpty() ? null : m_name);
                    pstmt.setString(7, mobile_no.isEmpty() ? null : mobile_no);
                    pstmt.setString(8, present_address.isEmpty() ? null : present_address);
                    pstmt.setString(9, permanent_address.isEmpty() ? null : permanent_address);
                    pstmt.setString(10, u_id);
                } else {
                    pstmt = conn.prepareStatement("INSERT INTO students (s_id, s_name, gender, dob, age, f_name, m_name, mobile_no, present_address, permanent_address) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)");
                    pstmt.setString(1, u_id);
                    pstmt.setString(2, s_name);
                    pstmt.setString(3, gender);
                    pstmt.setString(4, dob);
                    pstmt.setInt(5, age);
                    pstmt.setString(6, f_name.isEmpty() ? null : f_name);
                    pstmt.setString(7, m_name.isEmpty() ? null : m_name);
                    pstmt.setString(8, mobile_no.isEmpty() ? null : mobile_no);
                    pstmt.setString(9, present_address.isEmpty() ? null : present_address);
                    pstmt.setString(10, permanent_address.isEmpty() ? null : permanent_address);
                }
                pstmt.executeUpdate();

                pstmt = conn.prepareStatement("UPDATE users SET is_profile_complete = TRUE WHERE u_id = ?");
                pstmt.setString(1, u_id);
                pstmt.executeUpdate();

                response.sendRedirect("index.jsp");
            } catch (Exception e) {
                message = "<div class='alert alert-danger text-center'>Error: Unable to update profile.</div>";
            } finally {
                closeResources(conn, pstmt, rs);
            }
        } else {
            try {
                conn = getConnection();
                pstmt = conn.prepareStatement("SELECT s_name, gender, dob, age, f_name, m_name, mobile_no, present_address, permanent_address FROM students WHERE s_id = ?");
                pstmt.setString(1, u_id);
                rs = pstmt.executeQuery();
                if (rs.next()) {
                    s_name = rs.getString("s_name") != null ? rs.getString("s_name") : "";
                    gender = rs.getString("gender") != null ? rs.getString("gender") : "";
                    dob = rs.getString("dob") != null ? rs.getString("dob") : "";
                    age = rs.getInt("age");
                    f_name = rs.getString("f_name") != null ? rs.getString("f_name") : "";
                    m_name = rs.getString("m_name") != null ? rs.getString("m_name") : "";
                    mobile_no = rs.getString("mobile_no") != null ? rs.getString("mobile_no") : "";
                    present_address = rs.getString("present_address") != null ? rs.getString("present_address") : "";
                    permanent_address = rs.getString("permanent_address") != null ? rs.getString("permanent_address") : "";
                }
            } catch (Exception e) {
                message = "<div class='alert alert-danger text-center'>Error loading profile: Unable to fetch data.</div>";
            } finally {
                closeResources(conn, pstmt, rs);
            }
        }
    %>
    <%= message %>
    <div class="form-container">
        <h3>Edit Your Profile</h3>
        <form method="POST" action="editStudent.jsp">
            <div class="mb-3">
                <label for="s_name">Name</label>
                <input type="text" class="form-control" id="s_name" name="s_name" value="<%= s_name %>" required>
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
                <label for="dob">Date of Birth</label>
                <input type="date" class="form-control" id="dob" name="dob" value="<%= dob %>" required>
            </div>
            <div class="mb-3">
                <label for="age">Age</label>
                <input type="number" class="form-control" id="age" name="age" value="<%= age %>" required min="0" max="150">
            </div>
            <div class="mb-3">
                <label for="f_name">Father's Name</label>
                <input type="text" class="form-control" id="f_name" name="f_name" value="<%= f_name %>">
            </div>
            <div class="mb-3">
                <label for="m_name">Mother's Name</label>
                <input type="text" class="form-control" id="m_name" name="m_name" value="<%= m_name %>">
            </div>
            <div class="mb-3">
                <label for="mobile_no">Mobile No</label>
                <input type="text" class="form-control" id="mobile_no" name="mobile_no" value="<%= mobile_no %>" pattern="[0-9]{10}" title="Enter a valid 10-digit mobile number">
            </div>
            <div class="mb-3">
                <label for="present_address">Present Address</label>
                <textarea class="form-control" id="present_address" name="present_address" rows="3"><%= present_address %></textarea>
            </div>
            <div class="mb-3">
                <label for="permanent_address">Permanent Address</label>
                <textarea class="form-control" id="permanent_address" name="permanent_address" rows="3"><%= permanent_address %></textarea>
            </div>
            <button type="submit" class="btn btn-primary">Save Profile</button>
            <a href="index.jsp" class="btn btn-secondary">Cancel</a>
        </form>
    </div>
</div>
<%@ include file="footer.jsp"%>