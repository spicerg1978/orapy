set feedback on

prompt
ACCEPT schemaname CHAR PROMPT    "Enter Schema name (UPPERCASE): "
prompt


SELECT dt.owner,
       dt.tablespace_name,
       dt.table_name,
       ROUND (SUM (de.bytes) / 1024 / 1024 , 8) Mb
FROM sys.dba_extents de,
     sys.dba_tables dt
WHERE dt.tablespace_name = de.tablespace_name
AND   de.segment_name = dt.table_name
AND   dt.owner = '&schemaname'
GROUP BY dt.owner, dt.tablespace_name, dt.table_name
ORDER BY 1,3;