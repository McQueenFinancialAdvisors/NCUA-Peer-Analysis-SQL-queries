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
fs220.acct_860c

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

---=====Balance Sheet=====--
sum(fs220.Acct_010) as total_assets, -- Total Assets
sum(fs220n.Acct_li0069) as total_liabilities, -- Total Liabilities
(sum(fs220.Acct_010) - sum(fs220n.Acct_li0069)) as net_worth, -- Total Equity

sum(fs220.Acct_025b) as total_loans, -- Total Loans
sum(fs220.Acct_719) as loan_loss_reserve, -- Loan Loss Reserve
sum(fs220q.acct_nv0158) as total_securities, -- Total Securities
sum(fs220b.Acct_770) as fed_funds, -- Fed Funds (ignore)
sum(fs220b.Acct_797e) as available_for_sale, -- Premium/Discount/Gain/Loss
(sum(fs220.Acct_010) - sum(fs220.Acct_025b) - sum(fs220q.acct_nv0158)) as non_earning_assets, -- Non Earning Assets
sum(fs220.Acct_018) as total_deposits, -- Total Deposits
sum(fs220.Acct_860c) as total_borrowings,-- Total Borrowings
sum(fs220b.Acct_867c) as subordinated_debt, -- Subordinated Debt
sum(fs220.Acct_825) as total_other_liabilities, -- Total Other Liabilities
--sum(fs220a.Acct_997) as net_worth, -- Net Worth (ignore)

---=====Income Statement=====--
sum(fs220a.Acct_115) as total_interest_income, -- Total Interest Income
sum(fs220a.Acct_117) as non_interest_income, -- Non Interest Income
(sum(fs220a.Acct_115) + sum(fs220a.Acct_117)) as total_income, -- Total Income
sum(fs220a.Acct_350) as total_interest_expense, -- Total Interest Expense
sum(fs220.Acct_671) as non_interest_expense, -- Non Interest Expense
sum(fs220.Acct_300) as provision_loan_loss, -- Provision for Loan Loss
sum(fs220a.Acct_661a) as net_income, -- Net Income

---=====Ratios=====--
(case when (sum(fs220a.acct_110) - sum(fs220a.acct_119))/
            nullif((((sum(fs220.acct_025b) + sum(pye.acct_025b)) + (sum(fs220c.acct_003) + sum(pye.acct_003)))/2),0) IS NULL
       then 0
       else (sum(fs220a.acct_110) - sum(fs220a.acct_119))/
            (((sum(fs220.acct_025b) + sum(pye.acct_025b)) + (sum(fs220c.acct_003) + sum(pye.acct_003)))/2)
       end  * (12/(date_part('month', foicu.cycle_date)))) as yield_on_loans, -- Loan Yield
(case when sum(fs220.acct_025b) / nullif(sum(fs220.acct_018),0) IS NULL
      then 0
      else sum(fs220.acct_025b) / sum(fs220.acct_018)
      end) as loans_to_deposits,-- Loans to Deposits
(case when sum(fs220.acct_025b) / nullif(sum(fs220.Acct_010),0) IS NULL
      then 0
      else sum(fs220.acct_025b) / sum(fs220.Acct_010)
      end) as loans_to_assets,-- Loans to Assets
(case when (sum(fs220a.Acct_120) + sum(fs220n.Acct_IS0004))/
           nullif(((sum(fs220q.acct_nv0158) + sum(fs220a.acct_730b) + sum(fs220a.acct_730c)
 + sum(pye.acct_799i) + sum(pye.acct_730b) + sum(pye.acct_730c))/2),0) IS NULL
      then 0
      else (sum(fs220a.Acct_120) + sum(fs220n.Acct_IS0004))/
            ((sum(fs220q.acct_nv0158) + sum(fs220a.acct_730b) + sum(fs220a.acct_730c)
 + sum(pye.acct_799i) + sum(pye.acct_730b) + sum(pye.acct_730c))/2)
      end  * (12/(date_part('month', foicu.cycle_date)))) as investment_yield, -- Investment Yield
-- NMD to Deposits (ignore)
-- NMD Yield (ignore)
-- Term Deposit Yield (ignore)
(case when (sum(fs220a.acct_350) - sum(fs220.acct_340))/ nullif(((sum(fs220.Acct_018) + sum(pye.Acct_018))/2),0) IS NULL
       then 0
       else (sum(fs220a.acct_350) - sum(fs220.acct_340))/ ((sum(fs220.Acct_018) + sum(pye.Acct_018))/2)
       end  * (12/(date_part('month', foicu.cycle_date)))) as total_deposits_yield,-- Total Deposit Yield
(case when sum(fs220.acct_340)/nullif(((sum(fs220.acct_860c) + sum(pye.acct_860c))/2),0) IS NULL
       then 0
       else sum(fs220.acct_340)/ ((sum(fs220.acct_860c) + sum(pye.acct_860c))/2)
       end  * (12/(date_part('month', foicu.cycle_date)))) as borrowings_yield,-- Borrowings Yield

(case when (sum(fs220.Acct_340) + sum(fs220.Acct_380) + sum(fs220a.Acct_381))/
            nullif(((sum(fs220.acct_010) + sum(pye.acct_010))/2),0) IS NULL
       then 0
       else (sum(fs220.Acct_340) + sum(fs220.Acct_380) + sum(fs220a.Acct_381))/
            ((sum(fs220.acct_010) + sum(pye.acct_010))/2)
       end  * (12/(date_part('month', foicu.cycle_date)))) as cost_of_funds, -- Cost of Funds

 
(case when sum(fs220a.Acct_997)/nullif(sum(fs220.Acct_010),0) IS NULL
      then 0
      else sum(fs220a.Acct_997) / sum(fs220.Acct_010)
      end) as capital_to_assets, -- Capital to Assets

--====Net Interest Spread=====
(((case when
          ((((case when (sum(fs220a.acct_110) - sum(fs220a.acct_119))/
            nullif((((sum(fs220.acct_025b) + sum(pye.acct_025b)) + (sum(fs220c.acct_003) + sum(pye.acct_003)))/2),0) IS NULL
       then 0
       else (sum(fs220a.acct_110) - sum(fs220a.acct_119))/
            (((sum(fs220.acct_025b) + sum(pye.acct_025b)) + (sum(fs220c.acct_003) + sum(pye.acct_003)))/2)
       end  * (12/(date_part('month', foicu.cycle_date))))) * sum(fs220.Acct_025b)) --- Total Loan yield * Total Loans
+
(((case when (sum(fs220a.Acct_120) + sum(fs220n.Acct_IS0004))/
           nullif(((sum(fs220q.acct_nv0158) + sum(fs220a.acct_730b) + sum(fs220a.acct_730c)
 + sum(pye.acct_799i) + sum(pye.acct_730b) + sum(pye.acct_730c))/2),0) IS NULL
        then 0
        else (sum(fs220a.Acct_120) + sum(fs220n.Acct_IS0004))/
            ((sum(fs220q.acct_nv0158) + sum(fs220a.acct_730b) + sum(fs220a.acct_730c)
 + sum(pye.acct_799i) + sum(pye.acct_730b) + sum(pye.acct_730c))/2)
        end  * (12/(date_part('month', foicu.cycle_date))))) * sum(fs220q.acct_nv0158)))/ -- Total Investment Yield * Total Investments
         nullif((((sum(fs220.acct_025b) + sum(pye.acct_025b)) + (sum(fs220q.acct_nv0158) + sum(pye.Acct_799i)))/2),0) IS NULL
  then 0
  else
             ((((case when (sum(fs220a.acct_110) - sum(fs220a.acct_119))/
             nullif((((sum(fs220.acct_025b) + sum(pye.acct_025b)) + (sum(fs220c.acct_003) + sum(pye.acct_003)))/2),0) IS NULL
        then 0
        else (sum(fs220a.acct_110) - sum(fs220a.acct_119))/
             (((sum(fs220.acct_025b) + sum(pye.acct_025b)) + (sum(fs220c.acct_003) + sum(pye.acct_003)))/2)
        end  * (12/(date_part('month', foicu.cycle_date))))) * sum(fs220.Acct_025b)) --- Total Loan yield * Total Loans
 +
 (((case when (sum(fs220a.Acct_120) + sum(fs220n.Acct_IS0004))/
            nullif(((sum(fs220q.acct_nv0158) + sum(fs220a.acct_730b) + sum(fs220a.acct_730c)
   + sum(pye.acct_799i) + sum(pye.acct_730b) + sum(pye.acct_730c))/2),0) IS NULL
         then 0
         else (sum(fs220a.Acct_120) + sum(fs220n.Acct_IS0004))/
             ((sum(fs220q.acct_nv0158) + sum(fs220a.acct_730b) + sum(fs220a.acct_730c)
   + sum(pye.acct_799i) + sum(pye.acct_730b) + sum(pye.acct_730c))/2)
         end  * (12/(date_part('month', foicu.cycle_date))))) * sum(fs220q.acct_nv0158)))/ -- Total Investment Yield * Total Investments
(((sum(fs220.acct_025b) + sum(pye.acct_025b)) + (sum(fs220q.acct_nv0158) + sum(pye.Acct_799i)))/2)
end)) -- Yield on Earning Assets
-
((case when (sum(fs220.Acct_340) + sum(fs220.Acct_380) + sum(fs220a.Acct_381))/
            nullif(((sum(fs220.acct_010) + sum(pye.acct_010))/2),0) IS NULL
       then 0
       else (sum(fs220.Acct_340) + sum(fs220.Acct_380) + sum(fs220a.Acct_381))/
            ((sum(fs220.acct_010) + sum(pye.acct_010))/2)
       end  * (12/(date_part('month', foicu.cycle_date)))))) --cost of funds
  as net_interest_spread,-- Net Interest Spread
 
(case when (sum(fs220a.Acct_115) - sum(fs220a.Acct_350))/nullif((sum(fs220.acct_010) + sum(pye.acct_010))/2,0) IS NULL
       then 0
       else (sum(fs220a.Acct_115) - sum(fs220a.Acct_350))/((sum(fs220.acct_010) + sum(pye.acct_010))/2)
       end * (12/(date_part('month', foicu.cycle_date)))) as net_interest_margin,-- Net Interest Margin
(case when sum(fs220a.Acct_661a)/nullif((sum(fs220.acct_010) + sum(pye.acct_010))/2,0) IS NULL
       then 0
       else sum(fs220a.Acct_661a)/((sum(fs220.acct_010) + sum(pye.acct_010))/2)
       end * (12/(date_part('month', foicu.cycle_date)))) as return_on_assets,-- Return on Assets
(case when sum(fs220a.Acct_661a)/nullif(sum(fs220a.Acct_997),0) IS NULL
     then 0
else sum(fs220a.Acct_661a)/sum(fs220a.Acct_997)
end * (12/(date_part('month', foicu.cycle_date)))) as return_on_equity -- Return on Equity

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