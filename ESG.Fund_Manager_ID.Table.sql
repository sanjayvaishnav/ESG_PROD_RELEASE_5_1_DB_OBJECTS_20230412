USE [ESG]
GO
/****** Object:  Table [ESG].[Fund_Manager_ID]    Script Date: 4/18/2023 12:13:15 PM ******/
DROP TABLE IF EXISTS [ESG].[Fund_Manager_ID]
GO
/****** Object:  Table [ESG].[Fund_Manager_ID]    Script Date: 4/18/2023 12:13:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ESG].[Fund_Manager_ID](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[FUND_NAME] [varchar](255) NOT NULL,
	[FUND_MANAGER] [varchar](255) NOT NULL,
	[FM_EMAIL] [varchar](255) NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
