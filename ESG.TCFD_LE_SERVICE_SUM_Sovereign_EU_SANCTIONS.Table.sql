USE [ESG]
GO
/****** Object:  Table [ESG].[TCFD_LE_SERVICE_SUM_Sovereign_EU_SANCTIONS]    Script Date: 4/18/2023 12:13:15 PM ******/
DROP TABLE IF EXISTS [ESG].[TCFD_LE_SERVICE_SUM_Sovereign_EU_SANCTIONS]
GO
/****** Object:  Table [ESG].[TCFD_LE_SERVICE_SUM_Sovereign_EU_SANCTIONS]    Script Date: 4/18/2023 12:13:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ESG].[TCFD_LE_SERVICE_SUM_Sovereign_EU_SANCTIONS](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[DATE] [date] NULL,
	[MSCI_AS_OF_DATE] [date] NULL,
	[Legal_Entity] [varchar](255) NULL,
	[MV_EUR] [decimal](38, 8) NULL,
	[Service_Category] [varchar](255) NULL,
	[GOVERNMENT_EU_SANCTIONS_COV] [decimal](38, 8) NULL,
	[unique_sov_sanctions_count] [decimal](38, 8) NULL,
	[ASSET_GROUP] [varchar](255) NULL,
	[unique_sov_sanctions_pct] [decimal](38, 8) NULL
) ON [PRIMARY]
GO
