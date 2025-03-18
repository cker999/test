CREATE OR REPLACE PROCEDURE JONAVA.CALCULATE_SENSORS IS
tmpVar NUMBER;
/******************************************************************************
   NAME:       CALCULATE_SENSORS
   PURPOSE:    Apdoroja CALCULATED_SENSORS lenteles reishkinius

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        2002.10.07  Rimelis           1. Created this procedure.
   1.1.		  2002.10.11  Rimelis			2. vietoj update i SENSORS insert i SENSORS_DATA
   1.2.       2013.10.28  Paulius           Insertas daromas naudojant GT_DSM.insert_sensor_data
******************************************************************************/
  CURSOR get_calcsens IS
    SELECT param1, param2, param1_datetime, param2_datetime, result, expression, rowid
	  FROM calculated_sensors;
  calcsens_rec get_calcsens%ROWTYPE;
  CURSOR get_value(p_sensor_id NUMBER) IS
    SELECT value, datetime
	  FROM sensors
	  WHERE sensor_id = p_sensor_id;
  nParam1Value NUMBER;
  dParam1Date DATE:= NULL;
  nParam2Value NUMBER;
  dParam2Date DATE:= NULL;
  nResult NUMBER:= NULL;
  cSQL VARCHAR2(500):= NULL;
  on_err_code NUMBER;
  ov_err_msg VARCHAR2(1000);
  TYPE cur_typ IS REF CURSOR;
  dynamic_cur cur_typ;
BEGIN
  OPEN get_calcsens;
  LOOP
    FETCH get_calcsens INTO calcsens_rec;
	EXIT WHEN get_calcsens%NOTFOUND;
	-- randam pirmo parametro reikshme
	OPEN get_value(calcsens_rec.param1);
	FETCH get_value INTO nParam1Value, dParam1Date;
	IF get_value%FOUND THEN
		CLOSE get_value;
		-- randam antro parametro reikshme
		OPEN get_value(calcsens_rec.param2);
		FETCH get_value INTO nParam2Value, dParam2Date;
		IF get_value%FOUND THEN
		  IF calcsens_rec.param1_datetime IS NULL OR calcsens_rec.param2_datetime IS NULL OR
		     (calcsens_rec.param1_datetime < dParam1Date AND
			 calcsens_rec.param2_datetime < dParam2Date)
			 THEN
  		    -- vykdome formule
		    cSQL:= 'SELECT '||calcsens_rec.expression||' FROM dual';
		    BEGIN
		      IF INSTR(calcsens_rec.expression, ':PARAM1') < INSTR(calcsens_rec.expression, ':PARAM2') THEN
			    OPEN dynamic_cur FOR cSQL USING nParam1Value, nParam2Value;
		      ELSE
			    OPEN dynamic_cur FOR cSQL USING nParam2Value, nParam1Value;
		      END IF;
			  FETCH dynamic_cur INTO nResult;
			  CLOSE dynamic_cur;
		    EXCEPTION
		      WHEN OTHERS THEN
			    NULL;
		    END;
		    IF nResult IS NOT NULL THEN
--			  INSERT INTO sensor_data (sensor_id, value, datetime)
--			    VALUES (calcsens_rec.result, nResult, SYSDATE);
                GT_DSM.Insert_Sensor_Data(calcsens_rec.result,  sysdate, 0, nResult, on_err_code,ov_err_msg);
			  UPDATE calculated_sensors
			    SET param1_datetime = dParam1Date, param2_datetime = dParam2Date
				WHERE rowid = calcsens_rec.rowid;
			  COMMIT;
		    END IF;
		  END IF;
	    END IF;
	    CLOSE get_value;
	ELSE
		CLOSE get_value;
	END IF;
  END LOOP;
  CLOSE get_calcsens;
END CALCULATE_SENSORS; 
/
