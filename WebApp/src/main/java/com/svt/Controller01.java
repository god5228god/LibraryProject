package com.svt;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

public class Controller01 extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        process(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        process(request, response);
    }

    // 사용자 정의 메소드 - 서블릿 관련 코드 구성(업무 구성) -> 뷰에 제어권 넘기기
    protected void process(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

        // 업무 구성

        // 제어권 넘기기
        /*RequestDispatcher dispatcher = request.getRequestDispatcher("보낼 뷰 주소");
        dispatcher.forward(request, response);*/
    }

}
