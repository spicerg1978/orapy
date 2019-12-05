exec dbms_stats.gather_table_stats(ownname => 'TRIDFUN6', tabname => 'NOTIFICATION', estimate_percent => DBMS_STATS.AUTO_SAMPLE_SIZE,method_opt => 'FOR ALL COLUMNS SIZE AUTO', cascade => TRUE);
	    
exec dbms_stats.gather_table_stats(ownname => 'TRIDFUN6', tabname => 'COMMODITY_CONTRACT', estimate_percent => DBMS_STATS.AUTO_SAMPLE_SIZE, method_opt => 'FOR ALL COLUMNS SIZE AUTO', cascade => TRUE);	    
	    
exec dbms_stats.gather_table_stats(ownname => 'TRIDFUN6', tabname => 'POSITION_KEEPING_ACCOUNT', estimate_percent => DBMS_STATS.AUTO_SAMPLE_SIZE, method_opt => 'FOR ALL COLUMNS SIZE AUTO', cascade => TRUE);	    




 exec dbms_sqltune.accept_sql_profile(task_name =>'c99bdt3jnbyu5_AWR_tuning_task', task_owner => 'SYS', replace =>TRUE);