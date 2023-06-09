USE [ESG]
GO
/****** Object:  Table [ESG].[IMDR_UNDERLYING_HOLDINGS]    Script Date: 4/18/2023 12:13:15 PM ******/
DROP TABLE IF EXISTS [ESG].[IMDR_UNDERLYING_HOLDINGS]
GO
/****** Object:  Table [ESG].[IMDR_UNDERLYING_HOLDINGS]    Script Date: 4/18/2023 12:13:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ESG].[IMDR_UNDERLYING_HOLDINGS](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Platform] [varchar](50) NULL,
	[Portfolio_ID] [varchar](50) NULL,
	[Portfolio_Name] [varchar](255) NULL,
	[Share_Class_Name] [varchar](255) NULL,
	[ISIN_Share_Class] [varchar](255) NULL,
	[Share_Class_Fund_Value] [decimal](19, 4) NULL,
	[NAV_Date] [date] NULL,
	[ISIN_Underlying] [varchar](50) NULL,
	[Asset_Name] [varchar](255) NULL,
	[Asset_weight] [decimal](19, 6) NULL,
	[FUND_SHARE_CLASS_ID] [varchar](50) NULL,
	[ISSUERID] [varchar](50) NULL,
	[MSCI_AS_OF_DATE] [date] NULL,
	[MV_GBP] [decimal](19, 4) NULL,
	[MV_EUR] [decimal](19, 8) NULL,
	[MV_USD] [decimal](19, 8) NULL,
	[Service] [varchar](255) NULL,
	[IMDR_tagging] [varchar](255) NULL,
	[AssetGroupClass] [varchar](255) NULL,
	[LegalEntity] [varchar](255) NULL,
	[Custodian] [varchar](50) NULL,
	[ASSET_GROUP] [varchar](255) NULL,
	[ReportingCategory] [varchar](50) NULL,
	[FundViewTagging] [varchar](50) NULL,
	[FUND_ELIGIBILITY] [varchar](2) NULL,
	[IMDR_PROCESS_NAV_DATE] [date] NULL,
	[ServiceCategory] [varchar](20) NULL,
 CONSTRAINT [Pk_IMDR_Underlying_Holdings_ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
