<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ include file="/WEB-INF/jspf/db-connection.jsp" %>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Login Page</title>
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
                            <h1>Log-in</h1>
                            <% 
                                String error = request.getParameter("error");
                                if ("invalid".equals(error)) {
                            %>
                            <small class="text-danger">Invalid credentials. Please try again.</small>
                            <% } %>
                        </div>
                        <div class="card-body">
                            <form action="login.jsp" method="POST">
                                <div class="form-group">
                                    <input type="text" class="form-control" name="u_name" placeholder="Username" required/>
                                </div>
                                <div class="form-group">
                                    <input type="password" class="form-control" name="password" placeholder="Password" required/>
                                </div>
                                <div class="form-group">
                                    <select class="form-control" name="r_id" required>
                                        <option value="">Login As</option>
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
                                <button type="submit" class="btn btn-primary btn-block">Login</button>
                            </form>
                            <div class="text-center mt-3">
                                <a href="register.jsp">Register</a>
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
                String r_id = request.getParameter("r_id");
                conn = null;
                PreparedStatement pstmt = null;
                rs = null;
                try {
                    conn = getConnection();
                    pstmt = conn.prepareStatement("SELECT u_name FROM users WHERE u_name = ? AND password = ? AND r_id = ?");
                    pstmt.setString(1, u_name);
                    pstmt.setString(2, password);
                    pstmt.setInt(3, Integer.parseInt(r_id));
                    rs = pstmt.executeQuery();
                    if (rs.next()) {
                        session.setAttribute("username", u_name);
                        session.setAttribute("userRId", Integer.parseInt(r_id));
                        response.sendRedirect("index.jsp");
                    } else {
                        response.sendRedirect("login.jsp?error=invalid");
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                    response.sendRedirect("login.jsp?error=invalid");
                } finally {
                    closeResources(conn, pstmt, rs);
                }
            }
        %>
    </body>
</html>