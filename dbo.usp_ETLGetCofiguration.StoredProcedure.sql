USE [ESG]
GO
/****** Object:  StoredProcedure [dbo].[usp_ETLGetCofiguration]    Script Date: 4/18/2023 12:13:15 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[usp_ETLGetCofiguration]
GO
/****** Object:  StoredProcedure [dbo].[usp_ETLGetCofiguration]    Script Date: 4/18/2023 12:13:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_ETLGetCofiguration]
    @PackageName varchar(100),
    @SourceServer varchar(100) output,
    @sourceDB varchar(100) output,
    @SourceTable varchar(100) output,
	@DestinationServer varchar(100) output,
    @DestinationDB varchar(100) output,
    @DestinationTable varchar(100) output
as
begin

    set nocount on

    begin try

        select top 1 @SourceServer = coalesce(SourceServer,''),
               @sourceDB = coalesce(SourceDB,''),
               @SourceTable = coalesce(SourceTable,''),
			   @DestinationServer = coalesce(DestinationServer,''),
               @DestinationDB = coalesce(DestinationDB,''),
               @DestinationTable = coalesce(DestinationTable,'')
          from [dbo].[ETLSource]
         where PackageName = @PackageName

    end try
    begin catch
        declare @errormessage varchar(4000);
        declare @errorState int;
        select @errormessage = 'Error in getting configuration parameters' + ERROR_MESSAGE(),
               @errorState = error_state();

        declare @procedurename sysname
        set @procedurename = object_name(@@procid);

        exec dbo.usp_ETLLogError @etlprogram = @procedurename,
                                 @exceptionmessage = @errormessage

        raiserror(@errormessage, 18, @errorstate);
    end catch
end

GO
