select
  sql_id,
  b.name BIND_NAME,
  b.value_string BIND_STRING,
  t.child_number,
  t.elapsed_time/1000,
  to_char(t.last_active_time, 'dd-mm-yyyy HH24:mi:ss')
from
  v$sql t
  join v$sql_bind_capture b
  using (sql_id)
where
  b.value_string is not null
  and sql_id='0472h3957t9nh'
order by 5
/


DELETE       
  FROM position_keeping_account       
 WHERE exchange_code = :exchange_code             
   AND physical_commodity = :physical_commodity
   AND expiry_date = :expiry_date             
   AND generic_contract_type = :generic_contract_type


SQL_ID		BIND_NAME		BIND_STRING	CHILD_NUMBER
-------------------------------------------------------------------------------
0472h3957t9nh	:GENERIC_CONTRACT_TYPE	F	        0
0472h3957t9nh	:GENERIC_CONTRACT_TYPE	O               0
0472h3957t9nh	:EXPIRY_DATE		20110100        0
0472h3957t9nh	:EXPIRY_DATE		20101200        0
0472h3957t9nh	:PHYSICAL_COMMODITY	Y	        0
0472h3957t9nh	:PHYSICAL_COMMODITY	RC	        0
0472h3957t9nh	:EXCHANGE_CODE		X	        0
0472h3957t9nh	:EXCHANGE_CODE		L	        0

0472h3957t9nh	:GENERIC_CONTRACT_TYPE	O	        1
0472h3957t9nh	:GENERIC_CONTRACT_TYPE	F               1
0472h3957t9nh	:EXPIRY_DATE		20101200        1
0472h3957t9nh	:EXPIRY_DATE		20110100        1
0472h3957t9nh	:PHYSICAL_COMMODITY	Y	        1
0472h3957t9nh	:PHYSICAL_COMMODITY	RC	        1
0472h3957t9nh	:EXCHANGE_CODE		X               1
0472h3957t9nh	:EXCHANGE_CODE		L               1


16 rows selected.

SQL>
