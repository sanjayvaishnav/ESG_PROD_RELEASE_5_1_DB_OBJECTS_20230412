USE [ESG]
GO
/****** Object:  StoredProcedure [dbo].[usp_Load_TCFD_SFDR_REPORTING_SUMMARY_CheckIfDataExists]    Script Date: 4/18/2023 12:13:15 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[usp_Load_TCFD_SFDR_REPORTING_SUMMARY_CheckIfDataExists]
GO
/****** Object:  StoredProcedure [dbo].[usp_Load_TCFD_SFDR_REPORTING_SUMMARY_CheckIfDataExists]    Script Date: 4/18/2023 12:13:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[usp_Load_TCFD_SFDR_REPORTING_SUMMARY_CheckIfDataExists]
@ExecutionDate DATETIME,
@CheckIfDataExists INT OUTPUT

/*
Logic : 
The stored procedure will 
1) Calculate Last day of the current quarter based on execution date.
2) Calculates previous 4 rolling quarters end dates
3) Find if the Data exists in TCFD_LE_SERVICE_SUM for all dates calculated in Step 2

check if the data exists for 4 quarter end dates.

USE [ESG]
GO

DECLARE	@return_value int,
		@CheckIfDataExists INT

EXEC	@return_value = [dbo].[usp_Load_TCFD_SFDR_REPORTING_SUMMARY_CheckIfDataExists]
		@ExecutionDate = N'2023-03-02',
		@CheckIfDataExists = @CheckIfDataExists OUTPUT

SELECT	@CheckIfDataExists as N'@CheckIfDataExists'

SELECT	'Return Value' = @return_value

GO

-----------------------------------------------------------------------------
Created Date	Version		Created By		Comments
17-Oct-2022		0.1			Wipro			Initial version 
-----------------------------------------------------------------------------

*/

AS
BEGIN

DECLARE
@ReportDate DATETIME = @ExecutionDate,
@EndDatesOfPreviousQuarters DATETIME,
@EndDateOfRunningQuarter DATETIME,
@LastQuarter DATETIME,
@QuarterInterval INT = -1,
@MaxBatchID INT = 0, 
@LoopCount INT = 0,
@Id INT, 
@RecordCount INT, 
@IfRecordExistsForAllQuarters INT = 0,
@Reporting_Period VARCHAR(10)


----Truncate TCFD_SFDR_REPORTING_SUMMARY_QuarterEndDates_Staging----------
TRUNCATE TABLE [ESG].[ESG].[TCFD_SFDR_REPORTING_SUMMARY_QuarterEndDates_Staging]

--- Calculate Last day of the current quarter-------------
SELECT @EndDateOfRunningQuarter = DATEADD(DAY, -1, DATEADD(QUARTER, DATEDIFF(QUARTER, 0, @ReportDate) + 1, 0))
SELECT @EndDateOfRunningQuarter,@ReportDate

----- Calculate previous 4 rolling quarters logic start ------
WHILE(@QuarterInterval > -5)
BEGIN

	IF(CAST(@EndDateOfRunningQuarter as Date) = CAST(@ReportDate as Date))
		BEGIN
			SET @EndDatesOfPreviousQuarters = (SELECT DATEADD(DAY, -1, DATEADD(QUARTER, DATEDIFF(QUARTER, 0,DATEADD(QUARTER, @QuarterInterval + 1 , @ReportDate)) + 1, 0)))
			print 1
		END
	ELSE
		BEGIN
			SET @EndDatesOfPreviousQuarters = (SELECT DATEADD(DAY, -1, DATEADD(QUARTER, DATEDIFF(QUARTER, 0,DATEADD(QUARTER, @QuarterInterval , @ReportDate)) + 1, 0)))
			print 2
		END

INSERT INTO [ESG].[ESG].[TCFD_SFDR_REPORTING_SUMMARY_QuarterEndDates_Staging]
SELECT @EndDatesOfPreviousQuarters,
CASE
        WHEN MONTH(@EndDatesOfPreviousQuarters) >= 1 AND MONTH(@EndDatesOfPreviousQuarters) <=3
        THEN Convert(varchar(4),YEAR(@EndDatesOfPreviousQuarters)) +'_' + 'Q1'

        WHEN MONTH(@EndDatesOfPreviousQuarters) >= 4 AND MONTH(@EndDatesOfPreviousQuarters) <=6
        THEN Convert(varchar(4),YEAR(@EndDatesOfPreviousQuarters)) +'_' + 'Q2'

        WHEN MONTH(@EndDatesOfPreviousQuarters) >= 7 AND MONTH(@EndDatesOfPreviousQuarters) <=9
        THEN Convert(varchar(4),YEAR(@EndDatesOfPreviousQuarters)) +'_' + 'Q3'

        WHEN MONTH(@EndDatesOfPreviousQuarters) >= 10 AND MONTH(@EndDatesOfPreviousQuarters) <=12
        THEN Convert(varchar(4),YEAR(@EndDatesOfPreviousQuarters)) +'_' + 'Q4'
    END 'QUARTER',
	1,
	GETDATE(), @MaxBatchID + 1,''

SET @QuarterInterval = @QuarterInterval - 1
END
----- Calculate previous 4 rolling quarters logic ends ------

--select * from [ESG].[ESG].[TCFD_SFDR_REPORTING_SUMMARY_QuarterEndDates_Staging]
----- Find the Latest Quarter data for the current run --------
SELECT TOP(1) @Reporting_Period = YR_QTR
FROM [ESG].[ESG].[TCFD_SFDR_REPORTING_SUMMARY_QuarterEndDates_Staging] 
WHERE [ActiveFlg] = 1
ORDER BY [RollingPrevious4QuarterEndDate] DESC

----- Update TCFD_SFDR_REPORTING_SUMMARY_QuarterEndDates_Staging with the Latest Quarter data for the current run --------
UPDATE [ESG].[ESG].[TCFD_SFDR_REPORTING_SUMMARY_QuarterEndDates_Staging] SET Reporting_Period = @Reporting_Period
WHERE [ActiveFlg] = 1

/* To be removed before final run. this is just for data validation*/
UPDATE [ESG].[ESG].[TCFD_SFDR_REPORTING_SUMMARY_QuarterEndDates_Staging] SET 
[RollingPrevious4QuarterEndDate] = '2022-12-30' where [RollingPrevious4QuarterEndDate] = '2022-12-31'


--select * from  [ESG].[ESG].[TCFD_SFDR_REPORTING_SUMMARY_QuarterEndDates_Staging] 
---- Find if the Data exists in TCFD_LE_SERVICE_SUM for all dates of [TCFD_SFDR_REPORTING_SUMMARY_QuarterEndDates_Staging] ----------
SELECT TOP 1 @Id = ID from [ESG].[ESG].[TCFD_SFDR_REPORTING_SUMMARY_QuarterEndDates_Staging] WHERE ActiveFlg = 1 ORDER BY ID ASC
WHILE (@LoopCount < 4)
BEGIN

	SELECT @RecordCount = COUNT(1) FROM [ESG].[TCFD_LE_SERVICE_SUM] WITH (NOLOCK) WHERE [DATE] IN 
	(SELECT RollingPrevious4QuarterEndDate FROM [ESG].[ESG].[TCFD_SFDR_REPORTING_SUMMARY_QuarterEndDates_Staging] WHERE ActiveFlg = 1 AND ID = @Id)

	IF (@RecordCount > 0)
		BEGIN
			SET @IfRecordExistsForAllQuarters = @IfRecordExistsForAllQuarters + 1
		END
	SET @LoopCount = @LoopCount + 1
	SET @Id = @Id + 1

END

IF (@IfRecordExistsForAllQuarters = 4)
BEGIN
	SET @CheckIfDataExists = 1
END

ELSE
BEGIN
	SET @CheckIfDataExists = -1
END

END
GO
