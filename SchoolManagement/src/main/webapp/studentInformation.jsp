<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ include file="/WEB-INF/jspf/db-connection.jsp" %>
<%@ include file="header.jsp"%>
<body>
    <div class="container" style="min-height: 100vh; padding-bottom: 4rem;">
        <div class="row">
            <div class="col-12 col-sm-12 col-md-12">
                <div class="row">
                    <div class="col-12">
                        <div class="container">
                            <br/>
                            <h3>All Students:</h3>
                            <div class="table-responsive">
                                <table class="table table-striped">
                                    <thead class="thead-dark">
                                        <tr>
                                            <th scope="col">Student Name</th>
                                            <th scope="col">Roll No</th>
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
                                                pstmt = conn.prepareStatement("SELECT s_id, s_name, roll_no, mobile_no, present_address FROM students");
                                                rs = pstmt.executeQuery();
                                                while (rs.next()) {
                                                    String s_id = rs.getString("s_id");
                                        %>
                                        <tr>
                                            <td scope="row"><%= rs.getString("s_name") %></td>
                                            <td><%= rs.getString("roll_no") %></td>
                                            <td><%= rs.getString("mobile_no") != null ? rs.getString("mobile_no") : "-" %></td>
                                            <td><%= rs.getString("present_address") != null ? rs.getString("present_address") : "-" %></td>
                                            <td>
                                                <button type="button" class="btn">
                                                    <a href="studentDetail.jsp?s_id=<%= s_id %>">Details</a>
                                                </button>
                                                <% if (userRId != null && userRId == 3 && currentUserId.equals(s_id)) { %>
                                                <button type="button" class="btn btn-warning">
                                                    <a href="editStudent.jsp">Edit</a>
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
                                            <td colspan="5" class="text-danger">Error loading students.</td>
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