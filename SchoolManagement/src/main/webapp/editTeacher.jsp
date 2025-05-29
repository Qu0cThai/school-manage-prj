<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ include file="/WEB-INF/jspf/db-connection.jsp" %>
<%@ include file="header.jsp"%>
<body>
    <div class="container" style="min-height: 100vh; padding-bottom: 4rem;">
        <%
            String u_id = (String) session.getAttribute("u_id");
            Integer userRId = (Integer) session.getAttribute("userRId");
            if (u_id == null || userRId == null || userRId != 2) {
                response.sendRedirect("index.jsp");
                return;
            }

            Connection conn = null;
            PreparedStatement pstmt = null;
            ResultSet rs = null;
            String message = "";
            String t_name = "", t_email = "", gender = "", phone_number = "", address = "", sub_name = "", join_date = "";

            // Handle form submission
            if ("POST".equalsIgnoreCase(request.getMethod())) {
                try {
                    conn = getConnection();
                    t_name = request.getParameter("t_name");
                    t_email = request.getParameter("t_email");
                    gender = request.getParameter("gender");
                    phone_number = request.getParameter("phone_number");
                    address = request.getParameter("address");
                    sub_name = request.getParameter("sub_name");
                    join_date = request.getParameter("join_date");

                    // Check if teacher record exists
                    pstmt = conn.prepareStatement("SELECT 1 FROM teachers WHERE t_id = ?");
                    pstmt.setString(1, u_id);
                    rs = pstmt.executeQuery();
                    boolean exists = rs.next();
                    rs.close();
                    pstmt.close();

                    if (exists) {
                        // Update existing record
                        pstmt = conn.prepareStatement("UPDATE teachers SET t_name = ?, t_email = ?, gender = ?, phone_number = ?, address = ?, sub_name = ?, join_date = ? WHERE t_id = ?");
                        pstmt.setString(1, t_name);
                        pstmt.setString(2, t_email);
                        pstmt.setString(3, gender);
                        pstmt.setString(4, phone_number.isEmpty() ? null : phone_number);
                        pstmt.setString(5, address.isEmpty() ? null : address);
                        pstmt.setString(6, sub_name.isEmpty() ? null : sub_name);
                        pstmt.setString(7, join_date);
                        pstmt.setString(8, u_id);
                    } else {
                        // Insert new record
                        pstmt = conn.prepareStatement("INSERT INTO teachers (t_id, t_name, t_email, gender, phone_number, address, sub_name, join_date) VALUES (?, ?, ?, ?, ?, ?, ?, ?)");
                        pstmt.setString(1, u_id);
                        pstmt.setString(2, t_name);
                        pstmt.setString(3, t_email);
                        pstmt.setString(4, gender);
                        pstmt.setString(5, phone_number.isEmpty() ? null : phone_number);
                        pstmt.setString(6, address.isEmpty() ? null : address);
                        pstmt.setString(7, sub_name.isEmpty() ? null : sub_name);
                        pstmt.setString(8, join_date);
                    }
                    pstmt.executeUpdate();

                    // Mark profile as complete
                    pstmt = conn.prepareStatement("UPDATE users SET is_profile_complete = TRUE WHERE u_id = ?");
                    pstmt.setString(1, u_id);
                    pstmt.executeUpdate();

                    message = "<div class='alert alert-success'>Profile updated successfully!</div>";
                    response.sendRedirect("index.jsp");
                } catch (Exception e) {
                    message = "<div class='alert alert-danger'>Error: " + e.getMessage() + "</div>";
                } finally {
                    closeResources(conn, pstmt, rs);
                }
            } else {
                // Load existing data
                try {
                    conn = getConnection();
                    pstmt = conn.prepareStatement("SELECT t_name, t_email, gender, phone_number, address, sub_name, join_date FROM teachers WHERE t_id = ?");
                    pstmt.setString(1, u_id);
                    rs = pstmt.executeQuery();
                    if (rs.next()) {
                        t_name = rs.getString("t_name") != null ? rs.getString("t_name") : "";
                        t_email = rs.getString("t_email") != null ? rs.getString("t_email") : "";
                        gender = rs.getString("gender") != null ? rs.getString("gender") : "";
                        phone_number = rs.getString("phone_number") != null ? rs.getString("phone_number") : "";
                        address = rs.getString("address") != null ? rs.getString("address") : "";
                        sub_name = rs.getString("sub_name") != null ? rs.getString("sub_name") : "";
                        join_date = rs.getString("join_date") != null ? rs.getString("join_date") : "";
                    }
                } catch (Exception e) {
                    message = "<div class='alert alert-danger'>Error loading profile: " + e.getMessage() + "</div>";
                } finally {
                    closeResources(conn, pstmt, rs);
                }
            }
        %>
        <%= message %>
        <div class="row">
            <div class="col-8 offset-md-2">
                <div class="card">
                    <div class="card-header">
                        <h3>Edit Your Profile</h3>
                    </div>
                    <div class="card-body">
                        <form method="POST" action="editTeacher.jsp">
                            <div class="form-group">
                                <label for="t_name">Name</label>
                                <input type="text" class="form-control" name="t_name" value="<%= t_name %>" required>
                            </div>
                            <div class="form-group">
                                <label for="t_email">Email</label>
                                <input type="email" class="form-control" name="t_email" value="<%= t_email %>" required>
                            </div>
                            <div class="form-group">
                                <label for="gender">Gender</label>
                                <select class="form-control" name="gender" required>
                                    <option value="Male" <%= "Male".equals(gender) ? "selected" : "" %>>Male</option>
                                    <option value="Female" <%= "Female".equals(gender) ? "selected" : "" %>>Female</option>
                                    <option value="Other" <%= "Other".equals(gender) ? "selected" : "" %>>Other</option>
                                </select>
                            </div>
                            <div class="form-group">
                                <label for="phone_number">Phone Number</label>
                                <input type="text" class="form-control" name="phone_number" value="<%= phone_number %>">
                            </div>
                            <div class="form-group">
                                <label for="address">Address</label>
                                <textarea class="form-control" name="address" rows="3"><%= address %></textarea>
                            </div>
                            <div class="form-group">
                                <label for="sub_name">Subject</label>
                                <input type="text" class="form-control" name="sub_name" value="<%= sub_name %>">
                            </div>
                            <div class="form-group">
                                <label for="join_date">Join Date</label>
                                <input type="date" class="form-control" name="join_date" value="<%= join_date %>" required>
                            </div>
                            <button type="submit" class="btn btn-primary btn-block">Save Profile</button>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </div>
</body>
<%@ include file="footer.jsp"%>