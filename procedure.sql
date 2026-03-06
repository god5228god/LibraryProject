SELECT USER
FROM DUAL;

-- 소장 도서 생성 프로시저
-- BOOK_COPY테이블 ISBN, BOOK_STATUS_ID, BOOK_COUNT
CREATE OR REPLACE PROCEDURE PRC_BOOK_COPY_C
( P_ISBN    IN BOOK_INFO.ISBN%TYPE
, P_BOOK_STATUS_ID IN BOOK_STATUS.BOOK_STATUS_ID%TYPE
, P_BOOK_COUNT IN NUMBER DEFAULT 1
, O_RESULT  OUT NUMBER  -- 성공/실패 코드(1: 성공, 2: ISBN 없음, 3: 권수오류, 4: 아이디없음, 9: 기타)
, O_MSG  OUT VARCHAR -- 상세 메시지
)
IS
    V_ISBN NUMBER;
    
    USER_DEFINE_ERROR1  EXCEPTION;
    USER_DEFINE_ERROR2  EXCEPTION;
BEGIN

    -- ISBN 유효성 검사 (BOOK_INFO에 존재하는 ISBN인지 확인)
        SELECT COUNT(*) INTO V_ISBN
        FROM BOOK_INFO
        WHERE ISBN = P_ISBN;
        
        IF  V_ISBN = 0 THEN
            RAISE USER_DEFINE_ERROR1;
        END IF;
        
    -- COUNT 검사
        IF  P_BOOK_COUNT < 1 OR P_BOOK_COUNT > 99 THEN
            RAISE USER_DEFINE_ERROR2;
        END IF;
    
    -- 등록(새로등록/추가등록)
        FOR I IN 1..P_BOOK_COUNT LOOP
            INSERT INTO BOOK_COPY(BOOK_ID, ISBN, BOOK_STATUS_ID)
            VALUES(SEQ_BOOK_COPY.NEXTVAL, P_ISBN, P_BOOK_STATUS_ID);
        END LOOP;
        
    -- 성공 시 결과 담기
        O_RESULT := 1;
        O_MSG := '등록되었습니다.';
    
    -- 예외처리
    EXCEPTION
        WHEN USER_DEFINE_ERROR1 THEN
            O_RESULT := 2;
            O_MSG := '등록되지 않은 ISBN입니다.';
             --RAISE_APPLICATION_ERROR(-20001, '등록되지 않은 ISBN입니다.');
        WHEN USER_DEFINE_ERROR2 THEN
            -- RAISE_APPLICATION_ERROR(-20002, '책은 1 ~ 99권 사이로 입력해야합니다.');
    
END;
--==>> Procedure PRC_BOOK_COPY_C이(가) 컴파일되었습니다.


-- 대출 생성 프로시저
CREATE OR REPLACE PROCEDURE PRC_LOANS_C
( P_BOOK_ID IN  BOOK_COPY.BOOK_ID%TYPE
, P_USER_ID IN  USERS.USER_ID%TYPE
, P_EXT_COUNT IN NUMBER DEFAULT 0
, P_RESULT OUT NUMBER
)
IS
BEGIN
    -- 유저아이디 유효성 검사(존재, 상태)
    -- 북아이디 유효성검사(존재, 상태)
    
    -- INSERT(LOAN_ID-시퀀스, BOOK_ID, USER_ID, LOAN_DATE, DUE_DATE, RETURN_DATE(반납시), EXT_COUNT)
    -- 반납 예정일 연장 여부를 미리 받기 파라미터로 0이면 기본 반납예정일, 1이면 7일 더해주기
     -- 대출이 완료되면 BOOK_STATUS의 상태값이 트리거로 바뀌어야 함(LOANED)
    
    


END;

-- 대출 수정 프로시저
-- 도서 연장 프로시저
-- 도서 반납 프로시저



