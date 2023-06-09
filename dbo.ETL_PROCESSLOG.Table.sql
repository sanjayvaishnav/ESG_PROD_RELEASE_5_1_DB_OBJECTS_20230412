USE [ESG]
GO
/****** Object:  Table [dbo].[ETL_PROCESSLOG]    Script Date: 4/18/2023 12:13:15 PM ******/
DROP TABLE IF EXISTS [dbo].[ETL_PROCESSLOG]
GO
/****** Object:  Table [dbo].[ETL_PROCESSLOG]    Script Date: 4/18/2023 12:13:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ETL_PROCESSLOG](
	[PROCESSLOGID] [int] IDENTITY(1,1) NOT NULL,
	[TABLENAME] [varchar](100) NULL,
	[STARTTIME] [datetime] NULL,
	[ENDTIME] [datetime] NULL,
	[RECORDSPROCESSED] [int] NULL,
	[RECORDSINSERTED] [int] NULL,
	[RECORDSUPDATED] [int] NULL,
	[RECORDWITHERROR] [varchar](4000) NULL,
	[RECORDDELETED] [int] NULL,
	[SOURCETABLE] [varchar](100) NULL,
	[STATUSID] [int] NULL,
	[ETLPROGRAM] [varchar](100) NULL,
	[ETLPHASEID] [tinyint] NULL,
	[COMMENT] [varchar](max) NULL,
	[EXECUTEBY] [varchar](100) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
