-- Selection Note aggregated by position

select note.position_day,note.contract_type,note.exercise_price,note.exchange_code        
,note.logical_commodity ,note.physical_commodity   ,note.generic_contract_type
,note.expiry_date ,note.long_short_ind,
case when volume_change > 0 then 1 else 2 end as IND,
count(*) as count, sum(volume_change) as vol_change, sum(volume_change * valuation_price) as ticks
from notification note
where notification_type = 'T' and notification_status in ('RN','AN')
and note_processed_day = 0
and exchange_code = 'O'
group by note.position_day, note.contract_type, note.exercise_price, note.exchange_code,
note.logical_commodity, note.physical_commodity, note.generic_contract_type,
note.expiry_date, note.long_short_ind, case when volume_change > 0 then 1 else 2 end
order by 
note.position_day,note.contract_type,note.exercise_price,note.exchange_code        
,note.logical_commodity ,note.physical_commodity   ,note.generic_contract_type
,note.expiry_date ,note.long_short_ind

;

--Selecting PKA

select * from position_keeping_account pka
where (pka.position_day,pka.contract_type,pka.exercise_price,pka.exchange_code        
,pka.logical_commodity ,pka.physical_commodity   ,pka.generic_contract_type
,pka.expiry_date ,pka.position_ref )
in
(
select note.position_day,note.contract_type,note.exercise_price,note.exchange_code        
,note.logical_commodity ,note.physical_commodity   ,note.generic_contract_type
,note.expiry_date ,note.position_ref
from notification note
where note_creation_day = 7629 and  notification_type = 'T' and notification_status in ('RN','AN') and note_processed_day = 0
and note.all_lots_ind <> 'Y' 
) 
and exchange_code = 'O'

;


--Changing PKA  LONG long_account_vol


update  position_keeping_account  pka 
SET  pka.long_account_vol =   pka.long_account_vol -
(
select  sum(note.volume_change) from notification note
--,position_keeping_account  pka 
where note.position_day = pka.position_day
and note.exchange_code = pka.exchange_code
and note.position_ref= pka.position_ref
and note.contract_type = pka.contract_type 
and note.physical_commodity = pka.physical_commodity
and note.expiry_date = pka.expiry_date
and note.exercise_price = pka.exercise_price
and note.note_creation_day = 7629 and  note.notification_type = 'T'
and pka.position_day  = 7629
and note.notification_status in ('RN','AN') and note.note_processed_day = 0
and note.all_lots_ind <> 'Y'
and note.long_short_ind = 'L'
)

where (pka.position_day,pka.contract_type,pka.exercise_price,pka.exchange_code        
,pka.logical_commodity ,pka.physical_commodity   ,pka.generic_contract_type
,pka.expiry_date ,pka.position_ref )
in
(
select note.position_day,note.contract_type,note.exercise_price,note.exchange_code        
,note.logical_commodity ,note.physical_commodity   ,note.generic_contract_type
,note.expiry_date ,note.position_ref
from notification note
where note_creation_day = 7629 and  notification_type = 'T' and notification_status in ('RN','AN') and note_processed_day = 0
and note.all_lots_ind <> 'Y' and note.long_short_ind = 'L' 
) 
and exchange_code = 'O'
and pka.position_day  = 7629

;


--SHORT short_account_vol


update  position_keeping_account  pka 
SET  pka.short_account_vol =   pka.short_account_vol -
(
select  sum(note.volume_change) from notification note
--,position_keeping_account  pka 
where note.position_day = pka.position_day
and note.exchange_code = pka.exchange_code
and note.position_ref= pka.position_ref
and note.contract_type = pka.contract_type 
and note.physical_commodity = pka.physical_commodity
and note.expiry_date = pka.expiry_date
and note.exercise_price = pka.exercise_price
and note.note_creation_day = 7629 and  note.notification_type = 'T'
and pka.position_day  = 7629
and note.notification_status in ('RN','AN') and note.note_processed_day = 0
and note.all_lots_ind <> 'Y'
and note.long_short_ind = 'S'
)

where (pka.position_day,pka.contract_type,pka.exercise_price,pka.exchange_code        
,pka.logical_commodity ,pka.physical_commodity   ,pka.generic_contract_type
,pka.expiry_date ,pka.position_ref )
in
(
select note.position_day,note.contract_type,note.exercise_price,note.exchange_code        
,note.logical_commodity ,note.physical_commodity   ,note.generic_contract_type
,note.expiry_date ,note.position_ref
from notification note
where note_creation_day = 7629 and  notification_type = 'T' and notification_status in ('RN','AN') and note_processed_day = 0
and note.all_lots_ind <> 'Y' and note.long_short_ind = 'S' 
) 
and exchange_code = 'O'
and pka.position_day  = 7629

;


--Profit Long


update  position_keeping_account  pka 
SET  pka.profit =   pka.profit - pka.valuation_price * 
(
select  sum(note.volume_change) from notification note
--,position_keeping_account  pka 
where note.position_day = pka.position_day
and note.exchange_code = pka.exchange_code
and note.position_ref= pka.position_ref
and note.contract_type = pka.contract_type 
and note.physical_commodity = pka.physical_commodity
and note.expiry_date = pka.expiry_date
and note.exercise_price = pka.exercise_price
and note.note_creation_day = 7629 and  note.notification_type = 'T'
and pka.position_day  = 7629
and note.notification_status in ('RN','AN') and note.note_processed_day = 0
and note.all_lots_ind <> 'Y'
and note.long_short_ind = 'L'
)
 + 
 (
select  sum(note.volume_change * note.valuation_price) from notification note
--,position_keeping_account  pka 
where note.position_day = pka.position_day
and note.exchange_code = pka.exchange_code
and note.position_ref= pka.position_ref
and note.contract_type = pka.contract_type 
and note.physical_commodity = pka.physical_commodity
and note.expiry_date = pka.expiry_date
and note.exercise_price = pka.exercise_price
and note.note_creation_day = 7629 and  note.notification_type = 'T'
and pka.position_day  = 7629
and note.notification_status in ('RN','AN') and note.note_processed_day = 0
and note.all_lots_ind <> 'Y'
and note.long_short_ind = 'L'
)

where (pka.position_day,pka.contract_type,pka.exercise_price,pka.exchange_code        
,pka.logical_commodity ,pka.physical_commodity   ,pka.generic_contract_type
,pka.expiry_date ,pka.position_ref )
in
(
select note.position_day,note.contract_type,note.exercise_price,note.exchange_code        
,note.logical_commodity ,note.physical_commodity ,note.generic_contract_type
,note.expiry_date ,note.position_ref
from notification note , commodity_contract cc
where note.position_day = cc.trading_day
and note.exchange_code = cc.exchange_code
and note.generic_contract_type = cc.generic_contract_type
and note.physical_commodity = cc.physical_commodity
and note_creation_day = 7629 and  notification_type = 'T' and notification_status in ('RN','AN') and note_processed_day = 0
and note.all_lots_ind <> 'Y' and note.long_short_ind = 'L' 
and cc.futures_style_margining_ind = 'Y'
) 
and exchange_code = 'O'
and pka.position_day  = 7629

;


--Profit Short


update  position_keeping_account  pka 
SET  pka.profit =   pka.profit + pka.valuation_price * 
(
select  sum(note.volume_change) from notification note
--,position_keeping_account  pka 
where note.position_day = pka.position_day
and note.exchange_code = pka.exchange_code
and note.position_ref= pka.position_ref
and note.contract_type = pka.contract_type 
and note.physical_commodity = pka.physical_commodity
and note.expiry_date = pka.expiry_date
and note.exercise_price = pka.exercise_price
and note.note_creation_day = 7629 and  note.notification_type = 'T'
and pka.position_day  = 7629
and note.notification_status in ('RN','AN') and note.note_processed_day = 0
and note.all_lots_ind <> 'Y'
and note.long_short_ind = 'S'
)
 -
 (
select  sum(note.volume_change * note.valuation_price) from notification note
--,position_keeping_account  pka 
where note.position_day = pka.position_day
and note.exchange_code = pka.exchange_code
and note.position_ref= pka.position_ref
and note.contract_type = pka.contract_type 
and note.physical_commodity = pka.physical_commodity
and note.expiry_date = pka.expiry_date
and note.exercise_price = pka.exercise_price
and note.note_creation_day = 7629 and  note.notification_type = 'T'
and pka.position_day  = 7629
and note.notification_status in ('RN','AN') and note.note_processed_day = 0
and note.all_lots_ind <> 'Y'
and note.long_short_ind = 'S'
)

where (pka.position_day,pka.contract_type,pka.exercise_price,pka.exchange_code        
,pka.logical_commodity ,pka.physical_commodity   ,pka.generic_contract_type
,pka.expiry_date ,pka.position_ref )
in
(
select note.position_day,note.contract_type,note.exercise_price,note.exchange_code        
,note.logical_commodity ,note.physical_commodity ,note.generic_contract_type
,note.expiry_date ,note.position_ref
from notification note , commodity_contract cc
where note.position_day = cc.trading_day
and note.exchange_code = cc.exchange_code
and note.generic_contract_type = cc.generic_contract_type
and note.physical_commodity = cc.physical_commodity
and note_creation_day = 7629 and  notification_type = 'T' and notification_status in ('RN','AN') and note_processed_day = 0
and note.all_lots_ind <> 'Y' and note.long_short_ind = 'S' 
and cc.futures_style_margining_ind = 'Y'
) 
and exchange_code = 'O'
and pka.position_day  = 7629

;

--premium Long 


update  position_keeping_account  pka 
SET  pka.premium =   pka.premium  + 
 (
select  sum(note.volume_change * note.valuation_price) from notification note
--,position_keeping_account  pka 
where note.position_day = pka.position_day
and note.exchange_code = pka.exchange_code
and note.position_ref= pka.position_ref
and note.contract_type = pka.contract_type 
and note.physical_commodity = pka.physical_commodity
and note.expiry_date = pka.expiry_date
and note.exercise_price = pka.exercise_price
and note.note_creation_day = 7629 and  note.notification_type = 'T'
and pka.position_day  = 7629
and note.notification_status in ('RN','AN') and note.note_processed_day = 0
and note.all_lots_ind <> 'Y'
and note.long_short_ind = 'L'
)

where (pka.position_day,pka.contract_type,pka.exercise_price,pka.exchange_code        
,pka.logical_commodity ,pka.physical_commodity   ,pka.generic_contract_type
,pka.expiry_date ,pka.position_ref )
in
(
select note.position_day,note.contract_type,note.exercise_price,note.exchange_code        
,note.logical_commodity ,note.physical_commodity ,note.generic_contract_type
,note.expiry_date ,note.position_ref
from notification note , commodity_contract cc
where note.position_day = cc.trading_day
and note.exchange_code = cc.exchange_code
and note.generic_contract_type = cc.generic_contract_type
and note.physical_commodity = cc.physical_commodity
and note_creation_day = 7629 and  notification_type = 'T' and notification_status in ('RN','AN') and note_processed_day = 0
and note.all_lots_ind <> 'Y' and note.long_short_ind = 'L' 
and cc.futures_style_margining_ind <> 'Y'
) 
and exchange_code = 'O'
and pka.position_day  = 7629


;


--premium  Short


update  position_keeping_account  pka 
SET  pka.premium =   pka.premium  - 
 (
select  sum(note.volume_change * note.valuation_price) from notification note
--,position_keeping_account  pka 
where note.position_day = pka.position_day
and note.exchange_code = pka.exchange_code
and note.position_ref= pka.position_ref
and note.contract_type = pka.contract_type 
and note.physical_commodity = pka.physical_commodity
and note.expiry_date = pka.expiry_date
and note.exercise_price = pka.exercise_price
and note.note_creation_day = 7629 and  note.notification_type = 'T'
and pka.position_day  = 7629
and note.notification_status in ('RN','AN') and note.note_processed_day = 0
and note.all_lots_ind <> 'Y'
and note.long_short_ind = 'S'
)

where (pka.position_day,pka.contract_type,pka.exercise_price,pka.exchange_code        
,pka.logical_commodity ,pka.physical_commodity   ,pka.generic_contract_type
,pka.expiry_date ,pka.position_ref )
in
(
select note.position_day,note.contract_type,note.exercise_price,note.exchange_code        
,note.logical_commodity ,note.physical_commodity ,note.generic_contract_type
,note.expiry_date ,note.position_ref
from notification note , commodity_contract cc
where note.position_day = cc.trading_day
and note.exchange_code = cc.exchange_code
and note.generic_contract_type = cc.generic_contract_type
and note.physical_commodity = cc.physical_commodity
and note_creation_day = 7629 and  notification_type = 'T' and notification_status in ('RN','AN') and note_processed_day = 0
and note.all_lots_ind <> 'Y' and note.long_short_ind = 'S' 
and cc.futures_style_margining_ind <> 'Y'
) 
and exchange_code = 'O'
and pka.position_day  = 7629

;


--Selecting PKA


select * from position_keeping_account pka
where (pka.position_day,pka.contract_type,pka.exercise_price,pka.exchange_code        
,pka.logical_commodity ,pka.physical_commodity   ,pka.generic_contract_type
,pka.expiry_date ,pka.position_ref )
in
(
select note.position_day,note.contract_type,note.exercise_price,note.exchange_code        
,note.logical_commodity ,note.physical_commodity   ,note.generic_contract_type
,note.expiry_date ,note.position_ref
from notification note
where note_creation_day = 7629 and  notification_type = 'T' and notification_status in ('RN','AN') and note_processed_day = 0
and note.all_lots_ind <> 'Y' 
) 
and exchange_code = 'O'
;

