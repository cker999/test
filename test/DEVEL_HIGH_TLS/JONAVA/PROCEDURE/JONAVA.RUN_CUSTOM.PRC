﻿CREATE OR REPLACE PROCEDURE JONAVA.RUN_CUSTOM IS
BEGIN
  NULL;
EXCEPTION
  WHEN OTHERS THEN
    ADD_ERROR(SQLERRM, 3, 'DDV', 'RUN_CUSTOM');
END; -- Procedure

/
