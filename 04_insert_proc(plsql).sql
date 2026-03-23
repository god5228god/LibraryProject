
--------------------------------------------------------------------------------
-- 프로시저를 통한 샘플 데이터 삽입
--------------------------------------------------------------------------------

-- 샘플데이터 삽입
--☆ 단독저자
DECLARE
    V_RESULT2 VARCHAR2(1000);
    V_RESULT VARCHAR2(100);
    V_MSG    VARCHAR2(500);
BEGIN
    -- 도서 및 작가 등록
    PRC_BOOK_TOTAL_REG('9788937460586', '싯다르타',NULL
    , '민음사', '헤르만 헤세', '850', V_RESULT2);


    -- 소장 도서 생성 (1권, 상태 1)
    PRC_BOOK_COPY_C('9788937460586',1, 1, V_RESULT, V_MSG);
    
    DBMS_OUTPUT.PUT_LINE('결과: ' || V_RESULT2 || ' / 소장메시지: ' || V_MSG);

END;
/

SELECT *
FROM VIEW_BOOK_INFO;

SELECT *
FROM BOOK_COPY;

SELECT *
FROM BOOK_INFO;

DELETE
FROM PUBLISHERS;

DELETE
FROM AUTHORS;


DELETE
FROM CONTRIBUTOR;


-- 도서 대출

-- 도서 반납





