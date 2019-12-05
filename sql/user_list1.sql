/* include the values from dbms_application_info */

set lines 1000
column osuser format a14
column username format a15
--column machine format a25
--column login format a20
column module format a30
column action format a100
column client_info format a20

select username, osuser, status, --machine, 
       --to_char(logon_time, 'YYYY-MM-DD HH24:MI:SS') "LOGIN", 
       module, action, client_info
  from v$session
 where username is not null
   and sid != (select distinct sid from v$mystat)
 order by logon_time
/

clear col

