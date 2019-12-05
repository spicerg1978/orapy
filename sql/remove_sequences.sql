
set serveroutput on

begin
    for x in (select sequence_name from user_sequences)
   loop
     dbms_output.put_line('drop sequence '||x.sequence_name);
     execute immediate 'drop sequence '||x.sequence_name;
   end loop;
 end;
/


