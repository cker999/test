CREATE OR REPLACE PROCEDURE JONAVA.Get_disp_properties1
 (d_n IN varchar2,
   d_sn IN varchar2,
   d_p IN varchar2,
   d_id OUT number,
   d_sid OUT number,
   o_user OUT varchar2,
   o_passw OUT varchar2,
   vRet OUT NUMBER )
IS
   vHM NUMBER(3);
BEGIN
  o_user := '';
	o_passw := '';
	vRet := -1;
	SELECT COUNT(*)
		INTO vHM
		FROM dispatchers
		WHERE disp_name = d_n
			AND disp_secname = d_sn
			AND disp_passw = d_p;
	IF vHM = 1 THEN
		-- one record was found
		SELECT o_user,o_passw,disp_id,security_id
			INTO o_user,o_passw,d_id,d_sid FROM dispatchers
			WHERE disp_name = d_n AND disp_secname = d_sn AND disp_passw = d_p;
		vRet := 0;
	ELSIF	vHM = 0 THEN
		-- no records
		vRet := 1;
	ELSE
		-- more one records
		vRet := 2;
	END IF;
END;

/
