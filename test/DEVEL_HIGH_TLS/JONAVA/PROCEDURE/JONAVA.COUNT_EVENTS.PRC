CREATE OR REPLACE PROCEDURE JONAVA.Count_Events
/* Paskirtis:     Suskaiciuoti nepatvirtintus ivykius nurodytoje pastoteje,
                  kuriuos reikia patvirtinti. Procedura tikrina standartinius
				  ivykiu aprasus EVEDES ir vartotojo nustatytus CUSTEVEDES
	Parametrai:	IN  sub_id - Pastotes id
			   OUT  tcon   - Kontroleriu ivykiu skaicius
			   OUT  tcob   - Objektu ivykiu skaicius
			   OUT  tsen   - Davikliu ivykiu skaicius
			   OUT  tswi   - jungikliu ivykiu skaicius
*/
         (sub_id IN NUMBER,   -- Pastotes ID
		  tcon OUT NUMBER,
		  tcob OUT NUMBER,
		  tsen OUT NUMBER,
		  tswi OUT NUMBER) IS
-- Kontroleriu nepatvirtintu ivykiu kursorius
  CURSOR con_eve_cursor IS
    SELECT coneve.contr_id, coneve.event_id, evedes.confirm
      FROM coneve, evedes, con
  	  WHERE coneve.event_id = evedes.id
     	AND con.subst_id = sub_id
        AND con.contr_id = coneve.contr_id
     	AND coneve.status_id = 0;
  conrec con_eve_cursor%ROWTYPE;
-- Objektu nepatvirtintu ivykiu kursorius
  CURSOR cob_eve_cursor IS
    SELECT cobeve.cobject_id, cobeve.event_id, evedes.confirm
      FROM cobeve, evedes, cob
  	  WHERE cobeve.event_id = evedes.id
     	AND cob.subst_id = sub_id
        AND cob.cobject_id = cobeve.cobject_id
     	AND cobeve.status_id = 0;
  cobrec cob_eve_cursor%ROWTYPE;
-- Davikliu nepatvirtintu ivykiu kursorius
  CURSOR sen_eve_cursor IS
    SELECT seneve.sensor_id, seneve.event_id, evedes.confirm
      FROM seneve, evedes, sen
  	  WHERE seneve.event_id = evedes.id
     	AND sen.subst_id = sub_id
        AND sen.sensor_id = seneve.sensor_id
     	AND seneve.status_id = 0;
  senrec sen_eve_cursor%ROWTYPE;
-- Jungikliu nepatvirtintu ivykiu kursorius
  CURSOR swi_eve_cursor IS
    SELECT swieve.switch_id, swieve.event_id, evedes.confirm
      FROM swieve, evedes, swi
  	  WHERE swieve.event_id = evedes.id
     	AND swi.subst_id = sub_id
        AND swi.switch_id = swieve.switch_id
     	AND swieve.status_id = 0;
  swirec swi_eve_cursor%ROWTYPE;
-- Vartotojo aprasytu ivykiu konkretiems objektams kursorius
  CURSOR cust_eve_cursor (object_id NUMBER, event_id NUMBER) IS
    SELECT confirm
      FROM custevedes
      WHERE obj_id = object_id
        AND eve_id = event_id;
  conf   NUMBER;
-- PL/SQL Block
BEGIN
-- Kontroleriu nepatvirtinti ivykiai, kuriuos reikia patvirtinti
  tcon:= 0;
  OPEN con_eve_cursor;
  LOOP
    FETCH con_eve_cursor INTO conrec;
    EXIT WHEN con_eve_cursor%NOTFOUND;
    OPEN cust_eve_cursor(conrec.contr_id, conrec.event_id);
    FETCH cust_eve_cursor INTO conf;
    IF cust_eve_cursor%FOUND THEN
      IF conf = 1 THEN
        tcon:= tcon + 1;
      END IF;
    ELSIF conrec.confirm = 1 THEN
      tcon:= tcon + 1;
    END IF;
    CLOSE cust_eve_cursor;
  END LOOP;
  CLOSE con_eve_cursor;
-- Objektu nepatvirtinti ivykiai, kuriuos reikia patvirtinti
  tcob:= 0;
  OPEN cob_eve_cursor;
  LOOP
    FETCH cob_eve_cursor INTO cobrec;
    EXIT WHEN cob_eve_cursor%NOTFOUND;
    OPEN cust_eve_cursor(cobrec.cobject_id, cobrec.event_id);
    FETCH cust_eve_cursor INTO conf;
    IF cust_eve_cursor%FOUND THEN
      IF conf = 1 THEN
        tcob:= tcob + 1;
      END IF;
    ELSIF cobrec.confirm = 1 THEN
      tcob:= tcob + 1;
    END IF;
    CLOSE cust_eve_cursor;
  END LOOP;
  CLOSE cob_eve_cursor;
-- Davikliu nepatvirtinti ivykiai, kuriuos reikia patvirtinti
  tsen:= 0;
  OPEN sen_eve_cursor;
  LOOP
    FETCH sen_eve_cursor INTO senrec;
    EXIT WHEN sen_eve_cursor%NOTFOUND;
    OPEN cust_eve_cursor(senrec.sensor_id, senrec.event_id);
    FETCH cust_eve_cursor INTO conf;
    IF cust_eve_cursor%FOUND THEN
      IF conf = 1 THEN
        tsen:= tsen + 1;
      END IF;
    ELSIF senrec.confirm = 1 THEN
      tsen:= tsen + 1;
    END IF;
    CLOSE cust_eve_cursor;
  END LOOP;
  CLOSE sen_eve_cursor;
-- Jungikliu nepatvirtinti ivykiai, kuriuos reikia patvirtinti
  tswi:= 0;
  OPEN swi_eve_cursor;
  LOOP
    FETCH swi_eve_cursor INTO swirec;
    EXIT WHEN swi_eve_cursor%NOTFOUND;
    OPEN cust_eve_cursor(swirec.switch_id, swirec.event_id);
    FETCH cust_eve_cursor INTO conf;
    IF cust_eve_cursor%FOUND THEN
      IF conf = 1 THEN
        tswi:= tswi + 1;
      END IF;
    ELSIF swirec.confirm = 1 THEN
      tswi:= tswi + 1;
    END IF;
    CLOSE cust_eve_cursor;
  END LOOP;
  CLOSE swi_eve_cursor;
-- excepetion handling goes here
--  EXCEPTION
--    WHEN OTHERS THEN
--      dbms_output.put_line('Count_Events error');
END;

/
