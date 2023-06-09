USE [ESG]
GO
/****** Object:  Table [dbo].[ETLSOURCE]    Script Date: 4/18/2023 12:13:15 PM ******/
DROP TABLE IF EXISTS [dbo].[ETLSOURCE]
GO
/****** Object:  Table [dbo].[ETLSOURCE]    Script Date: 4/18/2023 12:13:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ETLSOURCE](
	[RowID] [int] IDENTITY(1,1) NOT NULL,
	[RunSeq] [int] NULL,
	[PackageName] [varchar](100) NULL,
	[SourceType] [varchar](50) NULL,
	[SourceServer] [varchar](300) NULL,
	[SourceDB] [varchar](50) NULL,
	[SourceTable] [varchar](50) NULL,
	[DestinationServer] [varchar](300) NULL,
	[DestinationDB] [varchar](50) NULL,
	[DestinationTable] [varchar](50) NULL,
	[IsActive] [bit] NULL,
	[Source_File] [varchar](1000) NULL
) ON [PRIMARY]
GO
