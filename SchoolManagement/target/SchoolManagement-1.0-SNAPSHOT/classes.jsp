<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ include file="header.jsp"%>
<%@ include file="/WEB-INF/jspf/db-connection.jsp"%>
<%@ page import="java.sql.*" %>
<%
    String u_id = (String) session.getAttribute("u_id");
    String u_name = (String) session.getAttribute("u_name");
    Integer userRId = (Integer) session.getAttribute("userRId");

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
            out.println("<div class='alert alert-danger text-center'>Error fetching username: " + e.getMessage() + "</div>");
        } finally {
            closeResources(conn, pstmt, rs);
        }
    }

    if (u_id == null || u_name == null || userRId == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String userId = u_id;
    if (userRId == 3) {
        try {
            conn = getConnection();
            pstmt = conn.prepareStatement("SELECT u_id FROM users WHERE u_id = ? AND r_id = ?");
            pstmt.setString(1, u_id);
            pstmt.setInt(2, userRId);
            rs = pstmt.executeQuery();
            if (!rs.next()) {
                out.println("<div class='alert alert-danger text-center'>Error: User ID not found for user " + u_name + "</div>");
                return;
            }
        } catch (Exception e) {
            out.println("<div class='alert alert-danger text-center'>Error fetching user ID: " + e.getMessage() + "</div>");
            return;
        } finally {
            closeResources(conn, pstmt, rs);
        }
    }

    String message = "";
    if ("POST".equalsIgnoreCase(request.getMethod()) && userRId == 3) {
        String classId = request.getParameter("class_id");
        String action = request.getParameter("action");
        try {
            conn = getConnection();
            if ("register".equals(action)) {
                pstmt = conn.prepareStatement("SELECT 1 FROM classes WHERE class_id = ?");
                pstmt.setString(1, classId);
                rs = pstmt.executeQuery();
                if (!rs.next()) {
                    message = "<div class='alert alert-danger text-center'>Class ID " + classId + " does not exist.</div>";
                    throw new Exception("Invalid class");
                }
                rs.close();
                pstmt.close();

                pstmt = conn.prepareStatement("SELECT 1 FROM student_classes WHERE s_id = ? AND class_id = ?");
                pstmt.setString(1, userId);
                pstmt.setString(2, classId);
                rs = pstmt.executeQuery();
                if (rs.next()) {
                    message = "<div class='alert alert-warning text-center'>You are already registered for class " + classId + ".</div>";
                    throw new Exception("Already registered");
                }
                rs.close();
                pstmt.close();

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
                    message = "<div class='alert alert-danger text-center'>Time conflict with another registered class.</div>";
                    throw new Exception("Time conflict");
                }
                rs.close();
                pstmt.close();

                pstmt = conn.prepareStatement("INSERT INTO student_classes (s_id, class_id) VALUES (?, ?)");
                pstmt.setString(1, userId);
                pstmt.setString(2, classId);
                pstmt.executeUpdate();
                message = "<div class='alert alert-success text-center'>Successfully registered for class " + classId + "!</div>";
            } else if ("drop".equals(action)) {
                pstmt = conn.prepareStatement("SELECT 1 FROM student_classes WHERE s_id = ? AND class_id = ?");
                pstmt.setString(1, userId);
                pstmt.setString(2, classId);
                rs = pstmt.executeQuery();
                if (!rs.next()) {
                    message = "<div class='alert alert-warning text-center'>You are not registered for class " + classId + ".</div>";
                    throw new Exception("Not registered");
                }
                rs.close();
                pstmt.close();

                pstmt = conn.prepareStatement("DELETE FROM student_classes WHERE s_id = ? AND class_id = ?");
                pstmt.setString(1, userId);
                pstmt.setString(2, classId);
                pstmt.executeUpdate();
                message = "<div class='alert alert-success text-center'>Successfully dropped class " + classId + ".</div>";
            }
        } catch (Exception e) {
            if (message.isEmpty()) {
                message = "<div class='alert alert-danger text-center'>Error processing request: " + e.getMessage() + "</div>";
            }
        } finally {
            closeResources(conn, pstmt, rs);
        }
    }
    String selectedSession = request.getParameter("academic_session");
%>
<style>
    h3 {
        color: #4facfe;
        margin-top: 2rem;
        margin-bottom: 1.5rem;
        text-align: center;
    }
    .table-container {
        background: #ffffff;
        border-radius: 15px;
        box-shadow: 0 8px 16px rgba(0, 0, 0, 0.2);
        padding: 2rem;
        margin-bottom: 2rem;
    }
    .btn-secondary {
        background: linear-gradient(90deg, #ff7e5f, #feb47b);
        border: none;
        transition: transform 0.3s ease;
    }
    .btn-secondary:hover {
        background: linear-gradient(90deg, #feb47b, #ff7e5f);
        transform: scale(1.05);
    }
    .table {
        border-radius: 8px;
        overflow: hidden;
    }
    .table thead th {
        background: #4facfe;
        color: white;
        text-align: center;
        cursor: pointer;
    }
    /* Removed unused .fadeIn animation and redundant .btn-primary styles */
</style>
<div class="container mt-4">
    <div class="table-container">
        <%= message %>
        <h3>Available Classes</h3>
        <div class="mb-3">
            <label for="filterDay" class="form-label">Filter by Day:</label>
            <select id="filterDay" class="form-control d-inline-block w-auto">
                <option value="">All Days</option>
                <%
                    String[] days = {"Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"};
                    for (String day : days) {
                        out.println("<option value='" + day + "'>" + day + "</option>");
                    }
                %>
            </select>
            <label for="filterSession" class="form-label ms-3">Filter by Session:</label>
            <select id="filterSession" class="form-control d-inline-block w-auto">
                <option value="">All Sessions</option>
                <%
                    try {
                        conn = getConnection();
                        pstmt = conn.prepareStatement("SELECT DISTINCT academic_session FROM classes ORDER BY academic_session DESC");
                        rs = pstmt.executeQuery();
                        while (rs.next()) {
                            String academicSession = rs.getString("academic_session");
                            String selected = academicSession.equals(selectedSession) ? "selected" : "";
                %>
                <option value="<%= academicSession %>" <%= selected %>><%= academicSession %></option>
                <%
                        }
                    } catch (Exception e) {
                        out.println("<option>Error: " + e.getMessage() + "</option>");
                    } finally {
                        closeResources(conn, pstmt, rs);
                    }
                %>
            </select>
            <label for="filterSemester" class="form-label ms-3">Filter by Semester:</label>
            <select id="filterSemester" class="form-control d-inline-block w-auto">
                <option value="">All Semesters</option>
                <option value="1">1</option>
                <option value="2">2</option>
                <option value="3">3</option>
            </select>
        </div>
        <div class="table-responsive">
            <table class="table table-bordered" id="classesTable">
                <thead>
                    <tr>
                        <th data-sort="class_id">Class ID</th>
                        <th data-sort="subject">Subject</th>
                        <th data-sort="room">Room</th>
                        <th data-sort="t_name">Teacher</th>
                        <th data-sort="time">Time</th>
                        <th data-sort="day_of_week">Day</th>
                        <th data-sort="academic_session">Session</th>
                        <th data-sort="semester">Semester</th>
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
                    <tr class="<%= isRegistered ? "registered-class" : "" %>">
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
                                <button type="submit" class="btn btn-danger btn-sm" data-bs-toggle="tooltip" title="Drop this class" onclick="return confirm('Are you sure you want to drop class <%= classId %>?');">Drop</button>
                            </form>
                            <% } else { %>
                            <form method="POST" action="classes.jsp" style="display:inline;">
                                <input type="hidden" name="class_id" value="<%= classId %>">
                                <input type="hidden" name="action" value="register">
                                <button type="submit" class="btn btn-primary btn-sm" data-bs-toggle="tooltip" title="Register for this class">Register</button>
                            </form>
                            <% } %>
                        </td>
                        <% } %>
                    </tr>
                    <%
                            }
                        } catch (Exception e) {
                            out.println("<tr><td colspan='" + (userRId == 3 ? 9 : 8) + "' class='text-danger'>Error: " + e.getMessage() + "</td></tr>");
                        } finally {
                            closeResources(conn, pstmt, rs);
                        }
                    %>
                </tbody>
            </table>
        </div>
        <% if (userRId == 2 || userRId == 3) { %>
        <a href="timeTable.jsp" class="btn btn-secondary mt-3">View Timetable</a>
        <% } %>
    </div>
</div>
<script>
    document.addEventListener('DOMContentLoaded', function () {
        document.querySelectorAll('[data-bs-toggle="tooltip"]').forEach(el => new bootstrap.Tooltip(el));

        const table = document.getElementById('classesTable');
        const headers = table.querySelectorAll('th[data-sort]');
        headers.forEach(header => {
            header.addEventListener('click', () => {
                const sortKey = header.getAttribute('data-sort');
                const tbody = table.querySelector('tbody');
                const rows = Array.from(tbody.querySelectorAll('tr'));
                const isAscending = header.classList.toggle('sort-asc');
                rows.sort((a, b) => {
                    const aText = a.cells[Array.from(headers).indexOf(header)].textContent.trim();
                    const bText = b.cells[Array.from(headers).indexOf(header)].textContent.trim();
                    return isAscending ? aText.localeCompare(bText) : bText.localeCompare(aText);
                });
                tbody.innerHTML = '';
                rows.forEach(row => tbody.appendChild(row));
            });
        });

        const filters = [
            { id: 'filterDay', cellIndex: 5 },
            { id: 'filterSession', cellIndex: 6 },
            { id: 'filterSemester', cellIndex: 7 }
        ];
        filters.forEach(filter => {
            document.getElementById(filter.id).addEventListener('change', () => {
                const rows = table.querySelectorAll('tbody tr');
                rows.forEach(row => {
                    const matches = filters.every(f => {
                        const value = document.getElementById(f.id).value;
                        return !value || row.cells[f.cellIndex].textContent.trim() === value;
                    });
                    row.style.display = matches ? '' : 'none';
                });
            });
        });
    });
</script>
<%@ include file="footer.jsp"%>