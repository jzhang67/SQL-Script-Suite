SET verify OFF;
SET timing OFF;

DECLARE
	l_tblname	dba_tables.table_name%TYPE;
	l_ownrname	dba_tables.owner%TYPE;
	l_prCmd 	VARCHAR2(100);
	l_on		VARCHAR2(100);
	l_grantSel 	VARCHAR2(100);
	l_grantIn	VARCHAR2(100);
	l_grantUpd	VARCHAR2(100);
	l_grantDel	VARCHAR2(100);
	l_grantFull	VARCHAR2(100);
	l_dropCmd 	VARCHAR2(100);
	ex_noTables EXCEPTION;
	CURSOR c_tables is
		SELECT table_name FROM dba_tables 
			WHERE owner LIKE UPPER('%&owner%');

BEGIN
	OPEN c_tables;
	FETCH c_tables into l_tblname;
	IF (l_tblname IS NULL) THEN
		Raise ex_noTables;
	END IF;
	WHILE (c_tables%FOUND) LOOP
		
		l_dropCmd := 'DROP PUBLIC SYNONYM ' || l_tblname;
		EXECUTE IMMEDIATE (l_dropCmd);	

		SELECT owner INTO l_ownrname FROM dba_tables WHERE table_name = l_tblname;
		l_prCmd := 'CREATE PUBLIC SYNONYM ' || l_tblname || ' FOR ' || l_ownrname || '.' || l_tblname;
		DBMS_output.put_line(l_prCmd);
		EXECUTE IMMEDIATE (l_prCmd);
		
		l_on := ' on ' || l_ownrname || '.' || l_tblname || ' to ' || l_ownrname;
		
		l_grantSel 	:= 'GRANT SELECT ' || l_on || '_read';
		l_grantIn 	:= 'GRANT INSERT ' || l_on || '_insert';
		l_grantUpd	:= 'GRANT UPDATE ' || l_on || '_updt';
		l_grantDel	:= 'GRANT DELETE ' || l_on || '_delete';
		l_grantFull	:= 'GRANT SELECT, INSERT, UPDATE, DELETE ' || l_on || '_full';
		
		EXECUTE IMMEDIATE (l_grantSel);
		EXECUTE IMMEDIATE (l_grantIn);
		EXECUTE IMMEDIATE (l_grantUpd);
		EXECUTE IMMEDIATE (l_grantDel);
		EXECUTE IMMEDIATE (l_grantFull);

		FETCH c_tables into l_tblname;
	END LOOP;
	CLOSE c_tables;
	
EXCEPTION
	WHEN ex_noTables THEN
		DBMS_OUTPUT.put_line('No tables found!');
END;
/