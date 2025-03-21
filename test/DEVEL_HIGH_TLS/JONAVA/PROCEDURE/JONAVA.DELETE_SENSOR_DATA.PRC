﻿CREATE OR REPLACE PROCEDURE JONAVA.DELETE_SENSOR_DATA
IS
BEGIN
--Pirma magistrale
DELETE FROM SENSOR_DATA WHERE DATETIME > SYSDATE - 10/(24*60) AND SENSOR_ID = 2744151893 AND ( VALUE > 50000 OR VALUE < 1); --energija
DELETE FROM SENSOR_DATA WHERE DATETIME > SYSDATE - 10/(24*60) AND SENSOR_ID = 2744151894 AND ( VALUE > 10000 OR VALUE < 1); --galia
DELETE FROM SENSOR_DATA WHERE DATETIME > SYSDATE - 10/(24*60) AND SENSOR_ID = 2744151900 AND ( VALUE > 1000 OR VALUE < 30); --debitas
DELETE FROM SENSOR_DATA WHERE DATETIME > SYSDATE - 10/(24*60) AND SENSOR_ID = 2744151901 AND ( VALUE > 100 OR VALUE < 10); --temperatura
DELETE FROM SENSOR_DATA WHERE DATETIME > SYSDATE - 10/(24*60) AND SENSOR_ID = 2744151902 AND ( VALUE > 100 OR VALUE < 10); --temperatura
DELETE FROM SENSOR_DATA WHERE DATETIME > SYSDATE - 10/(24*60) AND SENSOR_ID = 2744151905 AND ( VALUE > 10 OR VALUE < 2); -- slegis
DELETE FROM SENSOR_DATA WHERE DATETIME > SYSDATE - 10/(24*60) AND SENSOR_ID = 2744151906 AND ( VALUE > 10 OR VALUE < 2); --slegis
DELETE FROM SENSOR_DATA WHERE DATETIME > SYSDATE - 10/(24*60) AND SENSOR_ID = 2744151916 AND ( VALUE > 1000 OR VALUE < 30); --debitas
DELETE FROM SENSOR_DATA WHERE DATETIME > SYSDATE - 10/(24*60) AND SENSOR_ID = 2744152010 AND ( VALUE > 20 OR VALUE < -20); --debito skirtumas
DELETE FROM SENSOR_DATA WHERE DATETIME > SYSDATE - 10/(24*60) AND SENSOR_ID = 2744152011 AND ( VALUE > 60 OR VALUE < -60); --temperaturos skirtumas
DELETE FROM SENSOR_DATA WHERE DATETIME > SYSDATE - 10/(24*60) AND SENSOR_ID = 2744152012 AND ( VALUE > 4 OR VALUE < -4); --slegiu skirtumas
--Antra magistrale
DELETE FROM SENSOR_DATA WHERE DATETIME > SYSDATE - 10/(24*60) AND SENSOR_ID = 2744251921 AND ( VALUE > 50000 OR VALUE < 1); --energija
DELETE FROM SENSOR_DATA WHERE DATETIME > SYSDATE - 10/(24*60) AND SENSOR_ID = 2744251922 AND ( VALUE > 10000 OR VALUE < 1); --galia
DELETE FROM SENSOR_DATA WHERE DATETIME > SYSDATE - 10/(24*60) AND SENSOR_ID = 2744251928 AND ( VALUE > 1000 OR VALUE < 30); --debitas
DELETE FROM SENSOR_DATA WHERE DATETIME > SYSDATE - 10/(24*60) AND SENSOR_ID = 2744251929 AND ( VALUE > 100 OR VALUE < 10); --temperatura
DELETE FROM SENSOR_DATA WHERE DATETIME > SYSDATE - 10/(24*60) AND SENSOR_ID = 2744251930 AND ( VALUE > 100 OR VALUE < 10); --temperatura
DELETE FROM SENSOR_DATA WHERE DATETIME > SYSDATE - 10/(24*60) AND SENSOR_ID = 2744251933 AND ( VALUE > 10 OR VALUE < 1); --slegis
DELETE FROM SENSOR_DATA WHERE DATETIME > SYSDATE - 10/(24*60) AND SENSOR_ID = 2744251934 AND ( VALUE > 10 OR VALUE < 1); --slegis
DELETE FROM SENSOR_DATA WHERE DATETIME > SYSDATE - 10/(24*60) AND SENSOR_ID = 2744251944 AND ( VALUE > 1000 OR VALUE < 30); --debitas
DELETE FROM SENSOR_DATA WHERE DATETIME > SYSDATE - 10/(24*60) AND SENSOR_ID = 2744252013 AND ( VALUE > 20 OR VALUE < -20); --debito skirtumas
DELETE FROM SENSOR_DATA WHERE DATETIME > SYSDATE - 10/(24*60) AND SENSOR_ID = 2744252014 AND ( VALUE > 60 OR VALUE < -60); --temperaturos skirtumas
DELETE FROM SENSOR_DATA WHERE DATETIME > SYSDATE - 10/(24*60) AND SENSOR_ID = 2744252015 AND ( VALUE > 4 OR VALUE < -4); --slegiu skirtumas
DELETE FROM COMMANDS WHERE END_TIME < SYSDATE - 59/(24*60) AND COM_STATUS_ID >= 0; --istriname senas komandas
COMMIT;
END;

/
