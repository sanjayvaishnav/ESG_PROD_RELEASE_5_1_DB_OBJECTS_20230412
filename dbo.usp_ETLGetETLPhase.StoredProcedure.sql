USE [ESG]
GO
/****** Object:  StoredProcedure [dbo].[usp_ETLGetETLPhase]    Script Date: 4/18/2023 12:13:15 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[usp_ETLGetETLPhase]
GO
/****** Object:  StoredProcedure [dbo].[usp_ETLGetETLPhase]    Script Date: 4/18/2023 12:13:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[usp_ETLGetETLPhase]
    @ETLPhase varchar(50),
    @ETLPhaseID Int output
as
begin

    begin try

        select @ETLPhaseID = ETLPHASEID
          from [dbo].[ETL_PHASE]
         where PHASENAME = @ETLPhase

    end try
    begin catch
        declare @errormessage varchar(4000);
        declare @errorState int;
        select @errormessage = 'Error in getting ETLPhaseID number' + ERROR_MESSAGE(),
               @errorState = error_state();

        declare @procedurename sysname
        set @procedurename = object_name(@@procid);

        exec dbo.usp_ETLLogError @etlprogram = @procedurename,
                                 @exceptionmessage = @errormessage

        raiserror(@errormessage, 18, @errorstate);

    end catch

end

GO
