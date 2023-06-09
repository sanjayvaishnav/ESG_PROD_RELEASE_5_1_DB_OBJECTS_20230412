USE [ESG]
GO
/****** Object:  Table [ESG].[Factors_All_Sovereign_EU_SANCTIONS]    Script Date: 4/18/2023 12:13:15 PM ******/
DROP TABLE IF EXISTS [ESG].[Factors_All_Sovereign_EU_SANCTIONS]
GO
/****** Object:  Table [ESG].[Factors_All_Sovereign_EU_SANCTIONS]    Script Date: 4/18/2023 12:13:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ESG].[Factors_All_Sovereign_EU_SANCTIONS](
	[Date] [date] NULL,
	[LegalEntity] [nvarchar](255) NULL,
	[ServiceCategory] [nvarchar](255) NULL,
	[MSCI_AS_OF_DATE] [date] NULL,
	[Sov_EUSANC_MV_GBP] [decimal](19, 4) NULL,
	[Sov_EUSANC_MV_EUR] [decimal](19, 4) NULL,
	[ASSET_GROUP] [varchar](50) NULL,
	[FUND_SHARE_CLASS_ID] [varchar](50) NULL,
	[ISSUERID] [varchar](50) NULL,
	[FUND_TYPE] [varchar](50) NULL,
	[FUND_ELIGIBILITY] [varchar](2) NULL,
	[AUM] [decimal](19, 4) NULL,
	[MV_GBP_Total] [decimal](19, 4) NULL,
	[IsSOV] [varchar](50) NULL,
	[cov_GOVERNMENT_EU_SANCTIONS] [float] NULL,
	[GOVERNMENT_EU_SANCTIONS] [varchar](50) NULL,
	[FUND_SFDR_GLOBAL_EU_SANCTIONS_COUNT] [decimal](19, 4) NULL,
	[FUND_SFDR_GLOBAL_EU_SANCTIONS_COV] [decimal](19, 4) NULL,
	[FUND_SFDR_GLOBAL_EU_SANCTIONS_PERCENTAGE] [decimal](19, 4) NULL,
	[cov_unique_issuer] [decimal](38, 15) NULL,
	[sov_sanctions] [decimal](19, 4) NULL
) ON [PRIMARY]
GO
