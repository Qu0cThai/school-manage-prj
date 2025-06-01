<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ include file="header.jsp"%>
<%@ include file="/WEB-INF/jspf/db-connection.jsp"%>
<%@ page import="java.sql.*" %>
<style>
    .list-group-item {
        background: #f8f9fa;
        border: none;
        transition: all 0.3s ease;
    }
    .list-group-item:hover {
        background: linear-gradient(90deg, #4facfe, #00f2fe);
        color: white !important;
        transform: translateX(5px);
    }
    .sidebar {
        background: linear-gradient(180deg, #e0f7fa, #b2ebf2);
        border-radius: 10px;
        padding: 10px;
        box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
    }
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
    i {
        color: #4facfe;
    }
    .list-group-item:hover i {
        color: white;
    }
    h3 {
        text-align: center;
    }
</style>
<div class="container mt-4">
    <%        Integer userRId = (Integer) session.getAttribute("userRId");
        out.println("<!-- Debug: userRId = " + (userRId != null ? userRId : "null") + ", username = " + (username != null ? username : "null") + " -->");
    %>
    <div class="row">
        <%
            if (userRId != null && (userRId == 1 || userRId == 2 || userRId == 3)) {
                try {
        %>
        <div class="col-12 col-md-3 mb-4">
            <div class="sidebar">
                <%
                    if (userRId == 1) {
                %>
                <h3 class="text-primary">Admin Dashboard</h3>
                <div class="list-group">
                    <a href="manageNotice.jsp" class="list-group-item list-group-item-action"><i class="fas fa-bell me-2"></i>Manage Notice</a>
                    <a href="classes.jsp" class="list-group-item list-group-item-action"><i class="fas fa-user-graduate me-2"></i>Classes</a>
                    <a href="teacherInformation.jsp" class="list-group-item list-group-item-action"><i class="fas fa-user-tie me-2"></i>Teachers Information</a>
                    <a href="studentInformation.jsp" class="list-group-item list-group-item-action"><i class="fas fa-user-graduate me-2"></i>Students Information</a>         
                </div>
                <%
                } else if (userRId == 2) { 
                    Connection conn = null;
                    Statement stmt = null;
                    ResultSet rs = null;
                    int totalStudents = 0, totalTeachers = 0, totalEmployees = 0;
                    try {
                        conn = getConnection();
                        stmt = conn.createStatement();
                        rs = stmt.executeQuery("SELECT COUNT(*) AS count FROM students");
                        if (rs.next()) {
                            totalStudents = rs.getInt("count");
                        }
                        rs.close();
                        rs = stmt.executeQuery("SELECT COUNT(*) AS count FROM teachers");
                        if (rs.next()) {
                            totalTeachers = rs.getInt("count");
                        }
                        rs.close();
                        rs = stmt.executeQuery("SELECT COUNT(*) AS count FROM users WHERE r_id NOT IN (2, 3)");
                        if (rs.next()) {
                            totalEmployees = rs.getInt("count");
                        }
                    } catch (Exception e) {
                        out.println("<p>Error fetching counts: " + e.getMessage() + "</p>");
                    } finally {
                        closeResources(conn, stmt, rs);
                    }
                %>
                <h3 class="text-success">Teacher Dashboard</h3>
                <div class="list-group">
                    <a href="manageClasses.jsp" class="list-group-item list-group-item-action"><i class="fas fa-chalkboard me-2"></i>Manage Classes</a>
                    <a href="timeTable.jsp" class="list-group-item list-group-item-action"><i class="fas fa-calendar-alt me-2"></i>Timetable</a>
                    <a href="teacherInformation.jsp" class="list-group-item list-group-item-action"><i class="fas fa-user-tie me-2"></i>Teachers Information</a>
                    <a href="studentInformation.jsp" class="list-group-item list-group-item-action"><i class="fas fa-user-graduate me-2"></i>Students Information</a>                            
                </div>
                <%
                } else if (userRId == 3) {
                %>
                <h3 class="text-info">Student Dashboard</h3>
                <div class="list-group">
                    <a href="classes.jsp" class="list-group-item list-group-item-action"><i class="fas fa-chalkboard me-2"></i>Classes</a>
                    <a href="timeTable.jsp" class="list-group-item list-group-item-action"><i class="fas fa-calendar-alt me-2"></i>Timetable</a>
                    <a href="teacherInformation.jsp" class="list-group-item list-group-item-action"><i class="fas fa-user-tie me-2"></i>Teachers Information</a>
                    <a href="studentInformation.jsp" class="list-group-item list-group-item-action"><i class="fas fa-user-graduate me-2"></i>Students Information</a> 
                </div>
                <%
                    }
                %>
            </div>
        </div>
        <%
                } catch (Exception e) {
                    out.println("<p>Error rendering sidebar: " + e.getMessage() + "</p>");
                }
            }
        %>
        <div class="<%= (userRId == null) ? "col-12 col-md-12" : "col-12 col-md-9"%>">
            <div class="notice-board">
                <button type="button" class="btn btn-secondary btn-lg btn-block">Notice Board</button>
                <div class="list-group mt-3">
                    <%
                        Connection conn = null;
                        Statement stmt = null;
                        ResultSet rs = null;
                        try {
                            conn = getConnection();
                            stmt = conn.createStatement();
                            String sql = "SELECT n.n_title, n.n_description, n.publish_date, u.u_name "
                                    + "FROM notices n JOIN users u ON n.created_by = u.u_id "
                                    + "ORDER BY n.publish_date DESC LIMIT 3";
                            rs = stmt.executeQuery(sql);
                            while (rs.next()) {
                                String title = rs.getString("n_title");
                                String description = rs.getString("n_description");
                                String publishDate = rs.getString("publish_date");
                                String createdBy = rs.getString("u_name");
                    %>
                    <a class="list-group-item list-group-item-action">
                        <div>
                            <h4 class="text-primary">⇛ <%= title%></h4>
                            <p class="text-muted">Description: <%= description != null ? description : "No description available"%></p>
                            <small class="text-secondary">Publish Date: <%= publishDate%> | Posted by: <%= createdBy%></small>
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
                    <a class="list-group-item list-group-item-action text-center" href="noticeBoard.jsp">
                        <small class="list-group-item list-group-item-action" style="padding-left:0">See More..</small>
                    </a>
                </div>
            </div>
        </div>
    </div>
</div>
<%@ include file="footer.jsp"%>
</html>