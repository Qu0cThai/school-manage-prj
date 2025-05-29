<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ include file="header.jsp"%>
<%@ include file="/WEB-INF/jspf/db-connection.jsp"%>
<%@ page import="java.sql.*" %>
<%
    // Restrict access to admins (r_id=1)
    Integer userRId = (Integer) session.getAttribute("userRId");
    if (userRId == null || username == null || userRId != 1) {
        response.sendRedirect("index.jsp");
        return;
    }

    // Handle form submissions and edit form display
    String message = "";
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    // Check for edit form display
    String action = request.getParameter("action");
    String editClassId = request.getParameter("class_id");
    boolean showEditForm = "edit".equals(action) && editClassId != null;
    String editSubject = "", editRoom = "", editTeacherName = "", editTimeBegin = "", editTimeEnd = "";
    String editDayOfWeek = "", editAcademicSession = "", editSemester = "";

    if (showEditForm) {
        try {
            conn = getConnection();
            pstmt = conn.prepareStatement(
                "SELECT c.class_id, c.subject, c.room, t.t_name, c.time_begin, c.time_end, c.day_of_week, c.academic_session, c.semester " +
                "FROM classes c JOIN teachers t ON c.t_id = t.t_id WHERE c.class_id = ?"
            );
            pstmt.setString(1, editClassId);
            rs = pstmt.executeQuery();
            if (rs.next()) {
                editSubject = rs.getString("subject");
                editRoom = rs.getString("room");
                editTeacherName = rs.getString("t_name");
                editTimeBegin = rs.getString("time_begin");
                editTimeEnd = rs.getString("time_end");
                editDayOfWeek = rs.getString("day_of_week");
                editAcademicSession = rs.getString("academic_session");
                editSemester = rs.getString("semester");
            } else {
                message = "<div class='alert alert-danger'>Class ID " + editClassId + " not found.</div>";
                showEditForm = false;
            }
        } catch (Exception e) {
            message = "<div class='alert alert-danger'>Error loading class: " + e.getMessage() + "</div>";
            showEditForm = false;
        } finally {
            closeResources(conn, pstmt, rs);
        }
    }

    // Handle POST requests
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        try {
            conn = getConnection();
            action = request.getParameter("action");
            if ("add".equals(action)) {
                String classId = request.getParameter("class_id");
                String subject = request.getParameter("subject");
                String room = request.getParameter("room");
                String teacherName = request.getParameter("teacher_name");
                String timeBegin = request.getParameter("time_begin");
                String timeEnd = request.getParameter("time_end");
                String dayOfWeek = request.getParameter("day_of_week");
                String academicSession = request.getParameter("academic_session");
                String semester = request.getParameter("semester");

                // Validate teacher name and get t_id
                String tId = "";
                pstmt = conn.prepareStatement("SELECT t_id FROM teachers WHERE t_name = ?");
                pstmt.setString(1, teacherName);
                rs = pstmt.executeQuery();
                if (rs.next()) {
                    tId = rs.getString("t_id");
                } else {
                    message = "<div class='alert alert-danger'>Teacher name not found: " + teacherName + "</div>";
                    throw new Exception("Invalid teacher name");
                }
                rs.close();
                pstmt.close();

                // Insert class
                pstmt = conn.prepareStatement(
                    "INSERT INTO classes (class_id, subject, room, t_id, time_begin, time_end, academic_session, semester, day_of_week) " +
                    "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)"
                );
                pstmt.setString(1, classId);
                pstmt.setString(2, subject);
                pstmt.setString(3, room);
                pstmt.setString(4, tId);
                pstmt.setString(5, timeBegin);
                pstmt.setString(6, timeEnd);
                pstmt.setString(7, academicSession);
                pstmt.setInt(8, Integer.parseInt(semester));
                pstmt.setString(9, dayOfWeek);
                pstmt.executeUpdate();
                message = "<div class='alert alert-success'>Class added successfully!</div>";
            } else if ("update".equals(action)) {
                String classId = request.getParameter("class_id");
                String subject = request.getParameter("subject");
                String room = request.getParameter("room");
                String teacherName = request.getParameter("teacher_name");
                String timeBegin = request.getParameter("time_begin");
                String timeEnd = request.getParameter("time_end");
                String dayOfWeek = request.getParameter("day_of_week");
                String academicSession = request.getParameter("academic_session");
                String semester = request.getParameter("semester");

                // Validate teacher name and get t_id
                String tId = "";
                pstmt = conn.prepareStatement("SELECT t_id FROM teachers WHERE t_name = ?");
                pstmt.setString(1, teacherName);
                rs = pstmt.executeQuery();
                if (rs.next()) {
                    tId = rs.getString("t_id");
                } else {
                    message = "<div class='alert alert-danger'>Teacher name not found: " + teacherName + "</div>";
                    throw new Exception("Invalid teacher name");
                }
                rs.close();
                pstmt.close();

                // Update class
                pstmt = conn.prepareStatement(
                    "UPDATE classes SET subject = ?, room = ?, t_id = ?, time_begin = ?, time_end = ?, academic_session = ?, semester = ?, day_of_week = ? " +
                    "WHERE class_id = ?"
                );
                pstmt.setString(1, subject);
                pstmt.setString(2, room);
                pstmt.setString(3, tId);
                pstmt.setString(4, timeBegin);
                pstmt.setString(5, timeEnd);
                pstmt.setString(6, academicSession);
                pstmt.setInt(7, Integer.parseInt(semester));
                pstmt.setString(8, dayOfWeek);
                pstmt.setString(9, classId);
                int rows = pstmt.executeUpdate();
                if (rows > 0) {
                    message = "<div class='alert alert-success'>Class " + classId + " updated successfully!</div>";
                } else {
                    message = "<div class='alert alert-danger'>Class ID " + classId + " not found.</div>";
                }
            } else if ("delete".equals(action)) {
                String classId = request.getParameter("class_id");
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

                // Delete from student_classes first
                pstmt = conn.prepareStatement("DELETE FROM student_classes WHERE class_id = ?");
                pstmt.setString(1, classId);
                pstmt.executeUpdate();
                pstmt.close();

                // Delete class
                pstmt = conn.prepareStatement("DELETE FROM classes WHERE class_id = ?");
                pstmt.setString(1, classId);
                pstmt.executeUpdate();
                message = "<div class='alert alert-success'>Class " + classId + " deleted successfully!</div>";
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
    <!-- Jumbotron -->
    <div class="jumbotron jumbotron-fluid">
        <div class="container">
            <h1 class="display-4">Manage Classes</h1>
            <p class="lead">Add, edit, or delete classes for the academic session.</p>
        </div>
    </div>
    <%= message %>
    <!-- Edit Class Form (if editing) -->
    <% if (showEditForm) { %>
    <h3>Edit Class <%= editClassId %></h3>
    <form method="POST" action="manageClasses.jsp">
        <input type="hidden" name="action" value="update">
        <input type="hidden" name="class_id" value="<%= editClassId %>">
        <div class="form-group">
            <label>Subject</label>
            <input type="text" name="subject" class="form-control" value="<%= editSubject %>" required>
        </div>
        <div class="form-group">
            <label>Room</label>
            <input type="text" name="room" class="form-control" value="<%= editRoom %>" required>
        </div>
        <div class="form-group">
            <label>Teacher Name</label>
            <select name="teacher_name" class="form-control" required>
                <option value="">Select Teacher</option>
                <%
                    try {
                        conn = getConnection();
                        pstmt = conn.prepareStatement("SELECT t_name FROM teachers ORDER BY t_name");
                        rs = pstmt.executeQuery();
                        while (rs.next()) {
                            String tName = rs.getString("t_name");
                            String selected = tName.equals(editTeacherName) ? "selected" : "";
                            out.println("<option value='" + tName + "' " + selected + ">" + tName + "</option>");
                        }
                    } catch (Exception e) {
                        out.println("<option>Error: " + e.getMessage() + "</option>");
                    } finally {
                        closeResources(conn, pstmt, rs);
                    }
                %>
            </select>
        </div>
        <div class="form-group">
            <label>Time Begin</label>
            <input type="time" name="time_begin" class="form-control" value="<%= editTimeBegin %>" required>
        </div>
        <div class="form-group">
            <label>Time End</label>
            <input type="time" name="time_end" class="form-control" value="<%= editTimeEnd %>" required>
        </div>
        <div class="form-group">
            <label>Day of Week</label>
            <select name="day_of_week" class="form-control" required>
                <%
                    String[] days = {"Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"};
                    for (String day : days) {
                        String selected = day.equals(editDayOfWeek) ? "selected" : "";
                        out.println("<option value='" + day + "' " + selected + ">" + day + "</option>");
                    }
                %>
            </select>
        </div>
        <div class="form-group">
            <label>Academic Session</label>
            <input type="text" name="academic_session" class="form-control" value="<%= editAcademicSession %>" required>
        </div>
        <div class="form-group">
            <label>Semester</label>
            <select name="semester" class="form-control" required>
                <%
                    for (int i = 1; i <= 3; i++) {
                        String selected = String.valueOf(i).equals(editSemester) ? "selected" : "";
                        out.println("<option value='" + i + "' " + selected + ">" + i + "</option>");
                    }
                %>
            </select>
        </div>
        <button type="submit" class="btn btn-primary">Update Class</button>
        <a href="manageClasses.jsp" class="btn btn-secondary">Cancel</a>
    </form>
    <% } else { %>
    <!-- Add Class Form -->
    <h3>Add New Class</h3>
    <form method="POST" action="manageClasses.jsp">
        <input type="hidden" name="action" value="add">
        <div class="form-group">
            <label>Class ID</label>
            <input type="text" name="class_id" class="form-control" required>
        </div>
        <div class="form-group">
            <label>Subject</label>
            <input type="text" name="subject" class="form-control" required>
        </div>
        <div class="form-group">
            <label>Room</label>
            <input type="text" name="room" class="form-control" required>
        </div>
        <div class="form-group">
            <label>Teacher Name</label>
            <select name="teacher_name" class="form-control" required>
                <option value="">Select Teacher</option>
                <%
                    try {
                        conn = getConnection();
                        pstmt = conn.prepareStatement("SELECT t_name FROM teachers ORDER BY t_name");
                        rs = pstmt.executeQuery();
                        while (rs.next()) {
                            String tName = rs.getString("t_name");
                            out.println("<option value='" + tName + "'>" + tName + "</option>");
                        }
                    } catch (Exception e) {
                        out.println("<option>Error: " + e.getMessage() + "</option>");
                    } finally {
                        closeResources(conn, pstmt, rs);
                    }
                %>
            </select>
        </div>
        <div class="form-group">
            <label>Time Begin</label>
            <input type="time" name="time_begin" class="form-control" required>
        </div>
        <div class="form-group">
            <label>Time End</label>
            <input type="time" name="time_end" class="form-control" required>
        </div>
        <div class="form-group">
            <label>Day of Week</label>
            <select name="day_of_week" class="form-control" required>
                <option value="Monday">Monday</option>
                <option value="Tuesday">Tuesday</option>
                <option value="Wednesday">Wednesday</option>
                <option value="Thursday">Thursday</option>
                <option value="Friday">Friday</option>
                <option value="Saturday">Saturday</option>
                <option value="Sunday">Sunday</option>
            </select>
        </div>
        <div class="form-group">
            <label>Academic Session</label>
            <input type="text" name="academic_session" class="form-control" value="2024-2025" required>
        </div>
        <div class="form-group">
            <label>Semester</label>
            <select name="semester" class="form-control" required>
                <option value="1">1</option>
                <option value="2">2</option>
                <option value="3">3</option>
            </select>
        </div>
        <button type="submit" class="btn btn-primary">Add Class</button>
    </form>
    <% } %>

    <!-- Classes Table -->
    <h3 class="mt-5">Existing Classes</h3>
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
                    <th>Actions</th>
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
                    <td>
                        <a href="manageClasses.jsp?action=edit&class_id=<%= classId %>" class="btn btn-warning btn-sm">Edit</a>
                        <form method="POST" action="manageClasses.jsp" style="display:inline;">
                            <input type="hidden" name="action" value="delete">
                            <input type="hidden" name="class_id" value="<%= classId %>">
                            <button type="submit" class="btn btn-danger btn-sm" onclick="return confirm('Are you sure you want to delete class <%= classId %>?');">Delete</button>
                        </form>
                    </td>
                </tr>
                <%
                        }
                    } catch (Exception e) {
                        out.println("<tr><td colspan='9'>Error: " + e.getMessage() + "</td></tr>");
                    } finally {
                        closeResources(conn, pstmt, rs);
                    }
                %>
            </tbody>
        </table>
    </div>
</div>
<%@ include file="footer.jsp"%>