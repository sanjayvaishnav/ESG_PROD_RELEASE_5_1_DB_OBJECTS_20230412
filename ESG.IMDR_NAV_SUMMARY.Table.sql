USE [ESG]
GO
/****** Object:  Table [ESG].[IMDR_NAV_SUMMARY]    Script Date: 4/18/2023 12:13:15 PM ******/
DROP TABLE IF EXISTS [ESG].[IMDR_NAV_SUMMARY]
GO
/****** Object:  Table [ESG].[IMDR_NAV_SUMMARY]    Script Date: 4/18/2023 12:13:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ESG].[IMDR_NAV_SUMMARY](
	[ID] [int] NULL,
	[Platform] [varchar](255) NULL,
	[Portfolio] [varchar](255) NULL,
	[Fund_Name] [varchar](255) NULL,
	[Share_Class] [varchar](255) NULL,
	[ISIN] [varchar](255) NULL,
	[Fund_Value] [decimal](19, 4) NULL,
	[Units] [decimal](19, 4) NULL,
	[Price_per_Unit] [decimal](19, 4) NULL,
	[Yield] [varchar](255) NULL,
	[NAV_Date] [date] NULL,
	[%Change] [float] NULL,
	[FUND_SHARE_CLASS_ID] [varchar](50) NULL,
	[ISSUERID] [varchar](50) NULL,
	[MSCI_AS_OF_DATE] [date] NULL,
	[Fund_Value_GBP] [decimal](19, 4) NULL
) ON [PRIMARY]
GO
