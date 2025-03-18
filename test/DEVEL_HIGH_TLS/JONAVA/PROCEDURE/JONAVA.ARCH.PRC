CREATE OR REPLACE PROCEDURE JONAVA.ARCH IS

 nLevel arx_level_conf.level_id%TYPE;
 nTotal NUMBER;
 nStep NUMBER;
 dBegin DATE;
 dStart DATE;
 dEnd DATE;
 dFrom DATE;
 dTo DATE;
 dMin DATE;
 dMax DATE;
 nSum NUMBER;
 nMin NUMBER;
 nAvg NUMBER;
 nMax NUMBER;
 nCnt NUMBER;

 PROCEDURE MakeArxLog (iv_msg VARCHAR2) IS
 BEGIN
  IF nTotal > 0 THEN
   INSERT INTO arx_log (datetime
                      , rows_count
                      , level_id
                      , duration
                      , message)
                VALUES (SYSDATE
                      , nTotal
                      , nLevel
                      , TO_CHAR(TRUNC((SYSDATE - dBegin) * 24*60*60))||' sec.'
                      , iv_msg);
   COMMIT;
  END IF;
 END;

 PROCEDURE MakeErrLog (iv_sender VARCHAR2, iv_module VARCHAR2, iv_msg VARCHAR2) IS
 BEGIN
  INSERT INTO error_log (datetime, msg, msg_level, sender, module)
                 VALUES (SYSDATE, iv_msg, 3, iv_sender, iv_module);
  COMMIT;
 END;

BEGIN
 FOR cConf IN (SELECT * FROM arx_level_conf WHERE next_process < SYSDATE AND enabled = 1 ORDER BY level_id) LOOP
  nLevel := cConf.level_id;
  dBegin := SYSDATE;
  dStart := NULL;
  nTotal := 0;

  IF cConf.level_id < 4 THEN
   EXECUTE IMMEDIATE 'SELECT SYSDATE - '||cConf.processing_range||' FROM dual' INTO dEnd;
   EXECUTE IMMEDIATE 'SELECT '||cConf.processing_interval||' FROM dual' INTO nStep;
   EXECUTE IMMEDIATE 'SELECT COUNT(*)
                        FROM sensor_data'||(CASE WHEN cConf.level_id > 1 THEN '_level'||cConf.level_id END)||'
                       WHERE datetime'||(CASE WHEN cConf.level_id > 1 THEN '_start' END)||' < :dEnd'
           INTO nCnt USING dEnd;
   UPDATE arx_level_conf SET max_rows = nCnt, current_row = 0 WHERE level_id = cConf.level_id;
   COMMIT;

   IF nCnt > 0 THEN
    FOR cSens IN (SELECT * FROM sensors) LOOP
     SELECT TRUNC(MIN(datetime), (CASE WHEN nStep < 1/1440 THEN 'MI' WHEN nStep >= 1 THEN 'DD' ELSE 'HH24' END)) INTO dFrom FROM sensor_data WHERE sensor_id = cSens.sensor_id AND datetime < dEnd; 
     WHILE dFrom + nStep <= dEnd LOOP
      dTo := dFrom + nStep;
      EXECUTE IMMEDIATE 'DELETE sensor_data'||(CASE WHEN cConf.level_id > 1 THEN '_level'||TO_CHAR(cConf.level_id) END)||'
                          WHERE sensor_id = :sensor_id
                            AND datetime'||(CASE WHEN cConf.level_id > 1 THEN '_start' END)||' >= :dFrom
                            AND datetime'||(CASE WHEN cConf.level_id > 1 THEN '_end <= ' ELSE ' < ' END)||':dTo
                      RETURNING '||(CASE WHEN cConf.level_id > 1 THEN 'MIN(datetime_start), MAX(datetime_end), SUM(sum_value), MIN(min_value), AVG(avg_value), MAX(max_value), SUM(items_agregated)'
                                                                 ELSE 'MIN(datetime), MAX(datetime), SUM(value), MIN(value), AVG(value), MAX(value), COUNT(*)' END)||'
                           INTO :dMin, :dMax, :nSum, :nMin, :nAvg, :nMax, :nCnt'
              USING cSens.sensor_id, dFrom, dTo RETURNING INTO dMin, dMax, nSum, nMin, nAvg, nMax, nCnt;
      IF SQL%FOUND THEN
       IF dStart IS NULL OR dMin < dStart THEN
        dStart := dMin;
       END IF;
       BEGIN
        EXECUTE IMMEDIATE 'INSERT INTO sensor_data_level'||TO_CHAR(cConf.level_id + 1)||'
                                       (sensor_id,
                                        datetime_start,
                                        datetime_end,
                                        min_value,
                                        avg_value,
                                        max_value,
                                        sum_value,
                                        items_agregated)
                                VALUES (:sensor_id,
                                        :dFrom,
                                        :dTo,
                                        :nMin,
                                        :nAvg,
                                        :nMax,
                                        :nSum,
                                        :nCnt)'
                USING cSens.sensor_id, dFrom, dTo, nMin, nAvg, nMax, nSum, nCnt;
       EXCEPTION WHEN DUP_VAL_ON_INDEX THEN
        EXECUTE IMMEDIATE 'UPDATE sensor_data_level'||TO_CHAR(cConf.level_id + 1)||'
                              SET min_value = LEAST(min_value, :nMin)
                                , avg_value = (sum_value + :nSum) / (items_agregated + :nCnt)
                                , max_value = GREATEST(max_value, :nMax)
                                , sum_value = sum_value + :nSum
                                , items_agregated = items_agregated + :nCnt
                            WHERE sensor_id = :sensor_id
                              AND datetime_start = :dFrom
                              AND datetime_end = :dTo'
                USING nMin, nSum, nCnt, nMax, nSum, nCnt, cSens.sensor_id, dFrom, dTo;
       END;
       nTotal := nTotal + nCnt;
       UPDATE arx_level_conf SET current_row = current_row + nCnt WHERE level_id = cConf.level_id;
       COMMIT;
      END IF;
      dFrom := dFrom + nStep;
     END LOOP;
    END LOOP;
    MakeArxLog('Lower Date: '||TO_CHAR(dStart, 'YYYY.MM.DD HH24:MI:SS')||', Upper Date: '||TO_CHAR(dMax, 'YYYY.MM.DD HH24:MI:SS')||', Proc. Int.: '||cConf.processing_interval);
   END IF;

  ELSIF cConf.level_id = 4 THEN
   FOR cMntn IN (SELECT * FROM arx_table_maintaining WHERE enabled = 1) LOOP
    BEGIN
     EXECUTE IMMEDIATE 'DELETE '||cMntn.table_name||' WHERE '||cMntn.range||' RETURNING COUNT(*) INTO :nTotal' RETURNING INTO nTotal;
     MakeArxLog('Deleted from '||cMntn.table_name||' with range: '||cMntn.range);
    EXCEPTION WHEN OTHERS THEN
     MakeErrLog('ARCH_MNTN', 'TABLE: '||cMntn.table_name, SUBSTR(SQLERRM, 1, 2000));
    END;
   END LOOP;
  END IF;

  EXECUTE IMMEDIATE 'UPDATE arx_level_conf SET next_process = next_process + '||cConf.processing_step||' WHERE level_id = :level_id' USING cConf.level_id;
 END LOOP;

EXCEPTION WHEN OTHERS THEN
 MakeErrLog('ARCH', 'LEVEL: '||nLevel, SUBSTR(SQLERRM, 1, 2000));
END;
/
