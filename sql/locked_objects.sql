COLUMN owner FORMAT A20
COLUMN username FORMAT A20
COLUMN object_owner FORMAT A20
COLUMN object_name FORMAT A30
COLUMN locked_mode FORMAT A15

SELECT b.session_id AS sid,
       NVL(b.oracle_username, '(oracle)') AS username,
       a.owner AS object_owner,
       a.object_name,
       Decode(b.locked_mode, 0, 'None NO LOCK',
                             1, 'Null (NULL) ROW SHARE',
                             2, 'Row-S (SS) ',
                             3, 'Row-X (SX) ROW EXCLUSIVE',
                             4, 'Share (S) SHARE',
                             5, 'S/Row-X (SSX) SHARE ROW EXCL',
                             6, 'Exclusive (X) EXCLUSIVE',
                             b.locked_mode) locked_mode,
       b.os_user_name
  FROM dba_objects a,
       v$locked_object b
 WHERE a.object_id = b.object_id
ORDER BY 1, 2, 3, 4;

SET PAGESIZE 14
SET VERIFY ON


