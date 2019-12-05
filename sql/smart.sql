set feedback off
set head off
set echo off


spool C:\sqlscripts\scripts\smart_postclone.sql

select 'create or replace directory '||directory_name||' as '||CHR(39)||substr(directory_path,1,7)
       ||substr(value,8,4)||substr(directory_path, 12, 6)||substr(value,8,4)||substr(directory_path,22)||CHR(39)||';' 
from dba_directories, v$parameter p
where p.num = '228'
/

spool off

set feedback on

@@smart_postclone.sql





















