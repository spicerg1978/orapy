SELECT a.tablespace_name                            tsname,
       a.contents                                   Type,
       a.extent_management                          "Extent Mngmt",
       round(b.bytes/(1024*1024),2)                 SIZE_MB,
       round(c.free_bytes/(1024*1024),2)            FREE_MB,
       round((b.bytes-c.free_bytes)/(1024*1024),2)  USED_MB,
       a.status	
  FROM dba_tablespaces a,
              (  SELECT tablespace_name, sum(bytes) bytes
                   FROM dba_data_files
               GROUP BY tablespace_name
               UNION
                 SELECT tablespace_name, sum(bytes) bytes
                   FROM dba_temp_files
               GROUP BY tablespace_name) b,
              (  SELECT ddf.tablespace_name, 
                        nvl(sum(dfs.bytes),0) free_bytes, 
                        (sum(ddf.bytes)-sum(dfs.bytes)) used_bytes
                   FROM dba_free_space dfs , dba_data_files ddf
                  WHERE dfs.file_id (+)=ddf.file_id
               GROUP BY ddf.tablespace_name
               UNION
                 SELECT tablespace_name, sum(bytes_free) free_bytes, sum(bytes_used) used_bytes 
                   FROM v$temp_space_header
               GROUP BY tablespace_name) c
  WHERE a.tablespace_name=b.tablespace_name
    AND c.tablespace_name=a.tablespace_name
    AND c.tablespace_name=b.tablespace_name
ORDER BY 1
