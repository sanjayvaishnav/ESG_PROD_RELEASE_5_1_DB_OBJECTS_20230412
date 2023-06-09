USE [ESG]
GO
/****** Object:  Table [ESG].[ESG_SECURITY_LEVEL_REF]    Script Date: 4/18/2023 12:13:15 PM ******/
DROP TABLE IF EXISTS [ESG].[ESG_SECURITY_LEVEL_REF]
GO
/****** Object:  Table [ESG].[ESG_SECURITY_LEVEL_REF]    Script Date: 4/18/2023 12:13:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ESG].[ESG_SECURITY_LEVEL_REF](
	[ISSUER_NAME] [varchar](500) NULL,
	[ISSUERID] [varchar](50) NOT NULL,
	[ISSUER_SEDOL] [varchar](50) NOT NULL,
	[ISSUER_ISIN] [varchar](50) NOT NULL,
	[ISSUER_CNTRY_DOMICILE] [varchar](50) NULL,
	[ASSET_TYPE] [varchar](50) NOT NULL,
	[SECURITY_COUNTRY] [varchar](50) NULL,
	[EXCHANGE] [varchar](50) NOT NULL,
	[AS_OF_DATE] [date] NOT NULL,
	[MarketCap_USD] [decimal](19, 4) NULL,
	[ISSUER_CUSIP] [varchar](50) NOT NULL,
	[FIGI] [varchar](50) NOT NULL
) ON [PRIMARY]
GO
