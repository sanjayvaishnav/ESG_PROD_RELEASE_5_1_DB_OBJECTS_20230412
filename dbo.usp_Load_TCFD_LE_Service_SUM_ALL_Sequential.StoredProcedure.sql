USE [ESG]
GO
/****** Object:  StoredProcedure [dbo].[usp_Load_TCFD_LE_Service_SUM_ALL_Sequential]    Script Date: 4/18/2023 12:13:15 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[usp_Load_TCFD_LE_Service_SUM_ALL_Sequential]
GO
/****** Object:  StoredProcedure [dbo].[usp_Load_TCFD_LE_Service_SUM_ALL_Sequential]    Script Date: 4/18/2023 12:13:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[usp_Load_TCFD_LE_Service_SUM_ALL_Sequential]
(
@RunDates Date,
@MultipleDateRun char(1)
)

/*
Logic : This stored procedure will 
1) call usp_Load_TCFD_LE_Service_SUM_Temp_SourceTable
2) call usp_Load_TCFD_LE_Service_SUM_Calculations_NewPAI_Sovereign_EU_SANCTIONS
3) call usp_Load_TCFD_LE_Service_SUM_Calculations_NewPAI

Load data into TCFD_LE_SERVICE_SUM_POC


If @MultipleDateRun = 1 then multiple months data will get processed
if @MultipleDateRun = 0 then one month data will get processed


USE [ESG]
GO

DECLARE	@return_value int

EXEC	@return_value = [dbo].[usp_Load_TCFD_LE_Service_SUM_ALL_Sequential]
		@RunDates = '2021-11-30',
		@MultipleDateRun = N'1'

SELECT	'Return Value' = @return_value

GO
-------------------------------------------------------------------------------
Created Date	Version		Created By		Comments
01-FEB-2023		0.1			Wipro			Initial version 
-------------------------------------------------------------------------------

*/

AS
BEGIN

DECLARE @TotalCountOfReportingGroup INT, 
@LoopCounter INT, 
@reporting_group VARCHAR(50),
@return_value INT,
@return_value2 INT,
@return_value3 INT,
@MonthCounter INT = 0,
@TotalMonthCount INT = 0,
@dates varchar(500),
@RunDate Date

SET @LoopCounter = 1

DECLARE @table_Dates TABLE  (
    [Date] [date] NULL,
    [Active_Flag] [char](1) NULL
);

IF (@MultipleDateRun = 1)
BEGIN
	insert into @table_Dates 
	select date, 1 from [ESG].[ESG].[ESG_Holdings_EOM]
	where
	date > @RunDates
	group by date
	order by date desc; 
END
ELSE
BEGIN
	insert into @table_Dates 
	select date, 1 from [ESG].[ESG].[ESG_Holdings_EOM]
	where
	date = @RunDates
	group by date
	order by date desc; 
END

SELECT @TotalMonthCount = COUNT(1) from @table_Dates
SELECT * from @table_Dates order by date desc 

SELECT @TotalCountOfReportingGroup = count(1) 
FROM [ESG].[TCFD_LE_SERVICE_SUM_Reporting_Group] 
where [EXECUTION_STATUS] = 0 and [ACTIVEFLG] = 1

SELECT @MonthCounter,@TotalMonthCount
WHILE(@MonthCounter < @TotalMonthCount)
BEGIN
	SELECT @dates = [Date] from @table_Dates WHERE Active_Flag = 1 order by date desc

				--WHILE (@LoopCounter <= @TotalCountOfReportingGroup)
				--BEGIN

					SELECT top 1 @reporting_group = [REPORTING_GROUP] FROM [ESG].[TCFD_LE_SERVICE_SUM_Reporting_Group] where 
					[EXECUTION_STATUS] = 0 and [ACTIVEFLG] = 1

					INSERT INTO [ESG].[TCFD_LE_SERVICE_LOG] VALUES (GETDATE(),'usp_Load_TCFD_LE_Service_SUM_ALL','Before execution of usp_Load_TCFD_LE_Service_SUM_Temp_SourceTable for ' + @reporting_group) 

					--select @reporting_group,@dates

					EXEC @return_value = [dbo].usp_Load_TCFD_LE_Service_SUM_SOURCE_TABLE
					@reporting_group = @reporting_group,
					@dates = @dates

					INSERT INTO [ESG].[TCFD_LE_SERVICE_LOG] VALUES (GETDATE(),'usp_Load_TCFD_LE_Service_SUM_ALL','After execution of usp_Load_TCFD_LE_Service_SUM_Temp_SourceTable for ' + @reporting_group) 

					IF (@return_value = 1)
						BEGIN

						INSERT INTO [ESG].[TCFD_LE_SERVICE_LOG] VALUES (GETDATE(),'usp_Load_TCFD_LE_Service_SUM_ALL','Before execution of usp_Load_TCFD_LE_Service_SUM_Calculations_NewPAI_Sovereign_EU_SANCTIONS for ' + @reporting_group) 
				
						EXEC @return_value2 = [dbo].usp_Load_TCFD_LE_Service_SUM_Calculations_Sovereign_EU_SANCTIONS 

						IF (@return_value2 = 1)
						BEGIN
							INSERT INTO [ESG].[TCFD_LE_SERVICE_LOG] VALUES (GETDATE(),'usp_Load_TCFD_LE_Service_SUM_ALL','After execution of usp_Load_TCFD_LE_Service_SUM_Calculations_NewPAI for ' + @reporting_group)

							EXEC @return_value3 = [dbo].usp_Load_TCFD_LE_Service_SUM_Calculations @reporting_group = @reporting_group,@dates = @dates
						END

							SELECT @return_value,@return_value2,@return_value3
						END

						INSERT INTO [ESG].[TCFD_LE_SERVICE_LOG] VALUES (GETDATE(),'usp_Load_TCFD_LE_Service_SUM_ALL','After updating [ESG].[TCFD_LE_SERVICE_SUM_Reporting_Group] for ' + @reporting_group) 

						--SET @LoopCounter = @LoopCounter + 1
				--END

			UPDATE @table_Dates SET Active_Flag = 0 WHERE Date = @dates

SET @MonthCounter = @MonthCounter + 1
END

UPDATE [ESG].[TCFD_LE_SERVICE_SUM_Reporting_Group]
SET [EXECUTION_STATUS] = 1 , [EXECUTION_DATE] = CAST(GETDATE() AS date)
WHERE [REPORTING_GROUP] = @reporting_group
END
GO
