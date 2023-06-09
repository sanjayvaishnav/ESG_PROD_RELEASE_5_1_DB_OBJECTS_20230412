USE [ESG]
GO
/****** Object:  StoredProcedure [ESG].[usp_ETL_TCFD_LE_Service_SUM_Temp_Final]    Script Date: 4/18/2023 12:13:15 PM ******/
DROP PROCEDURE IF EXISTS [ESG].[usp_ETL_TCFD_LE_Service_SUM_Temp_Final]
GO
/****** Object:  StoredProcedure [ESG].[usp_ETL_TCFD_LE_Service_SUM_Temp_Final]    Script Date: 4/18/2023 12:13:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [ESG].[usp_ETL_TCFD_LE_Service_SUM_Temp_Final]
as 
begin 
--truncate table [ESG].[TCFD_LE_Service_SUM]

drop table if exists #dates ;
select  date 
 into #dates 
 from [ESG].[ESG].[ESG_Holdings_EOM]
where 
--date =EOMONTH (date) 
--and 
date > ( select max(DATE) from [ESG].[TCFD_LE_Service_SUM])
 group by date
order by date desc;

declare @dates varchar(500)

select @dates= Stuff((select ','+ cast(date as varchar(500))  from #dates for xml path('')),1,1,'') 
--select @dates='2022-11-30'
--select @dates='2021-12-31,2022-01-31,2022-01-31'



exec [dbo].[usp_Load_TCFD_LE_Service_SUM_Temp_All_Date_Fundview] @dates

drop table if exists #temp_cov_adj_wt_all;
drop table if exists [ESG].[Factors_All];

exec [dbo].[usp_Load_TCFD_LE_Service_SUM_Temp_All_DateExceptSWE_Fundview] @dates

drop table if exists #temp_cov_adj_wt_all;
drop table if exists [ESG].[Factors_All];
 

exec [dbo].[usp_Load_TCFD_LE_Service_SUM_Temp_All_DL_Fundview] @dates

drop table if exists #temp_cov_adj_wt_all;
drop table if exists [ESG].[Factors_All];


exec [dbo].[usp_Load_TCFD_LE_Service_SUM_Temp_All_DLSC_Fundview] @dates

drop table if exists #temp_cov_adj_wt_all;
drop table if exists [ESG].[Factors_All];


exec [dbo].[usp_Load_TCFD_LE_Service_SUM_Temp_All_DLSWE_Fundview] @dates

drop table if exists #temp_cov_adj_wt_all;
drop table if exists [ESG].[Factors_All];


exec [dbo].[usp_Load_TCFD_LE_Service_SUM_Temp_All_DSC_Fundview] @dates

drop table if exists #temp_cov_adj_wt_all;
drop table if exists [ESG].[Factors_All];


exec [dbo].[usp_Load_TCFD_LE_Service_SUM_Temp_All_Date_HOLDING_CFO] @dates

drop table if exists #temp_cov_adj_wt_all;
drop table if exists [ESG].[Factors_All];


exec [dbo].[usp_Load_TCFD_LE_Service_SUM_Temp_All_DateExceptSWE_HOLDING_CFO] @dates

drop table if exists #temp_cov_adj_wt_all;
drop table if exists [ESG].[Factors_All];


exec [dbo].[usp_Load_TCFD_LE_Service_SUM_Temp_All_DL_HOLDING_CFO] @dates


drop table if exists #temp_cov_adj_wt_all;
drop table if exists [ESG].[Factors_All];


exec [dbo].[usp_Load_TCFD_LE_Service_SUM_Temp_All_DLSC_HOLDING_CFO] @dates

drop table if exists #temp_cov_adj_wt_all;
drop table if exists [ESG].[Factors_All];


exec [dbo].[usp_Load_TCFD_LE_Service_SUM_Temp_All_DLSWE_HOLDING_CFO] @dates

drop table if exists #temp_cov_adj_wt_all;
drop table if exists [ESG].[Factors_All];


exec [dbo].[usp_Load_TCFD_LE_Service_SUM_Temp_All_DSC_HOLDING_CFO] @dates


end



GO
