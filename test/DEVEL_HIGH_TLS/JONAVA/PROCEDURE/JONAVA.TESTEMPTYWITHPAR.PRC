CREATE OR REPLACE PROCEDURE JONAVA.TestEmptyWithPar
 	(pipename IN VARCHAR2,
	 timeout IN NUMBER,
	 status OUT NUMBER,
	 pipe_msg_num OUT NUMBER) IS
BEGIN
null;
/*
-- copy the message into the local message buffer.
  status := dbms_pipe.receive_message(pipename, timeout);
  IF status = 0 THEN
  -- retrieve item from the buffer.
    dbms_pipe.unpack_message(pipe_msg_num);
  ELSE
  -- nesekmingas nuskaitymas. Pvz. kai pipe'as tuscias.
  	pipe_msg_num := -1;
  END IF;
*/
END;

/
