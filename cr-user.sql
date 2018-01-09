SET TERMOUT 	ON;
SET TRIMSPOOL 	ON;
SET SERVEROUTPUT ON SIZE 1000000;

SET ECHO		OFF;
--SET FEEDBACK 	OFF;
SET VERIFY 		OFF;
SET HEADING 	OFF;

PROMPT;
ACCEPT USER_OLD PROMPT 'Enter existing User ID: ';
PROMPT;
ACCEPT USER_NEW PROMPT 'Enter new User ID: ';

DECLARE
	
	TYPE r_users 	IS RECORD (
		rs_dts		dba_users.DEFAULT_TABLESPACE%TYPE,
		rs_tts		dba_users.TEMPORARY_TABLESPACE%TYPE,
		rs_pf		dba_users.PROFILE%TYPE
	);

	TYPE r_tsquota IS RECORD (
		rs_tsn		dba_ts_quotas.TABLESPACE_NAME%TYPE,
		rs_mxb		dba_ts_quotas.MAX_BYTES%TYPE
	);

	TYPE r_syspr	IS RECORD (
		rs_sysprivs	dba_sys_privs.PRIVILEGE%TYPE
	);
	
	TYPE r_tabpr	IS RECORD (
		rs_ownr		dba_tab_privs.OWNER%TYPE,
		rs_tblnm	dba_tab_privs.TABLE_NAME%TYPE,
		rs_tblprivs	dba_tab_privs.PRIVILEGE%TYPE	
	);

	TYPE r_rlpr		IS RECORD(
		rs_gtdrl	dba_role_privs.GRANTED_ROLE%TYPE
	);	
	
	CURSOR c_users IS
		SELECT DEFAULT_TABLESPACE, TEMPORARY_TABLESPACE, PROFILE
			FROM dba_users
				WHERE USERNAME = UPPER('&USER_OLD');
			
	CURSOR c_tsquota IS
		SELECT TABLESPACE_NAME, MAX_BYTES
			FROM dba_ts_quotas
				WHERE USERNAME = UPPER('&USER_OLD');

	CURSOR c_sysprivs IS
		SELECT PRIVILEGE
			FROM dba_sys_privs
				WHERE GRANTEE = UPPER('&USER_OLD');
	
	CURSOR c_tabprivs IS
		SELECT OWNER, TABLE_NAME, PRIVILEGE
			FROM dba_tab_privs
				WHERE GRANTEE = UPPER('&USER_OLD');
	
	CURSOR c_roleprivs IS
		SELECT GRANTED_ROLE
			FROM dba_role_privs
				WHERE GRANTEE = UPPER('&USER_OLD');
	
	l_users			r_users;
	l_tsquota		r_tsquota;
	l_syspr			r_syspr;
	l_tabpr			r_tabpr;
	l_rlpr			r_rlpr;
	l_dfuser		VARCHAR2(200);
	l_dfquota		VARCHAR2(200);
	l_dfsysprv		VARCHAR2(200);
	l_dftabprv		VARCHAR2(200);
	l_dfrlprv		VARCHAR2(200);
	l_temp			VARCHAR2(200);
	l_temp1			VARCHAR2(200);
	l_start			VARCHAR2(200);
	l_tst			VARCHAR2(200);
	l_same			VARCHAR2(200);
	l_tst1			VARCHAR2(200);
	
BEGIN
	
	OPEN 	c_users;
	FETCH 	c_users 	INTO l_users;
	
	OPEN 	c_tsquota;	
	FETCH 	c_tsquota 	INTO l_tsquota;
	
	OPEN 	c_sysprivs;
	FETCH 	c_sysprivs	INTO l_syspr;
	l_temp		:= l_syspr.rs_sysprivs;
	l_start 	:= l_syspr.rs_sysprivs;
	
	OPEN 	c_tabprivs;
	FETCH 	c_tabprivs	INTO l_tabpr;
	
	OPEN  	c_roleprivs;
	FETCH 	c_roleprivs	INTO l_rlpr;
	l_temp1	:= l_rlpr.rs_gtdrl;
	
	l_dfuser := 'CREATE USER '||'&USER_NEW'||' IDENTIFIED BY '||'&USER_NEW'||'$123'||'
DEFAULT TABLESPACE '||l_users.rs_dts||'
TEMPORARY TABLESPACE '||l_users.rs_tts||'
QUOTA 10M ON '||l_users.rs_dts||'
PROFILE '||l_users.rs_pf;
	
	l_tst := l_syspr.rs_sysprivs;
	DBMS_OUTPUT.put_line('***'||l_tst);
	FETCH c_sysprivs INTO l_syspr;
	l_temp := l_temp||', '||l_syspr.rs_sysprivs;
	
	WHILE(c_sysprivs%FOUND) LOOP
		FETCH c_sysprivs INTO l_syspr;
		DBMS_OUTPUT.put_line('***'||l_same);
		DBMS_OUTPUT.put_line('***'||l_tst);

		l_same := l_syspr.rs_sysprivs;
		IF l_tst = l_same THEN
			EXIT;
		END IF;
		IF l_start = l_same THEN
			EXIT;
		END IF;
		l_temp := l_temp||', '||l_syspr.rs_sysprivs;
		l_tst := l_syspr.rs_sysprivs;
	END LOOP;
	
/*	l_tst1 := l_rlpr.rs_gtdrl;
	FETCH c_roleprivs INTO l_rlpr;
	l_temp1 := l_temp1||', '||l_rlpr.rs_gtdrl;
	*/
	WHILE(c_roleprivs%FOUND) LOOP
		l_dfrlprv := 'GRANT '||l_temp1||' TO '||'&USER_NEW';
		FETCH c_roleprivs INTO l_rlpr;
		IF l_tst1 = l_rlpr.rs_gtdrl THEN
			EXIT;
		END IF;
--		l_temp1 := l_temp1||', '||l_rlpr.rs_gtdrl;
	END LOOP;
	
	l_dfsysprv	:= 'GRANT '||l_temp||' TO '||'&USER_NEW';
	l_temp := null;
	
	DBMS_OUTPUT.put_line(l_dfuser);
	EXECUTE IMMEDIATE (l_dfuser);

	DBMS_OUTPUT.put_line(l_dfsysprv);
	EXECUTE IMMEDIATE (l_dfsysprv);
	
	DBMS_OUTPUT.put_line(l_dfrlprv);
	EXECUTE IMMEDIATE (l_dfrlprv);
	
	WHILE(c_tabprivs%FOUND) LOOP
		l_dftabprv := 'GRANT '||l_tabpr.rs_tblprivs||' ON '||l_tabpr.rs_ownr||'.'||l_tabpr.rs_tblnm||' TO '||'&USER_NEW';
		DBMS_OUTPUT.put_line(l_dftabprv);
		EXECUTE IMMEDIATE (l_dftabprv);
		FETCH c_tabprivs INTO l_tabpr;
	END LOOP;
	
	
	CLOSE	c_users;
	CLOSE	c_tsquota;
	CLOSE	c_sysprivs;
	CLOSE	c_tabprivs;
	CLOSE	c_roleprivs;

END;
/

	--alter user default role all;