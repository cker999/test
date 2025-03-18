CREATE OR REPLACE PROCEDURE JONAVA.SLUDGE_CONTROL IS
/******************************************************************************
   NAME:       SLUDGE_CONTROL
   PURPOSE:    To calculate the desired information.

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        2001.07.02             1. Created this procedure.

******************************************************************************/
  CriterionCount NUMBER:= 5;

  CURSOR get_criterion IS
    SELECT s.criterion_id, s.subst_id, s.min_lim, s.max_lim, e.value
	  FROM sludge_conf s, sensors e
	  WHERE s.SUBST_ID = e.SUBST_ID AND
	        s.CONTR_ID = e.CONTR_ID AND
			s.SENSOR_ID = e.SENSOR_ID;
  criterion_rec get_criterion%ROWTYPE;
  CURSOR get_flag IS
    SELECT value
	  FROM system_params
	  WHERE param = 'SLUDGE_DETECTED';
  flag_rec get_flag%ROWTYPE;
  nSubstId NUMBER:= 0;
BEGIN
 OPEN get_criterion;
 LOOP
   FETCH get_criterion INTO criterion_rec;
   EXIT WHEN get_criterion%NOTFOUND;
   nSubstId:= criterion_rec.subst_id;
   IF criterion_rec.value >= criterion_rec.min_lim AND
      criterion_rec.value <= criterion_rec.max_lim THEN
	 CriterionCount:= CriterionCount - 1;
   END IF;
 END LOOP;
 CLOSE get_criterion;
 -- ivedam ivyki
 OPEN get_flag;
 FETCH get_flag INTO flag_rec;
 IF get_flag%FOUND THEN
   IF flag_rec.value = 'N' AND CriterionCount = 0 THEN
   -- pranesham apie izo pavoju
     INSERT INTO subst_events (id, datetime, datetime_ms, event_id, status_id, subst_id)
	   VALUES (event_id_seq.nextval, SYSDATE, 0, 504, 0, nSubstId);
	 UPDATE system_params
	   SET value= 'Y'
	   WHERE param = 'SLUDGE_DETECTED';
   ELSIF flag_rec.value = 'Y' AND CriterionCount > 0 THEN
   -- pranesham apie izo pavojaus pabaiga
     INSERT INTO subst_events (id, datetime, datetime_ms, event_id, status_id, subst_id)
	   VALUES (event_id_seq.nextval, SYSDATE, 0, 505, 0, nSubstId);
	 UPDATE system_params
	   SET value= 'N'
	   WHERE param = 'SLUDGE_DETECTED';
   END IF;
   COMMIT;
 END IF;
 CLOSE get_flag;

END SLUDGE_CONTROL;

/
