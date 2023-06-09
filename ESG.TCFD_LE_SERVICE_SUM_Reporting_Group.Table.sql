USE [ESG]
GO
/****** Object:  Table [ESG].[TCFD_LE_SERVICE_SUM_Reporting_Group]    Script Date: 4/18/2023 12:13:15 PM ******/
DROP TABLE IF EXISTS [ESG].[TCFD_LE_SERVICE_SUM_Reporting_Group]
GO
/****** Object:  Table [ESG].[TCFD_LE_SERVICE_SUM_Reporting_Group]    Script Date: 4/18/2023 12:13:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ESG].[TCFD_LE_SERVICE_SUM_Reporting_Group](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[REPORTING_GROUP] [varchar](50) NULL,
	[EXECUTION_STATUS] [char](1) NULL,
	[EXECUTION_DATE] [date] NULL,
	[ACTIVEFLG] [char](1) NULL
) ON [PRIMARY]
GO
