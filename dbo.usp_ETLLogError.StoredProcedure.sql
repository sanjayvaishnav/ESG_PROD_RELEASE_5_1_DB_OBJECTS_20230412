USE [ESG]
GO
/****** Object:  StoredProcedure [dbo].[usp_ETLLogError]    Script Date: 4/18/2023 12:13:15 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[usp_ETLLogError]
GO
/****** Object:  StoredProcedure [dbo].[usp_ETLLogError]    Script Date: 4/18/2023 12:13:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[usp_ETLLogError]
    @Etlprogram varchar(255),
    @tablename sysname = null,
    @processlogid int = null,
    @severity int = null,
    @comment varchar(2000) = null,
    @ExceptionMessage varchar(max) = null
as
begin

    set nocount on;
    begin try

        declare @executedby varchar(100)
        set @executedby = convert(varchar(100), suser_sname())

        insert into [ESG].[dbo].[ETL_ErrorLog] (CREATEDTIME,
                                          TABLENAME,
                                          ETLPROGRAM,
                                          PROCESSLOGID,
                                          SEVERITY,
                                          COMMENT,
                                          EXCEPTION,
                                          EXECUTEDBY)
        values (getdate(), @tablename, @etlprogram, @processlogid, @severity, @comment, @exceptionmessage, @executedby)

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
