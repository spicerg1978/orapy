/* Shows the sql text that is executing for a given user */

prompt
prompt users currently active...
prompt

set echo off verify off lines 170
column osuser format a15
column username format a15
column machine format a20
column login format a20

select username, osuser, status, machine, to_char(logon_time, 'YYYY-MM-DD HH24:MI:SS') "LOGIN", MODULE from v$session
where username is not null
  and status ='ACTIVE'
order by logon_time
/

clear col

prompt
prompt SQL text running...
prompt

select sid, username, sql_text stext
  from v$session s, v$sqltext t
 where s.sql_address = t.address
   and s.sql_hash_value = t.hash_value
   and username = upper('&user')
order by SID, piece asc
/