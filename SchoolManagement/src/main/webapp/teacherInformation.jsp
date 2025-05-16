<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ include file="/WEB-INF/jspf/db-connection.jsp" %>
<%@ include file="header.jsp"%>
    <body>
        <div class="container" style="min-height: 100vh; padding-bottom: 4rem;">
            <!--body-->
            <div class="row">
                <div class="col-12 col-sm-12 col-md-12">
                    <!--teacher information-->
                    <div class="row">
                        <div class="col-12">
                            <div class="container">
                                <br/>
                                <h3>All Teachers:</h3>
                                <div class="table-responsive">
                                    <table class="table table-striped">
                                        <thead class="thead-dark">
                                            <tr>
                                                <th scope="col">Teacher Name</th>
                                                <th scope="col">Email</th>
                                                <th scope="col">Mobile No</th>
                                                <th scope="col">Address</th>
                                                <th></th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <% 
                                                Connection conn = null;
                                                Statement stmt = null;
                                                ResultSet rs = null;
                                                try {
                                                    conn = getConnection();
                                                    stmt = conn.createStatement();
                                                    rs = stmt.executeQuery("SELECT t_id, t_name, t_email, phone_number, address FROM teachers");
                                                    while (rs.next()) {
                                            %>
                                            <tr>
                                                <td scope="row"><%= rs.getString("t_name") %></td>
                                                <td><%= rs.getString("t_email") %></td>
                                                <td><%= rs.getString("phone_number") %></td>
                                                <td><%= rs.getString("address") %></td>
                                                <td>
                                                    <button type="button" class="btn">
                                                        <a href="teacherDetail.jsp?t_id=<%= rs.getString("t_id") %>">Details</a>
                                                    </button>
                                                </td>
                                            </tr>
                                            <% 
                                                    }
                                                } catch (Exception e) {
                                                    e.printStackTrace();
                                            %>
                                            <tr>
                                                <td colspan="5" class="text-danger">Error loading teachers.</td>
                                            </tr>
                                            <% 
                                                } finally {
                                                    closeResources(conn, stmt, rs);
                                                }
                                            %>
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </body>
<%@ include file="footer.jsp"%>