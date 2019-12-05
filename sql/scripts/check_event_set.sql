set serveroutput on 
declare event_level number; 
begin for i in 10000..10999 
loop sys.dbms_system.read_ev(i,event_level); 
if (event_level > 0) then 
   dbms_output.put_line('Event '||to_char(i)||' set at level '|| to_char(event_level)); 
end if; 
end loop; 
end; 
/


alter system set events'10949 trace name context forever, level 1';