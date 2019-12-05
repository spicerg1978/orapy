$ORACLE_HOME/bin/rman target / auxiliary sys/b1gb3n@TTRI03 

run
{
allocate channel prmy1 type disk;
allocate channel prmy2 type disk;
allocate channel prmy3 type disk;
allocate channel prmy4 type disk;
allocate auxiliary channel stby type disk;
duplicate target database for standby from active database nofilenamecheck
spfile
set db_unique_name='TTRI03A'
set fal_client='TTRI03A.LIFFE.COM'
set fal_server='TTRI03.LIFFE.COM'
set instance_name='TTRI03A'
set job_queue_processes='0'
set log_archive_dest_2='service="TTRI03.LIFFE.COM"','   LGWR SYNC AFFIRM delay=0 OPTIONAL compression=DISABLE max_failure=0 max_connections=4 reopen=900 db_unique_name="TTRI03" net_timeout=40 valid_for=(online_logfile,primary_role)'
set log_archive_dest_state_2='DEFER'
set log_file_name_convert='/oralogs/TTRI03/ora*/','/oralogs/TTRI03/ora*/'
;
}

exit
EOF
exit
