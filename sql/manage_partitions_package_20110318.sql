create or replace
PACKAGE             "MANAGE_PARTITIONS" AS
/***********************************************************************************************************************
 Change History:
 Date          Name                     Description
 ----          ----                     -----------
 19/01/2011    Gareth Spicer            Initial Design
***********************************************************************************************************************/
PROCEDURE CREATE_PARTITIONS
( p_schema            IN      VARCHAR2,
  p_cnt_part  	      IN      NUMBER
);
PROCEDURE CREATE_HALF_TRADE_PART
 ( p_schema            IN      VARCHAR2,
   p_part_cnt          IN      NUMBER,
   p_trad_day	       IN      NUMBER
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

PROCEDURE             CREATE_NOTIFICATION_RCVRY_PART
( p_schema            IN      VARCHAR2,
  p_part_cnt          IN      NUMBER,
  p_trad_day          IN      NUMBER
);

PROCEDURE             CREATE_PKA_PART
( p_schema            IN      VARCHAR2,
  p_part_cnt          IN      NUMBER,
  p_trad_day          IN      NUMBER
);

PROCEDURE             CREATE_PKT_PART
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

create or replace
PACKAGE BODY             "MANAGE_PARTITIONS" as
/***********************************************************************************************************************
 Change History:
 Date          Name                     Description
 ----          ----                     -----------
 19/01/2011    Gareth Spicer            Initial Design
***********************************************************************************************************************/
PROCEDURE CREATE_PARTITIONS
(p_schema            IN      VARCHAR2,
 p_cnt_part  	     IN      NUMBER
)
AS
  v_trad_day    number;
   BEGIN
      select get_trading_day(p_schema)
        into v_trad_day
        from dual;
    CREATE_HALF_TRADE_PART(p_schema,p_cnt_part,v_trad_day);
    CREATE_MESSAGE_AUDIT_PART(p_schema,p_cnt_part,v_trad_day);
    CREATE_NOTIFICATION_PART(p_schema,p_cnt_part,v_trad_day);
END CREATE_PARTITIONS;

PROCEDURE             CREATE_HALF_TRADE_PART
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
    lock_table_stats(p_schema, 'HALF_TRADE','UNLOCK');
    FOR x in 1..p_part_cnt
         LOOP
      v_nxt_trad_day := p_trad_day + v_cnt;
      dbms_output.put_line('trading_day is....'||p_trad_day||' next trading_day is '||v_nxt_trad_day);
      dbms_output.put_line('insert into half_trade values.....'||v_nxt_trad_day);
        select get_partition_name(p_schema,'HALF_TRADE')
          into v_src_part_name
          from dual;
      dbms_output.put_line('source partition....'||v_src_part_name);
    execute immediate 'insert into '||p_schema||'.half_trade
                              select HALF_TRADE_ID,HALF_TRADE_SRC_ID,SUB_TRADE_SEQ_NO,'||v_nxt_trad_day||
                                     ',MATCH_SEQ_NO,TRADE_STATUS,SLIP_TYPE,TRADE_TYPE,EXCHANGE_CODE,
                                     TRADER_CARD_REF,TRADED_DATE,ENTERED_DATE,MODIFIED_DATE,MATCHED_DATE,
                                     ASSIGNED_DATE,ORIGINATOR_TRADER,ORIGINATOR_FIRM,ORIGINATOR_CLEARER,
                                     COUNTERPARTY_TRADER,COUNTERPARTY_FIRM,COUNTERPARTY_CLEARER,COUNTERTRADE_ID,
                                     COUNTERTRADE_SRC_ID,COUNTERTRADE_SUB_NO,BUY_SELL_IND,CONTRACT_TYPE,GENERIC_CONTRACT_TYPE,
                                      PHYSICAL_COMMODITY,LOGICAL_COMMODITY,DELIVERY_MONTH,EXPIRY_DATE,EXERCISE_PRICE,VOLUME,
                                     ACCOUNT_CODE,OPEN_CLOSE_IND,ALLOCATION_TRADER,ALLOCATION_FIRM,ALLOCATION_CLEARER,
                                     COUNTERCLAIM_ID,COUNTERCLAIM_SRC_ID,OPERATOR_NAME,USER_INFO,TRADE_CHARGE_IND,
                                     TRADING_ENVIRONMENT,MARGINING_ACCOUNT,CROSS_TYPE,KERB_TRANSFER_ORIG_NOTE_ID,KERB_TRANSFER_DEST_NOTE_ID,
                                     ORDER_SLIP_ID,TIME_BRACKET,KERB_TREE_IND,TRADE_ENTRY_METHOD_IND,TRANSFER_IND,TRANSFER_PRICE,
                                     ORIG_TRADING_DAY,ORIG_SLIP_NO,ORIG_SLIP_SRC_ID,ORIG_SUB_TRADE_SEQ_NO,SUB_ACCOUNT,TRANSFER_DAY,
                                     CONTRA_VOLUME,PRE_DEFAULT_TRADE_STATUS,PRE_DEFAULT_ACCOUNT_CODE,PRE_DEFAULT_ALLOC_TRADER,
                                     PRE_DEFAULT_ALLOC_FIRM,PRE_DEFAULT_ALLOC_CLEARER,PRE_DEFAULT_SUB_ACCOUNT,POSITION_REF,
                                     DID_CLOSING_SETTLEMENT_IND,OTIS_SLIP_ID,OTIS_CTI,OTIS_FBA,EXTERN_CLOSING_IND,POSITION_STATUS,
                                     PREASSIGNED_ACCOUNT_CODE,TSCS_TX_IND,OTIS_ORIGIN,TRADE_DATE,OTIS_NETTING_RULE_IND,TRADE_PRICE,
                                     VALUATION_PRICE,EXTERN_TRADE_DATE,AUTHORISATION_STATE_IND,CUSTOMER_TYPE_IND,DESIGNATED_ACCOUNT,
                                     CUSTOMER_REF,SESSION_ID,TRADE_CLIP_ID,ORDER_ID,AGGRESSOR,STRATEGY_CODE,POSTING_CODE,
                                     PRODUCT_IDENTIFICATION,TRADE_LOCKED_IND,TRANSACTION_ID,TRS_TRADE_STATUS,TRS_ACCOUNT_CODE,
                                     TRS_ALLOCATION_TRADER,TRS_ALLOCATION_FIRM,TRS_ALLOCATION_CLEARER,TRS_OPEN_CLOSE_IND,
                                     TRS_POSITION_REF,TRS_MARGINING_ACCOUNT,KERB_TRADE_IND,TRS_KERB_TREE_IND,TRS_MODIFIED_DATE,
                                     TRS_MATCHED_DATE,KERB_MODIFIED_IND,COUNTERPARTY_ANONYMOUS_FIRM,COUNTERPARTY_ANONYMOUS_TRADER,
                                     TRS_KERB_TRADE_STATUS,TRS_SUB_ACCOUNT,TRANSACTION_ACTION_FLAG
                                from '||p_schema||'.half_trade
                               where rownum < 2';
 	rollback;

       dbms_output.put_line('new partition created');

       select get_partition_name(p_schema,'HALF_TRADE')
	          into v_new_part_name
          from dual;

         dbms_output.put_line('new partition.......'||v_new_part_name);

       update TRIDENT_TAB_STATS
          set c2 = replace(c2, v_src_part_name, v_new_part_name)
        where c1 = 'HALF_TRADE';

       commit;

        get_table_stats(p_schema,'HALF_TRADE',v_new_part_name);

       v_cnt := v_cnt+1;

     END LOOP;

     lock_table_stats(p_schema, 'HALF_TRADE','LOCK');

   END CREATE_HALF_TRADE_PART;


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


     dbms_output.put_line('trading_day is....'||p_trad_day||' next trading_day is '||v_nxt_trad_day);
     dbms_output.put_line('insert into MESSAGE_AUDIT values.....'||v_nxt_trad_day);

     v_nxt_trad_day := p_trad_day + v_cnt;

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

        dbms_output.put_line('trading_day is....'||p_trad_day||' next trading_day is '||v_nxt_trad_day);
        dbms_output.put_line('insert into NOTIFICATION values.....'||v_nxt_trad_day);

        v_nxt_trad_day := p_trad_day + v_cnt;

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


PROCEDURE             CREATE_NOTIFICATION_RCVRY_PART
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
    v_cnt := 1;
    lock_table_stats(p_schema, 'NOTIFICATION_RCVRY','UNLOCK');
    FOR x in 1..p_part_cnt
         LOOP
         v_nxt_trad_day := p_trad_day + v_cnt;
      dbms_output.put_line('trading_day is....'||p_trad_day||' next trading_day is '||v_nxt_trad_day);
      dbms_output.put_line('insert into NOTIFICATION_RCVRY values.....'||v_nxt_trad_day);
       select get_trading_day(p_schema)
         into v_nxt_trad_day
         from dual;
         v_nxt_trad_day := v_nxt_trad_day + v_cnt;
        select get_partition_name(p_schema,'NOTIFICATION_RCVRY')
          into v_src_part_name
          from dual;
      dbms_output.put_line('source partition....'||v_src_part_name);
     execute immediate 'insert into '||p_schema||'.NOTIFICATION_RCVRY
                                  SELECT  EXCHANGE_CODE,NOTIFICATION_ID,NOTIFICATION_SRC_ID,NOTIFICATION_TYPE,NOTIFICATION_SRC,
    			              '||v_nxt_trad_day||' ,VOLUME_CHANGE,ENTERED_DATE,MATCHED_DATE,MODIFIED_DATE,CLEARER,FIRM,
    			              TRADER,ACCOUNT_CODE,POSITION_REF,CONTRACT_TYPE,GENERIC_CONTRACT_TYPE,PHYSICAL_COMMODITY,
    			              LOGICAL_COMMODITY,EXPIRY_DATE,EXERCISE_PRICE,VALUATION_PRICE,COUNTERPARTY_FIRM,COUNTERPARTY_TRADER,
    			              OPERATOR_NAME,USER_INFO,POSITION_DAY,TENDER_DELETION_DAY,NEW_TENDER_DELETION_DAY,MARGINING_ACCOUNT,
    			              COUNTERNOTE_ID,COUNTERNOTE_SRC_ID,COUNTERTRADE_ID,COUNTERTRADE_SRC_ID,COUNTERTRADE_SUB_NO,
    			              COUNTERTRADE_VOLUME,NOTE_PROCESSED_DAY,MATCH_SEQ_NO,ALL_LOTS_IND,NOTIFICATION_STATUS,ADJUSTED_VOLUME_CHANGE,
    			              ADJUST_NON_MARG_VOLUME,LOT_SIZE,OLD_VALUATION_PRICE,PAY_COLLECT,PREMIUM_PAY_COLLECT,CONTINGENT_MARGIN,
    			              PAID_VARIATION,PAID_CONTINGENT,POSITION_TYPE,ALT_DELIVERABLE_IND,TRADE_CHARGE_IND,LONG_SHORT_IND,
    			              SUB_ACCOUNT,POSITION_STATUS,CORRECTION_TYPE,TRANSFER_METHOD,EXTERN_EXCHANGE_ID,GUARANTEE_ACCOUNT,
    			              ALLOCATION_TRADER,ALLOCATION_FIRM,GHOST_FLAG,COUNTERPARTY_ANONYMOUS_FIRM,COUNTERPARTY_ANONYMOUS_TRADER,
    			              REFERENCE_DAY,EXERCISE_VALUE,PROFIT_CHANGE,CLEARING_JOB_ID,EXECUTION_DAY,EXECUTION_JOB_ID,EXECUTION_SEQUENCE,
            			      RECOVERY_TIMESTAMP
                                    from '||p_schema||'.NOTIFICATION_RCVRY
                               where rownum < 2';
 	rollback;
       dbms_output.put_line('new partition created');
 	select get_partition_name(p_schema,'NOTIFICATION_RCVRY')
	          into v_new_part_name
          from dual;
         --dbms_output.put_line('source partition....'||v_src_part_name);
         dbms_output.put_line('new partition.......'||v_new_part_name);
         update TRIDENT_TAB_STATS
           set c2 = replace(c2, v_src_part_name, v_new_part_name)
           where c1 = 'NOTIFICATION_RCVRY';
         commit;
          get_table_stats(p_schema,'NOTIFICATION_RCVRY',v_new_part_name);
         v_cnt := v_cnt+1;
     END LOOP;
      lock_table_stats(p_schema, 'NOTIFICATION_RCVRY','LOCK');
   END CREATE_NOTIFICATION_RCVRY_PART;

PROCEDURE             CREATE_PKA_PART
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
    v_cnt := 1;
    lock_table_stats(p_schema, 'POSITION_KEEPING_ACCOUNT','UNLOCK');
    FOR x in 1..p_part_cnt
         LOOP
         v_nxt_trad_day := p_trad_day + v_cnt;
      dbms_output.put_line('trading_day is....'||p_trad_day||' next trading_day is '||v_nxt_trad_day);
      dbms_output.put_line('insert into POSITION_KEEPING_ACCOUNT values.....'||v_nxt_trad_day);
       select get_trading_day(p_schema)
         into v_nxt_trad_day
         from dual;
         v_nxt_trad_day := v_nxt_trad_day + v_cnt;
        select get_partition_name(p_schema,'POSITION_KEEPING_ACCOUNT')
          into v_src_part_name
          from dual;
      dbms_output.put_line('source partition....'||v_src_part_name);
     execute immediate 'insert into '||p_schema||'.POSITION_KEEPING_ACCOUNT
                                  SELECT POSITION_REF,EXCHANGE_CODE,'||v_nxt_trad_day||' ,PHYSICAL_COMMODITY,CONTRACT_TYPE,
    			             EXPIRY_DATE,EXERCISE_PRICE,LOGICAL_COMMODITY,GENERIC_CONTRACT_TYPE,
    			             TRADER,FIRM,CLEARER,ACCOUNT_CODE,MARGIN_ACCOUNT,SUB_ACCOUNT,VALUATION_PRICE,
    			             LOT_SIZE,VOLUME,LONG_ACCOUNT_VOL,LONG_ADJUSTED_VOL,SHORT_ACCOUNT_VOL,
    			             SHORT_ADJUSTED_VOL,LONG_TRADED_VOL,LONG_TRADES_CNT,SHORT_TRADED_VOL,
    			             SHORT_TRADES_CNT,LONG_KERB_TRADE_CNT,LONG_KERB_TRADE_VOL,SHORT_KERB_TRADE_CNT,
    			             SHORT_KERB_TRADE_VOL,LONG_CONTRA_VOL,LONG_CREATE_VOL,SHORT_CONTRA_VOL,
    			             SHORT_CREATE_VOL,LONG_CABINET_VOL,SHORT_CABINET_VOL,MAN_SETTLED_VOL,
    			             AUTO_SETTLED_VOL,MAN_UNSETTLED_VOL,LONG_TRANSFERRED_IN_VOL,LONG_TRANSFERRED_OUT_VOL,
    			             SHORT_TRANSFERRED_IN_VOL,SHORT_TRANSFERRED_OUT_VOL,MAN_EXERCISED_VOL,AUTO_EXERCISED_VOL,
    			             MAN_ABANDONED_VOL,LONG_RESULT_OF_EXERCISE_VOL,SHORT_RESULT_OF_EXERCISE_VOL,LONG_EXPIRED_VOL,
    			             SHORT_EXPIRED_VOL,MAN_DELIVERED_VOL,AUTO_DELIVERED_VOL,LOTS_ASSIGNED_VOL,LONG_RESULT_OF_ASSIGN_VOL,
    			             SHORT_RESULT_OF_ASSIGN_VOL,LONG_TRANSFERRED_EXTRNL_VOL,SHORT_TRANSFERRED_EXTRNL_VOL,
    			             PROFIT,PREMIUM,CONTINGENT_MARGIN,CONTINGENT_PRICE,CABINET_TRADE_VALUE,AUTO_EXERCISE_NOTIFICATION,
           EOD_RECONCILIATION_FLAG,LONG_BF_CORRECTED_VOL,SHORT_BF_CORRECTED_VOL
                                    from '||p_schema||'.POSITION_KEEPING_ACCOUNT
                               where rownum < 2';
 	rollback;
       dbms_output.put_line('new partition created');
 	select get_partition_name(p_schema,'POSITION_KEEPING_ACCOUNT')
	          into v_new_part_name
          from dual;
         --dbms_output.put_line('source partition....'||v_src_part_name);
         dbms_output.put_line('new partition.......'||v_new_part_name);
         update TRIDENT_TAB_STATS
           set c2 = replace(c2, v_src_part_name, v_new_part_name)
           where c1 = 'POSITION_KEEPING_ACCOUNT';
         commit;
          get_table_stats(p_schema,'POSITION_KEEPING_ACCOUNT',v_new_part_name);
         v_cnt := v_cnt+1;
     END LOOP;
      lock_table_stats(p_schema, 'POSITION_KEEPING_ACCOUNT','LOCK');
   END CREATE_PKA_PART;

PROCEDURE             CREATE_PKT_PART
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
    v_cnt := 1;
    lock_table_stats(p_schema, 'POSITION_KEEP_TRACKING','UNLOCK');
    FOR x in 1..p_part_cnt
         LOOP
         v_nxt_trad_day := p_trad_day + v_cnt;
      dbms_output.put_line('trading_day is....'||p_trad_day||' next trading_day is '||v_nxt_trad_day);
      dbms_output.put_line('insert into POSITION_KEEP_TRACKING values.....'||v_nxt_trad_day);
       select get_trading_day(p_schema)
         into v_nxt_trad_day
         from dual;
         v_nxt_trad_day := v_nxt_trad_day + v_cnt;
        select get_partition_name(p_schema,'POSITION_KEEP_TRACKING')
          into v_src_part_name
          from dual;
      dbms_output.put_line('source partition....'||v_src_part_name);
    execute immediate 'insert into POSITION_KEEP_TRACKING
                                  select '||v_nxt_trad_day||' exchange_code, ai_partition_no,
                                         output_sequence_no, event_mnemonic
                                    from '||p_schema||'.POSITION_KEEP_TRACKING
                               where rownum < 2';
 	rollback;
       dbms_output.put_line('new partition created');
 	select get_partition_name(p_schema,'POSITION_KEEP_TRACKING')
	          into v_new_part_name
          from dual;

        dbms_output.put_line('new partition.......'||v_new_part_name);

        update TRIDENT_TAB_STATS
           set c2 = replace(c2, v_src_part_name, v_new_part_name)
           where c1 = 'POSITION_KEEP_TRACKING';
         commit;
          get_table_stats(p_schema,'POSITION_KEEP_TRACKING',v_new_part_name);
         v_cnt := v_cnt+1;
     END LOOP;
      lock_table_stats(p_schema, 'POSITION_KEEP_TRACKING','LOCK');
   END CREATE_PKT_PART;

FUNCTION GET_TRADING_DAY
(
 p_schema IN  VARCHAR2
)
RETURN NUMBER
AS
 v_trad_day number;
BEGIN
   execute immediate 'select max(trading_day) from '||p_schema||'.trading_day where component_name = ''POSITION_MAINTENANCE''' into v_trad_day;
RETURN v_trad_day;
END GET_TRADING_DAY;
FUNCTION GET_PARTITION_NAME
(
 p_schema    IN  VARCHAR2,
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
 p_new_part in varchar2
)
AS
BEGIN
         dbms_stats.import_table_stats(ownname=>p_schema,tabname=>p_tab_name,partname=>p_new_part,stattab=>'TRIDENT_TAB_STATS',statown=>'DBA_ADMIN');
END get_table_stats;
PROCEDURE lock_table_stats
(
 p_schema   in varchar2,
 p_tab_name in varchar2,
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
END lock_table_stats;

PROCEDURE delete_partitions
(
 p_schema   in varchar2
)
AS

 v_tab varchar2(30);
 v_part varchar2(30);
 v_highvalue varchar2(30);
 v_num_of_rows number;
 v_trad_day varchar2(10);
 v_owner varchar2(100);

cursor part_get is
select table_owner, table_name, partition_name, high_value
  from dba_tab_partitions
  where partition_name like 'SYS_%' and table_owner=p_schema;

  
begin


 select GET_TRADING_DAY(p_schema)
   into v_trad_day
   from dual;


for x in part_get
loop
v_owner := x.table_owner;
v_tab := x.table_name;
v_part := x.partition_name;
v_highvalue := x.high_value;

 case v_tab
      when 'NOTIFICATION' then
         execute immediate 'select count(*) from '||v_owner||'.'||v_tab||' where note_creation_day = '||v_highvalue
         into v_num_of_rows ;
      when 'POSITION_KEEPING_ACCOUNT' then
         execute immediate 'select count(*) from '||v_owner||'.'||v_tab||' where position_day = '||v_highvalue
         into v_num_of_rows ;
      else
         execute immediate 'select count(*) from '||v_owner||'.'||v_tab||' where trading_day = '||v_highvalue
         into v_num_of_rows ;
   end case;

 if v_num_of_rows <= 0 and v_highvalue <= v_trad_day then
      DBMS_OUTPUT.PUT_LINE('Owner: '||v_owner||' Table '||v_tab||', Trading Day '||v_highvalue||', Partion name, ' || v_part||' is empty');
      case v_tab
         when 'NOTIFICATION' then
            DBMS_OUTPUT.PUT_LINE('REMOVING: Owner: '||v_owner||' Table: '||v_tab||' Partition name to delete is: ' || v_part);
            execute immediate 'alter table '||v_owner||'.'||v_tab ||' drop partition '|| v_part;
             DBMS_OUTPUT.PUT_LINE('REMOVED: Partition : ' || v_part);
         when 'POSITION_KEEPING_ACCOUNT' then
            DBMS_OUTPUT.PUT_LINE('NOT REMOVED: Partition name: ' || v_part);
         else
            DBMS_OUTPUT.PUT_LINE('REMOVING: Owner: '||v_owner||' Table: '||v_tab||' Partition name to delete is: ' || v_part);
            execute immediate 'alter table '||v_owner||'.'||v_tab ||' drop partition '|| v_part;
            DBMS_OUTPUT.PUT_LINE('REMOVED: Partition : ' || v_part);
         end case;
   end if;

end loop;
end delete_partitions;

END manage_partitions;
/
