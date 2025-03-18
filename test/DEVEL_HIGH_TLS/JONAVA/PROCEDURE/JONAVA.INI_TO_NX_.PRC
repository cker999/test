CREATE OR REPLACE PROCEDURE JONAVA.INI_TO_NX_ (LANG_O VARCHAR2, LANG_T VARCHAR2, MOD_ID NUMBER)IS
tmpVar NUMBER;
/******************************************************************************
   NAME:       INI_TO_NX_
   PURPOSE:    Load translated data from nx_ini_strings to nx_string.

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        2002.06.07  Auris S          1. Data loading

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
	      LANGUAGE_CODE = LANG_O;

CURSOR get_from_ini IS
  SELECT RTRIM(SUBSTR(other, 1, 250)), rowid
    FROM nx_ini_strings
	WHERE StrRaw = LITH_STRING_NX;

BEGIN
  UPDATE nx_ini_strings
    SET used= 0;

  OPEN get_string;
  LOOP
    FETCH get_string INTO StrRAW, Node;
	EXIT WHEN get_string%NOTFOUND;
	OPEN get_from_ini;
	FETCH get_from_ini INTO TrStr, IniROW;
	IF get_from_ini%FOUND THEN
	  StrRAW:= UTL_RAW.CAST_TO_RAW(TrStr);
	  UPDATE nx_string
	    SET string_text= StrRAW
		WHERE version_id = MOD_ID AND
		      language_code = LANG_T AND
			  node_id = Node;
	  UPDATE nx_ini_strings
	    SET used= 1
		WHERE rowid = IniROW;
	END IF;
	CLOSE get_from_ini;
  END LOOP;
  CLOSE get_string;
  COMMIT;
END INI_TO_NX_;

/
