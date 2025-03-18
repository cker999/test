CREATE OR REPLACE Procedure JONAVA.AI_CHANN55
   ( nChan IN NUMBER, nDev OUT NUMBER, nChan1 OUT NUMBER, nChan2 OUT NUMBER)
   IS
-- For AI channels above 55, returns ELGIDA device number nDev and both start
-- (nChan1) and end (nChan2) AI channel
BEGIN
    IF nChan < 56 THEN
        -- not ELGIDA channel
        nDev := 0;
        nChan1 := 0;
        nChan2 := 0;
    ELSE
        -- which device (getting integral part of division)
        --nDev := (nChan - 56) / 7 + 1;
        nDev := to_number(substr(ltrim(to_char((nChan - 56) / 7,'099.999')),
            1,instr(ltrim(to_char((nChan - 56) / 7,'099.999')), '.')-1)) + 1;
        -- channel from
        nChan1 := 56 + (nDev - 1) * 7;
        -- channel to
        nChan2 := nChan1 + 6;
    END IF;
--EXCEPTION
--    WHEN exception_name THEN
--        statements ;
END; -- Procedure

/
