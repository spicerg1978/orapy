col stmtid      heading 'Stmt Id'               format    9999999999
col dr          heading 'PIO blks'              format   999,999,999
col bg          heading 'LIOs'                  format   999,999,999
col sr          heading 'Sorts'                 format       999,999
col exe         heading 'Runs'                  format   999,999,999
col rp          heading 'Rows'                  format 9,999,999,999
col rpr         heading 'LIOs|per Row'          format   999,999,999
col rpe         heading 'LIOs|per Run'          format   999,999,999

set termout   on
set pause     on
set pagesize  30
set pause     'More: '
set linesize  95

select  hash_value stmtid
       ,sum(disk_reads) dr
       ,sum(buffer_gets) bg
       ,sum(rows_processed) rp
       ,sum(buffer_gets)/greatest(sum(rows_processed),1) rpr
       ,sum(executions) exe
       ,sum(buffer_gets)/greatest(sum(executions),1) rpe
 from v$sql
where command_type in ( 2,3,6,7 )
group by hash_value
order by 5 desc
/

set pause off
