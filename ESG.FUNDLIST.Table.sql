USE [ESG]
GO
/****** Object:  Table [ESG].[FUNDLIST]    Script Date: 4/18/2023 12:13:15 PM ******/
DROP TABLE IF EXISTS [ESG].[FUNDLIST]
GO
/****** Object:  Table [ESG].[FUNDLIST]    Script Date: 4/18/2023 12:13:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ESG].[FUNDLIST](
	[Stu_Fund_Code] [numeric](8, 0) NOT NULL,
	[Cust_Code] [varchar](100) NULL,
	[Cust_Name] [varchar](100) NULL,
	[Source] [varchar](100) NULL,
	[Platform] [varchar](100) NULL,
	[SendToBBG] [bit] NULL
) ON [PRIMARY]
GO
