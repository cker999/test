CREATE OR REPLACE PROCEDURE JONAVA.rest_get_server_xml (in_server_id zone_servers.id%TYPE := NULL) IS
  l_clob CLOB;
BEGIN
 SELECT XMLELEMENT("servers", XMLAGG(XMLELEMENT("row", XMLFOREST(id "server_id", name "server_name")))).getClobVal() INTO l_clob FROM zone_servers WHERE id = NVL(in_server_id, id);
 OWA_UTIL.mime_header('text/xml');
 HTP.print(l_clob);
END;
/
