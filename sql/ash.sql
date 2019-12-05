select sample_time, session_id, session_serial#, sql_id, event, wait_class, wait_time, blocking_session, time_waited, module
from dba_hist_active_sess_history
order by SAMPLE_TIME
