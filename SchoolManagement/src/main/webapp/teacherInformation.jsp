<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ include file="/WEB-INF/jspf/db-connection.jsp" %>
<%@ include file="header.jsp"%>
<body>
    <div class="container" style="min-height: 100vh; padding-bottom: 4rem;">
        <div class="row">
            <div class="col-12 col-sm-12 col-sm-12 col-md-12">
                <div class="row">
                    <div class="col-sm-12">
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
                                            <th scope="col">Actions</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <%
                                            Connection conn = null;
                                            PreparedStatement pstmt = null;
                                            ResultSet rs = null;
                                            String currentUserId = (String) session.getAttribute("u_id");
                                            Integer userRId = (Integer) session.getAttribute("userRId");
                                            try {
                                                conn = getConnection();
                                                pstmt = conn.prepareStatement("SELECT t_id, t_name, t_email, phone_number, address FROM teachers");
                                                rs = pstmt.executeQuery();
                                                while (rs.next()) {
                                                    String t_id = rs.getString("t_id");
                                        %>
                                        <tr>
                                            <td><%= rs.getString("t_name") %></td>
                                            <td><%= rs.getString("t_email") %></td>
                                            <td><%= rs.getString("phone_number") != null ? rs.getString("phone_number") : "-" %></td>
                                            <td><%= rs.getString("address") != null ? rs.getString("address") : "-" %></td>
                                            <td>
                                                <button type="button" class="btn btn-primary">
                                                    <a href="teacherDetail.jsp?t_id=<%= t_id %>">Details</a>
                                                </button>
                                                <% if (userRId != null && userRId == 2 && currentUserId.equals(t_id)) { %>
                                                <button type="button" class="btn btn-warning">
                                                    <a href="editTeacher.jsp">Edit</a>
                                                </button>
                                                <% } %>
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
                                                closeResources(conn, pstmt, rs);
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