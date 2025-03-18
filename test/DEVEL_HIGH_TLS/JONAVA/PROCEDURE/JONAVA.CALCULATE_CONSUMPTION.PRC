CREATE OR REPLACE PROCEDURE JONAVA.calculate_consumption IS
   p_date date default to_date(to_char(sysdate, 'yyyy.mm.dd'), 'yyyy.mm.dd');
BEGIN
   data_auto_col.calculate_consumption(p_date);
EXCEPTION
    WHEN OTHERS THEN
        NULL;
END;

/
