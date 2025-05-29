<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.security.MessageDigest" %>
<%@ include file="/WEB-INF/jspf/db-connection.jsp" %>
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <title>Registration Page</title>
    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0/css/bootstrap.min.css" crossorigin="anonymous">
    <script src="https://code.jquery.com/jquery-3.2.1.slim.min.js" crossorigin="anonymous"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.12.9/umd/popper.min.js" crossorigin="anonymous"></script>
    <script src="https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0/js/bootstrap.min.js" crossorigin="anonymous"></script>
</head>
<body>
<div class="container" style="min-height: 100vh; padding-bottom: 4rem;">
    <div class="row">
        <div class="col-md-4 offset-md-4">
            <div class="card mt-5">
                <div class="card-header text-center">
                    <small class="text-danger">Please Sign-up first</small>
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
                        <div class="form-group">
                            <input type="text" class="form-control" name="u_name" placeholder="Username" required/>
                        </div>
                        <div class="form-group">
                            <input type="password" class="form-control" name="password" placeholder="Password" required/>
                        </div>
                        <div class="form-group">
                            <input type="email" class="form-control" name="email" placeholder="E-mail" required/>
                        </div>
                        <div class="form-group">
                            <input type="text" class="form-control" name="phone" placeholder="Phone Number" required/>
                        </div>
                        <div class="form-group">
                            <select class="form-control" name="r_id" required>
                                <option value="">Registration As</option>
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
                        <button type="submit" class="btn btn-primary btn-block">Registration</button>
                    </form>
                    <div class="text-right mt-3">
                        <small><a href="login.jsp">Back</a></small>
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
            // Log the SQL error for debugging
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