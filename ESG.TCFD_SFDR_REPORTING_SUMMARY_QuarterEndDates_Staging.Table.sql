USE [ESG]
GO
/****** Object:  Table [ESG].[TCFD_SFDR_REPORTING_SUMMARY_QuarterEndDates_Staging]    Script Date: 4/18/2023 12:13:15 PM ******/
DROP TABLE IF EXISTS [ESG].[TCFD_SFDR_REPORTING_SUMMARY_QuarterEndDates_Staging]
GO
/****** Object:  Table [ESG].[TCFD_SFDR_REPORTING_SUMMARY_QuarterEndDates_Staging]    Script Date: 4/18/2023 12:13:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ESG].[TCFD_SFDR_REPORTING_SUMMARY_QuarterEndDates_Staging](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[RollingPrevious4QuarterEndDate] [date] NULL,
	[YR_QTR] [varchar](10) NULL,
	[ActiveFlg] [char](1) NULL,
	[ReportRunDate] [datetime] NULL,
	[BatchID] [int] NULL,
	[Reporting_Period] [varchar](10) NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
