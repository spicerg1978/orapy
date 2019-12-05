select 	j.log_user,
	j.broken,
	j.failures,
	j.last_date||':'||j.last_sec  last_date,
	j.this_date||':'||j.this_sec  this_date,
	j.next_date||':'||j.this_sec  next_date,
	j.next_date - j.last_date interval,
	j.what
  from	(select dj.log_user, dj.job, dj.broken, dj.failures, dj.last_date,
                dj.last_sec, dj.this_date, dj.this_sec, dj.next_date, dj.next_sec,
                dj.interval, dj.what
           from dba_jobs dj) j
