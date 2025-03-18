CREATE OR REPLACE PROCEDURE JONAVA.DDO IS
 cursor erz_did_cursor IS
     SELECT ez.subst_id AS subst_id, ez.CONTR_ID AS contr_id, ez.ERZ_ID AS erz_id
       from erz ez
       WHERE ez.erz_d_id is null;

   erz_did erz_did_cursor%ROWTYPE;

   nMinId NUMBER(5);
   nHM1 NUMBER(5);
   nHM2 NUMBER(5);
   nHM3 NUMBER(5);
   nHM4 NUMBER(5);
   nHM5 NUMBER(5);
   nHM6 NUMBER(5);

   result number;
   nCounter NUMBER := 0;
BEGIN
  OPEN erz_did_cursor;
  LOOP

    FETCH erz_did_cursor INTO erz_did;

	IF erz_did_cursor%NOTFOUND THEN
	  exit;

	ELSE
	  LOOP
        nCounter := nCounter + 1;
      	SELECT sensor_id_seq.nextval INTO nMinID FROM DUAL;
		nHM1 := -1;
        nHM2 := -1;
        nHM3 := -1;
        nHM4 := -1;
        nHM5 := -1;
        nHM6 := -1;

        SELECT COUNT(*) INTO nHM1 FROM sen
          WHERE sen.subst_id = erz_did.subst_id AND
	            sen.sensor_id = nMinID;

        SELECT COUNT(*) INTO nHM2 FROM swi
          WHERE swi.subst_id = erz_did.subst_id AND
	            swi.switch_id = nMinID;

        SELECT COUNT(*) INTO nHM3 FROM cob
          WHERE  cob.subst_id = erz_did.subst_id AND
            	 cob.cobject_id = nMinID;

	    SELECT COUNT(*) INTO nHM4 FROM sevcd
    	  WHERE sevcd.subst_id = erz_did.subst_id AND
	      		sevcd.sevcd_d_id = nMinID;

        SELECT COUNT(*) INTO nHM5 FROM counters
      	  WHERE counters.subst_id = erz_did.subst_id AND
	            counters.counter_d_id = nMinID;

        SELECT COUNT(*) INTO nHM6 FROM erz
          WHERE erz.subst_id = erz_did.subst_id AND
	            erz.erz_d_id = nMinID;


		IF nHM1 + nHM2 + nHM3 + nHM4 + nHM5 + nHM6 = 0 THEN
      	   result := erz_did.subst_id * 100000 + nMinID;
      	   EXIT;
    	END IF;
    	EXIT WHEN nCounter > 10000;
      END LOOP;
	  UPDATE ERZ ez
	    SET ez.erz_d_id = result
		WHERE ez.erz_id = erz_did.erz_id AND
		      ez.subst_id = erz_did.subst_id AND
			  ez.contr_id = erz_did.contr_id;
	  commit;
	END IF;
  END LOOP;


END;

/
