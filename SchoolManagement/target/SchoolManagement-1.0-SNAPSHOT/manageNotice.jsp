<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ include file="header.jsp"%>
<%@ include file="/WEB-INF/jspf/db-connection.jsp"%>
<%@ page import="java.sql.*, java.text.SimpleDateFormat, java.util.Date" %>
<%!
    String escapeJavaScript(String str) {
        if (str == null) return "";
        return str.replace("\\", "\\\\")
                  .replace("'", "\\'")
                  .replace("\"", "\\\"")
                  .replace("\n", "\\n")
                  .replace("\r", "\\r");
    }
%>
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

    if (u_id == null || u_name == null || userRId == null || (userRId != 1)) {
        response.sendRedirect("index.jsp");
        return;
    }

    String errorMessage = "";
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
        animation: fadeIn 1s ease-in;
        margin-bottom: 2rem;
    }
    .form-group {
        position: relative;
        margin-bottom: 1.5rem;
    }
    .form-group label {
        color: #495057;
        font-weight: bold;
    }
    .form-group input, .form-group textarea, .form-group select {
        border-radius: 8px;
        border: 1px solid #ced4da;
        transition: border-color 0.3s ease;
    }
    .form-group input:focus, .form-group textarea:focus, .form-group select:focus {
        border-color: #4facfe;
        box-shadow: 0 0 5px rgba(79, 172, 254, 0.3);
    }
    .btn-primary {
        background: #4facfe;
        border: none;
        transition: all 0.3s ease;
    }
    .btn-primary:hover {
        background: #4facfe;
        transform: scale(1.05);
    }
    .btn-secondary {
        background: linear-gradient(90deg, #ff7e5f, #feb47b);
        border: none;
        transition: all 0.3s ease;
    }
    .btn-secondary:hover {
        transform: scale(1.05);
    }
    .btn-warning {
        background: linear-gradient(90deg, #ffca28, #ffeb3b);
        border: none;
        transition: all 0.3s ease;
    }
    .btn-warning:hover {
        transform: scale(1.05);
    }
    .btn-danger {
        background: linear-gradient(90deg, #dc3545, #f44336);
        border: none;
        transition: all 0.3s ease;
    }
    .btn-danger:hover {
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
    .table tbody tr {
        transition: background-color 0.3s ease;
    }
    .table tbody tr:hover {
        background: #e0f7fa;
    }
    .table tbody td {
        text-align: center;
        vertical-align: middle;
    }
    .table tbody tr.my-notice {
        background: rgba(40, 167, 69, 0.2);
    }
    .alert-success, .alert-danger {
        border-radius: 8px;
        margin-bottom: 1.5rem;
        text-align: center;
    }
</style>
<div class="container mt-4">
    <%
        String success = request.getParameter("success");
        if (success != null) {
            String message = "";
            if ("added".equals(success)) message = "Notice added successfully!";
            else if ("edited".equals(success)) message = "Notice updated successfully!";
            else if ("deleted".equals(success)) message = "Notice deleted successfully!";
    %>
    <div class="alert alert-success alert-dismissible fade show" role="alert">
        <%= message %>
        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
    </div>
    <% } %>
    <% if (!errorMessage.isEmpty()) { %>
    <div class="alert alert-danger alert-dismissible fade show" role="alert">
        <%= errorMessage %>
        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
    </div>
    <% } %>

    <div class="form-container">
        <h3>Add New Notice</h3>
        <form action="manageNotice.jsp" method="POST">
            <input type="hidden" name="action" value="add">
            <div class="form-group">
                <label for="n_title">Title</label>
                <input type="text" class="form-control" id="n_title" name="n_title" placeholder="Enter notice title" required>
            </div>
            <div class="form-group">
                <label for="n_description">Description</label>
                <textarea class="form-control" id="n_description" name="n_description" rows="4" placeholder="Enter description"></textarea>
            </div>
            <div class="form-group">
                <label for="publish_date">Publish Date</label>
                <input type="date" class="form-control" id="publish_date" name="publish_date" required>
            </div>
            <button type="submit" class="btn btn-primary">Add Notice</button>
        </form>
    </div>

    <div class="form-container" id="editForm" style="display: none;">
        <h3>Edit Notice</h3>
        <form action="manageNotice.jsp" method="POST">
            <input type="hidden" name="action" value="edit">
            <input type="hidden" name="n_id" id="edit_n_id">
            <div class="form-group">
                <label for="edit_n_title">Title</label>
                <input type="text" class="form-control" id="edit_n_title" name="n_title" required>
            </div>
            <div class="form-group">
                <label for="edit_n_description">Description</label>
                <textarea class="form-control" id="edit_n_description" name="n_description" rows="4"></textarea>
            </div>
            <div class="form-group">
                <label for="edit_publish_date">Publish Date</label>
                <input type="date" class="form-control" id="edit_publish_date" name="publish_date" required>
            </div>
            <button type="submit" class="btn btn-primary">Update Notice</button>
            <button type="button" class="btn btn-secondary" onclick="document.getElementById('editForm').style.display='none';">Cancel</button>
        </form>
    </div>

    <div class="table-container">
        <h3>All Notices</h3>
        <div class="table-responsive">
            <table class="table table-bordered" id="noticesTable">
                <thead>
                    <tr>
                        <th data-sort="n_title">Title</th>
                        <th data-sort="n_description">Description</th>
                        <th data-sort="publish_date">Publish Date</th>
                        <th data-sort="u_name">Posted By</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                        SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
                        try {
                            conn = getConnection();
                            String sql = "SELECT n.n_id, n.n_title, n.n_description, n.publish_date, n.created_by, u.u_name " +
                                        "FROM notices n JOIN users u ON n.created_by = u.u_id " +
                                        "ORDER BY n.publish_date DESC";
                            pstmt = conn.prepareStatement(sql);
                            rs = pstmt.executeQuery();
                            if (!rs.next()) {
                                out.println("<tr><td colspan='5' class='text-center'>No notices found.</td></tr>");
                            } else {
                                do {
                                    int n_id = rs.getInt("n_id");
                                    String title = rs.getString("n_title");
                                    String description = rs.getString("n_description");
                                    Date publishDate = rs.getDate("publish_date");
                                    String formattedPublishDate = publishDate != null ? dateFormat.format(publishDate) : "";
                                    String createdBy = rs.getString("u_name");
                                    String noticeCreator = rs.getString("created_by");
                    %>
                    <tr class="<%= noticeCreator.equals(u_id) ? "my-notice" : "" %>">
                        <td><%= title %></td>
                        <td><%= description != null ? description : "No description" %></td>
                        <td><%= formattedPublishDate %></td>
                        <td><%= createdBy %></td>
                        <td>
                            <%
                                if (noticeCreator.equals(u_id)) {
                            %>
                            <button class="btn btn-warning btn-sm" onclick="editNotice(<%= n_id %>, '<%= escapeJavaScript(title) %>', '<%= escapeJavaScript(description != null ? description : "") %>', '<%= formattedPublishDate %>')">Edit</button>
                            <form action="manageNotice.jsp" method="POST" style="display:inline;">
                                <input type="hidden" name="action" value="delete">
                                <input type="hidden" name="n_id" value="<%= n_id %>">
                                <button type="submit" class="btn btn-danger btn-sm" onclick="return confirm('Are you sure you want to delete this notice?')">Delete</button>
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
                                } while (rs.next());
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
<script>
    document.addEventListener('DOMContentLoaded', function () {
        const table = document.getElementById('noticesTable');
        const headers = table.querySelectorAll('th[data-sort]');
        headers.forEach(header => {
            header.addEventListener('click', () => {
                const sortKey = header.getAttribute('data-sort');
                const tbody = table.querySelector('tbody');
                const rows = Array.from(tbody.querySelectorAll('tr'));
                const isAscending = header.classList.toggle('sort-asc');
                rows.sort((a, b) => {
                    const aText = a.querySelector(`td:nth-child(${Array.from(headers).indexOf(header) + 1})`).textContent.trim();
                    const bText = b.querySelector(`td:nth-child(${Array.from(headers).indexOf(header) + 1})`).textContent.trim();
                    return isAscending ? aText.localeCompare(bText) : bText.localeCompare(aText);
                });
                while (tbody.firstChild) {
                    tbody.removeChild(tbody.firstChild);
                }
                rows.forEach(row => tbody.appendChild(row));
            });
        });

        window.editNotice = function(n_id, title, description, publish_date) {
            try {
                document.getElementById('editForm').style.display = 'block';
                document.getElementById('edit_n_id').value = n_id;
                document.getElementById('edit_n_title').value = title;
                document.getElementById('edit_n_description').value = description;
                document.getElementById('edit_publish_date').value = publish_date;
                window.scrollTo(0, document.getElementById('editForm').offsetTop);
            } catch (e) {
                console.error('Error in editNotice:', e);
            }
        };
    });
</script>
<%@ include file="footer.jsp"%>
<%
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String action = request.getParameter("action");
        conn = null;
        pstmt = null;
        rs = null;
        try {
            conn = getConnection();
            if ("add".equals(action)) {
                String title = request.getParameter("n_title");
                String description = request.getParameter("n_description");
                String publishDate = request.getParameter("publish_date");
                if (title == null || title.trim().isEmpty()) {
                    errorMessage = "Notice title is required.";
                    throw new Exception("Invalid title");
                }
                if (publishDate == null || !publishDate.matches("\\d{4}-\\d{2}-\\d{2}")) {
                    errorMessage = "Invalid publish date. Use format YYYY-MM-DD.";
                    throw new Exception("Invalid publish_date");
                }
                pstmt = conn.prepareStatement("INSERT INTO notices (n_title, n_description, publish_date, created_by) VALUES (?, ?, ?, ?)");
                pstmt.setString(1, title);
                pstmt.setString(2, description != null && !description.isEmpty() ? description : null);
                pstmt.setString(3, publishDate);
                pstmt.setString(4, u_id);
                pstmt.executeUpdate();
                response.sendRedirect("manageNotice.jsp?success=added");
            } else if ("edit".equals(action)) {
                String n_idStr = request.getParameter("n_id");
                String title = request.getParameter("n_title");
                String description = request.getParameter("n_description");
                String publishDate = request.getParameter("publish_date");
                int n_id;
                try {
                    n_id = Integer.parseInt(n_idStr);
                } catch (NumberFormatException e) {
                    errorMessage = "Invalid notice ID.";
                    throw new Exception("Invalid n_id");
                }
                if (title == null || title.trim().isEmpty()) {
                    errorMessage = "Notice title is required.";
                    throw new Exception("Invalid title");
                }
                if (publishDate == null || !publishDate.matches("\\d{4}-\\d{2}-\\d{2}")) {
                    errorMessage = "Invalid publish date. Use format YYYY-MM-DD.";
                    throw new Exception("Invalid publish_date");
                }
                pstmt = conn.prepareStatement("UPDATE notices SET n_title = ?, n_description = ?, publish_date = ? WHERE n_id = ? AND created_by = ?");
                pstmt.setString(1, title);
                pstmt.setString(2, description != null && !description.isEmpty() ? description : null);
                pstmt.setString(3, publishDate);
                pstmt.setInt(4, n_id);
                pstmt.setString(5, u_id);
                int rows = pstmt.executeUpdate();
                if (rows > 0) {
                    response.sendRedirect("manageNotice.jsp?success=edited");
                } else {
                    errorMessage = "Notice not found or you are not authorized to edit it.";
                    throw new Exception("Update failed");
                }
            } else if ("delete".equals(action)) {
                String n_idStr = request.getParameter("n_id");
                int n_id;
                try {
                    n_id = Integer.parseInt(n_idStr);
                } catch (NumberFormatException e) {
                    errorMessage = "Invalid notice ID.";
                    throw new Exception("Invalid n_id");
                }
                pstmt = conn.prepareStatement("DELETE FROM notices WHERE n_id = ? AND created_by = ?");
                pstmt.setInt(1, n_id);
                pstmt.setString(2, u_id);
                int rows = pstmt.executeUpdate();
                if (rows > 0) {
                    response.sendRedirect("manageNotice.jsp?success=deleted");
                } else {
                    errorMessage = "Notice not found or you are not authorized to delete it.";
                    throw new Exception("Delete failed");
                }
            }
        } catch (Exception e) {
            if (errorMessage.isEmpty()) {
                errorMessage = "Error processing request: " + e.getMessage();
            }
        } finally {
            closeResources(conn, pstmt, rs);
        }
    }
%>