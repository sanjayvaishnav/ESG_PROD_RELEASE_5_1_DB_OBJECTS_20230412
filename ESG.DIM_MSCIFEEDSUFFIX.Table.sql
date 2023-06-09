USE [ESG]
GO
/****** Object:  Table [ESG].[DIM_MSCIFEEDSUFFIX]    Script Date: 4/18/2023 12:13:15 PM ******/
DROP TABLE IF EXISTS [ESG].[DIM_MSCIFEEDSUFFIX]
GO
/****** Object:  Table [ESG].[DIM_MSCIFEEDSUFFIX]    Script Date: 4/18/2023 12:13:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ESG].[DIM_MSCIFEEDSUFFIX](
	[Date_Key] [int] NULL,
	[ESGholdingDate] [date] NULL,
	[StartOfWeek] [date] NULL,
	[WeekDayNum] [int] NULL,
	[MSCIFeedSuffix] [date] NULL,
	[MSCIFeedSuffix_Key] [int] NULL,
	[LastDayofMonth] [int] NULL,
	[LastDayofQtr] [int] NULL,
	[IMDR_Process_Date] [date] NULL,
	[ESGHoldingEOM] [int] NULL
) ON [PRIMARY]
GO
