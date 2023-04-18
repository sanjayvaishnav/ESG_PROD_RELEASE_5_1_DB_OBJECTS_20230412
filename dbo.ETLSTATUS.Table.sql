USE [ESG]
GO
/****** Object:  Table [dbo].[ETLSTATUS]    Script Date: 4/18/2023 12:13:15 PM ******/
DROP TABLE IF EXISTS [dbo].[ETLSTATUS]
GO
/****** Object:  Table [dbo].[ETLSTATUS]    Script Date: 4/18/2023 12:13:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ETLSTATUS](
	[StatusId] [tinyint] NULL,
	[StatusName] [varchar](20) NULL
) ON [PRIMARY]
GO
