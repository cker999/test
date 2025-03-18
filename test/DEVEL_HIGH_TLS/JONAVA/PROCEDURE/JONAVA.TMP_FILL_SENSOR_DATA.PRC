CREATE OR REPLACE PROCEDURE JONAVA.TMP_FILL_SENSOR_DATA is
cursor c_sensor is
    select
        ai.subst_id,
        ai.contr_id,
        ai.channel_id,
        ai.sensor_id
    from
        ai_channels ai
    where
        ai.sensor_id is not null
        and length(to_char(ai.channel_id)) < 5
    order by
        ai.subst_id,
        ai.contr_id,
        ai.channel_id,
        ai.sensor_id;

    r_sensor c_sensor%rowtype;

    p_value number;
begin
    for r_sensor in c_sensor loop
        p_value :=
        (to_number(to_char(sysdate, 'yyyy'), '9999') /
        to_number(to_char(sysdate, 'hh24'), '99')) *
        (to_number(to_char(sysdate, 'mi'), '99') -
        to_number(to_char(sysdate, 'ss'), '99'));

        begin
            insert into sensor_data
            (sensor_id, datetime, value)
            values
            (r_sensor.sensor_id, sysdate, p_value);
            commit;
        exception
            when others then
                null;
        end;
    end loop;
end;

/
