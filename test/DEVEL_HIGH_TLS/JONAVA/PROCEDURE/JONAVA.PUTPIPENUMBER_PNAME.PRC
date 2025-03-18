CREATE OR REPLACE PROCEDURE JONAVA.PutPipeNumber_PName
/*  Paskirtis:	  Siuncia viena reiksme <pipe_msg_text> i pipe'a <pipename>.
				  Reiksme pipe'e privalo buti NUMBER tipo.
				  Jei pavyksta, siunciamas ir pipe'o vardas i pipe'a <common_pipename>
				  Pagal issiusta pipe'o varda bus nustatyta, kuriame pipe'e atsirado pranesimas,
				  tokiu budu nuolat tikrinti pakanka tik viena pipe'a vardu <common_pipename>
	Parametrai:	IN  pipename        - Pipe'o, i kuri padedamas pranesimas, vardas
					common_pipename - pipe'as, i kuri perduodamas <pipename>
 					pipe_msg_text   - Pranesimas (reiksme) NUMBER tipo
					timeout  		- Laikas sek., per kuri pranesimas padedamas i pipe'a. Jei 0, tai
				  	  	   	   		  reiksme padedama be uzlaikymo.
					maxpipe			- Maximum size allowed for the pipe, in bytes.
*/
	(pipename 	     IN VARCHAR2,  -- Pipe'o vardas, i kuri perduodamas pranesimas NUMBER tipo
 	 common_pipename IN VARCHAR2,  -- Pipe'o vardas, i kuri bus perduotas pipe'o vardas, kuriame bus pranesimas
	 pipe_msg_num    IN NUMBER,    -- perduodamas pranesimas NUMBER tipo
	 timeout  	     IN NUMBER,    -- Time to wait while attempting to place a message on a pipe, in seconds
	 maxpipe 	     IN NUMBER) IS -- Maximum size allowed for the pipe, in bytes
pipe_write_error EXCEPTION;
state NUMBER;
BEGIN
  -- Purges contents of local buffer.
  dbms_pipe.reset_buffer;
  -- pack into the local message buffer
  -- Perduodamas pranesimas NUMBER tipo i nurodyta pipe'a
  dbms_pipe.pack_message(pipe_msg_num);
  -- send a message on the named pipe
  state:= dbms_pipe.send_message(pipename, timeout, maxpipe);
  IF state = 0 THEN
    -- Purges contents of local buffer.
    dbms_pipe.reset_buffer;
    -- pack into the local message buffer
	-- Perduodamas pipe'o vardas, kuriame pries tai sekmingai issiustas pranesimas
    dbms_pipe.pack_message(pipename);
    -- send a message on the named pipe
    state:= dbms_pipe.send_message(common_pipename, timeout, maxpipe);
	IF state <> 0 THEN
	  -- 1:Timed out 2:An interrupt occurred 3:Insufficient privileges
      RAISE pipe_write_error;
	END IF;
  ELSE
    RAISE pipe_write_error;
  END IF;
  EXCEPTION
    WHEN pipe_write_error THEN
	  -- 1:Timed out 2:An interrupt occurred 3:Insufficient privileges
	  IF state = 1 THEN
	    dbms_output.put_line('Timed out error on (' || to_char(state) || ') writing to pipe');
	    --raise_application_error(-20000, 'Timed out error on (' || to_char(state) || ') writing to pipe');
	  ELSIF state = 2 THEN
	    dbms_output.put_line('An interrupt occurred on (' || to_char(state) || ') writing to pipe');
	    --raise_application_error(-20000, 'An interrupt occurred on (' || to_char(state) || ') writing to pipe');
	  ELSIF state = 3 THEN
	    dbms_output.put_line('Insufficient privileges error on (' || to_char(state) || ') writing to pipe');
	    --raise_application_error(-20000, 'Insufficient privileges error on (' || to_char(state) || ') writing to pipe');
      END IF;
END;

/
