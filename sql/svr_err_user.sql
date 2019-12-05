set lines 1000 pages 1000 trims on verify off
break on "Day" Skip 2 on "Day"
column "TIME" format a23
column "User" format a15
column db_name format a30
column "Day" format a10

prompt
ACCEPT username CHAR PROMPT    "Enter username : "
prompt

spool user_errors.txt
select  to_char(error_datetime, 'Day') "Day",
        to_char(error_datetime, 'YYYY-MM-DD HH24:MI:SS') "TIME",
	error_user "User",
	db_name,
	error_stack
  from SERVERERROR_LOG
 where error_user = upper('&username')
 order by error_datetime;
spool off

edit user_errors.txt
