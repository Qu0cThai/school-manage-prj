<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.security.MessageDigest" %>
<%@ include file="/WEB-INF/jspf/db-connection.jsp" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login - School Management System</title>
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">
</head>
<body>
    <div class="container" style="min-height: 100vh; display: flex; align-items: center; justify-content: center;">
        <div class="card" style="width: 100%; max-width: 400px;">
            <div class="card-header text-center">
                <h3>Login</h3>
            </div>
            <div class="card-body">
                <%
                    String errorMessage = "";
                    if ("POST".equalsIgnoreCase(request.getMethod())) {
                        String roleId = request.getParameter("role");
                        String username = request.getParameter("username");
                        String password = request.getParameter("password");

                        Connection conn = null;
                        PreparedStatement pstmt = null;
                        ResultSet rs = null;
                        try {
                            conn = getConnection();
                            // Hash password with MD5
                            MessageDigest md = MessageDigest.getInstance("MD5");
                            byte[] hash = md.digest(password.getBytes());
                            StringBuilder hexString = new StringBuilder();
                            for (byte b : hash) {
                                String hex = Integer.toHexString(0xff & b);
                                if (hex.length() == 1) hexString.append('0');
                                hexString.append(hex);
                            }
                            String hashedPassword = hexString.toString();

                            pstmt = conn.prepareStatement("SELECT u_id, u_name, r_id, is_profile_complete FROM users WHERE u_name = ? AND password = ? AND r_id = ?");
                            pstmt.setString(1, username);
                            pstmt.setString(2, hashedPassword);
                            pstmt.setInt(3, Integer.parseInt(roleId));
                            rs = pstmt.executeQuery();

                            if (rs.next()) {
                                session.setAttribute("u_id", rs.getString("u_id"));
                                session.setAttribute("username", rs.getString("u_name"));
                                session.setAttribute("userRId", rs.getInt("r_id"));
                                boolean isProfileComplete = rs.getBoolean("is_profile_complete");
                                if (!isProfileComplete) {
                                    if (rs.getInt("r_id") == 2) {
                                        response.sendRedirect("editTeacher.jsp");
                                    } else if (rs.getInt("r_id") == 3) {
                                        response.sendRedirect("editStudent.jsp");
                                    } else {
                                        response.sendRedirect("index.jsp");
                                    }
                                } else {
                                    response.sendRedirect("index.jsp");
                                }
                            } else {
                                errorMessage = "Invalid username, password, or role.";
                            }
                        } catch (Exception e) {
                            errorMessage = "Error: " + e.getMessage();
                        } finally {
                            closeResources(conn, pstmt, rs);
                        }
                    }
                %>
                <% if (!errorMessage.isEmpty()) { %>
                    <div class="alert alert-danger"><%= errorMessage %></div>
                <% } %>
                <form method="POST" action="login.jsp">
                    <div class="form-group">
                        <label for="role">Role</label>
                        <select class="form-control" id="role" name="role" required>
                            <option value="">Select Role</option>
                            <%
                                Connection conn = null;
                                Statement stmt = null;
                                ResultSet rs = null;
                                try {
                                    conn = getConnection();
                                    stmt = conn.createStatement();
                                    rs = stmt.executeQuery("SELECT r_id, r_name FROM roles");
                                    while (rs.next()) {
                            %>
                            <option value="<%= rs.getInt("r_id") %>"><%= rs.getString("r_name") %></option>
                            <%
                                    }
                                } catch (Exception e) {
                                    out.println("<option>Error loading roles</option>");
                                } finally {
                                    closeResources(conn, stmt, rs);
                                }
                            %>
                        </select>
                    </div>
                    <div class="form-group">
                        <label for="username">Username</label>
                        <input type="text" class="form-control" id="username" name="username" required>
                    </div>
                    <div class="form-group">
                        <label for="password">Password</label>
                        <input type="password" class="form-control" id="password" name="password" required>
                    </div>
                    <button type="submit" class="btn btn-primary btn-block">Login</button>
                </form>
                <div class="text-center mt-3">
                    <p>Don't have an account? <a href="register.jsp">Register here</a></p>
                </div>
            </div>
        </div>
    </div>
    <script src="https://code.jquery.com/jquery-3.5.1.slim.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@4.5.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>