CREATE OR REPLACE PROCEDURE JONAVA.RemovePipes
/* Paskirtis:	  Istrinti pipe'us
   Parametrai:	  IN  id     - modulio identifikatorius
                  OUT nera
*/
                 (id    IN NUMBER) IS
 status NUMBER;
BEGIN
  status:= dbms_pipe.remove_pipe('PipeName$' || id);
  status:= dbms_pipe.remove_pipe('Pipe_OBJ_Update$' || id);
  status:= dbms_pipe.remove_pipe('GraphPipeName$' || id);
  status:= dbms_pipe.remove_pipe('GraphSensorsIDPipe$' || id);
  EXCEPTION
    WHEN OTHERS THEN
      dbms_output.put_line('Error while removing pipes');
END;

/
