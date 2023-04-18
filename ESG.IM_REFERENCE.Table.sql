USE [ESG]
GO
/****** Object:  Table [ESG].[IM_REFERENCE]    Script Date: 4/18/2023 12:13:15 PM ******/
DROP TABLE IF EXISTS [ESG].[IM_REFERENCE]
GO
/****** Object:  Table [ESG].[IM_REFERENCE]    Script Date: 4/18/2023 12:13:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ESG].[IM_REFERENCE](
	[SerialNumber] [int] IDENTITY(1,1) NOT NULL,
	[IM_Name] [varchar](100) NOT NULL,
	[IM_EmailID] [varchar](150) NOT NULL
) ON [PRIMARY]
GO
