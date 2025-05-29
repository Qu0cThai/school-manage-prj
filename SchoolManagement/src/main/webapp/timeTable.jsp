<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ include file="header.jsp"%>
<%@ include file="/WEB-INF/jspf/db-connection.jsp"%>
<%@ page import="java.sql.*, java.time.*" %>
<%
    // Restrict access to logged-in users (r_id=1, 2, 3)
    Integer userRId = (Integer) session.getAttribute("userRId");
    // Note: 'username' is assumed to be defined in header.jsp
    if (userRId == null || username == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    // Get user's u_id (matches t_id for r_id=2, s_id for r_id=3)
    String userId = "";
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    try {
        conn = getConnection();
        pstmt = conn.prepareStatement("SELECT u_id FROM users WHERE LOWER(u_name) = LOWER(?) AND r_id = ?");
        pstmt.setString(1, username);
        pstmt.setInt(2, userRId);
        rs = pstmt.executeQuery();
        if (rs.next()) {
            userId = rs.getString("u_id");
        } else {
            out.println("<div class='alert alert-danger'>Error: User ID not found for username " + username + "</div>");
            return;
        }
    } catch (Exception e) {
        out.println("<div class='alert alert-danger'>Error fetching user ID: " + e.getMessage() + "</div>");
        return;
    } finally {
        closeResources(conn, pstmt, rs);
    }
%>
<div class="container">
    <!-- Debug Output -->
    <%
        out.println("<!-- Debug: userRId = " + (userRId != null ? userRId : "null") + ", username = " + (username != null ? username : "null") + ", userId = " + userId + " -->");
    %>
    <!-- Jumbotron -->
    <div class="jumbotron jumbotron-fluid">
        <div class="container">
            <h1 class="display-4">Your Timetable, <%= username %>!</h1>
            <p class="lead">
                <% if (userRId == 1) { %>View all classes<% } %>
                <% if (userRId == 2) { %>View your teaching schedule<% } %>
                <% if (userRId == 3) { %>View your registered classes<% } %>
            </p>
        </div>
    </div>
    <!-- Timetable -->
    <div class="row">
        <div class="col-12">
            <h3>Weekly Timetable</h3>
            <div class="table-responsive">
                <table class="table table-bordered">
                    <thead>
                        <tr>
                            <th>Time</th>
                            <th>Monday</th>
                            <th>Tuesday</th>
                            <th>Wednesday</th>
                            <th>Thursday</th>
                            <th>Friday</th>
                            <th>Saturday</th>
                            <th>Sunday</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            String[] days = {"Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"};
                            for (int hour = 7; hour <= 22; hour++) {
                                String timeSlot = String.format("%02d:00", hour);
                        %>
                        <tr>
                            <td><%= timeSlot %></td>
                            <%
                                for (String day : days) {
                                    String sql = "";
                                    if (userRId == 1) {
                                        sql = "SELECT class_id, subject, room, time_begin, time_end FROM classes WHERE day_of_week = ? AND ? >= time_begin AND ? <= time_end";
                                    } else if (userRId == 2) {
                                        sql = "SELECT class_id, subject, room, time_begin, time_end FROM classes WHERE t_id = ? AND day_of_week = ? AND ? >= time_begin AND ? <= time_end";
                                    } else if (userRId == 3) {
                                        sql = "SELECT c.class_id, c.subject, c.room, c.time_begin, c.time_end FROM classes c JOIN student_classes sc ON c.class_id = sc.class_id WHERE sc.s_id = ? AND c.day_of_week = ? AND ? >= time_begin AND ? <= time_end";
                                    }
                                    try {
                                        conn = getConnection();
                                        pstmt = conn.prepareStatement(sql);
                                        if (userRId == 1) {
                                            pstmt.setString(1, day);
                                            pstmt.setString(2, timeSlot);
                                            pstmt.setString(3, timeSlot);
                                        } else {
                                            pstmt.setString(1, userId);
                                            pstmt.setString(2, day);
                                            pstmt.setString(3, timeSlot);
                                            pstmt.setString(4, timeSlot);
                                        }
                                        // Debug query parameters
                                        out.println("<!-- Debug Query: sql=" + sql + ", params=[" + (userRId != 1 ? userId + "," : "") + day + "," + timeSlot + "] -->");
                                        rs = pstmt.executeQuery();
                                        StringBuilder classInfo = new StringBuilder();
                                        while (rs.next()) {
                                            String timeBegin = rs.getString("time_begin").substring(0, 5); // Format 08:00
                                            String timeEnd = rs.getString("time_end").substring(0, 5);   // Format 20:00
                                            classInfo.append(rs.getString("subject")).append("<br>")
                                                     .append(rs.getString("room")).append("<br>")
                                                     .append(timeBegin).append("–").append(timeEnd).append("<br>");
                                        }
                            %>
                            <td><%= classInfo.length() > 0 ? classInfo.toString() : "" %></td>
                            <%
                                    } catch (Exception e) {
                                        out.println("<td>Error: " + e.getMessage() + "</td>");
                                    } finally {
                                        closeResources(conn, pstmt, rs);
                                    }
                                }
                            %>
                        </tr>
                        <%
                            }
                        %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>
<%@ include file="footer.jsp"%>