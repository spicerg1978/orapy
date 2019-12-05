set serveroutput on 
cl scr
prompt ================================
prompt ================================

prompt
prompt DISPLAYS USERS COUNT OF AUTHORISED APPLICATIONS
prompt

prompt ================================
prompt ================================

set feedback on
set linesize 500

select  count(*), valid_program
   from  valid_users
   group by valid_program;
   
   
 