AWR sqlsnapshot

select c1.SNAP_ID, max(to_char(begin_interval_time,'dd-mm-yyyy hh24:mi')) as Begin,
       sum(executions_delta) as Executions,
       sum(elapsed_time_delta) as ElapsedTime,
       round((case when sum(executions_delta) > 0 then (sum(elapsed_time_delta)/sum(executions_delta))/1000 else 0 end),3) as AvgMs,
       sum(buffer_gets_delta) as BufferGets,
       sum(disk_reads_delta) as DiskReads,
       sum(IOWAIT_DELTA)         "IO"   ,
       round((case when sum(executions_delta) > 0 then (sum(iowait_delta)/sum(executions_delta))/1000 else 0 end),3) as AvgIoWait,
       sum(APWAIT_DELTA)         "APPL" ,
       sum(CCWAIT_DELTA)         "CC" ,
       sum(ROWS_PROCESSED_DELTA)  "Rows"
from WRH$_SQLSTAT c1,
     WRM$_SNAPSHOT c2,
     WRH$_SQLTEXT c3
where c1.snap_id = c2.snap_id
and c1.sql_id = '&sqlid'
and c1.sql_id = c3.sql_id
and c1.DBid = c3.DBid
and to_char(begin_interval_time,'dd-mm-yyyy') = '&back'
group by c1.SNAP_ID
order by c1.SNAP_ID asc
/
