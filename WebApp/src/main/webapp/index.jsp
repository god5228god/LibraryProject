<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="com.util.DBConn" %>
<%
UserDAO

%>
<html>
<body>
    <h2>도서관 프로젝트 DB 접속 테스트</h2>
    <%
        try {
            Connection conn = DBConn.getConnection();
            if(conn != null) {
                out.println("<h3 style='color:blue'>연결 성공!</h3>");
                conn.close(); // 사용 후 바로 닫기
            }
        } catch(Exception e) {
            out.println("<h3 style='color:red'>실패 사유: " + e.getMessage() + "</h3>");
        }
    %>
</body>
</html>