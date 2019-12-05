/* include the values from dbms_application_info */

set lines 1000
column "DisplayName" format a30
column "EmailAddress" format a40
column login format a20
column machine format a25
column status format a10

select  a."DisplayName",
	a."EmailAddress",
        to_char(b.logon_time, 'YYYY-MM-DD HH24:MI:SS') "LOGIN",
        b.status, b.machine
  from  users@security_db a, v$session b
 where  (upper(substr(a."NTLogon", (instr(upper(a."NTLogon"), '\')+1), 10))) = upper(b.osuser)
   and  a."NTLogon" is not null
/

clear col