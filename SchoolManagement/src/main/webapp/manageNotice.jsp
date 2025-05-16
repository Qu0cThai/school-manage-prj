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
    <!-- Jumbotron -->
    <div class="jumbotron jumbotron-fluid">
        <div class="container">
            <h1 class="display-4">Manage Notices, <%= username %>!</h1>
            <p class="lead">Add, edit, or delete notices for the notice board.</p>
        </div>
    </div>
    <!-- Add Notice Form -->
    <div class="row">
        <div class="col-12 col-md-6">
            <div class="card">
                <div class="card-header">
                    <h3>Add New Notice</h3>
                </div>
                <div class="card-body">
                    <form action="manageNotice.jsp" method="POST">
                        <input type="hidden" name="action" value="add">
                        <div class="form-group">
                            <label for="n_title">Title</label>
                            <input type="text" class="form-control" name="n_title" placeholder="Enter notice title" required>
                        </div>
                        <div class="form-group">
                            <label for="n_description">Description</label>
                            <textarea class="form-control" name="n_description" rows="4" placeholder="Enter description"></textarea>
                        </div>
                        <div class="form-group">
                            <label for="publish_date">Publish Date</label>
                            <input type="date" class="form-control" name="publish_date" required>
                        </div>
                        <button type="submit" class="btn btn-primary btn-block">Add Notice</button>
                    </form>
                </div>
            </div>
        </div>
        <!-- Edit Notice Form (Hidden by Default, Populated via JavaScript) -->
        <div class="col-12 col-md-6">
            <div class="card" id="editForm" style="display: none;">
                <div class="card-header">
                    <h3>Edit Notice</h3>
                </div>
                <div class="card-body">
                    <form action="manageNotice.jsp" method="POST">
                        <input type="hidden" name="action" value="edit">
                        <input type="hidden" name="n_id" id="edit_n_id">
                        <div class="form-group">
                            <label for="edit_n_title">Title</label>
                            <input type="text" class="form-control" name="edit_n_title" id="edit_n_title" required>
                        </div>
                        <div class="form-group">
                            <label for="edit_n_description">Description</label>
                            <textarea class="form-control" name="edit_n_description" id="edit_n_description" rows="4"></textarea>
                        </div>
                        <div class="form-group">
                            <label for="edit_publish_date">Publish Date</label>
                            <input type="date" class="form-control" name="edit_publish_date" id="edit_publish_date" required>
                        </div>
                        <button type="submit" class="btn btn-primary btn-block">Update Notice</button>
                        <button type="button" class="btn btn-secondary btn-block" onclick="document.getElementById('editForm').style.display='none';">Cancel</button>
                    </form>
                </div>
            </div>
        </div>
    </div>
    <!-- Notices Table -->
    <div class="row mt-4">
        <div class="col-12">
            <h3>All Notices</h3>
            <table class="table table-bordered">
                <thead>
                    <tr>
                        <th>Title</th>
                        <th>Description</th>
                        <th>Publish Date</th>
                        <th>Posted By</th>
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
                            String sql = "SELECT n.n_id, n.n_title, n.n_description, n.publish_date, u.u_name " +
                                        "FROM notices n JOIN users u ON n.created_by = u.u_id " +
                                        "ORDER BY n.publish_date DESC";
                            pstmt = conn.prepareStatement(sql);
                            rs = pstmt.executeQuery();
                            while (rs.next()) {
                                int n_id = rs.getInt("n_id");
                                String title = rs.getString("n_title");
                                String description = rs.getString("n_description");
                                String publishDate = rs.getString("publish_date");
                                String createdBy = rs.getString("u_name");
                    %>
                    <tr>
                        <td><%= title %></td>
                        <td><%= description != null ? description : "No description" %></td>
                        <td><%= publishDate %></td>
                        <td><%= createdBy %></td>
                        <td>
                            <button class="btn btn-sm btn-warning" onclick="editNotice(<%= n_id %>, '<%= title.replace("'", "\\'") %>', '<%= description != null ? description.replace("'", "\\'") : "" %>', '<%= publishDate %>')">Edit</button>
                            <form action="manageNotice.jsp" method="POST" style="display:inline;">
                                <input type="hidden" name="action" value="delete">
                                <input type="hidden" name="n_id" value="<%= n_id %>">
                                <button type="submit" class="btn btn-sm btn-danger" onclick="return confirm('Are you sure you want to delete this notice?')">Delete</button>
                            </form>
                        </td>
                    </tr>
                    <%
                            }
                        } catch (Exception e) {
                            out.println("<tr><td colspan='5' class='text-danger'>Error fetching notices: " + e.getMessage() + "</td></tr>");
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
    function editNotice(n_id, title, description, publish_date) {
        document.getElementById('editForm').style.display = 'block';
        document.getElementById('edit_n_id').value = n_id;
        document.getElementById('edit_n_title').value = title;
        document.getElementById('edit_n_description').value = description;
        document.getElementById('edit_publish_date').value = publish_date;
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
            // Get admin's u_id from users table
            int adminUId = 0;
            pstmt = conn.prepareStatement("SELECT u_id FROM users WHERE u_name = ? AND r_id = 1");
            pstmt.setString(1, username);
            rs = pstmt.executeQuery();
            if (rs.next()) {
                adminUId = rs.getInt("u_id");
            } else {
                out.println("<p class='text-danger'>Error: Admin user not found.</p>");
                return;
            }
            rs.close();
            pstmt.close();

            if ("add".equals(action)) {
                String title = request.getParameter("n_title");
                String description = request.getParameter("n_description");
                String publishDate = request.getParameter("publish_date");
                pstmt = conn.prepareStatement("INSERT INTO notices (n_title, n_description, publish_date, created_by) VALUES (?, ?, ?, ?)");
                pstmt.setString(1, title);
                pstmt.setString(2, description != null && !description.isEmpty() ? description : null);
                pstmt.setString(3, publishDate);
                pstmt.setInt(4, adminUId);
                pstmt.executeUpdate();
                response.sendRedirect("manageNotice.jsp?success=added");
            } else if ("edit".equals(action)) {
                int n_id = Integer.parseInt(request.getParameter("n_id"));
                String title = request.getParameter("edit_n_title");
                String description = request.getParameter("edit_n_description");
                String publishDate = request.getParameter("edit_publish_date");
                pstmt = conn.prepareStatement("UPDATE notices SET n_title = ?, n_description = ?, publish_date = ? WHERE n_id = ? AND created_by = ?");
                pstmt.setString(1, title);
                pstmt.setString(2, description != null && !description.isEmpty() ? description : null);
                pstmt.setString(3, publishDate);
                pstmt.setInt(4, n_id);
                pstmt.setInt(5, adminUId);
                pstmt.executeUpdate();
                response.sendRedirect("manageNotice.jsp?success=edited");
            } else if ("delete".equals(action)) {
                int n_id = Integer.parseInt(request.getParameter("n_id"));
                pstmt = conn.prepareStatement("DELETE FROM notices WHERE n_id = ? AND created_by = ?");
                pstmt.setInt(1, n_id);
                pstmt.setInt(2, adminUId);
                pstmt.executeUpdate();
                response.sendRedirect("manageNotice.jsp?success=deleted");
            }
        } catch (Exception e) {
            out.println("<p class='text-danger'>Error processing request: " + e.getMessage() + "</p>");
        } finally {
            closeResources(conn, pstmt, rs);
        }
    }
    // Display success message
    String success = request.getParameter("success");
    if (success != null) {
        String message = "";
        if ("added".equals(success)) message = "Notice added successfully!";
        else if ("edited".equals(success)) message = "Notice updated successfully!";
        else if ("deleted".equals(success)) message = "Notice deleted successfully!";
%>
<div class="alert alert-success alert-dismissible fade show" role="alert">
    <%= message %>
    <button type="button" class="close" data-dismiss="alert" aria-label="Close">
        <span aria-hidden="true">&times;</span>
    </button>
</div>
<% } %>
</html>