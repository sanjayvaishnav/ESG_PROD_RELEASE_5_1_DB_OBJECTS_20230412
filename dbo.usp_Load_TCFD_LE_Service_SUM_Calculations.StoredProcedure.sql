USE [ESG]
GO
/****** Object:  StoredProcedure [dbo].[usp_Load_TCFD_LE_Service_SUM_Calculations]    Script Date: 4/18/2023 12:13:15 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[usp_Load_TCFD_LE_Service_SUM_Calculations]
GO
/****** Object:  StoredProcedure [dbo].[usp_Load_TCFD_LE_Service_SUM_Calculations]    Script Date: 4/18/2023 12:13:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[usp_Load_TCFD_LE_Service_SUM_Calculations]
(
@reporting_group varchar(50),
@dates varchar(200)=Null
)
/*
Logic :

USE [ESG]
GO

DECLARE	@return_value int

EXEC	@return_value = [dbo].[usp_Load_TCFD_LE_Service_SUM_Calculations]
		@reporting_group = N'HOLDING_CFO'

SELECT	'Return Value' = @return_value

GO

-------------------------------------------------------------------------------
Created Date	Version		Created By		Comments
01-FEB-2023		0.1			Wipro			Initial version 
15-FEB-2023		0.2			Wipro			Changes for PAI 6,13,16,17,18 (Changes for Release 4)
-------------------------------------------------------------------------------

*/
AS
BEGIN
	drop table if exists #temp_cov_adj_wt_all;
	drop table if exists [ESG].[Factors_All];
	TRUNCATE TABLE [ESG].[SOURCE_TABLE_AUM]
	DECLARE @ReturnValue AS INT = 0 ;
	DECLARE @Table as Varchar(30) ;

BEGIN TRY
INSERT INTO [ESG].[TCFD_LE_SERVICE_LOG] VALUES (GETDATE(),'usp_Load_TCFD_LE_Service_SUM_Calculations','Start execution for ' + @reporting_group) 

	IF (@reporting_group = 'HOLDING_CFO')
	BEGIN
		;WITH AUM
				AS 
				(
					SELECT
					distinct [Date]
					,LegalEntity
					,ServiceCategory
					,[MSCI_AS_OF_DATE]
					,sum(MV_USD) over (partition by Date,LegalEntity,ServiceCategory,asset_group) as MV_USD_total
					,sum(MV_EUR) over (partition by Date,LegalEntity,ServiceCategory,asset_group) as AUM
					,sum(MV_GBP) over (partition by Date,LegalEntity,ServiceCategory,asset_group) as MV_GBP_TOTAL
					,ASSET_GROUP
					FROM [ESG].[SOURCE_TABLE]
				)

		INSERT INTO [ESG].[SOURCE_TABLE_AUM] SELECT * FROM AUM
		INSERT INTO [ESG].[TCFD_LE_SERVICE_LOG] VALUES (GETDATE(),'usp_Load_TCFD_LE_Service_SUM_Calculations','After insertion into SOURCE_TABLE_AUM for ' + @reporting_group) 	
	END

	;WITH sovereign_source_table
				AS 
				(
					SELECT
					 [Date]
					,LegalEntity
					,ServiceCategory
					,[MSCI_AS_OF_DATE]
					,SUM((case
                            when A.fund_share_class_id IS NULL
                             AND A.issuerid IS NOT NULL
                             and DG.issuerid is not null then A.MV_GBP
                            when A.fund_share_class_id IS NOT NULL
                             and C.FUND_SFDR_GLOBAL_EU_SANCTIONS_COV > 0 then A.mv_gbp
                            else 0 end)) as Sov_EUSANC_MV_GBP

					,SUM((case
                            when A.fund_share_class_id IS NULL
                             AND A.issuerid IS NOT NULL
                             and DG.issuerid is not null then A.MV_EUR
                            when A.fund_share_class_id IS NOT NULL
                             and C.FUND_SFDR_GLOBAL_EU_SANCTIONS_COV > 0 then A.MV_EUR
                            else 0 end)) as Sov_EUSANC_MV_EUR

					,ASSET_GROUP
					,a.FUND_SHARE_CLASS_ID
                    ,a.ISSUERID
					,(case
                            when A.fund_share_class_id IS NULL
                             AND A.issuerid IS NOT NULL
                              then 'DIRECT'
                            when A.fund_share_class_id IS NOT NULL
                              then 'COLLECTIVE'
                            else 'ISIN NOT MATCHED/CASH' end) as FUND_TYPE
					
					FROM [ESG].[SOURCE_TABLE] A 
					left join [ESG].[CLTV_EUSUSTAINABLEFINANCE] C on a.MSCI_AS_OF_DATE = c.AS_OF_DATE and a.FUND_SHARE_CLASS_ID = c.FUND_SHARE_CLASS_ID
					left join (select issuerid from [ESG].[DIR_GOVRATING] group by issuerid) as DG on a.issuerId = dg.issuerid
					GROUP BY 
					[Date]
					,LegalEntity
					,ServiceCategory
					,[MSCI_AS_OF_DATE]
					,ASSET_GROUP
					,a.FUND_SHARE_CLASS_ID
                    ,a.ISSUERID
				)

INSERT INTO [ESG].[TCFD_LE_SERVICE_LOG] VALUES (GETDATE(),'usp_Load_TCFD_LE_Service_SUM_Calculations','After populating CTE sovereign_source_table for ' + @reporting_group) 

	select 
		* , 
		(
			case
			when fund_share_class_id IS NOT NULL
			and FUND_SFDR_CTRY_GHG_INTEN_GDP_EUR_COV >0 
			and FUND_ELIGIBILITY = 'T' then
			(case 
			when (sum(Sov_MV_GBP) over(partition by Date,LegalEntity,ServiceCategory,asset_group ) = 0) 
			then (0) 
			else
			cast((a.Sov_MV_GBP / sum(Sov_MV_GBP) over(partition by Date,LegalEntity,ServiceCategory,asset_group )) * FUND_SFDR_CTRY_GHG_INTEN_GDP_EUR_COV as float) / 100.0 end)
			when a.fund_share_class_id IS NULL
			AND a.issuerid IS NOT NULL
			and issovereign is not null and CTRY_GHG_INTEN_GDP_EUR > 0 then 
			(
			case 
			when (sum(Sov_MV_GBP) over(partition by Date,LegalEntity,ServiceCategory,asset_group ) = 0) 
			then 0
			else
			(a.Sov_MV_GBP / sum(Sov_MV_GBP) over(partition by Date,LegalEntity,ServiceCategory,asset_group ))
			end
			) end) as cov_adj_GHG_intensity_Sovereign,

			(case
			when fund_share_class_id IS NOT NULL and FUND_ELIGIBILITY = 'T' and FP_REG_FRAME_SFDR_ART6 = 'T'
			then
			(case 
			when (sum(cltv_mv_eur) over(partition by Date,LegalEntity,ServiceCategory,asset_group ) = 0) 
			then (0) 
			else
			cast((a.cltv_mv_eur * 100 / sum(cltv_mv_eur) over(partition by Date,LegalEntity,ServiceCategory,asset_group )) as float) end)
			else 0
			
			end) as CLTV_SFDR_ART6,

			(case
			when fund_share_class_id IS NOT NULL and FUND_ELIGIBILITY = 'T' and FP_REG_FRAME_SFDR_ART8 = 'T'
			then
			(case 
			when (sum(cltv_mv_eur) over(partition by Date,LegalEntity,ServiceCategory,asset_group ) = 0) 
			then (0) 
			else
			cast((a.cltv_mv_eur * 100 / sum(cltv_mv_eur) over(partition by Date,LegalEntity,ServiceCategory,asset_group )) as float) end)
			else 0
			
			end) as CLTV_SFDR_ART8,

			(case
			when fund_share_class_id IS NOT NULL and FUND_ELIGIBILITY = 'T' and FP_REG_FRAME_SFDR_ART9 = 'T'
			then
			(case 
			when (sum(cltv_mv_eur) over(partition by Date,LegalEntity,ServiceCategory,asset_group ) = 0) 
			then (0) 
			else
			cast((a.cltv_mv_eur * 100 / sum(cltv_mv_eur) over(partition by Date,LegalEntity,ServiceCategory,asset_group )) as float) end)
			else 0
			
			end) as CLTV_SFDR_ART9
				
		into        #temp_cov_adj_wt_all	
		from ( 
					 Select 
					  a.date,
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
                      c.FUND_SFDR_CARBON_FOOTPRINT_SCOPE_1,
                      c.FUND_SFDR_CARBON_FOOTPRINT_SCOPE_1_COV,
                      a.MV_EUR,
                      c.FUND_SFDR_CARBON_FOOTPRINT_SCOPE_2,
                      c.FUND_SFDR_CARBON_FOOTPRINT_SCOPE_3,
                      c.FUND_SFDR_CARBON_FOOTPRINT,
                      c.FUND_SFDR_GHG_INTENSITY,
                      d.MV_GBP_total,  -- to be changes to d.mv_gbp_total
                      d.AUM,
                      d.MV_USD_total,
					  a.ASSET_GROUP,
                      (CASE
                            when a.fund_share_class_id IS NOT NULL THEN 'COLLECTIVE'
                            when a.fund_share_class_id IS NULL
                             AND a.issuerid IS NOT NULL then 'DIRECT'
                            when a.isin is null
                      then      'CASH'
                            ELSE 'ISIN NOT MAPPED' END) AS Security_type,
                      (case when (NULLIF(d.aum, 0) = 0) then (0) else   NULLIF(d.aum, 0) end) Portfolio_wt,

                      (case
                            when a.fund_share_class_id IS NOT NULL
                             and c.FUND_SFDR_CARBON_FOOTPRINT_SCOPE_1_COV > 0
                             AND FUND_ELIGIBILITY = 'T' then
                                cast((  (case when (NULLIF(d.aum, 0) = 0) then (0) else a.MV_EUR / NULLIF(d.aum, 0) end)) * c.FUND_SFDR_CARBON_FOOTPRINT_SCOPE_1_COV as float)
                                / 100.0
                            when a.fund_share_class_id IS NULL
                             AND a.issuerid IS NOT NULL
                             and isnull(b.EVIC_EUR, 0) > 0
                             and b.EVIC_EUR is not null
                             and b.CARBON_EMISSIONS_SCOPE_1 is not null

                      then        (case when (NULLIF(d.aum, 0) = 0) then (0) else a.MV_EUR / NULLIF(d.aum, 0) end) -- change 5
                            else 0 END) cov_adjusted_wt,
                      (case
                            when a.fund_share_class_id IS NOT NULL
                             and g.FUND_FINANCED_CARBON_EMISSIONS_Coverage > 0
                             AND FUND_ELIGIBILITY = 'T' then
                                cast((case when (NULLIF(mv_usd_total , 0) = 0) then (0) else a.mv_usd / NULLIF(mv_usd_total, 0) end) * g.FUND_FINANCED_CARBON_EMISSIONS_Coverage as float)
                                / 100.0
                            when a.fund_share_class_id IS NULL
                             AND a.issuerid IS NOT NULL
                             and isnull(f.EVIC_USD_RECENT, 0) > 0
                             and f.EVIC_USD_RECENT is not null
                             and f.CARBON_EMISSIONS_SCOPE_12 is not null

                      then      (case when (NULLIF(mv_usd_total , 0) = 0) then (0) else a.mv_usd / NULLIF(mv_usd_total, 0) end) -- change 5
                            else 0 END) cov_adjusted_wt_SCOPE12_TCFD,
                      (case
                            when a.fund_share_class_id IS NOT NULL
                             and c.FUND_SFDR_CARBON_FOOTPRINT_SCOPE_2_COV > 0
                             AND FUND_ELIGIBILITY = 'T' then -- Hchange 2
                                cast((  (case when (NULLIF(d.aum, 0) = 0) then (0) else a.MV_EUR / NULLIF(d.aum, 0) end)) * c.FUND_SFDR_CARBON_FOOTPRINT_SCOPE_2_COV as float)
                                / 100.0
                            when a.fund_share_class_id IS NULL
                             AND a.issuerid IS NOT NULL
                             and isnull(b.EVIC_EUR, 0) > 0
                             and b.EVIC_EUR is not null
                             and b.CARBON_EMISSIONS_SCOPE_2 IS NOT NULL

                      then        (case when (NULLIF(d.aum, 0) = 0) then (0) else a.MV_EUR / NULLIF(d.aum, 0) end) -- Change 4
                            else 0 END) cov_adjusted_wt2,
                      (case
                            when a.fund_share_class_id IS NOT NULL
                             and c.FUND_SFDR_CARBON_FOOTPRINT_SCOPE_3_COV > 0
                             AND FUND_ELIGIBILITY = 'T' then -- Hchange 3
                                cast((  (case when (NULLIF(d.aum, 0) = 0) then (0) else a.MV_EUR / NULLIF(d.aum, 0) end)) * c.FUND_SFDR_CARBON_FOOTPRINT_SCOPE_3_COV as float)
                                / 100.0
                            when a.fund_share_class_id IS NULL
                             AND a.issuerid IS NOT NULL
                             and isnull(b.EVIC_EUR, 0) > 0
                             and b.EVIC_EUR is not null
                             and b.CARBON_EMISSIONS_SCOPE_3_total IS NOT NULL

                      then        (case when (NULLIF(d.aum, 0) = 0) then (0) else a.MV_EUR / NULLIF(d.aum, 0) end) -- Change 6
                            else 0 END) cov_adjusted_wt3,
                      (case
                            when a.fund_share_class_id IS NOT NULL
                             and c.FUND_SFDR_CARBON_FOOTPRINT_cov > 0
                             AND FUND_ELIGIBILITY = 'T' then -- Hchange 4
                                cast((  (case when (NULLIF(d.aum, 0) = 0) then (0) else a.MV_EUR / NULLIF(d.aum, 0) end)) * c.FUND_SFDR_CARBON_FOOTPRINT_cov as float) / 100.0
                            when a.fund_share_class_id IS NULL
                             AND a.issuerid IS NOT NULL
                             and isnull(b.EVIC_EUR, 0) > 0
                             and b.EVIC_EUR is not null
                             and b.CARBON_EMISSIONS_SCOPE123 IS NOT NULL

                      then        (case when (NULLIF(d.aum, 0) = 0) then (0) else a.MV_EUR / NULLIF(d.aum, 0) end) -- change 7
                            else 0 END) cov_adjusted_wt_total,
                      (case
                            when a.fund_share_class_id IS NOT NULL
                             and c.FUND_SFDR_GHG_INTENSITY_COV > 0
                             AND FUND_ELIGIBILITY = 'T' then -- Hchange 5
                                cast((  (case when (NULLIF(d.aum, 0) = 0) then (0) else a.MV_EUR / NULLIF(d.aum, 0) end)) * c.FUND_SFDR_GHG_INTENSITY_COV as float) / 100.0
                            when a.fund_share_class_id IS NULL
                             AND a.issuerid IS NOT NULL
                             and b.CARBON_EMISSIONS_SALES_EUR_SCOPE123_INTEN IS NOT NULL
                      then (  (case when (NULLIF(d.aum, 0) = 0) then (0) else a.MV_EUR / NULLIF(d.aum, 0) end))
                            else 0 END) cov_adjusted_GHG_INTENSITY,
                      (case
                            when a.fund_share_class_id IS NOT NULL
                             and g.FUND_WEIGHTED_AVG_CARBON_INTEN_COVERAGE > 0
                             AND FUND_ELIGIBILITY = 'T' then -- Hchange 5
                                cast((case when (NULLIF(mv_usd_total , 0) = 0) then (0) else a.mv_usd / NULLIF(mv_usd_total, 0) end) * g.FUND_WEIGHTED_AVG_CARBON_INTEN_COVERAGE as float)
                                / 100.0
                            when a.fund_share_class_id IS NULL
                             AND a.issuerid IS NOT NULL
                             and CARBON_EMISSIONS_SCOPE_12_INTEN IS NOT NULL

                      then (case when (NULLIF(mv_usd_total , 0) = 0) then (0) else a.mv_usd / NULLIF(mv_usd_total, 0) end)
                            else 0 END) cov_adjusted_avg_carbon_intensity_scope12_TCFD, 
                      (case
                            when a.fund_share_class_id IS NOT NULL
                             and c.FUND_SFDR_ACTIVE_FF_SECTOR_EXPOSURE_COV > 0
                             AND FUND_ELIGIBILITY = 'T' then -- Hchange 6
                                cast((  (case when (NULLIF(d.aum, 0) = 0) then (0) else a.MV_EUR / NULLIF(d.aum, 0) end)) * c.FUND_SFDR_ACTIVE_FF_SECTOR_EXPOSURE_COV as float)
                                / 100.0
                            when a.fund_share_class_id IS NULL
                             AND a.issuerid IS NOT NULL
                             and ACTIVE_FF_SECTOR_EXPOSURE <> ''
                             and ACTIVE_FF_SECTOR_EXPOSURE is not null then (  (case when (NULLIF(d.aum, 0) = 0) then (0) else a.MV_EUR / NULLIF(d.aum, 0) end))
                            else 0 END) cov_adjusted_CompanyExposer_FF,

                      (case
                            when a.fund_share_class_id IS NOT NULL
                             and c.FUND_SFDR_PCT_NONRENEW_CONSUMP_PROD_COV > 0
                             AND FUND_ELIGIBILITY = 'T' then -- Hchange 7
                                cast((  (case when (NULLIF(d.aum, 0) = 0) then (0) else a.MV_EUR / NULLIF(d.aum, 0) end)) * c.FUND_SFDR_PCT_NONRENEW_CONSUMP_PROD_COV as float)
                                / 100.0
                            when a.fund_share_class_id IS NULL
                             AND a.issuerid IS NOT NULL

                             and PCT_NONRENEW_CONSUMP_PROD is not null then (  (case when (NULLIF(d.aum, 0) = 0) then (0) else a.MV_EUR / NULLIF(d.aum, 0) end))
                            else 0 END) cov_Non_renewable_energy_SFDR,
                      (case
                            when a.fund_share_class_id IS NOT NULL
                             and c.FUND_SFDR_OPS_PROT_BIODIV_CONTROVS_COV > 0
                             AND FUND_ELIGIBILITY = 'T' then -- Hchange 8
                                cast((  (case when (NULLIF(d.aum, 0) = 0) then (0) else a.MV_EUR / NULLIF(d.aum, 0) end)) * c.FUND_SFDR_OPS_PROT_BIODIV_CONTROVS_COV as float)
                                / 100.0
                            when a.fund_share_class_id IS NULL
                             AND a.issuerid IS NOT NULL
                             and OPS_PROT_BIODIV_CONTROVS <> ''
                             and OPS_PROT_BIODIV_CONTROVS is not null then (  (case when (NULLIF(d.aum, 0) = 0) then (0) else a.MV_EUR / NULLIF(d.aum, 0) end))
                            else 0 END) cov_Neg_afct_biodiversity_sen_areas_Act_SFDR,
                      (case
                            when a.fund_share_class_id IS NOT NULL
                             and c.FUND_SFDR_WATER_EM_EFF_METRIC_TONS_COV > 0
                             AND FUND_ELIGIBILITY = 'T' then -- Hchange 9
                                cast((  (case when (NULLIF(d.aum, 0) = 0) then (0) else a.MV_EUR / NULLIF(d.aum, 0) end)) * c.FUND_SFDR_WATER_EM_EFF_METRIC_TONS_COV as float)
                                / 100.0
                            when a.fund_share_class_id IS NULL
                             AND a.issuerid IS NOT NULL
                             and isnull(b.EVIC_EUR, 0) > 0
                             and b.EVIC_EUR is not null

                             and WATER_EM_EFF_METRIC_TONS is not null then   (case when (NULLIF(d.aum, 0) = 0) then (0) else a.MV_EUR / NULLIF(d.aum, 0) end)
                            else 0 END) as cov_adj_Emissions_to_water_SFDR,
                      (case
                            when a.fund_share_class_id IS NOT NULL
                             and c.FUND_SFDR_HAZARD_WASTE_METRIC_TON_COV > 0
                             AND FUND_ELIGIBILITY = 'T' then -- Hchange 10
                                cast((  (case when (NULLIF(d.aum, 0) = 0) then (0) else a.MV_EUR / NULLIF(d.aum, 0) end)) * c.FUND_SFDR_HAZARD_WASTE_METRIC_TON_COV as float)
                                / 100.0
                            when a.fund_share_class_id IS NULL
                             AND a.issuerid IS NOT NULL
                             and isnull(b.EVIC_EUR, 0) > 0
                             and b.EVIC_EUR is not null

                             and HAZARD_WASTE_METRIC_TON is not null then   (case when (NULLIF(d.aum, 0) = 0) then (0) else a.MV_EUR / NULLIF(d.aum, 0) end)
                            else 0 END) as cov_adj_Hazardous_waste_ratio_SFDR,
                      (case
                            when a.fund_share_class_id IS NOT NULL
                             and c.FUND_SFDR_VIOLATIONS_UNGC_OECD_COV > 0
                             AND FUND_ELIGIBILITY = 'T' then -- Hchange 12
                                cast((  (case when (NULLIF(d.aum, 0) = 0) then (0) else a.MV_EUR / NULLIF(d.aum, 0) end)) * c.FUND_SFDR_VIOLATIONS_UNGC_OECD_COV as float)
                                / 100.0
                            when a.fund_share_class_id IS NULL
                             AND a.issuerid IS NOT NULL
                             and isnull(OVERALL_FLAG, '') <> ''
                             and OVERALL_FLAG is not null then (  (case when (NULLIF(d.aum, 0) = 0) then (0) else a.MV_EUR / NULLIF(d.aum, 0) end))
                            else 0 END) cov_adj_Violation_of_UN_Global_SFDR,
                      (case
                            when a.fund_share_class_id IS NOT NULL
                             and c.FUND_SFDR_MECH_UN_GLOBAL_COMPACT_COV > 0
                             AND FUND_ELIGIBILITY = 'T' then -- Hchange 13
                                cast((  (case when (NULLIF(d.aum, 0) = 0) then (0) else a.MV_EUR / NULLIF(d.aum, 0) end)) * c.FUND_SFDR_MECH_UN_GLOBAL_COMPACT_COV as float)
                                / 100.0
                            when a.fund_share_class_id IS NULL
                             AND a.issuerid IS NOT NULL
                             and isnull(MECH_UN_GLOBAL_COMPACT, '') <> ''
                             and MECH_UN_GLOBAL_COMPACT is not null then (  (case when (NULLIF(d.aum, 0) = 0) then (0) else a.MV_EUR / NULLIF(d.aum, 0) end))
                            else 0 END) cov_adj_mech_un_global_compact_sfdr,
                      (case
                            when a.fund_share_class_id IS NOT NULL
                             and (c.FUND_SFDR_GENDER_PAY_GAP_RATIO_COV > 0)
                             AND FUND_ELIGIBILITY = 'T' then -- Hchange 14
                                cast((  (case when (NULLIF(d.aum, 0) = 0) then (0) else a.MV_EUR / NULLIF(d.aum, 0) end)) * c.FUND_SFDR_GENDER_PAY_GAP_RATIO_COV as float)
                                / 100.0
                            when a.fund_share_class_id IS NULL
                             AND a.issuerid IS NOT NULL

                             and GENDER_PAY_GAP_RATIO is not null then (  (case when (NULLIF(d.aum, 0) = 0) then (0) else a.MV_EUR / NULLIF(d.aum, 0) end))
                            else 0 END) cov_adj_Unadjusted_gender_pay_gap_sfdr,

                      (case
                            when a.fund_share_class_id IS NOT NULL
                             and c.FUND_SFDR_FM_BOARD_RATIO_COV > 0
                             AND FUND_ELIGIBILITY = 'T' then 
                                cast((  (case when (NULLIF(d.aum, 0) = 0) then (0) else a.MV_EUR / NULLIF(d.aum, 0) end)) * c.FUND_SFDR_FM_BOARD_RATIO_COV as float) / 100.0
                            when a.fund_share_class_id IS NULL
                             AND a.issuerid IS NOT NULL
                             and FM_BOARD_RATIO is not null then (  (case when (NULLIF(d.aum, 0) = 0) then (0) else a.MV_EUR / NULLIF(d.aum, 0) end))
                            else 0 END) AS cov_adj_Board_of_Gender_diversity_ratio_sfdr,
				
					(case
                            when a.fund_share_class_id IS NOT NULL
                             and c.FUND_SFDR_FEMALE_DIRECTORS_COV > 0
                             AND FUND_ELIGIBILITY = 'T' then
                                cast((  (case when (NULLIF(d.aum, 0) = 0) then (0) else a.MV_EUR / NULLIF(d.aum, 0) end)) * c.FUND_SFDR_FEMALE_DIRECTORS_COV as float) / 100.0
                            when a.fund_share_class_id IS NULL
                             AND a.issuerid IS NOT NULL
                             and b.FEMALE_DIRECTORS_PCT is not null then (  (case when (NULLIF(d.aum, 0) = 0) then (0) else a.MV_EUR / NULLIF(d.aum, 0) end))
                            else 0 END) as cov_adj_Board_of_Gender_diversity_pct_sfdr,				 

                      (case
                            when a.fund_share_class_id IS NOT NULL
                             and c.FUND_SFDR_CONTRO_WEAP_CBLMBW_ANYTIE_COV > 0
                             AND FUND_ELIGIBILITY = 'T' then -- Hchange 16
                                cast((  (case when (NULLIF(d.aum, 0) = 0) then (0) else a.MV_EUR / NULLIF(d.aum, 0) end)) * c.FUND_SFDR_CONTRO_WEAP_CBLMBW_ANYTIE_COV as float)
                                / 100.0
                            when a.fund_share_class_id IS NULL
                             AND a.issuerid IS NOT NULL
                             and isnull(CONTRO_WEAP_CBLMBW_ANYTIE, '') <> ''
                             and CONTRO_WEAP_CBLMBW_ANYTIE is not null then (  (case when (NULLIF(d.aum, 0) = 0) then (0) else a.MV_EUR / NULLIF(d.aum, 0) end))
                            else 0 END) as cov_adj_Exp_to_controversial_weapons_SFDR,
                      (case
                            when a.fund_share_class_id IS NOT NULL
                             and c.FUND_REV_EXP_EST_EU_TAXONOMY_MAX_REV_COV > 0
                             AND FUND_ELIGIBILITY = 'T' -- Hchange 17
                      then      cast((  (case when (NULLIF(d.aum, 0) = 0) then (0) else a.MV_EUR / NULLIF(d.aum, 0) end)) * c.FUND_REV_EXP_EST_EU_TAXONOMY_MAX_REV_COV as float)
                                / 100.0
                            when a.fund_share_class_id IS NULL
                             AND a.issuerid IS NOT NULL
                             and e.EST_EU_TAXONOMY_MAX_REV is not null then (  (case when (NULLIF(d.aum, 0) = 0) then (0) else a.MV_EUR / NULLIF(d.aum, 0) end))
                            else 0 END) cov_adj_EU_Taxonomy_Revenue_Alignment_sfdr,
                      (case
                            when a.fund_share_class_id IS NULL
                             AND a.issuerid IS NOT NULL
                             and dg.issuerid is not null then a.MV_GBP
                            when a.fund_share_class_id IS NOT NULL
                             and c.FUND_SFDR_CTRY_GHG_INTEN_GDP_EUR_COV > 0 then a.mv_gbp
                            else 0 end) as Sov_MV_GBP,

					/* Changes for Release 4 start */

					(case
                            when a.fund_share_class_id IS not NULL
							then a.MV_EUR
                            else 0 end) as cltv_mv_eur,

					(case 
					when (a.date >'2023-01-01') 
					then 
					(					
						(case
						when a.fund_share_class_id IS NOT NULL and c.FUND_SFDR_HUMAN_RGTS_POL_COV > 0 AND FUND_ELIGIBILITY = 'T' 
						then cast(((case when (NULLIF(d.aum, 0) = 0) then (0) else a.MV_EUR / NULLIF(d.aum, 0) end)) * c.FUND_SFDR_HUMAN_RGTS_POL_COV as float) / 100.0
						when a.fund_share_class_id IS NULL
						AND a.issuerid IS NOT NULL and HUMAN_RGTS_POL <> '' and HUMAN_RGTS_POL is not null 
							then ((case when (NULLIF(d.aum, 0) = 0) then (0) else a.MV_EUR / NULLIF(d.aum, 0) end))
						else 0 END) 					
					)
					else Null end) as cov_SFDR_HUMAN_RGTS_POL,

					(case 
					when (a.date >'2023-01-01') 
					then 
					(
						(case
                    when a.fund_share_class_id IS NOT NULL and c.FUND_CARBON_EMISSIONS_REDUCT_INITIATIVES_COV > 0 AND FUND_ELIGIBILITY = 'T' 
					then cast(((case when (NULLIF(d.aum, 0) = 0) then (0) else a.MV_EUR / NULLIF(d.aum, 0) end)) * c.FUND_CARBON_EMISSIONS_REDUCT_INITIATIVES_COV as float) / 100.0
                    when a.fund_share_class_id IS NULL
                    AND a.issuerid IS NOT NULL and CARBON_REDUCT_INITIATIVES_PA <> '' and CARBON_REDUCT_INITIATIVES_PA is not null 
						then ((case when (NULLIF(d.aum, 0) = 0) then (0) else a.MV_EUR / NULLIF(d.aum, 0) end))
                    else 0 END)
					)
					else null end) as cov_CARBON_EMISSIONS_REDUCT_INITIATIVES,

					(case 
					when (a.date >'2023-01-01') 
					then 
					((case
                    when a.fund_share_class_id IS NOT NULL and c.FUND_SFDR_ENERGY_CONSUMP_INTEN_EUR_NACE_COV_A > 0 AND FUND_ELIGIBILITY = 'T' 
					then cast(((case when (NULLIF(d.aum, 0) = 0) then (0) else a.MV_EUR / NULLIF(d.aum, 0) end)) * c.FUND_SFDR_ENERGY_CONSUMP_INTEN_EUR_NACE_COV_A as float) / 100.0
                    when a.fund_share_class_id IS NULL
                    AND a.issuerid IS NOT NULL and ENERGY_CONSUMP_INTEN_EUR  is not null AND NACE_SECTION_CODE = 'A' 
						then ((case when (NULLIF(d.aum, 0) = 0) then (0) else a.MV_EUR / NULLIF(d.aum, 0) end))
                    else 0 END)) else null end) as cov_ENERGY_CONSUMP_INTEN_NACE_A,

					(case 
					when (a.date >'2023-01-01') 
					then 
					(
					(case
                    when a.fund_share_class_id IS NOT NULL and c.FUND_SFDR_ENERGY_CONSUMP_INTEN_EUR_NACE_COV_B > 0 AND FUND_ELIGIBILITY = 'T' 
					then cast(((case when (NULLIF(d.aum, 0) = 0) then (0) else a.MV_EUR / NULLIF(d.aum, 0) end)) * c.FUND_SFDR_ENERGY_CONSUMP_INTEN_EUR_NACE_COV_B as float) / 100.0
                    when a.fund_share_class_id IS NULL
                    AND a.issuerid IS NOT NULL and ENERGY_CONSUMP_INTEN_EUR  is not null AND NACE_SECTION_CODE = 'B' 
						then ((case when (NULLIF(d.aum, 0) = 0) then (0) else a.MV_EUR / NULLIF(d.aum, 0) end))
                    else 0 END)) else null end) as cov_ENERGY_CONSUMP_INTEN_NACE_B,

					(case 
					when (a.date >'2023-01-01') 
					then 
					(
					(case
                    when a.fund_share_class_id IS NOT NULL and c.FUND_SFDR_ENERGY_CONSUMP_INTEN_EUR_NACE_COV_C > 0 AND FUND_ELIGIBILITY = 'T' 
					then cast(((case when (NULLIF(d.aum, 0) = 0) then (0) else a.MV_EUR / NULLIF(d.aum, 0) end)) * c.FUND_SFDR_ENERGY_CONSUMP_INTEN_EUR_NACE_COV_C as float) / 100.0
                    when a.fund_share_class_id IS NULL
                    AND a.issuerid IS NOT NULL and ENERGY_CONSUMP_INTEN_EUR  is not null AND NACE_SECTION_CODE = 'C' 
						then ((case when (NULLIF(d.aum, 0) = 0) then (0) else a.MV_EUR / NULLIF(d.aum, 0) end))
                    else 0 END)) else null end) as cov_ENERGY_CONSUMP_INTEN_NACE_C,

					(case 
					when (a.date >'2023-01-01') 
					then 
					(
					(case
                    when a.fund_share_class_id IS NOT NULL and c.FUND_SFDR_ENERGY_CONSUMP_INTEN_EUR_NACE_COV_D > 0 AND FUND_ELIGIBILITY = 'T' 
					then cast(((case when (NULLIF(d.aum, 0) = 0) then (0) else a.MV_EUR / NULLIF(d.aum, 0) end)) * c.FUND_SFDR_ENERGY_CONSUMP_INTEN_EUR_NACE_COV_D as float) / 100.0
                    when a.fund_share_class_id IS NULL
                    AND a.issuerid IS NOT NULL and ENERGY_CONSUMP_INTEN_EUR  is not null AND NACE_SECTION_CODE = 'D' 
						then ((case when (NULLIF(d.aum, 0) = 0) then (0) else a.MV_EUR / NULLIF(d.aum, 0) end))
                    else 0 END)) else null end) as cov_ENERGY_CONSUMP_INTEN_NACE_D,

					(case 
					when (a.date >'2023-01-01') 
					then 
					(
					(case
                    when a.fund_share_class_id IS NOT NULL and c.FUND_SFDR_ENERGY_CONSUMP_INTEN_EUR_NACE_COV_E > 0 AND FUND_ELIGIBILITY = 'T' 
					then cast(((case when (NULLIF(d.aum, 0) = 0) then (0) else a.MV_EUR / NULLIF(d.aum, 0) end)) * c.FUND_SFDR_ENERGY_CONSUMP_INTEN_EUR_NACE_COV_E as float) / 100.0
                    when a.fund_share_class_id IS NULL
                    AND a.issuerid IS NOT NULL AND ENERGY_CONSUMP_INTEN_EUR  is not null AND NACE_SECTION_CODE = 'E' 
						then ((case when (NULLIF(d.aum, 0) = 0) then (0) else a.MV_EUR / NULLIF(d.aum, 0) end))
                    else 0 END)) else null end) as cov_ENERGY_CONSUMP_INTEN_NACE_E,

					(case 
					when (a.date >'2023-01-01') 
					then 
					(
					(case
                    when a.fund_share_class_id IS NOT NULL and c.FUND_SFDR_ENERGY_CONSUMP_INTEN_EUR_NACE_COV_F > 0 AND FUND_ELIGIBILITY = 'T' 
					then cast(((case when (NULLIF(d.aum, 0) = 0) then (0) else a.MV_EUR / NULLIF(d.aum, 0) end)) * c.FUND_SFDR_ENERGY_CONSUMP_INTEN_EUR_NACE_COV_F as float) / 100.0
                    when a.fund_share_class_id IS NULL
                    AND a.issuerid IS NOT NULL and ENERGY_CONSUMP_INTEN_EUR  is not null AND NACE_SECTION_CODE = 'F' 
						then ((case when (NULLIF(d.aum, 0) = 0) then (0) else a.MV_EUR / NULLIF(d.aum, 0) end))
                    else 0 END)) else null end) as cov_ENERGY_CONSUMP_INTEN_NACE_F,

					(case 
					when (a.date >'2023-01-01') 
					then 
					(
					(case
                    when a.fund_share_class_id IS NOT NULL and c.FUND_SFDR_ENERGY_CONSUMP_INTEN_EUR_NACE_COV_G > 0 AND FUND_ELIGIBILITY = 'T' 
					then cast(((case when (NULLIF(d.aum, 0) = 0) then (0) else a.MV_EUR / NULLIF(d.aum, 0) end)) * c.FUND_SFDR_ENERGY_CONSUMP_INTEN_EUR_NACE_COV_G as float) / 100.0
                    when a.fund_share_class_id IS NULL
                    AND a.issuerid IS NOT NULL and ENERGY_CONSUMP_INTEN_EUR  is not null AND NACE_SECTION_CODE = 'G' 
						then ((case when (NULLIF(d.aum, 0) = 0) then (0) else a.MV_EUR / NULLIF(d.aum, 0) end))
                    else 0 END)) else null end) as cov_ENERGY_CONSUMP_INTEN_NACE_G,

					(case 
					when (a.date >'2023-01-01') 
					then 
					(
					(case
                    when a.fund_share_class_id IS NOT NULL and c.FUND_SFDR_ENERGY_CONSUMP_INTEN_EUR_NACE_COV_H > 0 AND FUND_ELIGIBILITY = 'T' 
					then cast(((case when (NULLIF(d.aum, 0) = 0) then (0) else a.MV_EUR / NULLIF(d.aum, 0) end)) * c.FUND_SFDR_ENERGY_CONSUMP_INTEN_EUR_NACE_COV_H as float) / 100.0
                    when a.fund_share_class_id IS NULL
                    AND a.issuerid IS NOT NULL and ENERGY_CONSUMP_INTEN_EUR  is not null AND NACE_SECTION_CODE = 'H' 
						then ((case when (NULLIF(d.aum, 0) = 0) then (0) else a.MV_EUR / NULLIF(d.aum, 0) end))
                    else 0 END)) else null end) as cov_ENERGY_CONSUMP_INTEN_NACE_H,

					
					(case 
					when (a.date >'2023-01-01') 
					then 
					(
					(case
                    when a.fund_share_class_id IS NOT NULL and c.FUND_SFDR_ENERGY_CONSUMP_INTEN_EUR_NACE_COV_L > 0 AND FUND_ELIGIBILITY = 'T' 
					then cast(((case when (NULLIF(d.aum, 0) = 0) then (0) else a.MV_EUR / NULLIF(d.aum, 0) end)) * c.FUND_SFDR_ENERGY_CONSUMP_INTEN_EUR_NACE_COV_L as float) / 100.0
                    when a.fund_share_class_id IS NULL
                    AND a.issuerid IS NOT NULL and ENERGY_CONSUMP_INTEN_EUR  is not null AND NACE_SECTION_CODE = 'L' 
						then ((case when (NULLIF(d.aum, 0) = 0) then (0) else a.MV_EUR / NULLIF(d.aum, 0) end))
                    else 0 END)) else null end) as cov_ENERGY_CONSUMP_INTEN_NACE_L,

					(case 
					when (a.date >'2023-01-01') 
					then 
					((case
                    when a.fund_share_class_id IS NOT NULL and c.FUND_SFDR_ENERGY_CONSUMP_INTEN_EUR_COV > 0 AND FUND_ELIGIBILITY = 'T' 
					then cast(((case when (NULLIF(d.aum, 0) = 0) then (0) else a.MV_EUR / NULLIF(d.aum, 0) end)) * c.FUND_SFDR_ENERGY_CONSUMP_INTEN_EUR_COV as float) / 100.0
                    when a.fund_share_class_id IS NULL
                    AND a.issuerid IS NOT NULL and ENERGY_CONSUMP_INTEN_EUR  is not null
						then ((case when (NULLIF(d.aum, 0) = 0) then (0) else a.MV_EUR / NULLIF(d.aum, 0) end))
                    else 0 END)) else null end) as cov_ENERGY_CONSUMP_INTEN,

					/* Changes for Release 4 end */


					/* Changes for Release 5.1 start */

					(case
					when a.FUND_SHARE_CLASS_ID IS NOT NULL and FUND_ELIGIBILITY = 'T' and FP_REG_FRAME_SFDR_ART6 = 'T'
					then
					(case 
					when nullif(d.aum,0) = 0 then 0
					else
					cast(((a.MV_EUR * 100) / d.aum) as float) end)
					else 0
			
					end) as SFDR_ART6,

					(case
					when a.FUND_SHARE_CLASS_ID IS NOT NULL and FUND_ELIGIBILITY = 'T' and FP_REG_FRAME_SFDR_ART8 = 'T'
					then
					(case 
					when nullif(d.aum,0) = 0 then 0
					else
					cast(((a.MV_EUR * 100) / d.aum) as float) end)
					else 0
			
					end) as SFDR_ART8,

					(case
					when a.FUND_SHARE_CLASS_ID IS NOT NULL and FUND_ELIGIBILITY = 'T' and FP_REG_FRAME_SFDR_ART9 = 'T'
					then
					(case 
					when nullif(d.aum,0) = 0 then 0
					else
					cast(((a.MV_EUR * 100) / d.aum) as float) end)
					else 0
			
					end) as SFDR_ART9,

					(case 
					when (a.date >'2023-03-16') 
					then 
					(case
                            when 
							a.fund_share_class_id IS NOT NULL
                            and g.FUND_CARBON_EMISSIONS_SCOPE_3_TOT_EVIC_INTEN_COV > 0
                            AND FUND_ELIGIBILITY = 'T' 
							then
                                cast
								(
									(
										case 
										when (NULLIF(mv_usd_total , 0) = 0) then (0) 
										else a.mv_usd / NULLIF(mv_usd_total, 0) end) * g.FUND_CARBON_EMISSIONS_SCOPE_3_TOT_EVIC_INTEN_COV as float)/ 100.0
                            when a.fund_share_class_id IS NULL
                             AND a.issuerid IS NOT NULL
                             and isnull(f.EVIC_USD_RECENT, 0) > 0
                             and f.EVIC_USD_RECENT is not null
                             and b.CARBON_EMISSIONS_SCOPE_3_TOTAL is not null

							then      
								(case when (NULLIF(mv_usd_total , 0) = 0) then (0) else a.mv_usd / NULLIF(mv_usd_total, 0) end) 
                            else 0 END)
						else 0 end ) as cov_adjusted_wt_SCOPE3_TCFD,

					/* Changes for Release 5.1 end */

                      ACTIVE_FF_SECTOR_EXPOSURE,
                      FUND_SFDR_ACTIVE_FF_SECTOR_EXPOSURE_COV,

					  /* Changes for Release 4 start */
					  b.HUMAN_RGTS_POL,
					  c.FUND_SFDR_HUMAN_RGTS_POL,
					  c.FUND_SFDR_HUMAN_RGTS_POL_COV,

					  b.CARBON_REDUCT_INITIATIVES_PA,
					  c.FUND_CARBON_EMISSIONS_REDUCT_INITIATIVES,
					  c.FUND_CARBON_EMISSIONS_REDUCT_INITIATIVES_COV,

					  b.ENERGY_CONSUMP_INTEN_EUR,
					  b.NACE_SECTION_CODE,
					  c.FUND_SFDR_ENERGY_CONSUMP_INTEN_EUR_NACE_A,
					  c.FUND_SFDR_ENERGY_CONSUMP_INTEN_EUR_NACE_B,
					  c.FUND_SFDR_ENERGY_CONSUMP_INTEN_EUR_NACE_C,
					  c.FUND_SFDR_ENERGY_CONSUMP_INTEN_EUR_NACE_D,
					  c.FUND_SFDR_ENERGY_CONSUMP_INTEN_EUR_NACE_E,
					  c.FUND_SFDR_ENERGY_CONSUMP_INTEN_EUR_NACE_F,
					  c.FUND_SFDR_ENERGY_CONSUMP_INTEN_EUR_NACE_G,
					  c.FUND_SFDR_ENERGY_CONSUMP_INTEN_EUR_NACE_H,
					  c.FUND_SFDR_ENERGY_CONSUMP_INTEN_EUR_NACE_L,
					  
					  c.FUND_SFDR_ENERGY_CONSUMP_INTEN_EUR_COV,
					  c.FUND_SFDR_ENERGY_CONSUMP_INTEN_EUR_NACE_COV_A,
					  c.FUND_SFDR_ENERGY_CONSUMP_INTEN_EUR_NACE_COV_B,
					  c.FUND_SFDR_ENERGY_CONSUMP_INTEN_EUR_NACE_COV_C,
					  c.FUND_SFDR_ENERGY_CONSUMP_INTEN_EUR_NACE_COV_D,
					  c.FUND_SFDR_ENERGY_CONSUMP_INTEN_EUR_NACE_COV_E,
					  c.FUND_SFDR_ENERGY_CONSUMP_INTEN_EUR_NACE_COV_F,
					  c.FUND_SFDR_ENERGY_CONSUMP_INTEN_EUR_NACE_COV_G,
					  c.FUND_SFDR_ENERGY_CONSUMP_INTEN_EUR_NACE_COV_H,
					  c.FUND_SFDR_ENERGY_CONSUMP_INTEN_EUR_NACE_COV_L,

					  b.FEMALE_DIRECTORS_PCT,
					  c.FUND_SFDR_FEMALE_DIRECTORS_PCT,
					  c.FUND_SFDR_FEMALE_DIRECTORS_COV,					 

					  /* Changes for Release 4 end */

					  /* Changes for Release 5.1 start */
					  g.FUND_CARBON_EMISSIONS_SCOPE_3_TOT_EVIC_INTEN,
					  g.FUND_CARBON_EMISSIONS_SCOPE_3_TOT_EVIC_INTEN_COV,
					  /* Changes for Release 5.1 end */

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
                      a.FUND_ELIGIBILITY,
					  a.MV_GBP
                 from 
				 [ESG].[SOURCE_TABLE] a
                 left join [ESG].[DIR_SFDR] b on b.ISSUERID = a.ISSUERID and a.MSCI_AS_OF_DATE = b.AS_OF_DATE
                 left join [ESG].[CLTV_EUSUSTAINABLEFINANCE] c on a.MSCI_AS_OF_DATE     = c.AS_OF_DATE and a.FUND_SHARE_CLASS_ID = c.FUND_SHARE_CLASS_ID
                 left join [ESG].[SOURCE_TABLE_AUM] d on a.LegalEntity = d.LegalEntity and a.ServiceCategory = d.ServiceCategory and a.asset_group = d.asset_group and a.Date = d.Date
                 left join [ESG].[DIR_EUTAXONOMY] e on e.ISSUERID = a.ISSUERID and a.MSCI_AS_OF_DATE = e.AS_OF_DATE
                 left join [ESG].[DIR_CLIMATECHANGE] f on f.ISSUERID = a.ISSUERID and a.MSCI_AS_OF_DATE = f.AS_OF_DATE
                 LEFT JOIN [ESG].[CLTV_STDCOV_CLIMATECHANGE] g on a.MSCI_AS_OF_DATE = g.AS_OF_DATE and a.FUND_SHARE_CLASS_ID = g.FUND_SHARE_CLASS_ID
                 left join (select issuerid from [ESG].[DIR_GOVRATING] group by issuerid) as DG on a.issuerId = dg.issuerid   				
				) as a

	;with Results1
      as (select *,
				 (case
                      when ( NULLIF(Sum(cov_adjusted_ghg_intensity) OVER (partition by Date,LegalEntity,ServiceCategory,asset_group), 0) = 0 )
                      then (0)
                      else (cov_adjusted_ghg_intensity
							/ NULLIF(Sum(cov_adjusted_ghg_intensity) OVER (partition by Date,LegalEntity,ServiceCategory,asset_group), 0))
					  END) as normalized_ghg_intensity,

				  (case
                      when ( NULLIF(Sum(cov_Non_renewable_energy_SFDR) OVER (partition by Date,LegalEntity,ServiceCategory,asset_group), 0) = 0 )
                      then (0)
                      else ((cov_Non_renewable_energy_SFDR
								/ NULLIF(Sum(cov_Non_renewable_energy_SFDR) OVER (partition by Date,LegalEntity,ServiceCategory,asset_group), 0)))
					  END) as normalized_Non_renewable_energy_SFDR,

				  (case
                      when (nullif(sum(cov_adj_Unadjusted_gender_pay_gap_sfdr) over (partition by Date,LegalEntity,ServiceCategory,asset_group), 0) = 0 )
                      then (0)
                      else (cov_adj_Unadjusted_gender_pay_gap_sfdr
                  / nullif(sum(cov_adj_Unadjusted_gender_pay_gap_sfdr) over (partition by Date,LegalEntity,ServiceCategory,asset_group), 0))
					  END) as Norm_Unadjusted_gender_pay_gap_sfdr,

				 (case
                      when (nullif(sum(cov_adj_Board_of_Gender_diversity_ratio_sfdr) over (partition by Date,LegalEntity,ServiceCategory,asset_group), 0) = 0 )
                      then (0)
                      else (cov_adj_Board_of_Gender_diversity_ratio_sfdr
                  / nullif(sum(cov_adj_Board_of_Gender_diversity_ratio_sfdr) over (partition by Date,LegalEntity,ServiceCategory,asset_group), 0))
					  END) as Norm_Board_of_Gender_diversity_ratio_sfdr,

				(case
                      when (nullif(sum(cov_adj_Board_of_Gender_diversity_pct_sfdr) over (partition by Date,LegalEntity,ServiceCategory,asset_group), 0) = 0 )
                      then (0)
                      else (cov_adj_Board_of_Gender_diversity_pct_sfdr
                  / nullif(sum(cov_adj_Board_of_Gender_diversity_pct_sfdr) over (partition by Date,LegalEntity,ServiceCategory,asset_group), 0))
					  END) as Norm_Board_of_Gender_diversity_pct_sfdr,

				 (case
                      when (nullif(sum(cov_adj_EU_Taxonomy_Revenue_Alignment_sfdr) over (partition by Date,LegalEntity,ServiceCategory,asset_group), 0) = 0 )
                      then (0)
                      else (cov_adj_EU_Taxonomy_Revenue_Alignment_sfdr
                  / nullif(sum(cov_adj_EU_Taxonomy_Revenue_Alignment_sfdr) over (partition by Date,LegalEntity,ServiceCategory,asset_group), 0))
					  END) as Norm_EU_Taxonomy_Revenue_Alignment_sfdr,

				 (case
                      when (nullif(sum(cov_adj_GHG_intensity_Sovereign) over (partition by Date,LegalEntity,ServiceCategory,asset_group), 0) = 0 )
                      then (0)
                      else (cov_adj_GHG_intensity_Sovereign
				  /nullif(sum(cov_adj_GHG_intensity_Sovereign) over (partition by Date,LegalEntity,ServiceCategory,asset_group), 0))
					  END) as Norm_GHG_intensity_Sovereign,

				  (case
                      when (NULLIF(Sum(cov_adjusted_avg_carbon_intensity_scope12_TCFD) OVER (partition by Date,LegalEntity,ServiceCategory,asset_group), 0) = 0 )
                      then (0)
                      else (cov_adjusted_avg_carbon_intensity_scope12_TCFD
                  / NULLIF(Sum(cov_adjusted_avg_carbon_intensity_scope12_TCFD) OVER (partition by Date,LegalEntity,ServiceCategory,asset_group), 0))
					  END) as normalized_weighted_average_carbon_intensity_scope12_TCFD,

					/* Changes for Release 4 start */
				  (case
                      when (NULLIF(Sum(cov_ENERGY_CONSUMP_INTEN_NACE_A) OVER (partition by Date,LegalEntity,ServiceCategory,asset_group), 0) = 0 )
                      then (0)
                      else (cov_ENERGY_CONSUMP_INTEN_NACE_A
                  / NULLIF(Sum(cov_ENERGY_CONSUMP_INTEN_NACE_A) OVER (partition by Date,LegalEntity,ServiceCategory,asset_group), 0))
					  END) as normalized_cov_ENERGY_CONSUMP_INTEN_NACE_A,

					(case
                      when (NULLIF(Sum(cov_ENERGY_CONSUMP_INTEN_NACE_B) OVER (partition by Date,LegalEntity,ServiceCategory,asset_group), 0) = 0 )
                      then (0)
                      else (cov_ENERGY_CONSUMP_INTEN_NACE_B
                  / NULLIF(Sum(cov_ENERGY_CONSUMP_INTEN_NACE_B) OVER (partition by Date,LegalEntity,ServiceCategory,asset_group), 0))
					  END) as normalized_cov_ENERGY_CONSUMP_INTEN_NACE_B,

					(case
                      when (NULLIF(Sum(cov_ENERGY_CONSUMP_INTEN_NACE_C) OVER (partition by Date,LegalEntity,ServiceCategory,asset_group), 0) = 0 )
                      then (0)
                      else (cov_ENERGY_CONSUMP_INTEN_NACE_C
                  / NULLIF(Sum(cov_ENERGY_CONSUMP_INTEN_NACE_C) OVER (partition by Date,LegalEntity,ServiceCategory,asset_group), 0))
					  END) as normalized_cov_ENERGY_CONSUMP_INTEN_NACE_C,

				  	(case
                      when (NULLIF(Sum(cov_ENERGY_CONSUMP_INTEN_NACE_D) OVER (partition by Date,LegalEntity,ServiceCategory,asset_group), 0) = 0 )
                      then (0)
                      else (cov_ENERGY_CONSUMP_INTEN_NACE_D
                  / NULLIF(Sum(cov_ENERGY_CONSUMP_INTEN_NACE_D) OVER (partition by Date,LegalEntity,ServiceCategory,asset_group), 0))
					  END) as normalized_cov_ENERGY_CONSUMP_INTEN_NACE_D,

					(case
                      when (NULLIF(Sum(cov_ENERGY_CONSUMP_INTEN_NACE_E) OVER (partition by Date,LegalEntity,ServiceCategory,asset_group), 0) = 0 )
                      then (0)
                      else (cov_ENERGY_CONSUMP_INTEN_NACE_E
                  / NULLIF(Sum(cov_ENERGY_CONSUMP_INTEN_NACE_E) OVER (partition by Date,LegalEntity,ServiceCategory,asset_group), 0))
					  END) as normalized_cov_ENERGY_CONSUMP_INTEN_NACE_E,

					(case
                      when (NULLIF(Sum(cov_ENERGY_CONSUMP_INTEN_NACE_F) OVER (partition by Date,LegalEntity,ServiceCategory,asset_group), 0) = 0 )
                      then (0)
                      else (cov_ENERGY_CONSUMP_INTEN_NACE_F
                  / NULLIF(Sum(cov_ENERGY_CONSUMP_INTEN_NACE_F) OVER (partition by Date,LegalEntity,ServiceCategory,asset_group), 0))
					  END) as normalized_cov_ENERGY_CONSUMP_INTEN_NACE_F,

					(case
                      when (NULLIF(Sum(cov_ENERGY_CONSUMP_INTEN_NACE_G) OVER (partition by Date,LegalEntity,ServiceCategory,asset_group), 0) = 0 )
                      then (0)
                      else (cov_ENERGY_CONSUMP_INTEN_NACE_G
                  / NULLIF(Sum(cov_ENERGY_CONSUMP_INTEN_NACE_G) OVER (partition by Date,LegalEntity,ServiceCategory,asset_group), 0))
					  END) as normalized_cov_ENERGY_CONSUMP_INTEN_NACE_G,

					(case
                      when (NULLIF(Sum(cov_ENERGY_CONSUMP_INTEN_NACE_H) OVER (partition by Date,LegalEntity,ServiceCategory,asset_group), 0) = 0 )
                      then (0)
                      else (cov_ENERGY_CONSUMP_INTEN_NACE_H
                  / NULLIF(Sum(cov_ENERGY_CONSUMP_INTEN_NACE_H) OVER (partition by Date,LegalEntity,ServiceCategory,asset_group), 0))
					  END) as normalized_cov_ENERGY_CONSUMP_INTEN_NACE_H,

					(case
                      when (NULLIF(Sum(cov_ENERGY_CONSUMP_INTEN_NACE_L) OVER (partition by Date,LegalEntity,ServiceCategory,asset_group), 0) = 0 )
                      then (0)
                      else (cov_ENERGY_CONSUMP_INTEN_NACE_L
                  / NULLIF(Sum(cov_ENERGY_CONSUMP_INTEN_NACE_L) OVER (partition by Date,LegalEntity,ServiceCategory,asset_group), 0))
					  END) as normalized_cov_ENERGY_CONSUMP_INTEN_NACE_L
					
					/* Changes for Release 4 end */
            from #temp_cov_adj_wt_all)

    ---- The calculated data gets pushed into Factor_Scope1_SWE_Discretionary_Portfolio_All table.
	
    select *,
           (Scope1 + Scope2 + Scope3) as Total_GHG_emissions_SFDR,
		   (Scope3_TCFD + Scope12_TCFD) as Total_GHG_emissions_TCFD
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
                            else 0 end) * (normalized_weighted_average_carbon_intensity_scope12_TCFD) as Weighted_average_carbon_intensity_scope12_TCFD,
                      (case
                            when Security_type = 'DIRECT'
                             and ACTIVE_FF_SECTOR_EXPOSURE = 'yes' then 100
                            when Security_type = 'COLLECTIVE'
                             and isnull(FUND_SFDR_ACTIVE_FF_SECTOR_EXPOSURE_COV, 0) <> 0
                             and FUND_ELIGIBILITY = 'T' then FUND_SFDR_ACTIVE_FF_SECTOR_EXPOSURE
                            else 0 end) * (case when (aum = 0) then (0) else (mv_eur / aum) end) as ActiveinFFSector, 
                      case
                           when Security_type = 'DIRECT'
                            and (   EVIC_EUR > 0
                              and   EVIC_EUR IS NOT NULL)
                            and CARBON_EMISSIONS_SCOPE_1 is not null then
                      (CARBON_EMISSIONS_SCOPE_1 * MV_EUR) / (nullif(EVIC_EUR * 1000000, 0))
                           when Security_type = 'COLLECTIVE'
                            and FUND_SFDR_CARBON_FOOTPRINT_SCOPE_1_COV <> 0
                            and FUND_ELIGIBILITY = 'T' then
                      (FUND_SFDR_CARBON_FOOTPRINT_SCOPE_1 * MV_EUR) / 1000000
                           else 0 end as Scope1,
                      case
                           when Security_type = 'DIRECT'
                            and (   EVIC_USD_RECENT > 0
                              and   EVIC_USD_RECENT IS NOT NULL)
                            and CARBON_EMISSIONS_SCOPE_12 is not null then
                      (CARBON_EMISSIONS_SCOPE_12 * MV_USD) / (nullif(EVIC_USD_RECENT * 1000000, 0))
                           when Security_type = 'COLLECTIVE'
                            and FUND_SFDR_CARBON_FOOTPRINT_SCOPE_1_COV <> 0
                            and FUND_ELIGIBILITY = 'T' then
                      (FUND_FINANCED_CARBON_EMISSIONS * MV_USD) / 1000000
                           else 0 end as Scope12_TCFD,
                      case
                           when Security_type = 'DIRECT'
                            and (   EVIC_EUR > 0
                              and   EVIC_EUR IS NOT NULL)
                            and CARBON_EMISSIONS_SCOPE_2 is not null then
                      (CARBON_EMISSIONS_SCOPE_2 * MV_EUR) / (nullif(EVIC_EUR * 1000000, 0))
                           when Security_type = 'COLLECTIVE'
                            and FUND_SFDR_CARBON_FOOTPRINT_SCOPE_2_COV <> 0
                            and FUND_ELIGIBILITY = 'T' then
                      (FUND_SFDR_CARBON_FOOTPRINT_SCOPE_2 * MV_EUR) / 1000000
                           else 0 end as Scope2,
                      case
                           when Security_type = 'DIRECT'
                            and (   EVIC_EUR > 0
                              and   EVIC_EUR IS NOT NULL)
                            and CARBON_EMISSIONS_SCOPE_3_total is not null then
                      (CARBON_EMISSIONS_SCOPE_3_total * MV_EUR) / (nullif(EVIC_EUR * 1000000, 0))
                           when Security_type = 'COLLECTIVE'
                            and FUND_SFDR_CARBON_FOOTPRINT_SCOPE_3_COV <> 0
                            and FUND_ELIGIBILITY = 'T' then
                      (FUND_SFDR_CARBON_FOOTPRINT_SCOPE_3 * MV_EUR) / 1000000
                           else 0 end as Scope3,
                      (case
                            when Security_type = 'DIRECT'
                             and OPS_PROT_BIODIV_CONTROVS = 'Yes' then 100
                            when Security_type = 'COLLECTIVE'
                             and isnull(FUND_SFDR_OPS_PROT_BIODIV_CONTROVS_COV, 0) <> 0
                             and FUND_ELIGIBILITY = 'T' then
                                FUND_SFDR_OPS_PROT_BIODIV_CONTROVS
                            else 0 end) * (case when (aum = 0) then (0) else (mv_eur / aum) end) as Neg_afct_biodiversity_sen_areas_Act_SFDR,
                      (case
                            when Security_type = 'DIRECT'
                             and (   EVIC_EUR > 0
                               and   EVIC_EUR IS NOT NULL)
                             and WATER_EM_EFF_METRIC_TONS is not null then
                      ((WATER_EM_EFF_METRIC_TONS) * MV_EUR) / (nullif(EVIC_EUR * 1000000, 0)) -- a.MV_EUR) / (nullif(EVIC_EUR * 1000000, 0))
                            when Security_type = 'COLLECTIVE'
                             and FUND_SFDR_WATER_EM_EFF_METRIC_TONS_COV <> 0
                             and FUND_ELIGIBILITY = 'T' then
                      (FUND_SFDR_WATER_EM_EFF_METRIC_TONS) * MV_EUR / 1000000
                            else 0 end) as Emissions_to_water_SFDR,
                      (case
                            when Security_type = 'DIRECT'
                             and PCT_NONRENEW_CONSUMP_PROD IS NOT NULL
                      then      PCT_NONRENEW_CONSUMP_PROD
                            when Security_type = 'COLLECTIVE'
                             and isnull(FUND_SFDR_PCT_NONRENEW_CONSUMP_PROD_COV, 0) <> 0
                             and FUND_ELIGIBILITY = 'T' then FUND_SFDR_PCT_NONRENEW_CONSUMP_PROD
                            else 0 end) * (normalized_Non_renewable_energy_SFDR) as Non_renewable_energy_share_SFDR,
                      (case
                            when Security_type = 'DIRECT'
                             and (   EVIC_EUR > 0
                               and   EVIC_EUR IS NOT NULL)
                             and HAZARD_WASTE_METRIC_TON is not null then
                      (HAZARD_WASTE_METRIC_TON * MV_EUR) / (nullif(EVIC_EUR * 1000000, 0))
                            when Security_type = 'COLLECTIVE'
                             and FUND_SFDR_HAZARD_WASTE_METRIC_TON_COV <> 0
                             and FUND_ELIGIBILITY = 'T' then
                      (FUND_SFDR_HAZARD_WASTE_METRIC_TON * MV_EUR) / 1000000
                            else 0 end) as Hazardous_waste_ratio_SFDR,
                      (case
                            when Security_type = 'DIRECT'
                             and OVERALL_FLAG = 'Red' then 100
                            when Security_type = 'COLLECTIVE'
                             and isnull(FUND_SFDR_VIOLATIONS_UNGC_OECD_COV, 0) <> 0
                             and FUND_ELIGIBILITY = 'T' then FUND_SFDR_VIOLATIONS_UNGC_OECD
                            else 0 end) * (case when (aum = 0) then (0) else (mv_eur / aum) end) as Violation_of_UN_Global_SFDR,
                      (case
                            when Security_type = 'DIRECT'
                             and MECH_UN_GLOBAL_COMPACT = 'No evidence' then 100
                            when Security_type = 'COLLECTIVE'
                             and isnull(FUND_SFDR_MECH_UN_GLOBAL_COMPACT_COV, 0) <> 0
                             and FUND_ELIGIBILITY = 'T' then FUND_SFDR_MECH_UN_GLOBAL_COMPACT
                            else 0 end) * (case when (aum = 0) then (0) else (mv_eur / aum) end) as Mech_un_global_compact_sfdr,
                      (case
                            when Security_type = 'DIRECT'
                             and GENDER_PAY_GAP_RATIO IS NOT NULL then GENDER_PAY_GAP_RATIO
                            when Security_type = 'COLLECTIVE'
                             and isnull(FUND_SFDR_GENDER_PAY_GAP_RATIO_COV, 0) <> 0
                             and FUND_ELIGIBILITY = 'T' then FUND_SFDR_GENDER_PAY_GAP_RATIO
                            else 0 end) * (Norm_Unadjusted_gender_pay_gap_sfdr) as Unadjusted_gender_pay_gap_sfdr,
					
					 (case
                            when Security_type = 'DIRECT'
                             and FM_BOARD_RATIO IS NOT NULL then FM_BOARD_RATIO
                            when Security_type = 'COLLECTIVE'
                             and isnull(FUND_SFDR_FM_BOARD_RATIO_COV, 0) <> 0
                             and FUND_ELIGIBILITY = 'T' then FUND_SFDR_FM_BOARD_RATIO
                            else 0 end) * (Norm_Board_of_Gender_diversity_ratio_sfdr) as Board_of_Gender_diversity_ratio_sfdr,
					
					(case
                            when Security_type = 'DIRECT'
                             and FEMALE_DIRECTORS_PCT IS NOT NULL then FEMALE_DIRECTORS_PCT
                            when Security_type = 'COLLECTIVE'
                             and isnull(FUND_SFDR_FEMALE_DIRECTORS_COV, 0) <> 0
                             and FUND_ELIGIBILITY = 'T' then FUND_SFDR_FEMALE_DIRECTORS_PCT
                            else 0 end) * (Norm_Board_of_Gender_diversity_pct_sfdr) as Board_of_Gender_diversity_pct_sfdr ,
                   (case
                            when Security_type = 'DIRECT'
                             and CONTRO_WEAP_CBLMBW_ANYTIE = 'Yes' then 100
                            when Security_type = 'COLLECTIVE'
                             and isnull(FUND_SFDR_CONTRO_WEAP_CBLMBW_ANYTIE_COV, 0) <> 0
                             and FUND_ELIGIBILITY = 'T' then FUND_SFDR_CONTRO_WEAP_CBLMBW_ANYTIE
                            else 0 end) * (case when (aum = 0) then (0) else (mv_eur / aum) end) as Exp_to_controversial_weapons_SFDR,
                      (case
                            when Security_type = 'DIRECT'
                             and EST_EU_TAXONOMY_MAX_REV is not null then EST_EU_TAXONOMY_MAX_REV
                            when Security_type = 'COLLECTIVE'
                             and FUND_REV_EXP_EST_EU_TAXONOMY_MAX_REV_COV <> 0
                             and FUND_ELIGIBILITY = 'T'
                      then      FUND_REV_EXP_EST_EU_TAXONOMY_MAX_REV
                            else 0 end) * (case when (aum = 0) then (0) else (mv_eur / aum) end) as EU_Taxonomy_Revenue_Alignment_sfdr,
                      (case
                            when Security_type = 'DIRECT'
                             and CTRY_GHG_INTEN_GDP_EUR is not null
                             and issovereign is not null then CTRY_GHG_INTEN_GDP_EUR
                            when Security_type = 'COLLECTIVE'
                             and isnull(FUND_SFDR_CTRY_GHG_INTEN_GDP_EUR_COV, 0) <> 0
                             and FUND_ELIGIBILITY = 'T' then FUND_SFDR_CTRY_GHG_INTEN_GDP_EUR
                            else 0 end) * (Norm_GHG_intensity_Sovereign) as GHG_intensity_Sovereign,

							/* Changes for Release 4 start */
					(case 
					when (date >'2023-01-01') 
					then 
					(
					(case
                            when Security_type = 'DIRECT'
                             and HUMAN_RGTS_POL = 'Not Disclosed' then 100
                            when Security_type = 'COLLECTIVE'
                             and isnull(FUND_SFDR_HUMAN_RGTS_POL_COV, 0) <> 0
                             and FUND_ELIGIBILITY = 'T' then FUND_SFDR_HUMAN_RGTS_POL
                            else 0 end) * (case when (aum = 0) then (0) else (mv_eur / aum) end)) else null end ) as HUMAN_RGTS_POLICY,
					(case 
					when (date >'2023-01-01') 
					then 
					(
					(case
                            when Security_type = 'DIRECT'
                             and CARBON_REDUCT_INITIATIVES_PA = 'No' then 100
                            when Security_type = 'COLLECTIVE'
                             and isnull(FUND_CARBON_EMISSIONS_REDUCT_INITIATIVES_COV, 0) <> 0
                             and FUND_ELIGIBILITY = 'T' then FUND_CARBON_EMISSIONS_REDUCT_INITIATIVES
                            else 0 end) * (case when (aum = 0) then (0) else (mv_eur / aum) end)) else null end) as CARBON_REDUCT_INITIATIVES,
							(case 
					when (date >'2023-01-01') 
					then 
					(
					(case
                            when Security_type = 'DIRECT'
                             and ENERGY_CONSUMP_INTEN_EUR  IS NOT NULL AND NACE_SECTION_CODE = 'A'
                      then      ENERGY_CONSUMP_INTEN_EUR 
                            when Security_type = 'COLLECTIVE'
                             and isnull(FUND_SFDR_ENERGY_CONSUMP_INTEN_EUR_NACE_COV_A, 0) <> 0
                             and FUND_ELIGIBILITY = 'T' then FUND_SFDR_ENERGY_CONSUMP_INTEN_EUR_NACE_A
                            else 0 end) * (normalized_cov_ENERGY_CONSUMP_INTEN_NACE_A)) else null end) as ENERGY_CONSUMP_INTEN_NACE_A,

					(case 
					when (date >'2023-01-01') 
					then 
					(
					(case
                            when Security_type = 'DIRECT'
                             and ENERGY_CONSUMP_INTEN_EUR  IS NOT NULL AND NACE_SECTION_CODE = 'B'
                      then      ENERGY_CONSUMP_INTEN_EUR 
                            when Security_type = 'COLLECTIVE'
                             and isnull(FUND_SFDR_ENERGY_CONSUMP_INTEN_EUR_NACE_COV_B, 0) <> 0
                             and FUND_ELIGIBILITY = 'T' then FUND_SFDR_ENERGY_CONSUMP_INTEN_EUR_NACE_B
                            else 0 end) * (normalized_cov_ENERGY_CONSUMP_INTEN_NACE_B)) else null end) as ENERGY_CONSUMP_INTEN_NACE_B,

					(case 
					when (date >'2023-01-01') 
					then 
					(
					(case
                            when Security_type = 'DIRECT'
                             and ENERGY_CONSUMP_INTEN_EUR  IS NOT NULL AND NACE_SECTION_CODE = 'C'
                      then      ENERGY_CONSUMP_INTEN_EUR 
                            when Security_type = 'COLLECTIVE'
                             and isnull(FUND_SFDR_ENERGY_CONSUMP_INTEN_EUR_NACE_COV_C, 0) <> 0
                             and FUND_ELIGIBILITY = 'T' then FUND_SFDR_ENERGY_CONSUMP_INTEN_EUR_NACE_C
                            else 0 end) * (normalized_cov_ENERGY_CONSUMP_INTEN_NACE_C)) else null end) as ENERGY_CONSUMP_INTEN_NACE_C,

					(case 
					when (date >'2023-01-01') 
					then 
					(
					(case
                            when Security_type = 'DIRECT'
                             and ENERGY_CONSUMP_INTEN_EUR  IS NOT NULL AND NACE_SECTION_CODE = 'D'
                      then      ENERGY_CONSUMP_INTEN_EUR 
                            when Security_type = 'COLLECTIVE'
                             and isnull(FUND_SFDR_ENERGY_CONSUMP_INTEN_EUR_NACE_COV_D, 0) <> 0
                             and FUND_ELIGIBILITY = 'T' then FUND_SFDR_ENERGY_CONSUMP_INTEN_EUR_NACE_D
                            else 0 end) * (normalized_cov_ENERGY_CONSUMP_INTEN_NACE_D)) else null end) as ENERGY_CONSUMP_INTEN_NACE_D,

					(case 
					when (date >'2023-01-01') 
					then 
					(
					(case
                            when Security_type = 'DIRECT'
                             and ENERGY_CONSUMP_INTEN_EUR  IS NOT NULL AND NACE_SECTION_CODE = 'E'
                      then      ENERGY_CONSUMP_INTEN_EUR 
                            when Security_type = 'COLLECTIVE'
                             and isnull(FUND_SFDR_ENERGY_CONSUMP_INTEN_EUR_NACE_COV_E, 0) <> 0
                             and FUND_ELIGIBILITY = 'T' then FUND_SFDR_ENERGY_CONSUMP_INTEN_EUR_NACE_E
                            else 0 end) * (normalized_cov_ENERGY_CONSUMP_INTEN_NACE_E)) else null end) as ENERGY_CONSUMP_INTEN_NACE_E,

					(case 
					when (date >'2023-01-01') 
					then 
					(
					(case
                            when Security_type = 'DIRECT'
                             and ENERGY_CONSUMP_INTEN_EUR  IS NOT NULL AND NACE_SECTION_CODE = 'F'
                      then      ENERGY_CONSUMP_INTEN_EUR 
                            when Security_type = 'COLLECTIVE'
                             and isnull(FUND_SFDR_ENERGY_CONSUMP_INTEN_EUR_NACE_COV_F, 0) <> 0
                             and FUND_ELIGIBILITY = 'T' then FUND_SFDR_ENERGY_CONSUMP_INTEN_EUR_NACE_F
                            else 0 end) * (normalized_cov_ENERGY_CONSUMP_INTEN_NACE_F)) else null end) as ENERGY_CONSUMP_INTEN_NACE_F,

					(case 
					when (date >'2023-01-01') 
					then 
					((case
                            when Security_type = 'DIRECT'
                             and ENERGY_CONSUMP_INTEN_EUR  IS NOT NULL AND NACE_SECTION_CODE = 'G'
                      then      ENERGY_CONSUMP_INTEN_EUR 
                            when Security_type = 'COLLECTIVE'
                             and isnull(FUND_SFDR_ENERGY_CONSUMP_INTEN_EUR_NACE_COV_G, 0) <> 0
                             and FUND_ELIGIBILITY = 'T' then FUND_SFDR_ENERGY_CONSUMP_INTEN_EUR_NACE_G
                            else 0 end) * (normalized_cov_ENERGY_CONSUMP_INTEN_NACE_G)) else null end) as ENERGY_CONSUMP_INTEN_NACE_G,

					(case 
					when (date >'2023-01-01') 
					then 
					((case
                            when Security_type = 'DIRECT'
                             and ENERGY_CONSUMP_INTEN_EUR  IS NOT NULL AND NACE_SECTION_CODE = 'H'
                      then      ENERGY_CONSUMP_INTEN_EUR 
                            when Security_type = 'COLLECTIVE'
                             and isnull(FUND_SFDR_ENERGY_CONSUMP_INTEN_EUR_NACE_COV_H, 0) <> 0
                             and FUND_ELIGIBILITY = 'T' then FUND_SFDR_ENERGY_CONSUMP_INTEN_EUR_NACE_H
                            else 0 end) * (normalized_cov_ENERGY_CONSUMP_INTEN_NACE_H)) else null end) as ENERGY_CONSUMP_INTEN_NACE_H,

					(case 
					when (date >'2023-01-01') 
					then 
					((case
                            when Security_type = 'DIRECT'
                             and ENERGY_CONSUMP_INTEN_EUR  IS NOT NULL AND NACE_SECTION_CODE = 'L'
                      then      ENERGY_CONSUMP_INTEN_EUR 
                            when Security_type = 'COLLECTIVE'
                             and isnull(FUND_SFDR_ENERGY_CONSUMP_INTEN_EUR_NACE_COV_L, 0) <> 0
                             and FUND_ELIGIBILITY = 'T' then FUND_SFDR_ENERGY_CONSUMP_INTEN_EUR_NACE_L
                            else 0 end) * (normalized_cov_ENERGY_CONSUMP_INTEN_NACE_L)) else null end) as ENERGY_CONSUMP_INTEN_NACE_L,

					/* Changes for Release 4 end */

					/* Changes for Release 5.1 start */
					(case
					when (date > '2023-03-16')
					then
					(case
                           when Security_type = 'DIRECT'
                            and (   EVIC_USD_RECENT > 0
                            and   EVIC_USD_RECENT IS NOT NULL)
                            and CARBON_EMISSIONS_SCOPE_3_TOTAL is not null then
                      (CARBON_EMISSIONS_SCOPE_3_TOTAL * MV_USD) / (nullif(EVIC_USD_RECENT * 1000000, 0))
                           when Security_type = 'COLLECTIVE'
                            and FUND_CARBON_EMISSIONS_SCOPE_3_TOT_EVIC_INTEN_COV <> 0
                            and FUND_ELIGIBILITY = 'T' then
                      (FUND_CARBON_EMISSIONS_SCOPE_3_TOT_EVIC_INTEN * MV_USD) / 1000000
                           else 0 end)
					else 0 end) as Scope3_TCFD

				 /* Changes for Release 5.1 end */

                 FROM Results1) as CarbonfootPrint_derived

	INSERT INTO [ESG].[TCFD_LE_SERVICE_LOG] VALUES (GETDATE(),'usp_Load_TCFD_LE_Service_SUM_Calculations','Before populating [ESG].[TCFD_LE_SERVICE_SUM] for ' + @reporting_group) 

     ----From Factor_Scope1_SWE_Discretionary_Portfolio_All the data moves to TCFD_LE_Service_SUM 
	INSERT INTO [ESG].[ESG].[TCFD_LE_SERVICE_SUM] 
				(				
				   [DATE]
				  ,[MSCI_AS_OF_DATE]
				  ,[Legal_Entity]
				  ,[DistinctAsset]
				  ,[TotalClients]
				  ,[TotalPortfolio]
				  ,[MV_USD]
				  ,[MV_EUR]
				  ,[MV_GBP]
				  ,[Service]
				  ,[Service_Category]
				  ,[GHG_SCOPE_1]
				  ,[GHG_SCOPE_1_COV]
				  ,[GHG_SCOPE_2]
				  ,[GHG_SCOPE_2_COV]
				  ,[GHG_SCOPE_3]
				  ,[GHG_SCOPE_3_COV]
				  ,[GHG_SCOPE_123]
				  ,[GHG_SCOPE_123_COV]
				  ,[GHG_Carbon_Footprint_USD]
				  ,[GHG_Carbon_Footprint_USD_COV]
				  ,[GHG_Intensity_EUR]
				  ,[GHG_Intensity_EUR_COV]
				  ,[ACTIVE_FF_SECTOR_EXPOSURE]
				  ,[ACTIVE_FF_SECTOR_EXPOSURE_COV]
				  ,[GHG_Carbon_Footprint_SFDR]
				  ,[GHG_Carbon_Footprint_COV_SFDR]
				  ,[GHG_Intensity_EUR_SFDR]
				  ,[GHG_Intensity_EUR_COV_SFDR]
				  ,[Non_renewable_energy_CP_share_SFDR]
				  ,[Non_renewable_energy_CP_share_COV_SFDR]
				  ,[Nor_Neg_afct_biodiversity_sen_areas_Act_SFDR]
				  ,[Nor_Neg_afct_biodiversity_sen_areas_Act_COV_SFDR]
				  ,[Emissionsto_water_SFDR]
				  ,[Emissionsto_water_COV_SFDR]
				  ,[Violation_of_UN_Global_SFDR]
				  ,[Violation_of_UN_Global_COV_SFDR]
				  ,[Hazardous_waste_ratio_SFDR]
				  ,[Hazardous_waste_COV_SFDR]
				  ,[Mech_un_global_compact_sfdr]
				  ,[Mech_un_global_compact_cov_sfdr]
				  ,[Unadjusted_gender_pay_gap_sfdr]
				  ,[Unadjusted_gender_pay_gap_cov_sfdr]
				  ,[Exp_to_controversial_weapons_SFDR]
				  ,[Exp_to_controversial_weapons_COV_SFDR]
				  ,[EU_Taxonomy_Revenue_Alignment_sfdr]
				  ,[EU_Taxonomy_Revenue_Alignment_COV_sfdr]
				  ,[GHG_intensity_Sovereign_SFDR]
				  ,[GHG_intensity_Sovereign_COV_SFDR]
				  ,[Carbon_Emissions_Scope_12_TCFD]
				  ,[Carbon_Emissions_Scope_12_COV_TCFD]
				  ,[Weighted_average_carbon_intensity_scope12_TCFD]
				  ,[Weighted_average_carbon_intensity_scope12_COV_TCFD]
				  ,[CARBON_FOOTPRINT_TCFD]
				  ,[HUMAN_RGTS_POLICY]
				  ,[FUND_SFDR_HUMAN_RGTS_POL_COV]
				  ,[CARBON_REDUCT_INITIATIVES]
				  ,[cov_CARBON_EMISSIONS_REDUCT_INITIATIVES]
				  ,[ENERGY_CONSUMP_INTEN_NACE_A]
				  ,[cov_ENERGY_CONSUMP_INTEN_NACE_A]
				  ,[ENERGY_CONSUMP_INTEN_NACE_B]
				  ,[cov_ENERGY_CONSUMP_INTEN_NACE_B]
				  ,[ENERGY_CONSUMP_INTEN_NACE_C]
				  ,[cov_ENERGY_CONSUMP_INTEN_NACE_C]
				  ,[ENERGY_CONSUMP_INTEN_NACE_D]
				  ,[cov_ENERGY_CONSUMP_INTEN_NACE_D]
				  ,[ENERGY_CONSUMP_INTEN_NACE_E]
				  ,[cov_ENERGY_CONSUMP_INTEN_NACE_E]
				  ,[ENERGY_CONSUMP_INTEN_NACE_F]
				  ,[cov_ENERGY_CONSUMP_INTEN_NACE_F]
				  ,[ENERGY_CONSUMP_INTEN_NACE_G]
				  ,[cov_ENERGY_CONSUMP_INTEN_NACE_G]
				  ,[ENERGY_CONSUMP_INTEN_NACE_H]
				  ,[cov_ENERGY_CONSUMP_INTEN_NACE_H]
				  ,[ENERGY_CONSUMP_INTEN_NACE_L]
				  ,[cov_ENERGY_CONSUMP_INTEN_NACE_L]
				  ,[cov_ENERGY_CONSUMP_INTENSITY]
				  ,[CLTV_SFDR_ART6_impact]
				  ,[CLTV_SFDR_ART8_impact]
				  ,[CLTV_SFDR_ART9_impact]
				  ,[cltv_art_6_8_9_mv_eur]
				  ,[sov_intensity_mv_gbp]
				  ,[GOVERNMENT_EU_SANCTIONS_COV]
				  ,[UNIQUE_SOV_SANCTIONS_COUNT]
				  ,[UNIQUE_SOV_SANCTIONS_PCT]
				  ,[SOV_EUSAC_MV_EUR]
				  ,[reporting_group]
				  ,[ASSET_GROUP]
				  ,[Board_of_Gender_diversity_ratio_sfdr]
				  ,[cov_Board_of_Gender_diversity_ratio_sfdr]
				  ,[Board_of_Gender_diversity_pct_sfdr]
				  ,[cov_Board_of_Gender_diversity_pct_sfdr]
				  ,[SFDR_ART6]
				  ,[SFDR_ART8]
				  ,[SFDR_ART9]
				  ,[Carbon_Emissions_Scope_3_TCFD]
				  ,[Carbon_Emissions_Scope_3_COV_TCFD]
				  ,[Carbon_Emissions_Scope_123_TCFD]
				)

					SELECT 
					A.date,
					A.[MSCI_AS_OF_DATE],
					LegalEntity,
					Count(distinct (AssetName)) as [DistinctAsset],
					Count(distinct (ClientReference)) as [TotalClients],
					Count(distinct (Portfolio)) as [TotalPortfolio],
					MV_USD_total as MV_USD,
					AUM as MV_EUR,
					MV_GBP_TOTAL as MV_GBP,
					'NA' as Service,
					ServiceCategory as [Service_Category],
					sum(scope1) as [GHG_SCOPE_1],
					sum(cov_adjusted_wt) * 100 as [GHG_SCOPE_1_COV],
					sum(scope2) as [GHG_SCOPE_2],
					sum(cov_adjusted_wt2) * 100 as [GHG_SCOPE_2_COV],
					sum(scope3) as [GHG_SCOPE_3],
					sum(cov_adjusted_wt3) * 100 as [GHG_SCOPE_3_COV],
					sum(Total_GHG_emissions_SFDR) as [GHG_SCOPE_123],
					sum(cov_adjusted_wt3) * 100 as [GHG_SCOPE_123_COV],
					NULL as [GHG_Carbon_Footprint_USD],
					NULL AS GHG_Carbon_Footprint_USD_COV,
					sum(GHG_Intensity_of_investee_companies_1) as [GHG_Intensity_EUR],
					sum(cov_adjusted_GHG_INTENSITY) * 100 as [GHG_Intensity_EUR_COV],
					sum(ActiveinFFSector) as ACTIVE_FF_SECTOR_EXPOSURE,
					sum(cov_adjusted_CompanyExposer_FF) * 100 as ACTIVE_FF_SECTOR_EXPOSURE_COV,
					(case 
					when (AUM = 0) then (0)
					else (sum(Total_GHG_emissions_SFDR) * 1000000 / (AUM)) end ) as [GHG_Carbon_Footprint_SFDR],
					(case when sum(cov_adjusted_wt) < sum(cov_adjusted_wt2) then     case when sum(cov_adjusted_wt) < sum(cov_adjusted_wt3) 
					then sum(cov_adjusted_wt) else sum(cov_adjusted_wt3) end when sum(cov_adjusted_wt2) < sum(cov_adjusted_wt3) 
					then sum(cov_adjusted_wt2) else sum(cov_adjusted_wt3) end) * 100 as [GHG_Carbon_Footprint_COV_SFDR],
					sum(GHG_Intensity_of_investee_companies_1) as [GHG_Intensity_EUR_SFDR],
					sum(cov_adjusted_GHG_INTENSITY) * 100 as [GHG_Intensity_EUR_COV_SFDR],
					sum(Non_renewable_energy_share_SFDR) as Non_renewable_energy_CP_share_SFDR,
					sum(cov_Non_renewable_energy_SFDR) * 100 as Non_renewable_energy_CP_share_COV_SFDR,
					sum(Neg_afct_biodiversity_sen_areas_Act_SFDR) as Nor_Neg_afct_biodiversity_sen_areas_Act_SFDR,
					sum(cov_Neg_afct_biodiversity_sen_areas_Act_SFDR) * 100 as Nor_Neg_afct_biodiversity_sen_areas_Act_COV_SFDR,
					(case 
					when (AUM = 0) then (0)
					else (sum(Emissions_to_water_SFDR) * 1000000 / (AUM)) end ) as Emissionsto_water_SFDR,
					sum(cov_adj_Emissions_to_water_SFDR) * 100 as Emissionsto_water_COV_SFDR,

					sum(Violation_of_UN_Global_SFDR) as Violation_of_UN_Global_SFDR,
					sum(cov_adj_Violation_of_UN_Global_SFDR) * 100 as Violation_of_UN_Global_COV_SFDR,

					(case 
					when (AUM = 0) then (0)
					else (sum(Hazardous_waste_ratio_SFDR) * 1000000 / (AUM)) end ) as Hazardous_waste_ratio_SFDR,
					sum(cov_adj_Hazardous_waste_ratio_SFDR) * 100 as Hazardous_waste_COV_SFDR,

					sum(Mech_un_global_compact_sfdr) as Mech_un_global_compact_sfdr,
					sum(cov_adj_Mech_un_global_compact_sfdr) * 100 as Mech_un_global_compact_cov_sfdr,

					sum(Unadjusted_gender_pay_gap_sfdr) as Unadjusted_gender_pay_gap_sfdr,
					sum(cov_adj_Unadjusted_gender_pay_gap_sfdr) * 100 as Unadjusted_gender_pay_gap_cov_sfdr,
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
					(case 
					when (MV_USD_TOTAL = 0) then (0)
					else ((SUM(Scope12_TCFD) * 1000000) / MV_USD_TOTAL) end ) as CARBON_FOOTPRINT_TCFD,

					sum(HUMAN_RGTS_POLICY) as HUMAN_RGTS_POLICY,
					sum(cov_SFDR_HUMAN_RGTS_POL) * 100 as FUND_SFDR_HUMAN_RGTS_POL_COV,

					sum(CARBON_REDUCT_INITIATIVES) as CARBON_REDUCT_INITIATIVES,
					sum(cov_CARBON_EMISSIONS_REDUCT_INITIATIVES) * 100 as  cov_CARBON_EMISSIONS_REDUCT_INITIATIVES,

					sum(ENERGY_CONSUMP_INTEN_NACE_A) as ENERGY_CONSUMP_INTEN_NACE_A,
					sum(cov_ENERGY_CONSUMP_INTEN_NACE_A) * 100 as  normalized_cov_ENERGY_CONSUMP_INTEN_NACE_A,

					sum(ENERGY_CONSUMP_INTEN_NACE_B) as ENERGY_CONSUMP_INTEN_NACE_B,
					sum(cov_ENERGY_CONSUMP_INTEN_NACE_B) * 100 as  normalized_cov_ENERGY_CONSUMP_INTEN_NACE_B,

					sum(ENERGY_CONSUMP_INTEN_NACE_C) as ENERGY_CONSUMP_INTEN_NACE_C,
					sum(cov_ENERGY_CONSUMP_INTEN_NACE_C) * 100 as  normalized_cov_ENERGY_CONSUMP_INTEN_NACE_C,

					sum(ENERGY_CONSUMP_INTEN_NACE_D) as ENERGY_CONSUMP_INTEN_NACE_D,
					sum(cov_ENERGY_CONSUMP_INTEN_NACE_D) * 100 as  normalized_cov_ENERGY_CONSUMP_INTEN_NACE_D,

					sum(ENERGY_CONSUMP_INTEN_NACE_E) as ENERGY_CONSUMP_INTEN_NACE_E,
					sum(cov_ENERGY_CONSUMP_INTEN_NACE_E) * 100 as  normalized_cov_ENERGY_CONSUMP_INTEN_NACE_E,

					sum(ENERGY_CONSUMP_INTEN_NACE_F) as ENERGY_CONSUMP_INTEN_NACE_F,
					sum(cov_ENERGY_CONSUMP_INTEN_NACE_F) * 100 as  normalized_cov_ENERGY_CONSUMP_INTEN_NACE_F,

					sum(ENERGY_CONSUMP_INTEN_NACE_G) as ENERGY_CONSUMP_INTEN_NACE_G,
					sum(cov_ENERGY_CONSUMP_INTEN_NACE_G) * 100 as  normalized_cov_ENERGY_CONSUMP_INTEN_NACE_G,

					sum(ENERGY_CONSUMP_INTEN_NACE_H) as ENERGY_CONSUMP_INTEN_NACE_H,
					sum(cov_ENERGY_CONSUMP_INTEN_NACE_H) * 100 as  normalized_cov_ENERGY_CONSUMP_INTEN_NACE_H,

					sum(ENERGY_CONSUMP_INTEN_NACE_L) as ENERGY_CONSUMP_INTEN_NACE_L,
					sum(cov_ENERGY_CONSUMP_INTEN_NACE_L) * 100 as  normalized_cov_ENERGY_CONSUMP_INTEN_NACE_L,

					SUM(cov_ENERGY_CONSUMP_INTEN) * 100 as cov_ENERGY_CONSUMP_INTENSITY,

					sum(CLTV_SFDR_ART6) as CLTV_SFDR_ART6_impact,
					sum(CLTV_SFDR_ART8) as CLTV_SFDR_ART8_impact,
					sum(CLTV_SFDR_ART9) as CLTV_SFDR_ART9_impact,

					sum(cltv_mv_eur) as [cltv_art_6_8_9_mv_eur],
					sum(Sov_MV_GBP)  as [sov_intensity_mv_gbp],

					B.[GOVERNMENT_EU_SANCTIONS_COV] as [GOVERNMENT_EU_SANCTIONS_COV],
					B.[unique_sov_sanctions_count] as [UNIQUE_SOV_SANCTIONS_COUNT],
					B.[unique_sov_sanctions_pct] as [UNIQUE_SOV_SANCTIONS_PCT],
					B.MV_EUR as [SOV_EUSAC_MV_EUR],
					
					@reporting_group as reporting_group,
					A.asset_group,
					SUM(A.Board_of_Gender_diversity_ratio_sfdr) AS [Board_of_Gender_diversity_ratio_sfdr],
					SUM(A.cov_adj_Board_of_Gender_diversity_ratio_sfdr) * 100 as [cov_Board_of_Gender_diversity_ratio_sfdr],

					SUM(A.Board_of_Gender_diversity_pct_sfdr) AS [Board_of_Gender_diversity_pct_sfdr],
					SUM(A.cov_adj_Board_of_Gender_diversity_pct_sfdr) * 100 AS [cov_Board_of_Gender_diversity_pct_sfdr],

					SUM([SFDR_ART6]) AS [SFDR_ART6],
					SUM([SFDR_ART8]) AS [SFDR_ART8],
					SUM([SFDR_ART9]) AS [SFDR_ART9],

					SUM(Scope3_TCFD) AS [Carbon_Emissions_Scope_3_TCFD],
					SUM(cov_adjusted_wt_SCOPE3_TCFD) * 100 AS [Carbon_Emissions_Scope_3_COV_TCFD],
					SUM(Total_GHG_emissions_TCFD) AS [Carbon_Emissions_Scope_123_TCFD]
					
					FROM ESG.[Factors_All] A
					LEFT JOIN [ESG].[TCFD_LE_SERVICE_SUM_Sovereign_EU_SANCTIONS] B 
					ON A.ServiceCategory = B.[Service_Category] 
					and A.LegalEntity = B.Legal_Entity 
					AND A.date = B.DATE
					AND A.ASSET_GROUP = B.ASSET_GROUP

					group by 
					A.date,
					LegalEntity,
					ServiceCategory,
					A.[MSCI_AS_OF_DATE],
					MV_USD_total,
					MV_GBP_TOTAL,
					AUM,
					A.asset_group,
					B.[GOVERNMENT_EU_SANCTIONS_COV],
					B.[unique_sov_sanctions_count],
					B.[unique_sov_sanctions_pct],
					B.MV_EUR

	INSERT INTO [ESG].[TCFD_LE_SERVICE_LOG] VALUES (GETDATE(),'usp_Load_TCFD_LE_Service_SUM_Calculations','After populating [ESG].[ESG].[TCFD_LE_SERVICE_SUM] for ' + @reporting_group) 

	INSERT INTO [ESG].[GROUP_DRILL_DOWN_FACTORS]

				SELECT 
				date,
				[MSCI_AS_OF_DATE],
				[ISIN] as ISIN,
				[AssetName],
				LegalEntity as LegalEntity,
				ServiceCategory as [Service_Category],
				[ASSET_GROUP],
				[FUND_SHARE_CLASS_ID],
				[ISSUERID],
				MV_GBP_TOTAL as MV_GBP_TOTAL,
				SUM(MV_GBP) AS MV_GBP,
				AUM as MV_EUR_Total,
				SUM(MV_EUR) as MV_EUR,
				MV_USD_Total as MV_USD_Total,
				SUM(MV_USD) as MV_USD,
				 sum(scope1) as GHG_SCOPE_1
				,sum(cov_adjusted_wt) *100 as GHG_SCOPE_1_COV
				,sum(scope2) as GHG_SCOPE_2
				,sum(cov_adjusted_wt2)*100 as GHG_SCOPE_2_COV
				,sum(scope3) as GHG_SCOPE_3
				,sum(cov_adjusted_wt3)*100 as GHG_SCOPE_3_COV
				,sum(Total_GHG_emissions_SFDR) as [GHG_SCOPE_123]
				,sum(ActiveinFFSector) as ACTIVE_FF_SECTOR_EXPOSURE
				,sum(cov_adjusted_CompanyExposer_FF)*100 as ACTIVE_FF_SECTOR_EXPOSURE_COV
				,case 
				when (AUM = 0) then (0)
				else (sum(Total_GHG_emissions_SFDR) * 1000000 / (AUM)) end  as [GHG_Carbon_Footprint_SFDR],
				(case when sum(cov_adjusted_wt) < sum(cov_adjusted_wt2) then     case when sum(cov_adjusted_wt) < sum(cov_adjusted_wt3) 
				then sum(cov_adjusted_wt) else sum(cov_adjusted_wt3) end when sum(cov_adjusted_wt2) < sum(cov_adjusted_wt3) 
				then sum(cov_adjusted_wt2) else sum(cov_adjusted_wt3) end) * 100 as [GHG_Carbon_Footprint_COV_SFDR],
				sum(GHG_Intensity_of_investee_companies_1) as [GHG_Intensity_EUR_SFDR],
				sum(cov_adjusted_GHG_INTENSITY)*100 as [GHG_Intensity_EUR_COV_SFDR],
				sum(Non_renewable_energy_share_SFDR) as Non_renewable_energy_CP_share_SFDR,
				sum(cov_Non_renewable_energy_SFDR)*100 as Non_renewable_energy_CP_share_COV_SFDR,
				sum(Neg_afct_biodiversity_sen_areas_Act_SFDR) as Nor_Neg_afct_biodiversity_sen_areas_Act_SFDR,
				sum(cov_Neg_afct_biodiversity_sen_areas_Act_SFDR)*100 as Nor_Neg_afct_biodiversity_sen_areas_Act_COV_SFDR,
				(case 
				when (AUM = 0) then (0)
				else (sum(Emissions_to_water_SFDR) * 1000000 / (AUM)) end ) as Emissionsto_water_SFDR,
				sum(cov_adj_Emissions_to_water_SFDR) * 100 as Emissionsto_water_COV_SFDR,
				(case 
				when (AUM = 0) then (0)
				else (sum(Hazardous_waste_ratio_SFDR) * 1000000 / (AUM)) end ) as Hazardous_waste_ratio_SFDR,
				sum(cov_adj_Hazardous_waste_ratio_SFDR)*100 as Hazardous_waste_COV_SFDR,
				sum(Violation_of_UN_Global_SFDR) as Violation_of_UN_Global_SFDR,
				sum(cov_adj_Violation_of_UN_Global_SFDR)*100 as Violation_of_UN_Global_COV_SFDR,
				sum(Mech_un_global_compact_sfdr) as Mech_un_global_compact_sfdr,
				sum(cov_adj_Mech_un_global_compact_sfdr)*100 as Mech_un_global_compact_cov_sfdr,

				sum(Unadjusted_gender_pay_gap_sfdr) as Unadjusted_gender_pay_gap_sfdr,
				sum(cov_adj_Unadjusted_gender_pay_gap_sfdr)*100 as Unadjusted_gender_pay_gap_cov_sfdr,
				sum(Exp_to_controversial_weapons_SFDR) as Exp_to_controversial_weapons_SFDR,
				sum(cov_adj_Exp_to_controversial_weapons_SFDR)*100 as Exp_to_controversial_weapons_SFDR,
				sum(EU_Taxonomy_Revenue_Alignment_sfdr) as EU_Taxonomy_Revenue_Alignment_sfdr,
				sum(cov_adj_EU_Taxonomy_Revenue_Alignment_sfdr)*100 as EU_Taxonomy_Revenue_Alignment_COV_sfdr,
				sum(GHG_intensity_Sovereign) as GHG_intensity_Sovereign_SFDR,
				sum(cov_adj_GHG_intensity_Sovereign)*100 as GHG_intensity_Sovereign_COV_SFDR,
				sum(Scope12_TCFD) as Carbon_Emissions_Scope_12_TCFD,
				sum(cov_adjusted_wt_SCOPE12_TCFD)*100 as Carbon_Emissions_Scope_12_COV_TCFD,
				sum(Weighted_average_carbon_intensity_scope12_TCFD) as Weighted_average_carbon_intensity_scope12_TCFD,
				sum(cov_adjusted_avg_carbon_intensity_scope12_TCFD)*100 as Weighted_average_carbon_intensity_scope12_COV_TCFD,
				case 
				when (MV_USD_TOTAL = 0) then (0)
				else ((SUM(Scope12_TCFD) * 1000000) / MV_USD_TOTAL) end  as CARBON_FOOTPRINT_TCFD,
				sum(HUMAN_RGTS_POLICY) as HUMAN_RGTS_POLICY,
				sum(cov_SFDR_HUMAN_RGTS_POL)*100 as FUND_SFDR_HUMAN_RGTS_POL_COV,
				sum(CARBON_REDUCT_INITIATIVES) as CARBON_REDUCT_INITIATIVES,
				sum(cov_CARBON_EMISSIONS_REDUCT_INITIATIVES)*100 as cov_CARBON_EMISSIONS_REDUCT_INITIATIVES,
				sum(ENERGY_CONSUMP_INTEN_NACE_A) as ENERGY_CONSUMP_INTEN_NACE_A,
				sum(cov_ENERGY_CONSUMP_INTEN_NACE_A)*100 as cov_ENERGY_CONSUMP_INTEN_NACE_A,
				sum(ENERGY_CONSUMP_INTEN_NACE_B) AS ENERGY_CONSUMP_INTEN_NACE_B,
				sum(cov_ENERGY_CONSUMP_INTEN_NACE_B)*100 as cov_ENERGY_CONSUMP_INTEN_NACE_B,
				sum(ENERGY_CONSUMP_INTEN_NACE_C) AS ENERGY_CONSUMP_INTEN_NACE_C,
				sum(cov_ENERGY_CONSUMP_INTEN_NACE_C)*100 as cov_ENERGY_CONSUMP_INTEN_NACE_C,
				sum(ENERGY_CONSUMP_INTEN_NACE_D) AS ENERGY_CONSUMP_INTEN_NACE_D,
				sum(cov_ENERGY_CONSUMP_INTEN_NACE_D)*100 as cov_ENERGY_CONSUMP_INTEN_NACE_D,
				sum(ENERGY_CONSUMP_INTEN_NACE_E) AS ENERGY_CONSUMP_INTEN_NACE_E,
				sum(cov_ENERGY_CONSUMP_INTEN_NACE_E)*100 as cov_ENERGY_CONSUMP_INTEN_NACE_E,
				sum(ENERGY_CONSUMP_INTEN_NACE_F) AS ENERGY_CONSUMP_INTEN_NACE_F,
				sum(cov_ENERGY_CONSUMP_INTEN_NACE_F)*100 as cov_ENERGY_CONSUMP_INTEN_NACE_F,
				sum(ENERGY_CONSUMP_INTEN_NACE_G) AS ENERGY_CONSUMP_INTEN_NACE_G,
				sum(cov_ENERGY_CONSUMP_INTEN_NACE_G)*100 as cov_ENERGY_CONSUMP_INTEN_NACE_G,
				sum(ENERGY_CONSUMP_INTEN_NACE_H) AS ENERGY_CONSUMP_INTEN_NACE_H,
				sum(cov_ENERGY_CONSUMP_INTEN_NACE_H)*100 as cov_ENERGY_CONSUMP_INTEN_NACE_H,
				sum(ENERGY_CONSUMP_INTEN_NACE_L) AS ENERGY_CONSUMP_INTEN_NACE_L,
				sum(cov_ENERGY_CONSUMP_INTEN_NACE_L)*100 as cov_ENERGY_CONSUMP_INTEN_NACE_L,
				SUM(cov_ENERGY_CONSUMP_INTEN)*100 as cov_ENERGY_CONSUMP_INTENSITY,
				sum(CLTV_SFDR_ART6) as CLTV_SFDR_ART6_impact
				,sum(CLTV_SFDR_ART8) as CLTV_SFDR_ART8_impact
				,sum(CLTV_SFDR_ART9) as CLTV_SFDR_ART9_impact
				,sum(cltv_mv_eur) as cltv_art_6_8_9_mv_eur
				,sum(Sov_MV_GBP) as sov_intensity_mv_gbp
				,SUM(Board_of_Gender_diversity_ratio_sfdr) as Board_of_Gender_diversity_ratio_sfdr
				,SUM(cov_adj_Board_of_Gender_diversity_ratio_sfdr)*100  as cov_Board_of_Gender_diversity_ratio_sfdr
				,SUM(Board_of_Gender_diversity_pct_sfdr) as Board_of_Gender_diversity_pct_sfdr
				,SUM(cov_adj_Board_of_Gender_diversity_pct_sfdr)*100 as cov_Board_of_Gender_diversity_pct_sfdr
				,SUM([SFDR_ART6]) as SFDR_ART6
				,SUM([SFDR_ART8]) as SFDR_ART8
				,SUM([SFDR_ART9]) as SFDR_ART9
				,SUM(Scope3_TCFD) as Carbon_Emissions_Scope_3_TCFD
				,SUM(cov_adjusted_wt_SCOPE3_TCFD)*100 as  Carbon_Emissions_Scope_3_COV_TCFD
				,SUM(Total_GHG_emissions_TCFD) as  Carbon_Emissions_Scope_123_TCFD,
				[Security_type] as Security_type,
				[issovereign] as issovereign,
				[FUND_ELIGIBILITY] as FUND_ELIGIBILITY
				from 
				[ESG].[Factors_All]
				--[ESG].[Factors_All_POC_20230324]
				group by 
				date,
				[MSCI_AS_OF_DATE],
				[ISIN] ,
				[AssetName],
				LegalEntity ,
				ServiceCategory ,
				[ASSET_GROUP],
				[FUND_SHARE_CLASS_ID],
				[ISSUERID],
				MV_GBP_TOTAL ,
				AUM,
				MV_USD_Total,
				[Security_type],
				[issovereign],
				[FUND_ELIGIBILITY]

INSERT INTO [ESG].[TCFD_LE_SERVICE_LOG] VALUES (GETDATE(),'usp_Load_TCFD_LE_Service_SUM_Calculations','After populating [ESG].[ESG].[GROUP_DRILL_DOWN_FACTORS_POC] for ' + @reporting_group) 

	SET @ReturnValue = 1
	RETURN @ReturnValue
END TRY

BEGIN CATCH
	SET @ReturnValue = -1
	RETURN @ReturnValue
END CATCH

END

GO
