USE [ESG]
GO
/****** Object:  Table [ESG].[Factors_All]    Script Date: 4/18/2023 12:13:15 PM ******/
DROP TABLE IF EXISTS [ESG].[Factors_All]
GO
/****** Object:  Table [ESG].[Factors_All]    Script Date: 4/18/2023 12:13:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ESG].[Factors_All](
	[date] [date] NULL,
	[ServiceCategory] [varchar](50) NULL,
	[MSCI_AS_OF_DATE] [date] NULL,
	[LegalEntity] [varchar](255) NULL,
	[Service] [varchar](255) NULL,
	[ISIN] [varchar](50) NULL,
	[AssetName] [varchar](255) NULL,
	[ClientReference] [varchar](50) NULL,
	[Portfolio] [varchar](255) NULL,
	[FUND_SHARE_CLASS_ID] [varchar](50) NULL,
	[ISSUERID] [varchar](50) NULL,
	[CARBON_EMISSIONS_SCOPE_1] [decimal](19, 4) NULL,
	[CARBON_EMISSIONS_SCOPE_2] [decimal](19, 4) NULL,
	[CARBON_EMISSIONS_SCOPE_3_TOTAL] [decimal](19, 4) NULL,
	[CARBON_EMISSIONS_SCOPE123] [decimal](19, 4) NULL,
	[CARBON_EMISSIONS_SALES_EUR_SCOPE123_INTEN] [decimal](19, 4) NULL,
	[EVIC_EUR] [decimal](19, 4) NULL,
	[FUND_SFDR_CARBON_FOOTPRINT_SCOPE_1] [decimal](19, 4) NULL,
	[FUND_SFDR_CARBON_FOOTPRINT_SCOPE_1_COV] [decimal](19, 4) NULL,
	[MV_EUR] [decimal](19, 4) NULL,
	[FUND_SFDR_CARBON_FOOTPRINT_SCOPE_2] [decimal](19, 4) NULL,
	[FUND_SFDR_CARBON_FOOTPRINT_SCOPE_3] [decimal](19, 4) NULL,
	[FUND_SFDR_CARBON_FOOTPRINT] [decimal](19, 4) NULL,
	[FUND_SFDR_GHG_INTENSITY] [decimal](19, 4) NULL,
	[MV_GBP_total] [decimal](19, 4) NULL,
	[AUM] [decimal](19, 4) NULL,
	[MV_USD_total] [decimal](19, 4) NULL,
	[ASSET_GROUP] [varchar](50) NULL,
	[Security_type] [varchar](15) NOT NULL,
	[Portfolio_wt] [decimal](19, 4) NULL,
	[cov_adjusted_wt] [float] NULL,
	[cov_adjusted_wt_SCOPE12_TCFD] [float] NULL,
	[cov_adjusted_wt2] [float] NULL,
	[cov_adjusted_wt3] [float] NULL,
	[cov_adjusted_wt_total] [float] NULL,
	[cov_adjusted_GHG_INTENSITY] [float] NULL,
	[cov_adjusted_avg_carbon_intensity_scope12_TCFD] [float] NULL,
	[cov_adjusted_CompanyExposer_FF] [float] NULL,
	[cov_Non_renewable_energy_SFDR] [float] NULL,
	[cov_Neg_afct_biodiversity_sen_areas_Act_SFDR] [float] NULL,
	[cov_adj_Emissions_to_water_SFDR] [float] NULL,
	[cov_adj_Hazardous_waste_ratio_SFDR] [float] NULL,
	[cov_adj_Violation_of_UN_Global_SFDR] [float] NULL,
	[cov_adj_mech_un_global_compact_sfdr] [float] NULL,
	[cov_adj_Unadjusted_gender_pay_gap_sfdr] [float] NULL,
	[cov_adj_Board_of_Gender_diversity_ratio_sfdr] [float] NULL,
	[cov_adj_Board_of_Gender_diversity_pct_sfdr] [float] NULL,
	[cov_adj_Exp_to_controversial_weapons_SFDR] [float] NULL,
	[cov_adj_EU_Taxonomy_Revenue_Alignment_sfdr] [float] NULL,
	[Sov_MV_GBP] [decimal](19, 4) NULL,
	[cltv_mv_eur] [decimal](19, 4) NULL,
	[cov_SFDR_HUMAN_RGTS_POL] [float] NULL,
	[cov_CARBON_EMISSIONS_REDUCT_INITIATIVES] [float] NULL,
	[cov_ENERGY_CONSUMP_INTEN_NACE_A] [float] NULL,
	[cov_ENERGY_CONSUMP_INTEN_NACE_B] [float] NULL,
	[cov_ENERGY_CONSUMP_INTEN_NACE_C] [float] NULL,
	[cov_ENERGY_CONSUMP_INTEN_NACE_D] [float] NULL,
	[cov_ENERGY_CONSUMP_INTEN_NACE_E] [float] NULL,
	[cov_ENERGY_CONSUMP_INTEN_NACE_F] [float] NULL,
	[cov_ENERGY_CONSUMP_INTEN_NACE_G] [float] NULL,
	[cov_ENERGY_CONSUMP_INTEN_NACE_H] [float] NULL,
	[cov_ENERGY_CONSUMP_INTEN_NACE_L] [float] NULL,
	[cov_ENERGY_CONSUMP_INTEN] [float] NULL,
	[SFDR_ART6] [float] NULL,
	[SFDR_ART8] [float] NULL,
	[SFDR_ART9] [float] NULL,
	[cov_adjusted_wt_SCOPE3_TCFD] [float] NULL,
	[ACTIVE_FF_SECTOR_EXPOSURE] [varchar](50) NULL,
	[FUND_SFDR_ACTIVE_FF_SECTOR_EXPOSURE_COV] [decimal](19, 4) NULL,
	[HUMAN_RGTS_POL] [varchar](50) NULL,
	[FUND_SFDR_HUMAN_RGTS_POL] [decimal](19, 4) NULL,
	[FUND_SFDR_HUMAN_RGTS_POL_COV] [decimal](19, 4) NULL,
	[CARBON_REDUCT_INITIATIVES_PA] [varchar](50) NULL,
	[FUND_CARBON_EMISSIONS_REDUCT_INITIATIVES] [decimal](19, 4) NULL,
	[FUND_CARBON_EMISSIONS_REDUCT_INITIATIVES_COV] [decimal](19, 4) NULL,
	[ENERGY_CONSUMP_INTEN_EUR] [decimal](19, 4) NULL,
	[NACE_SECTION_CODE] [varchar](50) NULL,
	[FUND_SFDR_ENERGY_CONSUMP_INTEN_EUR_NACE_A] [decimal](19, 4) NULL,
	[FUND_SFDR_ENERGY_CONSUMP_INTEN_EUR_NACE_B] [decimal](19, 4) NULL,
	[FUND_SFDR_ENERGY_CONSUMP_INTEN_EUR_NACE_C] [decimal](19, 4) NULL,
	[FUND_SFDR_ENERGY_CONSUMP_INTEN_EUR_NACE_D] [decimal](19, 4) NULL,
	[FUND_SFDR_ENERGY_CONSUMP_INTEN_EUR_NACE_E] [decimal](19, 4) NULL,
	[FUND_SFDR_ENERGY_CONSUMP_INTEN_EUR_NACE_F] [decimal](19, 4) NULL,
	[FUND_SFDR_ENERGY_CONSUMP_INTEN_EUR_NACE_G] [decimal](19, 4) NULL,
	[FUND_SFDR_ENERGY_CONSUMP_INTEN_EUR_NACE_H] [decimal](19, 4) NULL,
	[FUND_SFDR_ENERGY_CONSUMP_INTEN_EUR_NACE_L] [decimal](19, 4) NULL,
	[FUND_SFDR_ENERGY_CONSUMP_INTEN_EUR_COV] [decimal](19, 4) NULL,
	[FUND_SFDR_ENERGY_CONSUMP_INTEN_EUR_NACE_COV_A] [decimal](19, 4) NULL,
	[FUND_SFDR_ENERGY_CONSUMP_INTEN_EUR_NACE_COV_B] [decimal](19, 4) NULL,
	[FUND_SFDR_ENERGY_CONSUMP_INTEN_EUR_NACE_COV_C] [decimal](19, 4) NULL,
	[FUND_SFDR_ENERGY_CONSUMP_INTEN_EUR_NACE_COV_D] [decimal](19, 4) NULL,
	[FUND_SFDR_ENERGY_CONSUMP_INTEN_EUR_NACE_COV_E] [decimal](19, 4) NULL,
	[FUND_SFDR_ENERGY_CONSUMP_INTEN_EUR_NACE_COV_F] [decimal](19, 4) NULL,
	[FUND_SFDR_ENERGY_CONSUMP_INTEN_EUR_NACE_COV_G] [decimal](19, 4) NULL,
	[FUND_SFDR_ENERGY_CONSUMP_INTEN_EUR_NACE_COV_H] [decimal](19, 4) NULL,
	[FUND_SFDR_ENERGY_CONSUMP_INTEN_EUR_NACE_COV_L] [decimal](19, 4) NULL,
	[FEMALE_DIRECTORS_PCT] [decimal](19, 4) NULL,
	[FUND_SFDR_FEMALE_DIRECTORS_PCT] [decimal](19, 4) NULL,
	[FUND_SFDR_FEMALE_DIRECTORS_COV] [decimal](19, 4) NULL,
	[FUND_CARBON_EMISSIONS_SCOPE_3_TOT_EVIC_INTEN] [decimal](19, 4) NULL,
	[FUND_CARBON_EMISSIONS_SCOPE_3_TOT_EVIC_INTEN_COV] [decimal](19, 4) NULL,
	[FUND_SFDR_ACTIVE_FF_SECTOR_EXPOSURE] [decimal](19, 4) NULL,
	[PCT_NONRENEW_CONSUMP_PROD] [decimal](19, 4) NULL,
	[FUND_SFDR_PCT_NONRENEW_CONSUMP_PROD_COV] [decimal](19, 4) NULL,
	[FUND_SFDR_PCT_NONRENEW_CONSUMP_PROD] [decimal](19, 4) NULL,
	[OPS_PROT_BIODIV_CONTROVS] [varchar](50) NULL,
	[FUND_SFDR_OPS_PROT_BIODIV_CONTROVS] [decimal](19, 4) NULL,
	[FUND_SFDR_OPS_PROT_BIODIV_CONTROVS_COV] [decimal](19, 4) NULL,
	[WATER_EM_EFF_METRIC_TONS] [decimal](19, 4) NULL,
	[FUND_SFDR_WATER_EM_EFF_METRIC_TONS] [decimal](19, 4) NULL,
	[FUND_SFDR_WATER_EM_EFF_METRIC_TONS_COV] [decimal](19, 4) NULL,
	[HAZARD_WASTE_METRIC_TON] [decimal](19, 4) NULL,
	[EVIC_USD_RECENT] [decimal](19, 4) NULL,
	[FUND_SFDR_HAZARD_WASTE_METRIC_TON_COV] [decimal](19, 4) NULL,
	[FUND_SFDR_HAZARD_WASTE_METRIC_TON] [decimal](19, 4) NULL,
	[OVERALL_FLAG] [varchar](50) NULL,
	[FUND_SFDR_VIOLATIONS_UNGC_OECD_COV] [decimal](19, 4) NULL,
	[FUND_SFDR_VIOLATIONS_UNGC_OECD] [decimal](19, 4) NULL,
	[MECH_UN_GLOBAL_COMPACT] [varchar](50) NULL,
	[FUND_SFDR_MECH_UN_GLOBAL_COMPACT_COV] [decimal](19, 4) NULL,
	[FUND_SFDR_MECH_UN_GLOBAL_COMPACT] [decimal](19, 4) NULL,
	[GENDER_PAY_GAP_RATIO] [decimal](19, 4) NULL,
	[FUND_SFDR_GENDER_PAY_GAP_RATIO_COV] [decimal](19, 4) NULL,
	[FUND_SFDR_GENDER_PAY_GAP_RATIO] [decimal](19, 4) NULL,
	[FM_BOARD_RATIO] [decimal](19, 4) NULL,
	[FUND_SFDR_FM_BOARD_RATIO] [decimal](19, 4) NULL,
	[FUND_SFDR_FM_BOARD_RATIO_COV] [decimal](19, 4) NULL,
	[CONTRO_WEAP_CBLMBW_ANYTIE] [varchar](50) NULL,
	[FUND_SFDR_CONTRO_WEAP_CBLMBW_ANYTIE] [decimal](19, 4) NULL,
	[FUND_SFDR_CONTRO_WEAP_CBLMBW_ANYTIE_COV] [decimal](19, 4) NULL,
	[FUND_REV_EXP_EST_EU_TAXONOMY_MAX_REV_COV] [decimal](19, 4) NULL,
	[FUND_REV_EXP_EST_EU_TAXONOMY_MAX_REV] [decimal](19, 4) NULL,
	[FP_REG_FRAME_SFDR_ART6] [varchar](50) NULL,
	[FP_REG_FRAME_SFDR_ART8] [varchar](50) NULL,
	[FP_REG_FRAME_SFDR_ART9] [varchar](50) NULL,
	[EST_EU_TAXONOMY_MAX_REV] [decimal](19, 4) NULL,
	[CTRY_GHG_INTEN_GDP_EUR] [decimal](19, 4) NULL,
	[FUND_SFDR_CTRY_GHG_INTEN_GDP_EUR] [decimal](19, 4) NULL,
	[FUND_SFDR_CTRY_GHG_INTEN_GDP_EUR_COV] [decimal](19, 4) NULL,
	[GOVERNMENT_EU_SANCTIONS] [varchar](50) NULL,
	[issovereign] [varchar](50) NULL,
	[FUND_SFDR_GHG_INTENSITY_COV] [decimal](19, 4) NULL,
	[FUND_SFDR_CARBON_FOOTPRINT_SCOPE_2_COV] [decimal](19, 4) NULL,
	[FUND_SFDR_CARBON_FOOTPRINT_SCOPE_3_COV] [decimal](19, 4) NULL,
	[CARBON_EMISSIONS_SCOPE_12_INTEN] [decimal](19, 4) NULL,
	[FUND_WEIGHTED_AVG_CARBON_INTEN_COVERAGE] [decimal](19, 4) NULL,
	[CARBON_EMISSIONS_SCOPE_12] [decimal](19, 4) NULL,
	[FUND_FINANCED_CARBON_EMISSIONS] [decimal](19, 4) NULL,
	[MV_USD] [decimal](19, 4) NULL,
	[FUND_WEIGHTED_AVG_CARBON_INTEN] [decimal](19, 4) NULL,
	[FUND_ELIGIBILITY] [varchar](2) NULL,
	[MV_GBP] [decimal](19, 4) NULL,
	[cov_adj_GHG_intensity_Sovereign] [float] NULL,
	[CLTV_SFDR_ART6] [float] NULL,
	[CLTV_SFDR_ART8] [float] NULL,
	[CLTV_SFDR_ART9] [float] NULL,
	[normalized_ghg_intensity] [float] NULL,
	[normalized_Non_renewable_energy_SFDR] [float] NULL,
	[Norm_Unadjusted_gender_pay_gap_sfdr] [float] NULL,
	[Norm_Board_of_Gender_diversity_ratio_sfdr] [float] NULL,
	[Norm_Board_of_Gender_diversity_pct_sfdr] [float] NULL,
	[Norm_EU_Taxonomy_Revenue_Alignment_sfdr] [float] NULL,
	[Norm_GHG_intensity_Sovereign] [float] NULL,
	[normalized_weighted_average_carbon_intensity_scope12_TCFD] [float] NULL,
	[normalized_cov_ENERGY_CONSUMP_INTEN_NACE_A] [float] NULL,
	[normalized_cov_ENERGY_CONSUMP_INTEN_NACE_B] [float] NULL,
	[normalized_cov_ENERGY_CONSUMP_INTEN_NACE_C] [float] NULL,
	[normalized_cov_ENERGY_CONSUMP_INTEN_NACE_D] [float] NULL,
	[normalized_cov_ENERGY_CONSUMP_INTEN_NACE_E] [float] NULL,
	[normalized_cov_ENERGY_CONSUMP_INTEN_NACE_F] [float] NULL,
	[normalized_cov_ENERGY_CONSUMP_INTEN_NACE_G] [float] NULL,
	[normalized_cov_ENERGY_CONSUMP_INTEN_NACE_H] [float] NULL,
	[normalized_cov_ENERGY_CONSUMP_INTEN_NACE_L] [float] NULL,
	[GHG_Intensity_of_investee_companies_1] [float] NULL,
	[Weighted_average_carbon_intensity_scope12_TCFD] [float] NULL,
	[ActiveinFFSector] [decimal](38, 6) NULL,
	[Scope1] [decimal](38, 6) NULL,
	[Scope12_TCFD] [decimal](38, 6) NULL,
	[Scope2] [decimal](38, 6) NULL,
	[Scope3] [decimal](38, 6) NULL,
	[Neg_afct_biodiversity_sen_areas_Act_SFDR] [decimal](38, 6) NULL,
	[Emissions_to_water_SFDR] [decimal](38, 6) NULL,
	[Non_renewable_energy_share_SFDR] [float] NULL,
	[Hazardous_waste_ratio_SFDR] [decimal](38, 6) NULL,
	[Violation_of_UN_Global_SFDR] [decimal](38, 6) NULL,
	[Mech_un_global_compact_sfdr] [decimal](38, 6) NULL,
	[Unadjusted_gender_pay_gap_sfdr] [float] NULL,
	[Board_of_Gender_diversity_ratio_sfdr] [float] NULL,
	[Board_of_Gender_diversity_pct_sfdr] [float] NULL,
	[Exp_to_controversial_weapons_SFDR] [decimal](38, 6) NULL,
	[EU_Taxonomy_Revenue_Alignment_sfdr] [decimal](38, 6) NULL,
	[GHG_intensity_Sovereign] [float] NULL,
	[HUMAN_RGTS_POLICY] [decimal](38, 6) NULL,
	[CARBON_REDUCT_INITIATIVES] [decimal](38, 6) NULL,
	[ENERGY_CONSUMP_INTEN_NACE_A] [float] NULL,
	[ENERGY_CONSUMP_INTEN_NACE_B] [float] NULL,
	[ENERGY_CONSUMP_INTEN_NACE_C] [float] NULL,
	[ENERGY_CONSUMP_INTEN_NACE_D] [float] NULL,
	[ENERGY_CONSUMP_INTEN_NACE_E] [float] NULL,
	[ENERGY_CONSUMP_INTEN_NACE_F] [float] NULL,
	[ENERGY_CONSUMP_INTEN_NACE_G] [float] NULL,
	[ENERGY_CONSUMP_INTEN_NACE_H] [float] NULL,
	[ENERGY_CONSUMP_INTEN_NACE_L] [float] NULL,
	[Scope3_TCFD] [decimal](38, 6) NULL,
	[Total_GHG_emissions_SFDR] [decimal](38, 6) NULL,
	[Total_GHG_emissions_TCFD] [decimal](38, 6) NULL
) ON [PRIMARY]
GO
