<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ include file="header.jsp"%>
<%@ include file="/WEB-INF/jspf/db-connection.jsp"%>
<%@ page import="java.sql.*" %>
<%
    // Get user info
    String u_id = (String) session.getAttribute("u_id");
    String u_name = (String) session.getAttribute("u_name");
    Integer userRId = (Integer) session.getAttribute("userRId");

    // Fetch u_name if not in session
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    if (u_id != null && u_name == null) {
        try {
            conn = getConnection();
            pstmt = conn.prepareStatement("SELECT u_name FROM users WHERE u_id = ?");
            pstmt.setString(1, u_id);
            rs = pstmt.executeQuery();
            if (rs.next()) {
                u_name = rs.getString("u_name");
                session.setAttribute("u_name", u_name);
            }
        } catch (Exception e) {
            out.println("<div class='alert alert-danger'>Error fetching username: " + e.getMessage() + "</div>");
        } finally {
            closeResources(conn, pstmt, rs);
        }
    }

    if (u_id == null || u_name == null || userRId == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    // Get s_id for students
    String userId = u_id;
    if (userRId == 3) {
        try {
            conn = getConnection();
            pstmt = conn.prepareStatement("SELECT u_id FROM users WHERE u_id = ? AND r_id = ?");
            pstmt.setString(1, u_id);
            pstmt.setInt(2, userRId);
            rs = pstmt.executeQuery();
            if (!rs.next()) {
                out.println("<div class='alert alert-danger'>Error: User ID not found for user " + u_name + "</div>");
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

                // Check for time conflict
                pstmt = conn.prepareStatement(
                    "SELECT 1 " +
                    "FROM student_classes sc " +
                    "JOIN classes c ON sc.class_id = c.class_id " +
                    "WHERE sc.s_id = ? " +
                    "AND c.day_of_week = (SELECT day_of_week FROM classes WHERE class_id = ?) " +
                    "AND c.semester = (SELECT semester FROM classes WHERE class_id = ?) " +
                    "AND c.academic_session = (SELECT academic_session FROM classes WHERE class_id = ?) " +
                    "AND c.time_begin < (SELECT time_end FROM classes WHERE class_id = ?) " +
                    "AND c.time_end > (SELECT time_begin FROM classes WHERE class_id = ?)"
                );
                pstmt.setString(1, userId);
                pstmt.setString(2, classId);
                pstmt.setString(3, classId);
                pstmt.setString(4, classId);
                pstmt.setString(5, classId);
                pstmt.setString(6, classId);
                rs = pstmt.executeQuery();
                if (rs.next()) {
                    message = "<div class='alert alert-danger'>Time conflict with another registered class.</div>";
                    throw new Exception("Time conflict");
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
                            String timeBegin = rs.getString("time_begin").substring(0, 5);
                            String timeEnd = rs.getString("time_end").substring(0, 5);
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