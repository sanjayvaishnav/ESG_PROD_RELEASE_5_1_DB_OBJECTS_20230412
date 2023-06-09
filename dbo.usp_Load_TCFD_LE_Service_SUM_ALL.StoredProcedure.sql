USE [ESG]
GO
/****** Object:  StoredProcedure [dbo].[usp_Load_TCFD_LE_Service_SUM_ALL]    Script Date: 4/18/2023 12:13:15 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[usp_Load_TCFD_LE_Service_SUM_ALL]
GO
/****** Object:  StoredProcedure [dbo].[usp_Load_TCFD_LE_Service_SUM_ALL]    Script Date: 4/18/2023 12:13:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[usp_Load_TCFD_LE_Service_SUM_ALL]

/*
Logic :

USE [ESG]
GO

exec [dbo].[usp_Load_TCFD_LE_Service_SUM_ALL]

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
@return_value2 INT

SET @LoopCounter = 1

drop table if exists #dates ;
select  date into #dates from [ESG].[ESG].[ESG_Holdings_EOM]
where 
--date = EOMONTH (date) 
--and
date > ( select max(DATE) from [ESG].[TCFD_LE_Service_SUM])
 group by date
order by date desc;

declare @dates varchar(500)

--select @dates= Stuff((select ','+ cast(date as varchar(500))  from #dates for xml path('')),1,1,'') 
select @dates = '2022-12-30'


SELECT @TotalCountOfReportingGroup = count(1) 
FROM [ESG].[TCFD_LE_SERVICE_SUM_Reporting_Group] 
where [EXECUTION_STATUS] = 0 and [ACTIVEFLG] = 1

WHILE (@LoopCounter <= @TotalCountOfReportingGroup)
BEGIN

SELECT top 1 @reporting_group = [REPORTING_GROUP] 
FROM [ESG].[TCFD_LE_SERVICE_SUM_Reporting_Group] 
where [EXECUTION_STATUS] = 0 and [ACTIVEFLG] = 1

SELECT @reporting_group

INSERT INTO [ESG].[TCFD_LE_SERVICE_LOG] VALUES (GETDATE(),'usp_Load_TCFD_LE_Service_SUM_ALL','Executing While Loop for ' + @reporting_group) 

INSERT INTO [ESG].[TCFD_LE_SERVICE_LOG] VALUES (GETDATE(),'usp_Load_TCFD_LE_Service_SUM_ALL',
'Before execution of usp_Load_TCFD_LE_Service_SUM_Temp_SourceTable for ' + @reporting_group) 

EXEC	@return_value = [dbo].[usp_Load_TCFD_LE_Service_SUM_Temp_SourceTable]
		@reporting_group = @reporting_group,
		@dates = @dates

--SELECT @return_value

INSERT INTO [ESG].[TCFD_LE_SERVICE_LOG] VALUES (GETDATE(),'usp_Load_TCFD_LE_Service_SUM_ALL',
'After execution of usp_Load_TCFD_LE_Service_SUM_Temp_SourceTable for ' + @reporting_group) 

IF (@return_value = 1 or @return_value = 2)
	BEGIN

	INSERT INTO [ESG].[TCFD_LE_SERVICE_LOG] VALUES (GETDATE(),'usp_Load_TCFD_LE_Service_SUM_ALL',
	'Before execution of usp_Load_TCFD_LE_Service_SUM_Temp_Calculations for ' + @reporting_group) 

		EXEC	@return_value2 = [dbo].[usp_Load_TCFD_LE_Service_SUM_Calculations]
		@reporting_group = @reporting_group

		SELECT @return_value2

	INSERT INTO [ESG].[TCFD_LE_SERVICE_LOG] VALUES (GETDATE(),'usp_Load_TCFD_LE_Service_SUM_ALL',
	'After execution of usp_Load_TCFD_LE_Service_SUM_Temp_Calculations for ' + @reporting_group) 

	END

UPDATE [ESG].[TCFD_LE_SERVICE_SUM_Reporting_Group]
SET [EXECUTION_STATUS] = 1 , [EXECUTION_DATE] = CAST(GETDATE() AS date)
WHERE [REPORTING_GROUP] = @reporting_group

INSERT INTO [ESG].[TCFD_LE_SERVICE_LOG] VALUES (GETDATE(),'usp_Load_TCFD_LE_Service_SUM_ALL',
'After updating [ESG].[TCFD_LE_SERVICE_SUM_Reporting_Group] for ' + @reporting_group) 

SET @LoopCounter = @LoopCounter + 1
END

END
GO
