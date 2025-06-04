<%@ page import="java.sql.*" %>
<%!
    private static final String JDBC_URL ="jdbc:mysql://localhost:3306/schoolmanagedb";
    private static final String JDBC_USER ="root";
    private static final String JDBC_PASSWORD ="12345";
    
    public static Connection getConnection()throws SQLException,
 ClassNotFoundException {
        Class.forName("com.mysql.cj.jdbc.Driver");
        return DriverManager.getConnection(JDBC_URL,JDBC_USER,
 JDBC_PASSWORD);
    }
    
    public static void closeResources(Connection conn,Statement stmt, ResultSet rs){
        try{
            if(rs != null)rs.close();
        }catch (SQLException e){
            e.printStackTrace();
        }
        
        try{
            if(stmt !=null)stmt.close();
        }catch (SQLException e){
            e.printStackTrace();
        }
        
        try{
            if(conn !=null)conn.close();
        }catch (SQLException e){
            e.printStackTrace();
        }
    }
 %>