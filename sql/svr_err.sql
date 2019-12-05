set lines 1000 pages 1000 trims on verify off
break on "Day" Skip 2 on "User"
column "TIME" format a23
column "User" format a15
column db_name format a30
column "Day" format a10

spool user_errors.txt
select  to_char(error_datetime, 'Day') "Day",
	error_user "User",
        to_char(error_datetime, 'YYYY-MM-DD HH24:MI:SS') "TIME",
	db_name,
	error_stack
  from  servererror_log
 order 
 by     error_datetime;
spool off

edit user_errors.txt
