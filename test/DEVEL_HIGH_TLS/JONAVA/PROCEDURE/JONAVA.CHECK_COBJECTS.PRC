CREATE OR REPLACE PROCEDURE JONAVA.CHECK_COBJECTS IS
tmpVar NUMBER;
/******************************************************************************
   NAME:       CHECK_COBJECTS
   PURPOSE:    Updatetinti cobjectus pagal susietu switchu pozicijas

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        2001.12.04             1. patikrinti cobjects susietus switchus ir
    		  						 	pagal juos update'inti cobjectus
******************************************************************************/
  CURSOR get_trusted_switch IS
    SELECT cs.switch_id, cs.state, c.TRUSTED_STATE, c.COBJECT_ID
      FROM cobjects c, cobject_switches cs
      WHERE c.COBJECT_ID = cs.COBJECT_ID AND
            c.TRUSTED_STATE = cs.STATE_ID;
  trusted_switch_rec get_trusted_switch%ROWTYPE;
  CURSOR get_switch_data (swid NUMBER) IS
    SELECT state, datetime
	  FROM switches
	  WHERE switch_id = swid;
  switch_rec get_switch_data%ROWTYPE;
BEGIN
  OPEN get_trusted_switch;
  LOOP
    FETCH get_trusted_switch INTO trusted_switch_rec;
	EXIT WHEN get_trusted_switch%NOTFOUND;
	OPEN get_switch_data (trusted_switch_rec.switch_id);
	FETCH get_switch_data INTO switch_rec;
	IF switch_rec.state = trusted_switch_rec.state THEN
	  UPDATE cobjects
	    SET state_id= trusted_switch_rec.trusted_state,
		    trusted_state= 0,
			datetime= switch_rec.datetime
		WHERE cobject_id = trusted_switch_rec.cobject_id;
	  COMMIT;
	END IF;
	CLOSE get_switch_data;
  END LOOP;
  CLOSE get_trusted_switch;
--EXCEPTION
--   WHEN OTHERS THEN
--       Null;
END CHECK_COBJECTS;
/
