USE [ESG]
GO
/****** Object:  Table [ESG].[DIR_GOVRATING]    Script Date: 4/18/2023 12:13:15 PM ******/
DROP TABLE IF EXISTS [ESG].[DIR_GOVRATING]
GO
/****** Object:  Table [ESG].[DIR_GOVRATING]    Script Date: 4/18/2023 12:13:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ESG].[DIR_GOVRATING](
	[ISSUER_NAME] [varchar](255) NULL,
	[ISSUERID] [varchar](50) NOT NULL,
	[ISSUER_CNTRY_DOMICILE] [varchar](50) NULL,
	[AS_OF_DATE] [date] NOT NULL,
	[GOVERNMENT_RAW_AG_FOREST] [decimal](19, 4) NULL,
	[GOVERNMENT_RAW_CO2] [decimal](19, 4) NULL,
	[GOVERNMENT_RAW_CO2_FLAG] [varchar](50) NULL,
	[GOVERNMENT_RAW_EN_IMP_FLAG] [varchar](50) NULL,
	[GOVERNMENT_RAW_EN_CONS] [decimal](19, 4) NULL,
	[GOVERNMENT_RAW_EN_CONS_FLAG] [varchar](50) NULL,
	[GOVERNMENT_RAW_EN_IMP] [decimal](19, 4) NULL,
	[GOVERNMENT_RAW_EN_PROD] [decimal](19, 4) NULL,
	[GOVERNMENT_RAW_EN_PROD_FLAG] [varchar](50) NULL,
	[GOVERNMENT_RAW_EN_RES_DEP] [decimal](19, 4) NULL,
	[GOVERNMENT_RAW_FOR_COV] [decimal](19, 4) NULL,
	[GOVERNMENT_RAW_GHG_PCT] [decimal](19, 4) NULL,
	[GOVERNMENT_RAW_GHG_CAPITA] [decimal](19, 4) NULL,
	[GOVERNMENT_RAW_PART_EM_DAMAGE] [decimal](19, 4) NULL,
	[GOVERNMENT_RAW_POP_NAT_DIS] [decimal](19, 4) NULL,
	[GOVERNMENT_RAW_REN_WATER] [decimal](19, 4) NULL,
	[GOVERNMENT_RAW_WATER_WD] [decimal](19, 4) NULL,
	[GOVERNMENT_TOTAL_EXP_SCORE] [decimal](19, 4) NULL,
	[GOVERNMENT_ESG_RATING] [varchar](50) NULL,
	[GOVERNMENT_CLASSIFICATION] [varchar](50) NULL,
	[GOVERNMENT_PREVIOUS_RATING] [varchar](50) NULL,
	[GOVERNMENT_REGION] [varchar](50) NULL,
	[GOVERNMENT_UN_SANCTIONS] [varchar](50) NULL,
	[GOVERNMENT_EU_SANCTIONS] [varchar](50) NULL,
	[GOVERNMENT_USE_CHILD_LABOR] [varchar](50) NULL,
 CONSTRAINT [Pk_DIR_GOVRATING_ISSUERID_AS_OF_DATE] PRIMARY KEY CLUSTERED 
(
	[ISSUERID] ASC,
	[AS_OF_DATE] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
