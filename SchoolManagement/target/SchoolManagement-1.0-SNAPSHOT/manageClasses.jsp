<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ include file="header.jsp"%>
<%@ include file="/WEB-INF/jspf/db-connection.jsp"%>
<%@ page import="java.sql.*, java.time.*, java.util.Arrays" %>
<%-- JSP logic remains unchanged --%>
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
            out.println("<!-- Error fetching u_name: " + e.getMessage() + " -->");
        } finally {
            closeResources(conn, pstmt, rs);
        }
    }

    if (u_id == null || u_name == null || userRId == null || userRId != 2) {
        response.sendRedirect("index.jsp");
        return;
    }

    String message = "";
    String action = request.getParameter("action");
    String editClassId = request.getParameter("class_id");
    boolean showEditForm = "edit".equals(action) && editClassId != null;
    String editSubject = "", editRoom = "", editTimeBegin = "", editTimeEnd = "";
    String editDayOfWeek = "", editAcademicSession = "", editSemester = "";

    if (showEditForm) {
        try {
            conn = getConnection();
            pstmt = conn.prepareStatement(
                "SELECT class_id, subject, room, time_begin, time_end, day_of_week, academic_session, semester " +
                "FROM classes WHERE class_id = ? AND t_id = ?"
            );
            pstmt.setString(1, editClassId);
            pstmt.setString(2, u_id);
            rs = pstmt.executeQuery();
            if (rs.next()) {
                editSubject = rs.getString("subject");
                editRoom = rs.getString("room");
                editTimeBegin = rs.getString("time_begin");
                editTimeEnd = rs.getString("time_end");
                editDayOfWeek = rs.getString("day_of_week");
                editAcademicSession = rs.getString("academic_session");
                editSemester = rs.getString("semester");
            } else {
                message = "<div class='alert alert-danger text-center'>Class ID " + editClassId + " not found or you are not authorized.</div>";
                showEditForm = false;
            }
        } catch (Exception e) {
            message = "<div class='alert alert-danger text-center'>Error loading class: " + e.getMessage() + "</div>";
            showEditForm = false;
        } finally {
            closeResources(conn, pstmt, rs);
        }
    }

    if ("POST".equalsIgnoreCase(request.getMethod())) {
        try {
            conn = getConnection();
            action = request.getParameter("action");
            if ("add".equals(action) || "update".equals(action)) {
                String classId = request.getParameter("class_id");
                String subject = request.getParameter("subject");
                String room = request.getParameter("room");
                String timeBegin = request.getParameter("time_begin");
                String timeEnd = request.getParameter("time_end");
                String dayOfWeek = request.getParameter("day_of_week");
                String academicSession = request.getParameter("academic_session");
                String semester = request.getParameter("semester");

                if (classId == null || classId.trim().isEmpty() || !classId.matches("[A-Za-z0-9]+")) {
                    message = "<div class='alert alert-danger text-center'>Invalid Class ID. Use only letters and numbers.</div>";
                    throw new Exception("Invalid class_id");
                }
                if (subject == null || subject.trim().isEmpty()) {
                    message = "<div class='alert alert-danger text-center'>Subject is required.</div>";
                    throw new Exception("Invalid subject");
                }
                if (room == null || room.trim().isEmpty()) {
                    message = "<div class='alert alert-danger text-center'>Room is required.</div>";
                    throw new Exception("Invalid room");
                }
                if (timeBegin == null || timeEnd == null) {
                    message = "<div class='alert alert-danger text-center'>Time Begin and Time End are required.</div>";
                    throw new Exception("Invalid time");
                }
                if (dayOfWeek == null || !Arrays.asList("Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday").contains(dayOfWeek)) {
                    message = "<div class='alert alert-danger text-center'>Invalid Day of Week.</div>";
                    throw new Exception("Invalid day_of_week");
                }
                if (academicSession == null || !academicSession.matches("\\d{4}-\\d{4}")) {
                    message = "<div class='alert alert-danger text-center'>Invalid Academic Session. Use format YYYY-YYYY.</div>";
                    throw new Exception("Invalid academic_session");
                }
                int semesterInt;
                try {
                    semesterInt = Integer.parseInt(semester);
                    if (semesterInt < 1 || semesterInt > 3) {
                        message = "<div class='alert alert-danger text-center'>Semester must be 1, 2, or 3.</div>";
                        throw new Exception("Invalid semester");
                    }
                } catch (NumberFormatException e) {
                    message = "<div class='alert alert-danger text-center'>Invalid Semester. Must be a number.</div>";
                    throw new Exception("Invalid semester");
                }

                LocalTime beginTime = LocalTime.parse(timeBegin);
                LocalTime endTime = LocalTime.parse(timeEnd);
                if (!beginTime.isBefore(endTime)) {
                    message = "<div class='alert alert-danger text-center'>Time Begin must be before Time End.</div>";
                    throw new Exception("Invalid time range");
                }

                pstmt = conn.prepareStatement(
                    "SELECT 1 FROM classes WHERE t_id = ? AND day_of_week = ? AND " +
                    "((time_begin <= ? AND time_end >= ?) OR (time_begin <= ? AND time_end >= ?)) " +
                    "AND class_id != ?"
                );
                pstmt.setString(1, u_id);
                pstmt.setString(2, dayOfWeek);
                pstmt.setString(3, timeBegin);
                pstmt.setString(4, timeBegin);
                pstmt.setString(5, timeEnd);
                pstmt.setString(6, timeEnd);
                pstmt.setString(7, "add".equals(action) ? "-1" : classId);
                rs = pstmt.executeQuery();
                if (rs.next()) {
                    message = "<div class='alert alert-danger text-center'>This time slot on " + dayOfWeek + " overlaps with an existing class.</div>";
                    throw new Exception("Time slot conflict");
                }
                rs.close();
                pstmt.close();

                if ("add".equals(action)) {
                    pstmt = conn.prepareStatement("SELECT 1 FROM classes WHERE class_id = ?");
                    pstmt.setString(1, classId);
                    rs = pstmt.executeQuery();
                    if (rs.next()) {
                        message = "<div class='alert alert-danger text-center'>Class ID " + classId + " already exists.</div>";
                        throw new Exception("Duplicate class_id");
                    }
                    rs.close();
                    pstmt.close();

                    pstmt = conn.prepareStatement("SELECT t_id FROM teachers WHERE t_id = ?");
                    pstmt.setString(1, u_id);
                    rs = pstmt.executeQuery();
                    if (!rs.next()) {
                        message = "<div class='alert alert-danger text-center'>Teacher ID " + u_id + " not found.</div>";
                        throw new Exception("Invalid teacher ID");
                    }
                    rs.close();
                    pstmt.close();

                    pstmt = conn.prepareStatement(
                        "INSERT INTO classes (class_id, subject, room, t_id, time_begin, time_end, academic_session, semester, day_of_week) " +
                        "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)"
                    );
                    pstmt.setString(1, classId);
                    pstmt.setString(2, subject);
                    pstmt.setString(3, room);
                    pstmt.setString(4, u_id);
                    pstmt.setString(5, timeBegin);
                    pstmt.setString(6, timeEnd);
                    pstmt.setString(7, academicSession);
                    pstmt.setInt(8, semesterInt);
                    pstmt.setString(9, dayOfWeek);
                    pstmt.executeUpdate();
                    message = "<div class='alert alert-success text-center'>Class added successfully!</div>";
                } else if ("update".equals(action)) {
                    pstmt = conn.prepareStatement(
                        "UPDATE classes SET subject = ?, room = ?, time_begin = ?, time_end = ?, academic_session = ?, semester = ?, day_of_week = ? " +
                        "WHERE class_id = ? AND t_id = ?"
                    );
                    pstmt.setString(1, subject);
                    pstmt.setString(2, room);
                    pstmt.setString(3, timeBegin);
                    pstmt.setString(4, timeEnd);
                    pstmt.setString(5, academicSession);
                    pstmt.setInt(6, semesterInt);
                    pstmt.setString(7, dayOfWeek);
                    pstmt.setString(8, classId);
                    pstmt.setString(9, u_id);
                    int rows = pstmt.executeUpdate();
                    if (rows > 0) {
                        message = "<div class='alert alert-success text-center'>Class " + classId + " updated successfully!</div>";
                    } else {
                        message = "<div class='alert alert-danger text-center'>Class ID " + classId + " not found or you are not authorized.</div>";
                    }
                }
            } else if ("delete".equals(action)) {
                String classId = request.getParameter("class_id");
                pstmt = conn.prepareStatement("SELECT 1 FROM classes WHERE class_id = ? AND t_id = ?");
                pstmt.setString(1, classId);
                pstmt.setString(2, u_id);
                rs = pstmt.executeQuery();
                if (!rs.next()) {
                    message = "<div class='alert alert-danger text-center'>Class ID " + classId + " not found or you are not authorized.</div>";
                    throw new Exception("Invalid class");
                }
                rs.close();
                pstmt.close();

                pstmt = conn.prepareStatement("DELETE FROM student_classes WHERE class_id = ?");
                pstmt.setString(1, classId);
                pstmt.executeUpdate();
                pstmt.close();

                pstmt = conn.prepareStatement("DELETE FROM classes WHERE class_id = ? AND t_id = ?");
                pstmt.setString(1, classId);
                pstmt.setString(2, u_id);
                pstmt.executeUpdate();
                message = "<div class='alert alert-success text-center'>Class " + classId + " deleted successfully!</div>";
            }
        } catch (Exception e) {
            if (message.isEmpty()) {
                message = "<div class='alert alert-danger text-center'>Error processing request: " + e.getMessage() + "</div>";
            }
        } finally {
            closeResources(conn, pstmt, rs);
        }
    }
%>
<style>
    h3 {
        color: #4facfe;
        margin-top: 2rem;
        margin-bottom: 1.5rem;
        text-align: center;
    }
    .form-container, .table-container {
        background: #ffffff;
        border-radius: 15px;
        box-shadow: 0 8px 16px rgba(0, 0, 0, 0.2);
        padding: 2rem;
        margin-bottom: 2rem;
    }
    .form-group {
        margin-bottom: 1.5rem;
    }
    .form-group label {
        color: #495057;
        font-weight: bold;
    }
    .form-group input, .form-group select {
        border-radius: 8px;
        border: 1px solid #ced4da;
    }
    .form-group input:focus, .form-group select:focus {
        border-color: #4facfe;
        box-shadow: 0 0 5px rgba(79, 172, 254, 0.3);
    }
    .btn-primary {
        background: #4facfe;
        border: none;
        transition: transform 0.3s ease;
    }
    .btn-primary:hover {
        transform: scale(1.05);
    }
    .btn-secondary, .btn-warning {
        transition: transform 0.3s ease;
    }
    .btn-secondary {
        background: linear-gradient(90deg, #ff7e5f, #feb47b);
        border: none;
    }
    .btn-secondary:hover {
        background: linear-gradient(90deg, #feb47b, #ff7e5f);
        transform: scale(1.05);
    }
    .btn-warning {
        background: linear-gradient(90deg, #ffca28, #ffeb3b);
        border: none;
    }
    .btn-warning:hover {
        background: linear-gradient(90deg, #ffeb3b, #ffca28);
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
    .table tbody tr.my-class {
        background: rgba(40, 167, 69, 0.2);
    }
    /* Removed unused .tooltip-icon, .btn-danger, .table tbody tr:hover, .table tbody td */
</style>
<div class="container mt-4">
    <div class="form-container">
        <%= message %>
        <% if (showEditForm) { %>
        <h3>Edit Class <%= editClassId %></h3>
        <form method="POST" action="manageClasses.jsp">
            <input type="hidden" name="action" value="update">
            <input type="hidden" name="class_id" value="<%= editClassId %>">
            <div class="form-group">
                <label for="subject">Subject</label>
                <input type="text" id="subject" name="subject" class="form-control" value="<%= editSubject %>" required>
            </div>
            <div class="form-group">
                <label for="room">Room</label>
                <input type="text" id="room" name="room" class="form-control" value="<%= editRoom %>" required>
            </div>
            <div class="form-group">
                <label for="time_begin">Time Begin</label>
                <input type="time" id="time_begin" name="time_begin" class="form-control" value="<%= editTimeBegin %>" required min="07:00" max="22:00">
            </div>
            <div class="form-group">
                <label for="time_end">Time End</label>
                <input type="time" id="time_end" name="time_end" class="form-control" value="<%= editTimeEnd %>" required min="07:00" max="22:00">
            </div>
            <div class="form-group">
                <label for="day_of_week">Day of Week</label>
                <select id="day_of_week" name="day_of_week" class="form-control" required>
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
                <label for="academic_session">Academic Session</label>
                <input type="text" id="academic_session" name="academic_session" class="form-control" value="<%= editAcademicSession %>" required pattern="\d{4}-\d{4}" title="Format: YYYY-YYYY (e.g., 2024-2025)">
            </div>
            <div class="form-group">
                <label for="semester">Semester</label>
                <select id="semester" name="semester" class="form-control" required>
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
            <a href="timeTable.jsp" class="btn btn-secondary float-end">Back to Timetable</a>
        </form>
        <% } else { %>
        <h3>Add New Class</h3>
        <form method="POST" action="manageClasses.jsp">
            <input type="hidden" name="action" value="add">
            <div class="form-group">
                <label for="class_id">Class ID</label>
                <input type="text" id="class_id" name="class_id" class="form-control" required pattern="[A-Za-z0-9]+" title="Class ID should contain only letters and numbers">
            </div>
            <div class="form-group">
                <label for="subject">Subject</label>
                <input type="text" id="subject" name="subject" class="form-control" required>
            </div>
            <div class="form-group">
                <label for="room">Room</label>
                <input type="text" id="room" name="room" class="form-control" required>
            </div>
            <div class="form-group">
                <label for="time_begin">Time Begin</label>
                <input type="time" id="time_begin" name="time_begin" class="form-control" required min="07:00" max="22:00">
            </div>
            <div class="form-group">
                <label for="time_end">Time End</label>
                <input type="time" id="time_end" name="time_end" class="form-control" required min="07:00" max="22:00">
            </div>
            <div class="form-group">
                <label for="day_of_week">Day of Week</label>
                <select id="day_of_week" name="day_of_week" class="form-control" required>
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
                <label for="academic_session">Academic Session</label>
                <input type="text" id="academic_session" name="academic_session" class="form-control" value="2024-2025" required pattern="\d{4}-\d{4}" title="Format: YYYY-YYYY (e.g., 2024-2025)">
            </div>
            <div class="form-group">
                <label for="semester">Semester</label>
                <select id="semester" name="semester" class="form-control" required>
                    <option value="1">1</option>
                    <option value="2">2</option>
                    <option value="3">3</option>
                </select>
            </div>
            <button type="submit" class="btn btn-primary">Add Class</button>
            <a href="timeTable.jsp" class="btn btn-secondary float-end">Back to Timetable</a>
        </form>
        <% } %>
    </div>

    <div class="table-container">
        <h3>Existing Classes</h3>
        <div class="mb-3">
            <label for="filterDay" class="form-label">Filter by Day:</label>
            <select id="filterDay" class="form-control">
                <option value="">All Days</option>
                <%
                    String[] days = {"Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"};
                    for (String day : days) {
                        out.println("<option value='" + day + "'>" + day + "</option>");
                    }
                %>
            </select>
            <label for="filterSemester" class="form-label ms-3">Filter by Semester:</label>
            <select id="filterSemester" class="form-control">
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
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                        try {
                            conn = getConnection();
                            pstmt = conn.prepareStatement(
                                "SELECT c.class_id, c.subject, c.room, t.t_name, c.time_begin, c.time_end, c.day_of_week, c.academic_session, c.semester, c.t_id " +
                                "FROM classes c JOIN teachers t ON c.t_id = t.t_id"
                            );
                            rs = pstmt.executeQuery();
                            while (rs.next()) {
                                String classId = rs.getString("class_id");
                                String tId = rs.getString("t_id");
                                String timeBegin = rs.getString("time_begin").substring(0, 5);
                                String timeEnd = rs.getString("time_end").substring(0, 5);
                                String time = timeBegin + "–" + timeEnd;
                    %>
                    <tr class="<%= tId.equals(u_id) ? "my-class" : "" %>">
                        <td><%= classId %></td>
                        <td><%= rs.getString("subject") %></td>
                        <td><%= rs.getString("room") %></td>
                        <td><%= rs.getString("t_name") %></td>
                        <td><%= time %></td>
                        <td><%= rs.getString("day_of_week") %></td>
                        <td><%= rs.getString("academic_session") %></td>
                        <td><%= rs.getString("semester") %></td>
                        <td>
                            <%
                                if (tId.equals(u_id)) {
                            %>
                            <a href="manageClasses.jsp?action=edit&class_id=<%= classId %>" class="btn btn-warning btn-sm">Edit</a>
                            <form method="POST" action="manageClasses.jsp" style="display:inline;">
                                <input type="hidden" name="action" value="delete">
                                <input type="hidden" name="class_id" value="<%= classId %>">
                                <button type="submit" class="btn btn-danger btn-sm" onclick="return confirm('Are you sure you want to delete class <%= classId %>?');">Delete</button>
                            </form>
                            <%
                                } else {
                            %>
                            <span class="text-muted">No actions available</span>
                            <%
                                }
                            %>
                        </td>
                    </tr>
                    <%
                            }
                        } catch (Exception e) {
                            out.println("<tr><td colspan='9' class='text-danger'>Error: " + e.getMessage() + "</td></tr>");
                        } finally {
                            closeResources(conn, pstmt, rs);
                        }
                    %>
                </tbody>
            </table>
        </div>
    </div>
</div>
<script>
    document.addEventListener('DOMContentLoaded', function () {
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