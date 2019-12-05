cl scr
/* 

  This script will set tracing on in another session
  
  Author:Steve Wilkins
  Date: Dec 2004

*/

set lines 1000
column osuser format   a13
column username format a15
column status format   a10
column machine format  a25
column login format    a20
column module format   a25
column sid format      9999
column serial# format  99999


select username, osuser, status, machine, sid, serial#,
       to_char(logon_time, 'YYYY-MM-DD HH24:MI:SS') "LOGIN", module
  from v$session
 where username is not null
 and sid != (select distinct sid from v$mystat)
 order by logon_time;
 
prompt ==========================
prompt ==========================

Prompt
Prompt T R A C E   S E S S I O N
Prompt
Prompt Event numbers
Prompt =============
Prompt 
Prompt # 10032 [sort tracing]
Prompt # 10053 [optimiser],
Prompt # 10060 [Query Transformation Tracing],
Prompt # 10128 [Partition Tracing],
Prompt # 10391 [Parallel Query],
Prompt # 10730 [SQL statemenet tracing with row level security],
Prompt # 10046 [Extended sql trace]
Prompt
Prompt Levels
Prompt ======
Prompt 
Prompt # 0  [off]
Prompt # 1  [sql]
Prompt # 4  [binds]
Prompt # 8  [timing]
Prompt # 12 [binds+timing]

prompt ==========================
prompt ==========================

set feedback on

prompt
ACCEPT sid CHAR PROMPT    "Enter sid number : "
prompt

prompt
ACCEPT serial CHAR PROMPT "Enter serial number : "
prompt

prompt
ACCEPT trace CHAR PROMPT  "Enter trace event : " default 10046
prompt

prompt
ACCEPT level CHAR PROMPT  "Enter trace level : " default 12
prompt

prompt 
pause  Setting &trace at level &level for &sid, &serial press RETURN to continue....

exec wilkinss1.set_trace_in_session(&sid, &serial, &trace, &level);

