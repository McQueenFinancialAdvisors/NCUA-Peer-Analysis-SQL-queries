select
repdte as report_date,
cert||'_'||'B' as institution_id,
cert as client_number,
name as client_name,
city as city,
stalp as state,
'B' as client_type,
intincy / 100 as yld_earn_assets,
intexpy / 100 as cost_funding_earn_assets,
nimy / 100 as net_int_margin,
noniiay / 100 as nonint_inc_to_assets,
nonixay / 100 as nonint_exp_to_assets,
elnatry / 100 as cred_loss_provision,
noijy / 100 as net_oper_inc_to_assets,
roa / 100 as return_on_assets,
roaptx / 100 as return_on_assets_pretax,
roe / 100 as return_on_equity,
roeinjr / 100 as retain_earn_to_ave_equity,
ntlnlsr / 100 as net_chrg_offs_to_ln_lease,
elnantr / 100 as ln_lease_loss_prov_to_net_chrg_offs,
iderncvr as earn_cover_net_loan_chrg_offs,
eeffr / 100 as efficiency_ratio,
astempm * 1000000 as assets_per_employ,  --displayed as 3.4 ($ Million)
iddivnir / 100 as cash_div_to_net_inc_ytd
from fdic_performance_conditions_ratios
where
--repdte between '2010-12-31' and '2021-09-30'
repdte = '2021-09-30'
and cert in ('845','847','2452','15664','16620','19674','22273','34953','30219','14926')
order by repdte desc;