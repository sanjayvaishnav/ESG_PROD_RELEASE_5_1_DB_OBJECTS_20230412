USE [ESG]
GO
/****** Object:  StoredProcedure [dbo].[usp_Load_TCFD_LE_Service_SUM_SOURCE_TABLE]    Script Date: 4/18/2023 12:13:15 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[usp_Load_TCFD_LE_Service_SUM_SOURCE_TABLE]
GO
/****** Object:  StoredProcedure [dbo].[usp_Load_TCFD_LE_Service_SUM_SOURCE_TABLE]    Script Date: 4/18/2023 12:13:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[usp_Load_TCFD_LE_Service_SUM_SOURCE_TABLE]
(
@reporting_group varchar(50),
@dates varchar(200)=Null
)

/*
Logic :

USE [ESG]
GO

DECLARE	@return_value int

EXEC	@return_value = [dbo].[usp_Load_TCFD_LE_Service_SUM_SOURCE_TABLE]
		@reporting_group = N'HOLDING_CFO',
		@dates = '2022-09-30'

SELECT	'Return Value' = @return_value

GO
-------------------------------------------------------------------------------
Created Date	Version		Created By		Comments
01-FEB-2023		0.1			Wipro			Initial version 
15-MAR-2023		0.2			Wipro			EIB-232, Adding before and after March 2023 logic  version 
-------------------------------------------------------------------------------
*/

AS

BEGIN

	DECLARE @ReturnValue AS INT = 0 
	drop table if exists #dates ;
	truncate table [ESG].[SOURCE_TABLE]

	select value as [Date] into #dates FROM STRING_SPLIT(@dates, ',');

	BEGIN TRY
	IF (@reporting_group = 'HOLDING_CFO')
	BEGIN
	
	INSERT INTO [ESG].[TCFD_LE_SERVICE_LOG] VALUES (GETDATE(),'usp_Load_TCFD_LE_Service_SUM_SOURCE_TABLE','Before populating Source Table for ' + @reporting_group) 
			
	;with Xplan_LC as
				(

				Select 
				ID,
				ClientReference,
				ClientName,
				NULL as ISIN_Share_Class,
				Null as Share_Class_Name,
				ISIN,
				AssetName,
				ISSUERID,
				FUND_SHARE_CLASS_ID,
				MSCI_AS_OF_DATE,
				MV_GBP,
				MV_EUR,
				MV_USD,
				Service,
				(
				case 
				when (LegalEntity is NULL) then ('NULL')
				ELSE (LegalEntity) end
				) as LegalEntity,

				AssetGroupClass,
				(
				case 
				when (ASSET_GROUP is NULL) then ('NULL')
				ELSE (ASSET_GROUP) end
				) as ASSET_GROUP,
				Date,
				FundViewTagging,
				FUND_ELIGIBILITY,
				InvestmentManager,
				RelationshipManager,
				Portfolio,
				Price,
				Units,
				SEDOL,
				Branch,
				Custodian,
				Exchange,
				FX_Price,
				(
				case 
				when (b.ServiceCategory is NULL) then ('NULL')
				ELSE (b.ServiceCategory) end
				) as ServiceCategory,

				(
				Case 
				When LegacyCompany is null then ' '
				Else LegacyCompany
				End) as LC,
				ReportingCategory
				FROM [ESG].[ESG_HOLDINGS_EOM] a
				LEFT JOIN [ESG].[SERVICE_CATEGORY_REF] as b on a.Service = b.MandateCode
				where  Custodian != 'Avaloq' and FundViewTagging in ('ECH IP', 'ECH in Fund')
				AND 					
				date in ( select date from #dates )

				),
				source_table as
				(

				/*---------------------Condition for Xplan case 1 where date >'2022-7-15'---------------------------------*/
				Select 
				ClientReference,
				ClientName,
				NULL as ISIN_Share_Class,
				Null as Share_Class_Name,
				ISIN,
				AssetName,
				ISSUERID,
				FUND_SHARE_CLASS_ID,
				MSCI_AS_OF_DATE,
				MV_GBP,
				MV_EUR,
				MV_USD,
				Service,
				LegalEntity,
				AssetGroupClass,
				ASSET_GROUP,
				Date,
				FundViewTagging,
				FUND_ELIGIBILITY,
				InvestmentManager,
				RelationshipManager,
				Portfolio,
				Price,
				Units,
				SEDOL,
				Branch,
				Custodian,
				Exchange,
				FX_Price,
				ServiceCategory as ServiceCategory
				from Xplan_LC
				where ReportingCategory in('IM Managed', 'IAS','BestInvest', 'Other Advisory', 'Direct', 'Advisory - PIRS')
				and LC != 'Index Wealth Management'  and date >'2022-7-15'

				UNION ALL
 
				/*---------------------Condition for Xplan case 1 where date <'2022-7-15'---------------------------------*/
				Select ClientReference,
				ClientName,
				NULL as ISIN_Share_Class,
				Null as Share_Class_Name,
				ISIN,
				AssetName,
				ISSUERID,
				FUND_SHARE_CLASS_ID,
				MSCI_AS_OF_DATE,
				MV_GBP,
				MV_EUR,
				MV_USD,
				Service,
				LegalEntity,
				AssetGroupClass,
				ASSET_GROUP,
				Date,
				FundViewTagging,
				FUND_ELIGIBILITY,
				InvestmentManager,
				RelationshipManager,
				Portfolio,
				Price,
				Units,
				SEDOL,
				Branch,
				Custodian,
				Exchange,
				FX_Price,
				ServiceCategory as ServiceCategory
				from Xplan_LC
				where ReportingCategory in('IM Managed', 'IAS', 'Other Advisory', 'Direct', 'Advisory - PIRS')
				and LC != 'Index Wealth Management'  and service != 'OIS' and date < '2022-7-15'
  
				Union all
				/*---------------------Condition for Xplan case 2 where date >'2022-7-15'---------------------------------*/
				Select ClientReference,
				ClientName,
				NULL as ISIN_Share_Class,
				Null as Share_Class_Name,
				ISIN,
				AssetName,
				ISSUERID,
				FUND_SHARE_CLASS_ID,
				MSCI_AS_OF_DATE,
				MV_GBP,
				MV_EUR,
				MV_USD,
				Service,
				LegalEntity,
				AssetGroupClass,
				ASSET_GROUP,
				Date,
				FundViewTagging,
				FUND_ELIGIBILITY,
				InvestmentManager,
				RelationshipManager,
				Portfolio,
				Price,
				Units,
				SEDOL,
				Branch,
				Custodian,
				Exchange,
				FX_Price ,
				ServiceCategory as ServiceCategory
				from Xplan_LC
				where Service in('HFSM Core Sat','HFSM SPS','SWE AIMS','SWE DIMS','SWE XO') AND DATE>'2022-7-15'

				UNION ALL

				/*---------------------Condition for Xplan case 2 where date <'2022-7-15'---------------------------------*/
				Select ClientReference,
				ClientName,
				NULL as ISIN_Share_Class,
				Null as Share_Class_Name,
				ISIN,
				AssetName,
				ISSUERID,
				FUND_SHARE_CLASS_ID,
				MSCI_AS_OF_DATE,
				MV_GBP,
				MV_EUR,
				MV_USD,
				Service,
				LegalEntity,
				AssetGroupClass,
				ASSET_GROUP,
				Date,
				FundViewTagging,
				FUND_ELIGIBILITY,
				InvestmentManager,
				RelationshipManager,
				Portfolio,
				Price,
				Units,
				SEDOL,
				Branch,
				Custodian,
				Exchange,
				FX_Price,
				ServiceCategory as ServiceCategory
				from Xplan_LC
				where Service in('HFSM Core Sat','HFSM SPS','SWE AIMS','SWE DIMS','SWE XO','OIS') AND DATE <'2022-7-15'
 
				union all
				/*---------------------Condition for IMDR TILL DECEMBER 2022---------------------------------*/
				SELECT
				Portfolio_ID,
				Portfolio_Name,
				ISIN_Share_Class,
				Share_Class_Name,
				ISIN_Underlying,
				Asset_Name,
				ISSUERID,
				FUND_SHARE_CLASS_ID,
				MSCI_AS_OF_DATE,
				MV_GBP,
				MV_EUR,
				MV_USD,
				Service,
				LegalEntity,
				AssetGroupClass,
				(
				case 
				when (ASSET_GROUP is NULL) then ('NULL')
				ELSE (ASSET_GROUP) end
				) as ASSET_GROUP,
				IMDR_PROCESS_NAV_DATE,
				FundViewTagging,
				FUND_ELIGIBILITY,
				NULL,
				NULL,
				NULL,
				NULL,
				NULL,
				NULL,
				NULL,
				Custodian,
				NULL,
				NULL,
				ServiceCategory as ServiceCategory
				FROM [ESG].[IMDR_UNDERLYING_HOLDINGS]
				where IMDR_PROCESS_NAV_DATE is not null 
			        and Platform <> 'DIF'
				AND IMDR_PROCESS_NAV_DATE in ( select date from #dates )
                                and IMDR_PROCESS_NAV_DATE <= '2022-12-31'

				
union all
				/*---------------------Condition for IMDR FROM JANUARY 2023---------------------------------*/
				SELECT
				Portfolio_ID,
				Portfolio_Name,
				ISIN_Share_Class,
				Share_Class_Name,
				ISIN_Underlying,
				Asset_Name,
				ISSUERID,
				FUND_SHARE_CLASS_ID,
				MSCI_AS_OF_DATE,
				MV_GBP,
				MV_EUR,
				MV_USD,
				Service,
				LegalEntity,
				AssetGroupClass,
				(
				case 
				when (ASSET_GROUP is NULL) then ('NULL')
				ELSE (ASSET_GROUP) end
				) as ASSET_GROUP,
				IMDR_PROCESS_NAV_DATE,
				FundViewTagging,
				FUND_ELIGIBILITY,
				NULL,
				NULL,
				NULL,
				NULL,
				NULL,
				NULL,
				NULL,
				Custodian,
				NULL,
				NULL,
				ServiceCategory as ServiceCategory
				FROM [ESG].[IMDR_UNDERLYING_HOLDINGS]
				where IMDR_PROCESS_NAV_DATE is not null 
                                AND IMDR_PROCESS_NAV_DATE in ( select date from #dates )
                                and IMDR_PROCESS_NAV_DATE > '2022-12-31'







				Union all
				/*---------------------Condition for AVALOQ---------------------------------*/
				SELECT 
				a.ClientReference,
				ClientName,
				NULL as ISIN_Share_Class,
				Null as Share_Class_Name,
				ISIN,
				AssetName,
				ISSUERID,
				FUND_SHARE_CLASS_ID,
				MSCI_AS_OF_DATE,
				MV_GBP,
				MV_EUR,
				MV_USD,
				Service,
				(
				case 
				when (LegalEntity is NULL) then ('NULL')
				ELSE (LegalEntity) end
				) as LegalEntity,

				AssetGroupClass,
				(
				case 
				when (ASSET_GROUP is NULL) then ('NULL')
				ELSE (ASSET_GROUP) end
				) as ASSET_GROUP,

				Date,
				FundViewTagging,
				FUND_ELIGIBILITY,
				InvestmentManager,
				RelationshipManager,
				Portfolio,
				Price,
				Units,
				SEDOL,
				Branch,
				Custodian,
				Exchange,
				FX_Price,				
				(
				case 
				when (c.ServiceCategory is NULL) then ('NULL')
				ELSE (c.ServiceCategory) end
				) as ServiceCategory


				FROM [ESG].[ESG_HOLDINGS_EOM] a
				left join (select distinct CLIENTREFERENCE, Finance_excluded from [ESG].[FUND_MASTER] where Finance_excluded = 'Y' ) b
				on a.ClientReference=b.CLIENTREFERENCE
				LEFT JOIN [ESG].[SERVICE_CATEGORY_REF] as c on a.Service = c.MandateCode
				where a.Custodian = 'Avaloq' and b.CLIENTREFERENCE is null
				AND date in ( select date from #dates )
				)

				INSERT INTO [ESG].[SOURCE_TABLE]
				SELECT * FROM Source_Table where LegalEntity = 'EPE' and ServiceCategory = 'ex-custody' and ClientReference in ('AM.9458','AK.7746')
				UNION ALL
				SELECT * FROM Source_Table where LegalEntity = 'EPE' and ServiceCategory != 'ex-custody'
				UNION ALL
				SELECT * FROM Source_Table where LegalEntity != 'EPE'

			SET @ReturnValue  = 1
	END

	INSERT INTO [ESG].[TCFD_LE_SERVICE_LOG] VALUES (GETDATE(),'usp_Load_TCFD_LE_Service_SUM_SOURCE_TABLE','After populating Source Table for ' + @reporting_group) 

	RETURN @ReturnValue
	END TRY

	BEGIN CATCH
	SET @ReturnValue  = -1
	RETURN @ReturnValue
	END CATCH
END
GO
