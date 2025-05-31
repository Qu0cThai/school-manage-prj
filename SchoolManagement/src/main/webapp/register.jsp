<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.security.MessageDigest" %>
<%@ include file="/WEB-INF/jspf/db-connection.jsp" %>
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Registration - School Management System</title>
    <!-- Bootstrap 5.3.0 -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet" crossorigin="anonymous">
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js" crossorigin="anonymous"></script>
    <!-- Font Awesome -->
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
        }
        .register-card {
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
            <div class="register-card mt-5">
                <div class="card-header text-center">
                    <small class="text-danger">Please Sign-up First</small>
                    <h1>Registration</h1>
                    <% 
                        String error = request.getParameter("error");
                        if ("exists".equals(error)) {
                    %>
                    <small class="text-danger">Username or email already exists.</small>
                    <% } else if ("db".equals(error)) { %>
                    <small class="text-danger">Registration failed. Please try again.</small>
                    <% } %>
                </div>
                <div class="card-body">
                    <form action="register.jsp" method="POST">
                        <div class="form-group mb-4">
                            <label for="u_name" class="mb-1">Username</label>
                            <div class="input-group">
                                <span class="input-group-text"><i class="fas fa-user"></i></span>
                                <input type="text" class="form-control" id="u_name" name="u_name" placeholder="Username" required/>
                            </div>
                        </div>
                        <div class="form-group mb-4">
                            <label for="password" class="mb-1">Password</label>
                            <div class="input-group">
                                <span class="input-group-text"><i class="fas fa-lock"></i></span>
                                <input type="password" class="form-control" id="password" name="password" placeholder="Password" required/>
                            </div>
                        </div>
                        <div class="form-group mb-4">
                            <label for="email" class="mb-1">E-mail</label>
                            <div class="input-group">
                                <span class="input-group-text"><i class="fas fa-envelope"></i></span>
                                <input type="email" class="form-control" id="email" name="email" placeholder="E-mail" required/>
                            </div>
                        </div>
                        <div class="form-group mb-4">
                            <label for="phone" class="mb-1">Phone Number</label>
                            <div class="input-group">
                                <span class="input-group-text"><i class="fas fa-phone"></i></span>
                                <input type="text" class="form-control" id="phone" name="phone" placeholder="Phone Number" required/>
                            </div>
                        </div>
                        <div class="form-group mb-4">
                            <label for="r_id" class="mb-1">Register As</label>
                            <div class="input-group">
                                <span class="input-group-text"><i class="fas fa-users"></i></span>
                                <select class="form-select" id="r_id" name="r_id" required>
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
                                            e.printStackTrace();
                                        } finally {
                                            try { if (rs != null) rs.close(); } catch (SQLException e) {}
                                            try { if (stmt != null) stmt.close(); } catch (SQLException e) {}
                                            try { if (conn != null) conn.close(); } catch (SQLException e) {}
                                        }
                                    %>
                                </select>
                            </div>
                        </div>
                        <button type="submit" class="btn btn-primary btn-block">Register</button>
                    </form>
                    <div class="text-right mt-3">
                        <small><a href="login.jsp">Back to Login</a></small>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
<% 
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String u_name = request.getParameter("u_name") != null ? request.getParameter("u_name").trim() : "";
        String password = request.getParameter("password");
        String email = request.getParameter("email") != null ? request.getParameter("email").trim() : "";
        String phone = request.getParameter("phone");
        String r_id = request.getParameter("r_id");
        conn = null;
        PreparedStatement pstmt = null;
        try {
            conn = getConnection();
            // Check if username or email exists
            pstmt = conn.prepareStatement("SELECT COUNT(*) FROM users WHERE u_name = ? OR email = ?");
            pstmt.setString(1, u_name);
            pstmt.setString(2, email);
            rs = pstmt.executeQuery();
            rs.next();
            if (rs.getInt(1) > 0) {
                response.sendRedirect("register.jsp?error=exists");
                return;
            }
            rs.close();
            pstmt.close();

            // Generate u_id based on role
            String u_id_prefix = "";
            if ("2".equals(r_id)) {
                u_id_prefix = "T";
            } else if ("3".equals(r_id)) {
                u_id_prefix = "S";
            } else if ("1".equals(r_id)) {
                u_id_prefix = "A";
            } else {
                throw new Exception("Invalid role ID");
            }

            pstmt = conn.prepareStatement("SELECT MAX(CAST(SUBSTRING(u_id, 2) AS UNSIGNED)) FROM users WHERE u_id LIKE ?");
            pstmt.setString(1, u_id_prefix + "%");
            rs = pstmt.executeQuery();
            int nextNumber = 1;
            if (rs.next() && rs.getInt(1) > 0) {
                nextNumber = rs.getInt(1) + 1;
            }
            rs.close();
            pstmt.close();
            String u_id = String.format("%s%03d", u_id_prefix, nextNumber);

            // Hash password (using MD5 for simplicity; use BCrypt in production)
            MessageDigest md = MessageDigest.getInstance("MD5");
            md.update(password.getBytes());
            byte[] digest = md.digest();
            StringBuilder sb = new StringBuilder();
            for (byte b : digest) {
                sb.append(String.format("%02x", b));
            }
            String hashedPassword = sb.toString();

            // Insert new user
            pstmt = conn.prepareStatement("INSERT INTO users (u_id, u_name, password, email, phone, r_id) VALUES (?, ?, ?, ?, ?, ?)");
            pstmt.setString(1, u_id);
            pstmt.setString(2, u_name);
            pstmt.setString(3, hashedPassword);
            pstmt.setString(4, email);
            pstmt.setString(5, phone);
            pstmt.setInt(6, Integer.parseInt(r_id));
            pstmt.executeUpdate();

            // If teacher or student, insert into respective tables
            if ("2".equals(r_id)) {
                pstmt = conn.prepareStatement("INSERT INTO teachers (t_id, t_name, t_email, phone_number) VALUES (?, ?, ?, ?)");
                pstmt.setString(1, u_id);
                pstmt.setString(2, u_name);
                pstmt.setString(3, email);
                pstmt.setString(4, phone);
                pstmt.executeUpdate();
            } else if ("3".equals(r_id)) {
                pstmt = conn.prepareStatement("INSERT INTO students (s_id, s_name, mobile_no) VALUES (?, ?, ?)");
                pstmt.setString(1, u_id);
                pstmt.setString(2, u_name);
                pstmt.setString(3, phone);
                pstmt.executeUpdate();
            }

            response.sendRedirect("login.jsp?success=registered");
        } catch (SQLException e) {
            e.printStackTrace();
            System.err.println("SQL Error: " + e.getMessage() + ", SQLState: " + e.getSQLState());
            if (e.getSQLState().startsWith("23")) { // Integrity constraint violation
                response.sendRedirect("register.jsp?error=exists");
            } else {
                response.sendRedirect("register.jsp?error=db");
            }
        } catch (Exception e) {
            e.printStackTrace();
            System.err.println("General Error: " + e.getMessage());
            response.sendRedirect("register.jsp?error=db");
        } finally {
            try { if (rs != null) rs.close(); } catch (SQLException e) {}
            try { if (pstmt != null) pstmt.close(); } catch (SQLException e) {}
            try { if (conn != null) conn.close(); } catch (SQLException e) {}
        }
    }
%>
</body>
</html>