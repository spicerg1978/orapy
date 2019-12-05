create or replace
package manage_partitions AS
/***********************************************************************************************************************
 Change History:
 Date          Name                     Description
 ----          ----                     -----------
 19/01/2011    Gareth Spicer            Initial Design
***********************************************************************************************************************/
PROCEDURE CREATE_PARTITIONS
( p_schema            IN      VARCHAR2
);

PROCEDURE CREATE_HALF_TRADE_PART
 ( p_schema            IN      VARCHAR2,
   p_part_cnt          IN      NUMBER,
   p_trad_day	       IN      NUMBER
);
PROCEDURE CREATE_MESSAGE_AUDIT_PART
 ( p_schema            IN      VARCHAR2,
   p_part_cnt          IN      NUMBER,
   p_trad_day	       IN      NUMBER
);
PROCEDURE CREATE_NOTIFICATION_PART
 ( p_schema            IN      VARCHAR2,
   p_part_cnt          IN      NUMBER,
   p_trad_day	       IN      NUMBER
);
PROCEDURE CREATE_NOTIFICATION_RCVRY_PART
 ( p_schema            IN      VARCHAR2,
   p_part_cnt          IN      NUMBER,
   p_trad_day	       IN      NUMBER
);
PROCEDURE CREATE_PKA_PART
 ( p_schema            IN      VARCHAR2,
   p_part_cnt          IN      NUMBER,
   p_trad_day	       IN      NUMBER
);
PROCEDURE CREATE_PKT_PART
 ( p_schema            IN      VARCHAR2,
   p_part_cnt          IN      NUMBER,
   p_trad_day	       IN      NUMBER
);
PROCEDURE CREATE_RISK_OPEN_POS_PART
 ( p_schema            IN      VARCHAR2,
   p_part_cnt          IN      NUMBER,
   p_trad_day	       IN      NUMBER
);
FUNCTION GET_TRADING_DAY
(  p_schema            IN      VARCHAR2
)
RETURN NUMBER;
END manage_partitions;
/

create or replace package body manage_partitions as
/***********************************************************************************************************************
 Change History:
 Date          Name                     Description
 ----          ----                     -----------
 19/01/2011    Gareth Spicer            Initial Design
***********************************************************************************************************************/
PROCEDURE CREATE_PARTITIONS
(
)
  v_trad_day    number;       
AS
   BEGIN
      
      select get_trading_day(v_trad_day)
        into v_trad_day
        from dual;
    
    CREATE_HALF_TRADE_PART(p_schema,5,v_trad_day);
      
END CREATE_PARTITIONS;

PROCEDURE             CREATE_HALF_TRADE_PART
( p_schema            IN      VARCHAR2,
  p_part_cnt          IN      NUMBER,
  p_trad_day          IN      NUMBER
)
    AS
      v_trad_day           number;
    --  x                    number:=1;
    --  v_ldata              long;
      v_src_part_name      varchar2(30);
      v_new_part_name      varchar2(30);
      v_cnt                number;
      v_nxt_trad_day       number;
   BEGIN
    v_cnt := 1;
    FOR x in 1..p_part_cnt
         LOOP
         v_nxt_trad_day := p_trad_day + v_cnt;
         dbms_output.put_line('trading_day is....'||p_trad_day||' next trading_day is '||v_nxt_trad_day);
         dbms_output.put_line('insert into half_trade values.....'||v_nxt_trad_day);
 execute immediate 'insert into half_trade
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
 	select partition_name
            into v_src_part_name
           from dba_tab_partitions
          where table_name = 'HALF_TRADE'
            and table_owner = p_schema
            and partition_position = (select min(partition_position) from dba_tab_partitions
                                  where table_name = 'HALF_TRADE'
                                    and table_owner = p_schema
                                         and partition_position != 1);
	 select partition_name
            into v_new_part_name
           from dba_tab_partitions
         where table_name = 'HALF_TRADE'
            and table_owner = p_schema
            and partition_position = (select max(partition_position)
                                   from dba_tab_partitions
                                  where table_name = 'HALF_TRADE'
                                   and table_owner = p_schema
                                     );
         dbms_output.put_line('source partition....'||v_src_part_name);
         dbms_output.put_line('new partition.......'||v_new_part_name);
         dbms_stats.unlock_table_stats(,'HALF_TRADE');
         --dbms_output.put_line('ownname => p_schema, tabname => HALF_TRADE, srcpartname => '||v_src_part_name||', dstpartname =>'||v_new_part_name);
	 --dbms_output.put_line(v_cnt);
         dbms_stats.copy_table_stats(ownname => p_schema, tabname => 'HALF_TRADE', srcpartname => v_src_part_name, dstpartname =>v_new_part_name);
         dbms_stats.lock_table_stats(user,'HALF_TRADE');
         v_cnt := v_cnt+1;
      END LOOP;
   END CREATE_HALF_TRADE_PART;
   
    PROCEDURE             CREATE_MESSAGE_AUDIT_PART
    ( p_schema            IN      VARCHAR2,
      p_part_cnt          IN      NUMBER,
      p_trad_day	  IN      NUMBER
    )
    AS
      v_trad_day           number;
      x                    number:=1;
      v_ldata              long;
      v_src_part_name      varchar2(30);
      v_new_part_name      varchar2(30);
      v_cnt                number;
      v_nxt_trad_day       number;
   BEGIN
    v_cnt := 1;
    FOR x in 1..5
         LOOP
         v_nxt_trad_day := v_trad_day + v_cnt;
         dbms_output.put_line('trading_day is....'||p_trad_day||' next trading_day is '||v_nxt_trad_day);
         dbms_output.put_line('insert into MESSAGE_AUDIT values.....'||v_nxt_trad_day);
 execute immediate 'insert into '||p_schema||'.MESSAGE_AUDIT
                              select  '||v_nxt_trad_day||' ,EXCHANGE_CODE,OUTPUT_SEQUENCE_NO,MESSAGE_ID,TRANSACTION_ID,
			              EXTERNAL_IND,MESSAGE_SRC,CLASS,FIRM,SERIES_PARTITION_KEY,
			              MESSAGE_TYPE,SLIP_ID,MESSAGE_DATA_VERSION,CREATION_DAY,ACTION_FLAG,MESSAGE_DATA
                                from '||p_schema||'.MESSAGE_AUDIT
                               where rownum < 2';
 	rollback;
 	select partition_name
            into v_src_part_name
           from dba_tab_partitions
          where table_name = 'MESSAGE_AUDIT'
            and table_owner = p_schema
            and partition_position = (select min(partition_position) from dba_tab_partitions
                                  where table_name = 'MESSAGE_AUDIT'
                                    and table_owner = p_schema
                                         and partition_position != 1);
	 select partition_name
            into v_new_part_name
           from dba_tab_partitions
         where table_name = 'MESSAGE_AUDIT'
            and table_owner = p_schema
            and partition_position = (select max(partition_position)
                                   from dba_tab_partitions
                                  where table_name = 'MESSAGE_AUDIT'
                                   and table_owner = p_schema
                                     );
         dbms_output.put_line('source partition....'||v_src_part_name);
         dbms_output.put_line('new partition.......'||v_new_part_name);
         dbms_stats.unlock_table_stats(user,'MESSAGE_AUDIT');
         dbms_stats.copy_table_stats(ownname => p_schema, tabname => 'MESSAGE_AUDIT', srcpartname => v_src_part_name, dstpartname =>v_new_part_name);
         dbms_stats.lock_table_stats(user,'MESSAGE_AUDIT');
         v_cnt := v_cnt+1;
      END LOOP;
   END CREATE_MESSAGE_AUDIT_PART;
   
 PROCEDURE             CREATE_NOTIFICATION_PART
    ( p_schema            IN      VARCHAR2,
      p_part_cnt          IN      NUMBER,
      p_trad_day          IN      NUMBER
    )
    AS
      v_trad_day           number;
      x                    number:=1;
      v_ldata              long;
      v_src_part_name      varchar2(30);
      v_new_part_name      varchar2(30);
      v_cnt                number;
      v_nxt_trad_day       number;
   BEGIN
    v_cnt := 1;
    FOR x in 1..5
         LOOP
         v_nxt_trad_day := v_trad_day + v_cnt;
         dbms_output.put_line('trading_day is....'||v_trad_day||' next trading_day is '||v_nxt_trad_day);
         dbms_output.put_line('insert into NOTIFICATION values.....'||v_nxt_trad_day);
 execute immediate 'insert into NOTIFICATION
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
			             ALT_DELIVERABLE_IND,TRADE_CHARGE_IND,LONG_SHORT_IND,SUB_ACCOUNT,POSITION_STATUS,CORRECTION_TYPE
			             TRANSFER_METHOD,EXTERN_EXCHANGE_ID,GUARANTEE_ACCOUNT,ALLOCATION_TRADER,ALLOCATION_FIRM,
			             GHOST_FLAG,COUNTERPARTY_ANONYMOUS_FIRM,COUNTERPARTY_ANONYMOUS_TRADER,REFERENCE_DAY,EXERCISE_VALUE
       PROFIT_CHANGE,CLEARING_JOB_ID
                                from '||p_schema||'.NOTIFICATION
                               where rownum < 2';
 	rollback;
 	select partition_name
            into v_src_part_name
           from dba_tab_partitions
          where table_name = 'NOTIFICATION'
            and table_owner = p_schema
            and partition_position = (select min(partition_position) from dba_tab_partitions
                                  where table_name = 'NOTIFICATION'
                                    and table_owner = p_schema
                                         and partition_position != 1);
	 select partition_name
            into v_new_part_name
           from dba_tab_partitions
         where table_name = 'NOTIFICATION'
            and table_owner = p_schema
            and partition_position = (select max(partition_position)
                                   from dba_tab_partitions
                                  where table_name = 'NOTIFICATION'
                                   and table_owner = p_schema
                                     );
         dbms_output.put_line('source partition....'||v_src_part_name);
         dbms_output.put_line('new partition.......'||v_new_part_name);
         dbms_stats.unlock_table_stats(user,'NOTIFICATION');
         dbms_stats.copy_table_stats(ownname => p_schema, tabname => 'NOTIFICATION', srcpartname => v_src_part_name, dstpartname =>v_new_part_name);
         dbms_stats.lock_table_stats(user,'NOTIFICATION');
         v_cnt := v_cnt+1;
      END LOOP;
   END CREATE_NOTIFICATION_PART;
   
    PROCEDURE             CREATE_NOTIFICATION_RCVRY_PART
    ( p_schema            IN      VARCHAR2,
      p_part_cnt          IN      NUMBER,
      p_trad_day          IN      NUMBER
    )
    AS
      v_trad_day           number;
      x                    number:=1;
      v_ldata              long;
      v_src_part_name      varchar2(30);
      v_new_part_name      varchar2(30);
      v_cnt                number;
      v_nxt_trad_day       number;
   BEGIN
    v_cnt := 1;
    FOR x in 1..5
         LOOP
         v_nxt_trad_day := v_trad_day + v_cnt;
         dbms_output.put_line('trading_day is....'||p_trad_day||' next trading_day is '||v_nxt_trad_day);
         dbms_output.put_line('insert into NOTIFICATION_RCVRY values.....'||v_nxt_trad_day);
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
 	select partition_name
            into v_src_part_name
           from dba_tab_partitions
          where table_name = 'NOTIFICATION_RCVRY'
            and table_owner = p_schema
            and partition_position = (select min(partition_position) from dba_tab_partitions
                                  where table_name = 'NOTIFICATION_RCVRY'
                                    and table_owner = p_schema
                                         and partition_position != 1);
	 select partition_name
            into v_new_part_name
           from dba_tab_partitions
         where table_name = 'NOTIFICATION_RCVRY'
            and table_owner = p_schema
            and partition_position = (select max(partition_position)
                                   from dba_tab_partitions
                                  where table_name = 'NOTIFICATION_RCVRY'
                                   and table_owner = p_schema
                                     );
         dbms_output.put_line('source partition....'||v_src_part_name);
         dbms_output.put_line('new partition.......'||v_new_part_name);
         dbms_stats.unlock_table_stats(user,'NOTIFICATION_RCVRY');
         dbms_stats.copy_table_stats(ownname => p_schema, tabname => 'NOTIFICATION_RCVRY', srcpartname => v_src_part_name, dstpartname =>v_new_part_name);
         dbms_stats.lock_table_stats(user,'NOTIFICATION_RCVRY');
         v_cnt := v_cnt+1;
      END LOOP;
   END CREATE_NOTIFICATION_RCVRY_PART;
   
    PROCEDURE             CREATE_PKA_PART
    ( p_schema            IN      VARCHAR2,
      p_part_cnt          IN      NUMBER,
      p_trad_day	  IN      NUMBER
    )
    AS
      v_trad_day           number;
      x                    number:=1;
      v_ldata              long;
      v_src_part_name      varchar2(30);
      v_new_part_name      varchar2(30);
      v_cnt                number;
      v_nxt_trad_day       number;
   BEGIN
    v_cnt := 1;
    FOR x in 1..5
         LOOP
         v_nxt_trad_day := v_trad_day + v_cnt;
         dbms_output.put_line('trading_day is....'||v_trad_day||' next trading_day is '||v_nxt_trad_day);
         dbms_output.put_line('insert into POSITION_KEEPING_ACCOUNT values.....'||v_nxt_trad_day);
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
 	select partition_name
            into v_src_part_name
           from dba_tab_partitions
          where table_name = 'POSITION_KEEPING_ACCOUNT'
            and table_owner = p_schema
            and partition_position = (select min(partition_position) from dba_tab_partitions
                                  where table_name = 'POSITION_KEEPING_ACCOUNT'
                                    and table_owner = p_schema
                                         and partition_position != 1);
	 select partition_name
            into v_new_part_name
           from dba_tab_partitions
         where table_name = 'POSITION_KEEPING_ACCOUNT'
            and table_owner = p_schema
            and partition_position = (select max(partition_position)
                                   from dba_tab_partitions
                                  where table_name = 'POSITION_KEEPING_ACCOUNT'
                                   and table_owner = p_schema
                                     );
         dbms_output.put_line('source partition....'||v_src_part_name);
         dbms_output.put_line('new partition.......'||v_new_part_name);
         dbms_stats.unlock_table_stats(user,'POSITION_KEEPING_ACCOUNT');
         dbms_stats.copy_table_stats(ownname => p_schema, tabname => 'POSITION_KEEPING_ACCOUNT', srcpartname => v_src_part_name, dstpartname =>v_new_part_name);
         dbms_stats.lock_table_stats(user,'POSITION_KEEPING_ACCOUNT');
         v_cnt := v_cnt+1;
      END LOOP;
   END CREATE_PKA_PART;
   
    PROCEDURE             CREATE_PKT_PART
    ( p_schema            IN      VARCHAR2,
      p_part_cnt          IN      NUMBER,
      p_trad_day	  IN      NUMBER
    )
    AS
      v_trad_day           number;
      x                    number:=1;
      v_ldata              long;
      v_src_part_name      varchar2(30);
      v_new_part_name      varchar2(30);
      v_cnt                number;
      v_nxt_trad_day       number;
   BEGIN
   v_cnt := 1;
    FOR x in 1..5
         LOOP
         v_nxt_trad_day := v_trad_day + v_cnt;
         dbms_output.put_line('trading_day is....'||v_trad_day||' next trading_day is '||v_nxt_trad_day);
         dbms_output.put_line('insert into POSITION_KEEPING_TRACKING values.....'||v_nxt_trad_day);
 execute immediate 'insert into POSITION_KEEPING_ACCOUNT
                              select..
                                from '||p_schema||'.POSITION_KEEPING_TRACKING
                               where rownum < 2';
 	rollback;
 	select partition_name
            into v_src_part_name
           from dba_tab_partitions
          where table_name = 'POSITION_KEEPING_TRACKING'
            and table_owner = p_schema
            and partition_position = (select min(partition_position) from dba_tab_partitions
                                  where table_name = 'POSITION_KEEPING_TRACKING'
                                    and table_owner = p_schema
                                         and partition_position != 1);
	 select partition_name
            into v_new_part_name
           from dba_tab_partitions
         where table_name = 'POSITION_KEEPING_TRACKING'
            and table_owner = p_schema
            and partition_position = (select max(partition_position)
                                   from dba_tab_partitions
                                  where table_name = 'POSITION_KEEPING_TRACKING'
                                   and table_owner = p_schema
                                     );
         dbms_output.put_line('source partition....'||v_src_part_name);
         dbms_output.put_line('new partition.......'||v_new_part_name);
         dbms_stats.unlock_table_stats(user,'POSITION_KEEPING_TRACKING');
         dbms_stats.copy_table_stats(ownname => p_schema, tabname => 'POSITION_KEEPING_TRACKING', srcpartname => v_src_part_name, dstpartname =>v_new_part_name);
         dbms_stats.lock_table_stats(user,'POSITION_KEEPING_TRACKING');
         v_cnt := v_cnt+1;
      END LOOP;
   END CREATE_PKT_PART;
    PROCEDURE             CREATE_RISK_OPEN_POS_PART
    ( p_schema            IN      VARCHAR2,
      p_part_cnt          IN      NUMBER,
      p_trad_day	  IN      NUMBER
    )
    AS
      v_trad_day           number;
      x                    number:=1;
      v_ldata              long;
      v_src_part_name      varchar2(30);
      v_new_part_name      varchar2(30);
      v_cnt                number;
      v_nxt_trad_day       number;
   BEGIN
    v_cnt := 1;
    FOR x in 1..5
         LOOP
         v_nxt_trad_day := v_trad_day + v_cnt;
         dbms_output.put_line('trading_day is....'||v_trad_day||' next trading_day is '||v_nxt_trad_day);
         dbms_output.put_line('insert into RISK_OPEN_POSITION values.....'||v_nxt_trad_day);
 execute immediate 'insert into RISK_OPEN_POSITION
                              select....
                                from '||p_schema||'.RISK_OPEN_POSITION
                               where rownum < 2';
 	rollback;
 	select partition_name
            into v_src_part_name
           from dba_tab_partitions
          where table_name = 'RISK_OPEN_POSITION'
            and table_owner = p_schema
            and partition_position = (select min(partition_position) from dba_tab_partitions
                                  where table_name = 'RISK_OPEN_POSITION'
                                    and table_owner = p_schema
                                         and partition_position != 1);
	 select partition_name
            into v_new_part_name
           from dba_tab_partitions
         where table_name = 'RISK_OPEN_POSITION'
            and table_owner = p_schema
            and partition_position = (select max(partition_position)
                                   from dba_tab_partitions
                                  where table_name = 'RISK_OPEN_POSITION'
                                   and table_owner = p_schema
                                     );
         dbms_output.put_line('source partition....'||v_src_part_name);
         dbms_output.put_line('new partition.......'||v_new_part_name);
         dbms_stats.unlock_table_stats(user,'RISK_OPEN_POSITION');
         dbms_stats.copy_table_stats(ownname => p_schema, tabname => 'RISK_OPEN_POSITION', srcpartname => v_src_part_name, dstpartname =>v_new_part_name);
         dbms_stats.lock_table_stats(user,'RISK_OPEN_POSITION');
         v_cnt := v_cnt+1;
      END LOOP;
   END CREATE_RISK_OPEN_POS_PART;
   
FUNCTION GET_TRADING_DAY
(
 p_schema IN  VARCHAR2
)
RETURN NUMBER
AS
 v_trad_day number;
BEGIN
   execute immediate 'select max(trading_day) from trading_day where component_name = ''POSITION_MAINTENANCE''' into v_trad_day;
RETURN v_trad_day;
END GET_TRADING_DAY;

END manage_partitions;