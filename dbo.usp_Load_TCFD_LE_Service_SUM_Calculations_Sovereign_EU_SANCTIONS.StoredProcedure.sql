USE [ESG]
GO
/****** Object:  StoredProcedure [dbo].[usp_Load_TCFD_LE_Service_SUM_Calculations_Sovereign_EU_SANCTIONS]    Script Date: 4/18/2023 12:13:15 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[usp_Load_TCFD_LE_Service_SUM_Calculations_Sovereign_EU_SANCTIONS]
GO
/****** Object:  StoredProcedure [dbo].[usp_Load_TCFD_LE_Service_SUM_Calculations_Sovereign_EU_SANCTIONS]    Script Date: 4/18/2023 12:13:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[usp_Load_TCFD_LE_Service_SUM_Calculations_Sovereign_EU_SANCTIONS]

/*
Logic :

USE [ESG]
GO

DECLARE	@return_value int

EXEC	@return_value = [dbo].[usp_Load_TCFD_LE_Service_SUM_Calculations_Sovereign_EU_SANCTIONS]

SELECT	'Return Value' = @return_value

GO
-------------------------------------------------------------------------------
Created Date	Version		Created By		Comments
01-FEB-2023		0.1			Wipro			Initial version 
15-FEB-2023		0.2			Wipro			Changes for PAI 6,13,16,17,18 (Changes for Release 4)
-------------------------------------------------------------------------------

*/
AS
BEGIN
	drop table if exists #temp_cov_adj_wt_all_Sovereign_EU_SANCTIONS;
	drop table if exists [ESG].[Factors_All_Sovereign_EU_SANCTIONS];
	TRUNCATE TABLE [ESG].[SOURCE_TABLE_AUM]
	TRUNCATE TABLE [ESG].[TCFD_LE_SERVICE_SUM_Sovereign_EU_SANCTIONS]
	DECLARE @ReturnValue AS INT = 0 ;

BEGIN TRY
INSERT INTO [ESG].[TCFD_LE_SERVICE_LOG] VALUES (GETDATE(),'usp_Load_TCFD_LE_Service_SUM_Calculations_Sovereign_EU_SANCTIONS','Start execution') 

DECLARE @table_sovereign_source TABLE  (

    [Date] [date] NULL,
    [LegalEntity] [nvarchar](255) NULL,
    [ServiceCategory] [nvarchar](255) NULL,
    [MSCI_AS_OF_DATE] [date] NULL,
	[Sov_EUSANC_MV_GBP] DECIMAL(19,4) NULL,
	[Sov_EUSANC_MV_EUR] DECIMAL(19,4) NULL,
	[ASSET_GROUP] [varchar](50) NULL,
	[FUND_SHARE_CLASS_ID] [varchar](50) NULL,
	[ISSUERID] [varchar](50) NULL,
	[FUND_TYPE] [varchar](50) NULL,
	[FUND_ELIGIBILITY] [varchar](2) NULL
);

INSERT INTO @table_sovereign_source 
					SELECT
					 [Date]
					,LegalEntity
					,ServiceCategory
					,[MSCI_AS_OF_DATE]
					,SUM((case
                            when A.fund_share_class_id IS NULL
                             AND A.issuerid IS NOT NULL
                             and DG.issuerid is not null then A.MV_GBP
                            when A.fund_share_class_id IS NOT NULL
                             and C.FUND_SFDR_GLOBAL_EU_SANCTIONS_COV > 0 then A.mv_gbp
                            else 0 end)) as Sov_EUSANC_MV_GBP

					,SUM((case
                            when A.fund_share_class_id IS NULL
                             AND A.issuerid IS NOT NULL
                             and DG.issuerid is not null then A.MV_EUR
                            when A.fund_share_class_id IS NOT NULL
                             and C.FUND_SFDR_GLOBAL_EU_SANCTIONS_COV > 0 then A.MV_EUR
                            else 0 end)) as Sov_EUSANC_MV_EUR

					,ASSET_GROUP
					,a.FUND_SHARE_CLASS_ID
                    ,a.ISSUERID
					,(case
                            when A.fund_share_class_id IS NULL
                             AND A.issuerid IS NOT NULL
                              then 'DIRECT'
                            when A.fund_share_class_id IS NOT NULL
                              then 'COLLECTIVE'
                            else 'ISIN NOT MATCHED/CASH' end) as FUND_TYPE
					,a.FUND_ELIGIBILITY
					
					FROM [ESG].[SOURCE_TABLE] A 
					left join [ESG].[CLTV_EUSUSTAINABLEFINANCE] C on a.MSCI_AS_OF_DATE = c.AS_OF_DATE and a.FUND_SHARE_CLASS_ID = c.FUND_SHARE_CLASS_ID
					left join (select issuerid from [ESG].[DIR_GOVRATING] group by issuerid) as DG on a.issuerId = dg.issuerid
					GROUP BY 
					[Date]
					,LegalEntity
					,ServiceCategory
					,[MSCI_AS_OF_DATE]
					,ASSET_GROUP
					,a.FUND_SHARE_CLASS_ID
                    ,a.ISSUERID
					,a.FUND_ELIGIBILITY		

INSERT INTO [ESG].[TCFD_LE_SERVICE_LOG] VALUES (GETDATE(),'usp_Load_TCFD_LE_Service_SUM_Calculations_Sovereign_EU_SANCTIONS','Before populating AUM Table ') 

		;WITH AUM
				AS 
				(
					SELECT
					distinct [Date]
					,LegalEntity
					,ServiceCategory
					,[MSCI_AS_OF_DATE]
					,NULL AS [MV_USD_total]
					,sum(Sov_EUSANC_MV_EUR) over (partition by Date,LegalEntity,ServiceCategory,asset_group) as AUM
					,sum(Sov_EUSANC_MV_GBP) over (partition by Date,LegalEntity,ServiceCategory,asset_group) as MV_GBP
					,ASSET_GROUP
					FROM @table_sovereign_source
				)

			INSERT INTO [ESG].[SOURCE_TABLE_AUM] SELECT * FROM AUM

		select * 
		into        #temp_cov_adj_wt_all_Sovereign_EU_SANCTIONS	
		from ( 
					 Select
					 a.[Date]
					,a.LegalEntity
					,a.ServiceCategory
					,a.[MSCI_AS_OF_DATE]
					,a.Sov_EUSANC_MV_GBP
					,a.Sov_EUSANC_MV_EUR
					,a.ASSET_GROUP
					,a.FUND_SHARE_CLASS_ID
                    ,a.ISSUERID
					,a.FUND_TYPE
					,a.FUND_ELIGIBILITY
					,d.AUM
					,d.MV_GBP_Total
					,e.ISSUERID AS 'IsSOV'

                   ,(case
                            when a.FUND_TYPE = 'COLLECTIVE' 
                             and c.FUND_SFDR_GLOBAL_EU_SANCTIONS_COV > 0
                             AND FUND_ELIGIBILITY = 'T' then
                                cast(((case when (NULLIF(d.AUM, 0) = 0) then (0) else a.Sov_EUSANC_MV_EUR / NULLIF(d.AUM, 0) end)) * c.FUND_SFDR_GLOBAL_EU_SANCTIONS_COV as float) / 100.0
                            when a.FUND_TYPE = 'DIRECT'
                             and b.GOVERNMENT_EU_SANCTIONS IS NOT NULL AND b.GOVERNMENT_EU_SANCTIONS <> '' and e.ISSUERID is not null
                      then (  (case when (NULLIF(d.AUM, 0) = 0) then (0) else a.Sov_EUSANC_MV_EUR / NULLIF(d.AUM, 0) end))
                            else 0 END) cov_GOVERNMENT_EU_SANCTIONS,

					b.GOVERNMENT_EU_SANCTIONS,
					c.FUND_SFDR_GLOBAL_EU_SANCTIONS_COUNT,
					c.FUND_SFDR_GLOBAL_EU_SANCTIONS_COV,
					c.FUND_SFDR_GLOBAL_EU_SANCTIONS_PERCENTAGE,
					
					(case
                            when a.FUND_TYPE = 'COLLECTIVE' 
                             and c.FUND_SFDR_GLOBAL_EU_SANCTIONS_COV > 0 and c.FUND_SFDR_GLOBAL_EU_SANCTIONS_PERCENTAGE != 0
                             AND FUND_ELIGIBILITY = 'T' 
							then (100 * c.FUND_SFDR_GLOBAL_EU_SANCTIONS_COUNT)/c.FUND_SFDR_GLOBAL_EU_SANCTIONS_PERCENTAGE
                            when (a.FUND_TYPE = 'DIRECT' and e.ISSUERID is not null)
                            then 1
                            else 0 END) as cov_unique_issuer
				   											
                 from 
				 @table_sovereign_source a
                 left join [ESG].[DIR_SFDR] b on b.ISSUERID = a.ISSUERID and a.MSCI_AS_OF_DATE = b.AS_OF_DATE
                 left join [ESG].[CLTV_EUSUSTAINABLEFINANCE] c on a.MSCI_AS_OF_DATE = c.AS_OF_DATE and a.FUND_SHARE_CLASS_ID = c.FUND_SHARE_CLASS_ID
                 left join [ESG].[SOURCE_TABLE_AUM] d on a.LegalEntity = d.LegalEntity and a.ServiceCategory = d.ServiceCategory and a.asset_group = d.asset_group and a.Date = d.Date
				 left join [ESG].DIR_GOVRATING e on a.ISSUERID = e.ISSUERID and a.MSCI_AS_OF_DATE = e.AS_OF_DATE			
				) as a

    select * into  [ESG].[Factors_All_Sovereign_EU_SANCTIONS]
      from (   
	  select *,(case
            when cov_unique_issuer <> 0 
			then 
				(
					CASE 
					WHEN (FUND_TYPE = 'COLLECTIVE' AND FUND_ELIGIBILITY = 'T')  THEN (FUND_SFDR_GLOBAL_EU_SANCTIONS_COUNT)
					WHEN (FUND_TYPE = 'DIRECT' AND GOVERNMENT_EU_SANCTIONS = 'YES' AND IsSOV IS NOT NULL) THEN (1) 
					ELSE 0
					END
				) 
            else 0 
		END) as sov_sanctions
		FROM #temp_cov_adj_wt_all_Sovereign_EU_SANCTIONS) as CarbonfootPrint_derived

	INSERT INTO [ESG].[TCFD_LE_SERVICE_LOG] VALUES (GETDATE(),'usp_Load_TCFD_LE_Service_SUM_Calculations_Sovereign_EU_SANCTIONS','Before populating [ESG].[TCFD_LE_SERVICE_SUM_Sovereign_EU_SANCTIONS]') 

     ----From Factors_All_POC_Sovereign_EU_SANCTIONS the data moves to TCFD_LE_SERVICE_SUM_NewPAI_Sovereign_EU_SANCTIONS 
	INSERT INTO  [ESG].[TCFD_LE_SERVICE_SUM_Sovereign_EU_SANCTIONS](
						[DATE] ,
						[MSCI_AS_OF_DATE] ,
						[Legal_Entity] ,
						[MV_EUR] ,
						[Service_Category] ,
						[GOVERNMENT_EU_SANCTIONS_COV] ,
						[unique_sov_sanctions_count] ,
						[ASSET_GROUP],
						[unique_sov_sanctions_pct]
					  )

					select 
					date,
					[MSCI_AS_OF_DATE],
					LegalEntity,
					AUM as MV_EUR,
					ServiceCategory as [Service_Category],
					(case
					when (date >= '2023-01-01') then (sum(cov_GOVERNMENT_EU_SANCTIONS) * 100)
					else 0 end
					) as GOVERNMENT_EU_SANCTIONS_COV,

					(case
					when (date >= '2023-01-01') then (sum(sov_sanctions))
					else 0 end
					) as [unique_sov_sanctions_count],
				
					asset_group,


					(case
					when (date >= '2023-01-01')
					then
					(
					CASE
						WHEN (SUM(cov_unique_issuer) = 0)
						THEN 0
					ELSE
						(SUM(sov_sanctions) * 100) /SUM(cov_unique_issuer)
					END 
					) 				
					ELSE
					0 END				
					) AS [unique_sov_sanctions_pct]
					
					FROM [ESG].[Factors_All_Sovereign_EU_SANCTIONS]
					group by 
					date,
					[MSCI_AS_OF_DATE],
					LegalEntity,
					MV_GBP_Total,
					AUM,
					ServiceCategory,
					asset_group
			INSERT INTO [ESG].[TCFD_LE_SERVICE_LOG] VALUES (GETDATE(),'usp_Load_TCFD_LE_Service_SUM_Calculations_Sovereign_EU_SANCTIONS',
			'After populating [ESG].[TCFD_LE_SERVICE_SUM_Sovereign_EU_SANCTIONS]') 			
	
	SET @ReturnValue = 1
	RETURN @ReturnValue
END TRY

BEGIN CATCH
	SET @ReturnValue = -1
	RETURN @ReturnValue
END CATCH

END

GO
