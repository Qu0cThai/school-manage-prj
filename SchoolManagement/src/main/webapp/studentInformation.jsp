<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ include file="/WEB-INF/jspf/db-connection.jsp" %>
<%@ include file="header.jsp"%>
<style>
    body {
        background: linear-gradient(135deg, #f0f4f8, #d9e2ec);
        font-family: 'Arial', sans-serif;
        min-height: 100vh;
    }
    .container {
        padding-top: 2rem;
        padding-bottom: 4rem;
    }
    .table-container {
        background: #ffffff;
        border-radius: 15px;
        box-shadow: 0 8px 16px rgba(0, 0, 0, 0.2);
        padding: 1.5rem;
        animation: fadeIn 1s ease-in;
    }
    h3 {
        color: #4facfe;
        margin-bottom: 1.5rem;
        text-align: center;
    }
    .table {
        border-radius: 8px;
        overflow: hidden;
    }
    .thead-dark {
        background: linear-gradient(90deg, #4facfe, #00f2fe);
        color: white;
    }
    .table-striped tbody tr:nth-of-type(odd) {
        background-color: #f8f9fa;
    }
    .table-striped tbody tr:hover {
        background-color: #e0f7fa;
        transition: background-color 0.3s ease;
    }
    .btn-primary {
        background: linear-gradient(90deg, #ff7e5f, #feb47b);
        border: none;
        border-radius: 8px;
        padding: 0.5rem 1rem;
        transition: all 0.3s ease;
    }
    .btn-primary:hover {
        background: linear-gradient(90deg, #feb47b, #ff7e5f);
        transform: scale(1.05);
    }
    .btn-warning {
        background: linear-gradient(90deg, #f6c23e, #e0a800);
        border: none;
        border-radius: 8px;
        padding: 0.5rem 1rem;
        transition: all 0.3s ease;
    }
    .btn-warning:hover {
        background: linear-gradient(90deg, #e0a800, #f6c23e);
        transform: scale(1.05);
    }
    .btn a {
        color: white;
        text-decoration: none;
    }
    .btn a:hover {
        color: white;
    }
    .text-danger {
        background: #f8d7da;
        color: #721c24;
        padding: 0.5rem;
        border-radius: 8px;
        text-align: center;
    }
</style>
<div class="container">
    <div class="table-container">
        <h3>All Students</h3>
        <div class="table-responsive">
            <table class="table table-striped">
                <thead class="thead-dark">
                    <tr>
                        <th scope="col">Student Name</th>
                        <th scope="col">Student Id</th>
                        <th scope="col">Mobile No</th>
                        <th scope="col">Address</th>
                        <th scope="col">Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                        Connection conn = null;
                        PreparedStatement pstmt = null;
                        ResultSet rs = null;
                        String currentUserId = (String) session.getAttribute("u_id");
                        Integer userRId = (Integer) session.getAttribute("userRId");
                        boolean isStudent = userRId != null && userRId == 3;
                        try {
                            conn = getConnection();
                            pstmt = conn.prepareStatement("SELECT s_id, s_name, mobile_no, present_address FROM students");
                            rs = pstmt.executeQuery();
                            if (!rs.isBeforeFirst()) { 
                    %>
                    <tr>
                        <td colspan="5" class="text-muted text-center">No students found.</td>
                    </tr>
                    <%
                            } else {
                                while (rs.next()) {
                                    String s_id = rs.getString("s_id");
                                    String s_name = rs.getString("s_name");
                                    String mobile_no = rs.getString("mobile_no");
                                    String present_address = rs.getString("present_address");
                    %>
                    <tr>
                        <td scope="row"><%= s_name != null ? s_name : "-" %></td>
                        <td><%= s_id != null ? s_id : "-" %></td>
                        <td><%= mobile_no != null ? mobile_no : "-" %></td>
                        <td><%= present_address != null ? present_address : "-" %></td>
                        <td>
                            <button type="button" class="btn btn-primary">
                                <a href="studentDetail.jsp?s_id=<%= s_id %>">Details</a>
                            </button>
                            <% if (isStudent && currentUserId != null && currentUserId.equals(s_id)) { %>
                            <button type="button" class="btn btn-warning">
                                <a href="editStudent.jsp">Edit</a>
                            </button>
                            <% } %>
                        </td>
                    </tr>
                    <%
                                }
                            }
                        } catch (Exception e) {
                            e.printStackTrace();
                    %>
                    <tr>
                        <td colspan="5" class="text-danger">Error loading students: <%= e.getMessage() %></td>
                    </tr>
                    <%
                        } finally {
                            closeResources(conn, pstmt, rs);
                        }
                    %>
                </tbody>
            </table>
        </div>
    </div>
</div>
<%@ include file="footer.jsp"%>