CREATE OR REPLACE PROCEDURE JONAVA.NX_TO_TXT IS
/******************************************************************************
   NAME:       NX_TO_TXT
   PURPOSE:    To calculate the desired information.

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        2001.05.21             1. Created this procedure.
*******************************************************************************/
StrRAW RAW(250);
Str VARCHAR2(250);
Id NUMBER:= 0;
Node NUMBER;
CURSOR get_string IS
  SELECT string_text, node_id
    FROM nx_string
	WHERE version_id = 1010 AND
	      language_code = 'US';
CURSOR get_other_string IS
  SELECT string_text
    FROM nx_string
	WHERE version_id = 1010 AND
	      language_code = 'LV' AND
		  node_id = Node;
BEGIN
  DELETE FROM nx_buffer;
  COMMIT;
  OPEN get_string;
  LOOP
    FETCH get_string INTO StrRAW, Node;
	EXIT WHEN get_string%NOTFOUND;
	Str:= UTL_RAW.CAST_TO_VARCHAR2(StrRAW);
	Id:= Id+1;
	INSERT INTO nx_buffer (data, id)
	  VALUES ('ORIGINAL='||Str, Id);
	OPEN get_other_string;
	FETCH get_other_string INTO StrRAW;
	IF get_other_string%FOUND THEN
  	  Id:= Id+1;
  	  Str:= UTL_RAW.CAST_TO_VARCHAR2(StrRAW);
	  INSERT INTO nx_buffer (data, id)
	    VALUES ('TRANSLATION='||Str, Id);
	END IF;
	CLOSE get_other_string;
  END LOOP;
  CLOSE get_string;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    Null;
  WHEN OTHERS THEN
    Null;
END NX_TO_TXT;

/
