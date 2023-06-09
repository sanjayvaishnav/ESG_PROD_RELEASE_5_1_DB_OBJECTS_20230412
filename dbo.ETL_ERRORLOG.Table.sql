USE [ESG]
GO
/****** Object:  Table [dbo].[ETL_ERRORLOG]    Script Date: 4/18/2023 12:13:15 PM ******/
DROP TABLE IF EXISTS [dbo].[ETL_ERRORLOG]
GO
/****** Object:  Table [dbo].[ETL_ERRORLOG]    Script Date: 4/18/2023 12:13:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ETL_ERRORLOG](
	[CREATEDTIME] [datetime] NULL,
	[TABLENAME] [varchar](100) NULL,
	[ETLPROGRAM] [varchar](100) NULL,
	[PROCESSLOGID] [int] NULL,
	[SEVERITY] [int] NULL,
	[COMMENT] [text] NULL,
	[EXCEPTION] [varchar](1000) NULL,
	[EXECUTEDBY] [varchar](100) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
