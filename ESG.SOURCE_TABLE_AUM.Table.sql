USE [ESG]
GO
/****** Object:  Table [ESG].[SOURCE_TABLE_AUM]    Script Date: 4/18/2023 12:13:15 PM ******/
DROP TABLE IF EXISTS [ESG].[SOURCE_TABLE_AUM]
GO
/****** Object:  Table [ESG].[SOURCE_TABLE_AUM]    Script Date: 4/18/2023 12:13:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ESG].[SOURCE_TABLE_AUM](
	[Date] [date] NULL,
	[LegalEntity] [varchar](255) NULL,
	[ServiceCategory] [varchar](50) NULL,
	[MSCI_AS_OF_DATE] [date] NULL,
	[MV_USD_total] [decimal](19, 4) NULL,
	[AUM] [decimal](19, 4) NULL,
	[MV_GBP_Total] [decimal](19, 4) NULL,
	[ASSET_GROUP] [varchar](50) NULL
) ON [PRIMARY]
GO
