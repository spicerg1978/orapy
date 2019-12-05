prompt ==========================
prompt ==========================

Prompt
Prompt R E V O K E   A C C E S S
Prompt
Prompt 
Prompt This program revokes access from a user / program
Prompt
Prompt
Prompt

prompt ==========================
prompt ==========================

set feedback on

prompt
ACCEPT username CHAR PROMPT    "Enter user name (UPPERCASE): "
prompt

prompt
ACCEPT program CHAR PROMPT "Enter program name : "
prompt

prompt
ACCEPT desc CHAR PROMPT  "Enter program description : "
prompt

prompt 
pause  Revoking access from &username for program name &program press RETURN to continue....

exec dbsecurity.remove_user_program('&username', '&program', '&desc');

prompt
prompt Access now revoked from &username for &program
prompt 

set verify off
break on user skip 1 on user
select valid_ora "User", valid_program "Executable", description "Program"
  from valid_users
 where valid_ora ='&username'
 order by 1,2,3;
 
 