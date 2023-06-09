USE [ESG]
GO
/****** Object:  Table [ESG].[IMDR_PF_BREAKDOWN]    Script Date: 4/18/2023 12:13:15 PM ******/
DROP TABLE IF EXISTS [ESG].[IMDR_PF_BREAKDOWN]
GO
/****** Object:  Table [ESG].[IMDR_PF_BREAKDOWN]    Script Date: 4/18/2023 12:13:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ESG].[IMDR_PF_BREAKDOWN](
	[ID] [int] NULL,
	[Platform] [varchar](255) NULL,
	[Portfolio] [varchar](50) NULL,
	[Portfolio_Name] [varchar](100) NULL,
	[ISIN] [varchar](50) NULL,
	[Tilney_Code] [varchar](50) NULL,
	[Fund_Name] [varchar](100) NULL,
	[Units] [decimal](19, 4) NULL,
	[Base_Value] [decimal](19, 4) NULL,
	[Base_Price] [decimal](19, 4) NULL,
	[Weight] [float] NULL,
	[NAV_Date] [date] NULL,
	[CCY] [varchar](50) NULL,
	[FX] [decimal](19, 4) NULL,
	[FUND_SHARE_CLASS_ID] [varchar](50) NULL,
	[ISSUERID] [varchar](50) NULL,
	[MSCI_AS_OF_DATE] [date] NULL,
	[Base_Value_GBP] [decimal](19, 4) NULL
) ON [PRIMARY]
GO
