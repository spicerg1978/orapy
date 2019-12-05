set serveroutput on 
cl scr
prompt ================================
prompt ================================

prompt
prompt DISPLAYS USERS AUTHORISED ACCESS
prompt

prompt ================================
prompt ================================

set feedback on
set linesize 500

select  count(*), valid_ora
   from  valid_users
   group by valid_ora
  order by valid_ora desc;
   
   
 