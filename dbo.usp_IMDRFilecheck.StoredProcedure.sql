USE [ESG]
GO
/****** Object:  StoredProcedure [dbo].[usp_IMDRFilecheck]    Script Date: 4/18/2023 12:13:15 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[usp_IMDRFilecheck]
GO
/****** Object:  StoredProcedure [dbo].[usp_IMDRFilecheck]    Script Date: 4/18/2023 12:13:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[usp_IMDRFilecheck]
(@status int output)
/*
-------------------------------------------------------------------------------
Created Date	Version		Created By		Comments
13-Sep-2022		0.1			Wipro			Initial version
20-Sep-2022		0.2			Wipro			Changed the @BasePath. Reading from ETLSource table.
-------------------------------------------------------------------------------

*/
AS
BEGIN
    DECLARE @NAV_Summary_FilesExist INT = 1,
            @PF_Breakdown_FilesExist INT = 1,
			@BasePath VARCHAR(100),
			@ErrorMessage varchar(500)
            --@BasePath VARCHAR(100) --= '\\dd01fpsv01\shared\WiPro\IMDR\'

SELECT  @BasePath = [SourceServer] FROM [ESG].[dbo].[ETLSource] WHERE PackageName = 'IMDRFileCheck.dtsx'

    DECLARE @Files TABLE (
        [FileName] VARCHAR(100),
        Depth INT,
        [File] INT)

    INSERT INTO @Files
    EXEC master.sys.xp_dirtree @BasePath, 1, 1;

	--select * from @Files

	SET @ErrorMessage = 'File which do not exists are ';

	IF Not Exists (SELECT TOP 1 * FROM @Files WHERE [FileName] LIKE '%NAV_Summary%' and  [FileName] not LIKE '%~%$%')
	BEGIN
		SET @ErrorMessage = @ErrorMessage + 'NAV_Summary ,'
		SET @NAV_Summary_FilesExist = 0
	END

	IF Not Exists (SELECT TOP 1 * FROM @Files WHERE [FileName] LIKE '%PF_BREAKDOWN%' and  [FileName] not LIKE '%~%$%')
	BEGIN
		SET @ErrorMessage = @ErrorMessage + 'PF_BREAKDOWN ,'
		SET @PF_Breakdown_FilesExist = 0
	END


	IF (@NAV_Summary_FilesExist = 0 OR @PF_Breakdown_FilesExist = 0)

	BEGIN
		SET @status = 0
		INSERT INTO [ESG].[dbo].[ETL_ErrorLog] VALUES (GETDATE(),NULL,'IMDRFilecheck',NULL,0, '',@ErrorMessage, convert(varchar(100), suser_sname()))
	END
	ELSE
	BEGIN
		SET @status = 1
	END

    --SELECT TOP 1 @NAV_Summary_FilesExist = 1
    --  FROM @Files
    -- WHERE  [FileName] LIKE '%NAV_Summary%' and  [FileName] not LIKE '%~%$%' 


    --SELECT TOP 1 @PF_Breakdown_FilesExist1 = 1
    --  FROM @Files
    -- WHERE [FileName] LIKE '%PF_BREAKDOWN%' and  [FileName] not LIKE '%~%$%' 

    --SELECT @status= case
    --            when @NAV_Summary_FilesExist = 1
    --             and @PF_Breakdown_FilesExist = 1 then 1
    --            else 0 end
END
GO
