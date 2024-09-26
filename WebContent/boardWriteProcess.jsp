<%@ page import="java.io.*, java.sql.*, javax.servlet.http.*, javax.servlet.annotation.MultipartConfig" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%
    request.setCharacterEncoding("UTF-8"); // 인코딩 설정

    // 폼 데이터 가져오기
    String title = request.getParameter("title");
    String content = request.getParameter("content");
    String author = request.getParameter("author");

    if (title == null || title.trim().isEmpty()) {
        title = "Untitled";
    }
    if (content == null) {
        content = "";
    }
    if (author == null) {
        author = "Anonymous";
    }

    // 파일 업로드 처리
    Part filePart = request.getPart("uploadFile");
    String fileName = "";
    long fileSize = 0;
    InputStream fileContent = null;

    if (filePart != null && filePart.getSize() > 0) {
        fileName = filePart.getSubmittedFileName();
        fileSize = filePart.getSize();
        fileContent = filePart.getInputStream();

        // 서버의 지정된 디렉토리에 파일 저장
        String uploadDir = getServletContext().getRealPath("/uploads");
        File uploadDirFile = new File(uploadDir);
        if (!uploadDirFile.exists()) {
            uploadDirFile.mkdirs();
        }

        File file = new File(uploadDir + File.separator + fileName);
        try (FileOutputStream fos = new FileOutputStream(file)) {
            byte[] buffer = new byte[1024];
            int bytesRead;
            while ((bytesRead = fileContent.read(buffer)) != -1) {
                fos.write(buffer, 0, bytesRead);
            }
        }
    }

    // 데이터베이스에 저장
    try (Connection conn = DriverManager.getConnection("jdbc:mysql://10.0.2.37:3306/shopping-cart?useUnicode=true&characterEncoding=utf8", "dbuser", "1234")) {
        String sql = "INSERT INTO board (title, author, content, file_name, file_size, file_content) VALUES (?, ?, ?, ?, ?, ?)";
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, title);
            pstmt.setString(2, author);
            pstmt.setString(3, content);
            pstmt.setString(4, fileName);
            pstmt.setLong(5, fileSize);
            if (fileContent != null) {
                pstmt.setBlob(6, fileContent);
            } else {
                pstmt.setNull(6, java.sql.Types.BLOB);
            }
            pstmt.executeUpdate();
        }
    } catch (Exception e) {
        e.printStackTrace();
        out.println("게시글 저장 중 오류가 발생했습니다.");
    }

    response.sendRedirect("boardList.jsp");
%>
