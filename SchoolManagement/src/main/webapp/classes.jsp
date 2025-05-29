<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ include file="header.jsp"%>
<%@ include file="/WEB-INF/jspf/db-connection.jsp"%>
<%@ page import="java.sql.*" %>
<%
    // Get user info
    Integer userRId = (Integer) session.getAttribute("userRId");
    if (userRId == null || username == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    // Get s_id for students
    String userId = "";
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    if (userRId == 3) {
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
    }

    // Handle registration or drop
    String message = "";
    if ("POST".equalsIgnoreCase(request.getMethod()) && userRId == 3) {
        String classId = request.getParameter("class_id");
        String action = request.getParameter("action");
        try {
            conn = getConnection();
            if ("register".equals(action)) {
                // Check if class exists
                pstmt = conn.prepareStatement("SELECT 1 FROM classes WHERE class_id = ?");
                pstmt.setString(1, classId);
                rs = pstmt.executeQuery();
                if (!rs.next()) {
                    message = "<div class='alert alert-danger'>Class ID " + classId + " does not exist.</div>";
                    throw new Exception("Invalid class");
                }
                rs.close();
                pstmt.close();

                // Check if already registered
                pstmt = conn.prepareStatement("SELECT 1 FROM student_classes WHERE s_id = ? AND class_id = ?");
                pstmt.setString(1, userId);
                pstmt.setString(2, classId);
                rs = pstmt.executeQuery();
                if (rs.next()) {
                    message = "<div class='alert alert-warning'>You are already registered for class " + classId + ".</div>";
                    throw new Exception("Already registered");
                }
                rs.close();
                pstmt.close();

                // Register student
                pstmt = conn.prepareStatement("INSERT INTO student_classes (s_id, class_id) VALUES (?, ?)");
                pstmt.setString(1, userId);
                pstmt.setString(2, classId);
                pstmt.executeUpdate();
                message = "<div class='alert alert-success'>Successfully registered for class " + classId + "!</div>";
            } else if ("drop".equals(action)) {
                // Check if registered
                pstmt = conn.prepareStatement("SELECT 1 FROM student_classes WHERE s_id = ? AND class_id = ?");
                pstmt.setString(1, userId);
                pstmt.setString(2, classId);
                rs = pstmt.executeQuery();
                if (!rs.next()) {
                    message = "<div class='alert alert-warning'>You are not registered for class " + classId + ".</div>";
                    throw new Exception("Not registered");
                }
                rs.close();
                pstmt.close();

                // Drop class
                pstmt = conn.prepareStatement("DELETE FROM student_classes WHERE s_id = ? AND class_id = ?");
                pstmt.setString(1, userId);
                pstmt.setString(2, classId);
                pstmt.executeUpdate();
                message = "<div class='alert alert-success'>Successfully dropped class " + classId + ".</div>";
            }
        } catch (Exception e) {
            if (message.isEmpty()) {
                message = "<div class='alert alert-danger'>Error processing request: " + e.getMessage() + "</div>";
            }
        } finally {
            closeResources(conn, pstmt, rs);
        }
    }
%>
<div class="container">
    <h1>Classes</h1>
    <%= message %>
    <div class="table-responsive">
        <table class="table table-bordered">
            <thead>
                <tr>
                    <th>Class ID</th>
                    <th>Subject</th>
                    <th>Room</th>
                    <th>Teacher</th>
                    <th>Time</th>
                    <th>Day</th>
                    <th>Session</th>
                    <th>Semester</th>
                    <% if (userRId == 3) { %>
                    <th>Action</th>
                    <% } %>
                </tr>
            </thead>
            <tbody>
                <%
                    try {
                        conn = getConnection();
                        pstmt = conn.prepareStatement(
                            "SELECT c.class_id, c.subject, c.room, t.t_name, c.time_begin, c.time_end, c.day_of_week, c.academic_session, c.semester " +
                            "FROM classes c JOIN teachers t ON c.t_id = t.t_id"
                        );
                        rs = pstmt.executeQuery();
                        while (rs.next()) {
                            String classId = rs.getString("class_id");
                            String timeBegin = rs.getString("time_begin").substring(0, 5); // Format 08:00
                            String timeEnd = rs.getString("time_end").substring(0, 5);   // Format 20:00
                            String time = timeBegin + "–" + timeEnd;
                            boolean isRegistered = false;
                            if (userRId == 3) {
                                PreparedStatement checkStmt = conn.prepareStatement(
                                    "SELECT 1 FROM student_classes WHERE s_id = ? AND class_id = ?"
                                );
                                checkStmt.setString(1, userId);
                                checkStmt.setString(2, classId);
                                ResultSet checkRs = checkStmt.executeQuery();
                                isRegistered = checkRs.next();
                                checkRs.close();
                                checkStmt.close();
                            }
                %>
                <tr>
                    <td><%= classId %></td>
                    <td><%= rs.getString("subject") %></td>
                    <td><%= rs.getString("room") %></td>
                    <td><%= rs.getString("t_name") %></td>
                    <td><%= time %></td>
                    <td><%= rs.getString("day_of_week") %></td>
                    <td><%= rs.getString("academic_session") %></td>
                    <td><%= rs.getString("semester") %></td>
                    <% if (userRId == 3) { %>
                    <td>
                        <% if (isRegistered) { %>
                        <form method="POST" action="classes.jsp" style="display:inline;">
                            <input type="hidden" name="class_id" value="<%= classId %>">
                            <input type="hidden" name="action" value="drop">
                            <button type="submit" class="btn btn-danger btn-sm">Drop</button>
                        </form>
                        <% } else { %>
                        <form method="POST" action="classes.jsp" style="display:inline;">
                            <input type="hidden" name="class_id" value="<%= classId %>">
                            <input type="hidden" name="action" value="register">
                            <button type="submit" class="btn btn-primary btn-sm">Register</button>
                        </form>
                        <% } %>
                    </td>
                    <% } %>
                </tr>
                <%
                        }
                    } catch (Exception e) {
                        out.println("<tr><td colspan='" + (userRId == 3 ? 9 : 8) + "'>Error: " + e.getMessage() + "</td></tr>");
                    } finally {
                        closeResources(conn, pstmt, rs);
                    }
                %>
            </tbody>
        </table>
    </div>
</div>
<%@ include file="footer.jsp"%>