USE [ESG]
GO
/****** Object:  StoredProcedure [dbo].[usp_ETLCreateProcessLog]    Script Date: 4/18/2023 12:13:15 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[usp_ETLCreateProcessLog]
GO
/****** Object:  StoredProcedure [dbo].[usp_ETLCreateProcessLog]    Script Date: 4/18/2023 12:13:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[usp_ETLCreateProcessLog]
    @TableName Sysname,
    @ETLProgram sysname,
    --@GroupID int,
    @SourceTable Sysname,
    @ETLPhaseID int,
    @comment varchar(2000) = null,
    @ProcessLogId int output
as
begin

    set nocount on;
    begin try

        declare @executedby varchar(100);
        set @executedby = convert(varchar(100), suser_sname())

        insert into [dbo].[ETL_ProcessLog] (TABLENAME,
                                            STARTTIME,
                                            SOURCETABLE,
                                            ETLPROGRAM,
                                            ETLPHASEID,
                                            STATUSID,
                                            COMMENT,
                                            EXECUTEBY)
        values (@TableName,
                getdate(),
                @SourceTable,
                @ETLProgram,
                @ETLPhaseID,
                3, -- pending
                @comment,
                @executedby)

        select @ProcessLogId = Scope_identity();


    end try
    begin catch

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
