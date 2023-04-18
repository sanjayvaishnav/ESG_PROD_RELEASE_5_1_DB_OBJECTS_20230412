USE [ESG]
GO
/****** Object:  Table [dbo].[ETL_PHASE]    Script Date: 4/18/2023 12:13:15 PM ******/
DROP TABLE IF EXISTS [dbo].[ETL_PHASE]
GO
/****** Object:  Table [dbo].[ETL_PHASE]    Script Date: 4/18/2023 12:13:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ETL_PHASE](
	[ETLPHASEID] [tinyint] NULL,
	[PHASENAME] [varchar](20) NULL,
	[ISACTIVE] [bit] NULL
) ON [PRIMARY]
GO
