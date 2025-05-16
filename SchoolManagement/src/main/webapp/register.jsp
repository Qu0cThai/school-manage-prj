<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ include file="/WEB-INF/jspf/db-connection.jsp" %>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Login Page</title>
        <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0/css/bootstrap.min.css" crossorigin="anonymous">
        <!-- Bootstrap JS and dependencies -->
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
                                                closeResources(conn, stmt, rs);
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
                String u_name = request.getParameter("u_name");
                String password = request.getParameter("password");
                String email = request.getParameter("email");
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
                    } else {
                        pstmt = conn.prepareStatement("INSERT INTO users (u_name, password, email, phone, r_id) VALUES (?, ?, ?, ?, ?)");
                        pstmt.setString(1, u_name);
                        pstmt.setString(2, password);
                        pstmt.setString(3, email);
                        pstmt.setString(4, phone);
                        pstmt.setInt(5, Integer.parseInt(r_id));
                        pstmt.executeUpdate();
                        response.sendRedirect("login.jsp");
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                    response.sendRedirect("register.jsp?error=exists");
                } finally {
                    closeResources(conn, pstmt, rs);
                }
            }
        %>
    </body>