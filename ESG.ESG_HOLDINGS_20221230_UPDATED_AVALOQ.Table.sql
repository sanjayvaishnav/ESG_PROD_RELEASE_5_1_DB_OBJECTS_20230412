USE [ESG]
GO
/****** Object:  Table [ESG].[ESG_HOLDINGS_20221230_UPDATED_AVALOQ]    Script Date: 4/18/2023 12:13:15 PM ******/
DROP TABLE IF EXISTS [ESG].[ESG_HOLDINGS_20221230_UPDATED_AVALOQ]
GO
/****** Object:  Table [ESG].[ESG_HOLDINGS_20221230_UPDATED_AVALOQ]    Script Date: 4/18/2023 12:13:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ESG].[ESG_HOLDINGS_20221230_UPDATED_AVALOQ](
	[ClientReference] [nvarchar](50) NULL,
	[ClientName] [nvarchar](255) NULL,
	[RelationshipManager] [nvarchar](255) NULL,
	[InvestmentManager] [nvarchar](255) NULL,
	[Portfolio] [nvarchar](255) NOT NULL,
	[Service] [nvarchar](255) NULL,
	[Date] [date] NULL,
	[ISIN] [nvarchar](50) NULL,
	[SEDOL] [nvarchar](50) NULL,
	[AssetName] [nvarchar](255) NULL,
	[Units] [decimal](19, 4) NULL,
	[Price] [decimal](19, 4) NULL,
	[Exchange] [nvarchar](50) NULL,
	[FX_Price] [decimal](19, 4) NULL,
	[MV_GBP] [decimal](19, 4) NULL,
	[AssetGroupClass] [nvarchar](255) NOT NULL,
	[LegalEntity] [nvarchar](255) NULL,
	[Custodian] [nvarchar](50) NOT NULL,
	[Branch] [nvarchar](50) NULL,
	[ISSUERID] [varchar](50) NULL,
	[FUND_SHARE_CLASS_ID] [varchar](50) NULL,
	[ASSET_GROUP] [varchar](50) NULL,
	[MSCI_AS_OF_DATE] [date] NULL,
	[IMDRtagging] [varchar](200) NULL,
	[MV_USD] [decimal](19, 4) NULL,
	[MV_EUR] [decimal](19, 4) NULL,
	[ReportingCategory] [nvarchar](100) NULL,
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[TAP_MV_GBP] [decimal](19, 4) NULL,
	[SMART_MV_GBP] [decimal](19, 4) NULL,
	[FirmCode] [nvarchar](255) NULL,
	[ServiceCategory] [nvarchar](255) NULL,
	[LegacyCompany] [nvarchar](255) NULL,
	[MV_GBP_NonTAP] [decimal](19, 4) NULL,
	[FundViewTagging] [varchar](50) NULL,
	[FUND_ELIGIBILITY] [varchar](2) NULL,
	[Short_NonShort_Positions] [varchar](50) NULL
) ON [PRIMARY]
GO
