CREATE OR REPLACE Procedure JONAVA.SUB_TYPE_DESC
   ( nSubstID IN NUMBER, vDesc IN OUT VARCHAR)
IS
   nID NUMBER;
BEGIN
    SELECT sub_type INTO nID FROM sub WHERE subst_id = nSubstId;
    SELECT sub_desc INTO vDesc FROM subtyp WHERE id = nID;
EXCEPTION
    WHEN NO_DATA_FOUND OR TOO_MANY_ROWS THEN
         vDesc := '';
END; -- Procedure

/
