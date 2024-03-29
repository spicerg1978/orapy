/*********************************************************** 

	Description: Show SQLs with the highest lock waits 
   

*********************************************************/


column sql_text format a40 heading "SQL Text"
column app_time_ms format 99,999,999 heading "AppTime(ms)"
column app_time_pct format 999.99 heading "SQL App|Time%"
column pct_of_app_time format 999.99 heading "% Tot|App Time"
set pagesize 1000
set lines 100
set echo on 

WITH sql_app_waits AS 
    (SELECT sql_id, SUBSTR(sql_text, 1, 80) sql_text, 
            application_wait_time/1000 app_time_ms,
            elapsed_time,
            ROUND(application_wait_time * 100 / 
                elapsed_time, 2) app_time_pct,
            ROUND(application_wait_time * 100 / 
                SUM(application_wait_time) OVER (), 2) pct_of_app_time,
            RANK() OVER (ORDER BY application_wait_Time DESC) ranking
       FROM v$sql
      WHERE elapsed_time > 0
        AND application_wait_time>0 )
SELECT sql_text, app_time_ms, app_time_pct,
       pct_of_app_time, ranking
FROM sql_app_waits
WHERE ranking <= 10
ORDER BY ranking  ; 
 
