USE [ESG]
GO
/****** Object:  StoredProcedure [dbo].[usp_MSCIFilecheck]    Script Date: 4/18/2023 12:13:15 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[usp_MSCIFilecheck]
GO
/****** Object:  StoredProcedure [dbo].[usp_MSCIFilecheck]    Script Date: 4/18/2023 12:13:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[usp_MSCIFilecheck]
(@status INT OUTPUT)

/*
-----------------------------------------------------------------------------------------------------------------------------------------------------------
Created Date	Version		Created/Modidied By		Comments
13-Sep-2022		0.1			Wipro				Initial version
20-Sep-2022		0.2			Wipro				Removed hardcoding for @BasePath
26-Sep-2022		0.3			Wipro				Changed @BasePath for ESG_RATING files
-----------------------------------------------------------------------------------------------------------------------------------------------------------

*/

AS
BEGIN
		DECLARE 
		@TSW_BISR_FilesExist INT = 1,					-- value 0 suggests that files do not exist
		@TSW_ClimateChange_FilesExist INT = 1,
		@TSW_Controversies_FilesExist INT = 1,
		@TSW_EuTaxonomy_FilesExist INT = 1,
		@TSW_FundRatings_StandardCoverage_FilesExist INT = 1,
		@TSW_FundRatings_StandardCoverage_ClimateChange_FilesExist INT = 1,
		@TSW_FundRatings_StandardCoverage_EUSustainableFinance_FilesExist INT = 1,
		@TSW_GovRatings_FilesExist INT = 1,
		@TSW_SDG_FilesExist INT = 1,
		@TSW_SecurityLevelReferenceFile_FilesExist INT = 1,
		@TSW_SFDR_FilesExist INT = 1,
		@EQUITY_GLOBAL_wcuse_FilesExist INT = 1,
		@FI_CORPORATE_ALL_wcuse_FilesExist INT = 1,

		@BasePath_ESG_FACTOR_FEED VARCHAR(100) ,
		@BasePath_ESG_RATING VARCHAR(100) ,

		@ErrorMessage varchar(500)


		DECLARE @Files_For_ESG_FACTOR_FEED TABLE ([FileName] VARCHAR(100),Depth INT,[File] INT)
		DECLARE @Files_ESG_RATING TABLE ([FileName] VARCHAR(100),Depth INT,[File] INT)

		/* Finding the path for TSW files */
		SELECT @BasePath_ESG_FACTOR_FEED = [SourceServer] FROM [ESG].[dbo].[ETLSource] WHERE PackageName = 'MSCIFileCheck.dtsx' and Source_File = 'ESG_FACTOR_FEED'

		/* Finding the path for SUMMARY_SCORES files */
		SELECT @BasePath_ESG_RATING = [SourceServer] FROM [ESG].[dbo].[ETLSource] WHERE PackageName = 'MSCIFileCheck.dtsx' and Source_File = 'ESG_RATING'

		/* Insert into table the TSW files */
		INSERT INTO @Files_For_ESG_FACTOR_FEED EXEC master.sys.xp_dirtree @BasePath_ESG_FACTOR_FEED, 1, 1;

		/* Insert into table the SUMMARY_SCORES files */
		INSERT INTO @Files_ESG_RATING EXEC master.sys.xp_dirtree @BasePath_ESG_RATING, 1, 1;

		SET @ErrorMessage = 'File which do not exists are ';

		/* Condition check for ESG FACTOR FEED files. */
		IF Not Exists (SELECT TOP 1 * FROM @Files_For_ESG_FACTOR_FEED WHERE [FileName] LIKE '10122_TSW_BISR_2%' and  [FileName] not LIKE '%~%$%')
		BEGIN
		SET @ErrorMessage = @ErrorMessage + '10122_TSW_BISR_ ,'
		SET @TSW_BISR_FilesExist = 0
		END

		IF Not Exists (SELECT TOP 1 * FROM @Files_For_ESG_FACTOR_FEED WHERE [FileName] LIKE '10122_TSW_ClimateChange_2%' and  [FileName] not LIKE '%~%$%')
		BEGIN
		SET @ErrorMessage = @ErrorMessage + '10122_TSW_ClimateChange_ ,'
		SET @TSW_ClimateChange_FilesExist = 0
		END

		IF Not Exists (SELECT TOP 1 * FROM @Files_For_ESG_FACTOR_FEED WHERE [FileName] LIKE '10122_TSW_Controversies_2%' and  [FileName] not LIKE '%~%$%')
		BEGIN
		SET @ErrorMessage = @ErrorMessage + '10122_TSW_Controversies_ ,'
		SET @TSW_Controversies_FilesExist = 0
		END
	
		IF Not Exists (SELECT TOP 1 * FROM @Files_For_ESG_FACTOR_FEED WHERE [FileName] LIKE '10122_TSW_EuTaxonomy_2%' and  [FileName] not LIKE '%~%$%')
		BEGIN
		SET @ErrorMessage = @ErrorMessage + '10122_TSW_EuTaxonomy_ ,'
		SET @TSW_EuTaxonomy_FilesExist = 0
		END

		IF Not Exists (SELECT TOP 1 * FROM @Files_For_ESG_FACTOR_FEED WHERE [FileName] LIKE '10122_TSW_FundRatings_StandardCoverage_2%' and  [FileName] not LIKE '%~%$%')
		BEGIN
		SET @ErrorMessage = @ErrorMessage + '10122_TSW_FundRatings_StandardCoverage_ ,'
		SET @TSW_FundRatings_StandardCoverage_FilesExist = 0
		END

		IF Not Exists (SELECT TOP 1 * FROM @Files_For_ESG_FACTOR_FEED WHERE [FileName] LIKE '10122_TSW_FundRatings_StandardCoverage_ClimateChange_2%' and  [FileName] not LIKE '%~%$%' )
		BEGIN
		SET @ErrorMessage = @ErrorMessage + '10122_TSW_FundRatings_StandardCoverage_ClimateChange_ ,'
		SET @TSW_FundRatings_StandardCoverage_ClimateChange_FilesExist = 0
		END

		IF Not Exists (SELECT TOP 1 * FROM @Files_For_ESG_FACTOR_FEED WHERE [FileName] LIKE '10122_TSW_FundRatings_StandardCoverage_EUSustainableFinance_2%' and  [FileName] not LIKE '%~%$%' )
		BEGIN
		SET @ErrorMessage = @ErrorMessage + '10122_TSW_FundRatings_StandardCoverage_EUSustainableFinance_ ,'
		SET @TSW_FundRatings_StandardCoverage_EUSustainableFinance_FilesExist = 0
		END

		IF Not Exists (SELECT TOP 1 * FROM @Files_For_ESG_FACTOR_FEED WHERE [FileName] LIKE '10122_TSW_GovRatings_2%' and  [FileName] not LIKE '%~%$%' )
		BEGIN
		SET @ErrorMessage = @ErrorMessage + '10122_TSW_GovRatings_ ,'
		SET @TSW_GovRatings_FilesExist = 0
		END

		IF Not Exists (SELECT TOP 1 * FROM @Files_For_ESG_FACTOR_FEED WHERE [FileName] LIKE '10122_TSW_SDG_2%' and  [FileName] not LIKE '%~%$%' )
		BEGIN
		SET @ErrorMessage = @ErrorMessage + '10122_TSW_GovRatings_ ,'
		SET @TSW_SDG_FilesExist = 0
		END

		IF Not Exists (SELECT TOP 1 * FROM @Files_For_ESG_FACTOR_FEED WHERE [FileName] LIKE '10122_TSW_SecurityLevelReferenceFile_2%' and  [FileName] not LIKE '%~%$%' )
		BEGIN
		SET @ErrorMessage = @ErrorMessage + '10122_TSW_SecurityLevelReferenceFile_ ,'
		SET @TSW_SecurityLevelReferenceFile_FilesExist = 0
		END

		IF Not Exists (SELECT TOP 1 * FROM @Files_For_ESG_FACTOR_FEED WHERE [FileName] LIKE '10122_TSW_SFDR_2%' and  [FileName] not LIKE '%~%$%')
		BEGIN
		SET @ErrorMessage = @ErrorMessage + '10122_TSW_SFDR_ ,'
		SET @TSW_SFDR_FilesExist = 0
		END

		/* Condition check for 'EQUITY_GLOBAL_SUMMARY_SCORES and FI_CORPORATE_ALL_SUMMARY_SCORES. */
		IF Not Exists (SELECT TOP 1 * FROM @Files_ESG_RATING WHERE [FileName] LIKE 'EQUITY_GLOBAL_SUMMARY_SCORES_2%' and  [FileName] not LIKE '%~%$%' )
		BEGIN
		SET @ErrorMessage = @ErrorMessage + 'EQUITY_GLOBAL_SUMMARY_SCORES_ ,'
		SET @EQUITY_GLOBAL_wcuse_FilesExist = 0
		END

		IF Not Exists (SELECT TOP 1 * FROM @Files_ESG_RATING WHERE [FileName] LIKE 'FI_CORPORATE_ALL_SUMMARY_SCORES_2%' and  [FileName] not LIKE '%~%$%' )
		BEGIN
		SET @ErrorMessage = @ErrorMessage + 'FI_CORPORATE_ALL_SUMMARY_SCORES_ ,'
		SET @FI_CORPORATE_ALL_wcuse_FilesExist = 0
		END

		IF (@TSW_BISR_FilesExist = 0
		OR @TSW_ClimateChange_FilesExist = 0
		OR @TSW_Controversies_FilesExist = 0
		OR @TSW_EuTaxonomy_FilesExist = 0
		OR @TSW_FundRatings_StandardCoverage_FilesExist = 0 
		OR @TSW_FundRatings_StandardCoverage_ClimateChange_FilesExist = 0 
		OR @TSW_FundRatings_StandardCoverage_EUSustainableFinance_FilesExist = 0 
		OR @TSW_GovRatings_FilesExist = 0 
		OR @TSW_SDG_FilesExist = 0 
		OR @TSW_SecurityLevelReferenceFile_FilesExist = 0
		OR @TSW_SFDR_FilesExist = 0
		OR @EQUITY_GLOBAL_wcuse_FilesExist = 0 
		OR @FI_CORPORATE_ALL_wcuse_FilesExist = 0)

	BEGIN
		SET @status = 0
		INSERT INTO [ESG].[dbo].[ETL_ErrorLog] VALUES (GETDATE(),NULL,'MSCIFilecheck',NULL,0, '',@ErrorMessage, convert(varchar(100), suser_sname()))
	END
	ELSE
	BEGIN
		SET @status = 1
	END

END
GO
