

set lines 1000
--column osuser format a13
--column username format a15
--column machine format a25
--column login format a20
--column module format a25
--column action format a100
--column client_info format a20


prompt
ACCEPT table CHAR PROMPT    "Enter table_name : "
prompt

select 	owner, table_name
from 	dba_tables
where 	table_name like '&table' 
order by owner
/

clear col

