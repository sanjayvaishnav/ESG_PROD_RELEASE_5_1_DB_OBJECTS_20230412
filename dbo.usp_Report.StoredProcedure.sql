USE [ESG]
GO
/****** Object:  StoredProcedure [dbo].[usp_Report]    Script Date: 4/18/2023 12:13:15 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[usp_Report]
GO
/****** Object:  StoredProcedure [dbo].[usp_Report]    Script Date: 4/18/2023 12:13:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[usp_Report]
as
begin

drop table if exists #temp_cov_adj_wt;

with AUM
  AS (
  SELECT 
	sum(MV_EUR) AUM,
	Legalentity,
	service,
	date
	FROM [ESG].[ESG_Holdings_his]
	where LegalEntity       = 'SWE'
	and Service           = 'Discretionary Portfolio'
	and date              = '2022-06-30'
	-- and InvestmentManager = 'John Skehan' --SWEDiscretionary Portfolio
	group by Legalentity,
	service,
	date
	)

Select a.date,
       a.LegalEntity,
       a.Service,
       a.ISIN,
       a.MV_GBP AUM,
       a.FUND_SHARE_CLASS_ID,
       a.ISSUERID,
       b.CARBON_EMISSIONS_SCOPE_1,
	   b.CARBON_EMISSIONS_SCOPE_2,
	   b.CARBON_EMISSIONS_SCOPE_3_TOTAL,
	   b.CARBON_EMISSIONS_SCOPE123,
       b.EVIC_EUR,
       a.InvestmentManager,
       c.FUND_SFDR_CARBON_FOOTPRINT_SCOPE_1,
       c.FUND_SFDR_CARBON_FOOTPRINT_SCOPE_1_COV,a.MV_EUR,
	   c.FUND_SFDR_CARBON_FOOTPRINT_SCOPE_2,
	   c.FUND_SFDR_CARBON_FOOTPRINT_SCOPE_3,
	   c.FUND_SFDR_CARBON_FOOTPRINT,

       (CASE
             when a.fund_share_class_id IS NOT NULL THEN 'COLLECTIVE'
             when a.fund_share_class_id IS NULL
              AND a.issuerid IS NOT NULL then 'DIRECT'
             when a.isin is null
              and a.SEDOL is null then 'CASH'
             ELSE 'ISIN NOT MAPPED' END) AS Security_type,
       (a.MV_EUR / NULLIF(d.aum, 0)) Portfolio_wt,

       case
            when a.fund_share_class_id IS NOT NULL THEN FUND_SFDR_CARBON_FOOTPRINT_SCOPE_1
            when a.fund_share_class_id IS NULL
            AND a.issuerid IS NOT NULL then CARBON_EMISSIONS_SCOPE_1
            else Null end as [DIR_SFDR_CLTV EUS],

       (case
            when a.fund_share_class_id IS NOT NULL
              and c.FUND_SFDR_CARBON_FOOTPRINT_SCOPE_1_COV is not null then
                 cast((a.MV_EUR / NULLIF(d.aum, 0)) * c.FUND_SFDR_CARBON_FOOTPRINT_SCOPE_1_COV as float) / 100.0
             when a.fund_share_class_id IS NULL
              AND a.issuerid IS NOT NULL
              and isnull(b.EVIC_EUR, 0) > 0
              and isnull(case
                              when a.fund_share_class_id IS NOT NULL THEN FUND_SFDR_CARBON_FOOTPRINT_SCOPE_1
                              when a.fund_share_class_id IS NULL
                               AND a.issuerid IS NOT NULL then CARBON_EMISSIONS_SCOPE_1
                              else Null end,
                         0) > 0 then a.MV_EUR / NULLIF(d.aum, 0)
             else 0 END) cov_adjusted_wt

		

	into   #temp_cov_adj_wt
	from [ESG].[ESG_Holdings_his] a
	left join [ESG].[DIR_SFDR] b on b.ISSUERID = a.ISSUERID and a.MSCI_AS_OF_DATE = b.AS_OF_DATE
	left join [ESG].[CLTV_EUSUSTAINABLEFINANCE] c on a.MSCI_AS_OF_DATE = c.AS_OF_DATE and a.FUND_SHARE_CLASS_ID = c.FUND_SHARE_CLASS_ID
	left join AUM d on a.LegalEntity = d.LegalEntity and a.Service = d.Service and a.Date = d.Date
	where a.LegalEntity = 'SWE'
	and a.Service = 'Discretionary Portfolio' 
	and a.Date = '2022-06-30'
  -- and a.InvestmentManager = 'John Skehan'

 -- select * from #temp_cov_adj_wt


;with Results1 as 
(
select *,
       cov_adjusted_wt / nullif(sum(cov_adjusted_wt) over (partition by LegalEntity, Service, Date),0) as Normalized,
       (cov_adjusted_wt / nullif(sum(cov_adjusted_wt) over (partition by LegalEntity, Service, Date),0))* sum(MV_EUR) 
	   over (partition by LegalEntity, Service, Date) as Normalized_MVEUR
  from #temp_cov_adj_wt
)

  select * ,
  case 
	when Security_type='DIRECT' and (EVIC_EUR > 0 and EVIC_EUR IS NOT NULL) and  isnull(CARBON_EMISSIONS_SCOPE_1,0) > 0 
	then (CARBON_EMISSIONS_SCOPE_1 * Normalized_MVEUR)/(nullif(EVIC_EUR * 1000000,0))

	when  Security_type='COLLECTIVE'  
	then  (FUND_SFDR_CARBON_FOOTPRINT_SCOPE_1*Normalized_MVEUR)/1000000 

	else 0 end as Scope1,

  case 
	when Security_type='DIRECT' and (EVIC_EUR > 0 and EVIC_EUR IS NOT NULL) and  isnull(CARBON_EMISSIONS_SCOPE_2,0) > 0 
	then (CARBON_EMISSIONS_SCOPE_2 * Normalized_MVEUR)/(nullif(EVIC_EUR * 1000000,0))

	when  Security_type='COLLECTIVE'  
	then  (FUND_SFDR_CARBON_FOOTPRINT_SCOPE_2 * Normalized_MVEUR)/1000000

	else 0 end as Scope2,

	case 
	when Security_type='DIRECT' and (EVIC_EUR > 0 and EVIC_EUR IS NOT NULL) and  isnull(CARBON_EMISSIONS_SCOPE_3_total,0) > 0 
	then (CARBON_EMISSIONS_SCOPE_3_total * Normalized_MVEUR)/(nullif(EVIC_EUR * 1000000,0))

	when  Security_type='COLLECTIVE'  
	then  (FUND_SFDR_CARBON_FOOTPRINT_SCOPE_3 * Normalized_MVEUR)/1000000

	else 0 end as Scope3
  
  
into ESG.Factor_Scope1_SWE_Discretionary_Portfolio
  FROM Results1


  --select * from ESG.Factor_Scope1_SWE_Discretionary_Portfolio


end
GO
