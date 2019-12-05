BEGIN
DBMS_SCHEDULER.CREATE_PROGRAM 
(
  program_name            => 'WDW_ARCHIVE',
  program_type            => 'EXECUTABLE',
  program_action          => '/wload/wpet/home/wpetwdw/wdw/tools/wdw_archive',
  number_of_arguments     => 1,
  enabled                 => FALSE,
  comments                => 'generate'
 );
  dbms_scheduler.define_program_argument (
         program_name => 'WDW_ARCHIVE'
        ,argument_position => 1
        ,argument_name => 'phase'
        ,argument_type => 'VARCHAR2'
        ,default_value => 'test'
      );
  dbms_scheduler.enable(name => 'WDW_ARCHIVE');
END;
/




BEGIN
DBMS_SCHEDULER.CREATE_JOB (
   job_name          =>  'ARCHIVE',
   program_name      =>  'WDW_ARCHIVE',
   repeat_interval   =>  'FREQ=SECONDLY;INTERVAL=600',
   enabled            =>  TRUE,
   comments          =>  'Every 10 Mins');
END;
/


BEGIN
DBMS_SCHEDULER.drop_program(program_name => 'WDW_ARCHIVE',
force => TRUE);
end;
/

