<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ include file="header.jsp"%>
<%@ include file="/WEB-INF/jspf/db-connection.jsp"%>
<%@ page import="java.sql.*" %>
<body>
    <div class="container">
        <!--body-->
        <div class="row">
            <div class="col-12 col-sm-12 col-md-12">
                <div class="container">
                    <br/>
                    <h1>All Notice :</h1><hr/>
                    <%
                        Connection conn = null;
                        Statement stmt = null;
                        ResultSet rs = null;
                        try {
                            // Use the connection method from db-connection.jsp
                            conn = getConnection();
                            
                            // Create SQL query
                            stmt = conn.createStatement();
                            String sql = "SELECT n_title, n_description, publish_date FROM notices ORDER BY publish_date DESC";
                            rs = stmt.executeQuery(sql);
                            
                            // Iterate through the result set
                            while (rs.next()) {
                                String title = rs.getString("n_title");
                                String description = rs.getString("n_description");
                                String publishDate = rs.getString("publish_date");
                    %>
                    <a class="list-group-item list-group-item-action">
                        <div>
                            <h4>⇛ <%= title %></h4>
                            Description: <%= description != null ? description : "No description available" %><br/>
                            <small>Publish Date: <%= publishDate %></small>
                        </div>
                    </a>
                    <%
                            }
                        } catch (Exception e) {
                            out.println("Error: " + e.getMessage());
                        } finally {
                            // Use the closeResources method from db-connection.jsp
                            closeResources(conn, stmt, rs);
                        }
                    %>
                </div>
                <br/>
            </div>
        </div>
    </div>
</body>
<%@ include file="footer.jsp"%>