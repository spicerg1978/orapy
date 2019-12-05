/* 
usage @quick_trace level script_to_trace.sql

additional note for starting tracing:

exec dbms_system.ksdddt; -- show the wall clock time compared to the tim value
exec dbms_system.ksdwrt; -- write a custom message to the trace file

dbms_system.ksdwrt(dest	number, tst varchar2);

dest
====
1 = trace file  
2 = alter log
3 = both

*/
set verify off feedback off termout off newpage 0 pages 0 lines 1000
alter session set events '10046 trace name context forever, level &1';
exec dbms_system.ksdwrt(1, 'Quick Trace at level &1, Script: &2');

@&2

alter session set events '10046 trace name context off';


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
         where sid 	= (select distinct sid from v$mystat);                   
                    
	select lower(name) 
	  into v_database
	  from v$database;         
                    
         select p.spid 
           into v_pid
           from v$process p, v$session s 
          where p.addr = s.paddr 
            and s.sid = (select distinct sid from v$mystat);
   
   
   
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
			       fields terminated by '||chr(39)||'~!~!~$'||chr(39)||' 
         		       missing field values are null 
			       )
			       location ('||chr(39)||v_file_name||chr(39)||')
			     )
			     reject limit unlimited';


end;
/

set trims on pages 10000 lines 10000 heading off

host del h:\sqldump\quick_trace.out

exec dbms_lock.sleep(3);
spool h:\sqldump\quick_trace.out
select * from temp_trace;
spool off
edit  h:\sqldump\quick_trace.out
set termout on feedback on heading on