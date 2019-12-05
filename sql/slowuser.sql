set lines 1000 pages 1000 verify off feedback on arraysize 2000
cl scr

prompt ========================================
prompt
prompt U S E R   T R A C K E R
prompt
prompt ========================================
prompt
prompt

col sid          	format 999 
col osuser 		format a13
col username 		format a15
col machine 		format a25
col login 		format a20
col module	 	format a25
col action 		format a100
col client_info 	format a20

prompt -- ========================================
prompt -- Users
prompt -- ========================================

select username, sid, osuser, machine, 
       to_char(logon_time, 'YYYY-MM-DD HH24:MI:SS') "LOGIN", 
       module, action, client_info
  from v$session
 where username is not null
   and status != 'INACTIVE'
   and sid != (select distinct sid from v$mystat)
 order by logon_time;

prompt
ACCEPT username prompt 'user name UPPER CASE: '
prompt

prompt -- ========================================
prompt -- Waiting for?
prompt -- ========================================

col sid          	format 999          
col seq#         	format 99999   
col event        	format a20         
col "P1 Text : Value"   format a30                         
col "P2 Text : Value"   format a30       
col "P3 Text : Value"   format a30 
col wait_time    	format 999999         
col seconds_in_wait   	format 99999999   
col state        	format a10
col event 		format a30            
col total_waits 	format 999999999         
col total_timeouts 	format 999999999
col time_waited 	format  9999999999
col average_wait 	format  999999
col max_wait 		format  999999
col username 		format a15
col sql_text 		format a60
col sql_text 		format a50

select  b.username,	
        --  b.sid, 
 	a.event,
 	a.seconds_in_wait,
 	(case nvl(a.p1text, 'x')
 	 when 'x' then null
 	 else a.p1text||': '||a.p1
 	  end)  				"P1 Text : Value",
 	(case nvl(a.p2text, 'x')
 	 when 'x' then null
 	 else a.p2text||': '||a.p2
 	  end)  				"P2 Text : Value",
 	(case nvl(a.p3text, 'x')
 	 when 'x' then null
 	 else a.p3text||': '||a.p3
 	  end)  				"P3 Text : Value",
 	(case to_char(a.wait_time)
 	 when '0' then 'Waiting'
 	 else to_char(a.wait_time)
 	  end)  				wait_time
  from v$session_wait a, v$session b 
 where a.sid = b.sid
   and b.username is not null
   and b.username = '&username';

prompt -- ========================================
prompt -- What has he waited for since login?
prompt -- ========================================

col event 		format a40

select 
	username, 
	s.sid,
	s.serial#, 
	event, 
	total_waits
from v$session_event, v$session s
where v$session_event.sid = s.sid
and type ='USER'
and s.username = '&username'
order by total_waits desc;

prompt -- ========================================
prompt -- Running SQL?
prompt -- ========================================

select 
	s.username,
	q.sql_text, 
	q.buffer_gets,  
	q.rows_processed, 
	q.disk_reads 
from v$sql q, v$session s
where s.sql_address = q.address
and s.username = '&username'
order by buffer_gets;


prompt -- ========================================
prompt -- Execution plan?
prompt -- ========================================


set verify off
set lines 1000
set pages 1000

set recsep off
break on sq page

col SQ		noprint new_value sql_text
col ID		format a6	heading "ID"
col PT		format 99	heading "Parent"
col OB		format a20	heading "Object"
col OP		format a18	heading "Operation"
col OT		format a30	heading "Options"
col PS		format 999	heading "Pos"
col CD		format 999	heading "Rows"
col CP		format 99999	heading "Cpu"	
col IO		format 999	heading "IO"

ttitle "Statement:" sql_text

select s.sql_text		 			SQ,
       lpad(to_char(p.id),depth) 			ID,
       p.parent_id 					PT,
       decode(p.id,0,'Cost: '||p.cost,p.object_name) 	OB,
       p.operation 					OP,
       p.options 					OT,
       to_number(decode(p.id,0,null,p.position)) 	PS,
       p.cardinality 					CD,
       p.cpu_cost 					CPU,
       p.io_cost 					IO
  from v$sql s, v$session sess, v$sql_plan p
 where p.address = s.address
   and p.hash_value = s.hash_value
   and p.child_number = s.child_number
   and sess.sql_address = s.address
   and sess.username = '&username';
   
set recsep wrap

prompt -- ========================================
prompt -- Session I/O
prompt -- ========================================

select
	username,                    
	io.sid,
	serial#,
	block_gets + consistent_gets "COMBINED GETS",        
	physical_reads         
from v$sess_io io, v$session
where io.sid =v$session.sid
and v$session.username = '&username'
order by 4;
