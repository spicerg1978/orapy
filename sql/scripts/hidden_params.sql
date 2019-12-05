select name, value, isdefault, ismodified, isset
  from
     ( 
     select flag,name,value,isdefault,ismodified,
            case when isdefault||ismodified = 'TRUEFALSE' then 'FALSE' else 'TRUE' end isset
     from
        (
         select
               decode(substr(i.ksppinm,1,1),'_',2,1) flag
               , i.ksppinm name
               , sv.ksppstvl value
               , sv.ksppstdf  isdefault
               , decode(bitand(sv.ksppstvf,7),1,'TRUE',4,'TRUE','FALSE') ismodified
          from x$ksppi  i
               , x$ksppsv sv
         where i.indx = sv.indx
        )
    )
where name like nvl('%&parameter%',name)
  and upper(isset) like upper(nvl('%&isset%',isset))
  and flag not in (decode('&show_hidden','Y',3,2))
order by flag,replace(name,'_','')

