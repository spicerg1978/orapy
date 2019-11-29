declare
  DateEpoch constant date := date '2019-01-01';
  vDate date;
  n pls_integer;
begin
   for i in 1..365
    loop
     vDate := DateEpoch + i;
     n := dbms_random.value(1,100);  
     insert into file_io
     values
     (vDate,'datafile 05',n);
 end loop;
commit;
end;
/

