prompt
ACCEPT path CHAR PROMPT    "Enter path to unload to [include the '/' or '\' at the end]: "
prompt

prompt
ACCEPT schema CHAR PROMPT "Enter schema to unload to '~' separated file(s): "
prompt

set termout off lines 0 pages 0 trims on feedback off
spool c:\unload_data\unload_user.sql
exec unload_schema ('&schema','&path');
spool off

@c:\unload_data\unload_user.sql

set termout on
prompt finished unloading data..
