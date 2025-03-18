CREATE OR REPLACE Procedure JONAVA.Check_Modules_Status

/******************************************************************************
   NAME:       CHECK_MODULES_STATUS
   PURPOSE:    tikrinti veikianciu moduliu sarasa MODULE_STATUS lenteleje
               ir jei modulis pasenes pagal Last_Active reiksme daugiau kaip
			   nustatytas module_timeout, istrina irasa is lenteles

   REVISIONS:
   Ver        Date        Author       Description
   ---------  ----------  -----------  ------------------------------------
   1.0        seniaj      Robke        1. Sukure
   1.1        2001.12.17  Rimelis      2. ACTIVE_DISPATCHERS apdorojimas ishmesti tuos irashus,
                                          kurie netenkina DBMS_SESSION.IS_ACTIVE_SESSION
                                          Tokie irashai yra nuluzusiu DDV moduliu
   1.2        2002.03.14  Aurimas      3. Jeigu DSM (module_type = 2) pakibo, tai irasome
                                          ivyki (506) i pirma pasote, kurios tipas rysio serveris.
   1.3        2003.02.18  Rimelis      4. Jei DSM nuluzo ji ishmetant reikia COMMANDS irashus
                                          su statusu -1 ir -3 updateint i statusa 903
******************************************************************************/
IS
  -- aktyvus schemos moduliai
  CURSOR mod_cursor IS
    SELECT id, module_type FROM modsta
      WHERE (sysdate-last_active)*24*60*60 >= module_timeout;
  mod_cursor_rec mod_cursor%ROWTYPE;

  CURSOR comn_serv IS
    SELECT s.subst_id AS subst_id
	  FROM sub s
	  WHERE s.sub_type = 5;
  comn_serv_rec comn_serv%ROWTYPE;

  CURSOR get_active_disps IS
    SELECT session_id, rowid
	  FROM active_dispatchers;
  active_disps_rec get_active_disps%ROWTYPE;

BEGIN

  OPEN mod_cursor;
  LOOP
    FETCH mod_cursor INTO mod_cursor_rec;
    EXIT WHEN mod_cursor%NOTFOUND;

	IF mod_cursor_rec.module_type = 2 THEN
	  -- randam ryshio serveri ir ikalam jam ivyki
	  OPEN comn_serv;
	  FETCH comn_serv INTO comn_serv_rec;
	  IF comn_serv %FOUND THEN
        INSERT INTO subeve (subst_id, datetime, datetime_ms, event_id)
	      VALUES (comn_serv_rec.subst_id, SYSDATE, 0, 506);
	  END IF;
	  CLOSE comn_serv;
	  -- ikalam visom komandom su statusu -1 ir -3 statusa 903
	  UPDATE commands
	    SET com_status_id = 903
		WHERE (com_status_id = -1 OR com_status_id = -3) AND
		      zone IN (SELECT id
			             FROM zone_servers);
	  COMMIT;

	ELSIF mod_cursor_rec.module_type = 3 THEN
      INSERT INTO error_log( msg )
	    VALUES ( 'Pakibo GVM ');
	  COMMIT;
	END IF;

    DELETE modsta WHERE id = mod_cursor_rec.id;
    COMMIT;
  END LOOP;
  CLOSE mod_cursor;
  -- active_dispatchers
  OPEN get_active_disps;
  LOOP
    FETCH get_active_disps INTO active_disps_rec;
	EXIT WHEN get_active_disps%NOTFOUND;
	IF NOT DBMS_SESSION.IS_SESSION_ALIVE(active_disps_rec.session_id) THEN
	  DELETE FROM active_dispatchers
	    WHERE rowid = active_disps_rec.rowid;
      COMMIT;
	END IF;
  END LOOP;
  CLOSE get_active_disps;
--EXCEPTION
--  WHEN OTHERS THEN
--    ADD_ERROR(SQLERRM, 1, USER, 'CHECK_MODULES_STATUS');
END;

/
