USE [ESG]
GO
/****** Object:  Table [ESG].[TCFD_LE_SERVICE_LOG]    Script Date: 4/18/2023 12:13:15 PM ******/
DROP TABLE IF EXISTS [ESG].[TCFD_LE_SERVICE_LOG]
GO
/****** Object:  Table [ESG].[TCFD_LE_SERVICE_LOG]    Script Date: 4/18/2023 12:13:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ESG].[TCFD_LE_SERVICE_LOG](
	[CREATEDTIME] [datetime] NULL,
	[PROCEDURENAME] [varchar](100) NULL,
	[COMMENT] [text] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
