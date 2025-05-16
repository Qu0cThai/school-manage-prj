<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ include file="header.jsp"%>
<%@ include file="/WEB-INF/jspf/db-connection.jsp"%>
<%@ page import="java.sql.*" %>
<%
    // Restrict access to Admin (r_id=1)
    Integer userRId = (Integer) session.getAttribute("userRId");
    if (userRId == null || userRId != 1) {
        response.sendRedirect("index.jsp");
        return;
    }
%>
<div class="container">

    <!-- Add Student Form -->
    <div class="row">
        <div class="col-12 col-md-6">
            <div class="card">
                <div class="card-header">
                    <h3>Add New Student</h3>
                </div>
                <div class="card-body">
                    <form action="manageStudent.jsp" method="POST">
                        <input type="hidden" name="action" value="add">
                        <div class="form-group">
                            <label for="s_id">Student ID</label>
                            <input type="text" class="form-control" name="s_id" placeholder="e.g., S003" required>
                        </div>
                        <div class="form-group">
                            <label for="s_name">Name</label>
                            <input type="text" class="form-control" name="s_name" placeholder="Enter name" required>
                        </div>
                        <div class="form-group">
                            <label for="roll_no">Roll No</label>
                            <input type="text" class="form-control" name="roll_no" placeholder="e.g., 003" required>
                        </div>
                        <div class="form-group">
                            <label for="gender">Gender</label>
                            <select class="form-control" name="gender" required>
                                <option value="">Select Gender</option>
                                <option value="Male">Male</option>
                                <option value="Female">Female</option>
                                <option value="Other">Other</option>
                            </select>
                        </div>
                        <div class="form-group">
                            <label for="dob">Date of Birth</label>
                            <input type="date" class="form-control" name="dob" required>
                        </div>
                        <div class="form-group">
                            <label for="age">Age</label>
                            <input type="number" class="form-control" name="age" placeholder="Enter age" required>
                        </div>
                        <div class="form-group">
                            <label for="f_name">Father's Name</label>
                            <input type="text" class="form-control" name="f_name" placeholder="Enter father's name">
                        </div>
                        <div class="form-group">
                            <label for="m_name">Mother's Name</label>
                            <input type="text" class="form-control" name="m_name" placeholder="Enter mother's name">
                        </div>
                        <div class="form-group">
                            <label for="mobile_no">Mobile No</label>
                            <input type="text" class="form-control" name="mobile_no" placeholder="Enter mobile number">
                        </div>
                        <div class="form-group">
                            <label for="present_address">Present Address</label>
                            <textarea class="form-control" name="present_address" rows="3" placeholder="Enter present address"></textarea>
                        </div>
                        <div class="form-group">
                            <label for="permanent_address">Permanent Address</label>
                            <textarea class="form-control" name="permanent_address" rows="3" placeholder="Enter permanent address"></textarea>
                        </div>
                        <button type="submit" class="btn btn-primary btn-block">Add Student</button>
                    </form>
                </div>
            </div>
        </div>
        <!-- Edit Student Form (Hidden by Default) -->
        <div class="col-12 col-md-6">
            <div class="card" id="editForm" style="display: none;">
                <div class="card-header">
                    <h3>Edit Student</h3>
                </div>
                <div class="card-body">
                    <form action="manageStudent.jsp" method="POST">
                        <input type="hidden" name="action" value="edit">
                        <input type="hidden" name="s_id" id="edit_s_id">
                        <div class="form-group">
                            <label for="edit_s_name">Name</label>
                            <input type="text" class="form-control" name="edit_s_name" id="edit_s_name" required>
                        </div>
                        <div class="form-group">
                            <label for="edit_roll_no">Roll No</label>
                            <input type="text" class="form-control" name="edit_roll_no" id="edit_roll_no" required>
                        </div>
                        <div class="form-group">
                            <label for="edit_gender">Gender</label>
                            <select class="form-control" name="edit_gender" id="edit_gender" required>
                                <option value="Male">Male</option>
                                <option value="Female">Female</option>
                                <option value="Other">Other</option>
                            </select>
                        </div>
                        <div class="form-group">
                            <label for="edit_dob">Date of Birth</label>
                            <input type="date" class="form-control" name="edit_dob" id="edit_dob" required>
                        </div>
                        <div class="form-group">
                            <label for="edit_age">Age</label>
                            <input type="number" class="form-control" name="edit_age" id="edit_age" required>
                        </div>
                        <div class="form-group">
                            <label for="edit_f_name">Father's Name</label>
                            <input type="text" class="form-control" name="edit_f_name" id="edit_f_name">
                        </div>
                        <div class="form-group">
                            <label for="edit_m_name">Mother's Name</label>
                            <input type="text" class="form-control" name="edit_m_name" id="edit_m_name">
                        </div>
                        <div class="form-group">
                            <label for="edit_mobile_no">Mobile No</label>
                            <input type="text" class="form-control" name="edit_mobile_no" id="edit_mobile_no">
                        </div>
                        <div class="form-group">
                            <label for="edit_present_address">Present Address</label>
                            <textarea class="form-control" name="edit_present_address" id="edit_present_address" rows="3"></textarea>
                        </div>
                        <div class="form-group">
                            <label for="edit_permanent_address">Permanent Address</label>
                            <textarea class="form-control" name="edit_permanent_address" id="edit_permanent_address" rows="3"></textarea>
                        </div>
                        <button type="submit" class="btn btn-primary btn-block">Update Student</button>
                        <button type="button" class="btn btn-secondary btn-block" onclick="document.getElementById('editForm').style.display='none';">Cancel</button>
                    </form>
                </div>
            </div>
        </div>
    </div>
    <!-- Students Table -->
    <div class="row mt-4">
        <div class="col-12">
            <h3>All Students</h3>
            <table class="table table-bordered">
                <thead>
                    <tr>
                        <th>Student ID</th>
                        <th>Name</th>
                        <th>Roll No</th>
                        <th>Gender</th>
                        <th>Date of Birth</th>
                        <th>Age</th>
                        <th>Father's Name</th>
                        <th>Mother's Name</th>
                        <th>Mobile No</th>
                        <th>Present Address</th>
                        <th>Permanent Address</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                        Connection conn = null;
                        PreparedStatement pstmt = null;
                        ResultSet rs = null;
                        try {
                            conn = getConnection();
                            String sql = "SELECT s_id, s_name, roll_no, gender, dob, age, f_name, m_name, mobile_no, present_address, permanent_address FROM students ORDER BY s_id";
                            pstmt = conn.prepareStatement(sql);
                            rs = pstmt.executeQuery();
                            while (rs.next()) {
                                String s_id = rs.getString("s_id");
                                String s_name = rs.getString("s_name");
                                String roll_no = rs.getString("roll_no");
                                String gender = rs.getString("gender");
                                String dob = rs.getString("dob");
                                int age = rs.getInt("age");
                                String f_name = rs.getString("f_name");
                                String m_name = rs.getString("m_name");
                                String mobile_no = rs.getString("mobile_no");
                                String present_address = rs.getString("present_address");
                                String permanent_address = rs.getString("permanent_address");
                    %>
                    <tr>
                        <td><%= s_id %></td>
                        <td><%= s_name %></td>
                        <td><%= roll_no %></td>
                        <td><%= gender != null ? gender : "-" %></td>
                        <td><%= dob %></td>
                        <td><%= age %></td>
                        <td><%= f_name != null ? f_name : "-" %></td>
                        <td><%= m_name != null ? m_name : "-" %></td>
                        <td><%= mobile_no != null ? mobile_no : "-" %></td>
                        <td><%= present_address != null ? present_address : "-" %></td>
                        <td><%= permanent_address != null ? permanent_address : "-" %></td>
                        <td>
                            <button class="btn btn-sm btn-warning" onclick="editStudent('<%= s_id %>', '<%= s_name.replace("'", "\\'") %>', '<%= roll_no.replace("'", "\\'") %>', '<%= gender != null ? gender : "" %>', '<%= dob %>', '<%= age %>', '<%= f_name != null ? f_name.replace("'", "\\'") : "" %>', '<%= m_name != null ? m_name.replace("'", "\\'") : "" %>', '<%= mobile_no != null ? mobile_no.replace("'", "\\'") : "" %>', '<%= present_address != null ? present_address.replace("'", "\\'") : "" %>', '<%= permanent_address != null ? permanent_address.replace("'", "\\'") : "" %>')">Edit</button>
                            <form action="manageStudent.jsp" method="POST" style="display:inline;">
                                <input type="hidden" name="action" value="delete">
                                <input type="hidden" name="s_id" value="<%= s_id %>">
                                <button type="submit" class="btn btn-sm btn-danger" onclick="return confirm('Are you sure you want to delete this student?')">Delete</button>
                            </form>
                        </td>
                    </tr>
                    <%
                            }
                        } catch (Exception e) {
                            out.println("<tr><td colspan='12' class='text-danger'>Error fetching students: " + e.getMessage() + "</td></tr>");
                        } finally {
                            closeResources(conn, pstmt, rs);
                        }
                    %>
                </tbody>
            </table>
        </div>
    </div>
</div>
<!-- JavaScript for Edit Form -->
<script>
    function editStudent(s_id, s_name, roll_no, gender, dob, age, f_name, m_name, mobile_no, present_address, permanent_address) {
        document.getElementById('editForm').style.display = 'block';
        document.getElementById('edit_s_id').value = s_id;
        document.getElementById('edit_s_name').value = s_name;
        document.getElementById('edit_roll_no').value = roll_no;
        document.getElementById('edit_gender').value = gender;
        document.getElementById('edit_dob').value = dob;
        document.getElementById('edit_age').value = age;
        document.getElementById('edit_f_name').value = f_name;
        document.getElementById('edit_m_name').value = m_name;
        document.getElementById('edit_mobile_no').value = mobile_no;
        document.getElementById('edit_present_address').value = present_address;
        document.getElementById('edit_permanent_address').value = permanent_address;
    }
</script>
<%@ include file="footer.jsp"%>
</html>
<%
    // Handle form submissions (Add, Edit, Delete)
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String action = request.getParameter("action");
        conn = null;
        pstmt = null;
        try {
            conn = getConnection();
            if ("add".equals(action)) {
                String s_id = request.getParameter("s_id");
                String s_name = request.getParameter("s_name");
                String roll_no = request.getParameter("roll_no");
                String gender = request.getParameter("gender");
                String dob = request.getParameter("dob");
                int age = Integer.parseInt(request.getParameter("age"));
                String f_name = request.getParameter("f_name");
                String m_name = request.getParameter("m_name");
                String mobile_no = request.getParameter("mobile_no");
                String present_address = request.getParameter("present_address");
                String permanent_address = request.getParameter("permanent_address");
                pstmt = conn.prepareStatement("INSERT INTO students (s_id, s_name, roll_no, gender, dob, age, f_name, m_name, mobile_no, present_address, permanent_address) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)");
                pstmt.setString(1, s_id);
                pstmt.setString(2, s_name);
                pstmt.setString(3, roll_no);
                pstmt.setString(4, gender);
                pstmt.setString(5, dob);
                pstmt.setInt(6, age);
                pstmt.setString(7, f_name != null && !f_name.isEmpty() ? f_name : null);
                pstmt.setString(8, m_name != null && !m_name.isEmpty() ? m_name : null);
                pstmt.setString(9, mobile_no != null && !mobile_no.isEmpty() ? mobile_no : null);
                pstmt.setString(10, present_address != null && !present_address.isEmpty() ? present_address : null);
                pstmt.setString(11, permanent_address != null && !permanent_address.isEmpty() ? permanent_address : null);
                pstmt.executeUpdate();
                response.sendRedirect("manageStudent.jsp?success=added");
            } else if ("edit".equals(action)) {
                String s_id = request.getParameter("s_id");
                String s_name = request.getParameter("edit_s_name");
                String roll_no = request.getParameter("edit_roll_no");
                String gender = request.getParameter("edit_gender");
                String dob = request.getParameter("edit_dob");
                int age = Integer.parseInt(request.getParameter("edit_age"));
                String f_name = request.getParameter("edit_f_name");
                String m_name = request.getParameter("edit_m_name");
                String mobile_no = request.getParameter("edit_mobile_no");
                String present_address = request.getParameter("edit_present_address");
                String permanent_address = request.getParameter("edit_permanent_address");
                pstmt = conn.prepareStatement("UPDATE students SET s_name = ?, roll_no = ?, gender = ?, dob = ?, age = ?, f_name = ?, m_name = ?, mobile_no = ?, present_address = ?, permanent_address = ? WHERE s_id = ?");
                pstmt.setString(1, s_name);
                pstmt.setString(2, roll_no);
                pstmt.setString(3, gender);
                pstmt.setString(4, dob);
                pstmt.setInt(5, age);
                pstmt.setString(6, f_name != null && !f_name.isEmpty() ? f_name : null);
                pstmt.setString(7, m_name != null && !m_name.isEmpty() ? m_name : null);
                pstmt.setString(8, mobile_no != null && !mobile_no.isEmpty() ? mobile_no : null);
                pstmt.setString(9, present_address != null && !present_address.isEmpty() ? present_address : null);
                pstmt.setString(10, permanent_address != null && !permanent_address.isEmpty() ? permanent_address : null);
                pstmt.setString(11, s_id);
                pstmt.executeUpdate();
                response.sendRedirect("manageStudent.jsp?success=edited");
            } else if ("delete".equals(action)) {
                String s_id = request.getParameter("s_id");
                pstmt = conn.prepareStatement("DELETE FROM students WHERE s_id = ?");
                pstmt.setString(1, s_id);
                pstmt.executeUpdate();
                response.sendRedirect("manageStudent.jsp?success=deleted");
            }
        } catch (Exception e) {
            out.println("<p class='text-danger'>Error processing request: " + e.getMessage() + "</p>");
        } finally {
            closeResources(conn, pstmt, null);
        }
    }
    // Display success message
    String success = request.getParameter("success");
    if (success != null) {
        String message = "";
        if ("added".equals(success)) message = "Student added successfully!";
        else if ("edited".equals(success)) message = "Student updated successfully!";
        else if ("deleted".equals(success)) message = "Student deleted successfully!";
%>
<div class="alert alert-success alert-dismissible fade show" role="alert">
    <%= message %>
    <button type="button" class="close" data-dismiss="alert" aria-label="Close">
        <span aria-hidden="true">×</span>
    </button>
</div>
<% } %>
</html>