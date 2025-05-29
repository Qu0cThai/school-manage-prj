<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ include file="/WEB-INF/jspf/db-connection.jsp" %>
<%@ include file="header.jsp"%>
<body>
    <div class="container" style="min-height: 100vh; padding-bottom: 4rem;">
        <%
            String u_id = (String) session.getAttribute("u_id");
            Integer userRId = (Integer) session.getAttribute("userRId");
            if (u_id == null || userRId == null || userRId != 3) {
                response.sendRedirect("index.jsp");
                return;
            }

            Connection conn = null;
            PreparedStatement pstmt = null;
            ResultSet rs = null;
            String message = "";
            String s_name = "", roll_no = "", gender = "", dob = "", f_name = "", m_name = "", mobile_no = "", present_address = "", permanent_address = "";
            int age = 0;

            // Handle form submission
            if ("POST".equalsIgnoreCase(request.getMethod())) {
                try {
                    conn = getConnection();
                    s_name = request.getParameter("s_name");
                    roll_no = request.getParameter("roll_no");
                    gender = request.getParameter("gender");
                    dob = request.getParameter("dob");
                    age = Integer.parseInt(request.getParameter("age"));
                    f_name = request.getParameter("f_name");
                    m_name = request.getParameter("m_name");
                    mobile_no = request.getParameter("mobile_no");
                    present_address = request.getParameter("present_address");
                    permanent_address = request.getParameter("permanent_address");

                    // Check if student record exists
                    pstmt = conn.prepareStatement("SELECT 1 FROM students WHERE s_id = ?");
                    pstmt.setString(1, u_id);
                    rs = pstmt.executeQuery();
                    boolean exists = rs.next();
                    rs.close();
                    pstmt.close();

                    if (exists) {
                        // Update existing record
                        pstmt = conn.prepareStatement("UPDATE students SET s_name = ?, roll_no = ?, gender = ?, dob = ?, age = ?, f_name = ?, m_name = ?, mobile_no = ?, present_address = ?, permanent_address = ? WHERE s_id = ?");
                        pstmt.setString(1, s_name);
                        pstmt.setString(2, roll_no);
                        pstmt.setString(3, gender);
                        pstmt.setString(4, dob);
                        pstmt.setInt(5, age);
                        pstmt.setString(6, f_name.isEmpty() ? null : f_name);
                        pstmt.setString(7, m_name.isEmpty() ? null : m_name);
                        pstmt.setString(8, mobile_no.isEmpty() ? null : mobile_no);
                        pstmt.setString(9, present_address.isEmpty() ? null : present_address);
                        pstmt.setString(10, permanent_address.isEmpty() ? null : permanent_address);
                        pstmt.setString(11, u_id);
                    } else {
                        // Insert new record
                        pstmt = conn.prepareStatement("INSERT INTO students (s_id, s_name, roll_no, gender, dob, age, f_name, m_name, mobile_no, present_address, permanent_address) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)");
                        pstmt.setString(1, u_id);
                        pstmt.setString(2, s_name);
                        pstmt.setString(3, roll_no);
                        pstmt.setString(4, gender);
                        pstmt.setString(5, dob);
                        pstmt.setInt(6, age);
                        pstmt.setString(7, f_name.isEmpty() ? null : f_name);
                        pstmt.setString(8, m_name.isEmpty() ? null : m_name);
                        pstmt.setString(9, mobile_no.isEmpty() ? null : mobile_no);
                        pstmt.setString(10, present_address.isEmpty() ? null : present_address);
                        pstmt.setString(11, permanent_address.isEmpty() ? null : permanent_address);
                    }
                    pstmt.executeUpdate();

                    // Mark profile as complete
                    pstmt = conn.prepareStatement("UPDATE users SET is_profile_complete = TRUE WHERE u_id = ?");
                    pstmt.setString(1, u_id);
                    pstmt.executeUpdate();

                    message = "<div class='alert alert-success'>Profile updated successfully!</div>";
                    response.sendRedirect("index.jsp");
                } catch (Exception e) {
                    message = "<div class='alert alert-danger'>Error: " + e.getMessage() + "</div>";
                } finally {
                    closeResources(conn, pstmt, rs);
                }
            } else {
                // Load existing data
                try {
                    conn = getConnection();
                    pstmt = conn.prepareStatement("SELECT s_name, roll_no, gender, dob, age, f_name, m_name, mobile_no, present_address, permanent_address FROM students WHERE s_id = ?");
                    pstmt.setString(1, u_id);
                    rs = pstmt.executeQuery();
                    if (rs.next()) {
                        s_name = rs.getString("s_name") != null ? rs.getString("s_name") : "";
                        roll_no = rs.getString("roll_no") != null ? rs.getString("roll_no") : "";
                        gender = rs.getString("gender") != null ? rs.getString("gender") : "";
                        dob = rs.getString("dob") != null ? rs.getString("dob") : "";
                        age = rs.getInt("age");
                        f_name = rs.getString("f_name") != null ? rs.getString("f_name") : "";
                        m_name = rs.getString("m_name") != null ? rs.getString("m_name") : "";
                        mobile_no = rs.getString("mobile_no") != null ? rs.getString("mobile_no") : "";
                        present_address = rs.getString("present_address") != null ? rs.getString("present_address") : "";
                        permanent_address = rs.getString("permanent_address") != null ? rs.getString("permanent_address") : "";
                    }
                } catch (Exception e) {
                    message = "<div class='alert alert-danger'>Error loading profile: " + e.getMessage() + "</div>";
                } finally {
                    closeResources(conn, pstmt, rs);
                }
            }
        %>
        <%= message %>
        <div class="row">
            <div class="col-8 offset-md-2">
                <div class="card">
                    <div class="card-header">
                        <h3>Edit Your Profile</h3>
                    </div>
                    <div class="card-body">
                        <form method="POST" action="editStudent.jsp">
                            <div class="form-group">
                                <label for="s_name">Name</label>
                                <input type="text" class="form-control" name="s_name" value="<%= s_name %>" required>
                            </div>
                            <div class="form-group">
                                <label for="roll_no">Roll No</label>
                                <input type="text" class="form-control" name="roll_no" value="<%= roll_no %>" required>
                            </div>
                            <div class="form-group">
                                <label for="gender">Gender</label>
                                <select class="form-control" name="gender" required>
                                    <option value="Male" <%= "Male".equals(gender) ? "selected" : "" %>>Male</option>
                                    <option value="Female" <%= "Female".equals(gender) ? "selected" : "" %>>Female</option>
                                    <option value="Other" <%= "Other".equals(gender) ? "selected" : "" %>>Other</option>
                                </select>
                            </div>
                            <div class="form-group">
                                <label for="dob">Date of Birth</label>
                                <input type="date" class="form-control" name="dob" value="<%= dob %>" required>
                            </div>
                            <div class="form-group">
                                <label for="age">Age</label>
                                <input type="number" class="form-control" name="age" value="<%= age %>" required>
                            </div>
                            <div class="form-group">
                                <label for="f_name">Father's Name</label>
                                <input type="text" class="form-control" name="f_name" value="<%= f_name %>">
                            </div>
                            <div class="form-group">
                                <label for="m_name">Mother's Name</label>
                                <input type="text" class="form-control" name="m_name" value="<%= m_name %>">
                            </div>
                            <div class="form-group">
                                <label for="mobile_no">Mobile No</label>
                                <input type="text" class="form-control" name="mobile_no" value="<%= mobile_no %>">
                            </div>
                            <div class="form-group">
                                <label for="present_address">Present Address</label>
                                <textarea class="form-control" name="present_address" rows="3"><%= present_address %></textarea>
                            </div>
                            <div class="form-group">
                                <label for="permanent_address">Permanent Address</label>
                                <textarea class="form-control" name="permanent_address" rows="3"><%= permanent_address %></textarea>
                            </div>
                            <button type="submit" class="btn btn-primary btn-block">Save Profile</button>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </div>
</body>
<%@ include file="footer.jsp"%>