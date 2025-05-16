<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ include file="/WEB-INF/jspf/db-connection.jsp" %>
<%@ include file="header.jsp"%>
    <body>
        <div class="container" style="min-height: 100vh; padding-bottom: 4rem;">
            <!--body-->
            <div class="row">
                <div class="col-12 col-sm-12 col-md-12">
                    <!--student details-->
                    <div class="row">
                        <div class="col-8 offset-md-2">
                            <div class="container border rounded pb-5">
                                <br/>
                                <h3>Student Details:</h3>
                                <div style="max-height: 70vh; overflow-y: auto; padding-right: 1rem;">
                                    <% 
                                        Connection conn = null;
                                        PreparedStatement pstmt = null;
                                        ResultSet rs = null;
                                        String s_id = request.getParameter("s_id");
                                        try {
                                            conn = getConnection();
                                            pstmt = conn.prepareStatement("SELECT s_id, s_name, roll_no, gender, dob, age, f_name, m_name, mobile_no, present_address, permanent_address FROM students WHERE s_id = ?");
                                            pstmt.setString(1, s_id != null ? s_id : "S001");
                                            rs = pstmt.executeQuery();
                                            if (rs.next()) {
                                    %>
                                    <form class="form-group" action="" method="">
                                        <center>
                                            <img class="img-thumbnail" style="width:200px; height:200px; margin-bottom: 1rem;" 
                                                 src="resource/images/<%= rs.getString("s_name") %>_<%= rs.getString("roll_no") %>.jpg" 
                                                 alt="<%= rs.getString("s_name") %> Image"/>
                                        </center>
                                        <h6 class="modal-title mt-3">Student Name</h6>
                                        <input class="form-control mb-3" type="text" name="s_name" value="<%= rs.getString("s_name") %>" readonly/>
                                        <h6 class="modal-title">Roll No</h6>
                                        <input class="form-control mb-3" type="text" name="roll_no" value="<%= rs.getString("roll_no") %>" readonly/>
                                        <h6 class="modal-title">Gender</h6>
                                        <input class="form-control mb-3" type="text" name="gender" value="<%= rs.getString("gender") %>" readonly/>
                                        <h6 class="modal-title">Date of Birth</h6>
                                        <input class="form-control mb-3" type="text" name="dob" value="<%= rs.getString("dob") %>" readonly/>
                                        <h6 class="modal-title">Age</h6>
                                        <input class="form-control mb-3" type="text" name="age" value="<%= rs.getInt("age") %>" readonly/>
                                        <h6 class="modal-title">Father Name</h6>
                                        <input class="form-control mb-3" type="text" name="f_name" value="<%= rs.getString("f_name") %>" readonly/>
                                        <h6 class="modal-title">Mother Name</h6>
                                        <input class="form-control mb-3" type="text" name="m_name" value="<%= rs.getString("m_name") %>" readonly/>
                                        <h6 class="modal-title">Mobile No</h6>
                                        <input class="form-control mb-3" type="text" name="mobile_no" value="<%= rs.getString("mobile_no") %>" readonly/>
                                        <h6 class="modal-title">Present Address</h6>
                                        <input class="form-control mb-3" type="text" name="present_address" value="<%= rs.getString("present_address") %>" readonly/>
                                        <h6 class="modal-title">Permanent Address</h6>
                                        <input class="form-control mb-3" type="text" name="permanent_address" value="<%= rs.getString("permanent_address") %>" readonly/>
                                    </form>
                                    <% 
                                            } else {
                                    %>
                                    <p class="text-danger">Student not found.</p>
                                    <% 
                                            }
                                        } catch (Exception e) {
                                            e.printStackTrace();
                                    %>
                                    <p class="text-danger">Error loading student details.</p>
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