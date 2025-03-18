CREATE OR REPLACE PROCEDURE JONAVA.check_cobject_state IS
 nMask NUMBER(3);
 nNewState cobjects.state_id%TYPE;
BEGIN
 FOR cCobject IN (SELECT * FROM cobjects FOR UPDATE OF state_id) LOOP
  nNewState := cCobject.state_id;
  FOR cState IN (SELECT os.state_inverted
                      , os.state_bit_nr
                      , s.state swt_state
                   FROM cobject_switches os
                      , switches s
                  WHERE os.cobject_id = cCobject.cobject_id
                    AND s.switch_id = os.switch_id) LOOP
   IF cState.state_inverted = 1 THEN --reikia invertuot
    cState.swt_state := ABS(cState.swt_state - 1);
   END IF;
   IF cState.swt_state = 0 THEN -- nuresetinam bita (AND)
    nMask := 255 - POWER(2,(cState.state_bit_nr - 1));
    nNewState := BitAND(nNewState, nMask);
   ELSE -- nustatom bita (OR)
    nMask := POWER(2, (cState.state_bit_nr - 1));
    nNewState := (nNewState + nMask) - BitAND(nNewState, nMask);
   END IF;
  END LOOP;
  UPDATE cobjects SET state_id = nNewState WHERE cobject_id = cCobject.cobject_id;
 END LOOP;
END;
/
