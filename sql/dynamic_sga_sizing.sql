set echo off
column SIZE_MB format 999,999.99;
set pagesize 100 lines 120 feed on heading on
break on REPORT;
compute sum label 'Total' of SIZE_MB on REPORT;
SELECT component, current_size/1024/1024 as size_mb, min_size/1024/1024 as min_size_mb
FROM v$sga_dynamic_components
WHERE current_size > 0
ORDER BY component; 