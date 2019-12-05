column name 		format a30
column value 		format a50
column set 		format a5

VARIABLE param_info REFCURSOR

DECLARE

x varchar2(6);

BEGIN

select decode(count(*), 1, 'spfile', 'pfile') file_type
  into x
  from v$spparameter
 where rownum = 1
   and isspecified ='TRUE'
;
 
 if x = 'spfile' then
 
 OPEN :param_info FOR 
   select name, value, isspecified "set"
     from v$spparameter
    where isspecified = 'TRUE'
   union all
   select name, value, isspecified "set"
     from v$spparameter
    where isspecified = 'FALSE';


 dbms_output.put_line (chr(10));
 dbms_output.put_line ('SPFILE USED, REPORTING PARAMETERS...');
 dbms_output.put_line (chr(10));
 
 
 else

 OPEN :param_info FOR 
   select name, value, isdefault "set"
     from v$parameter
    where isdefault = 'FALSE'
   union all
   select name, value, isdefault "set"
     from v$parameter
    where isdefault = 'TRUE';

 dbms_output.put_line (chr(10));
 dbms_output.put_line ('PFILE USED, REPORTING PARAMETERS...');
 dbms_output.put_line (chr(10));
  
 end if;

END;
/

print param_info;