CREATE OR REPLACE TRIGGER update_aud
AFTER UPDATE
	ON *****

DECLARE

l_user 		varchar2(32);
l_owner		varchar2(32);
l_tablename	varchar2(64);
l_action	varchar2(16);
l_time		date;
l_ex		varchar2(128);

BEGIN

l_tablename := 'NYMED_USERS';
l_action := 'Update';
select USER into l_user from dual;
--SELECT OWNER INTO l_owner FROM dba_tables WHERE TABLE_NAME = 'NYMED_USERS';
l_owner := 'NYMED';
--select to_char(sysdate,'Day mm/dd/yyyy hh24:mi:ss') into l_time from dual;
select sysdate into l_time from dual;
DBMS_OUTPUT.put_line('Triggered');
INSERT INTO NYMED_AUD (USERNAME, OWNER, TABLENAME, ACTION, TIMESTAMP)
VALUES (l_user, l_owner, l_tablename, l_action, l_time);

END;
/

show errors;