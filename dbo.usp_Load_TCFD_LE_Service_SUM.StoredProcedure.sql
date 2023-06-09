USE [ESG]
GO
/****** Object:  StoredProcedure [dbo].[usp_Load_TCFD_LE_Service_SUM]    Script Date: 4/18/2023 12:13:15 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[usp_Load_TCFD_LE_Service_SUM]
GO
/****** Object:  StoredProcedure [dbo].[usp_Load_TCFD_LE_Service_SUM]    Script Date: 4/18/2023 12:13:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[usp_Load_TCFD_LE_Service_SUM]


/*
Logic : This stored procedure will 
1) call usp_Load_TCFD_LE_Service_SUM_SOURCE_TABLE
2) call usp_Load_TCFD_LE_Service_SUM_Calculations_Sovereign_EU_SANCTIONS
3) call usp_Load_TCFD_LE_Service_SUM_Calculations

Load data into TCFD_LE_SERVICE_SUM


USE [ESG]
GO

exec [dbo].[usp_Load_TCFD_LE_Service_SUM]

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
@dates varchar(500)

SET @LoopCounter = 1

drop table if exists #dates ;
select date into #dates from [ESG].[ESG].[ESG_Holdings_EOM]
where
date > ( select max(DATE) from [ESG].[TCFD_LE_Service_SUM])
group by date
order by date desc;

select @dates= Stuff((select ','+ cast(date as varchar(500))  from #dates for xml path('')),1,1,'') 
select @dates

SELECT @TotalCountOfReportingGroup = count(1) 
FROM [ESG].[TCFD_LE_SERVICE_SUM_Reporting_Group] 
where [EXECUTION_STATUS] = 0 and [ACTIVEFLG] = 1

WHILE (@LoopCounter <= @TotalCountOfReportingGroup)
	BEGIN

		SELECT top 1 @reporting_group = [REPORTING_GROUP] FROM [ESG].[TCFD_LE_SERVICE_SUM_Reporting_Group] where 
		[EXECUTION_STATUS] = 0 and 
		[ACTIVEFLG] = 1

		INSERT INTO [ESG].[TCFD_LE_SERVICE_LOG] VALUES (GETDATE(),'usp_Load_TCFD_LE_Service_SUM','Before execution of usp_Load_TCFD_LE_Service_SUM_SOURCE_TABLE for ' + @reporting_group) 

		--select @reporting_group,@dates

		EXEC @return_value = [dbo].[usp_Load_TCFD_LE_Service_SUM_SOURCE_TABLE]
		@reporting_group = @reporting_group,
		@dates = @dates

		INSERT INTO [ESG].[TCFD_LE_SERVICE_LOG] VALUES (GETDATE(),'usp_Load_TCFD_LE_Service_SUM','After execution of usp_Load_TCFD_LE_Service_SUM_SOURCE_TABLE for ' + @reporting_group) 

		IF (@return_value = 1)
			BEGIN

			INSERT INTO [ESG].[TCFD_LE_SERVICE_LOG] VALUES (GETDATE(),'usp_Load_TCFD_LE_Service_SUM','Before execution of usp_Load_TCFD_LE_Service_SUM_Calculations_Sovereign_EU_SANCTIONS for ' + @reporting_group) 
				
			EXEC @return_value2 = [dbo].[usp_Load_TCFD_LE_Service_SUM_Calculations_Sovereign_EU_SANCTIONS]

			IF (@return_value2 = 1)
			BEGIN
				INSERT INTO [ESG].[TCFD_LE_SERVICE_LOG] VALUES (GETDATE(),'usp_Load_TCFD_LE_Service_SUM','After execution of usp_Load_TCFD_LE_Service_SUM_Calculations for ' + @reporting_group)

				EXEC @return_value3 = [dbo].[usp_Load_TCFD_LE_Service_SUM_Calculations] @reporting_group = @reporting_group,@dates = @dates
			END

				SELECT @return_value,@return_value2,@return_value3
			END

		UPDATE [ESG].[TCFD_LE_SERVICE_SUM_Reporting_Group]
		SET [EXECUTION_STATUS] = 1 , [EXECUTION_DATE] = CAST(GETDATE() AS date)
		WHERE [REPORTING_GROUP] = @reporting_group

		INSERT INTO [ESG].[TCFD_LE_SERVICE_LOG] VALUES (GETDATE(),'usp_Load_TCFD_LE_Service_SUM','After updating [ESG].[TCFD_LE_SERVICE_SUM_Reporting_Group] for ' + @reporting_group) 

SET @LoopCounter = @LoopCounter + 1
END

END
GO
