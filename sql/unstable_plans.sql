SQL> @unstable_plans

break on plan_hash_value on startup_time skip 1
 select * from (
    select sql_id, sum(execs), min(avg_etime) min_etime, max(avg_etime) max_etime, stddev_etime/min(avg_etime) norm_stddev
       from (
           select sql_id, plan_hash_value, execs, avg_etime,
                  stddev(avg_etime) over (partition by sql_id) stddev_etime
             from (
                   select sql_id, plan_hash_value,
                          sum(nvl(executions_delta,0)) execs,
                          (sum(elapsed_time_delta)/decode(sum(nvl(executions_delta,0)),0,1,sum(executions_delta))/1000000) avg_etime
   			   -- sum((buffer_gets_delta/decode(nvl(buffer_gets_delta,0),0,1,executions_delta))) avg_lio
                     from DBA_HIST_SQLSTAT S, DBA_HIST_SNAPSHOT SS
                     where ss.snap_id = S.snap_id
                       and sql_id in (select sql_id 
                                        from V$sql
                       		       where (sql_text like 'SELECT /*+ FIRST_ROWS (100) */%message_audit%' or sql_text like 'SELECT /*+ FIRST_ROWS (100) */%MESSAGE_AUDIT%')
                                           or upper(sql_text) like 'SELECT * FROM TABLE%'
                                        and parsing_schema_name in ('TRIDCURR','TRIDLIVE','TRIDPERF3', 'TRIDPERF2'))
                     group by sql_id, plan_hash_value)
                   )
              group by sql_id,stddev_etime)
             )
  order by last_active_time
/




 select * from (
    select sql_id, sum(execs), min(avg_etime) min_etime, max(avg_etime) max_etime, stddev_etime/min(avg_etime) norm_stddev
    from (
    select sql_id, plan_hash_value, execs, avg_etime,
    stddev(avg_etime) over (partition by sql_id) stddev_etime
    from (
    select sql_id, plan_hash_value,
    sum(nvl(executions_delta,0)) execs,
    (sum(elapsed_time_delta)/decode(sum(nvl(executions_delta,0)),0,1,sum(executions_delta))/1000000) avg_etime
   -- sum((buffer_gets_delta/decode(nvl(buffer_gets_delta,0),0,1,executions_delta))) avg_lio
   from DBA_HIST_SQLSTAT S, DBA_HIST_SNAPSHOT SS
   where ss.snap_id = S.snap_id
   and ss.instance_number = S.instance_number
   and executions_delta > 0
   and elapsed_time_delta > 0
   group by sql_id, plan_hash_value
   )
   )
   group by sql_id, stddev_etime
   )
   where norm_stddev > nvl(to_number('&min_stddev'),2)
   and max_etime > nvl(to_number('&min_etime'),.1)
   order by norm_stddev
 /









   and ss.instance_number = S.instance_number
   and executions_delta > 0
   and elapsed_time_delta > 0
   group by sql_id, plan_hash_value
   )
   )
   group by sql_id, stddev_etime
   )
   where norm_stddev > nvl(to_number('&min_stddev'),2)
   and max_etime > nvl(to_number('&min_etime'),.1)
   order by norm_stddev
   /
   
   
 SQL> @find_sql
  select sql_id, child_number, plan_hash_value plan_hash, executions execs,
        (elapsed_time/1000000)/decode(nvl(executions,0),0,1,executions) avg_etime,
        buffer_gets/decode(nvl(executions,0),0,1,executions) avg_lio,
       sql_text
     from v$sql s
     where upper(sql_text) like upper(nvl('&sql_text',sql_text))
     and sql_text not like '%from v$sql where sql_text like nvl(%'
     and sql_id like nvl('&sql_id',sql_id)
     order by 1, 2, 3
 /
 
 SQL> @awr_plan_stats
  break on plan_hash_value on startup_time skip 1
  select sql_id, plan_hash_value, sum(execs) execs, sum(etime) etime, sum(etime)/sum(execs) avg_etime, sum(lio)/sum(execs) avg_lio
     from (
     select ss.snap_id, ss.instance_number node, begin_interval_time, sql_id, plan_hash_value,
     nvl(executions_delta,0) execs,
     elapsed_time_delta/1000000 etime,
     (elapsed_time_delta/decode(nvl(executions_delta,0),0,1,executions_delta))/1000000 avg_etime,
     buffer_gets_delta lio,
     (buffer_gets_delta/decode(nvl(buffer_gets_delta,0),0,1,executions_delta)) avg_lio
     from DBA_HIST_SQLSTAT S, DBA_HIST_SNAPSHOT SS
    where sql_id = nvl('&sql_id','4dqs2k5tynk61')
    and ss.snap_id = S.snap_id
    and ss.instance_number = S.instance_number
    and executions_delta > 0
    )
    group by sql_id, plan_hash_value
    order by 5
   /
 
 
 SQL> @awr_plan_change
  break on plan_hash_value on startup_time skip 1
   select ss.snap_id, ss.instance_number node, begin_interval_time, sql_id, plan_hash_value,
          nvl(executions_delta,0) execs,
         (elapsed_time_delta/decode(nvl(executions_delta,0),0,1,executions_delta))/1000000 avg_etime,
         (buffer_gets_delta/decode(nvl(buffer_gets_delta,0),0,1,executions_delta)) avg_lio
    from DBA_HIST_SQLSTAT S, DBA_HIST_SNAPSHOT SS
   where sql_id = nvl('&sql_id','4dqs2k5tynk61')
     and ss.snap_id = S.snap_id
     and ss.instance_number = S.instance_number
     and executions_delta > 0
   order by 1, 2, 3
  /
 
 