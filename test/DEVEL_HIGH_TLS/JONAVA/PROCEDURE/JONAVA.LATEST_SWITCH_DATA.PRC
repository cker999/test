CREATE OR REPLACE PROCEDURE JONAVA.latest_switch_data
          (p_switch_id IN NUMBER, p_datetime OUT VARCHAR2, p_state OUT NUMBER) IS
    l_datetime DATE;
    l_datetime_ms NUMBER(3);
   BEGIN
     SELECT MAX(TO_CHAR(datetime,'YYYY.MM.DD HH24:MI:SS,') || TO_CHAR(datetime_ms,'009'))
       INTO p_datetime
       FROM switch_data
      WHERE (p_switch_id = switch_data.switch_id);
     l_datetime := TO_DATE(SUBSTR(p_datetime,1,19), 'YYYY.MM.DD HH24:MI:SS');
     l_datetime_ms := TO_NUMBER(SUBSTR(p_datetime, 21), '009');
     SELECT state
       INTO p_state
       FROM switch_data
      WHERE ((p_switch_id = switch_data.switch_id) AND
             (l_datetime = switch_data.datetime) AND
             (l_datetime_ms = switch_data.datetime_ms));
     p_datetime := SUBSTR(p_datetime, 9);
   EXCEPTION
       WHEN NO_DATA_FOUND THEN
            p_datetime := ' '; p_state := 0;
end;

/
