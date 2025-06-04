<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.security.MessageDigest" %>
<%@ include file="/WEB-INF/jspf/db-connection.jsp" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login - School Management System</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet" crossorigin="anonymous">
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js" crossorigin="anonymous"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" crossorigin="anonymous">
    <style>
        body {
            background: linear-gradient(135deg, #f0f4f8, #d9e2ec);
            font-family: 'Arial', sans-serif;
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding-bottom: 4rem;
            margin: 0;
        }
    .login-card {
        background: linear-gradient(135deg, #ffffff, #e0f7fa);
        border-radius: 15px;
        box-shadow: 0 8px 16px rgba(0, 0, 0, 0.2);
        width: 100%;
        max-width: 400px;
        animation: fadeIn 1s ease-in;
    }
    .card-header {
        background: linear-gradient(90deg, #4facfe, #00f2fe);
        color: white;
        border-top-left-radius: 15px;
        border-top-right-radius: 15px;
        padding: 1.5rem;
        text-align: center;
    }
    .card-body {
        padding: 2rem;
    }
    .input-group-text {
        background: #b2ebf2;
        border: 2px solid #b2ebf2;
        border-right: none;
        color: #4facfe;
        border-radius: 8px 0 0 8px;
    }
    .form-control, .form-select {
        border: 2px solid #b2ebf2;
        border-left: none;
        border-radius: 0 8px 8px 0;
        transition: all 0.3s ease;
    }
    .form-control:focus, .form-select:focus {
        border-color: #4facfe;
        box-shadow: 0 0 8px rgba(79, 172, 254, 0.3);
    }
    .btn-primary {
        background: linear-gradient(90deg, #ff7e5f, #feb47b);
        border: none;
        border-radius: 8px;
        padding: 0.75rem;
        transition: all 0.3s ease;
    }
    .btn-primary:hover {
        background: linear-gradient(90deg, #feb47b, #ff7e5f);
        transform: scale(1.05);
    }
    .alert-danger {
        background: #f8d7da;
        color: #721c24;
        border-radius: 8px;
        animation: slideIn 0.5s ease;
    }
    a {
        color: #4facfe;
        text-decoration: none;
        transition: all 0.3s ease;
    }
    a:hover {
        color: #feb47b;
        text-decoration: underline;
    }
    @keyframes fadeIn {
        from { opacity: 0; transform: translateY(-20px); }
        to { opacity: 1; transform: translateY(0); }
    }
    @keyframes slideIn {
        from { opacity: 0; transform: translateX(-20px); }
        to { opacity: 1; transform: translateX(0); }
    }
</style>
</head>
<body>
    <div class="container">
        <div class="row justify-content-center">
            <div class="col-md-4">
                <div class="login-card mt-5">
                    <div class="card-header text-center">
                        <h3><i class="fas fa-sign-in-alt me-2"></i>Login</h3>
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
                                    errorMessage = "Login failed. Please try again.";
                                } finally {
                                    closeResources(conn, pstmt, rs);
                                }
                            }
                        %>
                        <% if (!errorMessage.isEmpty()) { %>
                            <div class="alert alert-danger"><%= errorMessage %></div>
                        <% } %>
                        <form method="POST" action="login.jsp">
                            <div class="mb-4">
                                <label for="role" class="mb-1">Role</label>
                                <div class="input-group">
                                    <span class="input-group-text"><i class="fas fa-users"></i></span>
                                    <select class="form-select" id="role" name="role" required>
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
                            </div>
                            <div class="mb-4">
                                <label for="username" class="mb-1">Username</label>
                                <div class="input-group">
                                    <span class="input-group-text"><i class="fas fa-user"></i></span>
                                    <input type="text" class="form-control" id="username" name="username" required>
                                </div>
                            </div>
                            <div class="mb-4">
                                <label for="password" class="mb-1">Password</label>
                                <div class="input-group">
                                    <span class="input-group-text"><i class="fas fa-lock"></i></span>
                                    <input type="password" class="form-control" id="password" name="password" required>
                                </div>
                            </div>
                            <button type="submit" class="btn btn-primary w-100" >Login</button>
                        </form>
                        <div class="text-center mt-3">
                            <p>Don't have an account? <a href="register.jsp">Register here</a></p>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</body>
</html>
