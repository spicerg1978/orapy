select 
to_char(sn.END_INTERVAL_TIME,'YYYY-MM-DD HH24:MI:SS') "End snapshot time",
sum(after.PHYRDS+after.PHYWRTS-before.PHYWRTS-before.PHYRDS) "number of IOs",
trunc(10*sum(after.READTIM+after.WRITETIM-before.WRITETIM-before.READTIM)/
sum(1+after.PHYRDS+after.PHYWRTS-before.PHYWRTS-before.PHYRDS)) "ave IO time (ms)",
trunc(sum(after.block_size * (after.PHYBLKRD+after.PHYBLKWRT-before.PHYBLKRD-before.PHYBLKWRT))/
sum(1+after.PHYRDS+after.PHYWRTS-before.PHYWRTS-before.PHYRDS)) "ave IO size (bytes)"
from DBA_HIST_FILESTATXS before, DBA_HIST_FILESTATXS after,DBA_HIST_SNAPSHOT sn
where 
after.file#=before.file# and
after.snap_id=before.snap_id+1 and
before.instance_number=after.instance_number and
after.snap_id=sn.snap_id and
after.instance_number=sn.instance_number
group by to_char(sn.END_INTERVAL_TIME,'YYYY-MM-DD HH24:MI:SS')
HAVING 
SUM(after.PHYRDS + after.PHYWRTS - before.PHYWRTS - before.PHYRDS) >= 0 AND 
SUM(after.PHYBLKRD + after.PHYBLKWRT - before.PHYBLKRD - before.PHYBLKWRT) >= 0
order by to_char(sn.END_INTERVAL_TIME,'YYYY-MM-DD HH24:MI:SS');
