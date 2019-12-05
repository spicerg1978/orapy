CREATE OR REPLACE PACKAGE "DBA_ADMIN"."MANAGE_PARTITIONS" AS
/***********************************************************************************************************************
 Change History:
 Date          Name                     Description
 ----          ----                     -----------
 19/01/2011    Gareth Spicer            Initial Design
 ***********************************************************************************************************************/

PROCEDURE CREATE_PARTITIONS
( p_schema            IN      VARCHAR2,
  p_cnt_part          IN      NUMBER,
  p_table_name        IN      VARCHAR2
);

PROCEDURE             CREATE_MESSAGE_AUDIT_PART
( p_schema            IN      VARCHAR2,
  p_part_cnt          IN      NUMBER,
  p_trad_day          IN      NUMBER
);

PROCEDURE             CREATE_NOTIFICATION_PART
( p_schema            IN      VARCHAR2,
  p_part_cnt          IN      NUMBER,
  p_trad_day          IN      NUMBER
);

FUNCTION GET_TRADING_DAY
(  p_schema            IN      VARCHAR2
)
RETURN NUMBER;

FUNCTION GET_PARTITION_NAME
(
 p_schema    IN  VARCHAR2,
 p_tab_name  IN  VARCHAR2
)
RETURN VARCHAR2;

PROCEDURE get_table_stats
(
 p_schema   in varchar2,
 p_tab_name in varchar2,
 p_new_part in varchar2
)
;

PROCEDURE lock_table_stats
(
 p_schema   in varchar2,
 p_tab_name in varchar2,
 p_lock in varchar2
)
;

PROCEDURE delete_partitions
(
 p_schema   in varchar2
);

END manage_partitions;
/

CREATE OR REPLACE PACKAGE BODY "DBA_ADMIN"."MANAGE_PARTITIONS" as
/***********************************************************************************************************************
 Change History:

DBMS_METADATA.GET_DDL('PACKAGE','MANAGE_PARTITIONS','DBA_ADMIN')
--------------------------------------------------------------------------------
 Date          Name                     Description
 ----          ----                     -----------
 19/01/2011    Gareth Spicer            Initial Design
***********************************************************************************************************************/

PROCEDURE CREATE_PARTITIONS
(p_schema            IN      VARCHAR2,
 p_cnt_part          IN      NUMBER,
 p_table_name        IN      VARCHAR2
)
AS
  v_trad_day   varchar2(30);
  v_max_day varchar2(30);
BEGIN
  v_max_day :=0;
FOR x IN (select high_value
            from dba_tab_partitions
           where table_owner = p_schema
             and table_name = p_table_name)
LOOP
 v_trad_day := x.high_value;
IF (v_max_day < v_trad_day) THEN
   v_max_day := v_trad_day;
END IF;
END LOOP;
IF p_table_name = 'MESSAGE_AUDIT' THEN
    CREATE_MESSAGE_AUDIT_PART(p_schema,p_cnt_part,v_max_day+1);
END IF;
IF p_table_name = 'NOTIFICATION' THEN
   CREATE_NOTIFICATION_PART(p_schema,p_cnt_part,v_max_day+1);
END IF;
END CREATE_PARTITIONS;

PROCEDURE             CREATE_MESSAGE_AUDIT_PART
( p_schema            IN      VARCHAR2,
  p_part_cnt          IN      NUMBER,
  p_trad_day          IN      NUMBER
)
    AS
      v_trad_day           number;
      v_src_part_name      varchar2(30);
      v_new_part_name      varchar2(30);
      v_cnt                number;
      v_nxt_trad_day       number;
   BEGIN
    v_cnt := 0;
    lock_table_stats(p_schema, 'MESSAGE_AUDIT','UNLOCK');
   FOR x in 1..p_part_cnt
   LOOP
     v_nxt_trad_day := p_trad_day + v_cnt;

     dbms_output.put_line('trading_day is....'||p_trad_day||' next trading_day is '||v_nxt_trad_day);
     dbms_output.put_line('insert into MESSAGE_AUDIT values.....'||v_nxt_trad_day);

     select get_partition_name(p_schema,'MESSAGE_AUDIT')
       into v_src_part_name
       from dual;

    dbms_output.put_line('source partition....'||v_src_part_name);

    execute immediate 'insert into '||p_schema||'.MESSAGE_AUDIT
                                  select  '||v_nxt_trad_day||' ,EXCHANGE_CODE,OUTPUT_SEQUENCE_NO,MESSAGE_ID,TRANSACTION_ID,
                                      EXTERNAL_IND,MESSAGE_SRC,CLASS,FIRM,SERIES_PARTITION_KEY,
                                      MESSAGE_TYPE,SLIP_ID,MESSAGE_DATA_VERSION,CREATION_DAY,ACTION_FLAG,MESSAGE_DATA
                                    from '||p_schema||'.MESSAGE_AUDIT
                               where rownum < 2';
    rollback;

    dbms_output.put_line('new partition created');

    select get_partition_name(p_schema,'MESSAGE_AUDIT')
      into v_new_part_name
      from dual;

    dbms_output.put_line('new partition.......'||v_new_part_name);
     update TRIDENT_TAB_STATS
        set c2 = replace(c2, v_src_part_name, v_new_part_name)
      where c1 = 'MESSAGE_AUDIT';

    commit;

    get_table_stats(p_schema,'MESSAGE_AUDIT',v_new_part_name);
    v_cnt := v_cnt+1;

    END LOOP;
 
    lock_table_stats(p_schema, 'MESSAGE_AUDIT','LOCK');

END CREATE_MESSAGE_AUDIT_PART;

PROCEDURE             CREATE_NOTIFICATION_PART
( p_schema            IN      VARCHAR2,
  p_part_cnt          IN      NUMBER,
  p_trad_day          IN      NUMBER
)
    AS
      v_trad_day           number;
      v_src_part_name      varchar2(30);
      v_new_part_name      varchar2(30);
      v_cnt                number;
      v_nxt_trad_day       number;

BEGIN
    v_cnt := 0;
    lock_table_stats(p_schema, 'NOTIFICATION','UNLOCK');
     FOR x in 1..p_part_cnt
       LOOP
        v_nxt_trad_day := p_trad_day + v_cnt;
        
        dbms_output.put_line('trading_day is....'||p_trad_day||' next trading_day is '||v_nxt_trad_day);
        dbms_output.put_line('insert into NOTIFICATION values.....'||v_nxt_trad_day);
        
        select get_partition_name(p_schema,'NOTIFICATION')
          into v_src_part_name
          from dual;
      
         dbms_output.put_line('source partition....'||v_src_part_name);
         
         execute immediate 'insert into '||p_schema||'.NOTIFICATION
                         select EXCHANGE_CODE,NOTIFICATION_ID,NOTIFICATION_SRC_ID,NOTIFICATION_TYPE,NOTIFICATION_SRC,
                                '||v_nxt_trad_day||' ,VOLUME_CHANGE,ENTERED_DATE,MATCHED_DATE,MODIFIED_DATE,CLEARER,
                                     FIRM,TRADER,ACCOUNT_CODE,POSITION_REF,CONTRACT_TYPE,GENERIC_CONTRACT_TYPE,
                                     PHYSICAL_COMMODITY,LOGICAL_COMMODITY,EXPIRY_DATE,EXERCISE_PRICE,VALUATION_PRICE,
                                     COUNTERPARTY_FIRM,COUNTERPARTY_TRADER,OPERATOR_NAME,USER_INFO,POSITION_DAY,
                                     TENDER_DELETION_DAY,NEW_TENDER_DELETION_DAY,MARGINING_ACCOUNT,COUNTERNOTE_ID,
                                     COUNTERNOTE_SRC_ID,COUNTERTRADE_ID,COUNTERTRADE_SRC_ID,COUNTERTRADE_SUB_NO,
                                     COUNTERTRADE_VOLUME,NOTE_PROCESSED_DAY,MATCH_SEQ_NO,ALL_LOTS_IND,NOTIFICATION_STATUS,
                                     ADJUSTED_VOLUME_CHANGE,ADJUST_NON_MARG_VOLUME,LOT_SIZE,OLD_VALUATION_PRICE,PAY_COLLECT,
                                     PREMIUM_PAY_COLLECT,CONTINGENT_MARGIN,PAID_VARIATION,PAID_CONTINGENT,POSITION_TYPE,
                                     ALT_DELIVERABLE_IND,TRADE_CHARGE_IND,LONG_SHORT_IND,SUB_ACCOUNT,POSITION_STATUS,CORRECTION_TYPE,
                                     TRANSFER_METHOD,EXTERN_EXCHANGE_ID,GUARANTEE_ACCOUNT,ALLOCATION_TRADER,ALLOCATION_FIRM,
                                     GHOST_FLAG,COUNTERPARTY_ANONYMOUS_FIRM,COUNTERPARTY_ANONYMOUS_TRADER,REFERENCE_DAY,EXERCISE_VALUE,
                                     PROFIT_CHANGE,CLEARING_JOB_ID
                            from '||p_schema||'.NOTIFICATION
                           where rownum < 2';
       rollback;

       dbms_output.put_line('new partition created');

       select get_partition_name(p_schema,'NOTIFICATION')
         into v_new_part_name
         from dual;

        dbms_output.put_line('new partition.......'||v_new_part_name);

        update TRIDENT_TAB_STATS
           set c2 = replace(c2, v_src_part_name, v_new_part_name)
         where c1 = 'NOTIFICATION';

        commit;

        get_table_stats(p_schema,'NOTIFICATION',v_new_part_name);
        v_cnt := v_cnt+1;
    END LOOP;
        lock_table_stats(p_schema, 'NOTIFICATION','LOCK');

END CREATE_NOTIFICATION_PART;

FUNCTION GET_TRADING_DAY
(
 p_schema IN  VARCHAR2
)
RETURN NUMBER
AS
 v_trad_day number;
BEGIN
   execute immediate 'select max(trading_day) from '||p_schema||'.trading_day wh
ere component_name = ''POSITION_MAINTENANCE''' into v_trad_day;
RETURN v_trad_day;
END GET_TRADING_DAY;
FUNCTION GET_PARTITION_NAME
(
 p_schema    IN  VARCHAR2,

DBMS_METADATA.GET_DDL('PACKAGE','MANAGE_PARTITIONS','DBA_ADMIN')
--------------------------------------------------------------------------------
 p_tab_name  IN  VARCHAR2
)
RETURN VARCHAR2
AS
 v_part_name varchar2(30);
BEGIN
    select partition_name
               into v_part_name
              from dba_tab_partitions
            where table_name = p_tab_name
               and table_owner = p_schema

DBMS_METADATA.GET_DDL('PACKAGE','MANAGE_PARTITIONS','DBA_ADMIN')
--------------------------------------------------------------------------------
               and partition_position = (select max(partition_position)
                                      from dba_tab_partitions
                                     where table_name = p_tab_name
                                      and table_owner = p_schema
                                     );
RETURN v_part_name;
END GET_PARTITION_NAME;
PROCEDURE get_table_stats
(
 p_schema   in varchar2,
 p_tab_name in varchar2,

DBMS_METADATA.GET_DDL('PACKAGE','MANAGE_PARTITIONS','DBA_ADMIN')
--------------------------------------------------------------------------------
 p_new_part in varchar2
)
AS
BEGIN
         dbms_stats.import_table_stats(ownname=>p_schema,tabname=>p_tab_name,par
tname=>p_new_part,stattab=>'TRIDENT_TAB_STATS',statown=>'DBA_ADMIN');
END get_table_stats;
PROCEDURE lock_table_stats
(
 p_schema   in varchar2,
 p_tab_name in varchar2,

DBMS_METADATA.GET_DDL('PACKAGE','MANAGE_PARTITIONS','DBA_ADMIN')
--------------------------------------------------------------------------------
 p_lock in varchar2
)
AS
BEGIN
   IF p_lock = 'UNLOCK'
   THEN
         dbms_stats.unlock_table_stats(p_schema,p_tab_name);
   ELSIF p_lock = 'LOCK'
   THEN
         dbms_stats.lock_table_stats(p_schema,p_tab_name);
   END IF;

DBMS_METADATA.GET_DDL('PACKAGE','MANAGE_PARTITIONS','DBA_ADMIN')
--------------------------------------------------------------------------------
END lock_table_stats;
PROCEDURE delete_partitions
(
 p_schema   in varchar2
)
AS
 v_tab varchar2(30);
 v_part varchar2(30);
 v_highvalue number;
 v_num_of_rows number;
 v_trad_day varchar2(10);

DBMS_METADATA.GET_DDL('PACKAGE','MANAGE_PARTITIONS','DBA_ADMIN')
--------------------------------------------------------------------------------
 v_owner varchar2(100);
cursor part_get is
select table_owner, table_name, partition_name, high_value
  from dba_tab_partitions
  where partition_name like 'SYS_%' and table_owner=p_schema
   order by table_name, partition_name;
begin
 select GET_TRADING_DAY(p_schema)
   into v_trad_day
   from dual;
for x in part_get

DBMS_METADATA.GET_DDL('PACKAGE','MANAGE_PARTITIONS','DBA_ADMIN')
--------------------------------------------------------------------------------

loop

v_owner := x.table_owner;
v_tab := x.table_name;
v_part := x.partition_name;
v_highvalue := to_number(x.high_value)-1;

 case v_tab
     when 'NOTIFICATION' then
         execute immediate 'select count(*) from '||v_owner||'.'||v_tab||' where

DBMS_METADATA.GET_DDL('PACKAGE','MANAGE_PARTITIONS','DBA_ADMIN')
--------------------------------------------------------------------------------
 note_creation_day = '||v_highvalue
         into v_num_of_rows ;
      when 'NOTIFICATION_RCVRY' then
        execute immediate 'select count(*) from '|| v_owner ||'.'||v_tab||' wher
e note_creation_day = '||v_highvalue
          into v_num_of_rows ;
      when 'POSITION_KEEPING_ACCOUNT' then
         execute immediate 'select count(*) from '||v_owner||'.'||v_tab||' where
 position_day = '||v_highvalue
         into v_num_of_rows ;
      else

DBMS_METADATA.GET_DDL('PACKAGE','MANAGE_PARTITIONS','DBA_ADMIN')
--------------------------------------------------------------------------------
         execute immediate 'select count(*) from '||v_owner||'.'||v_tab||' where
 trading_day = '||v_highvalue
         into v_num_of_rows ;
         DBMS_OUTPUT.PUT_LINE('TABLE NAME: '||v_tab||' ROW COUNT: '||v_num_of_ro
ws||' HIGH_VALUE: '||v_highvalue||' TRAD DAY: '||v_trad_day);
   end case;
 if v_num_of_rows <= 0 and v_highvalue < v_trad_day then
      DBMS_OUTPUT.PUT_LINE('Owner: '||v_owner||' Table '||v_tab||', Trading Day
'||v_highvalue||', Partion name, ' || v_part||' is empty');
      case v_tab
         when 'NOTIFICATION' then

DBMS_METADATA.GET_DDL('PACKAGE','MANAGE_PARTITIONS','DBA_ADMIN')
--------------------------------------------------------------------------------
            DBMS_OUTPUT.PUT_LINE('REMOVING: Owner: '||v_owner||' Table: '||v_tab
||' Partition name to delete is: ' || v_part);
            --execute immediate 'alter table '||v_owner||'.'||v_tab ||' drop par
tition '|| v_part;
             DBMS_OUTPUT.PUT_LINE('ROW COUNT: '||v_num_of_rows||' HIGH_VALUE: '|
|v_highvalue||' TRAD DAY: '||v_trad_day);
             DBMS_OUTPUT.PUT_LINE('REMOVED: Partition : ' || v_part);
         when 'POSITION_KEEPING_ACCOUNT' then
            DBMS_OUTPUT.PUT_LINE('NOT REMOVED: Partition name: ' || v_part);
         else
            DBMS_OUTPUT.PUT_LINE('REMOVING: Owner: '||v_owner||' Table: '||v_tab

DBMS_METADATA.GET_DDL('PACKAGE','MANAGE_PARTITIONS','DBA_ADMIN')
--------------------------------------------------------------------------------
||' Partition name to delete is: ' || v_part);
            --execute immediate 'alter table '||v_owner||'.'||v_tab ||' drop par
tition '|| v_part;
             DBMS_OUTPUT.PUT_LINE('ROW COUNT: '||v_num_of_rows||' HIGH_VALUE: '|
|v_highvalue||' TRAD DAY: '||v_trad_day);
            DBMS_OUTPUT.PUT_LINE('REMOVED: Partition : ' || v_part);
         end case;
   end if;
end loop;
end delete_partitions;
END manage_partitions;

DBMS_METADATA.GET_DDL('PACKAGE','MANAGE_PARTITIONS','DBA_ADMIN')
--------------------------------------------------------------------------------



SQL>
