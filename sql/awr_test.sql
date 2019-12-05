select distinct dbid, instance_number, db_name, instance_name
  from WRM$_DATABASE_INSTANCE;

prompt Please choose the database to run AWR report on.....
prompt Using &&dbid for database Id
prompt Using &&inst_num for instance number


--
--  Set up the binds for dbid and instance_number

variable db_id       number;
variable inst_num   number;
begin
  :db_id      :=  &dbid;
  :inst_num  :=  &inst_num;
end;
/

set lines 1000
set pages 100
col snapdat format a30

prompt please choose snapshot 
prompt Hit RETURN to display snapshots available

pause

select di.instance_name                                  inst_name
     , di.db_name                                        db_name
     , s.snap_id                                         snap_id
     , to_char(s.end_interval_time,'dd Mon YYYY HH24:mi') snapdat
     , s.snap_level                                      lvl
  from WRM$_SNAPSHOT s
     , WRM$_DATABASE_INSTANCE di
 where s.dbid              = :db_id
   and s.instance_number   = :inst_num
   and di.dbid             = s.dbid
   and di.instance_number  = s.instance_number
   and di.startup_time     = s.startup_time
   and s.end_interval_time >= decode(1
                                   , 0   , to_date('31-JAN-9999','DD-MON-YYYY')
                                   , 3.14, s.end_interval_time
                                   , to_date('17/05/2011','dd/mm/yyyy') - (1-1))
 order by db_name, instance_name, snap_id;



prompt
prompt
prompt Specify the Begin and End Snapshot Ids
prompt ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
prompt Begin Snapshot Id specified: &&begin_snap
prompt
prompt End   Snapshot Id specified: &&end_snap
prompt


--
--  Set up the snapshot-related binds

variable bid        number;
variable eid        number;
begin
  :bid       :=  &begin_snap;
  :eid       :=  &end_snap;
end;
/

--
-- Find out if we are going to print report to html or to text
prompt
prompt Specify the Report Type
prompt ~~~~~~~~~~~~~~~~~~~~~~~
prompt Would you like an HTML report, or a plain text report?
prompt Enter 'html' for an HTML report, or 'text' for plain text
prompt  Defaults to 'html'

column report_type new_value report_type;
set heading off;
select 'Type Specified: ',lower(nvl('&&report_type','html')) report_type from dual;
set heading on;

set termout off;
-- Set the extension based on the report_type
column ext new_value ext;
select '.html' ext from dual where lower('&&report_type') <> 'text';
select '.txt' ext from dual where lower('&&report_type') = 'text';
set termout on;


set termout off;
-- set report function name and line size
column fn_name new_value fn_name noprint;
select 'awr_report_text' fn_name from dual where lower('&report_type') = 'text';
select 'awr_report_html' fn_name from dual where lower('&report_type') <> 'text';

column lnsz new_value lnsz noprint;
select '80' lnsz from dual where lower('&report_type') = 'text';
select '1500' lnsz from dual where lower('&report_type') <> 'text';

set linesize &lnsz;
set termout on;
spool &report_name;


select output from table(dbms_workload_repository.awr_report_text( :db_id,
                                                            :inst_num,
                                                            :bid, :eid,
                                                            0 ));
                                                            
spool off                                                            
--SPOOL OFF!!!