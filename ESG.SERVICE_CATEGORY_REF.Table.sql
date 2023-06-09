USE [ESG]
GO
/****** Object:  Table [ESG].[SERVICE_CATEGORY_REF]    Script Date: 4/18/2023 12:13:15 PM ******/
DROP TABLE IF EXISTS [ESG].[SERVICE_CATEGORY_REF]
GO
/****** Object:  Table [ESG].[SERVICE_CATEGORY_REF]    Script Date: 4/18/2023 12:13:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ESG].[SERVICE_CATEGORY_REF](
	[MandateCode] [varchar](50) NULL,
	[MyTilneyCategory] [varchar](7) NULL,
	[ServiceCategory] [varchar](50) NULL,
	[ManagementType] [varchar](50) NULL,
	[Effective_Date] [date] NULL
) ON [PRIMARY]
GO
