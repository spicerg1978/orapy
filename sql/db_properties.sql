set lines 1000
column PROPERTY_NAME 	format a30        
column PROPERTY_VALUE 	format a30
column DESCRIPTION   	format a200

select * from database_properties
 order by property_name;