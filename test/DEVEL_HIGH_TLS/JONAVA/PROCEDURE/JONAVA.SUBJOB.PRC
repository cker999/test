CREATE OR REPLACE Procedure JONAVA.SUBJOB
   ( which IN NUMBER)
-- Parametrai:       IN  - which
--                         1,  2,  3  - JOB, paleidziantis Arxproc(1) procedura
--                         11, 12, 13  - JOB, paleidziantis Arxproc(2) procedura
--                         21, 22, 23  - JOB, paleidziantis Arxproc(3) procedura
--                         31, 32, 33 - JOB, paleidziantis Check_Modules_Status procedura
IS
    jobno NUMBER;
BEGIN
    IF which IN (2,3) THEN
        BEGIN
            SELECT job INTO jobno FROM user_jobs
                WHERE what LIKE 'arxproc(1)%';
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                  DBMS_OUTPUT.PUT_LINE('Error: no job');
                RETURN;
                --WHEN TOO_MANY_ROWS THEN
                --    jobno := 202;
        END;
    END IF;
    IF which IN (12,13) THEN
        BEGIN
            SELECT job INTO jobno FROM user_jobs
                WHERE what LIKE 'arxproc(2)%';
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                  DBMS_OUTPUT.PUT_LINE('Error: no job');
                RETURN;
        END;
    END IF;
    IF which IN (22,23) THEN
        BEGIN
            SELECT job INTO jobno FROM user_jobs
                WHERE what LIKE 'arxproc(3)%';
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                  DBMS_OUTPUT.PUT_LINE('Error: no job');
                RETURN;
        END;
    END IF;
    -- JOB kuris paleidzia procedura Check_Modules_Status.
    -- Procedura tikrina veikianciu moduliu sarasa MODULE_STATUS lenteleje
    -- ir jei modulis pasenes pagal Last_Active reiksme, istrina irasa is lenteles
    IF which IN (32,33) THEN
        BEGIN
            SELECT job INTO jobno FROM user_jobs
                WHERE what LIKE 'Check_Modules_Status%';
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                  DBMS_OUTPUT.PUT_LINE('Error: no job');
                RETURN;
        END;
    END IF;
    /***************************    VP1    ******************************/
    IF which = 1 THEN
        -- submit job VP1
        DBMS_JOB.SUBMIT(jobno,
            'arxproc(1);',
            SYSDATE,
            'SYSDATE + 1/(24*2)');
        DBMS_OUTPUT.PUT_LINE('Job is submitted. Job No:'||jobno);
    ELSIF which = 2 THEN
        -- remove job
        DBMS_JOB.REMOVE(jobno);
        DBMS_OUTPUT.PUT_LINE('Job is removed');
    ELSIF which = 3 THEN
        -- run job
        DBMS_JOB.RUN(jobno);
        DBMS_OUTPUT.PUT_LINE('Job is executed');
    /***************************    VP2   ******************************/
    ELSIF which = 11 THEN
        -- submit job VP2
        DBMS_JOB.SUBMIT(jobno,
            'arxproc(2);',
            SYSDATE,
            'SYSDATE + 6/24');
        DBMS_OUTPUT.PUT_LINE('Job is submitted. Job No:'||jobno);
    ELSIF which = 12 THEN
        -- remove job
        DBMS_JOB.REMOVE(jobno);
        DBMS_OUTPUT.PUT_LINE('Job is removed');
    ELSIF which = 13 THEN
        -- run job
        DBMS_JOB.RUN(jobno);
        DBMS_OUTPUT.PUT_LINE('Job is executed');
    /***************************    VP3 ******************************/
    ELSIF which = 21 THEN
        -- submit job VP3
        DBMS_JOB.SUBMIT(jobno,
            'arxproc(3);',
            SYSDATE,
            'SYSDATE + 1');
        DBMS_OUTPUT.PUT_LINE('Job is submitted. Job No:'||jobno);
    ELSIF which = 22 THEN
        -- remove job
        DBMS_JOB.REMOVE(jobno);
        DBMS_OUTPUT.PUT_LINE('Job is removed');
    ELSIF which = 23 THEN
        -- run job
        DBMS_JOB.RUN(jobno);
        DBMS_OUTPUT.PUT_LINE('Job is executed');
    /*************************** Check_Modules_Status ******************************/
    ELSIF which = 31 THEN
        -- submit job
        DBMS_JOB.SUBMIT(jobno,
            'Check_Modules_Status;',
            SYSDATE,
            'SYSDATE + 1/1440'); -- po 60 sekundziu
        DBMS_OUTPUT.PUT_LINE('Job is submitted. Job No:'||jobno);
    ELSIF which = 32 THEN
        -- remove job
        DBMS_JOB.REMOVE(jobno);
        DBMS_OUTPUT.PUT_LINE('Job is removed');
    ELSIF which = 33 THEN
        -- run job
        DBMS_JOB.RUN(jobno);
        DBMS_OUTPUT.PUT_LINE('Job is executed');
    END IF;
    COMMIT;
END; -- Procedure SUBJOB
-- End of DDL script for SUBJOB

/
