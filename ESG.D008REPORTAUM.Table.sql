USE [ESG]
GO
/****** Object:  Table [ESG].[D008REPORTAUM]    Script Date: 4/18/2023 12:13:15 PM ******/
DROP TABLE IF EXISTS [ESG].[D008REPORTAUM]
GO
/****** Object:  Table [ESG].[D008REPORTAUM]    Script Date: 4/18/2023 12:13:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ESG].[D008REPORTAUM](
	[EffectiveDate] [date] NULL,
	[Category] [varchar](255) NULL,
	[MandateCodeGroup] [varchar](255) NULL,
	[MandateCode] [varchar](255) NULL,
	[MandateCodeDerived] [varchar](255) NULL,
	[Vendor] [varchar](255) NULL,
	[FirmCode] [varchar](255) NULL,
	[LegacyCompany] [varchar](255) NULL,
	[LegacySubCompany] [varchar](255) NULL,
	[OpeningAUM] [decimal](19, 4) NULL,
	[ClosingAUM] [decimal](19, 4) NULL,
	[Inflows] [decimal](19, 4) NULL,
	[Outflows] [decimal](19, 4) NULL,
	[NNM] [decimal](19, 4) NULL,
	[ServiceCategory] [varchar](255) NULL,
	[CapitalIncome] [decimal](19, 4) NULL
) ON [PRIMARY]
GO
