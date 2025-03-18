CREATE OR REPLACE PROCEDURE JONAVA.SESS_LOGGER IS
/******************************************************************************
   NAME:       SESS_LOGGER
   PURPOSE:    To calculate the desired information.

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        2002.05.27             1. Created this procedure.

******************************************************************************/
 CURSOR get_all_sessions IS
  SELECT   /*+ choose */
         s.serial#, si.sid, s.osuser, s.terminal,
         s.program, p.program as osprogram, s.logon_time, s.lockwait,
         si.physical_reads, si.block_gets, si.consistent_gets,
         si.block_changes, si.consistent_changes, s.action
    FROM v$session s, v$process p, sys.v_$sess_io si
   WHERE s.paddr = p.addr(+)
     AND si.sid(+) = s.sid
     AND (s.username IS NOT NULL)
     AND (NVL (s.osuser, 'x') <> 'SYSTEM')
     AND (s.TYPE <> 'BACKGROUND')
  ORDER BY 1;
 all_sessions_rec get_all_sessions%ROWTYPE;

 CURSOR get_all_locks IS
   SELECT   /*+ choose */
         s.osuser, s.program, s.serial#, lk.sid,
         DECODE (
            lk.TYPE,
            'MR', 'Media Recovery',
            'RT', 'Redo Thread',
            'UN', 'User Name',
            'TX', 'Transaction',
            'TM', 'DML',
            'UL', 'PL/SQL User Lock',
            'DX', 'Distributed Xaction',
            'CF', 'Control File',
            'IS', 'Instance State',
            'FS', 'File Set',
            'IR', 'Instance Recovery',
            'ST', 'Disk Space Transact.',
            'TS', 'Temp Segment',
            'IV', 'Libr. Cache Invalid.',
            'LS', 'Log Start or Switch',
            'RW', 'Row Wait',
            'SQ', 'Sequence Number',
            'TE', 'Extend Table',
            'TT', 'Temp Table',
            lk.TYPE
         ) lock_type,
         DECODE (
            lk.lmode,
            0, 'None',
            1, 'Null',
            2, 'Row-S (SS)',
            3, 'Row-X (SX)',
            4, 'Share',
            5, 'S/Row-X (SSX)',
            6, 'Exclusive',
            TO_CHAR (lk.lmode)
         ) mode_held,
         DECODE (
            request,
            0, 'None',
            1, 'Null',
            2, 'Row-S (SS)',
            3, 'Row-X (SX)',
            4, 'Share',
            5, 'S/Row-X (SSX)',
            6, 'Exclusive',
            TO_CHAR (lk.request)
         ) mode_requested,
         DECODE (
            lk.block,
            0, 'Not Blocking',           /* Not blocking any other processes */
            1, 'Blocking',               /* This lock blocks other processes */
            2, 'Global',            /* This lock is global, so we can't tell */
            TO_CHAR (lk.block)
         ) blocking_others,
           owner || '.' || object_name as object_name
    FROM v$lock lk, v$session s, all_objects ao, v$locked_object lo
   WHERE lk.lmode != 0
     AND lk.lmode != 1
     AND lk.sid = s.sid
     AND ao.object_id = lo.object_id
     AND lo.session_id = s.sid
     AND (s.username IS NOT NULL)
     AND (s.username <> 'SYSTEM')
     AND (s.username <> 'SYS')
     AND (s.osuser IS NOT NULL)
     AND (s.osuser <> 'SYSTEM')
  ORDER BY 1;
 all_locks_rec get_all_locks%ROWTYPE;

 CURSOR get_blocks IS
   SELECT   /*+ choose */
         bs.sid, bs.serial#, bs.program as blocking_app,
         ws.program as waiting_app, bs.machine as blocking_machine,
         ws.machine as waiting_machine,
         DECODE (
            wk.TYPE,
            'MR', 'Media Recovery',
            'RT', 'Redo Thread',
            'UN', 'USER Name',
            'TX', 'Transaction',
            'TM', 'DML',
            'UL', 'PL/SQL USER LOCK',
            'DX', 'Distributed Xaction',
            'CF', 'Control FILE',
            'IS', 'Instance State',
            'FS', 'FILE SET',
            'IR', 'Instance Recovery',
            'ST', 'Disk SPACE Transact.',
            'TS', 'Temp Segment',
            'IV', 'Libr. Cache Invalid.',
            'LS', 'LOG START OR Switch',
            'RW', 'ROW Wait',
            'SQ', 'Sequence Number',
            'TE', 'Extend TABLE',
            'TT', 'Temp TABLE',
            wk.TYPE
         ) lock_type,
         DECODE (
            hk.lmode,
            0, 'None',
            1, 'NULL',
            2, 'ROW-S (SS)',
            3, 'ROW-X (SX)',
            4, 'SHARE',
            5, 'S/ROW-X (SSX)',
            6, 'EXCLUSIVE',
            TO_CHAR (hk.lmode)
         ) mode_held,
         DECODE (
            wk.request,
            0, 'None',
            1, 'NULL',
            2, 'ROW-S (SS)',
            3, 'ROW-X (SX)',
            4, 'SHARE',
            5, 'S/ROW-X (SSX)',
            6, 'EXCLUSIVE',
            TO_CHAR (wk.request)
         ) mode_requested,
		   oc.sql_text
    FROM v$lock hk, v$session bs, v$lock wk, v$session ws, v$open_cursor oc
   WHERE hk.lmode != 0
     AND hk.lmode != 1
     AND wk.request != 0
     AND wk.TYPE(+) = hk.TYPE
     AND wk.id1(+) = hk.id1
     AND wk.id2(+) = hk.id2
     AND hk.sid = bs.sid(+)
     AND wk.sid = ws.sid(+)
     AND (bs.username IS NOT NULL)
     AND (bs.username <> 'SYSTEM')
     AND (bs.username <> 'SYS')
	 AND bs.SID = oc.SID
  ORDER BY 1;
 blocks_rec get_blocks%ROWTYPE;

 fLog UTL_FILE.FILE_TYPE;
 cFileLocation VARCHAR2(20):= 'E:\LOG';
 cFileName VARCHAR2(20):= 'testas.log';
 cOpenMode VARCHAR2(1):= 'a';
 cBuffer VARCHAR2(1024):= 'testas';
BEGIN
  cFileName:= 's'||TO_CHAR(SYSDATE, 'YYYYMMDD_HH24')||'.log';
  fLog:= UTL_FILE.FOPEN(cFileLocation, cFileName, cOpenMode);

  cBuffer:= '>>>>> '||TO_CHAR(SYSDATE, 'YYYY.MM.DD HH24:MI:SS');
  UTL_FILE.PUT_LINE(fLog, cBuffer);
  UTL_FILE.PUT_LINE(fLog, NULL);
    -- all sessions
  cBuffer:= 'Serial#   SID       Client User                   Terminal        Program             O.S Program         Connect Time            Lock Wait Phys. Reads Block Gets  Cons. Gets  Block Chges Cons. Chges ACTION              ';
  UTL_FILE.PUT_LINE(fLog, cBuffer);
  cBuffer:= '----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------';
  UTL_FILE.PUT_LINE(fLog, cBuffer);
  OPEN get_all_sessions;
  LOOP
    FETCH get_all_sessions INTO all_sessions_rec;
	EXIT WHEN get_all_sessions%NOTFOUND;
	cBuffer:= RPAD(TO_CHAR(all_sessions_rec.serial#), 10) || RPAD(TO_CHAR(all_sessions_rec.sid), 10);
	cBuffer:= cBuffer || RPAD(all_sessions_rec.osuser, 30) || RPAD(all_sessions_rec.terminal, 16);
	cBuffer:= cBuffer || RPAD(NVL(SUBSTR(TRIM(all_sessions_rec.program), 1, 20), ' '), 20) || RPAD(SUBSTR(TRIM(all_sessions_rec.osprogram), 1, 20), 20);
    cBuffer:= cBuffer || TO_CHAR(all_sessions_rec.logon_time, ' YYYY.MM.DD HH24:MI:SS') || RPAD(NVL(SUBSTR(TRIM(all_sessions_rec.lockwait), 1, 10), ' '), 10);
    cBuffer:= cBuffer || RPAD(TO_CHAR(all_sessions_rec.physical_reads), 12) || RPAD(TO_CHAR(all_sessions_rec.block_gets), 12);
    cBuffer:= cBuffer || RPAD(TO_CHAR(all_sessions_rec.consistent_gets), 12) || RPAD(TO_CHAR(all_sessions_rec.block_changes), 12);
    cBuffer:= cBuffer || RPAD(TO_CHAR(all_sessions_rec.consistent_changes), 12) || RPAD(SUBSTR(all_sessions_rec.action, 1, 20), 20);
    UTL_FILE.PUT_LINE(fLog, cBuffer);
  END LOOP;
  UTL_FILE.PUT_LINE(fLog, NULL);
  CLOSE get_all_sessions;
  -- locks
  cBuffer:= 'O.S. User           Program             Serial#   SID       Lock Type           Lock Mode           Request Type        Blocking Others      Object                        ';
  UTL_FILE.PUT_LINE(fLog, cBuffer);
  cBuffer:= '--------------------------------------------------------------------------------------------------------------------------------------------------------------------------';
  UTL_FILE.PUT_LINE(fLog, cBuffer);
  OPEN get_all_locks;
  LOOP
    FETCH get_all_locks INTO all_locks_rec;
	EXIT WHEN get_all_locks%NOTFOUND;
	cBuffer:= RPAD(TRIM(all_locks_rec.osuser), 20) || RPAD(NVL(TRIM(all_locks_rec.program), ' '), 20);
	cBuffer:= cBuffer || RPAD(TO_CHAR(all_locks_rec.serial#), 10) || RPAD(TO_CHAR(all_locks_rec.sid), 10);
	cBuffer:= cBuffer || RPAD(TRIM(all_locks_rec.lock_type), 20) || RPAD(TRIM(all_locks_rec.mode_held), 20);
	cBuffer:= cBuffer || RPAD(TRIM(all_locks_rec.mode_requested), 20) || RPAD(TRIM(all_locks_rec.blocking_others), 20);
	cBuffer:= cBuffer || ' ' || TRIM(all_locks_rec.object_name);
    UTL_FILE.PUT_LINE(fLog, cBuffer);
  END LOOP;
  UTL_FILE.PUT_LINE(fLog, NULL);
  CLOSE get_all_locks;
  -- blocks
  cBuffer:= 'SID       Serial#   Blocking App.       Waiting App.        Blocking Machine    Waiting Machine     Lock Type           Mode Held      Mode Requested';
  UTL_FILE.PUT_LINE(fLog, cBuffer);
  cBuffer:= '-----------------------------------------------------------------------------------------------------------------------------------------------------';
  UTL_FILE.PUT_LINE(fLog, cBuffer);
  OPEN get_blocks;
  LOOP
    FETCH get_blocks INTO blocks_rec;
	EXIT WHEN get_blocks%NOTFOUND;
	cBuffer:= RPAD(TO_CHAR(blocks_rec.sid), 10) || RPAD(TO_CHAR(blocks_rec.serial#), 10);
	cBuffer:= cBuffer || RPAD(TRIM(blocks_rec.blocking_app), 20) || RPAD(TRIM(blocks_rec.waiting_app), 20);
	cBuffer:= cBuffer || RPAD(TRIM(blocks_rec.blocking_machine), 20) || RPAD(TRIM(blocks_rec.waiting_machine), 20);
    cBuffer:= cBuffer || RPAD(TRIM(blocks_rec.lock_type), 20) || RPAD(TRIM(blocks_rec.mode_held), 15);
	cBuffer:= cBuffer || RPAD(TRIM(blocks_rec.mode_requested), 15);
    UTL_FILE.PUT_LINE(fLog, cBuffer);
	cBuffer:= 'SQL= ' || TRIM(blocks_rec.sql_text);
    UTL_FILE.PUT_LINE(fLog, cBuffer);
  END LOOP;
  UTL_FILE.PUT_LINE(fLog, NULL);
  CLOSE get_blocks;

  UTL_FILE.FCLOSE(fLog);

--   EXCEPTION
--     WHEN NO_DATA_FOUND THEN
--       Null;
--     WHEN OTHERS THEN
--       Null;
END SESS_LOGGER;
/
