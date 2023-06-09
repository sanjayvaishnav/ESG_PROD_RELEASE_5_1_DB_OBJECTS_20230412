USE [ESG]
GO
/****** Object:  Table [ESG].[STG_IMDR_PF_BREAKDOWN]    Script Date: 4/18/2023 12:13:15 PM ******/
DROP TABLE IF EXISTS [ESG].[STG_IMDR_PF_BREAKDOWN]
GO
/****** Object:  Table [ESG].[STG_IMDR_PF_BREAKDOWN]    Script Date: 4/18/2023 12:13:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ESG].[STG_IMDR_PF_BREAKDOWN](
	[ID] [varchar](50) NULL,
	[Platform] [varchar](255) NULL,
	[Portfolio] [varchar](50) NULL,
	[Portfolio_Name] [varchar](100) NULL,
	[ISIN] [varchar](50) NULL,
	[Tilney_Code] [varchar](50) NULL,
	[Fund_Name] [varchar](100) NULL,
	[Units] [varchar](50) NULL,
	[Base_Value] [varchar](50) NULL,
	[Base_Price] [varchar](50) NULL,
	[Weight] [varchar](50) NULL,
	[NAV_Date] [varchar](50) NULL,
	[CCY] [varchar](50) NULL,
	[FX] [varchar](50) NULL,
	[MSCI_AS_OF_DATE] [varchar](50) NULL
) ON [PRIMARY]
GO
