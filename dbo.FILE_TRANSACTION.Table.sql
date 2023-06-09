USE [ESG]
GO
/****** Object:  Table [dbo].[FILE_TRANSACTION]    Script Date: 4/18/2023 12:13:15 PM ******/
DROP TABLE IF EXISTS [dbo].[FILE_TRANSACTION]
GO
/****** Object:  Table [dbo].[FILE_TRANSACTION]    Script Date: 4/18/2023 12:13:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FILE_TRANSACTION](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Step_Name] [varchar](100) NULL,
	[FlatFileName] [varchar](300) NULL,
	[RecordsInserted] [int] NULL,
	[Dated] [date] NULL
) ON [PRIMARY]
GO
