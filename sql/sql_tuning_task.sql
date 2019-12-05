DECLARE
  l_sql_tune_task_id  VARCHAR2(100);
BEGIN
  l_sql_tune_task_id := DBMS_SQLTUNE.create_tuning_task (
                          sql_id      => 'a5ydwc7jqwfyn',
                          scope       => DBMS_SQLTUNE.scope_comprehensive,
                          time_limit  => 60,
                          task_name   => 'a5ydwc7jqwfyn_AWR_tuning_task1',
                          description => 'Tuning task for statement 19v5guvsgcd1v in AWR.');
  DBMS_OUTPUT.put_line('l_sql_tune_task_id: ' || l_sql_tune_task_id);
END;
/


EXEC DBMS_SQLTUNE.execute_tuning_task(task_name => 'a5ydwc7jqwfyn_AWR_tuning_task1');


SET LONG 10000;
SET PAGESIZE 1000
SET LINESIZE 200
SELECT DBMS_SQLTUNE.report_tuning_task('a5ydwc7jqwfyn_AWR_tuning_task1') AS recommendations FROM dual;
SET PAGESIZE 24



a5ydwc7jqwfyn

UPDATE clearing_job job
                SET job.state =
                       CASE
                          WHEN job.state = 'WAITING' then 'PENDING'
                          WHEN job.state = 'MANUAL'  then 'HELD'
                       END
                  , job.state_messages = ''

RECOMMENDATIONS
--------------------------------------------------------------------------------
              WHERE job.state IN ( 'WAITING', 'MANUAL' )
                AND NOT EXISTS ( SELECT DISTINCT 1
                                   FROM clearing_dependency job_dep
                                      , clearing_job        preceeding_job
                                  WHERE job_dep.job_id         = job.job_id
                                    AND job_dep.dep_type       = 'JOB'
                                    AND preceeding_job.job_id  =
             job_dep.preceeding_job_id
                                    AND preceeding_job.state  != 'COMPLETE' )
                AND NOT EXISTS ( SELECT DISTINCT 1
                                   FROM clearing_dependency event_dep
                                      , clearing_event
             preceeding_event
                                  WHERE event_dep.job_id           =
             job.job_id
                                    AND event_dep.dep_type         = 'EVENT'
                                    AND preceeding_event.event_id  =
             event_dep.preceeding_event_id
                                    AND preceeding_event.state    !=
             'COMPLETE' )





    exec dbms_stats.gather_table_stats(ownname => 'TRIDINT3', tabname =>'CLEARING_JOB', estimate_percent => DBMS_STATS.AUTO_SAMPLE_SIZE,method_opt => 'FOR ALL COLUMNS SIZE AUTO', cascade => TRUE);

   exec dbms_stats.gather_table_stats(ownname => 'TRIDINT3', tabname =>
            'CLEARING_DEPENDENCY', estimate_percent =>
            DBMS_STATS.AUTO_SAMPLE_SIZE, method_opt => 'FOR ALL COLUMNS SIZE
            AUTO', cascade => TRUE);

  exec dbms_stats.gather_table_stats(ownname => 'TRIDINT3', tabname =>
            'CLEARING_EVENT', estimate_percent =>
            DBMS_STATS.AUTO_SAMPLE_SIZE, method_opt => 'FOR ALL COLUMNS SIZE
            AUTO', cascade => TRUE);

exec dbms_sqltune.accept_sql_profile(task_name => 'a5ydwc7jqwfyn_AWR_tuning_task1', task_owner => 'SYS', replace =>TRUE);

