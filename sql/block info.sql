select avg(count(*)) "AVERAGE RECORDS PER BLOCK"
  from position_keeping_account 
 group by dbms_rowid.rowid_block_number(rowid);
 
 
 select count (distinct dbms_rowid.rowid_block_number(rowid)) "TABLE BLOCK COUNT"
   from position_keeping_account;



select segment_name,  round(bytes/1024/1024) "MB"
 from user_segments
where segment_name in ('POSITION_KEEPING_ACCOUNT');