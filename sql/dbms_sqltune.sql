

SET SERVEROUTPUT ON

-- Tuning task created for specific a statement from the AWR.
DECLARE
  l_sql_tune_task_id  VARCHAR2(100);
BEGIN
  l_sql_tune_task_id := DBMS_SQLTUNE.create_tuning_task (
                          sql_id      => '0bj43bps8nuzm',
                          scope       => DBMS_SQLTUNE.scope_comprehensive,
                          time_limit  => 500,
                          task_name   => '0bj43bps8nuzm_task',
                          description => 'Tuning task for statement 0bj43bps8nuzm in AWR.');
  DBMS_OUTPUT.put_line('l_sql_tune_task_id: ' || l_sql_tune_task_id);
END;
/


EXEC DBMS_SQLTUNE.execute_tuning_task(task_name => '0bj43bps8nuzm_task')
/


SET LONG 10000;
SET PAGESIZE 1000
SET LINESIZE 200
SELECT DBMS_SQLTUNE.report_tuning_task('0bj43bps8nuzm_task') AS recommendations FROM dual;
SET PAGESIZE 24



BEGIN
  DBMS_SQLTUNE.drop_tuning_task (task_name => '0bj43bps8nuzm_task');
END;
/


BEGIN
  DBMS_SQLTUNE.drop_sql_profile (
    name   => 'SYS_SQLPROF_0131425fb4540001',
    ignore => TRUE);
END;
/




SET SERVEROUTPUT ON

-- Tuning task created for specific a statement from the AWR.
DECLARE
  l_sql_tune_task_id  VARCHAR2(100);
BEGIN
  l_sql_tune_task_id := DBMS_SQLTUNE.create_tuning_task (
                          begin_snap  => 4652,
                          end_snap    => 4664,
                          sql_id      => '6sk44xqn7sfq3',
                          scope       => DBMS_SQLTUNE.scope_comprehensive,
                          time_limit  => 60,
                          task_name   => '6sk44xqn7sfq3_AWR_tuning_task',
                          description => 'Tuning task for statement 6sk44xqn7sfq3 in AWR.');
  DBMS_OUTPUT.put_line('l_sql_tune_task_id: ' || l_sql_tune_task_id);
END;
/


index and baseline


> execute dbms_sqltune.create_sql_plan_baseline(task_name =>'5pj42b5p0z6ks_task', owner_name => 'SYS', plan_hash_value =>157492600);



SET SERVEROUTPUT ON
DECLARE
  l_plans_loaded  PLS_INTEGER;
BEGIN
  l_plans_loaded := DBMS_SPM.load_plans_from_cursor_cache(
    sql_id => '116adc0mmpkjt');
    
  DBMS_OUTPUT.put_line('Plans Loaded: ' || l_plans_loaded);
END;
/


SET SERVEROUTPUT ON
DECLARE
  l_plans_unpacked  PLS_INTEGER;
BEGIN
  l_plans_unpacked := DBMS_SPM.unpack_stgtab_baseline(
    table_name      => 'pti_baselines',
    table_owner     => 'DBA_ADMIN');

  DBMS_OUTPUT.put_line('Plans Unpacked: ' || l_plans_unpacked);
END;
/

BEGIN
  DBMS_SPM.CREATE_STGTAB_BASELINE(
    table_name      => 'pti_baselines',
    table_owner     => 'TRIDGUI3');
END;
/

SET SERVEROUTPUT ON
DECLARE
  l_plans_packed  PLS_INTEGER;
BEGIN
  l_plans_packed := DBMS_SPM.pack_stgtab_baseline(
    table_name      => 'pti_baselines',
    table_owner     => 'TRIDGUI3');

  DBMS_OUTPUT.put_line('Plans Packed: ' || l_plans_packed);
END;
/







2pd55sjh0rkk3/0 1292937785 f    20-11-2012 14:25:46      931861 577491.998 602290.966       .646         19    30514375        1611526     779405 N N


2pd55sjh0rkk3/4 3450024138      20-11-2012 14:20:21       1052 3304280.69 3310571.83   3146.931          0   281494500           2104    2721895 N N
