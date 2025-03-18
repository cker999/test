CREATE OR REPLACE PROCEDURE JONAVA.PROCESS_ARX IS
  i NUMBER;
  tDate DATE;

  CURSOR get_conf (level_in IN NUMBER) IS
    SELECT enabled, next_process, processing_range, processing_step
	  FROM arx_level_conf
	  WHERE level_id = level_in;
  conf_rec get_conf%ROWTYPE;
/******************************************************************************
   NAME:       PROCESS_ARX
   PURPOSE:    Paleisti ARX proceduras

   REVISIONS:
   Ver        Date         Description
   ---------  ----------   ------------------------------------
   1.0        2001.07.16   1. Created this procedure.
   1.1	      2001.07.24   2. ARXPROC2
   1.2	      2001.07.30   3. ARXPROC3
   1.3		  2002.12.06   4. Kaliningradui versija
   2.0        2003.01.17   5. Konfiguruojama versija. K0nfiguracija imama ish
                              ARX_LEVEL_CONF. Veikia kartu tik su ARX >=3.0 versija
******************************************************************************/
BEGIN
  FOR i IN 1..4 LOOP
    OPEN get_conf(i);
    FETCH get_conf INTO conf_rec;
    IF get_conf%FOUND THEN
      IF conf_rec.next_process < SYSDATE AND conf_rec.enabled = 1 THEN
        -- randam virshutine skanavimo data ir kviechiam procedura
		IF i IN (1, 2, 3) THEN
          EXECUTE IMMEDIATE 'BEGIN ARX.ARXPROC'||TO_CHAR(i)||'(SYSDATE - '||conf_rec.processing_range||'); END;';
		ELSE
		  ARX.ARXPROC4;
		END IF;
	    -- pakeichiam next_date
	    EXECUTE IMMEDIATE 'SELECT SYSDATE + '||conf_rec.processing_step||' FROM dual' INTO tDate;
        UPDATE arx_level_conf
          SET next_process= tDate
	      WHERE level_id = i;
	    COMMIT;
      END IF;
    END IF;
    CLOSE get_conf;
  END LOOP;

EXCEPTION
  WHEN OTHERS THEN
    ADD_ERROR(SQLERRM, 3, 'PROCESS_ARX');
END PROCESS_ARX;

/
