CREATE OR REPLACE PROCEDURE JONAVA.Test_user
 	(d_n IN varchar2,
 	 d_sn IN varchar2,
 	 d_p IN varchar2,
	o_user OUT varchar2,
	o_passw OUT varchar2 ) IS
BEGIN
	o_user := 'a';
	o_passw := 'b';
	SELECT ouser,opassw
		INTO o_user,o_passw
		FROM disp_test
		WHERE disp_vardas = d_n
			AND disp_pavarde = d_sn
			AND disp_slapt = d_p;
END;

/
