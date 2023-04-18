USE [ESG]
GO
/****** Object:  Table [ESG].[TCFD_SFDR_REPORTING_SUMMARY_HIS_BKP_20230411]    Script Date: 4/18/2023 12:13:15 PM ******/
DROP TABLE IF EXISTS [ESG].[TCFD_SFDR_REPORTING_SUMMARY_HIS_BKP_20230411]
GO
/****** Object:  Table [ESG].[TCFD_SFDR_REPORTING_SUMMARY_HIS_BKP_20230411]    Script Date: 4/18/2023 12:13:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ESG].[TCFD_SFDR_REPORTING_SUMMARY_HIS_BKP_20230411](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[YR_QTR] [varchar](10) NULL,
	[Run_DATE] [date] NULL,
	[Service_Category] [varchar](255) NULL,
	[LEGAL_ENTITY] [varchar](255) NULL,
	[DISTINCTASSET] [decimal](19, 8) NULL,
	[TOTALCLIENTS] [decimal](19, 8) NULL,
	[TOTALPORTFOLIO] [decimal](19, 8) NULL,
	[MV_USD] [decimal](38, 8) NULL,
	[MV_EUR] [decimal](38, 8) NULL,
	[MV_GBP] [decimal](38, 8) NULL,
	[GHG_SCOPE_1] [decimal](38, 8) NULL,
	[GHG_SCOPE_1_COV] [decimal](38, 8) NULL,
	[GHG_SCOPE_2] [decimal](38, 8) NULL,
	[GHG_SCOPE_2_COV] [decimal](38, 8) NULL,
	[GHG_SCOPE_3] [decimal](38, 8) NULL,
	[GHG_SCOPE_3_COV] [decimal](38, 8) NULL,
	[GHG_SCOPE_123] [decimal](38, 8) NULL,
	[GHG_SCOPE_123_COV] [decimal](38, 8) NULL,
	[GHG_CARBON_FOOTPRINT_USD] [decimal](38, 8) NULL,
	[GHG_CARBON_FOOTPRINT_USD_COV] [decimal](38, 8) NULL,
	[GHG_INTENSITY_EUR] [decimal](38, 8) NULL,
	[GHG_INTENSITY_EUR_COV] [decimal](38, 8) NULL,
	[ACTIVE_FF_SECTOR_EXPOSURE] [decimal](19, 4) NULL,
	[ACTIVE_FF_SECTOR_EXPOSURE_COV] [decimal](19, 4) NULL,
	[GHG_CARBON_FOOTPRINT_SFDR] [decimal](19, 4) NULL,
	[GHG_CARBON_FOOTPRINT_COV_SFDR] [decimal](19, 4) NULL,
	[NON_RENEWABLE_ENERGY_CP_SHARE_SFDR] [decimal](19, 4) NULL,
	[NON_RENEWABLE_ENERGY_CP_SHARE_COV_SFDR] [decimal](19, 4) NULL,
	[NOR_NEG_AFCT_BIODIVERSITY_SEN_AREAS_ACT_SFDR] [decimal](19, 4) NULL,
	[NOR_NEG_AFCT_BIODIVERSITY_SEN_AREAS_ACT_COV_SFDR] [decimal](19, 4) NULL,
	[EMISSIONSTO_WATER_SFDR] [decimal](19, 4) NULL,
	[EMISSIONSTO_WATER_COV_SFDR] [decimal](19, 4) NULL,
	[VIOLATION_OF_UN_GLOBAL_SFDR] [decimal](19, 4) NULL,
	[VIOLATION_OF_UN_GLOBAL_COV_SFDR] [decimal](19, 4) NULL,
	[HAZARDOUS_WASTE_RATIO_SFDR] [decimal](19, 4) NULL,
	[HAZARDOUS_WASTE_COV_SFDR] [decimal](19, 4) NULL,
	[MECH_UN_GLOBAL_COMPACT_SFDR] [decimal](19, 4) NULL,
	[MECH_UN_GLOBAL_COMPACT_COV_SFDR] [decimal](19, 4) NULL,
	[UNADJUSTED_GENDER_PAY_GAP_SFDR] [decimal](19, 4) NULL,
	[UNADJUSTED_GENDER_PAY_GAP_COV_SFDR] [decimal](19, 4) NULL,
	[BOARD_OF_GENDER_DENSITY_SFDR] [decimal](19, 4) NULL,
	[BOARD_OF_GENDER_DENSITY_COV_SFDR] [decimal](19, 4) NULL,
	[EXP_TO_CONTROVERSIAL_WEAPONS_SFDR] [decimal](19, 4) NULL,
	[EXP_TO_CONTROVERSIAL_WEAPONS_COV_SFDR] [decimal](19, 4) NULL,
	[EU_TAXONOMY_REVENUE_ALIGNMENT_SFDR] [decimal](19, 4) NULL,
	[EU_TAXONOMY_REVENUE_ALIGNMENT_COV_SFDR] [decimal](19, 4) NULL,
	[BatchID] [int] NOT NULL,
	[GHG_intensity_Sovereign_SFDR] [decimal](19, 4) NULL,
	[GHG_intensity_Sovereign_COV_SFDR] [decimal](19, 4) NULL,
	[Carbon_Emissions_Scope_12_TCFD] [decimal](19, 4) NULL,
	[Weighted_average_carbon_intensity_scope12_TCFD] [decimal](19, 4) NULL,
	[Weighted_average_carbon_intensity_scope12_COV_TCFD] [decimal](19, 4) NULL,
	[CARBON_FOOTPRINT_TCFD] [decimal](19, 4) NULL,
	[Carbon_Emissions_Scope_12_COV_TCFD] [decimal](19, 4) NULL,
	[reporting_group] [varchar](50) NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC,
	[BatchID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
