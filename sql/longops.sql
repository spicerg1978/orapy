set serveroutput on echo off feedback on verify off

set lines 200
column osuser format a25
column username format a15
column machine format a30
column login format a20

cl scr

prompt session long operations...

/* List of sessions that can be traced */
select username, sid, serial#, osuser, status, to_char(logon_time, 'YYYY-MM-DD HH24:MI:SS') "LOGIN"
  from v$session
 where type ='USER'
   and username is not null
   and sid != (select distinct sid from v$mystat)
 order by login;

clear col


set lines 200
column "Complete" 	format 9,999,999
column "Remaining" 	format 9,999,999
column "Object" 	format a5
column "Operation" 	format a20
column "Remaining" 	format 9,999
column "So Far" 	format 9,999
column "Start time" 	format a20

/* Enter the sid and seial number of the session to trace */
ACCEPT SID prompt 'please enter the sid: '
ACCEPT SERIAL prompt 'please enter the serial#: '

SELECT 
	a.SOFAR 					"Complete",
	(a.totalwork - (a.sofar)) 			"Remaining", 
	a.OPNAME 					"Operation",
	c.object_name 					"Object",
	to_char(a.start_time, 'YYYY-MM-DD HH24:MI:SS') 	"Start time",
	a.elapsed_seconds                               "So Far",
	TIME_REMAINING                                  "Remaining"
 FROM   v$session_longops a, v$session b, dba_objects c
WHERE   a.sid=b.sid and a.serial# = b.serial#  -- join there to filter out history
  and   a.target = c.object_id
  and   a.SID=&SID AND a.SERIAL#=&SERIAL
  and   a.sid != (select distinct sid from v$mystat)
order   by 6 desc
/
