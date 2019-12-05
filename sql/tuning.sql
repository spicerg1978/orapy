set echo off
rem
rem Script: tuning.sql
rem
rem Purpose: Check various statistics for the currently-running database
rem    to see if there are any database parameters or other modifications
rem    you could make to tune the database for faster response.
rem
rem Author: David Midgett <Dave.Midgett@EKU.EDU>
rem    Eastern Kentucky University
rem
rem Modifications: Stephen Rea <srea@uaex.edu>
rem    University of Arkansas Cooperative Extension Service
rem
rem Updates:
rem 7/16/03 - Added database SID to init.ora file names in output.  Show
rem    current values of init.ora parameters and other values in question.  
rem    Branch around multi-threaded server output if MTS not being used.
rem    Cleaned up the formatting of the output for consistency.
rem
set feedback off
column SID new_value SID
select substr(substr(global_name,1,30),1,instr(substr(global_name,1,30),'.')-1) SID
  from global_name;
prompt
rem Bypass multi-threaded server checks if there aren't any mts servers.
set termout off heading off
spool tmp~~~.sql
select '/*' from v$parameter where name = 'mts_servers' and value = '0';
spool off
@tmp~~~.sql
set termout on heading on
prompt ================================================================================;
prompt
prompt .                      Tuning Multi-Threaded Server
prompt
prompt ================================================================================;
prompt
prompt If SERVERS_HIGHWATER exceeds the MTS_SERVERS parameter, increase the number of
prompt MTS_SERVERS in the init&SID..ora file.
set heading off
select 'Current MTS_SERVERS number is ' || value from v$parameter where name = 'mts_servers';
set heading on
select * from v$mts;
-- */
!rm tmp~~~.sql
set termout on heading on
prompt ================================================================================;
prompt
prompt .                      Tuning The Library Cache
prompt
prompt ================================================================================;
prompt
prompt Library cache get/hit ratio for SQL AREA should be in high 90's. If not, there
prompt is room to improve the efficiency of your application.
select namespace, gets, gethits, gethitratio from v$librarycache;
prompt
prompt --------------------------------------------------------------------------------;
prompt
prompt If reloads-to-pins ratio is greater than .01, increase SHARED_POOL_SIZE in
prompt the init&SID..ora file.
set heading off
select 'Current SHARED_POOL_SIZE value is ' || value from v$parameter where name = 'shared_pool_size';
set heading on
select sum(pins) "Executions", sum(reloads) "LC Misses",
   sum(reloads)/sum(pins) "Ratio" from v$librarycache;
prompt
prompt --------------------------------------------------------------------------------;
prompt
prompt Data Dictionary Cache -- If ratio is greater than .15, consider increasing
prompt SHARED_POOL_SIZE in the init&SID..ora file.
set heading off
select 'Current SHARED_POOL_SIZE value is ' || value from v$parameter where name = 'shared_pool_size';
set heading on
select sum(gets) "Total Gets", sum(getmisses) "Total Get Misses",
   sum(getmisses)/sum(gets) "Ratio" from v$rowcache;
prompt
prompt --------------------------------------------------------------------------------;
prompt
prompt Packages you might want to consider pinning into the shared pool:
column owner format a12
column name format a25
column type format a15
set feedback on
select owner, name, type, loads, executions, sharable_mem
   from v$db_object_cache
   where kept = 'NO'
      and loads > 1 and executions > 50 and sharable_mem > 10000
      and type in ('PACKAGE', 'PACKAGE BODY', 'FUNCTION', 'PROCEDURE')
   order by loads desc;
set feedback off
prompt --------------------------------------------------------------------------------;
prompt
prompt Shared Pool Reserved space -- The goal is to have zero REQUEST_MISSES and
prompt REQUEST_FAILURES, so increase SHARED_POOL_RESERVED_SIZE in the init&SID..ora
prompt file if either of them are greater than 0.
set heading off
select 'Current SHARED_POOL_RESERVED_SIZE value is ' || value from v$parameter where name = 'shared_pool_reserved_size';
set heading on
select request_misses, request_failures, last_failure_size
   from v$shared_pool_reserved;
prompt
prompt ================================================================================;
prompt
prompt .                      Tuning the Data Dictionary Cache
prompt
prompt ================================================================================;
prompt
prompt If the gethitratio is greater than .15 -- increase the SHARED_POOL_SIZE
prompt parameter in the init&SID..ora file.
set heading off
select 'Current SHARED_POOL_SIZE value is ' || value from v$parameter where name = 'shared_pool_size';
set heading on
select sum(gets) "totl_gets", sum(getmisses) "totl_get_misses",
   sum(getmisses)/sum(gets) * 100 "gethitratio"
   from v$rowcache;
prompt
prompt ================================================================================;
prompt
prompt .                      Tuning The Data Buffer Cache
prompt
prompt ================================================================================;
prompt
prompt Goal is to have a Cache Hit Ratio greater than 90% -- if lower, increase value
prompt for DB_BLOCK_BUFFERS in the init&SID..ora file.
set heading off
select 'Current DB_BLOCK_BUFFERS value is ' || value from v$parameter where name = 'db_block_buffers';
set heading on
column value format 999,999,999,999
select name, value from v$sysstat where
   name in ('db block gets', 'consistent gets', 'physical reads');
select 1 - (phy.value / (cur.value + con.value)) "Cache Hit Ratio"
   from v$sysstat cur, v$sysstat con, v$sysstat phy
   where cur.name = 'db block gets'
      and con.name = 'consistent gets'
      and phy.name = 'physical reads';
prompt
prompt --------------------------------------------------------------------------------;
prompt
prompt If the number of free buffers inspected is high or increasing, consider
prompt increasing the DB_BLOCK_BUFFERS parameter in the init&SID..ora file.
set heading off
select 'Current DB_BLOCK_BUFFERS value is ' || value from v$parameter where name = 'db_block_buffers';
set heading on
column value format 999,999,999
select name, value from v$sysstat where name = 'free buffer inspected';
prompt
prompt --------------------------------------------------------------------------------;
prompt
prompt A high or increasing number of waits indicates that the db writer cannot keep
prompt up writing dirty buffers. Consider increasing the number of writers using the
prompt DB_WRITER_PROCESSES parameter in the init&SID..ora file.
set heading off
select 'Current DB_WRITER_PROCESSES value is ' || value from v$parameter where name = 'db_writer_processes';
set heading on
select event, total_waits from v$system_event where event in
   ('free buffer waits', 'buffer busy waits');
prompt
prompt --------------------------------------------------------------------------------;
prompt
prompt If the LRU Hit percentage is less than 99%, consider adding more
prompt DB_WRITER_PROCESSES and increasing the DB_BLOCK_LRU_LATCHES parameter
prompt in the init&SID..ora file.
set heading off
select 'Current DB_WRITER_PROCESSES value is ' || v1.value || chr(10) ||
   'Current DB_BLOCK_LRU_LATCHES value is ' || v2.value
   from v$parameter v1,v$parameter v2
   where v1.name = 'db_writer_processes' and v2.name = 'db_block_lru_latches';
set heading on
select name, 100 - (sleeps/gets * 100) "LRU Hit%" from v$latch
   where name = 'cache buffers lru chain';
prompt
prompt ================================================================================;
prompt
prompt .                      Tuning The Redo Log Buffer
prompt
prompt ================================================================================;
prompt
prompt Ideally, there should never be a wait for log buffer space. Increase LOG_BUFFER
prompt in the init&SID..ora file if the selection below doesn't show "no rows selected".
set heading off
select 'Current LOG_BUFFER size is ' || value from v$parameter where name = 'log_buffer';
set heading on
set feedback on
select sid, event, state from v$session_wait
   where event = 'log buffer space';
set feedback off
prompt --------------------------------------------------------------------------------;
prompt
prompt If there are any Wait events because of log switches, consider increasing the
prompt size of the redo log files.
set heading off
select 'Current size of redo log files is ' || bytes || ' bytes' from v$log where rownum = 1;
set heading on
column event format a30
select event, total_waits, time_waited, average_wait from v$system_event
   where event like 'log file switch completion%';
prompt
prompt ================================================================================;
prompt
prompt Tables with Chain count greater than 10% of the number of rows:
set feedback on
select owner, table_name, num_rows, chain_cnt, chain_cnt/num_rows "Percent"
   from dba_tables where (chain_cnt/num_rows) > .1 and num_rows > 0;
set feedback off
prompt ================================================================================;
prompt
prompt .                             Tuning Sorts
prompt
prompt ================================================================================;
prompt
prompt The ratio of disk sorts to memory sorts should be less than 5%. Consider
prompt increasing the SORT_AREA_SIZE parameter in the init&SID..ora file. You
prompt might also consider setting up separate temp tablespaces for frequent
prompt users of disk sorts.
set heading off
select 'Current SORT_AREA_SIZE value is ' || value from v$parameter where name = 'sort_area_size';
set heading on
select disk.value "Disk", mem.value "Mem", (disk.value/mem.value) * 100 "Ratio"
   from v$sysstat mem, v$sysstat disk
   where mem.name = 'sorts (memory)'
      and disk.name = 'sorts (disk)';
prompt
prompt ================================================================================;
prompt
prompt .                      Tuning Rollback segments
prompt
prompt ================================================================================;
prompt
prompt If ratio of waits to gets is greater than 1%, you need more rbs segments.
set heading off
select 'Current number of rollback segments is ' || count(*) from dba_rollback_segs
   where status = 'ONLINE' and owner = 'PUBLIC';
set heading on
select sum(waits)*100/sum(gets) "Ratio", sum(waits) "Waits", sum(gets) "Gets"
   from v$rollstat;
prompt
prompt --------------------------------------------------------------------------------;
prompt
prompt Rollback segment waits -- any waits indicates need for more segments.
set heading off
select 'Current number of rollback segments is ' || count(*) from dba_rollback_segs
   where status = 'ONLINE' and owner = 'PUBLIC';
set heading on
select * from v$waitstat where class = 'undo header';
column event format a25
prompt
prompt --------------------------------------------------------------------------------;
prompt
prompt Rollback segment waits for transaction slots -- any waits indicates need for
prompt more segments.
set heading off
select 'Current number of rollback segments is ' || count(*) from dba_rollback_segs
   where status = 'ONLINE' and owner = 'PUBLIC';
set heading on
set feedback on
select * from v$system_event where event = 'undo segment tx slot';
set feedback off
prompt --------------------------------------------------------------------------------;
prompt
prompt Rollback contention -- should be zero for all rbs's.
column name format a10
select n.name,round (100 * s.waits/s.gets) "%contention"
    from v$rollname n, v$rollstat s
    where n.usn = s.usn;
prompt
clear columns
set feedback on echo on
