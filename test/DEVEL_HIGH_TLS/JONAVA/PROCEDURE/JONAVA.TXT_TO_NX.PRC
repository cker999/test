CREATE OR REPLACE PROCEDURE JONAVA.TXT_TO_NX ( LANG_O VARCHAR2, MOD_ID NUMBER)IS
tmpVar NUMBER;
/******************************************************************************
   NAME:       TXT_TO_NX
   PURPOSE:    This procedure converts LITH data of table NX_INI_STRINGS to raw format and
               compares it with nx_string String_Text.

   REVISIONS:
   Ver        Date        Author
   ---------  ----------  ---------------
   1.0        2002.06.06  Auris S


******************************************************************************/
StrRAW  RAW(250);
StrRAW1 RAW(250);
StrRAW2 RAW(250);
Str     VARCHAR2(250);
IniROW  ROWID;


CURSOR get_from_ini IS
  SELECT LITH, rowid
    FROM nx_ini_strings;

cursor get_from_nx IS
  SELECT String_Text, StrRaw
    FROM nx_string
	WHERE Version_Id = MOD_ID AND
	      LANGUAGE_CODE = LANG_O AND
		  ( (String_Text = StrRaw) OR (String_Text = StrRaw || '0A') ); --OA perkelimas i kita eilute...

BEGIN
  UPDATE nx_ini_strings
    SET used= 0;
  OPEN get_from_ini;
  LOOP
	FETCH get_from_ini INTO Str, IniROW;
	EXIT WHEN get_from_ini%NOTFOUND;
	StrRAW:= UTL_RAW.CAST_TO_RAW(Str);
	OPEN get_from_nx;
	FETCH get_from_nx INTO StrRaw1, StrRaw2;
	IF get_from_nx%FOUND THEN
	   IF ( StrRaw1 <> StrRaw2 ) THEN
	   	  StrRaw := StrRaw || '0A';
	   END IF;
	   UPDATE nx_ini_strings
	     SET LITH_STRING_NX = StrRaw, used = 1
		 WHERE rowid = IniROW;
    ELSE
 	  UPDATE nx_ini_strings
	     SET LITH_STRING_NX = StrRaw, used = 0
		 WHERE rowid = IniROW;
    END IF;
	CLOSE get_from_nx;
	COMMIT;
  END LOOP;
  CLOSE get_from_ini;

END TXT_TO_NX;

/
