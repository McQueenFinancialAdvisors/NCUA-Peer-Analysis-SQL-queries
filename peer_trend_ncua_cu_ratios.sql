WITH PYE as (  
select
fs220.cycle_date,
fs220.cu_number,
fs220.acct_010,
fs220.acct_025b,
fs220a.acct_799i,
fs220a.acct_730b,
fs220a.acct_730c,
fs220b.acct_781,
fs220c.acct_003,
fs220.Acct_018,
fs220.acct_860c,
fs220a.Acct_997

from ncua_fs220 fs220
full join ncua_fs220a fs220a
on fs220.cu_number = fs220a.cu_number
and fs220.cycle_date = fs220a.cycle_date
full join ncua_fs220b fs220b
on fs220.cu_number = fs220b.cu_number
and fs220.cycle_date = fs220b.cycle_date
full join ncua_fs220c fs220c
on fs220.cu_number = fs220c.cu_number
and fs220.cycle_date = fs220c.cycle_date
where fs220.cycle_date in ((select cast((date_part('year', cycle_date)) - 1 || '-12-31' as date) as pye_date
from ncua_fs220))
)

select
foicu.cycle_date as report_date,
foicu.cu_number||'_'||'C' as institution_id,
foicu.cu_number as client_number,
foicu.cu_name as client_name,
foicu.city as city,
foicu.state as state,
'C' as client_type,
((case when (sum(fs220a.acct_110) - sum(fs220a.acct_119))/
            nullif((((sum(fs220.acct_025b) + sum(pye.acct_025b)) + (sum(fs220c.acct_003) + sum(pye.acct_003)))/2),0) IS NULL
       then 0
       else (sum(fs220a.acct_110) - sum(fs220a.acct_119))/
            (((sum(fs220.acct_025b) + sum(pye.acct_025b)) + (sum(fs220c.acct_003) + sum(pye.acct_003)))/2)
       end  * (12/(date_part('month', foicu.cycle_date)))) * sum(fs220.Acct_025b) --- Total Loan yield * Total Loans
+
(case when (sum(fs220a.Acct_120) + sum(fs220n.Acct_IS0004))/
           nullif(((sum(fs220q.acct_nv0158) + sum(fs220a.acct_730b) + sum(fs220a.acct_730c)
 + sum(pye.acct_799i) + sum(pye.acct_730b) + sum(pye.acct_730c))/2),0) IS NULL
      then 0
      else (sum(fs220a.Acct_120) + sum(fs220n.Acct_IS0004))/
            ((sum(fs220q.acct_nv0158) + sum(fs220a.acct_730b) + sum(fs220a.acct_730c)
 + sum(pye.acct_799i) + sum(pye.acct_730b) + sum(pye.acct_730c))/2)
      end  * (12/(date_part('month', foicu.cycle_date)))) * sum(fs220q.acct_nv0158))-- Total Investment Yield * Total Investments
 / nullif((((sum(fs220.acct_025b) + sum(pye.acct_025b)) + (sum(fs220q.acct_nv0158) + sum(pye.Acct_799i)))/2),0) as yld_earn_assets,-- as yld_earn_assets,

(case when (sum(fs220.Acct_340) + sum(fs220.Acct_380) + sum(fs220a.Acct_381))/
            nullif(((sum(fs220.acct_010) + sum(pye.acct_010))/2),0) IS NULL
       then 0
       else (sum(fs220.Acct_340) + sum(fs220.Acct_380) + sum(fs220a.Acct_381))/
            ((sum(fs220.acct_010) + sum(pye.acct_010))/2)
       end  * (12/(date_part('month', foicu.cycle_date)))) as cost_funding_earn_assets, --cost_funding_earn_assets,

(case when (sum(fs220a.Acct_115) - sum(fs220a.Acct_350))/nullif((sum(fs220.acct_010) + sum(pye.acct_010))/2,0) IS NULL
        then 0
        else (sum(fs220a.Acct_115) - sum(fs220a.Acct_350))/((sum(fs220.acct_010) + sum(pye.acct_010))/2)
        end * (12/(date_part('month', foicu.cycle_date)))) as net_int_margin,-- as net_int_margin,
 
(case when (sum(fs220a.Acct_117))/nullif((sum(fs220.acct_010) + sum(pye.acct_010))/2,0) IS NULL
        then 0
        else (sum(fs220a.Acct_117))/((sum(fs220.acct_010) + sum(pye.acct_010))/2)
        end * (12/(date_part('month', foicu.cycle_date)))) as nonint_inc_to_assets,-- as nonint_inc_to_assets,
 
(case when (sum(fs220.Acct_671))/nullif((sum(fs220.acct_010) + sum(pye.acct_010))/2,0) IS NULL
        then 0
        else (sum(fs220.Acct_671))/((sum(fs220.acct_010) + sum(pye.acct_010))/2)
        end * (12/(date_part('month', foicu.cycle_date)))) as nonint_exp_to_assets,-- as nonint_exp_to_assets,

(case when (sum(fs220.Acct_300) + sum(fs220n.Acct_is0011))/nullif((sum(fs220.acct_010) + sum(pye.acct_010))/2,0) IS NULL
        then 0
        else (sum(fs220.Acct_300) + sum(fs220n.Acct_is0011))/((sum(fs220.acct_010) + sum(pye.acct_010))/2)
        end * (12/(date_part('month', foicu.cycle_date)))) as cred_loss_provision,-- as cred_loss_provision,
 
(case when (sum(fs220a.Acct_131) + sum(fs220n.Acct_IS0020))/nullif((sum(fs220.acct_010) + sum(pye.acct_010))/2,0) IS NULL
        then 0
        else (sum(fs220a.Acct_131) + sum(fs220n.Acct_IS0020))/((sum(fs220.acct_010) + sum(pye.acct_010))/2)
        end * (12/(date_part('month', foicu.cycle_date)))) as net_oper_inc_to_assets, --net_oper_inc_to_assets
 
(case when sum(fs220a.Acct_661a)/nullif((sum(fs220.acct_010) + sum(pye.acct_010))/2,0) IS NULL
        then 0
        else sum(fs220a.Acct_661a)/((sum(fs220.acct_010) + sum(pye.acct_010))/2)
        end * (12/(date_part('month', foicu.cycle_date)))) as return_on_assets,-- as return_on_assets,
 
(case when sum(fs220a.Acct_661a)/nullif((sum(fs220.acct_010) + sum(pye.acct_010))/2,0) IS NULL
        then 0
        else sum(fs220a.Acct_661a)/((sum(fs220.acct_010) + sum(pye.acct_010))/2)
        end * (12/(date_part('month', foicu.cycle_date)))) as return_on_assets_pretax, -- as return_on_assets_pretax, SAME as ROA for CU????????

(case when sum(fs220a.Acct_661a)/nullif(sum(fs220a.Acct_997),0) IS NULL
       then 0
    else sum(fs220a.Acct_661a)/sum(fs220a.Acct_997)
    end * (12/(date_part('month', foicu.cycle_date)))) as return_on_equity,-- as return_on_equity,

(case when (sum(fs220a.Acct_661a) - sum(fs220.Acct_380))/nullif((sum(fs220a.Acct_997) + sum(pye.Acct_997))/2,0) IS NULL
        then 0
        else (sum(fs220a.Acct_661a) - sum(fs220.Acct_380))/((sum(fs220a.Acct_997) + sum(pye.Acct_997))/2)
        end * (12/(date_part('month', foicu.cycle_date)))) as retain_earn_to_ave_equity, -- as (change in) retain_earn_to_ave_equity,

(case when (sum(fs220.acct_550) - sum(fs220.acct_551)) / nullif((sum(fs220.acct_025b) + sum(pye.acct_025b))/2,0) IS NULL
      then 0
      else (sum(fs220.acct_550) - sum(fs220.acct_551)) / ((sum(fs220.acct_025b) + sum(pye.acct_025b))/2)
      end * (12/(date_part('month', foicu.cycle_date)))) as net_chrg_offs_to_ln_lease,-- as net_chrg_offs_to_ln_lease,

(case when
          ((case when (sum(fs220.Acct_300) + sum(fs220n.Acct_IS0011))/nullif((sum(fs220.acct_010) + sum(pye.acct_010))/2,0) IS NULL
                 then 0
                 else (sum(fs220.Acct_300) + sum(fs220n.Acct_IS0011))/((sum(fs220.acct_010) + sum(pye.acct_010))/2)
                 end * (12/(date_part('month', foicu.cycle_date)))) /
            nullif((case when (sum(fs220.acct_550) - sum(fs220.acct_551)) / nullif((sum(fs220.acct_025b) + sum(pye.acct_025b))/2,0) IS NULL
                         then 0
                         else (sum(fs220.acct_550) - sum(fs220.acct_551)) / ((sum(fs220.acct_025b) + sum(pye.acct_025b))/2)
                         end * (12/(date_part('month', foicu.cycle_date)))),0) IS NULL)
      then 0
      else
          ((case when (sum(fs220.Acct_300) + sum(fs220n.Acct_IS0011))/nullif((sum(fs220.acct_010) + sum(pye.acct_010))/2,0) IS NULL
                 then 0
                 else (sum(fs220.Acct_300) + sum(fs220n.Acct_IS0011))/((sum(fs220.acct_010) + sum(pye.acct_010))/2)
                 end * (12/(date_part('month', foicu.cycle_date)))) /
           (case when (sum(fs220.acct_550) - sum(fs220.acct_551)) / nullif((sum(fs220.acct_025b) + sum(pye.acct_025b))/2,0) IS NULL
                 then 0
                 else (sum(fs220.acct_550) - sum(fs220.acct_551)) / ((sum(fs220.acct_025b) + sum(pye.acct_025b))/2)
                 end * (12/(date_part('month', foicu.cycle_date)))))
     end) as ln_lease_loss_prov_to_net_chrg_offs,--ln_lease_loss_prov_to_net_chrg_offs

(case when sum(fs220a.Acct_661a)/nullif((sum(fs220.acct_550) - sum(fs220.acct_551)),0) IS NULL
      then 0
      else (sum(fs220.acct_550) - sum(fs220.acct_551))
      end) as earn_cover_net_loan_chrg_offs, --earn_cover_net_loan_chrg_offs

(case when (sum(fs220.Acct_671))/nullif((sum(fs220a.Acct_115) - sum(fs220a.Acct_350)+ sum(fs220a.Acct_117) - sum(fs220.Acct_300)),0) IS NULL
       then 0
       else (sum(fs220.Acct_671))/(sum(fs220a.Acct_115) - sum(fs220a.Acct_350)+ sum(fs220a.Acct_117) - sum(fs220.Acct_300))
       end) as efficiency_ratio, --as efficiency_ratio

(case when (sum(fs220.Acct_010))/nullif((sum(fs220a.Acct_564A) + (sum(fs220a.Acct_564B)/2)),0) IS NULL
       then 0
       else (sum(fs220.Acct_010))/(sum(fs220a.Acct_564A) + (sum(fs220a.Acct_564B)/2))
       end) as assets_per_employ, -- as assets_per_employ, 564A + (564B/2)
 
(case when (sum(fs220.Acct_380))/nullif((sum(fs220a.Acct_661a)),0) IS NULL
       then 0
       else (sum(fs220.Acct_380))/(sum(fs220a.Acct_661a))
       end) as cash_div_to_net_inc_ytd --cash_div_to_net_inc_ytd

from ncua_foicu foicu
     full join
     ncua_fs220 fs220
on foicu.cu_number = fs220.cu_number
and foicu.cycle_date = fs220.cycle_date
full join
ncua_fs220a fs220a
on foicu.cu_number = fs220a.cu_number
and foicu.cycle_date = fs220a.cycle_date
full join
ncua_fs220c fs220c
on foicu.cu_number = fs220c.cu_number
and foicu.cycle_date = fs220c.cycle_date
full join
ncua_fs220d fs220d
on foicu.cu_number = fs220d.cu_number
and foicu.cycle_date = fs220d.cycle_date
full join
ncua_fs220h fs220h
on foicu.cu_number = fs220h.cu_number
and foicu.cycle_date = fs220h.cycle_date
full join
ncua_fs220n fs220n
on foicu.cu_number = fs220n.cu_number
and foicu.cycle_date = fs220n.cycle_date
full join
ncua_fs220b fs220b
on foicu.cu_number = fs220b.cu_number
and foicu.cycle_date = fs220b.cycle_date
     full join
ncua_fs220l fs220l
on foicu.cu_number = fs220l.cu_number
and foicu.cycle_date = fs220l.cycle_date
full join
ncua_fs220g fs220g
on foicu.cu_number = fs220g.cu_number
and foicu.cycle_date = fs220g.cycle_date
full join
ncua_fs220j fs220j
on foicu.cu_number = fs220j.cu_number
and foicu.cycle_date = fs220j.cycle_date
full join
ncua_fs220q fs220q
on foicu.cu_number = fs220q.cu_number
and foicu.cycle_date = fs220q.cycle_date
full join
pye pye
on foicu.cu_number = pye.cu_number
and cast(date_part('year', foicu.cycle_date) - 1 || '-12-31' as date) = pye.cycle_date

where --foicu.cu_number in ('60105','12067','64880','61879','60991','4271','62072','62829','62848','61759')
      --and
 foicu.cycle_date = '2022-03-31'
group by foicu.cycle_date, foicu.cu_number, foicu.cu_name, foicu.city, foicu.state;