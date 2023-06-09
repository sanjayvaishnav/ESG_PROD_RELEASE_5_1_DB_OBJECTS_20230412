USE [ESG]
GO
/****** Object:  Table [ESG].[TCFD_LE_SERVICE_SUM_20230118]    Script Date: 4/18/2023 12:13:15 PM ******/
DROP TABLE IF EXISTS [ESG].[TCFD_LE_SERVICE_SUM_20230118]
GO
/****** Object:  Table [ESG].[TCFD_LE_SERVICE_SUM_20230118]    Script Date: 4/18/2023 12:13:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ESG].[TCFD_LE_SERVICE_SUM_20230118](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[DATE] [date] NULL,
	[MSCI_AS_OF_DATE] [date] NULL,
	[Legal_Entity] [varchar](255) NULL,
	[DistinctAsset] [decimal](19, 8) NULL,
	[TotalClients] [decimal](19, 8) NULL,
	[TotalPortfolio] [decimal](19, 8) NULL,
	[MV_USD] [decimal](38, 8) NULL,
	[MV_EUR] [decimal](38, 8) NULL,
	[MV_GBP] [decimal](38, 8) NULL,
	[Service] [varchar](255) NULL,
	[Service_Category] [varchar](255) NULL,
	[GHG_SCOPE_1] [decimal](38, 8) NULL,
	[GHG_SCOPE_1_COV] [decimal](38, 8) NULL,
	[GHG_SCOPE_2] [decimal](38, 8) NULL,
	[GHG_SCOPE_2_COV] [decimal](38, 8) NULL,
	[GHG_SCOPE_3] [decimal](38, 8) NULL,
	[GHG_SCOPE_3_COV] [decimal](38, 8) NULL,
	[GHG_SCOPE_123] [decimal](38, 8) NULL,
	[GHG_SCOPE_123_COV] [decimal](38, 8) NULL,
	[GHG_Carbon_Footprint_USD] [decimal](38, 8) NULL,
	[GHG_Carbon_Footprint_USD_COV] [decimal](38, 8) NULL,
	[GHG_Intensity_EUR] [decimal](38, 8) NULL,
	[GHG_Intensity_EUR_COV] [decimal](38, 8) NULL,
	[ACTIVE_FF_SECTOR_EXPOSURE] [decimal](19, 4) NULL,
	[ACTIVE_FF_SECTOR_EXPOSURE_COV] [decimal](19, 4) NULL,
	[GHG_Carbon_Footprint_SFDR] [decimal](19, 4) NULL,
	[GHG_Carbon_Footprint_COV_SFDR] [decimal](19, 4) NULL,
	[GHG_Intensity_EUR_SFDR] [decimal](19, 4) NULL,
	[GHG_Intensity_EUR_COV_SFDR] [decimal](19, 4) NULL,
	[Non_renewable_energy_CP_share_SFDR] [decimal](19, 4) NULL,
	[Non_renewable_energy_CP_share_COV_SFDR] [decimal](19, 4) NULL,
	[Nor_Neg_afct_biodiversity_sen_areas_Act_SFDR] [decimal](19, 4) NULL,
	[Nor_Neg_afct_biodiversity_sen_areas_Act_COV_SFDR] [decimal](19, 4) NULL,
	[Emissionsto_water_SFDR] [decimal](19, 4) NULL,
	[Emissionsto_water_COV_SFDR] [decimal](19, 4) NULL,
	[Violation_of_UN_Global_SFDR] [decimal](19, 4) NULL,
	[Violation_of_UN_Global_COV_SFDR] [decimal](19, 4) NULL,
	[Hazardous_waste_ratio_SFDR] [decimal](19, 4) NULL,
	[Hazardous_waste_COV_SFDR] [decimal](19, 4) NULL,
	[Mech_un_global_compact_sfdr] [decimal](19, 4) NULL,
	[Mech_un_global_compact_cov_sfdr] [decimal](19, 4) NULL,
	[Unadjusted_gender_pay_gap_sfdr] [decimal](19, 4) NULL,
	[Unadjusted_gender_pay_gap_cov_sfdr] [decimal](19, 4) NULL,
	[Board_of_Gender_density_sfdr] [decimal](19, 4) NULL,
	[Board_of_Gender_density_cov_sfdr] [decimal](19, 4) NULL,
	[Exp_to_controversial_weapons_SFDR] [decimal](19, 4) NULL,
	[Exp_to_controversial_weapons_COV_SFDR] [decimal](19, 4) NULL,
	[EU_Taxonomy_Revenue_Alignment_sfdr] [decimal](19, 4) NULL,
	[EU_Taxonomy_Revenue_Alignment_COV_sfdr] [decimal](19, 4) NULL,
	[GHG_intensity_Sovereign_SFDR] [decimal](19, 4) NULL,
	[GHG_intensity_Sovereign_COV_SFDR] [decimal](19, 4) NULL,
	[Carbon_Emissions_Scope_12_TCFD] [decimal](19, 4) NULL,
	[Weighted_average_carbon_intensity_scope12_TCFD] [decimal](19, 4) NULL,
	[Weighted_average_carbon_intensity_scope12_COV_TCFD] [decimal](19, 4) NULL,
	[CARBON_FOOTPRINT_TCFD] [decimal](19, 4) NULL,
	[Carbon_Emissions_Scope_12_COV_TCFD] [decimal](19, 4) NULL,
	[reporting_group] [varchar](50) NULL
) ON [PRIMARY]
GO
