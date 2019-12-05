 set lines 1000 pages 1000
 
 prompt *************************************************
 prompt *	remove_schema_extract script	        *
 prompt *************************************************
 
 prompt
  ACCEPT own CHAR PROMPT    "Enter Table Owner: "
 prompt
  
delete conf
where  table_owner = '&own';

commit;

select distinct table_owner
  from conf
  order by table_owner;



 