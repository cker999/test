CREATE OR REPLACE PROCEDURE JONAVA.PutPipeText
/*  Paskirtis:	  Siuncia viena reiksme <pipe_msg_text> i pipe'a <pipename>.
				  Reiksme pipe'e privalo buti VARCHAR2 tipo.
	Parametrai:	IN  pipename        - Pipe'o, i kuri padedamas pranesimas, vardas
 					pipe_msg_text   - Pranesimas (reiksme) VARCHAR2 tipo
					timeout  		- Laikas sek., per kuri pranesimas padedamas i pipe'a. Jei 0, tai
				  	  	   	   		  reiksme padedama be uzlaikymo.
					maxpipe			- Maximum size allowed for the pipe, in bytes.
			   OUT  status   		- 0 - Success
			                   		  1 - Timed out. If the pipe was implicitly-created and is empty, then it is removed.
							   		  2 - Record in the pipe is too large for the buffer.
							   		  3 - An interrupt occurred.
							   		  ORA-23322 - User has insufficient privileges to read from the pipe.
*/
	(pipename 	     IN VARCHAR2,  -- Pipe'o vardas, i kuri perduodamas pranesimas VARCHAR2 tipo
	 pipe_msg_text   IN VARCHAR2,  -- perduodamas pranesimas VARCHAR2 tipo
	 timeout  	     IN NUMBER,    -- Time to wait while attempting to place a message on a pipe, in seconds
	 maxpipe 	     IN NUMBER,	   -- Maximum size allowed for the pipe, in bytes
	 status 		 OUT NUMBER) IS
pipe_write_error EXCEPTION;
BEGIN
  -- Purges contents of local buffer.
  dbms_pipe.reset_buffer;
  -- pack into the local message buffer
  -- Perduodamas pranesimas VARCHAR2 tipo i nurodyta pipe'a
  dbms_pipe.pack_message(pipe_msg_text);
  -- send a message on the named pipe
  status:= dbms_pipe.send_message(pipename, timeout, maxpipe);
  IF status <> 0 THEN
	-- 1:Timed out 2:An interrupt occurred 3:Insufficient privileges
    RAISE pipe_write_error;
  END IF;
  EXCEPTION
    WHEN pipe_write_error THEN
	  -- 1:Timed out 2:An interrupt occurred 3:Insufficient privileges
	  IF status = 1 THEN
	    dbms_output.put_line('Timed out error on (' || to_char(status) || ') writing to pipe');
	    --raise_application_error(-20000, 'Timed out error on (' || to_char(state) || ') writing to pipe');
	  ELSIF status = 2 THEN
	    dbms_output.put_line('An interrupt occurred on (' || to_char(status) || ') writing to pipe');
	    --raise_application_error(-20000, 'An interrupt occurred on (' || to_char(state) || ') writing to pipe');
	  ELSIF status = 3 THEN
	    dbms_output.put_line('Insufficient privileges error on (' || to_char(status) || ') writing to pipe');
	    --raise_application_error(-20000, 'Insufficient privileges error on (' || to_char(state) || ') writing to pipe');
      END IF;
END;

/
