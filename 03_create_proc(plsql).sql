SELECT USER
FROM DUAL;


--● 소장 도서 생성 프로시저
-- BOOK_COPY테이블 ISBN, BOOK_STATUS_ID, BOOK_COUNT
CREATE OR REPLACE PROCEDURE PRC_BOOK_COPY_C
( P_ISBN    IN BOOK_INFO.ISBN%TYPE
, P_BOOK_STATUS_ID IN BOOK_STATUS.BOOK_STATUS_ID%TYPE
, P_BOOK_COUNT IN NUMBER DEFAULT 1
, O_RESULT  OUT VARCHAR2  -- 성공/실패 
, O_MSG  OUT VARCHAR2 -- 상세 메시지
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
        
    -- BOOK_STATUS_ID가 NULL인지 유효성 검사
    
        
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
        O_RESULT := 'SUCCESS';
        O_MSG := '등록되었습니다.';
    
    -- 예외처리
    EXCEPTION
        WHEN USER_DEFINE_ERROR1 THEN
            O_RESULT := 'INVALID_ISBN';
            O_MSG := '등록되지 않은 ISBN입니다.';
             --RAISE_APPLICATION_ERROR(-20001, '등록되지 않은 ISBN입니다.');
        WHEN USER_DEFINE_ERROR2 THEN
            O_RESULT := 'LIMIT_EXCEEDED';
            O_MSG := '도서 권 수는 1 ~ 99권 사이로 입력해야합니다.';
            -- RAISE_APPLICATION_ERROR(-20002, '책은 1 ~ 99권 사이로 입력해야합니다.');
        WHEN OTHERS THEN
            O_RESULT := 'SYSTEM_ERROR';
            O_MSG := '시스템 오류: ' || SQLERRM;
    
END;
/
--==>> Procedure PRC_BOOK_COPY_C이(가) 컴파일되었습니다.

--● 도서 상태 변경 트리거
CREATE OR REPLACE TRIGGER TRG_BOOK_STATUS
    AFTER
    INSERT OR UPDATE ON LOANS 
    FOR EACH ROW
BEGIN
    IF(INSERTING) THEN
        UPDATE BOOK_COPY
        SET BOOK_STATUS_ID = 2
        WHERE BOOK_ID = :NEW.BOOK_ID;
    END IF;
    
    IF(UPDATING) THEN
        IF(:OLD.RETURN_DATE IS NULL AND :NEW.RETURN_DATE IS NOT NULL) THEN
            UPDATE BOOK_COPY
            SET BOOK_STATUS_ID = 1
            WHERE BOOK_ID = :NEW.BOOK_ID;
        END IF;
        
    END IF;
END;
/
--==>> Trigger TRG_BOOK_STATUS이(가) 컴파일되었습니다.


--● 대출 생성 프로시저
CREATE OR REPLACE PROCEDURE PRC_LOANS_C
( P_BOOK_ID IN  BOOK_COPY.BOOK_ID%TYPE
, P_USER_ID IN  USERS.USER_ID%TYPE
, P_EXT_COUNT IN NUMBER DEFAULT 0
, O_RESULT  OUT VARCHAR2
, O_MSG OUT VARCHAR2
)
IS
    V_USER_ID_EXIST   NUMBER(1);
    V_STATUSID  USERS.STATUS_ID%TYPE;
    V_LOANEDBOOKS   NUMBER(2);
    V_MAX_LIMIT     NUMBER;
    V_LOAN_COUNT    NUMBER(2);
    V_BOOK_ID_EXIST NUMBER(1);
    V_BOOK_STATUS   BOOK_COPY.BOOK_STATUS_ID%TYPE;
    V_PENALTY_EDATE DATE;
    V_DUE_DATE  DATE;
    
    USER_DEFINE_ERROR1  EXCEPTION;
    USER_DEFINE_ERROR2  EXCEPTION;
    USER_DEFINE_ERROR3  EXCEPTION;
    USER_DEFINE_ERROR4  EXCEPTION;
    USER_DEFINE_ERROR5  EXCEPTION;
    USER_DEFINE_ERROR6  EXCEPTION;
    USER_DEFINE_ERROR7  EXCEPTION;
BEGIN
    -- 유저아이디 검사 
    -- 대출 자격 검사(유저상태(계정상태, 연체여부), 대출권수)
        BEGIN
            SELECT STATUS_ID, PENALTY_EDATE INTO V_STATUSID, V_PENALTY_EDATE
            FROM USERS
            WHERE USER_ID = P_USER_ID;
            
        EXCEPTION 
            WHEN NO_DATA_FOUND THEN
                RAISE USER_DEFINE_ERROR1;
        END;
    -- 유저 존재, 상태값에 따른 분기
       IF(V_STATUSID = 2) THEN
            RAISE USER_DEFINE_ERROR2;
       END IF;
                   
       IF(V_STATUSID = 3) THEN
            RAISE USER_DEFINE_ERROR3;
       END IF;
       
       -- 지금이 이벤트기간인지 아닌지 확인 후에 최대 대출 권수 확인
       BEGIN 
           SELECT MAX_LOAN_LIMIT INTO V_MAX_LIMIT
           FROM LOAN_EVENTS
           WHERE SYSDATE BETWEEN START_DATE AND END_DATE;
           
           EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    V_MAX_LIMIT := 10;
       END;
       
       -- 사용자의 대출 권수 확인
       SELECT COUNT(*) INTO V_LOAN_COUNT
       FROM LOANS
       WHERE USER_ID = P_USER_ID AND RETURN_DATE IS NULL;
       
       IF(V_LOAN_COUNT>=V_MAX_LIMIT) THEN
            RAISE USER_DEFINE_ERROR4;
       END IF;

        -- 북아이디 유효성검사(존재, 상태)
        BEGIN
            SELECT BOOK_STATUS_ID INTO V_BOOK_STATUS
            FROM BOOK_COPY
            WHERE BOOK_ID = P_BOOK_ID;
            
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                RAISE USER_DEFINE_ERROR5;
        END;

        
        -- 2.대출중 날짜 조회
        IF(V_BOOK_STATUS = 2) THEN
            SELECT DUE_DATE INTO V_DUE_DATE
            FROM LOANS
            WHERE BOOK_ID = P_BOOK_ID AND RETURN_DATE IS NULL;
            RAISE USER_DEFINE_ERROR6;
        END IF;
        
        IF(V_BOOK_STATUS = 3) THEN
            RAISE USER_DEFINE_ERROR7;
        END IF;
    
    -- INSERT(LOAN_ID-시퀀스, BOOK_ID, USER_ID, LOAN_DATE, DUE_DATE, RETURN_DATE(반납시), EXT_COUNT)
    -- 반납 예정일 연장 여부를 미리 받기 파라미터로 0이면 기본 반납예정일, 1이면 7일 더해주기
     -- 대출이 완료되면 BOOK_STATUS의 상태값이 트리거로 바뀌어야 함(LOANED)
     
    -- 연장 신청시 21일 늘려주고 연장 신청 안하면 기본 14일 세팅
        IF(P_EXT_COUNT = 1) THEN
            V_DUE_DATE := SYSDATE+21;
        ELSIF(P_EXT_COUNT= 0) THEN
            V_DUE_DATE := SYSDATE+14;
        END IF;
        
     
        INSERT INTO LOANS(LOAN_ID, BOOK_ID, USER_ID, LOAN_DATE, DUE_DATE, EXT_COUNT)
        VALUES(SEQ_LOAN.NEXTVAL, P_BOOK_ID, P_USER_ID, SYSDATE
        , V_DUE_DATE, P_EXT_COUNT);
        
        O_RESULT := 'SUCCESS';
        O_MSG := '대출이 완료되었습니다. 반납 예정일은 '|| TO_CHAR(V_DUE_DATE, 'YYYY-MM-DD')||'입니다.';
                


    EXCEPTION 
        WHEN USER_DEFINE_ERROR1 THEN
            O_RESULT := 'ID_NOT_EXIST';
            O_MSG := '존재하지 않는 아이디입니다.';
        WHEN USER_DEFINE_ERROR2 THEN
            O_RESULT := 'INACTIVE_USER';
            O_MSG := '비활성 계정입니다.';
        WHEN USER_DEFINE_ERROR3 THEN
            O_RESULT := 'PENALTY_USER';
            O_MSG := '연체로 인해 현재 대출 정지 상태입니다. 패널티 기간은' || TO_CHAR(V_PENALTY_EDATE,'YYYY-MM-DD') ||'까지 입니다.';
        WHEN USER_DEFINE_ERROR4 THEN
            O_RESULT := 'LIMIT_EXCEEDED';
            O_MSG := '현재 대출 가능한 권수를 초과했습니다.';
        WHEN USER_DEFINE_ERROR5 THEN
            O_RESULT := 'BOOK_NOT_EXIST';
            O_MSG := '유효하지 않은 도서입니다.';
        WHEN USER_DEFINE_ERROR6 THEN
            O_RESULT := 'LOANED_BOOK';
            O_MSG := '대출 중인 도서입니다. 예상 반납일은'|| TO_CHAR(V_DUE_DATE,'YYYY-MM-DD')||'입니다.';
        WHEN USER_DEFINE_ERROR7 THEN
            O_RESULT := 'INACTIVE_BOOK';
            O_MSG := '대출 불가능한 도서입니다.';
            
END;
/
--==>> Procedure PRC_LOANS_C이(가) 컴파일되었습니다.

--● 도서 연장 프로시저
CREATE OR REPLACE PROCEDURE PRC_EXT
( P_BOOK_ID IN BOOK_COPY.BOOK_ID%TYPE
, P_USER_ID IN USERS.USER_ID%TYPE
, P_EXT_COUNT IN LOANS.EXT_COUNT%TYPE
, O_RESULT  OUT VARCHAR2
, O_MSG OUT VARCHAR2
)
IS
    V_VALID_LOAN    NUMBER(1);
    V_EXT_COUNT     NUMBER(1);
    V_STATUS_ID     USER_STATUS.STATUS_ID%TYPE;
    
    USER_DEFINE_ERROR1   EXCEPTION;
    USER_DEFINE_ERROR2   EXCEPTION;
    USER_DEFINE_ERROR3   EXCEPTION;
    
BEGIN
    -- 유저 아이디 검증-- 이 유저가 이 도서를 대출한 것이 맞는지 확인
    -- + 아직 반납을 안한 것이 맞는지 확인
    -- + 연장 횟수가 남았는지 확인
    SELECT COUNT(*), NVL(MAX(EXT_COUNT), -1) INTO V_VALID_LOAN, V_EXT_COUNT
    FROM LOANS
    WHERE USER_ID = P_USER_ID 
        AND BOOK_ID = P_BOOK_ID 
        AND RETURN_DATE IS NULL;
    
    IF(V_VALID_LOAN<1) THEN
        RAISE USER_DEFINE_ERROR1;
    END IF;
    IF(V_EXT_COUNT>0) THEN
        RAISE USER_DEFINE_ERROR2;
    END IF;

    -- 연체 여부 확인
    SELECT STATUS_ID INTO V_STATUS_ID
    FROM USERS
    WHERE USER_ID = P_USER_ID;
    
    IF(V_STATUS_ID = 3) THEN
        RAISE USER_DEFINE_ERROR3;
    END IF;
    
    -- 연장(LOANS UPDATE)
    UPDATE LOANS
    SET EXT_COUNT = 1, DUE_DATE = DUE_DATE+7
    WHERE USER_ID = P_USER_ID 
        AND BOOK_ID = P_BOOK_ID
        AND RETURN_DATE IS NULL;
    
    O_RESULT := 'SUCCESS';
    O_MSG := '연장 완료되었습니다';
    
    EXCEPTION
        WHEN USER_DEFINE_ERROR1 THEN
            O_RESULT:= 'NOT_LOANED';
            O_MSG := '대출된 기록이 없습니다.';
         WHEN USER_DEFINE_ERROR2 THEN
            O_RESULT:= 'ALREADY_EXTENDED';
            O_MSG := '이미 연장된 도서입니다.';
        WHEN USER_DEFINE_ERROR3 THEN
            O_RESULT:= 'OVERDUE';
            O_MSG := '연체중인 도서는 연장이 불가합니다.';
END;
/
--==>> Procedure PRC_EXT이(가) 컴파일되었습니다.


--● 도서 반납 프로시저
CREATE OR REPLACE PROCEDURE PRC_RETURN
( P_BOOK_ID IN BOOK_COPY.BOOK_ID%TYPE
, O_RESULT  OUT VARCHAR2
, O_MSG OUT VARCHAR2
)
IS
    V_BOOK_STATUS_ID    BOOK_STATUS.BOOK_STATUS_ID%TYPE;
    V_DUE_DATE  DATE;
    V_USER_ID   USERS.USER_ID%TYPE;
    V_OVERDUE_DAYS  NUMBER;
    
    USER_DEFINE_ERROR1  EXCEPTION;
BEGIN

    -- 도서의 상태가 대출중인지 확인
        SELECT BOOK_STATUS_ID INTO V_BOOK_STATUS_ID
        FROM BOOK_COPY
        WHERE BOOK_ID = P_BOOK_ID;
        
        IF(V_BOOK_STATUS_ID != 2) THEN
            RAISE USER_DEFINE_ERROR1;
        END IF;
        
    -- 연체 여부 확인
        SELECT DUE_DATE, USER_ID INTO V_DUE_DATE, V_USER_ID
        FROM LOANS
        WHERE BOOK_ID = P_BOOK_ID
            AND RETURN_DATE IS NULL;

    -- 연체 일수 계산
        V_OVERDUE_DAYS := TRUNC(SYSDATE) - TRUNC(V_DUE_DATE);
        
    -- 반납
        UPDATE LOANS
        SET RETURN_DATE = SYSDATE
        WHERE BOOK_ID = P_BOOK_ID
            AND RETURN_DATE IS NULL;
            
        
    -- 연체 시 유저 STATUS 상태 변경
        IF(V_OVERDUE_DAYS > 0) THEN
            UPDATE USERS
            SET STATUS_ID = 2
            , PENALTY_EDATE = TRUNC(SYSDATE) + V_OVERDUE_DAYS
            WHERE USER_ID = V_USER_ID;
        END IF;
        
    
        
        O_RESULT := 'SUCCESS';
        
        IF(V_OVERDUE_DAYS >0 ) THEN
            O_MSG := '반납이 완료되었습니다.'|| V_OVERDUE_DAYS||'일 연체로 인해' 
            ||TO_CHAR(SYSDATE + V_OVERDUE_DAYS,'YYYY-MM-DD')||'까지 대출이 제한됩니다.';
        ELSE
            O_MSG := '반납이 완료되었습니다.';
        END IF;
        
        
    
    EXCEPTION
        WHEN USER_DEFINE_ERROR1 THEN
            O_RESULT := 'NOT_LOANED';
            O_MSG := '대출된 도서가 아니므로 반납이 불가합니다.';

END;
/
--==>> Procedure PRC_RETURN이(가) 컴파일되었습니다.



--● 연체자 자동 업데이트 스케줄러
-- 아직 반납을 안했지만 반납예정일이 지난 대출 건의 유저 상태를 연체상태로 변경
-- 익명 블록(일회성 코드) 
-- 오라클 서버 내부의 Job Queue에 이 스케줄이 등록
-- 자바 프로그램을 종료하거나, 컴퓨터를 끄더라도 DB서버가 켜져있다면 시간마다 오라클이 스스로 실행됨
DECLARE
BEGIN
    DBMS_SCHEDULER.CREATE_JOB(
          job_name    => 'JOB_UPDATE_OVERDUE_USERS'    
        , job_type    => 'STORED_PROCEDURE'              
        , job_action    => 'PRC_OVERDUE'
        , start_date    =>  SYSDATE             
        , repeat_interval   => 'FREQ=DAILY; BYHOUR=0; BYMINUTE=0'
        , enabled       => TRUE
        , comments      => '매일 자정에 연체자 상태를 정지로 변경함'
    
    );
END;
/
SELECT *
FROM USER_SCHEDULER_JOB_LOG;
--==>>
/*
642	26/03/23 09:00:54.960000000 +09:00	HWON	JOB_UPDATE_OVERDUE_USERS		DEFAULT_JOB_CLASS	RUN	SUCCEEDED						
*/

--● 연체자 처리 프로시저(스케줄러에서 호출)
CREATE OR REPLACE PROCEDURE PRC_OVERDUE
IS
BEGIN

    -- 연체된 아이디 찾아서 유저상태를 연체로 업데이트
    UPDATE USERS
    SET STATUS_ID = 3
    WHERE STATUS_ID = 1 
    AND USER_ID IN (
    SELECT DISTINCT USER_ID
    FROM LOANS
    WHERE RETURN_DATE IS NULL
        AND DUE_DATE < TRUNC(SYSDATE)
    );
    
    -- 연체기간이 끝났으면 다시 유저상태를 활성상태로 업데이트
    UPDATE USERS
    SET STATUS_ID = 1, PENALTY_EDATE = NULL
    WHERE STATUS_ID = 3
        AND( PENALTY_EDATE IS NOT NULL AND PENALTY_EDATE < TRUNC(SYSDATE))
        AND USER_ID NOT IN (
            SELECT DISTINCT USER_ID
            FROM LOANS
            WHERE RETURN_DATE IS NULL
                AND DUE_DATE < TRUNC(SYSDATE)
        );
    
    -- 커밋
    COMMIT;
    
END;
/
--==>> Procedure PRC_OVERDUE이(가) 컴파일되었습니다.

--● 대출 가능 확인 함수
CREATE OR REPLACE FUNCTION FN_AVAILED_LOAN
(P_USER_ID  IN  USERS.USER_ID%TYPE)
RETURN NUMBER
IS
    V_STATUS_ID USER_STATUS.STATUS_ID%TYPE;
    V_RESULT NUMBER(1);
BEGIN
-- 유저가 대출이 가능한 상태인지 확인하는 함수 정의
-- 대출 가능(1), 대출불가능(0)
    SELECT STATUS_ID INTO V_STATUS_ID
    FROM USERS
    WHERE USER_ID = P_USER_ID;
    
    IF(V_STATUS_ID = 1) THEN
        V_RESULT := 1;
    ELSE
        V_RESULT := 0;
    END IF;
    
    RETURN V_RESULT;
END;
/

--==>> Function FN_AVAILED_LOAN이(가) 컴파일되었습니다.

--------------------------------------------------------------------------------


-- ○ 통합 샘플 데이터 생성 프로시저
CREATE OR REPLACE PROCEDURE PRC_BOOK_TOTAL_REG
(
  P_ISBN        IN BOOK_INFO.ISBN%TYPE,
  P_TITLE       IN BOOK_INFO.TITLE%TYPE,
  P_SUBTITLE    IN BOOK_INFO.SUBTITLE%TYPE,
  P_PUB_NAME    IN PUBLISHERS.PUB_NAME%TYPE,
  P_AUTHOR_NAME IN AUTHORS.AUTHOR_NAME%TYPE,
  P_CAT_ID      IN BOOK_INFO.CAT_ID%TYPE,
  O_RESULT      OUT VARCHAR2
)
IS
  V_PUB_ID    NUMBER;
  V_AUTHOR_ID NUMBER;
  V_COUNT     NUMBER;
BEGIN
  -- 1. 출판사 및 작가 등록 (기존과 동일)
  BEGIN
    SELECT PUB_ID INTO V_PUB_ID FROM PUBLISHERS WHERE PUB_NAME = P_PUB_NAME;
  EXCEPTION WHEN NO_DATA_FOUND THEN
    INSERT INTO PUBLISHERS (PUB_ID, PUB_NAME) VALUES (SEQ_PUBLISHER.NEXTVAL, P_PUB_NAME) RETURNING PUB_ID INTO V_PUB_ID;
  END;

  BEGIN
    SELECT AUTHOR_ID INTO V_AUTHOR_ID FROM AUTHORS WHERE AUTHOR_NAME = P_AUTHOR_NAME;
  EXCEPTION WHEN NO_DATA_FOUND THEN
    INSERT INTO AUTHORS (AUTHOR_ID, AUTHOR_NAME) VALUES (SEQ_AUTHOR.NEXTVAL, P_AUTHOR_NAME) RETURNING AUTHOR_ID INTO V_AUTHOR_ID;
  END;

  -- 2. 도서 기본 정보 등록
  SELECT COUNT(*) INTO V_COUNT FROM BOOK_INFO WHERE ISBN = P_ISBN;
  IF V_COUNT = 0 THEN
    INSERT INTO BOOK_INFO (ISBN, TITLE, SUBTITLE, PUB_ID, CAT_ID) VALUES (P_ISBN, P_TITLE, P_SUBTITLE, V_PUB_ID, P_CAT_ID);
  END IF;

  -- 3. 저자 매핑 (CONTRIBUTOR) 로직
  SELECT COUNT(*) INTO V_COUNT FROM CONTRIBUTOR WHERE ISBN = P_ISBN;

  IF V_COUNT = 0 THEN
    -- [첫 번째 저자] 일단 NULL로 입력
    INSERT INTO CONTRIBUTOR (CONTRIBUTOR_ID, ISBN, AUTHOR_ID, AUTHOR_ORDER)
    VALUES (SEQ_CONTRIBUTOR.NEXTVAL, P_ISBN, V_AUTHOR_ID, NULL);
  ELSE
    -- [두 번째 이상 저자] 
    -- 1) 기존에 NULL이었던 첫 번째 저자를 1로 업데이트 (처음 한 번만 실행됨)
    UPDATE CONTRIBUTOR SET AUTHOR_ORDER = 1 WHERE ISBN = P_ISBN AND AUTHOR_ORDER IS NULL;
    
    -- 2) 현재 저자를 순서에 맞게 입력 (현재 수 + 1)
    INSERT INTO CONTRIBUTOR (CONTRIBUTOR_ID, ISBN, AUTHOR_ID, AUTHOR_ORDER)
    VALUES (SEQ_CONTRIBUTOR.NEXTVAL, P_ISBN, V_AUTHOR_ID, V_COUNT + 1);
  END IF;

  O_RESULT := 'SUCCESS';
EXCEPTION
  WHEN OTHERS THEN
    O_RESULT := 'ERROR: ' || SQLERRM;
END;
/
--==>> Procedure PRC_BOOK_TOTAL_REG이(가) 컴파일되었습니다.

--------------------------------------------------------------------------------
-- ※ 뷰 VIEW
--------------------------------------------------------------------------------
-- ○ 도서 정보 뷰(도서명, isbn, 작가, 출판사, 카테고리, 책상태)
CREATE OR REPLACE VIEW VIEW_BOOK_INFO
AS
SELECT  NVL(C.BOOK_ID,-999) AS BOOK_ID
, I.TITLE, I.SUBTITLE
, NVL(LISTAGG(A.AUTHOR_NAME, ',') WITHIN GROUP(ORDER BY CR.AUTHOR_ORDER, A.AUTHOR_NAME ASC), '-') AS AUTHOR
, NVL(LISTAGG(A.AUTHOR_ID, ',') WITHIN GROUP(ORDER BY CR.AUTHOR_ORDER, A.AUTHOR_ID), '-') AS AUTHOR_ID
, NVL(P.PUB_NAME,'-') AS PUB_NAME, NVL(CT.CAT_NAME, '-') AS CAT_NAME
, I.ISBN, NVL(BS.BOOK_STATUS_NAME, '-') AS BOOK_STATUS_NAME
, NVL(P.PUB_ID, -999) AS PUB_ID, NVL(CT.CAT_ID, -999) AS CAT_ID, NVL(C.BOOK_STATUS_ID, -999) AS BOOK_STATUS_ID
FROM BOOK_INFO I LEFT JOIN BOOK_COPY C
    ON I.ISBN = C.ISBN
LEFT JOIN PUBLISHERS P
    ON I.PUB_ID = P.PUB_ID
LEFT JOIN CATEGORIES CT
    ON I.CAT_ID = CT.CAT_ID
LEFT JOIN BOOK_STATUS BS
    ON C.BOOK_STATUS_ID = BS.BOOK_STATUS_ID
LEFT JOIN CONTRIBUTOR CR
    ON CR.ISBN = I.ISBN
LEFT JOIN AUTHORS A
    ON CR.AUTHOR_ID = A.AUTHOR_ID
GROUP BY C.BOOK_ID, I.TITLE, I.SUBTITLE, P.PUB_NAME, CT.CAT_NAME, I.ISBN, BS.BOOK_STATUS_NAME, P.PUB_ID, CT.CAT_ID, C.BOOK_STATUS_ID ;





