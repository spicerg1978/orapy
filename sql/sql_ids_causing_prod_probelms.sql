select sql_id||'/'||child_number as Id, plan_hash_value as Plan,
        --substr(trim(' ' from sql_text),instr(trim(' ' from sql_text),'EXCHANGE_CODE=')+15,1) as EXchg,
        to_char(last_active_time,'ddmmyy hh24miss')as Active,
        (case when SQL_PLAN_BASELINE is NULL then sql_profile else sQL_PLAN_BASELINE end) as ProfPlan,
        executions executions, cpu_time/1000 as cpums,
        ELAPSED_TIME/1000 as ElapseMs,
        (case  when executions > 0 then round((ELAPSED_TIME/1000)/executions,3) else 0 end) as AVgEMs,
        to_char(disk_reads) reads, buffer_gets, rows_processed rowp,
        concurrency_wait_time cc
     --,is_bind_sensitive S,is_bind_aware a
     from V$sql
  where sql_id in ('a7tsdb5wuw4ds','1md3fxmy3mfxn','cqjmj75344w69')
     and parsing_schema_name in ('TRIDCURR','TRIDLIVE','TRIDPERF3', 'TRIDPERF2')
  order by last_active_time



SQL_ID        PLAN_HASH_VALUE
------------- ---------------
1md3fxmy3mfxn      1514396961
a7tsdb5wuw4ds       140274873
cqjmj75344w69      3958977285

