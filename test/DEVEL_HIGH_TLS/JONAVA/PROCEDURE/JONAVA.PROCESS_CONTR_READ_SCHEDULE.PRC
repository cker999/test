CREATE OR REPLACE PROCEDURE JONAVA.PROCESS_CONTR_READ_SCHEDULE IS
/******************************************************************************
   NAME:       PROCESS_CONTR_READ_SCHEDULE
   PURPOSE:    To calculate the desired information.

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        2001.12.18             1. Created this procedure.
   1.1		  2002.05.14			 2. Pataisytas bug'as su insert'u
   2.0		  2002.05.24			 3. pakartotinas skaitymas po nesekmingos komandos
   2.1		  2002.09.30			 4. galimybe sukti nuskaityma ciklu nepertraukiamai
   2.2		  2002.10.30			 5. Ishtaisyti bug'as kai komandos po 2.1 pataisymo
   			  						 	 generuodavosi beperstojo
******************************************************************************/

  CURSOR get_schedule IS
    SELECT subst_id, contr_id, next_read, interval, disp_id, rowid, read_after_failure,
	       read_after_failure_date, read_after_failure_timeout
	  FROM controllers_read_schedule
	  WHERE stopped = 0;
  schedule_rec get_schedule%ROWTYPE;

  CURSOR get_command (p_subst_id in number, p_contr_id in number) IS
    SELECT com_status_id
	  FROM commands
	  WHERE cont_subst_id = p_subst_id AND
	        cont_contr_id = p_contr_id AND
			com_id = 8
	  ORDER BY id DESC;
  command_rec get_command%ROWTYPE;

  CURSOR get_cycle IS
    SELECT value
	  FROM system_params
	  WHERE param = 'SCHEDULE_UNINTERRUPTED';
  rec_cycle get_cycle%ROWTYPE;

  dNext DATE;
BEGIN
  OPEN get_schedule;
  LOOP
    FETCH get_schedule INTO schedule_rec;
	EXIT WHEN get_schedule%NOTFOUND;
	-- patikrinam ar paskutinis skaitymas nebuvo blogas
	OPEN get_command (schedule_rec.subst_id, schedule_rec.contr_id);
	FETCH get_command INTO command_rec;
	IF get_command%FOUND THEN
	  IF command_rec.com_status_id > 0 THEN 	 		-- paskutinis skaitymas buvo nesekmingas
	    IF schedule_rec.read_after_failure = 1 THEN		-- papildomo skaitymo funkcija aktyvuota
	      IF schedule_rec.read_after_failure_date IS NULL THEN -- nera papildomo skaitymo momento
		    BEGIN	-- suformuojam pirma papildomo skaitymo momenta
	          dNext:= SYSDATE + schedule_rec.read_after_failure_timeout/1440;
  	          UPDATE controllers_read_schedule
	            SET read_after_failure_date = dNext
	            WHERE rowid = schedule_rec.rowid;
			  COMMIT;
  		    EXCEPTION
   	          WHEN OTHERS THEN
 	            NULL;
	        END;
		  ELSE -- papildomas nuskaitymo momentas yra
		    IF schedule_rec.read_after_failure_date <= SYSDATE THEN -- laikas skaityti
		      BEGIN
  	  	        INSERT INTO commands (com_id, action_id, com_status_id,
	     	                        disp_id, reg_time, cont_contr_id, cont_subst_id, id)
			      VALUES (8, 1, -2, schedule_rec.disp_id, SYSDATE,
	      	            schedule_rec.contr_id, schedule_rec.subst_id, comms_id_seq.nextval);
			    -- suformuojam sekanti papildomo skaitymo momenta
	            dNext:= schedule_rec.read_after_failure_date + schedule_rec.read_after_failure_timeout/1440;
  	            IF dNext <= SYSDATE THEN -- korekcija, jei DSM buvo uzstriges ar tvarkarashtis buco sustabdytas
	              dNext:= SYSDATE + schedule_rec.read_after_failure_timeout/1440;
	            END IF;
  	            UPDATE controllers_read_schedule
 	              SET read_after_failure_date = dNext
	              WHERE rowid = schedule_rec.rowid;
			    COMMIT;
	          EXCEPTION
	            WHEN OTHERS THEN
	              NULL;
   	          END;
		    END IF;
		  END IF;
	    END IF;
	  ELSIF command_rec.com_status_id = 0 THEN -- komanda ivykdyta
        -- paskutinis skaitymas sekmingas arba vyksta
   	    IF schedule_rec.next_read <= SYSDATE THEN -- laikas skaityti
	      BEGIN
  	        INSERT INTO commands (com_id, action_id, com_status_id,
	                              disp_id, reg_time, cont_contr_id, cont_subst_id, id)
	          VALUES (8, 1, -2, schedule_rec.disp_id, SYSDATE,
	                  schedule_rec.contr_id, schedule_rec.subst_id, comms_id_seq.nextval);
	        dNext:= schedule_rec.next_read + schedule_rec.interval/1440;
  	        IF dNext <= SYSDATE THEN -- korekcija, jei tvarkarashtis buvo sustabdytas
	          dNext:= SYSDATE + schedule_rec.interval/1440;
	        END IF;
  	        UPDATE controllers_read_schedule
	          SET next_read= dNext
	          WHERE rowid = schedule_rec.rowid;
	        COMMIT;
	      EXCEPTION
	        WHEN OTHERS THEN
	          NULL;
	      END;
	    END IF;
 	    -- tikrinam ar neireikia sukti nuskaitymo ciklo nepertraukiamai
	    OPEN get_cycle;
		FETCH get_cycle INTO rec_cycle;
		IF get_cycle%FOUND THEN
		  IF rec_cycle.value = '1' AND schedule_rec.interval = 1 THEN
		    BEGIN
              INSERT INTO commands (com_id, action_id, com_status_id,
                                    disp_id, reg_time, cont_contr_id, cont_subst_id, id)
                VALUES (8, 1, -2, schedule_rec.disp_id, SYSDATE,
                        schedule_rec.contr_id, schedule_rec.subst_id, comms_id_seq.nextval);
            EXCEPTION
			  WHEN OTHERS THEN
			    NULL;
			END;
            dNext:= SYSDATE + schedule_rec.interval/1440;
  	        UPDATE controllers_read_schedule
	          SET next_read= dNext
	          WHERE rowid = schedule_rec.rowid;
	        COMMIT;
		  END IF;
	    END IF;
		CLOSE get_cycle;
    	-- papildomo skaitymo momentu generavimo sustabdymas po sekmingo nuskaitymo
	    IF schedule_rec.read_after_failure_date IS NOT NULL THEN
	      BEGIN
            UPDATE controllers_read_schedule
              SET read_after_failure_date = NULL
              WHERE rowid = schedule_rec.rowid;
  	        COMMIT;
          EXCEPTION
	        WHEN OTHERS THEN
	          NULL;
	      END;
	    END IF;
	  END IF;
	CLOSE get_command;
    END IF;
  END LOOP;
  CLOSE get_schedule;
EXCEPTION
  WHEN OTHERS THEN
    ADD_ERROR(SQLERRM, 3, 'PROCESS_CONTR_READ_SCHEDULE');
END PROCESS_CONTR_READ_SCHEDULE;

/
