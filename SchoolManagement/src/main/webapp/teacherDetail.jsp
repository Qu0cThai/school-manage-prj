<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ include file="/WEB-INF/jspf/db-connection.jsp" %>
<%@ include file="header.jsp"%>
    <body>
        <div class="container" style="min-height: 100vh; padding-bottom: 4rem;">
            <!--body-->
            <div class="row">
                <div class="col-12 col-sm-12 col-md-12">
                    <!--teacher details-->
                    <div class="row">
                        <div class="col-8 offset-md-2">
                            <div class="container border rounded pb-5">
                                <br/>
                                <h3>Teacher Details:</h3>
                                <div style="max-height: 70vh; overflow-y: auto; padding-right: 1rem;">
                                    <% 
                                        Connection conn = null;
                                        PreparedStatement pstmt = null;
                                        ResultSet rs = null;
                                        String t_id = request.getParameter("t_id");
                                        try {
                                            conn = getConnection();
                                            pstmt = conn.prepareStatement("SELECT t_id, t_name, t_email, gender, phone_number, address, sub_name, join_date FROM teachers WHERE t_id = ?");
                                            pstmt.setString(1, t_id != null ? t_id : "T001");
                                            rs = pstmt.executeQuery();
                                            if (rs.next()) {
                                    %>
                                    <form class="form-group" action="" method="">
                                        <h6 class="modal-title mt-3">Teacher Id</h6>
                                        <input class="form-control mb-3" type="text" name="t_id" value="<%= rs.getString("t_id") %>" readonly/>
                                        <h6 class="modal-title">Teacher Name</h6>
                                        <input class="form-control mb-3" type="text" name="t_name" value="<%= rs.getString("t_name") %>" readonly/>
                                        <h6 class="modal-title">Email</h6>
                                        <input class="form-control mb-3" type="text" name="t_email" value="<%= rs.getString("t_email") %>" readonly/>
                                        <h6 class="modal-title">Gender</h6>
                                        <input class="form-control mb-3" type="text" name="gender" value="<%= rs.getString("gender") %>" readonly/>
                                        <h6 class="modal-title">Phone Number</h6>
                                        <input class="form-control mb-3" type="text" name="p_number" value="<%= rs.getString("phone_number") %>" readonly/>
                                        <h6 class="modal-title">Address</h6>
                                        <textarea class="form-control mb-3" name="t_address" readonly><%= rs.getString("address") %></textarea>
                                        <h6 class="modal-title">Subject Name</h6>
                                        <input class="form-control mb-3" type="text" name="sub_id" value="<%= rs.getString("sub_name") %>" readonly/>
                                        <h6 class="modal-title">Join Date</h6>
                                        <input class="form-control mb-3" type="text" name="join_date" value="<%= rs.getString("join_date") %>" readonly/>
                                    </form>
                                    <% 
                                            } else {
                                    %>
                                    <p class="text-danger">Teacher not found.</p>
                                    <% 
                                            }
                                        } catch (Exception e) {
                                            e.printStackTrace();
                                    %>
                                    <p class="text-danger">Error loading teacher details.</p>
                                    <% 
                                        } finally {
                                            closeResources(conn, pstmt, rs);
                                        }
                                    %>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </body>
<%@ include file="footer.jsp"%>