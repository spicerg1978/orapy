REM *************************************************************************** 
REM 
REM        TITLE:
REM        AUTHOR:
REM        DESCRIPTION:
REM
REM
REM
REM        USAGE W/ PARAMETERS:
REM        
REM        TABLES USED:
REM
REM  MODIFICATION ALLOWED (Y/N):	
REM  MODIFICATION HISTORY:
REM  WHO          WHEN         WHAT
REM  --------------------------------------------------------------------------
REM               MM/DD/YY     INITIAL CREATION
REM
REM ***************************************************************************
rem  dfile.sql
rem
rem  linesize = 131
rem
set linesize 132
rem
ttitle 'Data Files by Tablespace'
rem
col tablespace_name format a15 heading 'TABLESPACE'
col file_id format 999 heading 'ID'
col bytes format 99,999,999,999
col blocks format 9,999,999
col status format a9
col file_name format a65 heading 'FILE NAME'
rem
break on report on tablespace_name skip 1
compute sum of bytes blocks on report tablespace_name
rem
SELECT 			tablespace_name, file_id, bytes, blocks, status, file_name
  FROM 			  sys.dba_data_files
 WHERE 		   tablespace_name IN (SELECT	DISTINCT(tablespace_name)
   					 FROM	(SELECT  tablespace_name
						   FROM	 dba_tab_partitions
						  WHERE  table_owner = 'MISMART'
						  UNION 
						 SELECT	 tablespace_name
						   FROM  dba_tables
						  WHERE  owner = 'MISMART'))
 ORDER BY tablespace_name, file_id;
rem
set linesize 80