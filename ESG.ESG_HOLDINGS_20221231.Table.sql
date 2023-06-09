USE [ESG]
GO
/****** Object:  Table [ESG].[ESG_HOLDINGS_20221231]    Script Date: 4/18/2023 12:13:15 PM ******/
DROP TABLE IF EXISTS [ESG].[ESG_HOLDINGS_20221231]
GO
/****** Object:  Table [ESG].[ESG_HOLDINGS_20221231]    Script Date: 4/18/2023 12:13:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ESG].[ESG_HOLDINGS_20221231](
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
	[Units] [numeric](19, 4) NULL,
	[Price] [numeric](19, 4) NULL,
	[Exchange] [nvarchar](50) NULL,
	[FX_Price] [numeric](19, 4) NULL,
	[MV_GBP] [numeric](19, 4) NULL,
	[TAP_MV_GBP] [numeric](19, 4) NULL,
	[SMART_MV_GBP] [numeric](19, 4) NULL,
	[AssetGroupClass] [nvarchar](255) NOT NULL,
	[LegalEntity] [nvarchar](255) NULL,
	[Custodian] [nvarchar](50) NOT NULL,
	[Branch] [nvarchar](50) NULL,
	[ReportingCategory] [nvarchar](100) NULL,
	[FirmCode] [nvarchar](255) NULL,
	[ServiceCategory] [nvarchar](255) NULL,
	[LegacyCompany] [nvarchar](255) NULL,
	[SnapshotDateKey] [int] NOT NULL,
	[SnapshotMonthKey] [int] NOT NULL
) ON [PRIMARY]
GO
