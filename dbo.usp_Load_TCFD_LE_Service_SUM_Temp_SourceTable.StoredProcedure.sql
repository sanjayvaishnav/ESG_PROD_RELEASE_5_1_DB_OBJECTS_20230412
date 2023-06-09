USE [ESG]
GO
/****** Object:  StoredProcedure [dbo].[usp_Load_TCFD_LE_Service_SUM_Temp_SourceTable]    Script Date: 4/18/2023 12:13:15 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[usp_Load_TCFD_LE_Service_SUM_Temp_SourceTable]
GO
/****** Object:  StoredProcedure [dbo].[usp_Load_TCFD_LE_Service_SUM_Temp_SourceTable]    Script Date: 4/18/2023 12:13:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[usp_Load_TCFD_LE_Service_SUM_Temp_SourceTable]
(
@reporting_group varchar(50),
@dates varchar(200)=Null
)

/*
Logic :

USE [ESG]
GO

DECLARE	@return_value int

EXEC	@return_value = [dbo].[usp_Load_TCFD_LE_Service_SUM_Temp_SourceTable]
		@reporting_group = N'HOLDING_CFO',
		@dates = '2023-01-31'

SELECT	'Return Value' = @return_value

GO
-------------------------------------------------------------------------------
Created Date	Version		Created By		Comments
01-FEB-2023		0.1			Wipro			Initial version 
-------------------------------------------------------------------------------
*/

AS

BEGIN

	DECLARE @ReturnValue AS INT = 0 
	drop table if exists #dates ;
	truncate table [ESG].[Source_Table_POC]

	select value as [Date] into #dates FROM STRING_SPLIT(@dates, ',');

	BEGIN TRY
	--IF (@reporting_group = 'FUND_LOOK_THROUGH')
	--BEGIN
	--	with Source_Table
	--			as 
	--			(
	--			SELECT 
	--			ClientReference,
	--			ClientName,
	--			NULL as ISIN_Share_Class,
	--			Null as Share_Class_Name,
	--			ISIN,
	--			AssetName,
	--			ISSUERID,
	--			FUND_SHARE_CLASS_ID,
	--			MSCI_AS_OF_DATE,
	--			MV_GBP,
	--			MV_EUR,
	--			MV_USD,
	--			Service,
	--			(
	--			case 
	--			when (LegalEntity is NULL) then ('NULL')
	--			ELSE (LegalEntity) end
	--			) as LegalEntity,
	--			AssetGroupClass,
	--			(
	--			case 
	--			when (ASSET_GROUP is NULL) then ('NULL')
	--			ELSE (ASSET_GROUP) end
	--			) as ASSET_GROUP,

	--			Date,
	--			FundViewTagging,
	--			FUND_ELIGIBILITY,
	--			InvestmentManager,
	--			NULL as RelationshipManager,
	--			Portfolio,
	--			NULL as Price,
	--			NULL as Units,
	--			NULL as SEDOL,
	--			NULL as Branch,
	--			NULL as Custodian,
	--			NULL as Exchange,
	--			NULL as FX_Price,
	--			(
	--			case 
	--			when (b.ServiceCategory is NULL) then ('NULL')
	--			ELSE (b.ServiceCategory) end
	--			) as ServiceCategory


	--			FROM [ESG].[ESG_HOLDINGS_EOM] a
	--			LEFT JOIN [ESG].[SERVICE_CATEGORY_REF] as b on a.Service = b.MandateCode
	--			WHERE
	--			FundViewTagging in ( 'FasCL - NON TAP', 'ECH IP' ) 
	--			and date in ( select date from #dates )

	--			UNION ALL

	--			SELECT 
	--			Portfolio_ID as ClientReference,
	--			Portfolio_Name as ClientName,
	--			ISIN_Share_Class,
	--			Share_Class_Name,
	--			ISIN_Underlying as ISIN,
	--			Asset_Name as AssetName,
	--			ISSUERID,
	--			FUND_SHARE_CLASS_ID,
	--			MSCI_AS_OF_DATE,
	--			MV_GBP,
	--			MV_EUR,
	--			MV_USD,
	--			Service,
	--			LegalEntity,
	--			AssetGroupClass,

	--			(
	--			case 
	--			when (ASSET_GROUP is NULL) then ('NULL')
	--			ELSE (ASSET_GROUP) end
	--			) as ASSET_GROUP,

	--			IMDR_PROCESS_NAV_DATE as Date,
	--			FundViewTagging,
	--			FUND_ELIGIBILITY,
	--			NULL as InvestmentManager,
	--			NULL as RelationshipManager,
	--			NULL as Portfolio,
	--			NULL as Price,
	--			NULL as Units,
	--			NULL as SEDOL,
	--			NULL as Branch,
	--			NULL as Custodian,
	--			NULL as Exchange,
	--			NULL as FX_Price,
	--			ServiceCategory as ServiceCategory

	--			FROM [ESG].[IMDR_Underlying_Holdings] 
	--			where IMDR_PROCESS_NAV_DATE IS NOT NULL and 
	--			IMDR_PROCESS_NAV_DATE in ( select date from #dates )
	--			and FundViewTagging = 'FASCL-TAP')

	--			INSERT INTO [ESG].[Source_Table_POC]
	--			SELECT * FROM Source_Table
	--	SET @ReturnValue  = 1
	--END

	IF (@reporting_group = 'HOLDING_CFO')
	BEGIN
			
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
				/*---------------------Condition for IMDR---------------------------------*/
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
				where IMDR_PROCESS_NAV_DATE is not null and Platform <> 'DIF'
				AND IMDR_PROCESS_NAV_DATE in ( select date from #dates )

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

				INSERT INTO [ESG].[Source_Table_POC]
				SELECT * FROM Source_Table
			SET @ReturnValue  = 2
	END

	INSERT INTO [ESG].[TCFD_LE_SERVICE_LOG] VALUES (GETDATE(),'usp_Load_TCFD_LE_Service_SUM_Temp_SourceTable','After populating Source Table for ' + @reporting_group) 

	RETURN @ReturnValue
	END TRY

	BEGIN CATCH
	SET @ReturnValue  = -1
	RETURN @ReturnValue
	END CATCH
END
GO
