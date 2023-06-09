USE [ESG]
GO
/****** Object:  StoredProcedure [dbo].[usp_ETLUpdateProcessLog]    Script Date: 4/18/2023 12:13:15 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[usp_ETLUpdateProcessLog]
GO
/****** Object:  StoredProcedure [dbo].[usp_ETLUpdateProcessLog]    Script Date: 4/18/2023 12:13:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[usp_ETLUpdateProcessLog]
    @ProcessLogId int,
    @EndTime datetime = null,
    @StatusID int = Null,
    @RecordProcessed int = null,
    @RecordInserted int = null,
    @RecordUpdated int = null,
    --@RecordWithError varchar(4000),
    @Comment varchar(max) = Null
As
Begin

    Declare @Commnet_column_length int = 0;

    select @Commnet_column_length = CHARACTER_MAXIMUM_LENGTH
      from INFORMATION_SCHEMA.COLUMNS
     where TABLE_NAME    = 'ETL_ProcessLog'
       and TABLE_SCHEMA  = 'dbo'
       and TABLE_CATALOG = DB_NAME()
       and COLUMN_NAME   = 'Comment';

    BEGIN TRY

        UPDATE dbo.ETL_ProcessLog
           set EndTime = isnull(@EndTime, Getdate()),
               RECORDSPROCESSED = isnull(@RecordProcessed, RECORDSPROCESSED),
               RECORDSINSERTED = isnull(@RecordInserted, RECORDSINSERTED),
               RECORDSUPDATED = isnull(@RecordUpdated, RECORDSUPDATED),
               --RecordWithError = isnull(@RecordWithError, RecordWithError),
               StatusId = @StatusId,
               Comment = @Comment
         where ProcessLogId = @ProcessLogId;
	

    END TRY
    Begin catch
        declare @errormessage varchar(4000);
        declare @errorserverity int,
                @errorstate     int;

        select @errormessage = ERROR_MESSAGE(),
               @errorserverity = 16,
               @errorstate = ERROR_STATE();

        raiserror(@errormessage, @errorserverity, @errorstate);
    end catch

end
GO
