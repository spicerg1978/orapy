select *
from (
     select owner, segment_name, segment_type, block_id
       from dba_extents
      where file_id = ( select file_id
                          from dba_data_files
                         where file_name = '/oradata/PTRI01/ora6/PTRI01_app02.dbf' )
      order by block_id desc
           )
    where rownum <= 5
 
