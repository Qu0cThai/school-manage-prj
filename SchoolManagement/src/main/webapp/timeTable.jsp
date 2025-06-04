<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ include file="header.jsp"%>
<%@ include file="/WEB-INF/jspf/db-connection.jsp"%>
<%@ page import="java.sql.*, java.time.*, java.util.*" %>
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

    String selectedSession = request.getParameter("academic_session");
    String selectedSemester = request.getParameter("semester");
%>
<style>
    h3 {
        color: #4facfe;
        text-align: center;
        margin-bottom: 1.5rem;
    }
    .table-container {
        background: #ffffff;
        border-radius: 15px;
        box-shadow: 0 8px 16px rgba(0, 0, 0, 0.2);
        padding: 1.5rem;
        animation: fadeIn 1s ease-in;
    }
    .table {
        border-radius: 8px;
        overflow: hidden;
    }
    .table thead th {
        background: #4facfe;
        color: white;
        text-align: center;
        vertical-align: middle;
    }
    .table tbody td {
        text-align: center;
        vertical-align: middle;
        background: #f8f9fa;
        transition: background-color 0.3s ease;
    }
    .table tbody td.class-cell-admin {
        background: rgba(79, 172, 254, 0.2);
        border: 1px solid #4facfe;
    }
    .table tbody td.class-cell-teacher {
        background: rgba(40, 167, 69, 0.2);
        border: 1px solid #28a745;
    }
    .table tbody td.class-cell-student {
        background: rgba(23, 162, 184, 0.2);
        border: 1px solid #17a2b8;
    }
    .table tbody td:hover {
        background: #e0f7fa;
    }
    .table tbody td.time-slot {
        font-weight: bold;
        color: #495057;
        background: #dee2e6;
    }
    .class-details {
        font-size: 0.9rem;
        color: #343a40;
    }
    .class-details span {
        display: block;
        margin-bottom: 0.25rem;
    }
    .alert-danger {
        background: #f8d7da;
        color: #721c24;
        padding: 0.5rem;
        border-radius: 8px;
        text-align: center;
    }
    .filter-form {
        background: #ffffff;
        padding: 1.5rem;
        border-radius: 12px;
        box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
        transition: transform 0.3s ease;
        margin-bottom: 20px;
    }
    .form-group label {
        color: #495057;
        font-weight: bold;
    }
    .btn-primary {
        background: #4facfe;
        border: none;
    }
</style>
<div class="container mt-4">
    <div class="row">
        <div class="col-12">
            <form method="GET" action="timeTable.jsp" class="filter-form">
                <div class="form-row">
                    <div class="form-group col-md-5">
                        <label for="academic_session">Academic Session</label>
                        <select name="academic_session" id="academic_session" class="form-control">
                            <option value="">Select Session</option>
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
                    </div>
                    <div class="form-group col-md-5">
                        <label for="semester">Semester</label>
                        <select name="semester" id="semester" class="form-control">
                            <option value="">Select Semester</option>
                            <%
                                for (int i = 1; i <= 3; i++) {
                                    String selected = selectedSemester != null && selectedSemester.equals(String.valueOf(i)) ? "selected" : "";
                            %>
                            <option value="<%= i %>" <%= selected %>><%= i %></option>
                            <%
                                }
                            %>
                        </select>
                    </div>
                    <div class="form-group col-md-2">
                        <label>&nbsp;</label>
                        <button type="submit" class="btn btn-primary btn-block">Filter</button>
                    </div>
                </div>
            </form>
        </div>
    </div>
    <div class="row">
        <div class="col-12">
            <div class="table-container">
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
                                int startHour = 7;
                                int endHour = 22;
                                Map<String, List<Map<String, String>>> timetable = new HashMap<>();
                                Map<String, Set<Integer>> occupiedSlots = new HashMap<>();

                                for (String day : days) {
                                    timetable.put(day, new ArrayList<>());
                                    occupiedSlots.put(day, new HashSet<>());
                                }

                                String sql = "";
                                List<String> params = new ArrayList<>();
                                if (userRId == 1) {
                                    sql = "SELECT class_id, subject, room, day_of_week, time_begin, time_end, academic_session, semester FROM classes WHERE time_begin >= '07:00' AND time_end <= '23:00'";
                                } else if (userRId == 2) {
                                    sql = "SELECT class_id, subject, room, day_of_week, time_begin, time_end, academic_session, semester FROM classes WHERE t_id = ? AND time_begin >= '07:00' AND time_end <= '23:00'";
                                    params.add(userId);
                                } else if (userRId == 3) {
                                    sql = "SELECT c.class_id, c.subject, c.room, c.day_of_week, c.time_begin, c.time_end, c.academic_session, c.semester FROM classes c JOIN student_classes sc ON c.class_id = sc.class_id WHERE sc.s_id = ? AND time_begin >= '07:00' AND time_end <= '23:00'";
                                    params.add(userId);
                                }

                                if (selectedSession != null && !selectedSession.isEmpty()) {
                                    sql += " AND academic_session = ?";
                                    params.add(selectedSession);
                                }
                                if (selectedSemester != null && !selectedSemester.isEmpty()) {
                                    sql += " AND semester = ?";
                                    params.add(selectedSemester);
                                }

                                try {
                                    conn = getConnection();
                                    pstmt = conn.prepareStatement(sql);
                                    for (int i = 0; i < params.size(); i++) {
                                        pstmt.setString(i + 1, params.get(i));
                                    }
                                    rs = pstmt.executeQuery();

                                    while (rs.next()) {
                                        String day = rs.getString("day_of_week");
                                        String timeBegin = rs.getString("time_begin").substring(0, 5);
                                        String timeEnd = rs.getString("time_end").substring(0, 5);
                                        Map<String, String> classDetails = new HashMap<>();
                                        classDetails.put("class_id", rs.getString("class_id"));
                                        classDetails.put("subject", rs.getString("subject"));
                                        classDetails.put("room", rs.getString("room"));
                                        classDetails.put("time_begin", timeBegin);
                                        classDetails.put("time_end", timeEnd);
                                        timetable.get(day).add(classDetails);
                                    }
                                } catch (Exception e) {
                                    out.println("<div class='alert alert-danger'>Error fetching classes: " + e.getMessage() + "</div>");
                                    return;
                                } finally {
                                    closeResources(conn, pstmt, rs);
                                }

                                for (int hour = startHour; hour <= endHour; hour++) {
                                    String timeSlot = String.format("%02d:00", hour);
                            %>
                            <tr>
                                <td class="time-slot"><%= timeSlot %></td>
                                <%
                                    for (String day : days) {
                                        boolean slotOccupied = occupiedSlots.get(day).contains(hour);
                                        if (slotOccupied) {
                                            continue;
                                        }

                                        Map<String, String> currentClass = null;
                                        for (Map<String, String> classDetails : timetable.get(day)) {
                                            String timeBegin = classDetails.get("time_begin");
                                            if (timeBegin.equals(timeSlot)) {
                                                currentClass = classDetails;
                                                break;
                                            }
                                        }

                                        if (currentClass != null) {
                                            String timeBegin = currentClass.get("time_begin");
                                            String timeEnd = currentClass.get("time_end");
                                            String subject = currentClass.get("subject");
                                            String room = currentClass.get("room");

                                            int beginHour = Integer.parseInt(timeBegin.split(":")[0]);
                                            int endHourForClass = Integer.parseInt(timeEnd.split(":")[0]);
                                            int rowspan = endHourForClass - beginHour + 1;

                                            for (int h = beginHour; h <= endHourForClass; h++) {
                                                occupiedSlots.get(day).add(h);
                                            }

                                            String cellClass = "";
                                            if (userRId == 1) {
                                                cellClass = "class-cell-admin";
                                            } else if (userRId == 2) {
                                                cellClass = "class-cell-teacher";
                                            } else if (userRId == 3) {
                                                cellClass = "class-cell-student";
                                            }
                                %>
                                <td rowspan="<%= rowspan %>" class="<%= cellClass %>">
                                    <div class="class-details">
                                        <span><%= subject %> <%= timeBegin %>–<%= timeEnd %></span>
                                        <span>Room: <%= room %></span>
                                    </div>
                                </td>
                                <%
                                        } else {
                                %>
                                <td></td>
                                <%
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
</div>
<%@ include file="footer.jsp"%>