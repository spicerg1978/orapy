SELECT 			tablespace_name, file_id, bytes, blocks, status, file_name
  FROM 			  sys.dba_data_files
 WHERE 		   tablespace_name IN (SELECT	DISTINCT(tablespace_name)
		  			 FROM	(SELECT   tablespace_name
					           FROM	  dba_ind_partitions
						  UNION 
						 SELECT	  tablespace_name
						   FROM   dba_indexes
						 ))
 ORDER BY tablespace_name, file_id
