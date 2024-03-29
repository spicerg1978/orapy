select sum( u.blocks * blk.block_size)/1024/1024 "Mb. in sort segments"
, (hwm.max * blk.block_size)/1024/1024 "Mb. High Water Mark"
from v$sort_usage u, (select block_size
from dba_tablespaces
where contents = 'TEMPORARY') blk
, (select segblk#+blocks max
from v$sort_usage
where segblk# = (select max(segblk#) from v$sort_usage) ) hwm
group by hwm.max * blk.block_size/1024/1024;



SELECT S.sid, S.serial# sid_serial, S.username, S.osuser, P.spid, S.module,
P.program, SUM (T.blocks) * TBS.block_size / 1024 / 1024 mb_used, T.tablespace,
COUNT(*) statements
FROM v$sort_usage T, v$session S, dba_tablespaces TBS, v$process P
WHERE T.session_addr = S.saddr
AND S.paddr = P.addr
AND T.tablespace = TBS.tablespace_name
GROUP BY S.sid, S.serial#, S.username, S.osuser, P.spid, S.module,
P.program, TBS.block_size, T.tablespace
ORDER BY sid_serial
/
