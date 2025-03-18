CREATE OR REPLACE PROCEDURE JONAVA.Check_Substation_Status
         (sub_id IN NUMBER,   -- Pastotes ID
		  tsen IN NUMBER,     -- 1 jei procedura kviesta is SENEVE_AFT_U trigerio, kitaip 0
		  tswi IN NUMBER,     -- 1 jei procedura kviesta is SWIEVE_AFT_U trigerio, kitaip 0
		  tcob IN NUMBER,	  -- 1 jei procedura kviesta is COBEVE_AFT_U trigerio, kitaip 0
		  tcon IN NUMBER,     -- 1 jei procedura kviesta is CONEVE_AFT_U trigerio, kitaip 0
		  tsub IN NUMBER,	  -- 1 jei procedura kviesta is SUBEVE_AFT_U trigerio, kitaip 0
		  tlzqm IN NUMBER,    -- 1 jei procedura kviesta is LZQMEVE_AFT_U trigerio, kitaip 0
		  tcnt IN NUMBER ) IS -- 1 jei procedura kviesta is CNTEVE_AFT_U trigerio, kitaip 0
-- Paskirtis: Patikrinti, ar yra nepatvirtintu ivykiu, kurie to reikalauja.
--            Ivykiai ieskomi lentelese SENEVE, SWIEVE, COBEVE, CONEVE ir SUBEVE
-- AUTONOMOUS_TRANSACTION reikalinga todel, kad uzklausos vykdomos lentelems,
-- kuriu trigeriai iskviete sia procedura, t.y. lenteles mutuoja ir paskutine
-- tranzakcija, kurioje patvirtinamas ivykis, dar nebaigta. Del pastarosios priezasties
-- zemiau esancio uzklausos su Count() grazina nepatvirtintu ivykiu skaiciu
-- pries tranzakcija ir lyginama ne su 0, bet su tsen/tswi/tcob (0 arba 1)
PRAGMA AUTONOMOUS_TRANSACTION;
unhandled_events_found EXCEPTION;
records_counted NUMBER;
-- PL/SQL Block
BEGIN
  --dbms_output.put_line('Check_Substation_Status');
  -- Patikrinam ar yra neptavirtintu ivykiu SENSOR_EVENTS lenteleje,
  -- kuriuos reikia patvirtinti
  SELECT COUNT(*) INTO records_counted
  	FROM seneve e, evedes d, sen s
	WHERE e.event_id = d.id
      AND s.sensor_id = e.sensor_id
	  AND s.subst_id = sub_id
	  AND e.status_id = 0
  	  AND (( d.confirm = 1  AND NOT EXISTS ( SELECT ced.eve_id
		                                       FROM custom_eve_desc ced
					   						   where ced.eve_id = e.event_id
					   						   AND ced.obj_id = e.sensor_id
					   						   AND ced.confirm = 0 ))
	     OR ( d.confirm = 0  AND    EXISTS ( SELECT ced.eve_id
		                                       FROM custom_eve_desc ced
			  		   						   where ced.eve_id = e.event_id
					   						   AND ced.obj_id = e.sensor_id
					   						   AND ced.confirm = 1 )) );
  IF records_counted > tsen THEN
    --dbms_output.put_line('Check_Substation_Status. Sensor events found ' || records_counted);
  	RAISE unhandled_events_found;
  ELSE
  	-- Patikrinam ar yra neptavirtintu ivykiu SWITCH_EVENTS lenteleje,
	-- kuriuos reikia patvirtinti
    SELECT COUNT(*) INTO records_counted
      FROM swieve e, evedes d, swi s
	  WHERE e.event_id = d.id
	    AND s.subst_id = sub_id
        AND s.switch_id = e.switch_id
	    AND e.status_id = 0
		AND (( d.confirm = 1  AND NOT EXISTS ( SELECT ced.eve_id
		                                         FROM custom_eve_desc ced
					   						  	 where ced.eve_id = e.event_id
					   						  	 AND ced.obj_id = e.switch_id
					   						  	 AND ced.confirm = 0 ))
	       OR ( d.confirm = 0  AND    EXISTS ( SELECT ced.eve_id
		                                         FROM custom_eve_desc ced
			  	   		     			         where ced.eve_id = e.event_id
					   						     AND ced.obj_id = e.switch_id
					   						     AND ced.confirm = 1 )) );
    IF records_counted > tswi THEN
	  --dbms_output.put_line('Check_Substation_Status. Switch events found ' || records_counted);
      RAISE unhandled_events_found;
    ELSE
      -- Patikrinam ar yra neptavirtintu ivykiu COBJECT_EVENTS lenteleje,
      -- kuriuos reikia patvirtinti
      SELECT COUNT(*) INTO records_counted
        FROM cobeve e, evedes d, cob c
	    WHERE e.event_id = d.id
          AND c.cobject_id = e.cobject_id
  	      AND c.subst_id = sub_id
	      AND e.status_id = 0
		  AND (( d.confirm = 1  AND NOT EXISTS ( SELECT ced.eve_id
		                                           FROM custom_eve_desc ced
				  	   						  	   where ced.eve_id = e.event_id
					   						  	   AND ced.obj_id = e.cobject_id
					   						  	   AND ced.confirm = 0 ))
	         OR ( d.confirm = 0  AND    EXISTS ( SELECT ced.eve_id
		                                           FROM custom_eve_desc ced
					   						       where ced.eve_id = e.event_id
					   						       AND ced.obj_id = e.cobject_id
					   						       AND ced.confirm = 1 )) );
      IF records_counted > tcob THEN
	    --dbms_output.put_line('Check_Substation_Status. Object events found ' || records_counted);
        RAISE unhandled_events_found;
      ELSE
        -- Patikrinam ar yra neptavirtintu ivykiu CONTROLLER_EVENTS lenteleje,
        -- kuriuos reikia patvirtinti
        SELECT COUNT(*) INTO records_counted
          FROM coneve e, evedes d
          WHERE e.event_id = d.id
  	        AND e.subst_id = sub_id
            AND e.status_id = 0
			AND (( d.confirm = 1  AND NOT EXISTS ( SELECT ced.eve_id
		                                             FROM custom_eve_desc ced
				  	   						  	     where ced.eve_id = e.event_id
					   						  	     AND ced.obj_id = e.contr_id
					   						  	     AND ced.confirm = 0 ))
	           OR ( d.confirm = 0  AND    EXISTS ( SELECT ced.eve_id
		                                             FROM custom_eve_desc ced
					   						         where ced.eve_id = e.event_id
					   						         AND ced.obj_id = e.contr_id
					   						         AND ced.confirm = 1 )) );
        IF records_counted > tcon THEN
		  --dbms_output.put_line('Check_Substation_Status. Controller events found ' || records_counted);
          RAISE unhandled_events_found;
	    ELSE
  		  -- Patikrinam ar yra neptavirtintu ivykiu SUBST_EVENTS lenteleje,
	      -- kuriuos reikia patvirtinti
	      SELECT COUNT(*) INTO records_counted
	        FROM subeve e, evedes d
	        WHERE e.event_id = d.id
		    AND e.subst_id = sub_id
	        AND e.status_id = 0
			AND (( d.confirm = 1  AND NOT EXISTS ( SELECT ced.eve_id
		                                             FROM custom_eve_desc ced
				  	   						  	     where ced.eve_id = e.event_id
					   						  	     AND ced.obj_id = e.subst_id
					   						  	     AND ced.confirm = 0 ))
	           OR ( d.confirm = 0  AND    EXISTS ( SELECT ced.eve_id
		                                             FROM custom_eve_desc ced
					   						         where ced.eve_id = e.event_id
					   						         AND ced.obj_id = e.subst_id
					   						         AND ced.confirm = 1 )) );
	      IF records_counted > tsub THEN
		  	--dbms_output.put_line('Check_Substation_Status. Substation events found ' || records_counted);
	        RAISE unhandled_events_found;
	   	  ELSE
		    -- Patikrinam ar yra neptavirtintu ivykiu LZQMEVE lenteleje,
		    -- kuriuos reikia patvirtinti
		    SELECT COUNT(*) INTO records_counted
		      FROM lzqmeve e, evedes d
		      WHERE e.event_id = d.id
			  AND e.subst_id = sub_id
		      AND e.status_id = 0
			  AND (( d.confirm = 1  AND NOT EXISTS ( SELECT ced.eve_id
		                                               FROM custom_eve_desc ced
				  	   						  	       where ced.eve_id = e.event_id
					   						  	       AND ced.obj_id = e.lzqm_id
					   						  	       AND ced.confirm = 0 ))
  	             OR ( d.confirm = 0  AND    EXISTS ( SELECT ced.eve_id
		                                               FROM custom_eve_desc ced
					   						           where ced.eve_id = e.event_id
					   						           AND ced.obj_id = e.lzqm_id
					   						           AND ced.confirm = 1 )) );
		    IF records_counted > tlzqm THEN
			  --dbms_output.put_line('Check_Substation_Status. Substation events found ' || records_counted);
		      RAISE unhandled_events_found;
			ELSE
			  -- Patikrinam ar yra neptavirtintu ivykiu COUNTER_EVENTS lenteleje,
  	          -- kuriuos reikia patvirtinti
	     	   SELECT COUNT(*) INTO records_counted
      		     FROM counter_events e, evedes d, counters cs
	  			 WHERE e.event_id = d.id
	    		 AND cs.subst_id = sub_id
        		 AND cs.id = e.counter_id
	    		 AND e.status_id = 0
				 AND (( d.confirm = 1  AND NOT EXISTS ( SELECT ced.eve_id
		                                           FROM custom_eve_desc ced
				  	   						  	   where ced.eve_id = e.event_id
					   						  	   AND ced.obj_id = e.counter_id
					   						  	   AND ced.confirm = 0 ))
			     OR ( d.confirm = 0  AND    EXISTS ( SELECT ced.eve_id
		                                           FROM custom_eve_desc ced
					   						       where ced.eve_id = e.event_id
					   						       AND ced.obj_id = e.counter_id
					   						       AND ced.confirm = 1 )) );
	      	   IF records_counted > tcnt THEN
	             --dbms_output.put_line('Check_Substation_Status. Substation events found ' || records_counted);
	             RAISE unhandled_events_found;
	   	  	   ELSE
		         -- Nepatvirtintu ivykiu, kurie reikalauja patvirtinimo,
			     -- nera pastoteje
		         UPDATE sub
		           SET status_id = 0
		           WHERE subst_id = sub_id;
		         COMMIT;
			   END IF;
			END IF;
    	  END IF;
		END IF;
--dbms_output.put_line('Check_Substation_Status. status_id updated to 0');
      END IF;
	END IF;
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
     -- null;
END;

/
