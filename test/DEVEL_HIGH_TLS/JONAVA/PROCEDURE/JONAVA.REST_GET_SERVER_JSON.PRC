CREATE OR REPLACE PROCEDURE JONAVA.rest_get_server_json (in_server_id zone_servers.id%TYPE := NULL) IS
  l_cursor SYS_REFCURSOR;
BEGIN
 OPEN l_cursor FOR SELECT id server_id, name server_name FROM zone_servers WHERE id = NVL(in_server_id, id);
 apex_json.open_object;
 apex_json.write('servers', l_cursor);
 apex_json.close_object;
END;
/
