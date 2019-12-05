select
os_username,
username,  
userhost, 
terminal, 
to_char(timestamp, 'DD-MON-YYYY hh24:mi:ss') when,  
owner,  
obj_name,  
action,  
action_name,          
statementid,  
returncode,  
priv_used
from dba_audit_trail
