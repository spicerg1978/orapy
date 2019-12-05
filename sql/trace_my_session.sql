set verify off feedback off
cl scr
prompt ==========================
prompt ==========================

Prompt
Prompt T R A C E   M Y   S E S S I O N
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


select sid your_sid, serial# your_serial#
  from v$session
 where sid = (select distinct sid from v$mystat);

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

alter session set events '&trace trace name context forever, level &level';

set define off
@&sql_file
set define on

alter session set events '&trace trace name context off';


declare

v_udump_dest     varchar2(100);
v_username       varchar2(45);
v_pid            varchar2(45);
v_full_path      varchar2(200);
v_database       varchar2(8);
v_file_name 	 varchar2(30);
v_os		 pls_integer := 0;

begin

	select instr(value,'\') 
	  into v_os
	  from v$parameter 
	 where name = 'user_dump_dest';

	select value 
	  into v_udump_dest
	  from v$parameter
	 where name = 'user_dump_dest';
                    
	select username 
          into v_username
	  from v$session
         where serial# = &serial
           and sid = &sid;                   
                    
	select lower(name) 
	  into v_database
	  from v$database;         
                    
         select p.spid 
           into v_pid
           from v$process p, v$session s 
          where p.addr=s.paddr 
            and s.sid = &sid;
   
   
   
	     if v_os != 0 
	     
	     then  -- it's on windows

			v_file_name  := v_database||'_ora_'||v_pid||'.trc';
			v_full_path   := v_udump_dest||'\'||v_file_name;
			dbms_output.put_line(chr(10));
			dbms_output.put_line('Trace file generated: '||v_file_name);

	     else  -- we're on unix
	     
			v_file_name  := v_database||'_ora_'||v_pid||'.trc';
			v_full_path   := v_udump_dest||'/'||v_file_name;
			dbms_output.put_line(chr(10));
			dbms_output.put_line('Trace file generated: '||v_file_name);
	     
	     end if;


	begin
	execute immediate 'drop table temp_trace';
	exception
	when others then null;
	end;


	execute immediate '
		create table temp_trace 
		       (text	varchar2(200))
			organization EXTERNAL
			     ( 
			       TYPE ORACLE_LOADER 
			       DEFAULT DIRECTORY traces
			       ACCESS PARAMETERS
			       (
			       records delimited by newline
			       badfile   '||chr(39)||'trace.bad'||chr(39)||'
			       logfile 	 '||chr(39)||'trace.log'||chr(39)||'
			       )
			       location ('||chr(39)||v_file_name||chr(39)||')
			     )
			     reject limit unlimited';


end;
/

set trims on pages 10000 lines 10000 termout off
spool c:\temp_trace.out
select * from temp_trace;
spool off
edit  c:\temp_trace.out
set termout on feedback on