
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
    PRC_BOOK_TOTAL_REG('9788934977841', '호모 데우스','미래의 역사'
    , '김영사', '유발 하라리', '900', V_RESULT2);


    -- 소장 도서 생성 (1권, 상태 1)
    PRC_BOOK_COPY_C('9788934977841',1, 1, V_RESULT, V_MSG);
    
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
    PRC_BOOK_TOTAL_REG('9791190030922', '소크라테스 익스프레스',NULL
    , '어크로스', '에릭 와이너', '160', V_RESULT2);


    -- 소장 도서 생성 (1권, 상태 1)
    PRC_BOOK_COPY_C('9791190030922',1, 1, V_RESULT, V_MSG);
    
    DBMS_OUTPUT.PUT_LINE('결과: ' || V_RESULT2 || ' / 소장메시지: ' || V_MSG);

END;
/

-- 공동 저자 
DECLARE
    V_RESULT2 VARCHAR2(1000);
    V_RESULT VARCHAR2(100);
    V_MSG    VARCHAR2(500);
BEGIN
    -- 도서 및 작가 등록
    PRC_BOOK_TOTAL_REG('9788936452452', '바다에 미래가 있다','10대를 위한 해양과학 이야기'
    , '창비', '정찬주', '450', V_RESULT2);

END;
/

SELECT *
FROM VIEW_BOOK_INFO
ORDER BY BOOK_ID DESC;

select *
from book_info
where isbn ='9788934977841';

update book_info
set cat_id = '330'
where isbn ='9788934977841';

SELECT *
FROM BOOK_COPY;

DELETE
FROM BOOK_COPY
WHERE BOOK_ID=8;

SELECT *
FROM BOOK_INFO;

SELECT *
FROM PUBLISHERS;

SELECT *
FROM AUTHORS;


SELECT *
FROM CONTRIBUTOR;

DELETE
FROM CONTRIBUTOR
WHERE CONTRIBUTOR_ID=6;


-- 도서 대출

-- 도서 반납

commit;




