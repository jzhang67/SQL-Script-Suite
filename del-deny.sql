CREATE OR REPLACE TRIGGER del_deny
BEFORE DELETE
	ON *****
	
DECLARE

l_user		varchar2(32);
l_roles		varchar2(64);
/*CURSOR c_roles IS
	SELECT granted_role FROM dba_role_privs
		WHERE grantee LIKE l_user;
l_roles 	dba_role_privs.granted_role%TYPE;
l_first		varchar2(32);
l_isNot		BOOLEAN := TRUE;
*/

BEGIN

select USER into l_user from dual;
select granted_role into l_roles from dba_role_privs
	where grantee = l_user;
IF (l_roles = 'DBA') THEN
	RETURN;
ELSE
	raise_application_error(-20001, 'Records cannot be deleted.');
END IF;


/*OPEN c_roles;
FETCH c_roles INTO l_roles;
l_first := l_roles;
IF (l_first = 'DBA') THEN
	l_isNot := FALSE;
END IF;
WHILE (c_roles%FOUND) LOOP
	FETCH c_roles INTO l_roles;
	IF(l_roles = 'DBA') THEN
		l_isNot := FALSE;
	END IF;
	IF(l_roles = l_first) THEN
		BREAK;
	END IF;
	END LOOP;
IF(l_isNot) THEN
	raise_application_error(-20001, 'Records cannot be deleted');
END IF;
CLOSE c_roles;
*/


END;
/

show errors;