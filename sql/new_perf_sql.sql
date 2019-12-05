--find_sql_stats.sql

set verify off
set pagesize 999
col username format a13
col prog format a22
col sql_text format a35
col sid format 999
col child_number format 99999 heading CHILD
col ocategory format a10
col execs format 9,999,999
col execs_per_sec format 999,999.99
col etime format 9,999,999.99
col avg_etime format 99,999.99
col cpu format 9,999,999
col avg_cpu  format 99,999.99
col pio format 9,999,999
col avg_pio format 99,999.99
col lio format 9,999,999
col avg_lio format 9,999,999
col ibs format a3
col iba format a3
col ish format a3

select sql_id, child_number, plan_hash_value,
is_bind_sensitive ibs,
is_bind_aware iba,
is_shareable ish,
executions execs,
rows_processed ,
-- executions/((sysdate-to_date(first_load_time,'YYYY-MM-DD/HH24:MI:SS'))*(24*60*60)) execs_per_sec,
-- elapsed_time/1000000 etime,
(elapsed_time/1000000)/decode(nvl(executions,0),0,1,executions) avg_etime,
-- cpu_time/1000000 cpu,
(cpu_time/1000000)/decode(nvl(executions,0),0,1,executions) avg_cpu,
-- disk_reads pio,
disk_reads/decode(nvl(executions,0),0,1,executions) avg_pio,
-- buffer_gets lio,
buffer_gets/decode(nvl(executions,0),0,1,executions) avg_lio,
sql_text
from v$sql s
where 
 pasing_schema_name = 'TRIDPERF3'--sql_text like nvl('&sql_text',sql_text)
--and sql_text not like '%from v$sql where sql_text like nvl(%'
--and sql_id like nvl('&sql_id',sql_id)
and is_bind_aware like nvl('&is_bind_aware',is_bind_aware)
order by sql_id, child_number
/

--child_loat_time.sql
set verify off
set pages 9999
set lines 150
select * from table(dbms_xplan.display_cursor('&sql_id','&child_no',''))
/

--diff_stats.sql
select report, maxdiffpct from
table(dbms_stats.diff_table_stats_in_history('&owner','&table_name',
systimestamp-&days_ago))
/

--flush_sql.sql

set serveroutput on
set pagesize 9999
set linesize 155
var name varchar2(50)
accept sql_id -
       prompt 'Enter value for sql_id: '

BEGIN

select address||','||hash_value into :name
from v$sqlarea
where sql_id like '&&sql_id';

dbms_shared_pool.purge(:name,'C',1);

END;
/

undef sql_id
undef name


--find_sql_by_cost.sql

select distinct parsing_schema_name, sa.sql_id, sp.plan_hash_value, cost
from v$sql_plan sp, v$sqlarea sa
where sp.sql_id = sa.sql_id
and parsing_schema_name like nvl('&parsing_user',parsing_schema_name)
and cost like nvl(to_number('&cost'),to_number(cost))
and sp.plan_hash_value like nvl('&plan_hash_value',sp.plan_hash_value)
and parent_id is null
and parsing_schema_name not in ('SYS','SYSTEM','DBSNMP','SYSMAN')
order by 4 desc
/

-- find_sql.sql

set verify off
set pagesize 999
col username format a13
col prog format a22
col sql_text format a41
col sid format 999
col child_number format 99999 heading CHILD
col ocategory format a10
col avg_etime format 9,999,999.99
col etime format 9,999,999.99

select sql_id, child_number, plan_hash_value plan_hash, executions execs, elapsed_time/1000000 etime,
(elapsed_time/1000000)/decode(nvl(executions,0),0,1,executions) avg_etime, u.username,
sql_text
from v$sql s, dba_users u
where upper(sql_text) like upper(nvl('&sql_text',sql_text))
and sql_text not like '%from v$sql where sql_text like nvl(%'
and sql_id like nvl('&sql_id',sql_id)
and u.user_id = s.parsing_user_id
/



select * from
table(dbms_stats.diff_table_stats_in_history('TRIDPERF3','PKA_UPDATE_TRACKING',systimestamp-1))
/