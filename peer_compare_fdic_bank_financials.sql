WITH PYE as (  
select
assets.repdte,
assets.cert,
assets.dep,
assets.idobrmtg,
sec.scrdebt

from fdic_assets_liabilities assets
full join fdic_securities sec
on assets.cert = sec.cert
and assets.repdte = sec.repdte

where assets.repdte in ((select cast((date_part('year', repdte)) - 1 || '-12-31' as date) as pye_date
from fdic_assets_liabilities))
)

select
assets.repdte as report_date,
assets.cert||'_'||'B' as institution_id,
assets.cert as client_number,
assets.name as client_name,
assets.city as city,
assets.stalp as state,
'B' as client_type,

---=====Balance Sheet=====--
assets.asset * 1000 as total_assets, -- Total Assets
assets.liab * 1000 as total_liabilities, -- Total Liabilities
assets.eq * 1000 as total_capital, -- Total Equity
assets.lnlsnet * 1000 as total_loans, -- Total Loans
assets.lnatres * 1000 as loan_loss_reserve, -- Loan Loss Reserve
assets.sc * 1000 as total_securities, -- Total Securities
assets.frepo * 1000 as fed_funds, -- Fed Funds
sec.scaf * 1000 as available_for_sale, -- Premium/Discount/Gain/Loss - AFS
(assets.asset - assets.ernast) * 1000 as non_earning_assets, -- Non Earning Assets
assets.dep * 1000 as total_deposits, -- Total Deposits
assets.idobrmtg * 1000 as total_borrowings, -- Total Borrowings
assets.subnd * 1000 as subordinated_debt, -- Subordinated Debt
assets.idoliab * 1000 as total_other_liabilities, -- Total Other Liabilities
--assets.eq as net_worth, -- Net Worth

---=====Income Statement=====---
inc.intinc * 1000 as total_interest_income, --Total Interest Income
inc.nonii * 1000 as non_interest_income,--Non Interest Income
(inc.intinc + inc.nonii) * 1000 as total_income, --Total Income
inc.eintexp * 1000 as total_interest_expense,--Total Interest Expense
inc.nonix * 1000 as non_interest_expense,--Non Interest Expense
inc.elnatr * 1000 as provision_loan_loss,--Provision for Loan Loss
inc.netinc * 1000 as net_income,--Net Income

---=====Ratios=====---
(case when (sum(intinc.ilndom * 1000) + sum(intinc.ils * 1000) + sum(intinc.iothii * 1000)) /
            nullif(sum(pcr.lnlsgr5 * 1000),0) IS NULL
       then 0
       else (sum(intinc.ilndom * 1000) + sum(intinc.ils * 1000) + sum(intinc.iothii * 1000)) / sum(pcr.lnlsgr5 * 1000)
       end * (12/(date_part('month', assets.repdte)))) as loan_yield, -- Loan Yield
pcr.lnlsdepr / 100 as loans_to_deposits, -- Loans to Deposits
pcr.lnlsntv / 100 as loans_to_assets, -- Loans to Assets

(case when (sum(intinc.isc * 1000) + sum(intinc.ichbal * 1000) + coalesce(sum(intinc.itrade * 1000),0)) /
            nullif(((sum(sec.scrdebt * 1000) + sum(pye.scrdebt * 1000))/2),0) IS NULL
       then 0
       else (sum(intinc.isc * 1000) + sum(intinc.ichbal * 1000) + coalesce(sum(intinc.itrade * 1000),0)) /
            ((sum(sec.scrdebt * 1000) + sum(pye.scrdebt * 1000))/2)
       end * (12/(date_part('month', assets.repdte)))) as investment_yield,-- Investment Yield
 
-- NMD to Deposits (ignore)
-- NMD Yield (ignore)
-- Term Deposit Yield (ignore)

(case when (sum(inc.eintexp * 1000) - sum(intexp.ettlotmg * 1000)) /
            nullif(((sum(assets.dep * 1000) + sum(pye.dep * 1000))/2),0) IS NULL
       then 0
       else (sum(inc.eintexp * 1000) - sum(intexp.ettlotmg * 1000)) /
            ((sum(assets.dep * 1000) + sum(pye.dep * 1000))/2)
       end * (12/(date_part('month', assets.repdte)))) as total_deposits_yield,  --Total Deposit Yield

(case when sum(intexp.ettlotmg * 1000) /
            nullif(((sum(assets.idobrmtg * 1000) + sum(pye.idobrmtg * 1000))/2),0) IS NULL
       then 0
       else sum(intexp.ettlotmg * 1000) /
            ((sum(assets.idobrmtg * 1000) + sum(pye.idobrmtg * 1000))/2)
       end * (12/(date_part('month', assets.repdte)))) as borrowings_yield, -- Borrowings Yield
 
pcr.intexpy / 100 as cost_of_funds, -- Cost of Funds
pcr.eqv / 100 as capital_to_assets, -- Capital to Assets
(pcr.intincy - pcr.intexpy) / 100 as net_interest_spread, -- Net Interest Spread
pcr.nimy / 100 as net_interest_margin,-- Net Interest Margin
pcr.roa / 100 as return_on_assets, -- Return on Assets
pcr.roe / 100 as return_on_equity  --Return on Equity

from fdic_assets_liabilities assets
full join fdic_income_expense inc
on assets.cert = inc.cert
and assets.repdte = inc.repdte
full join fdic_total_interest_income intinc
on assets.cert = intinc.cert
and assets.repdte = intinc.repdte
full join fdic_total_interest_expense intexp
on assets.cert = intexp.cert
and assets.repdte = intexp.repdte  
full join fdic_securities sec
on assets.cert = sec.cert
and assets.repdte = sec.repdte
full join fdic_total_deposits dep
on assets.cert = dep.cert
and assets.repdte = dep.repdte
full join fdic_performance_conditions_ratios pcr
on assets.cert = pcr.cert
and assets.repdte = pcr.repdte
full join fdic_total_unused_commitments unused
on assets.cert = unused.cert
and assets.repdte = unused.repdte
full join pye
on assets.cert = pye.cert
and cast(date_part('year', assets.repdte) - 1 || '-12-31' as date) = pye.repdte

where
assets.repdte = '2021-09-30'
and assets.cert in ('845','847','2452','15664','16620','19674','22273','34953','30219','14926')
group by
assets.repdte,
assets.cert,
assets.name,
assets.city,
assets.stalp,
assets.asset,
assets.eq,
assets.chbal,
assets.lnlsnet,
assets.lnatres,
assets.dep,
assets.sc,
assets.liab,
assets.idoliab,
assets.eqtot,
assets.idobrmtg,
assets.subnd,
assets.frepo,
assets.ernast,
inc.intinc,
inc.netinc,
inc.nonii,
inc.nonix,
inc.elnatr,
inc.eintexp,
sec.scaf,
pcr.lnlsntv,
pcr.roe,
pcr.roa,
pcr.lnlsdepr,
pcr.eqv,
pcr.nimy,
pcr.intexpy,
pcr.intincy;