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
    .mb-3 input {
        border-radius: 8px;
        border: 1px solid #ced4da;
        transition: border-color 0.3s ease;
    }
    .mb-3 input[readonly] {
        background-color: #f8f9fa;
        cursor: not-allowed;
    }
    .mb-3 input:focus {
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
    }
    .alert-danger {
        border-radius: 8px;
        margin-bottom: 1.5rem;
        text-align: center;
    }
</style>
<div class="container mt-4">
    <div class="form-container">
        <h3>Student Details</h3>
        <% 
            Connection conn = null;
            PreparedStatement pstmt = null;
            ResultSet rs = null;
            String s_id = request.getParameter("s_id");
            if (s_id == null || s_id.trim().isEmpty()) {
        %>
        <div class="alert alert-danger text-center">Invalid student ID.</div>
        <% 
            } else {
                try {
                    conn = getConnection();
                    pstmt = conn.prepareStatement("SELECT s_id, s_name, gender, dob, age, f_name, m_name, mobile_no, present_address, permanent_address FROM students WHERE s_id = ?");
                    pstmt.setString(1, s_id);
                    rs = pstmt.executeQuery();
                    if (rs.next()) {
        %>
        <div>
            <div class="mb-3">
                <label for="s_id">Student ID</label>
                <input class="form-control" id="s_id" name="s_id" type="text" value="<%= rs.getString("s_id") %>" readonly>
            </div>
            <div class="mb-3">
                <label for="s_name">Student Name</label>
                <input class="form-control" id="s_name" name="s_name" type="text" value="<%= rs.getString("s_name") %>" readonly>
            </div>
            <div class="mb-3">
                <label for="gender">Gender</label>
                <input class="form-control" id="gender" name="gender" type="text" value="<%= rs.getString("gender") %>" readonly>
            </div>
            <div class="mb-3">
                <label for="dob">Date of Birth</label>
                <input class="form-control" id="dob" name="dob" type="text" value="<%= rs.getString("dob") %>" readonly>
            </div>
            <div class="mb-3">
                <label for="age">Age</label>
                <input class="form-control" id="age" name="age" type="text" value="<%= rs.getInt("age") %>" readonly>
            </div>
            <div class="mb-3">
                <label for="f_name">Father Name</label>
                <input class="form-control" id="f_name" name="f_name" type="text" value="<%= rs.getString("f_name") %>" readonly>
            </div>
            <div class="mb-3">
                <label for="m_name">Mother Name</label>
                <input class="form-control" id="m_name" name="m_name" type="text" value="<%= rs.getString("m_name") %>" readonly>
            </div>
            <div class="mb-3">
                <label for="mobile_no">Mobile No</label>
                <input class="form-control" id="mobile_no" name="mobile_no" type="text" value="<%= rs.getString("mobile_no") %>" readonly>
            </div>
            <div class="mb-3">
                <label for="present_address">Present Address</label>
                <input class="form-control" id="present_address" name="present_address" type="text" value="<%= rs.getString("present_address") %>" readonly>
            </div>
            <div class="mb-3">
                <label for="permanent_address">Permanent Address</label>
                <input class="form-control" id="permanent_address" name="permanent_address" type="text" value="<%= rs.getString("permanent_address") %>" readonly>
            </div>
            <a href="javascript:history.back()" class="btn btn-secondary">Back</a>
        </div>
        <% 
                    } else {
        %>
        <div class="alert alert-danger text-center">Student not found.</div>
        <% 
                    }
                } catch (Exception e) {
        %>
        <div class="alert alert-danger text-center">Error loading student details: Unable to fetch data.</div>
        <% 
                } finally {
                    closeResources(conn, pstmt, rs);
                }
            }
        %>
    </div>
</div>
<%@ include file="footer.jsp"%>