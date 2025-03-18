CREATE OR REPLACE Procedure JONAVA.MARK_CHANNELS
   ( nChan IN NUMBER, nSubst_id IN NUMBER, nContr_id IN NUMBER, nWhich IN NUMBER)
   IS
-- Paskirtis: Rasti ir pazymeti AI_CHANNELS laukus SEND_CONF visai ELGID'iniu
-- prietaisu grupei (7 kanalai, tik kai nChan > 56)
-- AUTONOMOUS_TRANSACTION reikalinga todel, kad uzklausos vykdomos lentelems,
-- kuriu trigeriai iskviete sia procedura, t.y. lenteles mutuoja ir paskutine
-- tranzakcija, kurioje patvirtinamas ivykis, dar nebaigta. Del pastarosios priezasties
-- zemiau esancio uzklausos su Count() grazina nepatvirtintu ivykiu skaiciu
-- pries tranzakcija ir lyginama ne su 0, bet su tsen/tswi/tcob (0 arba 1)
    PRAGMA AUTONOMOUS_TRANSACTION;
    unhandled_events_found EXCEPTION;
    records_counted NUMBER;
    nChan1 NUMBER;
    nChan2 NUMBER;
    nDev NUMBER;
BEGIN
    IF nChan < 56 THEN
        -- not ELGIDA channel
        RETURN;
    ELSE
        AI_CHANN55(nChan, nDev, nChan1, nChan2);
        /*-- which device (getting integral part of division)
        --nDev := (nChan - 56) / 7 + 1;
        nDev := to_number(substr(ltrim(to_char((nChan - 56) / 7,'099.999')),
            1,instr(ltrim(to_char((nChan - 56) / 7,'099.999')), '.')-1)) + 1;
        -- channel from
        nChan1 := 56 + (nDev - 1) * 7;
        -- channel to
        nChan2 := nChan1 + 6;*/
    END IF;
    IF nWhich = 0 THEN
        -- mark SEND_CONF
        UPDATE aic SET SEND_CONF = 1
            WHERE subst_id = nSubst_id AND contr_id = nContr_id AND
                channel_id BETWEEN nChan1 AND nChan2 AND channel_id <> nChan;
    ELSE
        -- mark READ_CONF
        --UPDATE aic SET READ_CONF = 1
        --    WHERE subst_id = nSubst_id AND contr_id = nContr_id AND
        --        channel_id BETWEEN nChan1 AND nChan2 AND channel_id <> nChan;
        null;
    END IF;
    COMMIT;
    /*IF records_counted > tswi THEN
        --dbms_output.put_line('Check_Substation_Status. Switch events found ' || records_counted);
        RAISE unhandled_events_found;
    END IF;
    -- excepetion handling goes here
    EXCEPTION
    -- yra nepatvirtintu ivykiu - pastotes darbo ivertinimas - status_id=1
       WHEN unhandled_events_found THEN
         UPDATE sub
	        SET status_id = 1
            WHERE subst_id = sub_id;
         COMMIT;
     --  WHEN OTHERS THEN
     -- null;*/
END; -- Procedure

/
