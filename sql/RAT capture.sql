Processing object type DATABASE_EXPORT/SCHEMA/TABLE/TABLE_DATA
ORA-31693: Table data object "ENV93_APP"."SETL_PRICE" failed to load/unload and is being skipped due to error:
ORA-02291: integrity constraint (ENV93_APP.SPE_ST_FK) violated - parent key not found
ORA-31693: Table data object "ENV93_APP"."SETL_STATE" failed to load/unload and is being skipped due to error:
ORA-02291: integrity constraint (ENV93_APP.SS_ST_FK) violated - parent key not found
ORA-31693: Table data object "ENV93_APP"."SETL_STYLE" failed to load/unload and is being skipped due to error:
ORA-00001: unique constraint (ENV93_APP.SSTY_PK) violated
ORA-31693: Table data object "ENV93_APP"."SETL_TIME" failed to load/unload and is being skipped due to error:
ORA-00001: unique constraint (ENV93_APP.ST_UK) violated
Job "OPS$ORACLE"."SYS_IMPORT_TABLE_01" completed with 8 error(s) at 11:39:16



SETL_PRICE, SETL_STATE, SETL_STYLE





BEGIN
  DBMS_WORKLOAD_REPLAY.process_capture('DB_REPLAY_CAPTURE');

  DBMS_WORKLOAD_REPLAY.initialize_replay (replay_name => 'test_capture_2',
                                          replay_dir  => 'DB_REPLAY_CAPTURE');

  DBMS_WORKLOAD_REPLAY.prepare_replay (synchronization => TRUE);
END;
/


BEGIN
  DBMS_WORKLOAD_REPLAY.process_capture('DB_REPLAY_CAPTURE');

  DBMS_WORKLOAD_REPLAY.initialize_replay (replay_name => 'test_capture_2',
                                          replay_dir  => 'DB_REPLAY_CAPTURE');

  DBMS_WORKLOAD_REPLAY.prepare_replay (synchronization => FALSE);
END;
/



wrc mode=calibrate replaydir=/dbdump1/db_replay_capture/



wrc tridperf2/tridperf2 mode=replay replaydir=/dbdump1/db_replay_capture/



BEGIN
  DBMS_WORKLOAD_REPLAY.start_replay;
END;
/


BEGIN
  DBMS_WORKLOAD_REPLAY.cancel_replay;
END;
/