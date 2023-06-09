USE [ESG]
GO
/****** Object:  StoredProcedure [dbo].[usp_ESGReportDummy]    Script Date: 4/18/2023 12:13:15 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[usp_ESGReportDummy]
GO
/****** Object:  StoredProcedure [dbo].[usp_ESGReportDummy]    Script Date: 4/18/2023 12:13:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--exec [dbo].[usp_ESGReportDummy]

CREATE procedure [dbo].[usp_ESGReportDummy]
/*
Logic : 
The stored procedure has been created to populate TCFD_LE_Service_SUM

The input data flows from the below tables
[ESG].[ESG_Holdings_his]
[ESG].[DIR_SFDR]
[ESG].[CLTV_EUSUSTAINABLEFINANCE]

-------------------------------------------------------------------------------
Created Date	Version		Created By		Comments
26-Aug-2022		0.1			Wipro			Initial version 
-------------------------------------------------------------------------------

*/
As

Begin

	drop table if exists #temp_cov_adj_wt;
	drop table if exists ESG.Factor_Scope1_SWE_Discretionary_Portfolio;

	---- Logic to Calculate MV_USD_total, AUM, MV_GBP from [ESG_Holdings_HIS]
	with AUM
		AS (SELECT distinct [Service]
			  ,[Date]
			  ,LegalEntity
			  ,[MSCI_AS_OF_DATE]
			  ,sum(MV_USD) over (partition by [Service],[Date],LegalEntity) as MV_USD_total,
			  sum(MV_EUR) over (partition by [Service],[Date],LegalEntity) as AUM,
			  sum(MV_GBP) over (partition by [Service],[Date],LegalEntity) as MV_GBP
		  FROM [ESG].[ESG].[ESG_Holdings_HIS]
		  where 
		  --LegalEntity = 'SWE' and 
		  --Service     = 'Discretionary Portfolio' and
		  date in ('2022-05-31','2022-06-30','2022-07-31'))

		  ---- Logic to Calculate Scopes, Footprints and other factors.
			Select a.date,
				   a.LegalEntity,
				   a.Service,
				   a.ISIN,
				   a.ClientReference,
				   a.Portfolio,
				   a.MV_GBP AUM,
				   a.FUND_SHARE_CLASS_ID,
				   a.ISSUERID,
				   b.CARBON_EMISSIONS_SCOPE_1,
				   b.CARBON_EMISSIONS_SCOPE_2,
				   b.CARBON_EMISSIONS_SCOPE_3_TOTAL,
				   b.CARBON_EMISSIONS_SCOPE123,
				   b.CARBON_EMISSIONS_EVIC_EUR_SCOPE123_INTEN,
				   b.EVIC_EUR,
				   a.InvestmentManager,
				   c.FUND_SFDR_CARBON_FOOTPRINT_SCOPE_1,
				   c.FUND_SFDR_CARBON_FOOTPRINT_SCOPE_1_COV,
				   a.MV_EUR,
				   c.FUND_SFDR_CARBON_FOOTPRINT_SCOPE_2,
				   c.FUND_SFDR_CARBON_FOOTPRINT_SCOPE_3,
				   c.FUND_SFDR_CARBON_FOOTPRINT,
				   c.FUND_SFDR_GHG_INTENSITY,
				   d.MSCI_AS_OF_DATE,
				   d.MV_GBP,

				   (CASE
						 when a.fund_share_class_id IS NOT NULL THEN 'COLLECTIVE'
						 when a.fund_share_class_id IS NULL
						  AND a.issuerid IS NOT NULL then 'DIRECT'
						 when a.isin is null
						  and a.SEDOL is null then 'CASH'
						 ELSE 'ISIN NOT MAPPED' END) AS Security_type,
				   (a.MV_EUR / NULLIF(d.aum, 0)) Portfolio_wt,

				   case
						when isnull(c.FUND_SFDR_GHG_INTENSITY, 0) <> 0
						 and isnull(b.CARBON_EMISSIONS_EVIC_EUR_SCOPE123_INTEN, 0) <> 0 then (a.MV_EUR / NULLIF(d.aum, 0))
						else 0 end as Normalized_Portfolio_wt_intensity,

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
						 else 0 END) cov_adjusted_wt,

				   (case
						 when a.fund_share_class_id IS NOT NULL
						  and c.FUND_SFDR_CARBON_FOOTPRINT_SCOPE_2_COV is not null then
							 cast((a.MV_EUR / NULLIF(d.aum, 0)) * c.FUND_SFDR_CARBON_FOOTPRINT_SCOPE_2_COV as float) / 100.0
						 when a.fund_share_class_id IS NULL
						  AND a.issuerid IS NOT NULL
						  and isnull(b.EVIC_EUR, 0) > 0
						  and isnull(case
										  when a.fund_share_class_id IS NOT NULL THEN FUND_SFDR_CARBON_FOOTPRINT_SCOPE_2_COV
										  when a.fund_share_class_id IS NULL
										   AND a.issuerid IS NOT NULL then CARBON_EMISSIONS_SCOPE_2
										  else Null end,
									 0) > 0 then a.MV_EUR / NULLIF(d.aum, 0)
						 else 0 END) cov_adjusted_wt2,

				   (case
						 when a.fund_share_class_id IS NOT NULL
						  and c.FUND_SFDR_CARBON_FOOTPRINT_SCOPE_3_COV is not null then
							 cast((a.MV_EUR / NULLIF(d.aum, 0)) * c.FUND_SFDR_CARBON_FOOTPRINT_SCOPE_3_COV as float) / 100.0
						 when a.fund_share_class_id IS NULL
						  AND a.issuerid IS NOT NULL
						  and isnull(b.EVIC_EUR, 0) > 0
						  and isnull(case
										  when a.fund_share_class_id IS NOT NULL THEN FUND_SFDR_CARBON_FOOTPRINT_SCOPE_3_COV
										  when a.fund_share_class_id IS NULL
										   AND a.issuerid IS NOT NULL then CARBON_EMISSIONS_SCOPE_3_total
										  else Null end,
									 0) > 0 then a.MV_EUR / NULLIF(d.aum, 0)
						 else 0 END) cov_adjusted_wt3,

				   (case
						 when a.fund_share_class_id IS NOT NULL
						  and c.FUND_SFDR_CARBON_FOOTPRINT is not null then
							 cast((a.MV_EUR / NULLIF(d.aum, 0)) * c.FUND_SFDR_CARBON_FOOTPRINT as float) / 100.0
						 when a.fund_share_class_id IS NULL
						  AND a.issuerid IS NOT NULL
						  and isnull(b.EVIC_EUR, 0) > 0
						  and isnull(case
										  when a.fund_share_class_id IS NOT NULL THEN FUND_SFDR_CARBON_FOOTPRINT
										  when a.fund_share_class_id IS NULL
										   AND a.issuerid IS NOT NULL then CARBON_EMISSIONS_SCOPE123
										  else Null end,
									 0) > 0 then a.MV_EUR / NULLIF(d.aum, 0)
						 else 0 END) cov_adjusted_wt_total,

								 (case
						 when a.fund_share_class_id IS NOT NULL
						  and c.FUND_SFDR_GHG_INTENSITY_COV is not null then
							 cast((a.MV_EUR / NULLIF(d.aum, 0)) * c.FUND_SFDR_GHG_INTENSITY_COV as float) / 100.0
						 when a.fund_share_class_id IS NULL
						  AND a.issuerid IS NOT NULL
								   and CARBON_EMISSIONS_EVIC_EUR_SCOPE123_INTEN IS NOT NULL and 
															  CARBON_EMISSIONS_EVIC_EUR_SCOPE123_INTEN
															  <>0
															  then (a.MV_EUR / NULLIF(d.aum, 0))
						 else 0 END
						  ) cov_adjusted_GHG_INTENSITY,

				   d.MV_USD_total

				into   #temp_cov_adj_wt
				from [ESG].[ESG_Holdings_his] a
				left join [ESG].[DIR_SFDR] b on b.ISSUERID = a.ISSUERID and a.MSCI_AS_OF_DATE = b.AS_OF_DATE
				left join [ESG].[CLTV_EUSUSTAINABLEFINANCE] c on a.MSCI_AS_OF_DATE = c.AS_OF_DATE and a.FUND_SHARE_CLASS_ID = c.FUND_SHARE_CLASS_ID
				left join AUM d on a.LegalEntity = d.LegalEntity and a.Service = d.Service and a.Date = d.Date
				where
				--where a.LegalEntity = 'SWE'
				--  and a.Service     = 'Discretionary Portfolio'
				-- and a.Date        = '2022-06-30'
				a.Date in ('2022-05-31','2022-06-30','2022-07-31');

			with Results1
				as (

				select *,
				cov_adjusted_wt / nullif(sum(cov_adjusted_wt) over (partition by LegalEntity, Service, Date), 0) as Normalized,
				(cov_adjusted_wt / nullif(sum(cov_adjusted_wt) over (partition by LegalEntity, Service, Date), 0))
				* sum(MV_EUR) over (partition by LegalEntity, Service, Date) as Normalized_MVEUR,

				cov_adjusted_wt2 / nullif(sum(cov_adjusted_wt2) over (partition by LegalEntity, Service, Date), 0) as Normalized2,
				(cov_adjusted_wt2 / nullif(sum(cov_adjusted_wt2) over (partition by LegalEntity, Service, Date), 0))
				* sum(MV_EUR) over (partition by LegalEntity, Service, Date) as Normalized_MVEUR2,

				cov_adjusted_wt3 / nullif(sum(cov_adjusted_wt3) over (partition by LegalEntity, Service, Date), 0) as Normalized3,
				(cov_adjusted_wt3 / nullif(sum(cov_adjusted_wt3) over (partition by LegalEntity, Service, Date), 0))
				* sum(MV_EUR) over (partition by LegalEntity, Service, Date) as Normalized_MVEUR3,

				cov_adjusted_wt_total/ nullif(sum(cov_adjusted_wt_total) over (partition by LegalEntity, Service, Date), 0) as Normalized_total,
				(cov_adjusted_wt_total / nullif(sum(cov_adjusted_wt_total) over (partition by LegalEntity, Service, Date), 0))
				* sum(MV_EUR) over (partition by LegalEntity, Service, Date) as Normalized_MVEUR_total,

                (cov_adjusted_ghg_intensity / NULLIF(Sum(cov_adjusted_ghg_intensity) OVER (partition BY legalentity, service, date), 0))  AS normalized_ghg_intensity
				from #temp_cov_adj_wt)



				---- The calculated data gets pushed into Factor_Scope1_SWE_Discretionary_Portfolio table.
				select *,(Scope1 + Scope2 + Scope3) as Total_GHG_emissions     
				into ESG.Factor_Scope1_SWE_Discretionary_Portfolio
				from (   
				select *,
					(case
					when Security_type = 'DIRECT' and isnull(CARBON_EMISSIONS_EVIC_EUR_SCOPE123_INTEN,0) <> 0 then CARBON_EMISSIONS_EVIC_EUR_SCOPE123_INTEN
					when Security_type = 'COLLECTIVE' and isnull(FUND_SFDR_GHG_INTENSITY,0) <> 0 then FUND_SFDR_GHG_INTENSITY
					else 0 end) * (normalized_ghg_intensity)  as GHG_Intensity_of_investee_companies_1
,
					case
                       when Security_type = 'DIRECT'
                        and (   EVIC_EUR > 0
                          and   EVIC_EUR IS NOT NULL)
                        and isnull(CARBON_EMISSIONS_SCOPE_1, 0) > 0 then
                  (CARBON_EMISSIONS_SCOPE_1 * Normalized_MVEUR) / (nullif(EVIC_EUR * 1000000, 0))
                       when Security_type = 'COLLECTIVE' then
                  (FUND_SFDR_CARBON_FOOTPRINT_SCOPE_1 * Normalized_MVEUR) / 1000000
                       else 0 end as Scope1,

                  case
                       when Security_type = 'DIRECT'
                        and (   EVIC_EUR > 0
                          and   EVIC_EUR IS NOT NULL)
                        and isnull(CARBON_EMISSIONS_SCOPE_2, 0) > 0 then
                  (CARBON_EMISSIONS_SCOPE_2 * Normalized_MVEUR2) / (nullif(EVIC_EUR * 1000000, 0))
                       when Security_type = 'COLLECTIVE' then
                  (FUND_SFDR_CARBON_FOOTPRINT_SCOPE_2 * Normalized_MVEUR2) / 1000000
                       else 0 end as Scope2,

                  case
                       when Security_type = 'DIRECT'
                        and (   EVIC_EUR > 0
                          and   EVIC_EUR IS NOT NULL)
                        and isnull(CARBON_EMISSIONS_SCOPE_3_total, 0) > 0 then
                  (CARBON_EMISSIONS_SCOPE_3_total * Normalized_MVEUR3) / (nullif(EVIC_EUR * 1000000, 0))
                       when Security_type = 'COLLECTIVE' then
                  (FUND_SFDR_CARBON_FOOTPRINT_SCOPE_3 * Normalized_MVEUR3) / 1000000
                       else 0 end as Scope3
             FROM Results1) as CarbonfootPrint_derived


			 ---- From Factor_Scope1_SWE_Discretionary_Portfolio the data moves to TCFD_LE_Service_SUM 
			INSERT INTO [ESG].[TCFD_LE_Service_SUM] (
					[DATE] ,
					[MSCI_AS_OF_DATE] ,
					[Legal_Entity] ,
					[DistinctAsset] ,
					[TotalClients] ,
					[TotalPortfolio],
					[MV_USD],
					[MV_EUR] ,
					[MV_GBP],
					[Service] ,
					[Service_Category] ,
					[GHG_SCOPE_1] ,
					[GHG_SCOPE_1_COV] ,
					[GHG_SCOPE_2] ,
					[GHG_SCOPE_2_COV] ,
					[GHG_SCOPE_3] ,
					[GHG_SCOPE_3_COV] ,
					[GHG_SCOPE_123] ,
					[GHG_SCOPE_123_COV] ,
					[GHG_Carbon_Footprint_USD],
					[GHG_Carbon_Footprint_USD_COV] ,
					[GHG_Intensity_EUR] ,
					[GHG_Intensity_EUR_COV]
						)

					select 
					 date,
					 date,
					 LegalEntity, 
					 Count (distinct(ISIN)) as [DistinctAsset],
					 Count (distinct(ClientReference)) as [TotalClients],
					 Count (distinct(Portfolio)) as [TotalPortfolio],
					 sum(MV_USD_total) as MV_USD,
					 sum(AUM) as MV_EUR,
					 sum(MV_GBP) as MV_GBP,
					 Service,
					 null as [Service_Category],
					 sum(scope1) as [GHG_SCOPE_1],
					 sum(cov_adjusted_wt) as [GHG_SCOPE_1_COV],

					 sum(scope2) as [GHG_SCOPE_2],
					 sum(cov_adjusted_wt2) as [GHG_SCOPE_2_COV],

					 sum(scope3) as [GHG_SCOPE_3],
					 sum(cov_adjusted_wt3) as [GHG_SCOPE_3_COV],

					 sum(Total_GHG_emissions) as [GHG_SCOPE_123],
					 sum(cov_adjusted_wt3) as [GHG_SCOPE_123_COV],
					 0,0,
					 sum(GHG_Intensity_of_investee_companies_1) as [GHG_Intensity_EUR] ,
					 sum(cov_adjusted_GHG_INTENSITY) as [GHG_Intensity_EUR_COV]

					 from ESG.Factor_Scope1_SWE_Discretionary_Portfolio
					 group by date,legalentity,service

			--truncate table [ESG].[TCFD_LE_Service_SUM]
			--select * from [ESG].[TCFD_LE_Service_SUM]
end

GO
