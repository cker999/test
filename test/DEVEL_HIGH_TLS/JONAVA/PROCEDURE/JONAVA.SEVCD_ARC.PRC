CREATE OR REPLACE PROCEDURE JONAVA.SEVCD_ARC IS
  cKind  VARCHAR2(10):= '';
  ret    NUMBER;
  cRowId VARCHAR2(20):= '';
  CurRow ROWID;
  CURSOR get_jcpr IS
    SELECT subst_id, contr_id, sevcd_id, row_id, consob_value,
	       consoc_value, tmoy_value, pmoy_value, date_value, datetime
      FROM sevcd_jcpr_data
      WHERE ROWID = CHARTOROWID(cRowId);
  jcpr_rec get_jcpr%ROWTYPE;
  CURSOR get_jcms IS
    SELECT subst_id, contr_id, sevcd_id, row_id, volb_value, volc_value, volba_value,
           consob_value, consoc_value, dateb_value, datec_value, datetime
      FROM sevcd_jcms_data
      WHERE ROWID = CHARTOROWID(cRowId);
  jcms_rec get_jcms%ROWTYPE;
  CURSOR get_jevt IS
    SELECT subst_id, contr_id, sevcd_id, row_id, evmt_value, date_value, datetime
      FROM sevcd_jevt_data
      WHERE ROWID = CHARTOROWID(cRowId);
  jevt_rec get_jevt%ROWTYPE;
BEGIN
  GETPIPEMESSAGETEXT('SEVCD_JXXX', 0, ret, cKind);
  IF ret = 0 THEN
    IF cKind = 'JCPR' THEN
	  SELECT row_id, ROWID
	    INTO cRowId, CurRow
		FROM sevcd_arc_last_modified
		WHERE jxxx_kind = 1;
	  DELETE FROM sevcd_arc_last_modified
	    WHERE ROWID = CurRow;
	  OPEN get_jcpr;
	  FETCH get_jcpr INTO jcpr_rec;
	  CLOSE get_jcpr;
	  INSERT INTO sevcd_jcpr_data_arc (subst_id, contr_id, sevcd_id, row_id, consob_value,
	                                   consoc_value, tmoy_value, pmoy_value, date_value, datetime)
		VALUES (jcpr_rec.subst_id, jcpr_rec.contr_id, jcpr_rec.sevcd_id, jcpr_rec.row_id, jcpr_rec.consob_value,
                jcpr_rec.consoc_value, jcpr_rec.tmoy_value, jcpr_rec.pmoy_value, jcpr_rec.date_value, jcpr_rec.datetime);
    ELSIF cKind = 'JCMS' THEN
	  SELECT row_id, ROWID
	    INTO cRowId, CurRow
		FROM sevcd_arc_last_modified
		WHERE jxxx_kind = 2;
	  DELETE FROM sevcd_arc_last_modified
	    WHERE ROWID = CurRow;
	  OPEN get_jcms;
	  FETCH get_jcms INTO jcms_rec;
	  CLOSE get_jcms;
	  INSERT INTO sevcd_jcms_data_arc (subst_id, contr_id, sevcd_id, row_id, volb_value, volc_value, volba_value,
                                           consob_value, consoc_value, dateb_value, datec_value, datetime)
 	    VALUES (jcms_rec.subst_id, jcms_rec.contr_id, jcms_rec.sevcd_id, jcms_rec.row_id, jcms_rec.volb_value, jcms_rec.volc_value, jcms_rec.volba_value,
                    jcms_rec.consob_value, jcms_rec.consoc_value, jcms_rec.dateb_value, jcms_rec.datec_value, jcms_rec.datetime);
    ELSIF cKind = 'JEVT' THEN
	  SELECT row_id, ROWID
	    INTO cRowId, CurRow
		FROM sevcd_arc_last_modified
		WHERE jxxx_kind = 3;
	  DELETE FROM sevcd_arc_last_modified
	    WHERE ROWID = CurRow;
	  OPEN get_jevt;
	  FETCH get_jevt INTO jevt_rec;
	  CLOSE get_jevt;
          INSERT INTO sevcd_jevt_data_arc (subst_id, contr_id, sevcd_id, row_id, evmt_value, date_value, datetime)
            VALUES (jevt_rec.subst_id, jevt_rec.contr_id, jevt_rec.sevcd_id, jevt_rec.row_id, jevt_rec.evmt_value, jevt_rec.date_value, jevt_rec.datetime);
    END IF;
  END IF;
END;

/
