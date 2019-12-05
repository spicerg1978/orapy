create or replace
PACKAGE tridlive.pkg_query_manager AS
/***********************************************************************************************************************
 Change History:

 Date          Name                     Description
 ----          ----                     -----------
 08/12/09      Steve Bellamy            Implement Oracle based query management
 18/02/10      Steve Bellamy            Added position keeping queries
 19/02/10      Steve Bellamy            Split out the Kerb processing so that extra conditions are enforced
 24/02/10      Steve Bellamy            Altered transaction type to allow for greater flexibility in naming
 01/03/10      Steve Bellamy            Added variant for DB HALF TRADE searches that return V096
 02/03/10      Steve Bellamy            Add specific query procedures for P10 (Trade and Note) Slip Searches
 06/04/10      Tony Barker              Ensure P238 and P239 only return data for the current trading day
 09/04/10      Tony Barker              Aggregate P238 and P239 returns so gross and net are combined
 13/04/10      Tony Barker              Add order to P238 and P239 outer aggregations
 15/04/10      Tony Barker              Change sort order of P232 DPA returns
 28/04/10      Tony Barker              Change kerb flag to KERB_TRADE_IND
 06/05/10      Steve Bellamy            Handle slip_type ('G' - Ghost) for P010 Trade Slip Search
 14/06/10      Longde An                ISS73958: add restrictions into where clause for P232
 15/07/10      Tom Pinchen              Populate new trading_day column in the query_manager table
***********************************************************************************************************************/

   PROCEDURE GET_HALF_TRADES
      (
      p_where_clause        IN  VARCHAR,
      p_exchange_code       IN  query_manager.exchange_code%TYPE,
      p_terminal_id         IN  query_manager.terminal_id%TYPE,
      p_transaction_id      IN  query_manager.transaction_id%TYPE,
      p_max_row_per_message IN  query_manager.max_row_per_message%TYPE,
      p_max_rows            IN  query_manager.max_row%TYPE,
      p_query_id            OUT query_manager.query_id%TYPE,
      p_num_rows            OUT query_manager.max_row%TYPE
      );
   PROCEDURE GET_KERB_HALF_TRADES
      (
      p_where_clause        IN  VARCHAR,
      p_exchange_code       IN  query_manager.exchange_code%TYPE,
      p_terminal_id         IN  query_manager.terminal_id%TYPE,
      p_transaction_id      IN  query_manager.transaction_id%TYPE,
      p_max_row_per_message IN  query_manager.max_row_per_message%TYPE,
      p_max_rows            IN  query_manager.max_row%TYPE,
      p_query_id            OUT query_manager.query_id%TYPE,
      p_num_rows            OUT query_manager.max_row%TYPE
      );
   PROCEDURE GET_DB_HALF_TRADES
      (
      p_where_clause        IN  VARCHAR,
      p_exchange_code       IN  query_manager.exchange_code%TYPE,
      p_terminal_id         IN  query_manager.terminal_id%TYPE,
      p_transaction_id      IN  query_manager.transaction_id%TYPE,
      p_max_row_per_message IN  query_manager.max_row_per_message%TYPE,
      p_max_rows            IN  query_manager.max_row%TYPE,
      p_query_id            OUT query_manager.query_id%TYPE,
      p_num_rows            OUT query_manager.max_row%TYPE
      );
   PROCEDURE GET_HALF_TRADES_HIERARCHY
      (
      p_half_trade_id       IN  half_trade_results.half_trade_id%TYPE,
      p_countertrade_id     IN  half_trade_results.countertrade_id%TYPE,
      p_exchange_code       IN  query_manager.exchange_code%TYPE,
      p_terminal_id         IN  query_manager.terminal_id%TYPE,
      p_transaction_id      IN  query_manager.transaction_id%TYPE,
      p_max_row_per_message IN  query_manager.max_row_per_message%TYPE,
      p_trading_day         IN  half_trade_results.trading_day%TYPE,
      p_max_rows            IN  query_manager.max_row%TYPE,
      p_query_id            OUT query_manager.query_id%TYPE,
      p_num_rows            OUT query_manager.max_row%TYPE
      );
   PROCEDURE GET_KERB_HALF_TRADES_HIERARCHY
      (
      p_half_trade_id       IN  half_trade_results.half_trade_id%TYPE,
      p_countertrade_id     IN  half_trade_results.countertrade_id%TYPE,
      p_exchange_code       IN  query_manager.exchange_code%TYPE,
      p_terminal_id         IN  query_manager.terminal_id%TYPE,
      p_transaction_id      IN  query_manager.transaction_id%TYPE,
      p_max_row_per_message IN  query_manager.max_row_per_message%TYPE,
      p_trading_day         IN  half_trade_results.trading_day%TYPE,
      p_max_rows            IN  query_manager.max_row%TYPE,
      p_query_id            OUT query_manager.query_id%TYPE,
      p_num_rows            OUT query_manager.max_row%TYPE
      );
   PROCEDURE GET_HALF_TRADE_AUDIT
      (
      p_half_trade_id       IN  tscs_audit_results.half_trade_or_notification_id%TYPE,
      p_slip_type           IN  half_trade_results.slip_type%TYPE,
      p_exchange_code       IN  query_manager.exchange_code%TYPE,
      p_terminal_id         IN  query_manager.terminal_id%TYPE,
      p_transaction_id      IN  query_manager.transaction_id%TYPE,
      p_max_row_per_message IN  query_manager.max_row_per_message%TYPE,
      p_trading_day         IN  tscs_audit_results.trading_day%TYPE,
      p_max_rows            IN  query_manager.max_row%TYPE,
      p_query_id            OUT query_manager.query_id%TYPE,
      p_num_rows            OUT query_manager.max_row%TYPE
      );
   PROCEDURE GET_NOTES
      (
      p_where_clause        IN  VARCHAR,
      p_exchange_code       IN  query_manager.exchange_code%TYPE,
      p_terminal_id         IN  query_manager.terminal_id%TYPE,
      p_transaction_id      IN  query_manager.transaction_id%TYPE,
      p_max_row_per_message IN  query_manager.max_row_per_message%TYPE,
      p_max_rows            IN  query_manager.max_row%TYPE,
      p_query_id            OUT query_manager.query_id%TYPE,
      p_num_rows            OUT query_manager.max_row%TYPE
      );
   PROCEDURE GET_NOTE_AUDIT
      (
      p_notification_id     IN  tscs_audit_results.half_trade_or_notification_id%TYPE,
      p_exchange_code       IN  query_manager.exchange_code%TYPE,
      p_terminal_id         IN  query_manager.terminal_id%TYPE,
      p_transaction_id      IN  query_manager.transaction_id%TYPE,
      p_max_row_per_message IN  query_manager.max_row_per_message%TYPE,
      p_trading_day         IN  tscs_audit_results.trading_day%TYPE,
      p_max_rows            IN  query_manager.max_row%TYPE,
      p_query_id            OUT query_manager.query_id%TYPE,
      p_num_rows            OUT query_manager.max_row%TYPE
      );
   PROCEDURE UPDATE_QUERY_MANAGER
      (
      p_query_id            IN  query_manager.query_id%TYPE,
      p_last_row_retrieved  IN  query_manager.last_row_retrieved%TYPE
      );
   PROCEDURE UPDATE_QUERY_MANAGER
      (
      p_exchange_code       IN  query_manager.exchange_code%TYPE,
      p_terminal_id         IN  query_manager.terminal_id%TYPE,
      p_transaction_id      IN  query_manager.transaction_id%TYPE,
      p_last_row_retrieved  IN  query_manager.last_row_retrieved%TYPE
      );
   PROCEDURE CANCEL_QUERY_MANAGER
      (
      p_query_id            IN  query_manager.query_id%TYPE
      );
   PROCEDURE CANCEL_QUERY_MANAGER
      (
      p_exchange_code       IN  query_manager.exchange_code%TYPE,
      p_terminal_id         IN  query_manager.terminal_id%TYPE,
      p_transaction_id      IN  query_manager.transaction_id%TYPE
      );
   PROCEDURE QUERY_MANAGER_HOUSEKEEPING
      (
       p_process_orphans     IN  VARCHAR2
      );
   PROCEDURE GET_QUERY_TRANSACTION_TYPE
      (
       p_exchange_code       IN  query_manager.exchange_code%TYPE,
       p_terminal_id         IN  query_manager.terminal_id%TYPE,
       p_transaction_id      IN  query_manager.transaction_id%TYPE,
       p_transaction_type    OUT query_manager.transaction_type%TYPE
      );
   PROCEDURE GET_POSITIONS
      (
       p_where_clause        IN  VARCHAR,
       p_exchange_code       IN  query_manager.exchange_code%TYPE,
       p_terminal_id         IN  query_manager.terminal_id%TYPE,
       p_transaction_id      IN  query_manager.transaction_id%TYPE,
       p_max_row_per_message IN  query_manager.max_row_per_message%TYPE,
       p_max_rows            IN  query_manager.max_row%TYPE,
       p_query_id            OUT query_manager.query_id%TYPE,
       p_num_rows            OUT query_manager.max_row%TYPE
      );
   PROCEDURE GET_POSITION_SUMMARIES
      (
       p_where_clause        IN  VARCHAR,
       p_exchange_code       IN  query_manager.exchange_code%TYPE,
       p_terminal_id         IN  query_manager.terminal_id%TYPE,
       p_transaction_id      IN  query_manager.transaction_id%TYPE,
       p_max_row_per_message IN  query_manager.max_row_per_message%TYPE,
       p_max_rows            IN  query_manager.max_row%TYPE,
       p_query_id            OUT query_manager.query_id%TYPE,
       p_num_rows            OUT query_manager.max_row%TYPE
      );
   PROCEDURE GET_CMDTY_EXP_PSTNS
      (
       p_where_clause        IN  VARCHAR,
       p_exchange_code       IN  query_manager.exchange_code%TYPE,
       p_terminal_id         IN  query_manager.terminal_id%TYPE,
       p_transaction_id      IN  query_manager.transaction_id%TYPE,
       p_max_row_per_message IN  query_manager.max_row_per_message%TYPE,
       p_max_rows            IN  query_manager.max_row%TYPE,
       p_query_id            OUT query_manager.query_id%TYPE,
       p_num_rows            OUT query_manager.max_row%TYPE
      );
   PROCEDURE GET_SERIES_EXP_LNG_PSTNS
      (
       p_where_clause        IN  VARCHAR,
       p_exchange_code       IN  query_manager.exchange_code%TYPE,
       p_terminal_id         IN  query_manager.terminal_id%TYPE,
       p_transaction_id      IN  query_manager.transaction_id%TYPE,
       p_max_row_per_message IN  query_manager.max_row_per_message%TYPE,
       p_max_rows            IN  query_manager.max_row%TYPE,
       p_query_id            OUT query_manager.query_id%TYPE,
       p_num_rows            OUT query_manager.max_row%TYPE
      );
END pkg_query_manager;
/

create or replace
PACKAGE BODY tridlive.pkg_query_manager AS
/***********************************************************************************************************************
 Change History:

 Date          Name                     Description
 ----          ----                     -----------
 08/12/09      Steve Bellamy            Implement Oracle based query management
 04/01/10      Steve Bellamy            Add first_rows hints to speed un-indexed queries
 12/02/10      Steve Bellamy            If maximum records is set to 9999 then remove retrieval limit.
 18/02/10      Steve Bellamy            Added position keeping queries
 19/02/10      Steve Bellamy            Split out the Kerb processing so that extra conditions are enforced
 01/03/10      Steve Bellamy            Added variant for DB HALF TRADE searches that return V096
 02/03/10      Steve Bellamy            Add specific query procedures for P10 (Trade and Note) Slip Searches
 03/03/10      Steve Bellamy            Add position search results tables to housekeeping
 11/03/10      Steve Bellamy            Reject P238 returns if both long and short volume fields are zero or less
 11/03/10      Steve Bellamy            Reject P239 returns if all of Long Available, Manually Exercised and Abandonded
                                        volume fields are zero or less
 30/03/10      Steve Bellamy            Fix notice_expiry_day in GET_CMDTY_EXP_PSTNS and GET_CMDTY_EXP_PSTNS
                                        to use value from commodity month.
 30/03/10      Steve Bellamy            Add process to detect queries which truncate the resultant number of records.
 28/04/10      Tony Barker              Change kerb flag to KERB_TRADE_IND
 29/04/10      Steve Bellamy            Fix use of KERB_TRADE_IND
 06/05/10      Steve Bellamy            Handle slip_type ('G' - Ghost) for P010 Trade Slip Search
 07/05/10      Steve Bellamy            ISS72652 - Delete orphans from CEP_RESULTS during query housekeeping.
 24/05/10      Steve Bellamy            ISS73072 - TSCS Note Search altered to return CLEARING messages,
                                                   but exclude GHOST_NOTE and OLD_TRAMP.
 24/05/10      Steve Bellamy            ISS72296 - Allow use of relative searches for P101.
 25/05/10      Steve Bellamy            Modify P238 and P239 to use ALL_TRADING_DAYS table.
 22/06/10      Steve Bellamy            Modify sort order for P233 (Position Search) to better match TRS Screen 11
 15/07/10      Tom Pinchen              Change INITIALISE_QUERY_MANAGER to populate new trading_day column
 19/07/10      Steve Bellamy            Optimise P238 and P239 to reduce number of pka partitions searched
 22/07/10      Steve Bellamy            P238 and P239 should use commodity month data for POSITION_MAINTENANCE day
 15/09/10      Steve Bellamy            ISS77399: If maximum records is set to 9999 then use this as retrieval limit
                                        so as to avoid a overflow in the TRAMP retrieval quantity record.
 17/09/10      Steve Bellamy            Allow alternative sort order for P233 when notice_expiry_day is part of the
                                        WHERE clause, this is to support TRS expiry report as part of Option 16.
                                        This report needs potential to execute unlimited queries.

***********************************************************************************************************************/

   FUNCTION INITIALISE_QUERY_MANAGER
      (
      p_exchange_code       IN  query_manager.exchange_code%TYPE,
      p_terminal_id         IN  query_manager.terminal_id%TYPE,
      p_transaction_id      IN  query_manager.transaction_id%TYPE,
      p_transaction_type    IN  query_manager.transaction_type%TYPE,
      p_max_row_per_message IN  query_manager.max_row_per_message%TYPE
      ) RETURN query_manager.query_id%TYPE
   AS
      l_query_id    query_manager.query_id%TYPE;
      l_trading_day trading_day.trading_day%TYPE;
   BEGIN
      SELECT query_id_seq.nextval INTO l_query_id FROM dual;

      SELECT trading_day into l_trading_day
      FROM trading_day
      WHERE exchange_code=p_exchange_code
      AND component_name='AUDIT_REPLICATOR';

      BEGIN
         INSERT INTO query_manager ( query_id
                                    ,exchange_code
                                    ,terminal_id
                                    ,transaction_id
                                    ,transaction_type
                                    ,max_row_per_message
                                    ,last_row_retrieved
                                    ,max_row
                                    ,trading_day
                                   )
                            VALUES ( l_query_id
                                    ,p_exchange_code
                                    ,p_terminal_id
                                    ,p_transaction_id
                                    ,p_transaction_type
                                    ,p_max_row_per_message
                                    ,0
                                    ,0
                                    ,l_trading_day
                                   );
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX THEN
            UPDATE query_manager SET query_id = l_query_id
                                   , transaction_type = p_transaction_type
                                   , max_row_per_message = p_max_row_per_message
                                   , last_row_retrieved = 0
                                   , max_row = 0
                                   , trading_day = l_trading_day
               WHERE exchange_code  = p_exchange_code
                 AND terminal_id    = p_terminal_id
                 AND transaction_id = p_transaction_id;
            IF SQL%ROWCOUNT = 0 THEN
               -- Previous query id has just been deleted, so rerun the insert
               INSERT INTO query_manager ( query_id
                                          ,exchange_code
                                          ,terminal_id
                                          ,transaction_id
                                          ,transaction_type
                                          ,max_row_per_message
                                          ,last_row_retrieved
                                          ,max_row
                                          ,trading_day
                                         )
                                  VALUES ( l_query_id
                                          ,p_exchange_code
                                          ,p_terminal_id
                                          ,p_transaction_id
                                          ,p_transaction_type
                                          ,p_max_row_per_message
                                          ,0
                                          ,0
                                          ,l_trading_day
                                         );
            END IF;
      END;
      RETURN l_query_id;
   END INITIALISE_QUERY_MANAGER;

   PROCEDURE SET_MAX_ROW_IN_QUERY_MANAGER
      (
      p_query_id               IN  query_manager.query_id%TYPE,
      p_max_row                IN  query_manager.max_row%TYPE
      )
   AS
   BEGIN
      UPDATE query_manager SET max_row = p_max_row,
                               final_completion_indicator = 'E'
      WHERE query_id = p_query_id;
   END SET_MAX_ROW_IN_QUERY_MANAGER;

   PROCEDURE SET_MAX_ROW_IN_QUERY_MANAGER
      (
      p_query_id               IN  query_manager.query_id%TYPE,
      p_max_row                IN  query_manager.max_row%TYPE,
      p_qry_max_row            IN  query_manager.max_row%TYPE
      )
   AS
   BEGIN
      UPDATE query_manager SET max_row = LEAST( p_max_row, p_qry_max_row ),
                               final_completion_indicator = CASE WHEN p_max_row > p_qry_max_row THEN 'T' ELSE 'E' END
      WHERE query_id = p_query_id;
   END SET_MAX_ROW_IN_QUERY_MANAGER;

   PROCEDURE UPDATE_QUERY_MANAGER
      (
      p_query_id               IN  query_manager.query_id%TYPE,
      p_last_row_retrieved     IN  query_manager.last_row_retrieved%TYPE
      )
   AS
   BEGIN
      UPDATE query_manager SET last_row_retrieved = p_last_row_retrieved WHERE query_id = p_query_id;
   END UPDATE_QUERY_MANAGER;

   PROCEDURE UPDATE_QUERY_MANAGER
      (
      p_exchange_code       IN  query_manager.exchange_code%TYPE,
      p_terminal_id         IN  query_manager.terminal_id%TYPE,
      p_transaction_id      IN  query_manager.transaction_id%TYPE,
      p_last_row_retrieved  IN  query_manager.last_row_retrieved%TYPE
      )
   AS
   BEGIN
      UPDATE query_manager SET last_row_retrieved = p_last_row_retrieved
         WHERE exchange_code    = p_exchange_code AND
               terminal_id      = p_terminal_id AND
               transaction_id   = p_transaction_id;
   END UPDATE_QUERY_MANAGER;

   PROCEDURE CANCEL_QUERY_MANAGER
      (
      p_query_id            IN  query_manager.query_id%TYPE
      )
   AS
   BEGIN
      UPDATE query_manager SET last_row_retrieved = max_row WHERE query_id = p_query_id;
   END CANCEL_QUERY_MANAGER;

   PROCEDURE CANCEL_QUERY_MANAGER
      (
      p_exchange_code       IN  query_manager.exchange_code%TYPE,
      p_terminal_id         IN  query_manager.terminal_id%TYPE,
      p_transaction_id      IN  query_manager.transaction_id%TYPE
      )
   AS
   BEGIN
      UPDATE query_manager SET last_row_retrieved = max_row
         WHERE exchange_code    = p_exchange_code AND
               terminal_id      = p_terminal_id AND
               transaction_id   = p_transaction_id;
   END CANCEL_QUERY_MANAGER;

   PROCEDURE GET_HALF_TRADES
      (
      p_where_clause        IN  VARCHAR,
      p_kerb                IN  BOOLEAN,
      p_transaction_type    IN  query_manager.transaction_type%TYPE,
      p_exchange_code       IN  query_manager.exchange_code%TYPE,
      p_terminal_id         IN  query_manager.terminal_id%TYPE,
      p_transaction_id      IN  query_manager.transaction_id%TYPE,
      p_max_row_per_message IN  query_manager.max_row_per_message%TYPE,
      p_max_rows            IN  query_manager.max_row%TYPE,
      p_query_id            OUT query_manager.query_id%TYPE,
      p_num_rows            OUT query_manager.max_row%TYPE
      )
   AS
      v_sql VARCHAR2(4000);
   BEGIN
      p_query_id := INITIALISE_QUERY_MANAGER ( p_exchange_code
                                              ,p_terminal_id
                                              ,p_transaction_id
                                              ,p_transaction_type
                                              ,p_max_row_per_message
                                             );

     v_sql := 'INSERT INTO half_trade_results '||
                   'SELECT /*+ FIRST_ROWS */ :p_query_id, rownum AS query_row_num, ht.* FROM ('||
               'SELECT * FROM half_trade WHERE ';

      IF p_kerb THEN
         v_sql := v_sql||'kerb_trade_ind = ''Y'' AND ';
      END IF;
      v_sql := v_sql||'('||p_where_clause||') ORDER BY half_trade_id, sub_trade_seq_no, trading_day, exchange_code, slip_type ) ht';
--      IF p_max_rows < 9999 THEN
         v_sql := v_sql||' WHERE rownum <= :p_max_rows + 1';
         EXECUTE immediate v_sql USING p_query_id, p_max_rows;
--      ELSE
--         EXECUTE immediate v_sql USING p_query_id;
--      END IF;

      p_num_rows := SQL%ROWCOUNT;

--      IF p_max_rows < 9999 THEN
         SET_MAX_ROW_IN_QUERY_MANAGER( p_query_id, p_num_rows, p_max_rows );
         p_num_rows := LEAST( p_num_rows, p_max_rows);
--      ELSE
--         SET_MAX_ROW_IN_QUERY_MANAGER( p_query_id, p_num_rows );
--      END IF;
   END GET_HALF_TRADES;

   PROCEDURE GET_HALF_TRADES
      (
      p_where_clause        IN  VARCHAR,
      p_exchange_code       IN  query_manager.exchange_code%TYPE,
      p_terminal_id         IN  query_manager.terminal_id%TYPE,
      p_transaction_id      IN  query_manager.transaction_id%TYPE,
      p_max_row_per_message IN  query_manager.max_row_per_message%TYPE,
      p_max_rows            IN  query_manager.max_row%TYPE,
      p_query_id            OUT query_manager.query_id%TYPE,
      p_num_rows            OUT query_manager.max_row%TYPE
      )
   AS
   BEGIN
      GET_HALF_TRADES
         (
         p_where_clause,
         FALSE,
         'HALF_TRADE',
         p_exchange_code,
         p_terminal_id,
         p_transaction_id,
         p_max_row_per_message,
         p_max_rows,
         p_query_id,
         p_num_rows
         );
   END GET_HALF_TRADES;

   PROCEDURE GET_KERB_HALF_TRADES
      (
      p_where_clause        IN  VARCHAR,
      p_exchange_code       IN  query_manager.exchange_code%TYPE,
      p_terminal_id         IN  query_manager.terminal_id%TYPE,
      p_transaction_id      IN  query_manager.transaction_id%TYPE,
      p_max_row_per_message IN  query_manager.max_row_per_message%TYPE,
      p_max_rows            IN  query_manager.max_row%TYPE,
      p_query_id            OUT query_manager.query_id%TYPE,
      p_num_rows            OUT query_manager.max_row%TYPE
      )
   AS
   BEGIN
      GET_HALF_TRADES
         (
         p_where_clause,
         TRUE,
         'HALF_TRADE',
         p_exchange_code,
         p_terminal_id,
         p_transaction_id,
         p_max_row_per_message,
         p_max_rows,
         p_query_id,
         p_num_rows
         );
   END GET_KERB_HALF_TRADES;

   PROCEDURE GET_DB_HALF_TRADES
      (
      p_where_clause        IN  VARCHAR,
      p_exchange_code       IN  query_manager.exchange_code%TYPE,
      p_terminal_id         IN  query_manager.terminal_id%TYPE,
      p_transaction_id      IN  query_manager.transaction_id%TYPE,
      p_max_row_per_message IN  query_manager.max_row_per_message%TYPE,
      p_max_rows            IN  query_manager.max_row%TYPE,
      p_query_id            OUT query_manager.query_id%TYPE,
      p_num_rows            OUT query_manager.max_row%TYPE
      )
   AS
   BEGIN
      GET_HALF_TRADES
         (
         p_where_clause,
         FALSE,
         'DB_HALF_TRADE',
         p_exchange_code,
         p_terminal_id,
         p_transaction_id,
         p_max_row_per_message,
         p_max_rows,
         p_query_id,
         p_num_rows
         );
   END GET_DB_HALF_TRADES;

   PROCEDURE GET_HALF_TRADES_HIERARCHY
      (
      p_half_trade_id       IN  half_trade_results.half_trade_id%TYPE,
      p_countertrade_id     IN  half_trade_results.countertrade_id%TYPE,
      p_exchange_code       IN  query_manager.exchange_code%TYPE,
      p_terminal_id         IN  query_manager.terminal_id%TYPE,
      p_transaction_id      IN  query_manager.transaction_id%TYPE,
      p_max_row_per_message IN  query_manager.max_row_per_message%TYPE,
      p_trading_day         IN  half_trade_results.trading_day%TYPE,
      p_max_rows            IN  query_manager.max_row%TYPE,
      p_query_id            OUT query_manager.query_id%TYPE,
      p_num_rows            OUT query_manager.max_row%TYPE
   )
   AS
   BEGIN
      p_query_id := INITIALISE_QUERY_MANAGER ( p_exchange_code
                                              ,p_terminal_id
                                              ,p_transaction_id
                                              ,'HALF_TRADE'
                                              ,p_max_row_per_message
                                             );
      INSERT INTO half_trade_results
        SELECT p_query_id, rownum as query_row_num, half_trade.*
           FROM half_trade
           WHERE rownum <= p_max_rows
           CONNECT BY exchange_code=PRIOR exchange_code AND
                      trading_day  =PRIOR trading_day AND
                      half_trade_id=PRIOR counterclaim_id
           START WITH (half_trade_id,exchange_code,trading_day) IN
              (
              SELECT p_half_trade_id, p_exchange_code, p_trading_day FROM DUAL
              UNION
              SELECT NVL(p_countertrade_id,countertrade_id), exchange_code, trading_day
                 FROM half_trade
                 WHERE half_trade_id = p_half_trade_id AND
                       exchange_code = p_exchange_code AND
                       trading_day   = p_trading_day
              )
        ;

      p_num_rows := SQL%ROWCOUNT;
      SET_MAX_ROW_IN_QUERY_MANAGER( p_query_id, p_num_rows );
   END GET_HALF_TRADES_HIERARCHY;

   PROCEDURE GET_KERB_HALF_TRADES_HIERARCHY
      (
      p_half_trade_id       IN  half_trade_results.half_trade_id%TYPE,
      p_countertrade_id     IN  half_trade_results.countertrade_id%TYPE,
      p_exchange_code       IN  query_manager.exchange_code%TYPE,
      p_terminal_id         IN  query_manager.terminal_id%TYPE,
      p_transaction_id      IN  query_manager.transaction_id%TYPE,
      p_max_row_per_message IN  query_manager.max_row_per_message%TYPE,
      p_trading_day         IN  half_trade_results.trading_day%TYPE,
      p_max_rows            IN  query_manager.max_row%TYPE,
      p_query_id            OUT query_manager.query_id%TYPE,
      p_num_rows            OUT query_manager.max_row%TYPE
   )
   AS
   BEGIN
      p_query_id := INITIALISE_QUERY_MANAGER ( p_exchange_code
                                              ,p_terminal_id
                                              ,p_transaction_id
                                              ,'HALF_TRADE'
                                              ,p_max_row_per_message
                                             );
      INSERT INTO half_trade_results
        SELECT p_query_id, rownum as query_row_num, half_trade.*
           FROM half_trade
           WHERE (kerb_trade_ind = 'Y' OR pre_default_trade_status = 'ki') AND
                 rownum <= p_max_rows
           CONNECT BY exchange_code=PRIOR exchange_code AND
                      trading_day  =PRIOR trading_day AND
                      half_trade_id=PRIOR counterclaim_id
           START WITH (half_trade_id,exchange_code,trading_day) IN
              (
              SELECT p_half_trade_id, p_exchange_code, p_trading_day FROM DUAL
              UNION
              SELECT NVL(p_countertrade_id,countertrade_id), exchange_code, trading_day
                 FROM half_trade
                 WHERE half_trade_id = p_half_trade_id AND
                       exchange_code = p_exchange_code AND
                       trading_day   = p_trading_day
              )
        ;

      p_num_rows := SQL%ROWCOUNT;
      SET_MAX_ROW_IN_QUERY_MANAGER( p_query_id, p_num_rows );
   END GET_KERB_HALF_TRADES_HIERARCHY;

   PROCEDURE GET_HALF_TRADE_AUDIT
      (
      p_half_trade_id       IN  tscs_audit_results.half_trade_or_notification_id%TYPE,
      p_slip_type           IN  half_trade_results.slip_type%TYPE,
      p_exchange_code       IN  query_manager.exchange_code%TYPE,
      p_terminal_id         IN  query_manager.terminal_id%TYPE,
      p_transaction_id      IN  query_manager.transaction_id%TYPE,
      p_max_row_per_message IN  query_manager.max_row_per_message%TYPE,
      p_trading_day         IN  tscs_audit_results.trading_day%TYPE,
      p_max_rows            IN  query_manager.max_row%TYPE,
      p_query_id            OUT query_manager.query_id%TYPE,
      p_num_rows            OUT query_manager.max_row%TYPE
      )
   AS
      l_class tscs_audit_results.class%TYPE;
   BEGIN
      p_query_id := INITIALISE_QUERY_MANAGER ( p_exchange_code
                                              ,p_terminal_id
                                              ,p_transaction_id
                                              ,'HALF_TRADE_AUDIT'
                                              ,p_max_row_per_message
                                             );
      IF p_slip_type = 'G' THEN
         l_class := 'GHOST_TRADE';
      ELSE
         l_class := 'TRADE';
      END IF;
--      IF p_max_rows < 9999 THEN
         INSERT INTO tscs_audit_results
            SELECT p_query_id, rownum as query_row_num, tscs_audit_ordered.*
            FROM (
                 SELECT * FROM tscs_audit
                 WHERE trading_day                   = p_trading_day AND
                       exchange_code                 = p_exchange_code AND
                       message_src                   = 'TRADE_REPLICATOR' AND
                       class                         = l_class AND
                       half_trade_or_notification_id = p_half_trade_id
                 ORDER BY trading_day, exchange_code, output_sequence_no
                 ) tscs_audit_ordered
            WHERE rownum <= p_max_rows
         ;
--      ELSE
--         INSERT INTO tscs_audit_results
--            SELECT p_query_id, rownum as query_row_num, tscs_audit_ordered.*
--            FROM (
--                 SELECT * FROM tscs_audit
--                 WHERE trading_day                   = p_trading_day AND
--                       exchange_code                 = p_exchange_code AND
--                       message_src                   = 'TRADE_REPLICATOR' AND
--                       class                         = l_class AND
--                       half_trade_or_notification_id = p_half_trade_id
--                 ORDER BY trading_day, exchange_code, output_sequence_no
--                 ) tscs_audit_ordered
--         ;
--      END IF;
      p_num_rows := SQL%ROWCOUNT;
--      IF p_max_rows < 9999 THEN
         SET_MAX_ROW_IN_QUERY_MANAGER( p_query_id, p_num_rows, p_max_rows );
         p_num_rows := LEAST( p_num_rows, p_max_rows);
--      ELSE
--         SET_MAX_ROW_IN_QUERY_MANAGER( p_query_id, p_num_rows );
--      END IF;
   END GET_HALF_TRADE_AUDIT;

   PROCEDURE GET_NOTES
      (
      p_where_clause        IN  VARCHAR,
      p_exchange_code       IN  query_manager.exchange_code%TYPE,
      p_terminal_id         IN  query_manager.terminal_id%TYPE,
      p_transaction_id      IN  query_manager.transaction_id%TYPE,
      p_max_row_per_message IN  query_manager.max_row_per_message%TYPE,
      p_max_rows            IN  query_manager.max_row%TYPE,
      p_query_id            OUT query_manager.query_id%TYPE,
      p_num_rows            OUT query_manager.max_row%TYPE
      )
   AS
      v_sql VARCHAR2(4000);
   BEGIN
      p_query_id := INITIALISE_QUERY_MANAGER ( p_exchange_code
                                              ,p_terminal_id
                                              ,p_transaction_id
                                              ,'NOTIFICATION'
                                              ,p_max_row_per_message
                                             );
      v_sql := 'INSERT INTO notification_results  '||
               'SELECT /*+ FIRST_ROWS */ :p_query_id, rownum AS query_row_num, notes.* FROM (';
      -- See if relative position days are used in the query
      IF UPPER(p_where_clause) LIKE '%RELATIVE_POSITION_DAY%' THEN
         v_sql := v_sql||'SELECT exchange_code, notification_id, notification_src_id, notification_type, notification_src,'||
                         ' note_creation_day, volume_to_adjust, entered_date, matched_date, modified_date,'||
                         ' clearing_firm, firm, trader, account_code, position_ref, contract_type, generic_contract_type,'||
                         ' physical_commodity, logical_commodity, expiry_date, exercise_price, valuation_price,'||
                         ' counterparty_firm, counterparty_trader, operator_name, user_info, position_day,'||
                         ' tender_deletion_day, new_tender_deletion_day, margining_account,'||
                         ' counternote_id, counternote_src_id, countertrade_id, countertrade_src_id, countertrade_sub_no, countertrade_volume,'||
                         ' note_processed_day, match_seq_no, all_lots_ind, notification_status, adjust_volume, adjust_non_marg_volume,'||
                         ' run_mnemonic, run_no, run_sub_seq, lot_size, run_instance, run_logical, run_phys, run_generic, run_expiry,'||
                         ' old_valuation_price, pay_collect, premium_pay_collect, contingent_margin, paid_variation, paid_contingent,'||
                         ' position_type, alt_deliverable_ind, trade_charge_ind, long_short_ind, sub_account, position_status,'||
                         ' correction_type, transfer_method, extern_exchange_id, guarantee_account, allocation_trader, allocation_firm,'||
                         ' ghost_flag, counterparty_anonymous_firm, counterparty_anonymous_trader, reference_day, exercise_value'||
                         ' FROM notification_search';
      ELSE
         v_sql := v_sql||'SELECT * FROM notification';
      END IF;
      v_sql := v_sql||' WHERE '||p_where_clause||' ORDER BY notification_id, note_creation_day, exchange_code, ghost_flag ) notes';
--      IF p_max_rows < 9999 THEN
         v_sql := v_sql||' WHERE rownum <= :p_max_rows + 1';
         EXECUTE immediate v_sql USING p_query_id, p_max_rows;
--      ELSE
--         EXECUTE immediate v_sql USING p_query_id;
--      END IF;

      p_num_rows := SQL%ROWCOUNT;
--      IF p_max_rows < 9999 THEN
         SET_MAX_ROW_IN_QUERY_MANAGER( p_query_id, p_num_rows, p_max_rows );
         p_num_rows := LEAST( p_num_rows, p_max_rows);
--      ELSE
--         SET_MAX_ROW_IN_QUERY_MANAGER( p_query_id, p_num_rows );
--      END IF;
   END GET_NOTES;

   PROCEDURE GET_NOTE_AUDIT
      (
      p_notification_id     IN  tscs_audit_results.half_trade_or_notification_id%TYPE,
      p_exchange_code       IN  query_manager.exchange_code%TYPE,
      p_terminal_id         IN  query_manager.terminal_id%TYPE,
      p_transaction_id      IN  query_manager.transaction_id%TYPE,
      p_max_row_per_message IN  query_manager.max_row_per_message%TYPE,
      p_trading_day         IN  tscs_audit_results.trading_day%TYPE,
      p_max_rows            IN  query_manager.max_row%TYPE,
      p_query_id            OUT query_manager.query_id%TYPE,
      p_num_rows            OUT query_manager.max_row%TYPE
      )
   AS
   BEGIN
      p_query_id := INITIALISE_QUERY_MANAGER ( p_exchange_code
                                              ,p_terminal_id
                                              ,p_transaction_id
                                              ,'NOTE_AUDIT'
                                              ,p_max_row_per_message
                                             );
--      IF p_max_rows < 9999 THEN
         INSERT INTO tscs_audit_results
            SELECT p_query_id, rownum as query_row_num, tscs_audit_ordered.*
            FROM (
                 SELECT * FROM tscs_audit
                 WHERE trading_day                   = p_trading_day AND
                       exchange_code                 = p_exchange_code AND
                       message_src                   = 'NOTE_REPLICATOR' AND
                       class                         = 'CLEARING' AND
                       half_trade_or_notification_id = p_notification_id
                 ORDER BY trading_day, exchange_code, output_sequence_no
                 ) tscs_audit_ordered
            WHERE rownum <= p_max_rows + 1
         ;
--      ELSE
--         INSERT INTO tscs_audit_results
--            SELECT p_query_id, rownum as query_row_num, tscs_audit_ordered.*
--            FROM (
--                 SELECT * FROM tscs_audit
--                 WHERE trading_day                   = p_trading_day AND
--                       exchange_code                 = p_exchange_code AND
--                       message_src                   = 'NOTE_REPLICATOR' AND
--                       class                         = 'CLEARING' AND
--                       half_trade_or_notification_id = p_notification_id
--                 ORDER BY trading_day, exchange_code, output_sequence_no
--                 ) tscs_audit_ordered
--         ;
--      END IF;
      p_num_rows := SQL%ROWCOUNT;
--      IF p_max_rows < 9999 THEN
         SET_MAX_ROW_IN_QUERY_MANAGER( p_query_id, p_num_rows, p_max_rows );
         p_num_rows := LEAST( p_num_rows, p_max_rows);
--      ELSE
--         SET_MAX_ROW_IN_QUERY_MANAGER( p_query_id, p_num_rows );
--      END IF;
   END GET_NOTE_AUDIT;

   PROCEDURE QUERY_MANAGER_HOUSEKEEPING
      (
      p_process_orphans     IN  VARCHAR2
      )
   AS
   BEGIN
      -- Delete records from the query manager table where all records have been processed
      DELETE  
        FROM query_manager 
      WHERE last_row_retrieved=max_row;

      -- If orphaned results records also needed to be removed (because referential integrity is disabled)
      IF (p_process_orphans = 'TRUE') THEN
         -- Delete orphaned half trade results
         DELETE FROM half_trade_results WHERE query_id NOT IN
            (
            SELECT query_id FROM query_manager
            );
         -- Delete orphaned notification results
         DELETE FROM notification_results WHERE query_id NOT IN
            (
            SELECT query_id FROM query_manager
            );
         -- Delete orphaned tscs_audit results
         DELETE FROM tscs_audit_results WHERE query_id NOT IN
            (
            SELECT query_id FROM query_manager
            );
         -- Delete orphaned position keeping account results
         DELETE FROM pka_results WHERE query_id NOT IN
            (
            SELECT query_id FROM query_manager
            );
         -- Delete orphaned delivery pending account results
         DELETE FROM dpa_results WHERE query_id NOT IN
            (
            SELECT query_id FROM query_manager
            );
         -- Delete orphaned series with long position results
         DELETE FROM selp_results WHERE query_id NOT IN
            (
            SELECT query_id FROM query_manager
            );
         -- Delete orphaned commodities with expiring position results
         DELETE FROM cep_results WHERE query_id NOT IN
            (
            SELECT query_id FROM query_manager
            );
      END IF;

   END QUERY_MANAGER_HOUSEKEEPING;

   PROCEDURE GET_QUERY_TRANSACTION_TYPE
      (
      p_exchange_code       IN  query_manager.exchange_code%TYPE,
      p_terminal_id         IN  query_manager.terminal_id%TYPE,
      p_transaction_id      IN  query_manager.transaction_id%TYPE,
      p_transaction_type    OUT query_manager.transaction_type%TYPE
      )
   AS
   BEGIN
      BEGIN
         SELECT transaction_type INTO p_transaction_type
            FROM query_manager
            WHERE exchange_code    = p_exchange_code  AND
                  terminal_id      = p_terminal_id    AND
                  transaction_id   = p_transaction_id AND
                  last_row_retrieved < max_row;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            p_transaction_type := 'X';
      END;
   END GET_QUERY_TRANSACTION_TYPE;

   PROCEDURE GET_POSITIONS
      ( p_where_clause        IN  VARCHAR,
        p_exchange_code       IN  query_manager.exchange_code%TYPE,
        p_terminal_id         IN  query_manager.terminal_id%TYPE,
        p_transaction_id      IN  query_manager.transaction_id%TYPE,
        p_max_row_per_message IN  query_manager.max_row_per_message%TYPE,
        p_max_rows            IN  query_manager.max_row%TYPE,
        p_query_id            OUT query_manager.query_id%TYPE,
        p_num_rows            OUT query_manager.max_row%TYPE
      )
   AS v_sql VARCHAR2(8000);
   BEGIN
      p_query_id := INITIALISE_QUERY_MANAGER ( p_exchange_code
                                              ,p_terminal_id
                                              ,p_transaction_id
                                              ,'PKA'
                                              ,p_max_row_per_message
                                             );

      v_sql := 'INSERT INTO pka_results
                SELECT ';
      IF p_max_rows < 9999 THEN
         v_sql := v_sql||'/*+ FIRST_ROWS */ ';
      END IF;
      v_sql := v_sql||':p_query_id, rownum AS query_row_num, ps.*
                FROM ( SELECT * FROM position_search WHERE ' || p_where_clause || ' AND (
                               (profit + premium) <> 0 OR contingent_margin  <> 0
                            OR long_account_vol   <> 0 OR long_adjusted_vol  <> 0 OR long_traded_vol    <> 0
                            OR short_account_vol  <> 0 OR short_adjusted_vol <> 0 OR short_traded_vol   <> 0
                            OR long_expired_vol   <> 0 OR long_cabinet_vol   <> 0 OR long_contra_vol    <> 0 OR long_create_vol   <> 0
                            OR short_expired_vol  <> 0 OR short_cabinet_vol  <> 0 OR short_contra_vol   <> 0 OR short_create_vol  <> 0
                            OR lots_assigned_vol  <> 0 OR man_exercised_vol  <> 0 OR auto_exercised_vol <> 0 OR man_delivered_vol <> 0
                            OR auto_delivered_vol <> 0 OR man_settled_vol    <> 0 OR man_unsettled_vol  <> 0 OR auto_settled_vol  <> 0
                            OR long_transferred_in_vol      <> 0 OR long_transferred_out_vol   <> 0
                            OR short_transferred_in_vol     <> 0 OR short_transferred_out_vol  <> 0
                            OR long_transferred_extrnl_vol  <> 0 OR long_result_of_assign_vol  <> 0 OR long_result_of_exercise_vol  <> 0
                            OR short_transferred_extrnl_vol <> 0 OR short_result_of_assign_vol <> 0 OR short_result_of_exercise_vol <> 0
                            OR auto_exercise_notification   <> 0
                ) ';

      -- A specific order is required for the Option 16 expiry reports. For Trident Phase 1 only, this internal TRS query uses NOTICE_EXPIRY_DAY field.
      IF UPPER(p_where_clause) LIKE '%NOTICE_EXPIRY_DAY%' THEN
         v_sql := v_sql||'ORDER BY contract_type, physical_commodity, account_code, exercise_price';
      ELSE
         v_sql := v_sql||'ORDER BY physical_commodity, position_day, firm, account_code, generic_contract_type, contract_type, expiry_date, exercise_price';
      END IF;

      v_sql := v_sql||' ) ps';

      IF p_max_rows < 9999 THEN
         v_sql := v_sql|| ' WHERE rownum <= :p_max_rows + 1';
         EXECUTE immediate v_sql USING p_query_id, p_max_rows;
      ELSE
         EXECUTE immediate v_sql USING p_query_id;
      END IF;

      p_num_rows := SQL%ROWCOUNT;
      IF p_max_rows < 9999 THEN
         SET_MAX_ROW_IN_QUERY_MANAGER( p_query_id, p_num_rows, p_max_rows );
         p_num_rows := LEAST( p_num_rows, p_max_rows);
      ELSE
         SET_MAX_ROW_IN_QUERY_MANAGER( p_query_id, p_num_rows );
      END IF;
   END GET_POSITIONS;

   PROCEDURE GET_POSITION_SUMMARIES
      ( p_where_clause        IN  VARCHAR,
        p_exchange_code       IN  query_manager.exchange_code%TYPE,
        p_terminal_id         IN  query_manager.terminal_id%TYPE,
        p_transaction_id      IN  query_manager.transaction_id%TYPE,
        p_max_row_per_message IN  query_manager.max_row_per_message%TYPE,
        p_max_rows            IN  query_manager.max_row%TYPE,
        p_query_id            OUT query_manager.query_id%TYPE,
        p_num_rows            OUT query_manager.max_row%TYPE
      )
   AS v_sql VARCHAR2(8000);
   BEGIN
      p_query_id := INITIALISE_QUERY_MANAGER ( p_exchange_code
                                              ,p_terminal_id
                                              ,p_transaction_id
                                              ,'DPA'
                                              ,p_max_row_per_message
                                             );

      v_sql := 'INSERT INTO dpa_results
                SELECT /*+ FIRST_ROWS */ :p_query_id, rownum AS query_row_num, dpa.* FROM (
                    SELECT * FROM delivery_pending_account WHERE '|| p_where_clause || ' AND (
                           long_account_vol <> 0 OR short_account_vol <> 0
                        OR long_adjusted_vol <> 0 OR short_adjusted_vol <> 0
                        OR (long_account_vol - long_non_marginable_vol) <> 0 OR (short_account_vol - short_non_marginable_vol) <> 0
                        OR (long_adjusted_vol - long_adjstd_non_margin_vol) <> 0 OR (short_adjusted_vol - short_adjstd_non_margin_vol) <> 0
                        )
                    ORDER BY firm, trader, account_code, generic_contract_type, contract_type, expiry_date, exercise_price, tender_deletion_day
                ) dpa ';

--      IF p_max_rows < 9999 THEN
         v_sql := v_sql||' WHERE rownum <= :p_max_rows + 1';
         EXECUTE immediate v_sql USING p_query_id, p_max_rows;
--      ELSE
--         EXECUTE immediate v_sql USING p_query_id;
--      END IF;

      p_num_rows := SQL%ROWCOUNT;
--      IF p_max_rows < 9999 THEN
         SET_MAX_ROW_IN_QUERY_MANAGER( p_query_id, p_num_rows, p_max_rows );
         p_num_rows := LEAST( p_num_rows, p_max_rows);
--      ELSE
--         SET_MAX_ROW_IN_QUERY_MANAGER( p_query_id, p_num_rows );
--      END IF;
   END GET_POSITION_SUMMARIES;

   PROCEDURE GET_CMDTY_EXP_PSTNS
      ( p_where_clause        IN  VARCHAR,
        p_exchange_code       IN  query_manager.exchange_code%TYPE,
        p_terminal_id         IN  query_manager.terminal_id%TYPE,
        p_transaction_id      IN  query_manager.transaction_id%TYPE,
        p_max_row_per_message IN  query_manager.max_row_per_message%TYPE,
        p_max_rows            IN  query_manager.max_row%TYPE,
        p_query_id            OUT query_manager.query_id%TYPE,
        p_num_rows            OUT query_manager.max_row%TYPE
      )
   AS v_sql VARCHAR2(8000);
   BEGIN
      p_query_id := INITIALISE_QUERY_MANAGER ( p_exchange_code
                                              ,p_terminal_id
                                              ,p_transaction_id
                                              ,'CEP'
                                              ,p_max_row_per_message
                                             );

      v_sql := 'INSERT INTO cep_results
                SELECT :p_query_id, rownum AS query_row_num, agg.* FROM
                    (SELECT position_day, exchange_code, clearer, firm, physical_commodity, logical_commodity, generic_contract_type,
                    sum(long_available_vol) as long_available_vol, sum(short_available_vol) as short_available_vol from
                    (SELECT position_day, exchange_code, clearer, firm, physical_commodity, logical_commodity, generic_contract_type,
                            CASE WHEN account_maintenance = ''G'' THEN
                                      SUM(long_adjusted_vol + man_exercised_vol + man_abandoned_vol)
                                 WHEN account_maintenance = ''N'' THEN
                                      SUM(CASE WHEN long_adjusted_vol > short_adjusted_vol
                                               THEN long_adjusted_vol + man_exercised_vol + man_abandoned_vol - short_adjusted_vol
                                               ELSE long_adjusted_vol + man_exercised_vol
                                          END)
                            END AS long_available_vol,
                            CASE WHEN account_maintenance = ''G'' THEN SUM(short_adjusted_vol)
                                 WHEN account_maintenance = ''N'' THEN SUM(GREATEST(short_adjusted_vol - long_adjusted_vol,0))
                            END AS short_available_vol
                     FROM ( SELECT /*+ LEADING(days,pka) USE_NL(days,pka) */
                                   pka.position_day,          pka.exchange_code,         pka.clearer,           pka.firm,              pka.physical_commodity,
                                   pka.logical_commodity,     pka.generic_contract_type, pka.long_adjusted_vol, pka.man_exercised_vol, pka.man_abandoned_vol,
                                   pka.short_adjusted_vol,    ai.account_maintenance,
                                   DECODE( cm.notice_expiry_day, NULL,
                                      DECODE(SUBSTR(TO_CHAR(pka.expiry_date),7,2),''00'',NULL,
                                         (SELECT trading_day
                                          FROM trading_calendar
                                          WHERE todays_date = TO_DATE( TO_CHAR(pka.expiry_date), ''YYYYMMDD'' ))),
                                      cm.notice_expiry_day
                                   ) AS notice_expiry_day
                              FROM position_keeping_account pka,
                                   account_information ai,
                                   (
                                    SELECT cm.*
                                    FROM commodity_month cm,
                                         trading_day td
                                    WHERE cm.trading_day     = td.trading_day
                                      AND cm.exchange_code   = td.exchange_code
                                      AND td.component_name  = ''POSITION_MAINTENANCE''
                                   ) cm,
                                   all_trading_days atd,
                                   trading_day td,
                                   (SELECT exchange_code, delivery_exercise_day AS delivery_exercise_day
                                    FROM all_trading_days
                                    UNION
                                    SELECT exchange_code, trading_day AS delivery_exercise_day
                                    FROM trading_day
                                    WHERE component_name=''POSITION_MAINTENANCE''
                                   ) days
                             WHERE pka.exchange_code            = days.exchange_code
                               AND pka.position_day             = days.delivery_exercise_day
                               AND pka.position_day             = ai.trading_day
                               AND pka.exchange_code            = ai.exchange_code
                               AND pka.position_ref             = ai.position_reference
                               AND cm.exchange_code (+)         = pka.exchange_code
                               AND cm.physical_commodity (+)    = pka.physical_commodity
                               AND cm.generic_contract_type (+) = pka.generic_contract_type
                               AND cm.expiry_date (+)           = pka.expiry_date
                               AND pka.position_day             = NVL( atd.delivery_exercise_day, td.trading_day)
                               AND atd.exchange_code(+)         = pka.exchange_code
                               AND atd.physical_commodity(+)    = pka.physical_commodity
                               AND atd.generic_contract_type(+) = pka.generic_contract_type
                               AND atd.expiry_date(+)           = pka.expiry_date
                               AND td.exchange_code             = pka.exchange_code AND td.component_name = ''POSITION_MAINTENANCE''
                    ) WHERE notice_expiry_day IS NOT NULL AND (' || p_where_clause || ')
                    GROUP BY position_day, exchange_code, clearer, firm, physical_commodity, logical_commodity, generic_contract_type, account_maintenance
                    HAVING
                    ( CASE WHEN account_maintenance = ''G'' THEN
                                      SUM(long_adjusted_vol + man_exercised_vol + man_abandoned_vol)
                                 WHEN account_maintenance = ''N'' THEN
                                      SUM(CASE WHEN long_adjusted_vol > short_adjusted_vol
                                               THEN long_adjusted_vol + man_exercised_vol + man_abandoned_vol - short_adjusted_vol
                                               ELSE long_adjusted_vol + man_exercised_vol
                                          END)
                            END > 0 OR
                            CASE WHEN account_maintenance = ''G'' THEN SUM(short_adjusted_vol)
                                 WHEN account_maintenance = ''N'' THEN SUM(GREATEST(short_adjusted_vol - long_adjusted_vol,0))
                            END > 0 )
                )
                GROUP BY position_day, exchange_code, clearer, firm, physical_commodity, logical_commodity, generic_contract_type
                ORDER BY clearer, firm, logical_commodity, physical_commodity, generic_contract_type
                ) agg ';

--      IF p_max_rows < 9999 THEN
         v_sql := v_sql || ' WHERE rownum <= :p_max_rows + 1';
         EXECUTE immediate v_sql USING p_query_id, p_max_rows;
--      ELSE
--         EXECUTE immediate v_sql USING p_query_id;
--      END IF;

      p_num_rows := SQL%ROWCOUNT;
--      IF p_max_rows < 9999 THEN
         SET_MAX_ROW_IN_QUERY_MANAGER( p_query_id, p_num_rows, p_max_rows );
         p_num_rows := LEAST( p_num_rows, p_max_rows);
--      ELSE
--         SET_MAX_ROW_IN_QUERY_MANAGER( p_query_id, p_num_rows );
--      END IF;
   END GET_CMDTY_EXP_PSTNS;

   PROCEDURE GET_SERIES_EXP_LNG_PSTNS
      ( p_where_clause        IN  VARCHAR,
        p_exchange_code       IN  query_manager.exchange_code%TYPE,
        p_terminal_id         IN  query_manager.terminal_id%TYPE,
        p_transaction_id      IN  query_manager.transaction_id%TYPE,
        p_max_row_per_message IN  query_manager.max_row_per_message%TYPE,
        p_max_rows            IN  query_manager.max_row%TYPE,
        p_query_id            OUT query_manager.query_id%TYPE,
        p_num_rows            OUT query_manager.max_row%TYPE
      )
   AS v_sql VARCHAR2(8000);
   BEGIN
      p_query_id := INITIALISE_QUERY_MANAGER ( p_exchange_code
                                              ,p_terminal_id
                                              ,p_transaction_id
                                              ,'SELP'
                                              ,p_max_row_per_message
                                             );

      -- NOTE: P239s are for options only so GENERIC_CONTRACT_TYPE is always 'O' ... thus this is used as part of the aggregation key
      v_sql := 'INSERT INTO selp_results
                SELECT :p_query_id, rownum AS query_row_num, agg.* FROM
                ( select position_day,          exchange_code, clearer,     firm, trader,   physical_commodity, logical_commodity,
                generic_contract_type, contract_type, expiry_date, exercise_price, valuation_price,
                sum(long_available_vol) as long_available_vol, man_exercised_vol,man_abandoned_vol,auto_exercise_notification from
                    (SELECT position_day,          exchange_code, clearer,     firm, trader,   physical_commodity, logical_commodity,
                            generic_contract_type, contract_type, expiry_date, exercise_price, valuation_price,
                            CASE WHEN account_maintenance = ''G'' THEN
                                      SUM(long_adjusted_vol + man_exercised_vol + man_abandoned_vol)
                                 WHEN account_maintenance = ''N'' THEN
                                      SUM(CASE WHEN long_adjusted_vol > short_adjusted_vol
                                               THEN long_adjusted_vol + man_exercised_vol + man_abandoned_vol - short_adjusted_vol
                                               ELSE 0
                                          END)
                            END                    AS long_available_vol,
                            SUM(man_exercised_vol) AS man_exercised_vol ,
                            SUM(man_abandoned_vol) AS man_abandoned_vol ,
                            0                      AS auto_exercise_notification
                     FROM ( SELECT /*+ LEADING(days,pka) USE_NL(days,pka) */
                                   pka.position_day,          pka.exchange_code,      pka.clearer,                pka.firm,           pka.trader,
                                   pka.physical_commodity,    pka.logical_commodity,  pka.generic_contract_type,  pka.contract_type,  pka.expiry_date,
                                   pka.exercise_price,        pka.valuation_price,
                                   pka.long_adjusted_vol,     pka.man_exercised_vol,  pka.man_abandoned_vol,      pka.short_adjusted_vol,
                                   ai.account_maintenance,
                                   DECODE( cm.notice_expiry_day, NULL,
                                      DECODE(SUBSTR(TO_CHAR(pka.expiry_date),7,2),''00'',NULL,
                                         (SELECT trading_day
                                          FROM trading_calendar
                                          WHERE todays_date = TO_DATE( TO_CHAR(pka.expiry_date), ''YYYYMMDD'' ))),
                                      cm.notice_expiry_day
                                   ) AS notice_expiry_day
                              FROM position_keeping_account pka,
                                   account_information ai,
                                   (
                                    SELECT cm.*
                                    FROM commodity_month cm,
                                         trading_day td
                                    WHERE cm.trading_day     = td.trading_day
                                      AND cm.exchange_code   = td.exchange_code
                                      AND td.component_name  = ''POSITION_MAINTENANCE''
                                   ) cm,
                                   all_trading_days atd,
                                   trading_day td,
                                   (select exchange_code, delivery_exercise_day AS delivery_exercise_day
                                    from all_trading_days
                                    union
                                    select exchange_code, trading_day AS delivery_exercise_day
                                    from trading_day
                                    where component_name=''POSITION_MAINTENANCE'') days
                             WHERE pka.exchange_code            = days.exchange_code
                               AND pka.position_day             = days.delivery_exercise_day
                               AND pka.position_day             = ai.trading_day
                               AND pka.exchange_code            = ai.exchange_code
                               AND pka.position_ref             = ai.position_reference
                               AND cm.exchange_code (+)         = pka.exchange_code
                               AND cm.physical_commodity (+)    = pka.physical_commodity
                               AND cm.generic_contract_type (+) = pka.generic_contract_type
                               AND cm.expiry_date (+)           = pka.expiry_date
                               AND pka.position_day             = NVL( atd.delivery_exercise_day, td.trading_day)
                               AND atd.exchange_code(+)         = pka.exchange_code
                               AND atd.physical_commodity(+)    = pka.physical_commodity
                               AND atd.generic_contract_type(+) = pka.generic_contract_type
                               AND atd.expiry_date(+)           = pka.expiry_date
                               AND td.exchange_code             = pka.exchange_code AND td.component_name = ''POSITION_MAINTENANCE''
                    ) WHERE notice_expiry_day IS NOT NULL AND (' || p_where_clause || ')
                    GROUP BY position_day, exchange_code, clearer, firm, trader, physical_commodity, logical_commodity,
                             generic_contract_type, contract_type, account_maintenance, expiry_date, exercise_price, valuation_price
                    HAVING
                    ( CASE WHEN account_maintenance = ''G'' THEN
                                      SUM(long_adjusted_vol + man_exercised_vol + man_abandoned_vol)
                                 WHEN account_maintenance = ''N'' THEN
                                      SUM(CASE WHEN long_adjusted_vol > short_adjusted_vol
                                               THEN long_adjusted_vol + man_exercised_vol + man_abandoned_vol - short_adjusted_vol
                                               ELSE 0
                                          END)
                            END > 0 OR
                            SUM(man_exercised_vol) > 0 OR
                            SUM(man_abandoned_vol) > 0 )
                )
                GROUP BY position_day,          exchange_code, clearer,     firm, trader,   physical_commodity, logical_commodity,
                generic_contract_type, contract_type, expiry_date, exercise_price, valuation_price,
                man_exercised_vol,man_abandoned_vol,auto_exercise_notification
                ORDER BY clearer, firm, logical_commodity, physical_commodity, contract_type, exercise_price
                )agg';

--      IF p_max_rows < 9999 THEN
         v_sql := v_sql || ' WHERE rownum <= :p_max_rows + 1';
         EXECUTE immediate v_sql USING p_query_id, p_max_rows;
--      ELSE
--         EXECUTE immediate v_sql USING p_query_id;
--      END IF;

      p_num_rows := SQL%ROWCOUNT;
--      IF p_max_rows < 9999 THEN
         SET_MAX_ROW_IN_QUERY_MANAGER( p_query_id, p_num_rows, p_max_rows );
         p_num_rows := LEAST( p_num_rows, p_max_rows);
--      ELSE
--         SET_MAX_ROW_IN_QUERY_MANAGER( p_query_id, p_num_rows );
--      END IF;
   END GET_SERIES_EXP_LNG_PSTNS;

END pkg_query_manager;
/
