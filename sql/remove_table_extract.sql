 set lines 1000 pages 1000
 
 prompt *************************************************
 prompt *	remove_table_extract script	        *
 prompt *************************************************
 
 prompt
  ACCEPT own CHAR PROMPT    "Enter Table Owner: "
 prompt
 
 select distinct table_name
  from  conf
 where  table_owner = '&own';
 
 prompt
  ACCEPT tab CHAR PROMPT    "Enter Table Name: "
 prompt
 
delete conf
where  table_name = '&tab'
  and  table_owner = '&own';

commit;

select distinct table_owner, table_name
  from conf
  order by table_owner, table_name;



 