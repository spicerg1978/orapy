 set lines 1000 pages 1000
 
 prompt *************************************************
 prompt *	remove_extract_column script	        *
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

select col_num, table_column
 from  conf
where  table_name = '&tab';

prompt 
 ACCEPT col CHAR PROMPT     "Enter Column Name: "
prompt 


update conf
   set extract = 'N'
where  table_column = '&col'
  and  table_name = '&tab'
  and  table_owner = '&own';

commit;

select *
  from conf
 where table_owner = '&own'
   and table_name = '&tab'
order by col_num;



 