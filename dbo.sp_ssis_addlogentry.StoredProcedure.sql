USE [ESG]
GO
/****** Object:  StoredProcedure [dbo].[sp_ssis_addlogentry]    Script Date: 4/18/2023 12:13:15 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[sp_ssis_addlogentry]
GO
/****** Object:  StoredProcedure [dbo].[sp_ssis_addlogentry]    Script Date: 4/18/2023 12:13:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_ssis_addlogentry]  @event sysname,  @computer nvarchar(128),  @operator nvarchar(128),  @source nvarchar(1024),  @sourceid uniqueidentifier,  @executionid uniqueidentifier,  @starttime datetime,  @endtime datetime,  @datacode int,  @databytes image,  @message nvarchar(2048)AS  INSERT INTO sysssislog (      event,      computer,      operator,      source,      sourceid,      executionid,      starttime,      endtime,      datacode,      databytes,      message )  VALUES (      @event,      @computer,      @operator,      @source,      @sourceid,      @executionid,      @starttime,      @endtime,      @datacode,      @databytes,      @message )  RETURN 0
GO
