USE [ESG]
GO
/****** Object:  StoredProcedure [dbo].[usp_Load_TCFD_LE_Service_SUM_Temp_All_DLSC_Fundview]    Script Date: 4/18/2023 12:13:15 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[usp_Load_TCFD_LE_Service_SUM_Temp_All_DLSC_Fundview]
GO
/****** Object:  StoredProcedure [dbo].[usp_Load_TCFD_LE_Service_SUM_Temp_All_DLSC_Fundview]    Script Date: 4/18/2023 12:13:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE procedure [dbo].[usp_Load_TCFD_LE_Service_SUM_Temp_All_DLSC_Fundview]
(
@dates varchar(200)=Null
)
/*
Logic : 
The stored procedure has been created to populate [ESG].[TCFD_LE_Service_SUM_Temp_All]
The SSIS package TCFD_LE_Service_SUM.dtsx will populate [ESG].[TCFD_LE_Service_SUM] from [ESG].[TCFD_LE_Service_SUM_Temp_All] as per the logic mentioned in package
The input data flows from the below tables
[ESG].[ESG_Holdings_EOM]
[ESG].[DIR_SFDR]
[ESG].[CLTV_EUSUSTAINABLEFINANCE]

Execution step : EXECUTE  [dbo].[usp_Load_TCFD_LE_Service_SUM_Temp_All]

-------------------------------------------------------------------------------
Created Date	Version		Created By		Comments
26-Aug-2022		0.1			Wipro			Initial version 
-------------------------------------------------------------------------------

*/
As

Begin

	drop table if exists #temp_cov_adj_wt_all;
	drop table if exists [ESG].[Factors_All];
	--truncate table [ESG].[TCFD_LE_Service_SUM_Temp_All];

drop table if exists #dates ;
select  value as [Date]
 into #dates 
FROM STRING_SPLIT(@dates, ',');
	---- Logic to Calculate MV_USD_total, AUM, MV_GBP from [ESG_Holdings_EOM]
	with  Source_Table
      as (SELECT ID,
                 ClientReference,
                 ClientName,
                 NULL as ISIN_Share_Class,
                 Null as Share_Class_Name,
                 ISIN,
                 AssetName,
                 ISSUERID,
                 FUND_SHARE_CLASS_ID,
                 MSCI_AS_OF_DATE,
                 MV_GBP,
                 MV_EUR,
                 MV_USD,
                 Service,
                 LegalEntity,
                 AssetGroupClass,
                 ASSET_GROUP,
                 Date,
                 IMDRtagging,
                 FUND_ELIGIBILITY,
                 Portfolio,
                 InvestmentManager,
				 a.ServiceCategory as ServiceCategory
            FROM [ESG].[ESG_HOLDINGS_EOM] a
  INNER JOIN [ESG].[SERVICE_CATEGORY_REF] as b on a.Service = b.MandateCode
						  WHERE --a.LegalEntity != 'SWE' and b.ServiceCategory = ( 'Discretionary') 					--[ESG].[ESG_HOLDINGS_EOM]
          -- and 
		   FundViewTagging in ( 'FasCL - NON TAP', 'ECH IP' ) 
		   and date in ( select date from #dates )
          UNION ALL
          SELECT ID,
                 Portfolio_ID as ClientReference,
                 Portfolio_Name as ClientName,
                 ISIN_Share_Class,
                 Share_Class_Name,
                 ISIN_Underlying as ISIN,
                 Asset_Name as AssetName,
                 ISSUERID,
                 FUND_SHARE_CLASS_ID,
                 MSCI_AS_OF_DATE,
                 MV_GBP,
                 MV_EUR,
                 MV_USD,
                 Service,
                 LegalEntity,
                 AssetGroupClass,
                 ASSET_GROUP,
                 IMDR_PROCESS_NAV_DATE as Date,
                 IMDR_tagging,
                FUND_ELIGIBILITY,
                 null as Portfolio,
                 null as InvestmentManager,
				 ServiceCategory as ServiceCategory
            FROM [ESG].[IMDR_Underlying_Holdings] 
           where IMDR_PROCESS_NAV_DATE IS NOT NULL and 
		   IMDR_PROCESS_NAV_DATE in ( select date from #dates )
             and FundViewTagging = 'FASCL-TAP'),
			 AUM
		AS (SELECT distinct [Service]
			  ,[Date]
			  ,LegalEntity
			  ,ServiceCategory
			  ,[MSCI_AS_OF_DATE]
			  ,sum(MV_USD) over (partition by Date,LegalEntity,ServiceCategory) as MV_USD_total,
			  sum(MV_EUR) over (partition by Date,LegalEntity,ServiceCategory) as AUM,
			  sum(MV_GBP) over (partition by Date,LegalEntity,ServiceCategory) as MV_GBP
		  FROM Source_Table --as a
		--  left join esg.SERVICE_CATEGORY_REF b on a.Service=b.MandateCode
		
		 )

		  ---- Logic to Calculate Scopes, Footprints and other factors.
		select * ,
		
		(case
                 when fund_share_class_id IS NOT NULL
                  and FUND_SFDR_CTRY_GHG_INTEN_GDP_EUR_COV >0 
				   and FUND_ELIGIBILITY = 'T' then
                     cast((a.Sov_MV_GBP / sum(Sov_MV_GBP) over(partition by date,LegalEntity,ServiceCategory )) * FUND_SFDR_CTRY_GHG_INTEN_GDP_EUR_COV as float) / 100.0
                 when a.fund_share_class_id IS NULL
                  AND a.issuerid IS NOT NULL
                  and issovereign is not null and CTRY_GHG_INTEN_GDP_EUR >0 then (Sov_MV_GBP / sum(Sov_MV_GBP) over(partition by date,LegalEntity,ServiceCategory ))
                 END) as cov_adj_GHG_intensity_Sovereign
				
		into        #temp_cov_adj_wt_all	
		from ( Select a.date,
		a.ServiceCategory,
                      a.MSCI_AS_OF_DATE,
                      a.LegalEntity,
                      a.Service,
                      a.ISIN,
                      a.AssetName,
                      a.ClientReference,
                      a.Portfolio,
                      a.FUND_SHARE_CLASS_ID,
                      a.ISSUERID,
                      b.CARBON_EMISSIONS_SCOPE_1,
                      b.CARBON_EMISSIONS_SCOPE_2,
                      b.CARBON_EMISSIONS_SCOPE_3_TOTAL,
                      b.CARBON_EMISSIONS_SCOPE123,
                      b.CARBON_EMISSIONS_SALES_EUR_SCOPE123_INTEN,
                      b.EVIC_EUR,
                      a.InvestmentManager,
                      c.FUND_SFDR_CARBON_FOOTPRINT_SCOPE_1,
                      c.FUND_SFDR_CARBON_FOOTPRINT_SCOPE_1_COV,
                      a.MV_EUR,
                      c.FUND_SFDR_CARBON_FOOTPRINT_SCOPE_2,
                      c.FUND_SFDR_CARBON_FOOTPRINT_SCOPE_3,
                      c.FUND_SFDR_CARBON_FOOTPRINT,
                      c.FUND_SFDR_GHG_INTENSITY,
                      d.MV_GBP,
                      d.AUM,
                      d.MV_USD_total,
                      (CASE
                            when a.fund_share_class_id IS NOT NULL THEN 'COLLECTIVE'
                            when a.fund_share_class_id IS NULL
                             AND a.issuerid IS NOT NULL then 'DIRECT'
                            when a.isin is null
                      --and a.SEDOL is null
                      then      'CASH'
                            ELSE 'ISIN NOT MAPPED' END) AS Security_type,
                      (a.MV_EUR / NULLIF(d.aum, 0)) Portfolio_wt,
                      /* case
                when c.FUND_SFDR_GHG_INTENSITY IS NOT NULL -- Change 1 
                 and isnull(b.CARBON_EMISSIONS_SALES_EUR_SCOPE123_INTEN, 0) <> 0 then (a.MV_EUR / NULLIF(d.aum, 0))
                else 0 end as Normalized_Portfolio_wt_intensity, */
                      -- Change 2
                      /* case
               when a.fund_share_class_id IS NOT NULL THEN FUND_SFDR_CARBON_FOOTPRINT_SCOPE_1
                when a.fund_share_class_id IS NULL
                 AND a.issuerid IS NOT NULL and CARBON_EMISSIONS_SCOPE_1 is not null then CARBON_EMISSIONS_SCOPE_1
                else Null end as [DIR_SFDR_CLTV EUS],*/
                      -- Change 3
                      (case
                            when a.fund_share_class_id IS NOT NULL
                             and c.FUND_SFDR_CARBON_FOOTPRINT_SCOPE_1_COV > 0
                             AND FUND_ELIGIBILITY = 'T' then -- Hchange 1
                                cast((a.MV_EUR / NULLIF(d.aum, 0)) * c.FUND_SFDR_CARBON_FOOTPRINT_SCOPE_1_COV as float)
                                / 100.0
                            when a.fund_share_class_id IS NULL
                             AND a.issuerid IS NOT NULL
                             and isnull(b.EVIC_EUR, 0) > 0
                             and b.EVIC_EUR is not null
                             and b.CARBON_EMISSIONS_SCOPE_1 is not null
                      /*isnull(case
                                  when a.fund_share_class_id IS NOT NULL THEN FUND_SFDR_CARBON_FOOTPRINT_SCOPE_1
                                  when a.fund_share_class_id IS NULL
                                   AND a.issuerid IS NOT NULL then CARBON_EMISSIONS_SCOPE_1
                                  else Null end,
                             0) > 0 */
                      then      a.MV_EUR / NULLIF(d.aum, 0) -- change 5
                            else 0 END) cov_adjusted_wt, -- This is for scope 1 
                      (case
                            when a.fund_share_class_id IS NOT NULL
                             and g.FUND_FINANCED_CARBON_EMISSIONS_Coverage > 0
                             AND FUND_ELIGIBILITY = 'T' then -- Hchange 1
                                cast((a.MV_USD / NULLIF(MV_USD_total, 0)) * g.FUND_FINANCED_CARBON_EMISSIONS_Coverage as float)
                                / 100.0
                            when a.fund_share_class_id IS NULL
                             AND a.issuerid IS NOT NULL
                             and isnull(f.EVIC_USD_RECENT, 0) > 0
                             and f.EVIC_USD_RECENT is not null
                             and f.CARBON_EMISSIONS_SCOPE_12 is not null
                      /*isnull(case
                                  when a.fund_share_class_id IS NOT NULL THEN FUND_SFDR_CARBON_FOOTPRINT_SCOPE_1
                                  when a.fund_share_class_id IS NULL
                                   AND a.issuerid IS NOT NULL then CARBON_EMISSIONS_SCOPE_1
                                  else Null end,
                             0) > 0 */
                      then      a.MV_USD / NULLIF(MV_USD_total, 0) -- change 5
                            else 0 END) cov_adjusted_wt_SCOPE12_TCFD, -- 20221119
                      (case
                            when a.fund_share_class_id IS NOT NULL
                             and c.FUND_SFDR_CARBON_FOOTPRINT_SCOPE_2_COV > 0
                             AND FUND_ELIGIBILITY = 'T' then -- Hchange 2
                                cast((a.MV_EUR / NULLIF(d.aum, 0)) * c.FUND_SFDR_CARBON_FOOTPRINT_SCOPE_2_COV as float)
                                / 100.0
                            when a.fund_share_class_id IS NULL
                             AND a.issuerid IS NOT NULL
                             and isnull(b.EVIC_EUR, 0) > 0
                             and b.EVIC_EUR is not null
                             and b.CARBON_EMISSIONS_SCOPE_2 IS NOT NULL
                      /*isnull(
                                                  case
                                  when a.fund_share_class_id IS NOT NULL THEN FUND_SFDR_CARBON_FOOTPRINT_SCOPE_2_COV
                                  when a.fund_share_class_id IS NULL
                                   AND a.issuerid IS NOT NULL then CARBON_EMISSIONS_SCOPE_2
                                  else Null end,
                             0) > 0*/
                      then      a.MV_EUR / NULLIF(d.aum, 0) -- Change 4
                            else 0 END) cov_adjusted_wt2,
                      (case
                            when a.fund_share_class_id IS NOT NULL
                             and c.FUND_SFDR_CARBON_FOOTPRINT_SCOPE_3_COV > 0
                             AND FUND_ELIGIBILITY = 'T' then -- Hchange 3
                                cast((a.MV_EUR / NULLIF(d.aum, 0)) * c.FUND_SFDR_CARBON_FOOTPRINT_SCOPE_3_COV as float)
                                / 100.0
                            when a.fund_share_class_id IS NULL
                             AND a.issuerid IS NOT NULL
                             and isnull(b.EVIC_EUR, 0) > 0
                             and b.EVIC_EUR is not null
                             and b.CARBON_EMISSIONS_SCOPE_3_total IS NOT NULL
                      /*isnull(case
                                  when a.fund_share_class_id IS NOT NULL THEN FUND_SFDR_CARBON_FOOTPRINT_SCOPE_3_COV
                                  when a.fund_share_class_id IS NULL
                                   AND a.issuerid IS NOT NULL then CARBON_EMISSIONS_SCOPE_3_total
                                  else Null end,
                             0) > 0 */
                      then      a.MV_EUR / NULLIF(d.aum, 0) -- Change 6
                            else 0 END) cov_adjusted_wt3,
                      (case
                            when a.fund_share_class_id IS NOT NULL
                             and c.FUND_SFDR_CARBON_FOOTPRINT_cov > 0
                             AND FUND_ELIGIBILITY = 'T' then -- Hchange 4
                                cast((a.MV_EUR / NULLIF(d.aum, 0)) * c.FUND_SFDR_CARBON_FOOTPRINT_cov as float) / 100.0
                            when a.fund_share_class_id IS NULL
                             AND a.issuerid IS NOT NULL
                             and isnull(b.EVIC_EUR, 0) > 0
                             and b.EVIC_EUR is not null
                             and b.CARBON_EMISSIONS_SCOPE123 IS NOT NULL
                      /*isnull(case
                                  when a.fund_share_class_id IS NOT NULL THEN FUND_SFDR_CARBON_FOOTPRINT
                                  when a.fund_share_class_id IS NULL
                                   AND a.issuerid IS NOT NULL then CARBON_EMISSIONS_SCOPE123
                                  else Null end,
                             0) > 0 */
                      then      a.MV_EUR / NULLIF(d.aum, 0) -- change 7
                            else 0 END) cov_adjusted_wt_total,
                      (case
                            when a.fund_share_class_id IS NOT NULL
                             and c.FUND_SFDR_GHG_INTENSITY_COV > 0
                             AND FUND_ELIGIBILITY = 'T' then -- Hchange 5
                                cast((a.MV_EUR / NULLIF(d.aum, 0)) * c.FUND_SFDR_GHG_INTENSITY_COV as float) / 100.0
                            when a.fund_share_class_id IS NULL
                             AND a.issuerid IS NOT NULL
                             and b.CARBON_EMISSIONS_SALES_EUR_SCOPE123_INTEN IS NOT NULL
                      --and CARBON_EMISSIONS_SALES_EUR_SCOPE123_INTEN <> 0 -- change 8
                      then (a.MV_EUR / NULLIF(d.aum, 0))
                            else 0 END) cov_adjusted_GHG_INTENSITY,
                      (case
                            when a.fund_share_class_id IS NOT NULL
                             and g.FUND_WEIGHTED_AVG_CARBON_INTEN_COVERAGE > 0
                             AND FUND_ELIGIBILITY = 'T' then -- Hchange 5
                                cast((a.MV_USD / NULLIF(MV_USD_total, 0)) * g.FUND_WEIGHTED_AVG_CARBON_INTEN_COVERAGE as float)
                                / 100.0
                            when a.fund_share_class_id IS NULL
                             AND a.issuerid IS NOT NULL
                             and CARBON_EMISSIONS_SCOPE_12_INTEN IS NOT NULL
                      --and CARBON_EMISSIONS_SALES_EUR_SCOPE123_INTEN <> 0 -- change 8
                      then (a.MV_USD / NULLIF(MV_USD_total, 0))
                            else 0 END) cov_adjusted_avg_carbon_intensity_scope12_TCFD, -- 20221119
                      (case
                            when a.fund_share_class_id IS NOT NULL
                             and c.FUND_SFDR_ACTIVE_FF_SECTOR_EXPOSURE_COV > 0
                             AND FUND_ELIGIBILITY = 'T' then -- Hchange 6
                                cast((a.MV_EUR / NULLIF(d.aum, 0)) * c.FUND_SFDR_ACTIVE_FF_SECTOR_EXPOSURE_COV as float)
                                / 100.0
                            when a.fund_share_class_id IS NULL
                             AND a.issuerid IS NOT NULL
                             and ACTIVE_FF_SECTOR_EXPOSURE <> ''
                             and ACTIVE_FF_SECTOR_EXPOSURE is not null then (a.MV_EUR / NULLIF(d.aum, 0))
                            else 0 END) cov_adjusted_CompanyExposer_FF,
                      (case
                            when a.fund_share_class_id IS NOT NULL
                             and c.FUND_SFDR_PCT_NONRENEW_CONSUMP_PROD_COV > 0
                             AND FUND_ELIGIBILITY = 'T' then -- Hchange 7
                                cast((a.MV_EUR / NULLIF(d.aum, 0)) * c.FUND_SFDR_PCT_NONRENEW_CONSUMP_PROD_COV as float)
                                / 100.0
                            when a.fund_share_class_id IS NULL
                             AND a.issuerid IS NOT NULL
                             --                  and PCT_NONRENEW_CONSUMP_PROD <> 0   -- change 9
                             and PCT_NONRENEW_CONSUMP_PROD is not null then (a.MV_EUR / NULLIF(d.aum, 0))
                            else 0 END) cov_Non_renewable_energy_SFDR,
                      (case
                            when a.fund_share_class_id IS NOT NULL
                             and c.FUND_SFDR_OPS_PROT_BIODIV_CONTROVS_COV > 0
                             AND FUND_ELIGIBILITY = 'T' then -- Hchange 8
                                cast((a.MV_EUR / NULLIF(d.aum, 0)) * c.FUND_SFDR_OPS_PROT_BIODIV_CONTROVS_COV as float)
                                / 100.0
                            when a.fund_share_class_id IS NULL
                             AND a.issuerid IS NOT NULL
                             and OPS_PROT_BIODIV_CONTROVS <> ''
                             and OPS_PROT_BIODIV_CONTROVS is not null then (a.MV_EUR / NULLIF(d.aum, 0))
                            else 0 END) cov_Neg_afct_biodiversity_sen_areas_Act_SFDR,
                      (case
                            when a.fund_share_class_id IS NOT NULL
                             and c.FUND_SFDR_WATER_EM_EFF_METRIC_TONS_COV > 0
                             AND FUND_ELIGIBILITY = 'T' then -- Hchange 9
                                cast((a.MV_EUR / NULLIF(d.aum, 0)) * c.FUND_SFDR_WATER_EM_EFF_METRIC_TONS_COV as float)
                                / 100.0
                            when a.fund_share_class_id IS NULL
                             AND a.issuerid IS NOT NULL
                             and isnull(b.EVIC_EUR, 0) > 0
                             and b.EVIC_EUR is not null
                             --and isnull(WATER_EM_EFF_METRIC_TONS, 0) > 0 -- change 10
                             and WATER_EM_EFF_METRIC_TONS is not null then a.MV_EUR / NULLIF(d.aum, 0)
                            else 0 END) as cov_adj_Emissions_to_water_SFDR,
                      (case
                            when a.fund_share_class_id IS NOT NULL
                             and c.FUND_SFDR_HAZARD_WASTE_METRIC_TON_COV > 0
                             AND FUND_ELIGIBILITY = 'T' then -- Hchange 10
                                cast((a.MV_EUR / NULLIF(d.aum, 0)) * c.FUND_SFDR_HAZARD_WASTE_METRIC_TON_COV as float)
                                / 100.0
                            when a.fund_share_class_id IS NULL
                             AND a.issuerid IS NOT NULL
                             and isnull(b.EVIC_EUR, 0) > 0
                             and b.EVIC_EUR is not null
                             --and isnull(HAZARD_WASTE_METRIC_TON, 0) > 0 --change 11
                             and HAZARD_WASTE_METRIC_TON is not null then a.MV_EUR / NULLIF(d.aum, 0)
                            else 0 END) as cov_adj_Hazardous_waste_ratio_SFDR,
                      (case
                            when a.fund_share_class_id IS NOT NULL
                             and c.FUND_SFDR_VIOLATIONS_UNGC_OECD_COV > 0
                             AND FUND_ELIGIBILITY = 'T' then -- Hchange 12
                                cast((a.MV_EUR / NULLIF(d.aum, 0)) * c.FUND_SFDR_VIOLATIONS_UNGC_OECD_COV as float)
                                / 100.0
                            when a.fund_share_class_id IS NULL
                             AND a.issuerid IS NOT NULL
                             and isnull(OVERALL_FLAG, '') <> ''
                             and OVERALL_FLAG is not null then (a.MV_EUR / NULLIF(d.aum, 0))
                            else 0 END) cov_adj_Violation_of_UN_Global_SFDR,
                      (case
                            when a.fund_share_class_id IS NOT NULL
                             and c.FUND_SFDR_MECH_UN_GLOBAL_COMPACT_COV > 0
                             AND FUND_ELIGIBILITY = 'T' then -- Hchange 13
                                cast((a.MV_EUR / NULLIF(d.aum, 0)) * c.FUND_SFDR_MECH_UN_GLOBAL_COMPACT_COV as float)
                                / 100.0
                            when a.fund_share_class_id IS NULL
                             AND a.issuerid IS NOT NULL
                             and isnull(MECH_UN_GLOBAL_COMPACT, '') <> ''
                             and MECH_UN_GLOBAL_COMPACT is not null then (a.MV_EUR / NULLIF(d.aum, 0))
                            else 0 END) cov_adj_mech_un_global_compact_sfdr,
                      (case
                            when a.fund_share_class_id IS NOT NULL
                             and (c.FUND_SFDR_GENDER_PAY_GAP_RATIO_COV > 0)
                             AND FUND_ELIGIBILITY = 'T' then -- Hchange 14
                                cast((a.MV_EUR / NULLIF(d.aum, 0)) * c.FUND_SFDR_GENDER_PAY_GAP_RATIO_COV as float)
                                / 100.0
                            when a.fund_share_class_id IS NULL
                             AND a.issuerid IS NOT NULL
                             --  and isnull(GENDER_PAY_GAP_RATIO, 0) <> 0  -- change 12
                             and GENDER_PAY_GAP_RATIO is not null then (a.MV_EUR / NULLIF(d.aum, 0))
                            else 0 END) cov_adj_Unadjusted_gender_pay_gap_sfdr,
                      (case
                            when a.fund_share_class_id IS NOT NULL
                             and c.FUND_SFDR_FM_BOARD_RATIO_COV > 0
                             AND FUND_ELIGIBILITY = 'T' then -- Hchange 15
                                cast((a.MV_EUR / NULLIF(d.aum, 0)) * c.FUND_SFDR_FM_BOARD_RATIO_COV as float) / 100.0
                            when a.fund_share_class_id IS NULL
                             AND a.issuerid IS NOT NULL
                             --and isnull(FM_BOARD_RATIO, 0) <> 0    -- change 13
                             and FM_BOARD_RATIO is not null then (a.MV_EUR / NULLIF(d.aum, 0))
                            else 0 END) cov_adj_Board_of_Gender_density_sfdr,
                      (case
                            when a.fund_share_class_id IS NOT NULL
                             and c.FUND_SFDR_CONTRO_WEAP_CBLMBW_ANYTIE_COV > 0
                             AND FUND_ELIGIBILITY = 'T' then -- Hchange 16
                                cast((a.MV_EUR / NULLIF(d.aum, 0)) * c.FUND_SFDR_CONTRO_WEAP_CBLMBW_ANYTIE_COV as float)
                                / 100.0
                            when a.fund_share_class_id IS NULL
                             AND a.issuerid IS NOT NULL
                             and isnull(CONTRO_WEAP_CBLMBW_ANYTIE, '') <> ''
                             and CONTRO_WEAP_CBLMBW_ANYTIE is not null then (a.MV_EUR / NULLIF(d.aum, 0))
                            else 0 END) as cov_adj_Exp_to_controversial_weapons_SFDR,
                      (case
                            when a.fund_share_class_id IS NOT NULL
                             and c.FUND_REV_EXP_EST_EU_TAXONOMY_MAX_REV_COV > 0
                             AND FUND_ELIGIBILITY = 'T' -- Hchange 17
                      then      cast((a.MV_EUR / NULLIF(d.aum, 0)) * c.FUND_REV_EXP_EST_EU_TAXONOMY_MAX_REV_COV as float)
                                / 100.0
                            when a.fund_share_class_id IS NULL
                             AND a.issuerid IS NOT NULL
                             and e.EST_EU_TAXONOMY_MAX_REV is not null then (a.MV_EUR / NULLIF(d.aum, 0))
                            else 0 END) cov_adj_EU_Taxonomy_Revenue_Alignment_sfdr,
                      (case
                            when a.fund_share_class_id IS NULL
                             AND a.issuerid IS NOT NULL
                             and dg.issuerid is not null then a.MV_GBP
                            when a.fund_share_class_id IS NOT NULL
                             and c.FUND_SFDR_CTRY_GHG_INTEN_GDP_EUR_COV > 0 then a.mv_gbp
                            else 0 end) as Sov_MV_GBP,
                      ACTIVE_FF_SECTOR_EXPOSURE,
                      FUND_SFDR_ACTIVE_FF_SECTOR_EXPOSURE_COV,
                      FUND_SFDR_ACTIVE_FF_SECTOR_EXPOSURE,
                      b.PCT_NONRENEW_CONSUMP_PROD,
                      c.FUND_SFDR_PCT_NONRENEW_CONSUMP_PROD_COV,
                      c.FUND_SFDR_PCT_NONRENEW_CONSUMP_PROD,
                      b.OPS_PROT_BIODIV_CONTROVS,
                      c.FUND_SFDR_OPS_PROT_BIODIV_CONTROVS,
                      c.FUND_SFDR_OPS_PROT_BIODIV_CONTROVS_COV,
                      b.WATER_EM_EFF_METRIC_TONS,
                      c.FUND_SFDR_WATER_EM_EFF_METRIC_TONS,
                      c.FUND_SFDR_WATER_EM_EFF_METRIC_TONS_COV,
                      b.HAZARD_WASTE_METRIC_TON,
                      f.EVIC_USD_RECENT,
                      c.FUND_SFDR_HAZARD_WASTE_METRIC_TON_COV,
                      c.FUND_SFDR_HAZARD_WASTE_METRIC_TON,
                      b.OVERALL_FLAG,
                      c.FUND_SFDR_VIOLATIONS_UNGC_OECD_COV,
                      c.FUND_SFDR_VIOLATIONS_UNGC_OECD,
                      b.MECH_UN_GLOBAL_COMPACT,
                      c.FUND_SFDR_MECH_UN_GLOBAL_COMPACT_COV,
                      c.FUND_SFDR_MECH_UN_GLOBAL_COMPACT,
                      b.GENDER_PAY_GAP_RATIO,
                      c.FUND_SFDR_GENDER_PAY_GAP_RATIO_COV,
                      c.FUND_SFDR_GENDER_PAY_GAP_RATIO,
                      b.FM_BOARD_RATIO,
                      c.FUND_SFDR_FM_BOARD_RATIO,
                      c.FUND_SFDR_FM_BOARD_RATIO_COV,
                      b.CONTRO_WEAP_CBLMBW_ANYTIE,
                      c.FUND_SFDR_CONTRO_WEAP_CBLMBW_ANYTIE,
                      c.FUND_SFDR_CONTRO_WEAP_CBLMBW_ANYTIE_COV,
                      c.FUND_REV_EXP_EST_EU_TAXONOMY_MAX_REV_COV,
                      c.FUND_REV_EXP_EST_EU_TAXONOMY_MAX_REV,
                      c.FP_REG_FRAME_SFDR_ART6,
                      c.FP_REG_FRAME_SFDR_ART8,
                      c.FP_REG_FRAME_SFDR_ART9,
                      e.EST_EU_TAXONOMY_MAX_REV,
                      b.CTRY_GHG_INTEN_GDP_EUR,
                      c.FUND_SFDR_CTRY_GHG_INTEN_GDP_EUR,
                      c.FUND_SFDR_CTRY_GHG_INTEN_GDP_EUR_COV,
                      b.GOVERNMENT_EU_SANCTIONS,
                      dg.issuerid as issovereign,
                      c.FUND_SFDR_GHG_INTENSITY_COV,
                      c.FUND_SFDR_CARBON_FOOTPRINT_SCOPE_2_COV,
                      c.FUND_SFDR_CARBON_FOOTPRINT_SCOPE_3_COV,
                      CARBON_EMISSIONS_SCOPE_12_INTEN,
                      FUND_WEIGHTED_AVG_CARBON_INTEN_COVERAGE,
                      CARBON_EMISSIONS_SCOPE_12,
                      FUND_FINANCED_CARBON_EMISSIONS,
                      MV_USD,
                      FUND_WEIGHTED_AVG_CARBON_INTEN,
                      a.FUND_ELIGIBILITY
                 from Source_Table a
                 left join [ESG].[DIR_SFDR] b
                   on b.ISSUERID            = a.ISSUERID
                  and a.MSCI_AS_OF_DATE     = b.AS_OF_DATE
                 left join [ESG].[CLTV_EUSUSTAINABLEFINANCE] c
                   on a.MSCI_AS_OF_DATE     = c.AS_OF_DATE
                  and a.FUND_SHARE_CLASS_ID = c.FUND_SHARE_CLASS_ID
                 left join AUM d
                   on a.LegalEntity         = d.LegalEntity
                  and a.Service             = d.Service
                  and a.Date                = d.Date
                 left join [ESG].[DIR_EUTAXONOMY] e
                   on e.ISSUERID            = a.ISSUERID
                  and a.MSCI_AS_OF_DATE     = e.AS_OF_DATE
                 left join [ESG].[DIR_CLIMATECHANGE] f
                   on f.ISSUERID            = a.ISSUERID
                  and a.MSCI_AS_OF_DATE     = f.AS_OF_DATE
                 LEFT JOIN [ESG].[CLTV_STDCOV_CLIMATECHANGE] g
                   on a.MSCI_AS_OF_DATE     = g.AS_OF_DATE
                  and a.FUND_SHARE_CLASS_ID = g.FUND_SHARE_CLASS_ID
                 left join (select issuerid from [ESG].[DIR_GOVRATING] group by issuerid) as DG
                   on a.issuerId            = dg.issuerid
               
				
				) as a
;


    with Results1
      as (select *,
                 cov_adjusted_wt / nullif(sum(cov_adjusted_wt) over (partition by Date, LegalEntity,ServiceCategory), 0) as Normalized,
                 (cov_adjusted_wt / nullif(sum(cov_adjusted_wt) over (partition by Date, LegalEntity,ServiceCategory), 0))
                 * sum(MV_EUR) over (partition by Date, LegalEntity,ServiceCategory) as Normalized_MVEUR,
                 cov_adjusted_wt2 / nullif(sum(cov_adjusted_wt2) over (partition by Date, LegalEntity,ServiceCategory), 0) as Normalized2,
                 (cov_adjusted_wt2 / nullif(sum(cov_adjusted_wt2) over (partition by Date, LegalEntity,ServiceCategory), 0))
                 * sum(MV_EUR) over (partition by Date, LegalEntity,ServiceCategory) as Normalized_MVEUR2,
                 cov_adjusted_wt3 / nullif(sum(cov_adjusted_wt3) over (partition by Date, LegalEntity,ServiceCategory), 0) as Normalized3,
                 (cov_adjusted_wt3 / nullif(sum(cov_adjusted_wt3) over (partition by Date, LegalEntity,ServiceCategory), 0))
                 * sum(MV_EUR) over (partition by Date, LegalEntity,ServiceCategory) as Normalized_MVEUR3,
                 cov_adjusted_wt_total / nullif(sum(cov_adjusted_wt_total) over (partition by Date, LegalEntity,ServiceCategory), 0) as Normalized_total,
                 (cov_adjusted_wt_total / nullif(sum(cov_adjusted_wt_total) over (partition by Date, LegalEntity,ServiceCategory), 0))
                 * sum(MV_EUR) over (partition by Date, LegalEntity,ServiceCategory) as Normalized_MVEUR_total,
                 (cov_adjusted_ghg_intensity
                  / NULLIF(Sum(cov_adjusted_ghg_intensity) OVER (partition BY date, LegalEntity,ServiceCategory), 0)) AS normalized_ghg_intensity,
                 (cov_adjusted_CompanyExposer_FF
                  / NULLIF(Sum(cov_adjusted_CompanyExposer_FF) OVER (partition BY date, LegalEntity,ServiceCategory), 0)) AS normalized_ExposertoCompany_FF,
                 (cov_Non_renewable_energy_SFDR
                  / NULLIF(Sum(cov_Non_renewable_energy_SFDR) OVER (partition BY date, LegalEntity,ServiceCategory), 0)) AS normalized_Non_renewable_energy_SFDR,
                 (cov_Neg_afct_biodiversity_sen_areas_Act_SFDR
                  / nullif(sum(cov_Neg_afct_biodiversity_sen_areas_Act_SFDR) over (partition BY date, LegalEntity,ServiceCategory), 0)) as Nor_Neg_afct_biodiversity_sen_areas_Act_SFDR,
                 (cov_adj_Emissions_to_water_SFDR
                  / nullif(sum(cov_adj_Emissions_to_water_SFDR) over (partition BY date, LegalEntity,ServiceCategory), 0)) as Normalized_Emissions_to_water_SFDR,
                 (cov_adj_Emissions_to_water_SFDR
                  / nullif(sum(cov_adj_Emissions_to_water_SFDR) over (partition by Date, LegalEntity,ServiceCategory), 0))
                 * sum(MV_EUR) over (partition by Date, LegalEntity,ServiceCategory) as Normalized_Emissions_to_water_MVEUR_SFDR,
                 (cov_adj_Hazardous_waste_ratio_SFDR
                  / nullif(sum(cov_adj_Hazardous_waste_ratio_SFDR) over (partition BY date, LegalEntity,ServiceCategory), 0)) as Normalized_Hazardous_waste_ratio_SFDR,
                 (cov_adj_Hazardous_waste_ratio_SFDR
                  / nullif(sum(cov_adj_Hazardous_waste_ratio_SFDR) over (partition by Date, LegalEntity,ServiceCategory), 0))
                 * sum(MV_EUR) over (partition by Date, LegalEntity,ServiceCategory) as Normalized_Hazardous_waste_MVEUR_SFDR,
                 (cov_adj_Violation_of_UN_Global_SFDR
                  / nullif(sum(cov_adj_Violation_of_UN_Global_SFDR) over (partition by date, LegalEntity,ServiceCategory), 0)) as Norm_Violation_of_UN_Global_SFDR,
                 (cov_adj_mech_un_global_compact_sfdr
                  / nullif(sum(cov_adj_mech_un_global_compact_sfdr) over (partition by date, LegalEntity,ServiceCategory), 0)) as Norm_mech_un_global_compact_sfdr,
                 (cov_adj_Unadjusted_gender_pay_gap_sfdr
                  / nullif(sum(cov_adj_Unadjusted_gender_pay_gap_sfdr) over (partition by date, LegalEntity,ServiceCategory), 0)) as Norm_Unadjusted_gender_pay_gap_sfdr,
                 (cov_adj_Board_of_Gender_density_sfdr
                  / nullif(sum(cov_adj_Board_of_Gender_density_sfdr) over (partition by date, LegalEntity,ServiceCategory), 0)) as Norm_Board_of_Gender_density_sfdr,
                 (cov_adj_Exp_to_controversial_weapons_SFDR
                  / nullif(sum(cov_adj_Exp_to_controversial_weapons_SFDR) over (partition by date, LegalEntity,ServiceCategory), 0)) as Norm_Exp_to_controversial_weapons_SFDR,
                 (cov_adj_EU_Taxonomy_Revenue_Alignment_sfdr
                  / nullif(sum(cov_adj_EU_Taxonomy_Revenue_Alignment_sfdr) over (partition by date, LegalEntity,ServiceCategory), 0)) as Norm_EU_Taxonomy_Revenue_Alignment_sfdr,
				  (cov_adj_GHG_intensity_Sovereign
				  /nullif(sum(cov_adj_GHG_intensity_Sovereign) over (partition by date,LegalEntity,ServiceCategory), 0)) as Norm_GHG_intensity_Sovereign
				  ,  (cov_adjusted_avg_carbon_intensity_scope12_TCFD
                  / NULLIF(Sum(cov_adjusted_avg_carbon_intensity_scope12_TCFD) OVER (Partition by Date,LegalEntity,ServiceCategory), 0)) AS normalized_weighted_average_carbon_intensity_scope12_TCFD
            from #temp_cov_adj_wt_all)

    ---- The calculated data gets pushed into Factor_Scope1_SWE_Discretionary_Portfolio_All table.
    select *,
           (Scope1 + Scope2 + Scope3) as Total_GHG_emissions
    into   ESG.[Factors_All]
      from (   select *,
                      (case
                            when Security_type = 'DIRECT'
                             and CARBON_EMISSIONS_SALES_EUR_SCOPE123_INTEN IS NOT NULL then -- change 13
                                CARBON_EMISSIONS_SALES_EUR_SCOPE123_INTEN
                            when Security_type = 'COLLECTIVE'
                             and isnull(FUND_SFDR_GHG_INTENSITY_COV, 0) <> 0
                             and FUND_ELIGIBILITY = 'T' then FUND_SFDR_GHG_INTENSITY
                            else 0 end) * (normalized_ghg_intensity) as GHG_Intensity_of_investee_companies_1,
                      (case
                            when Security_type = 'DIRECT'
                             and CARBON_EMISSIONS_SCOPE_12_INTEN IS NOT NULL then -- change 13
                                CARBON_EMISSIONS_SCOPE_12_INTEN
                            when Security_type = 'COLLECTIVE'
                             and isnull(FUND_WEIGHTED_AVG_CARBON_INTEN_COVERAGE, 0) <> 0
                             and FUND_ELIGIBILITY = 'T' then FUND_WEIGHTED_AVG_CARBON_INTEN
                            else 0 end) * (normalized_weighted_average_carbon_intensity_scope12_TCFD) as Weighted_average_carbon_intensity_scope12_TCFD, -- 20221119
                      (case
                            when Security_type = 'DIRECT'
                             and ACTIVE_FF_SECTOR_EXPOSURE = 'yes' then 100
                            when Security_type = 'COLLECTIVE'
                             and isnull(FUND_SFDR_ACTIVE_FF_SECTOR_EXPOSURE_COV, 0) <> 0
                             and FUND_ELIGIBILITY = 'T' then FUND_SFDR_ACTIVE_FF_SECTOR_EXPOSURE
                            else 0 end) * (mv_eur / aum) as ActiveinFFSector, ---------   Exposure to companies active in the fossil fuel sector (%)
                      case
                           when Security_type = 'DIRECT'
                            and (   EVIC_EUR > 0
                              and   EVIC_EUR IS NOT NULL)
                            --                            and isnull(CARBON_EMISSIONS_SCOPE_1, 0) > 0  -- change 14
                            and CARBON_EMISSIONS_SCOPE_1 is not null then
                      (CARBON_EMISSIONS_SCOPE_1 * MV_EUR) / (nullif(EVIC_EUR * 1000000, 0))
                           when Security_type = 'COLLECTIVE'
                            and FUND_SFDR_CARBON_FOOTPRINT_SCOPE_1_COV <> 0
                            and FUND_ELIGIBILITY = 'T' then -- Change 15
                      (FUND_SFDR_CARBON_FOOTPRINT_SCOPE_1 * MV_EUR) / 1000000
                           else 0 end as Scope1, -- ((WATER_EM_EFF_METRIC_TONS)* a.MV_EUR) / (nullif(EVIC_EUR * 1000000, 0)),
                      case
                           when Security_type = 'DIRECT'
                            and (   EVIC_USD_RECENT > 0
                              and   EVIC_USD_RECENT IS NOT NULL)
                            and CARBON_EMISSIONS_SCOPE_12 is not null then
                      (CARBON_EMISSIONS_SCOPE_12 * MV_USD) / (nullif(EVIC_USD_RECENT * 1000000, 0))
                           when Security_type = 'COLLECTIVE'
                            and FUND_SFDR_CARBON_FOOTPRINT_SCOPE_1_COV <> 0
                            and FUND_ELIGIBILITY = 'T' then -- Change 15
                      (FUND_FINANCED_CARBON_EMISSIONS * MV_USD) / 1000000
                           else 0 end as Scope12_TCFD, -- MV_USD /( EVIC_USD_RECENT*1,000,000) --20221119,
                      case
                           when Security_type = 'DIRECT'
                            and (   EVIC_EUR > 0
                              and   EVIC_EUR IS NOT NULL)
                            --and isnull(CARBON_EMISSIONS_SCOPE_2, 0) > 0  -- change 15
                            and CARBON_EMISSIONS_SCOPE_2 is not null then
                      (CARBON_EMISSIONS_SCOPE_2 * MV_EUR) / (nullif(EVIC_EUR * 1000000, 0))
                           when Security_type = 'COLLECTIVE'
                            and FUND_SFDR_CARBON_FOOTPRINT_SCOPE_2_COV <> 0
                            and FUND_ELIGIBILITY = 'T' then -- change 16
                      (FUND_SFDR_CARBON_FOOTPRINT_SCOPE_2 * MV_EUR) / 1000000
                           else 0 end as Scope2,
                      case
                           when Security_type = 'DIRECT'
                            and (   EVIC_EUR > 0
                              and   EVIC_EUR IS NOT NULL)
                            --                            and isnull(CARBON_EMISSIONS_SCOPE_3_total, 0) > 0  -- change 17
                            and CARBON_EMISSIONS_SCOPE_3_total is not null then
                      (CARBON_EMISSIONS_SCOPE_3_total * MV_EUR) / (nullif(EVIC_EUR * 1000000, 0))
                           when Security_type = 'COLLECTIVE'
                            and FUND_SFDR_CARBON_FOOTPRINT_SCOPE_3_COV <> 0
                            and FUND_ELIGIBILITY = 'T' then -- change 18
                      (FUND_SFDR_CARBON_FOOTPRINT_SCOPE_3 * MV_EUR) / 1000000
                           else 0 end as Scope3,
                      (case
                            when Security_type = 'DIRECT'
                             and OPS_PROT_BIODIV_CONTROVS = 'Yes' then 100
                            when Security_type = 'COLLECTIVE'
                             and isnull(FUND_SFDR_OPS_PROT_BIODIV_CONTROVS_COV, 0) <> 0
                             and FUND_ELIGIBILITY = 'T' then -- change 19
                                FUND_SFDR_OPS_PROT_BIODIV_CONTROVS
                            else 0 end) * (mv_eur / aum) as Neg_afct_biodiversity_sen_areas_Act_SFDR,
                      (case
                            when Security_type = 'DIRECT'
                             and (   EVIC_EUR > 0
                               and   EVIC_EUR IS NOT NULL)
                             --and isnull(WATER_EM_EFF_METRIC_TONS, 0) > 0   -- change 20
                             and WATER_EM_EFF_METRIC_TONS is not null then
                      ((WATER_EM_EFF_METRIC_TONS) * MV_EUR) / (nullif(EVIC_EUR * 1000000, 0)) -- a.MV_EUR) / (nullif(EVIC_EUR * 1000000, 0))
                            when Security_type = 'COLLECTIVE'
                             and FUND_SFDR_WATER_EM_EFF_METRIC_TONS_COV <> 0
                             and FUND_ELIGIBILITY = 'T' then -- change 21
                      (FUND_SFDR_WATER_EM_EFF_METRIC_TONS) * MV_EUR / 1000000
                            else 0 end) as Emissions_to_water_SFDR,
                      (case
                            when Security_type = 'DIRECT'
                             and PCT_NONRENEW_CONSUMP_PROD IS NOT NULL -- change 22
                      then      PCT_NONRENEW_CONSUMP_PROD
                            when Security_type = 'COLLECTIVE'
                             and isnull(FUND_SFDR_PCT_NONRENEW_CONSUMP_PROD_COV, 0) <> 0
                             and FUND_ELIGIBILITY = 'T' then FUND_SFDR_PCT_NONRENEW_CONSUMP_PROD
                            else 0 end) * (normalized_Non_renewable_energy_SFDR) as Non_renewable_energy_share_SFDR,
                      (case
                            when Security_type = 'DIRECT'
                             and (   EVIC_EUR > 0
                               and   EVIC_EUR IS NOT NULL)
                             -- and isnull(HAZARD_WASTE_METRIC_TON, 0) > 0 -- change 23
                             and HAZARD_WASTE_METRIC_TON is not null then
                      (HAZARD_WASTE_METRIC_TON * MV_EUR) / (nullif(EVIC_EUR * 1000000, 0))
                            when Security_type = 'COLLECTIVE'
                             and FUND_SFDR_HAZARD_WASTE_METRIC_TON_COV <> 0
                             and FUND_ELIGIBILITY = 'T' then -- change 24
                      (FUND_SFDR_HAZARD_WASTE_METRIC_TON * MV_EUR) / 1000000
                            else 0 end) as Hazardous_waste_ratio_SFDR,
                      (case
                            when Security_type = 'DIRECT'
                             and OVERALL_FLAG = 'Red' then 100
                            when Security_type = 'COLLECTIVE'
                             and isnull(FUND_SFDR_VIOLATIONS_UNGC_OECD_COV, 0) <> 0
                             and FUND_ELIGIBILITY = 'T' then FUND_SFDR_VIOLATIONS_UNGC_OECD
                            else 0 end) * ((mv_eur / aum)) as Violation_of_UN_Global_SFDR,
                      (case
                            when Security_type = 'DIRECT'
                             and MECH_UN_GLOBAL_COMPACT = 'No evidence' then 100
                            when Security_type = 'COLLECTIVE'
                             and isnull(FUND_SFDR_MECH_UN_GLOBAL_COMPACT_COV, 0) <> 0
                             and FUND_ELIGIBILITY = 'T' then FUND_SFDR_MECH_UN_GLOBAL_COMPACT
                            else 0 end) * ((mv_eur / aum)) as Mech_un_global_compact_sfdr,
                      (case
                            when Security_type = 'DIRECT'
                             and GENDER_PAY_GAP_RATIO IS NOT NULL then GENDER_PAY_GAP_RATIO -- change 25
                            when Security_type = 'COLLECTIVE'
                             and isnull(FUND_SFDR_GENDER_PAY_GAP_RATIO_COV, 0) <> 0
                             and FUND_ELIGIBILITY = 'T' then FUND_SFDR_GENDER_PAY_GAP_RATIO
                            else 0 end) * (Norm_Unadjusted_gender_pay_gap_sfdr) as Unadjusted_gender_pay_gap_sfdr,
                      (case
                            when Security_type = 'DIRECT'
                             and FM_BOARD_RATIO IS NOT NULL then FM_BOARD_RATIO -- change 26
                            when Security_type = 'COLLECTIVE'
                             and isnull(FUND_SFDR_FM_BOARD_RATIO_COV, 0) <> 0
                             and FUND_ELIGIBILITY = 'T' then FUND_SFDR_FM_BOARD_RATIO
                            else 0 end) * (Norm_Board_of_Gender_density_sfdr) as Board_of_Gender_density_sfdr,
                      (case
                            when Security_type = 'DIRECT'
                             and CONTRO_WEAP_CBLMBW_ANYTIE = 'Yes' then 100
                            when Security_type = 'COLLECTIVE'
                             and isnull(FUND_SFDR_CONTRO_WEAP_CBLMBW_ANYTIE_COV, 0) <> 0
                             and FUND_ELIGIBILITY = 'T' then FUND_SFDR_CONTRO_WEAP_CBLMBW_ANYTIE
                            else 0 end) * (mv_eur / aum) as Exp_to_controversial_weapons_SFDR, -- change 20221121 -- remove (Norm_Exp_to_controversial_weapons_SFDR)
                      (case
                            when Security_type = 'DIRECT'
                             and EST_EU_TAXONOMY_MAX_REV is not null then EST_EU_TAXONOMY_MAX_REV
                            when Security_type = 'COLLECTIVE'
                             and FUND_REV_EXP_EST_EU_TAXONOMY_MAX_REV_COV <> 0
                             and FUND_ELIGIBILITY = 'T' -- change 28
                      then      FUND_REV_EXP_EST_EU_TAXONOMY_MAX_REV
                            else 0 end) * (Norm_EU_Taxonomy_Revenue_Alignment_sfdr) as EU_Taxonomy_Revenue_Alignment_sfdr,
                      (case
                            when Security_type = 'DIRECT'
                             and CTRY_GHG_INTEN_GDP_EUR is not null
                             and issovereign is not null then CTRY_GHG_INTEN_GDP_EUR
                            when Security_type = 'COLLECTIVE'
                             and isnull(FUND_SFDR_CTRY_GHG_INTEN_GDP_EUR_COV, 0) <> 0
                             and FUND_ELIGIBILITY = 'T' then FUND_SFDR_CTRY_GHG_INTEN_GDP_EUR
                            else 0 end) * (Norm_GHG_intensity_Sovereign) as GHG_intensity_Sovereign
                 FROM Results1) as CarbonfootPrint_derived

    -- From Factor_Scope1_SWE_Discretionary_Portfolio_All the data moves to TCFD_LE_Service_SUM 
    INSERT INTO [ESG].[TCFD_LE_Service_SUM] (
[DATE],
[MSCI_AS_OF_DATE],
[Legal_Entity],
[DistinctAsset],
[TotalClients],
[TotalPortfolio],
[MV_USD],
[MV_EUR],
[MV_GBP],
[Service],
[Service_Category],
[GHG_SCOPE_1],
[GHG_SCOPE_1_COV],
[GHG_SCOPE_2],
[GHG_SCOPE_2_COV],
[GHG_SCOPE_3],
[GHG_SCOPE_3_COV],
[GHG_SCOPE_123],
[GHG_SCOPE_123_COV],
[GHG_Carbon_Footprint_USD],
[GHG_Carbon_Footprint_USD_COV],
[GHG_Intensity_EUR],
[GHG_Intensity_EUR_COV],
ACTIVE_FF_SECTOR_EXPOSURE,
ACTIVE_FF_SECTOR_EXPOSURE_COV,
GHG_Carbon_Footprint_SFDR,
GHG_Carbon_Footprint_COV_SFDR,
GHG_Intensity_EUR_SFDR,
GHG_Intensity_EUR_COV_SFDR,
Non_renewable_energy_CP_share_SFDR,
Non_renewable_energy_CP_share_COV_SFDR,
Nor_Neg_afct_biodiversity_sen_areas_Act_SFDR,
Nor_Neg_afct_biodiversity_sen_areas_Act_COV_SFDR,
Emissionsto_water_SFDR,
Emissionsto_water_COV_SFDR,
Hazardous_waste_ratio_SFDR,
Hazardous_waste_COV_SFDR,
Violation_of_UN_Global_SFDR,
Violation_of_UN_Global_COV_SFDR,
Mech_un_global_compact_sfdr,
Mech_un_global_compact_cov_sfdr,
Unadjusted_gender_pay_gap_sfdr,
Unadjusted_gender_pay_gap_cov_sfdr,
Board_of_Gender_density_sfdr,
Board_of_Gender_density_cov_sfdr,
Exp_to_controversial_weapons_SFDR,
Exp_to_controversial_weapons_COV_SFDR,
EU_Taxonomy_Revenue_Alignment_sfdr,
EU_Taxonomy_Revenue_Alignment_COV_sfdr,
GHG_intensity_Sovereign_SFDR,
GHG_intensity_Sovereign_COV_SFDR,
Carbon_Emissions_Scope_12_TCFD,
Carbon_Emissions_Scope_12_COV_TCFD,
Weighted_average_carbon_intensity_scope12_TCFD,
Weighted_average_carbon_intensity_scope12_COV_TCFD,
CARBON_FOOTPRINT_TCFD,
reporting_group )
    select date,
           [MSCI_AS_OF_DATE],
           LegalEntity,
           Count(distinct (AssetName)) as [DistinctAsset],
           Count(distinct (ClientReference)) as [TotalClients],
           Count(distinct (Portfolio)) as [TotalPortfolio],
           MV_USD_total as MV_USD,
           AUM as MV_EUR,
           MV_GBP as MV_GBP,
		   'NA' as Service,
		   ServiceCategory as [Service_Category],
           sum(scope1) as [GHG_SCOPE_1],
           sum(cov_adjusted_wt) * 100 as [GHG_SCOPE_1_COV],
           sum(scope2) as [GHG_SCOPE_2],
           sum(cov_adjusted_wt2) * 100 as [GHG_SCOPE_2_COV],
           sum(scope3) as [GHG_SCOPE_3],
           sum(cov_adjusted_wt3) * 100 as [GHG_SCOPE_3_COV],
           sum(Total_GHG_emissions) as [GHG_SCOPE_123],
           sum(cov_adjusted_wt3) * 100 as [GHG_SCOPE_123_COV],
          NULL as [GHG_Carbon_Footprint_USD],
NULL AS GHG_Carbon_Footprint_USD_COV,
sum(GHG_Intensity_of_investee_companies_1) as [GHG_Intensity_EUR],
sum(cov_adjusted_GHG_INTENSITY) * 100 as [GHG_Intensity_EUR_COV],
sum(ActiveinFFSector) as ACTIVE_FF_SECTOR_EXPOSURE,
sum(cov_adjusted_CompanyExposer_FF) * 100 as ACTIVE_FF_SECTOR_EXPOSURE_COV,
(sum(Total_GHG_emissions) * 1000000 / (AUM)) as [GHG_Carbon_Footprint_SFDR],
(case when sum(cov_adjusted_wt) < sum(cov_adjusted_wt2) then     case when sum(cov_adjusted_wt) < sum(cov_adjusted_wt3) then sum(cov_adjusted_wt) else sum(cov_adjusted_wt3) end when sum(cov_adjusted_wt2) < sum(cov_adjusted_wt3) then sum(cov_adjusted_wt2) else sum(cov_adjusted_wt3) end) * 100 as [GHG_Carbon_Footprint_COV_SFDR],
sum(GHG_Intensity_of_investee_companies_1) as [GHG_Intensity_EUR_SFDR],
sum(cov_adjusted_GHG_INTENSITY) * 100 as [GHG_Intensity_EUR_COV_SFDR],
sum(Non_renewable_energy_share_SFDR) as Non_renewable_energy_CP_share_SFDR,
sum(cov_Non_renewable_energy_SFDR) * 100 as Non_renewable_energy_CP_share_COV_SFDR,
sum(Neg_afct_biodiversity_sen_areas_Act_SFDR) as Nor_Neg_afct_biodiversity_sen_areas_Act_SFDR,
sum(cov_Neg_afct_biodiversity_sen_areas_Act_SFDR) * 100 as Nor_Neg_afct_biodiversity_sen_areas_Act_COV_SFDR,
(sum(Emissions_to_water_SFDR) * 1000000 / (AUM)) as Emissionsto_water_SFDR,
sum(cov_adj_Emissions_to_water_SFDR) * 100 as Emissionsto_water_COV_SFDR,
(sum(Hazardous_waste_ratio_SFDR) * 1000000 / (AUM)) as Hazardous_waste_ratio_SFDR,
sum(cov_adj_Hazardous_waste_ratio_SFDR) * 100 as Hazardous_waste_COV_SFDR,
sum(Violation_of_UN_Global_SFDR) as Violation_of_UN_Global_SFDR,
sum(cov_adj_Violation_of_UN_Global_SFDR) * 100 as Violation_of_UN_Global_COV_SFDR,
sum(Mech_un_global_compact_sfdr) as Mech_un_global_compact_sfdr,
sum(cov_adj_Mech_un_global_compact_sfdr) * 100 as Mech_un_global_compact_cov_sfdr,
sum(Unadjusted_gender_pay_gap_sfdr) as Unadjusted_gender_pay_gap_sfdr,
sum(cov_adj_Unadjusted_gender_pay_gap_sfdr) * 100 as Unadjusted_gender_pay_gap_cov_sfdr,
sum(Board_of_Gender_density_sfdr) as Board_of_Gender_density_sfdr,
sum(cov_adj_Board_of_Gender_density_sfdr) * 100 as Board_of_Gender_density_cov_sfdr,
sum(Exp_to_controversial_weapons_SFDR) as Exp_to_controversial_weapons_SFDR,
sum(cov_adj_Exp_to_controversial_weapons_SFDR) * 100 as Exp_to_controversial_weapons_COV_SFDR,
sum(EU_Taxonomy_Revenue_Alignment_sfdr) as EU_Taxonomy_Revenue_Alignment_sfdr,
sum(cov_adj_EU_Taxonomy_Revenue_Alignment_sfdr) * 100 as EU_Taxonomy_Revenue_Alignment_COV_sfdr,
sum(GHG_intensity_Sovereign) as GHG_intensity_Sovereign_SFDR,
sum(cov_adj_GHG_intensity_Sovereign) * 100 as GHG_intensity_Sovereign_COV_SFDR,
sum(Scope12_TCFD) as Carbon_Emissions_Scope_12_TCFD,
sum(cov_adjusted_wt_SCOPE12_TCFD) * 100 as Carbon_Emissions_Scope_12_COV_TCFD,
sum(Weighted_average_carbon_intensity_scope12_TCFD) as Weighted_average_carbon_intensity_scope12_TCFD,
sum(cov_adjusted_avg_carbon_intensity_scope12_TCFD) * 100 as Weighted_average_carbon_intensity_scope12_COV_TCFD,
(SUM(Scope12_TCFD) * 1000000) / MV_USD_TOTAL AS CARBON_FOOTPRINT_TCFD,
'FUND_LOOK_THROUGH' as reporting_group

      from ESG.[Factors_All]
     group by date,
              LegalEntity,
			  ServiceCategory,
              [MSCI_AS_OF_DATE],
              MV_USD_total,
              MV_GBP,
              AUM

end



GO
