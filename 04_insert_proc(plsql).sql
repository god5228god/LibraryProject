
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
    PRC_BOOK_TOTAL_REG('9791197437311', '백년 허리','내 허리 사용 설명서. 2, 치료편'
    , '언탱글링', '정선근', '510', V_RESULT2);


    -- 소장 도서 생성 (1권, 상태 1)
    PRC_BOOK_COPY_C('9791197437311',1, 1, V_RESULT, V_MSG);
    
    DBMS_OUTPUT.PUT_LINE('결과: ' || V_RESULT2 || ' / 소장메시지: ' || V_MSG);

END;
/

SET DEFINE OFF;

-- 부제없는 버전
DECLARE
    V_RESULT2 VARCHAR2(1000);
    V_RESULT VARCHAR2(100);
    V_MSG    VARCHAR2(500);
BEGIN
    -- 도서 및 작가 등록
    PRC_BOOK_TOTAL_REG('9788983710451', '파인만 씨, 농담도 잘하시네! 2',NULL
    , '사이언스북스', '리처드 파인만', '420', V_RESULT2);


    -- 소장 도서 생성 (1권, 상태 1)
    PRC_BOOK_COPY_C('9788983710451',1, 1, V_RESULT, V_MSG);
    
    DBMS_OUTPUT.PUT_LINE('결과: ' || V_RESULT2 || ' / 소장메시지: ' || V_MSG);

END;
/


SELECT *
FROM VIEW_BOOK_INFO
ORDER BY BOOK_ID DESC;

select *
from book_info;


SELECT *
FROM BOOK_COPY;


SELECT *
FROM BOOK_INFO;

SELECT *
FROM PUBLISHERS;

SELECT *
FROM AUTHORS;


SELECT *
FROM CONTRIBUTOR;


-- 도서 대출

-- 도서 반납

commit;




