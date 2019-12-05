set lines 1000 pages 1000

column Sid/Serial 	format a10
column "Login Time" 	format a22
column "User" 		format a15
column "OS User" 	format a15
column "Machine" 	format a30
column "Succ?"          format a6

prompt
ACCEPT username CHAR PROMPT    "Enter username : "
prompt

spool user_audit.txt

select sid||', '||serial# "Sid/Serial", to_char(timestamp, 'yyyy-mm-dd hh24:mi:ss') "Login Time", success "Succ?", username "User" ,     
       osuserid "OS User", machinename "Machine", program prog
  from user_audit
 where username = '&username'
 order by 2;

spool off
 
edit user_audit.txt