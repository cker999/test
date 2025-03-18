CREATE OR REPLACE PROCEDURE JONAVA.CALC_HE1_DATA_WRAPPER (CalcDateStr IN VARCHAR2) IS
/******************************************************************************
   NAME:       CALC_HE1_DATA_WRAPPER
   PURPOSE:    HE.CALC_HE1_DATA wrapper for BDE

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        2001.06.28             1. Created this procedure.
******************************************************************************/
BEGIN
  HE.CALC_HE1_DATA(TO_DATE(CalcDateStr, 'YYYY.MM.DD HH24:MI:SS'));
END CALC_HE1_DATA_WRAPPER;

/
