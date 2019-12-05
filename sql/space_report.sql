set echo off
column TSNAME format a31;
column TYPE format a11;
column EXT_MGT format a12;
column STATUS format a9;
column SIZE_MB format 999,999.99;
column FREE_MB format 999,999.99;
column USED_MB format 999,999.99;
set pagesize 100 lines 120 feed on heading on
break on REPORT;
compute sum label 'Total' of SIZE_MB on REPORT;
compute sum label 'Total Free MB' of FREE_MB on REPORT;
compute sum label 'Total Used MB' of USED_MB on REPORT;
SELECT
      a.tablespace_name 			tsname,
      a.contents				  Type,
      a.extent_management		"Extent Mngmt",
      b.bytes/(1024*1024)                      SIZE_MB,
      c.free_bytes/(1024*1024)                 FREE_MB,
      (b.bytes-c.free_bytes)/(1024*1024)        USED_MB,
      a.STATUS 					STATUS              
  FROM dba_tablespaces a,
  	(SELECT tablespace_name, sum(bytes) bytes
           FROM dba_data_files
          GROUP BY tablespace_name
          UNION
         SELECT tablespace_name, sum(bytes) bytes
           FROM dba_temp_files
          GROUP BY tablespace_name) b,
        (SELECT ddf.tablespace_name, nvl(sum(dfs.bytes),0) free_bytes, (sum(ddf.bytes)-sum(dfs.bytes)) used_bytes
           FROM dba_free_space dfs , dba_data_files ddf
          WHERE dfs.file_id (+)=ddf.file_id
          GROUP BY ddf.tablespace_name
          UNION 
         SELECT tablespace_name, sum(bytes_free) free_bytes, sum(bytes_used) used_bytes  
           FROM v$temp_space_header
          GROUP BY tablespace_name) c
 WHERE a.tablespace_name=b.tablespace_name
   AND c.tablespace_name=a.tablespace_name
   AND c.tablespace_name=b.tablespace_name
   -- and a.tablespace_name not in ('TEMP', 'USERS')
   ORDER BY 1
/



--REDO LOG SIZING

 SELECT a.group#, a.member,b.bytes/1024/1024, b.status
   FROM v$logfile a, v$log b 
  WHERE a.group# = b.group#
/






 impdp / directory=TRIDENT dumpfile=PTRI01A_01_full_database_25-May-2011.0100.dmp remap_schema=TRIDLIVE:TRIDUAT2 remap_tablespace=HT_DATA_TBSPACE:APP remap_tablespace=HT_INDX_TBSPACE:INDX remap_tablespace=AUDIT_DATA_TBSPACE:APP remap_tablespace=AUDIT_INDX_TBSPACE:INDX remap_tablespace=PKA_DATA_TBSPACE:APP remap_tablespace=PKA_INDX_TBSPACE:INDX remap_tablespace=RES_DATA_TBSPACE:APP remap_tablespace=RES_INDX_TBSPACE:INDX schemas=TRIDLIVE 
 
 
 
 / dumpfile=PTRI01A_01_full_database_01-Oct-2012.2240.dmp remap_schema=TRIDLIVE:ANDYCA remap_tablespace=HT_DATA_TBSPACE:APP remap_tablespace=HT_INDX_TBSPACE:INDX remap_tablespace=AUDIT_DATA_TBSPACE:APP remap_tablespace=AUDIT_INDX_TBSPACE:INDX remap_tablespace=PKA_DATA_TBSPACE:APP remap_tablespace=PKA_INDX_TBSPACE:INDX remap_tablespace=RES_DATA_TBSPACE:APP remap_tablespace=RES_INDX_TBSPACE:INDX tables=tridlive.message_audit table_exists_action=replace

 
 
 impdp / dumpfile=PTRI01A_01_full_database_13-Feb-2013.2250.dmp remap_schema=TRIDLIVE:TRIDFUN1 remap_tablespace=HT_DATA_TBSPACE:APP remap_tablespace=HT_INDX_TBSPACE:INDX remap_tablespace=AUDIT_DATA_TBSPACE:APP remap_tablespace=AUDIT_INDX_TBSPACE:INDX remap_tablespace=PKA_DATA_TBSPACE:APP remap_tablespace=PKA_INDX_TBSPACE:INDX remap_tablespace=RES_DATA_TBSPACE:APP remap_tablespace=RES_INDX_TBSPACE:INDX schemas=TRIDLIVE parallel=8


SELECT b.tablespace,
           ROUND(((b.blocks*p.value)/1024/1024/1024),2)||'G' "SIZE",
           a.sid||','||a.serial# SID_SERIAL,
           a.username,
           a.program, 
           a.sql_id
      FROM sys.v_$session a,
           sys.v_$sort_usage b,
           sys.v_$parameter p
     WHERE p.name  = 'db_block_size'
      AND a.saddr = b.session_addr
   ORDER BY b.tablespace, b.blocks; 



ID                PLAN        ACTIVE             PROFPLAN                       EXECUTIONS      CPUMS   	ELAPSEMS     	AVGEMS 		READS  	BUFFER_GETS 	ROWP 	CC	PARSING_SCHE
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
9z93w0kwgtvg9/2   1539160365 270112 105239       SYS_SQLPROF_0132464fc17f0002            1 	1470467.46  	1470887.9  	1470887.9       18   	136086882 	0      	507	TRIDNEXT
9z93w0kwgtvg9/0   1736716158 270112 105240       SQL_PLAN_cqfgq4s23g3cb469bda3e         36   	7357.882   	7358.683    	204.408         0    	5057704   	0   	0	TRIDCURR


SQL> /

ID                      PLAN ACTIVE              PROFPLAN                       EXECUTIONS      CPUMS   	ELAPSEMS     	AVGEMS 		READS	BUFFER_GETS     ROWP	CC	PARSING_SCHE
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
9z93w0kwgtvg9/0   1736716158 270112 110016       SQL_PLAN_cqfgq4s23g3cb469bda3e         86  	23481.429   	23502.27    	273.282 	0	12082361   	0    	84	TRIDCURR
9z93w0kwgtvg9/2   1736716158 270112 110018       SQL_PLAN_cqfgq4s23g3cb469bda3e        161 	133359.728 	133545.195    	829.473 	25	89715549   	0	0	TRIDNEXT
