CREATE OR REPLACE PROCEDURE JONAVA.GetPipeMessageText
/*  Paskirtis:	  Grazina reiksme is pipe'o. Reiksme pipe'e privalo buti VARCHAR2 tipo.
				  Jei nurodytame pipe'e nera reiksmes, grazina -1
	Parametrai:	IN  pipename - Pipe vardas
				    timeout  - Laikas sek., kuri laukiamas pranesimas pipe'e. Jei 0, tai
				  	  	   	   reiksme nuskaitoma be uzlaikymo. Jei > 0, tai procedura laukia
							   timeout laika, kol atsiras pranesimas
			   OUT  status   - 0 - Success
			                   1 - Timed out. If the pipe was implicitly-created and is empty, then it is removed.
							   2 - Record in the pipe is too large for the buffer.
							   3 - An interrupt occurred.
							   ORA-23322 - User has insufficient privileges to read from the pipe.
				pipe_msg_num - Pranesimas (reiksme) VARCHAR2 tipo, nuskaitytas is pipe'e
							   -1 jei status nera Success
*/
 	(pipename IN VARCHAR2,
	 timeout IN NUMBER,
	 status OUT NUMBER,
	 pipe_msg_num OUT VARCHAR2) IS
BEGIN
-- copy the message into the local message buffer.
  status := dbms_pipe.receive_message(pipename, timeout);
  IF status = 0 THEN
  -- retrieve item from the buffer.
    dbms_pipe.unpack_message(pipe_msg_num);
  ELSE
  -- nesekmingas nuskaitymas. Pvz. kai pipe'as tuscias.
  	pipe_msg_num := NULL;
  END IF;
END;

/
