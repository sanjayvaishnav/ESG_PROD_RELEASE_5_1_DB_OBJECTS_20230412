USE [ESG]
GO
/****** Object:  StoredProcedure [dbo].[usp_Load_TCFD_SFDR_REPORTING_SUMMARY_QuarterEndDates]    Script Date: 4/18/2023 12:13:15 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[usp_Load_TCFD_SFDR_REPORTING_SUMMARY_QuarterEndDates]
GO
/****** Object:  StoredProcedure [dbo].[usp_Load_TCFD_SFDR_REPORTING_SUMMARY_QuarterEndDates]    Script Date: 4/18/2023 12:13:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[usp_Load_TCFD_SFDR_REPORTING_SUMMARY_QuarterEndDates]
/*
Logic : 
The Stored procedure finds the 
If the @ReportDate is 2022-12-31, find previous 4 quarters(including the DEC quarter) end date and insert into [TCFD_SFDR_REPORTING_SUMMARY_QuarterEndDates].
If the @ReportDate is not 2022-12-31, find previous 4 quarters(excluding the DEC quarter) end date and insert into [TCFD_SFDR_REPORTING_SUMMARY_QuarterEndDates].
If the @ReportDate is any other, find previous 4 quarters(excluding the running quarter) end date and insert into [TCFD_SFDR_REPORTING_SUMMARY_QuarterEndDates].
-------------------------------------------------------------------------------
Created Date	Version		Created By		Comments
12-Oct-2022		0.1			Wipro			Initial version 
-------------------------------------------------------------------------------

*/
AS

BEGIN

DECLARE @MaxBatchID INT

	UPDATE [ESG].[TCFD_SFDR_REPORTING_SUMMARY_QuarterEndDates] SET [ActiveFlg] = 0
	SELECT @MaxBatchID = MAX([BatchID]) FROM [ESG].[TCFD_SFDR_REPORTING_SUMMARY_QuarterEndDates] WITH(NOLOCK)

	if @MaxBatchID is NULL
		BEGIN
			SET @MaxBatchID = 0
		END

		SELECT @MaxBatchID

	INSERT INTO [ESG].[TCFD_SFDR_REPORTING_SUMMARY_QuarterEndDates]  (
	[RollingPrevious4QuarterEndDate] ,
	[YR_QTR],
	[ActiveFlg],
	[ReportRunDate] ,
	[BatchID],
	[Reporting_Period])

	SELECT 
	[RollingPrevious4QuarterEndDate] ,
	[YR_QTR],
	[ActiveFlg],
	[ReportRunDate] ,
	@MaxBatchID + 1,
	[Reporting_Period]
	
	FROM [ESG].[TCFD_SFDR_REPORTING_SUMMARY_QuarterEndDates_Staging]


	TRUNCATE TABLE [ESG].[TCFD_SFDR_REPORTING_SUMMARY_QuarterEndDates_Staging]
END
GO
