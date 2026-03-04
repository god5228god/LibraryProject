SELECT USER
FROM DUAL;

-- 로그인 프로시저
CREATE PROCEDURE PRC_LOGIN
( P_LOGIN_ID IN USER.LOGIN_ID%TYPE
, P_PW  IN USER.PW%TYPE
, P_LOGIN_NAME OUT USER.NAME%TYPE
, P_STATUS_ID OUT USER.STATUS_ID%TYPE
, P_ROLE_ID OUT USER.ROLE_ID%TYPE
, P_PENALTY_EDATE OUT USER.PENALTY_EDATE%TYPE
, P_RESULT OUT VARCHAR2
)
IS
BEGIN
    -- 아이디 존재 여부 확인
    
    -- 아이디가 존재하지 않는 경우
    
    -- 비밀번호 일치 확인
    
    -- 비밀번호가 틀린 경우
    
    -- 로그인 성공
    
END;

-- 대출 생성 프로시저

-- 대출 수정 프로시저

-- 도서 연장 프로시저

-- 반납 프로시저

-- 도서 권수 추가 프로시저(동일 책이 몇 권 있는지)

-- 도서 상태 변경 트리거

-- 연체 상태 자동 전환 트리거

-- 이벤트 권수 함수

-- 대출된 권수 함수

-- 연체중인 도서 여부 함수

-- 연체일 계산 함수

