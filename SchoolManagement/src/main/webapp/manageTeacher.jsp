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
    <!-- Add Teacher Form -->
    <div class="row">
        <div class="col-12 col-md-6">
            <div class="card">
                <div class="card-header">
                    <h3>Add New Teacher</h3>
                </div>
                <div class="card-body">
                    <form action="manageTeacher.jsp" method="POST">
                        <input type="hidden" name="action" value="add">
                        <div class="form-group">
                            <label for="t_id">Teacher ID</label>
                            <input type="text" class="form-control" name="t_id" placeholder="e.g., T004" required>
                        </div>
                        <div class="form-group">
                            <label for="t_name">Name</label>
                            <input type="text" class="form-control" name="t_name" placeholder="Enter name" required>
                        </div>
                        <div class="form-group">
                            <label for="t_email">Email</label>
                            <input type="email" class="form-control" name="t_email" placeholder="Enter email" required>
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
                            <label for="phone_number">Phone Number</label>
                            <input type="text" class="form-control" name="phone_number" placeholder="Enter phone number">
                        </div>
                        <div class="form-group">
                            <label for="address">Address</label>
                            <textarea class="form-control" name="address" rows="3" placeholder="Enter address"></textarea>
                        </div>
                        <div class="form-group">
                            <label for="sub_name">Subject</label>
                            <input type="text" class="form-control" name="sub_name" placeholder="e.g., Mathematics">
                        </div>
                        <div class="form-group">
                            <label for="join_date">Join Date</label>
                            <input type="date" class="form-control" name="join_date" required>
                        </div>
                        <button type="submit" class="btn btn-primary btn-block">Add Teacher</button>
                    </form>
                </div>
            </div>
        </div>
        <!-- Edit Teacher Form (Hidden by Default) -->
        <div class="col-12 col-md-6">
            <div class="card" id="editForm" style="display: none;">
                <div class="card-header">
                    <h3>Edit Teacher</h3>
                </div>
                <div class="card-body">
                    <form action="manageTeacher.jsp" method="POST">
                        <input type="hidden" name="action" value="edit">
                        <input type="hidden" name="t_id" id="edit_t_id">
                        <div class="form-group">
                            <label for="edit_t_name">Name</label>
                            <input type="text" class="form-control" name="edit_t_name" id="edit_t_name" required>
                        </div>
                        <div class="form-group">
                            <label for="edit_t_email">Email</label>
                            <input type="email" class="form-control" name="edit_t_email" id="edit_t_email" required>
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
                            <label for="edit_phone_number">Phone Number</label>
                            <input type="text" class="form-control" name="edit_phone_number" id="edit_phone_number">
                        </div>
                        <div class="form-group">
                            <label for="edit_address">Address</label>
                            <textarea class="form-control" name="edit_address" id="edit_address" rows="3"></textarea>
                        </div>
                        <div class="form-group">
                            <label for="edit_sub_name">Subject</label>
                            <input type="text" class="form-control" name="edit_sub_name" id="edit_sub_name">
                        </div>
                        <div class="form-group">
                            <label for="edit_join_date">Join Date</label>
                            <input type="date" class="form-control" name="edit_join_date" id="edit_join_date" required>
                        </div>
                        <button type="submit" class="btn btn-primary btn-block">Update Teacher</button>
                        <button type="button" class="btn btn-secondary btn-block" onclick="document.getElementById('editForm').style.display='none';">Cancel</button>
                    </form>
                </div>
            </div>
        </div>
    </div>
    <!-- Teachers Table -->
    <div class="row mt-4">
        <div class="col-12">
            <h3>All Teachers</h3>
            <table class="table table-bordered">
                <thead>
                    <tr>
                        <th>Teacher ID</th>
                        <th>Name</th>
                        <th>Email</th>
                        <th>Gender</th>
                        <th>Phone Number</th>
                        <th>Address</th>
                        <th>Subject</th>
                        <th>Join Date</th>
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
                            String sql = "SELECT t_id, t_name, t_email, gender, phone_number, address, sub_name, join_date FROM teachers ORDER BY t_id";
                            pstmt = conn.prepareStatement(sql);
                            rs = pstmt.executeQuery();
                            while (rs.next()) {
                                String t_id = rs.getString("t_id");
                                String t_name = rs.getString("t_name");
                                String t_email = rs.getString("t_email");
                                String gender = rs.getString("gender");
                                String phone_number = rs.getString("phone_number");
                                String address = rs.getString("address");
                                String sub_name = rs.getString("sub_name");
                                String join_date = rs.getString("join_date");
                    %>
                    <tr>
                        <td><%= t_id %></td>
                        <td><%= t_name %></td>
                        <td><%= t_email %></td>
                        <td><%= gender != null ? gender : "-" %></td>
                        <td><%= phone_number != null ? phone_number : "-" %></td>
                        <td><%= address != null ? address : "-" %></td>
                        <td><%= sub_name != null ? sub_name : "-" %></td>
                        <td><%= join_date %></td>
                        <td>
                            <button class="btn btn-sm btn-warning" onclick="editTeacher('<%= t_id %>', '<%= t_name.replace("'", "\\'") %>', '<%= t_email.replace("'", "\\'") %>', '<%= gender != null ? gender : "" %>', '<%= phone_number != null ? phone_number.replace("'", "\\'") : "" %>', '<%= address != null ? address.replace("'", "\\'") : "" %>', '<%= sub_name != null ? sub_name.replace("'", "\\'") : "" %>', '<%= join_date %>')">Edit</button>
                            <form action="manageTeacher.jsp" method="POST" style="display:inline;">
                                <input type="hidden" name="action" value="delete">
                                <input type="hidden" name="t_id" value="<%= t_id %>">
                                <button type="submit" class="btn btn-sm btn-danger" onclick="return confirm('Are you sure you want to delete this teacher?')">Delete</button>
                            </form>
                        </td>
                    </tr>
                    <%
                            }
                        } catch (Exception e) {
                            out.println("<tr><td colspan='9' class='text-danger'>Error fetching teachers: " + e.getMessage() + "</td></tr>");
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
    function editTeacher(t_id, t_name, t_email, gender, phone_number, address, sub_name, join_date) {
        document.getElementById('editForm').style.display = 'block';
        document.getElementById('edit_t_id').value = t_id;
        document.getElementById('edit_t_name').value = t_name;
        document.getElementById('edit_t_email').value = t_email;
        document.getElementById('edit_gender').value = gender;
        document.getElementById('edit_phone_number').value = phone_number;
        document.getElementById('edit_address').value = address;
        document.getElementById('edit_sub_name').value = sub_name;
        document.getElementById('edit_join_date').value = join_date;
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
                String t_id = request.getParameter("t_id");
                String t_name = request.getParameter("t_name");
                String t_email = request.getParameter("t_email");
                String gender = request.getParameter("gender");
                String phone_number = request.getParameter("phone_number");
                String address = request.getParameter("address");
                String sub_name = request.getParameter("sub_name");
                String join_date = request.getParameter("join_date");
                pstmt = conn.prepareStatement("INSERT INTO teachers (t_id, t_name, t_email, gender, phone_number, address, sub_name, join_date) VALUES (?, ?, ?, ?, ?, ?, ?, ?)");
                pstmt.setString(1, t_id);
                pstmt.setString(2, t_name);
                pstmt.setString(3, t_email);
                pstmt.setString(4, gender);
                pstmt.setString(5, phone_number != null && !phone_number.isEmpty() ? phone_number : null);
                pstmt.setString(6, address != null && !address.isEmpty() ? address : null);
                pstmt.setString(7, sub_name != null && !sub_name.isEmpty() ? sub_name : null);
                pstmt.setString(8, join_date);
                pstmt.executeUpdate();
                response.sendRedirect("manageTeacher.jsp?success=added");
            } else if ("edit".equals(action)) {
                String t_id = request.getParameter("t_id");
                String t_name = request.getParameter("edit_t_name");
                String t_email = request.getParameter("edit_t_email");
                String gender = request.getParameter("edit_gender");
                String phone_number = request.getParameter("edit_phone_number");
                String address = request.getParameter("edit_address");
                String sub_name = request.getParameter("edit_sub_name");
                String join_date = request.getParameter("edit_join_date");
                pstmt = conn.prepareStatement("UPDATE teachers SET t_name = ?, t_email = ?, gender = ?, phone_number = ?, address = ?, sub_name = ?, join_date = ? WHERE t_id = ?");
                pstmt.setString(1, t_name);
                pstmt.setString(2, t_email);
                pstmt.setString(3, gender);
                pstmt.setString(4, phone_number != null && !phone_number.isEmpty() ? phone_number : null);
                pstmt.setString(5, address != null && !address.isEmpty() ? address : null);
                pstmt.setString(6, sub_name != null && !sub_name.isEmpty() ? sub_name : null);
                pstmt.setString(7, join_date);
                pstmt.setString(8, t_id);
                pstmt.executeUpdate();
                response.sendRedirect("manageTeacher.jsp?success=edited");
            } else if ("delete".equals(action)) {
                String t_id = request.getParameter("t_id");
                pstmt = conn.prepareStatement("DELETE FROM teachers WHERE t_id = ?");
                pstmt.setString(1, t_id);
                pstmt.executeUpdate();
                response.sendRedirect("manageTeacher.jsp?success=deleted");
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
        if ("added".equals(success)) message = "Teacher added successfully!";
        else if ("edited".equals(success)) message = "Teacher updated successfully!";
        else if ("deleted".equals(success)) message = "Teacher deleted successfully!";
%>
<div class="alert alert-success alert-dismissible fade show" role="alert">
    <%= message %>
    <button type="button" class="close" data-dismiss="alert" aria-label="Close">
        <span aria-hidden="true">×</span>
    </button>
</div>
<% } %>
</html>