--  *********************************************
--   locks.sql
--      This program is used to show both:
--		1) users waiting for locked resources and:
--		2) the users who are locking those who are waiting
--
--  *********************************************

set linesize 80
set verify off

column username 	format a10
column lockwait		format a10
column sql		format a70 word_wrap
column object_owner	format a15
column object		format a20

break on sid  skip 2

prompt   This script shows all users who are waiting for locked resources...

SELECT
     b.username,
     b.serial#,
     c.sid,
     c.owner object_owner,
     c.object,
     a.sql_text SQL
FROM v$access c, v$sqltext a, v$session b
WHERE
     a.address = b.sql_address
     AND
     a.hash_value = b.sql_hash_value
     AND
     b.sid = c.sid
     AND
     b.lockwait IS NOT NULL
     AND
     c.owner NOT IN ('SYS','SYSTEM');


-- **********************************************
-- This script will also show the SQL being executed by the user.  NOTE: If 
-- the locking user is no longer executing any SQL, rows returned will be 0. 
-- The user, however, is still locking the above users since he/she has not 
-- yet committed his/her transaction -- maybe they are away from their desk?? 
-- You should call them and ask them to either commit or rollback.
-- **********************************************

prompt This script shows the users who are locking the above waiting resources... 

SELECT
      x.sid,
      x.serial#,
      x.username,
      y.id1,
      z.sql_text SQL
FROM  v$sqltext z, v$session x, v$lock y
WHERE y.id1 
      IN
         (SELECT distinct b.id1
          FROM v$lock b, v$session a
          WHERE b.kaddr = a.lockwait)
      AND x.sid = y.sid
      AND z.hash_value = x.sql_hash_value
      AND y.request = 0
;

