USE [ESG]
GO
/****** Object:  Table [ESG].[GROUP_DRILL_DOWN_FACTORS]    Script Date: 4/18/2023 12:13:15 PM ******/
DROP TABLE IF EXISTS [ESG].[GROUP_DRILL_DOWN_FACTORS]
GO
/****** Object:  Table [ESG].[GROUP_DRILL_DOWN_FACTORS]    Script Date: 4/18/2023 12:13:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ESG].[GROUP_DRILL_DOWN_FACTORS](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[date] [date] NULL,
	[MSCI_AS_OF_DATE] [date] NULL,
	[ISIN] [varchar](255) NULL,
	[AssetName] [varchar](255) NULL,
	[LegalEntity] [varchar](255) NULL,
	[ServiceCategory] [varchar](255) NULL,
	[ASSET_GROUP] [varchar](255) NULL,
	[FUND_SHARE_CLASS_ID] [varchar](255) NULL,
	[ISSUERID] [varchar](255) NULL,
	[MV_GBP_TOTAL] [decimal](38, 16) NULL,
	[MV_GBP] [decimal](38, 16) NULL,
	[MV_EUR_TOTAL] [decimal](38, 16) NULL,
	[MV_EUR] [decimal](38, 16) NULL,
	[MV_USD_TOTAL] [decimal](38, 16) NULL,
	[MV_USD] [decimal](38, 16) NULL,
	[GHG_SCOPE_1] [decimal](38, 16) NULL,
	[GHG_SCOPE_1_COV] [decimal](38, 16) NULL,
	[GHG_SCOPE_2] [decimal](38, 16) NULL,
	[GHG_SCOPE_2_COV] [decimal](38, 16) NULL,
	[GHG_SCOPE_3] [decimal](38, 16) NULL,
	[GHG_SCOPE_3_COV] [decimal](38, 16) NULL,
	[GHG_SCOPE_123] [decimal](38, 16) NULL,
	[ACTIVE_FF_SECTOR_EXPOSURE] [decimal](38, 16) NULL,
	[ACTIVE_FF_SECTOR_EXPOSURE_COV] [decimal](38, 16) NULL,
	[GHG_Carbon_Footprint_SFDR] [decimal](38, 16) NULL,
	[GHG_Carbon_Footprint_COV_SFDR] [decimal](38, 16) NULL,
	[GHG_Intensity_EUR_SFDR] [decimal](38, 16) NULL,
	[GHG_Intensity_EUR_COV_SFDR] [decimal](38, 16) NULL,
	[Non_renewable_energy_CP_share_SFDR] [decimal](38, 16) NULL,
	[Non_renewable_energy_CP_share_COV_SFDR] [decimal](38, 16) NULL,
	[Nor_Neg_afct_biodiversity_sen_areas_Act_SFDR] [decimal](38, 16) NULL,
	[Nor_Neg_afct_biodiversity_sen_areas_Act_COV_SFDR] [decimal](38, 16) NULL,
	[Emissionsto_water_SFDR] [decimal](38, 16) NULL,
	[Emissionsto_water_COV_SFDR] [decimal](38, 16) NULL,
	[Hazardous_waste_ratio_SFDR] [decimal](38, 16) NULL,
	[Hazardous_waste_COV_SFDR] [decimal](38, 16) NULL,
	[Violation_of_UN_Global_SFDR] [decimal](38, 16) NULL,
	[Violation_of_UN_Global_COV_SFDR] [decimal](38, 16) NULL,
	[Mech_un_global_compact_sfdr] [decimal](38, 16) NULL,
	[Mech_un_global_compact_cov_sfdr] [decimal](38, 16) NULL,
	[Unadjusted_gender_pay_gap_sfdr] [decimal](38, 16) NULL,
	[Unadjusted_gender_pay_gap_cov_sfdr] [decimal](38, 16) NULL,
	[Exp_to_controversial_weapons_SFDR] [decimal](38, 16) NULL,
	[Exp_to_controversial_weapons_COV_SFDR] [decimal](38, 16) NULL,
	[EU_Taxonomy_Revenue_Alignment_sfdr] [decimal](38, 16) NULL,
	[EU_Taxonomy_Revenue_Alignment_COV_sfdr] [decimal](38, 16) NULL,
	[GHG_intensity_Sovereign_SFDR] [decimal](38, 16) NULL,
	[GHG_intensity_Sovereign_COV_SFDR] [decimal](38, 16) NULL,
	[Carbon_Emissions_Scope_12_TCFD] [decimal](38, 16) NULL,
	[Carbon_Emissions_Scope_12_COV_TCFD] [decimal](38, 16) NULL,
	[Weighted_average_carbon_intensity_scope12_TCFD] [decimal](38, 16) NULL,
	[Weighted_average_carbon_intensity_scope12_COV_TCFD] [decimal](38, 16) NULL,
	[CARBON_FOOTPRINT_TCFD] [decimal](38, 16) NULL,
	[HUMAN_RGTS_POLICY] [decimal](38, 16) NULL,
	[FUND_SFDR_HUMAN_RGTS_POL_COV] [decimal](38, 16) NULL,
	[CARBON_REDUCT_INITIATIVES] [decimal](38, 16) NULL,
	[cov_CARBON_EMISSIONS_REDUCT_INITIATIVES] [decimal](38, 16) NULL,
	[ENERGY_CONSUMP_INTEN_NACE_A] [decimal](38, 16) NULL,
	[cov_ENERGY_CONSUMP_INTEN_NACE_A] [decimal](38, 16) NULL,
	[ENERGY_CONSUMP_INTEN_NACE_B] [decimal](38, 16) NULL,
	[cov_ENERGY_CONSUMP_INTEN_NACE_B] [decimal](38, 16) NULL,
	[ENERGY_CONSUMP_INTEN_NACE_C] [decimal](38, 16) NULL,
	[cov_ENERGY_CONSUMP_INTEN_NACE_C] [decimal](38, 16) NULL,
	[ENERGY_CONSUMP_INTEN_NACE_D] [decimal](38, 16) NULL,
	[cov_ENERGY_CONSUMP_INTEN_NACE_D] [decimal](38, 16) NULL,
	[ENERGY_CONSUMP_INTEN_NACE_E] [decimal](38, 16) NULL,
	[cov_ENERGY_CONSUMP_INTEN_NACE_E] [decimal](38, 16) NULL,
	[ENERGY_CONSUMP_INTEN_NACE_F] [decimal](38, 16) NULL,
	[cov_ENERGY_CONSUMP_INTEN_NACE_F] [decimal](38, 16) NULL,
	[ENERGY_CONSUMP_INTEN_NACE_G] [decimal](38, 16) NULL,
	[cov_ENERGY_CONSUMP_INTEN_NACE_G] [decimal](38, 16) NULL,
	[ENERGY_CONSUMP_INTEN_NACE_H] [decimal](38, 16) NULL,
	[cov_ENERGY_CONSUMP_INTEN_NACE_H] [decimal](38, 16) NULL,
	[ENERGY_CONSUMP_INTEN_NACE_L] [decimal](38, 16) NULL,
	[cov_ENERGY_CONSUMP_INTEN_NACE_L] [decimal](38, 16) NULL,
	[cov_ENERGY_CONSUMP_INTENSITY] [decimal](38, 16) NULL,
	[CLTV_SFDR_ART6_impact] [decimal](38, 16) NULL,
	[CLTV_SFDR_ART8_impact] [decimal](38, 16) NULL,
	[CLTV_SFDR_ART9_impact] [decimal](38, 16) NULL,
	[cltv_art_6_8_9_mv_eur] [decimal](38, 16) NULL,
	[sov_intensity_mv_gbp] [decimal](38, 16) NULL,
	[Board_of_Gender_diversity_ratio_sfdr] [decimal](19, 4) NULL,
	[cov_Board_of_Gender_diversity_ratio_sfdr] [decimal](19, 4) NULL,
	[Board_of_Gender_diversity_pct_sfdr] [decimal](19, 4) NULL,
	[cov_Board_of_Gender_diversity_pct_sfdr] [decimal](19, 4) NULL,
	[SFDR_ART6] [decimal](19, 4) NULL,
	[SFDR_ART8] [decimal](19, 4) NULL,
	[SFDR_ART9] [decimal](19, 4) NULL,
	[Carbon_Emissions_Scope_3_TCFD] [decimal](19, 4) NULL,
	[Carbon_Emissions_Scope_3_COV_TCFD] [decimal](19, 4) NULL,
	[Carbon_Emissions_Scope_123_TCFD] [decimal](19, 4) NULL,
	[Security_type] [varchar](255) NULL,
	[issovereign] [varchar](255) NULL,
	[FUND_ELIGIBILITY] [varchar](255) NULL
) ON [PRIMARY]
GO
