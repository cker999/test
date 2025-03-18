CREATE OR REPLACE PROCEDURE JONAVA.INI_TO_NX (MOD_ID NUMBER)IS
tmpVar NUMBER;
/******************************************************************************
   NAME:       INI_TO_NX
   PURPOSE:    To calculate the desired information.

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        2001.06.07             1. Created this procedure.

******************************************************************************/
StrRAW RAW(250);
Str VARCHAR2(250);
TrStr VARCHAR2(250);
Node NUMBER;
IniROW ROWID;
CURSOR get_string IS
  SELECT string_text, node_id
    FROM nx_string
	WHERE version_id = MOD_ID AND
	      LANGUAGE_CODE = 'US';
CURSOR get_from_ini IS
  SELECT RTRIM(SUBSTR(other, 1, 250)), rowid
    FROM nx_ini_strings
	WHERE TRIM(lith) = TRIM(Str);
BEGIN
  UPDATE nx_ini_strings
    SET used= 0;
  OPEN get_string;
  LOOP
    FETCH get_string INTO StrRAW, Node;
	EXIT WHEN get_string%NOTFOUND;
	Str:= UTL_RAW.CAST_TO_VARCHAR2(StrRAW);
	OPEN get_from_ini;
	FETCH get_from_ini INTO TrStr, IniROW;
	IF get_from_ini%FOUND THEN
	  StrRAW:= UTL_RAW.CAST_TO_RAW(TrStr);
	  UPDATE nx_string
	    SET string_text= StrRAW
		WHERE version_id = MOD_ID AND
		      language_code = 'LV' AND
			  node_id = Node;
	  UPDATE nx_ini_strings
	    SET used= 1
		WHERE rowid = IniROW;
	END IF;
	CLOSE get_from_ini;
  END LOOP;
  CLOSE get_string;
  COMMIT;
END INI_TO_NX;

/
