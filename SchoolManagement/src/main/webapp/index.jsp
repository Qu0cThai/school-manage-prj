<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ include file="header.jsp"%>
<%@ include file="/WEB-INF/jspf/db-connection.jsp"%>
<%@ page import="java.sql.*" %>
<div class="container">
    <!-- Debug Output -->
    <%
        Integer userRId = (Integer) session.getAttribute("userRId");
        out.println("<!-- Debug: userRId = " + (userRId != null ? userRId : "null") + ", username = " + (username != null ? username : "null") + " -->");
    %>
    <!-- Jumbotron -->
    <div class="jumbotron jumbotron-fluid">
        <div class="container">
            <h1 class="display-4">Welcome<%= username != null ? ", " + username : "" %>..</h1>
            <p class="lead">This is a modified jumbotron that occupies the entire horizontal space of its parent.</p>
        </div>
    </div>
    <!-- Body -->
    <div class="row">
        <!-- Sidebar for Teacher or Admin -->
        <%
            if (userRId != null && (userRId == 1 || userRId == 2)) {
                try {
        %>
            <div class="col-12 col-md-3">
                <%
                    if (userRId == 2) { // Teacher
                        Connection conn = null;
                        Statement stmt = null;
                        ResultSet rs = null;
                        int totalStudents = 0, totalTeachers = 0, totalEmployees = 0;
                        try {
                            conn = getConnection();
                            stmt = conn.createStatement();
                            // Count students
                            rs = stmt.executeQuery("SELECT COUNT(*) AS count FROM students");
                            if (rs.next()) totalStudents = rs.getInt("count");
                            rs.close();
                            // Count teachers
                            rs = stmt.executeQuery("SELECT COUNT(*) AS count FROM teachers");
                            if (rs.next()) totalTeachers = rs.getInt("count");
                            rs.close();
                            // Count employees (users who are not students or teachers)
                            rs = stmt.executeQuery("SELECT COUNT(*) AS count FROM users WHERE r_id NOT IN (2, 3)");
                            if (rs.next()) totalEmployees = rs.getInt("count");
                        } catch (Exception e) {
                            out.println("<p>Error fetching counts: " + e.getMessage() + "</p>");
                        } finally {
                            closeResources(conn, stmt, rs);
                        }
                %>
                    <!-- Teacher Sidebar -->
                    <div class="list-group">
                        <a href="attendance.jsp" class="list-group-item list-group-item-action">Attendance</a>
                        <a href="result.jsp" class="list-group-item list-group-item-action">Result</a>
                        <a href="classes.jsp" class="list-group-item list-group-item-action">Classes</a>
                    </div>
                <%
                    } else if (userRId == 1) { // Admin
                %>
                    <!-- Admin Sidebar -->
                    <div class="list-group">
                        <a href="session.jsp" class="list-group-item list-group-item-action">Session</a>
                        <a href="manageNotice.jsp" class="list-group-item list-group-item-action">Notice</a>
                        <a href="subject.jsp" class="list-group-item list-group-item-action">Subject</a>
                        <a href="classes.jsp" class="list-group-item list-group-item-action">Classes</a>
                        <a href="manageTeacher.jsp" class="list-group-item list-group-item-action">Teachers Information</a>
                        <a href="manageStudent.jsp" class="list-group-item list-group-item-action">Students Information</a>
                    </div>
                <%
                    }
                %>
            </div>
        <%
                } catch (Exception e) {
                    out.println("<p>Error rendering sidebar: " + e.getMessage() + "</p>");
                }
            } else {
                out.println("<!-- Debug: No sidebar shown, userRId is " + (userRId != null ? userRId : "null") + " -->");
            }
        %>
        <!-- Notice Board -->
        <div class="<%= (userRId == null || userRId == 3) ? "col-12 col-md-12" : "col-12 col-md-9" %>">
            <button type="button" class="btn btn-secondary btn-lg btn-block">Notice Board</button>
            <div class="list-group">
                <%
                    Connection conn = null;
                    Statement stmt = null;
                    ResultSet rs = null;
                    try {
                        conn = getConnection();
                        stmt = conn.createStatement();
                        String sql = "SELECT n.n_title, n.n_description, n.publish_date, u.u_name " +
                                    "FROM notices n JOIN users u ON n.created_by = u.u_id " +
                                    "ORDER BY n.publish_date DESC LIMIT 3";
                        rs = stmt.executeQuery(sql);
                        while (rs.next()) {
                            String title = rs.getString("n_title");
                            String description = rs.getString("n_description");
                            String publishDate = rs.getString("publish_date");
                            String createdBy = rs.getString("u_name");
                %>
                <a class="list-group-item list-group-item-action">
                    <div>
                        <h4>⇛ <%= title %></h4>
                        Description: <%= description != null ? description : "No description available" %><br/>
                        <small>Publish Date: <%= publishDate %> | Posted by: <%= createdBy %></small>
                    </div>
                </a>
                <%
                        }
                    } catch (Exception e) {
                        out.println("<p>Error fetching notices: " + e.getMessage() + "</p>");
                    } finally {
                        closeResources(conn, stmt, rs);
                    }
                %>
                <a class="list-group-item list-group-item-action" href="noticeBoard.jsp">
                    <div>
                        <small style="padding-left:120px">See More..</small>
                    </div>
                </a>
            </div>
        </div>
    </div>
</div>
<%@ include file="footer.jsp"%>
</html>