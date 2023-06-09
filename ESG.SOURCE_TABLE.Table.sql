USE [ESG]
GO
/****** Object:  Table [ESG].[SOURCE_TABLE]    Script Date: 4/18/2023 12:13:15 PM ******/
DROP TABLE IF EXISTS [ESG].[SOURCE_TABLE]
GO
/****** Object:  Table [ESG].[SOURCE_TABLE]    Script Date: 4/18/2023 12:13:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ESG].[SOURCE_TABLE](
	[ClientReference] [varchar](50) NULL,
	[ClientName] [varchar](255) NULL,
	[ISIN_Share_Class] [varchar](255) NULL,
	[Share_Class_Name] [varchar](255) NULL,
	[ISIN] [varchar](50) NULL,
	[AssetName] [varchar](255) NULL,
	[ISSUERID] [varchar](50) NULL,
	[FUND_SHARE_CLASS_ID] [varchar](50) NULL,
	[MSCI_AS_OF_DATE] [date] NULL,
	[MV_GBP] [decimal](19, 4) NULL,
	[MV_EUR] [decimal](19, 4) NULL,
	[MV_USD] [decimal](19, 4) NULL,
	[Service] [varchar](255) NULL,
	[LegalEntity] [varchar](255) NULL,
	[AssetGroupClass] [varchar](255) NULL,
	[ASSET_GROUP] [varchar](50) NULL,
	[Date] [date] NULL,
	[FundViewTagging] [varchar](200) NULL,
	[FUND_ELIGIBILITY] [varchar](2) NULL,
	[InvestmentManager] [varchar](255) NULL,
	[RelationshipManager] [varchar](255) NULL,
	[Portfolio] [varchar](255) NULL,
	[Price] [decimal](19, 4) NULL,
	[Units] [decimal](19, 4) NULL,
	[SEDOL] [varchar](255) NULL,
	[Branch] [varchar](255) NULL,
	[Custodian] [varchar](255) NULL,
	[Exchange] [varchar](255) NULL,
	[FX_Price] [decimal](19, 4) NULL,
	[ServiceCategory] [varchar](50) NULL
) ON [PRIMARY]
GO
