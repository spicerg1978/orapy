select to_char(trunc((sample_time),'HH'),'YYYMMDD:HH24:MI:SS'), state, count(*)/360
      from
        (select  sample_time,   sample_id
        ,  CASE  WHEN session_state = 'ON CPU' THEN 'CPU'
                 WHEN session_state = 'WAITING' AND wait_class IN ('User I/O') THEN 'IO'
                 WHEN session_state = 'WAITING' AND wait_class IN ('Cluster') THEN 'CLUSTER'
                 WHEN session_state = 'WAITING' AND wait_class IN ('Concurrency') THEN 'CONCURRENCY'
                 WHEN session_state = 'WAITING' AND wait_class IN ('System I/O') THEN 'SYSTEM I/O'
                 WHEN session_state = 'WAITING' AND wait_class IN ('Configuration') THEN 'CONFIGURATION'
                 WHEN session_state = 'WAITING' AND wait_class IN ('Application') THEN 'APPLICATION'
                 WHEN session_state = 'WAITING' AND wait_class IN ('Network') THEN 'NETWORK'
                 WHEN session_state = 'WAITING' AND wait_class IN ('Commit') THEN 'COMMIT'
                 ELSE 'WAIT' END state
          from DBA_HIST_ACTIVE_SESS_HISTORY
          where   session_type IN ( 'FOREGROUND')
         and sample_time  between trunc(sysdate-2,'HH') - 25/24 and trunc(sysdate,'HH') - 1/24  )
  group by trunc((sample_time),'HH'), state order by 2, 1
