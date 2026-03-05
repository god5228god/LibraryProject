SELECT USER
FROM DUAL;

-- 소장 도서 생성 프로시저
-- BOOK_COPY테이블 ISBN, BOOK_STATUS_ID, BOOK_COUNT
CREATE OR REPLACE PROCEDURE PRC_BOOK_COPY_C
( P_ISBN    IN BOOK_INFO.ISBN%TYPE
, P_BOOK_STATUS_ID IN BOOK_STATUS.BOOK_STATUS_ID%TYPE
, P_BOOK_COUNT  NUMBER DEFAULT 1
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
            INSERT INTO BOOK_COPY(BOOK_ID, ISBN, BOOK_STATUS_ID, CREATED_AT)
            VALUES();
        END LOOP;
    
    -- 예외처리
    EXCEPTION
        WHEN USER_DEFINE_ERROR1 THEN
             RAISE_APPLICATION_ERROR(-20001, '등록되지 않은 ISBN입니다.');
        WHEN USER_DEFINE_ERROR1 THEN
             RAISE_APPLICATION_ERROR(-20002, '책은 1 ~ 99권 사이로 입력해야합니다.');
    
END;



-- 대출 생성 프로시저
-- 대출 수정 프로시저
-- 도서 연장 프로시저
-- 도서 반납 프로시저



