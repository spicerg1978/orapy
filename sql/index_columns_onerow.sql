CREATE OR REPLACE FUNCTION portal_owner.get_index_cols (indexname VARCHAR2) 
RETURN VARCHAR2 
IS
cols VARCHAR2(400);
name varchar2(400);
cnt number;
x number;
BEGIN
    
    x := 1;
    
    select max(column_position) into cnt
    from   user_ind_columns
    where  index_name = indexname;
    
    while x <= cnt loop
    
    SELECT column_name INTO name
    FROM   user_ind_columns
    WHERE  index_name = indexname
    and    column_position = x;

    if (x = 1) then
    cols := name;
    else
    cols := cols ||', '|| name;
    end if;
    --cols := 'test';
    
    x := x+1;
    end loop;
    
    --cols := 'test';
  RETURN cols;
END;