USE [ESG]
GO
/****** Object:  Synonym [ESG].[ESG_ProcessSettings]    Script Date: 4/18/2023 12:13:15 PM ******/
DROP SYNONYM IF EXISTS [ESG].[ESG_ProcessSettings]
GO
/****** Object:  Synonym [ESG].[ESG_ProcessSettings]    Script Date: 4/18/2023 12:13:15 PM ******/
CREATE SYNONYM [ESG].[ESG_ProcessSettings] FOR [PD01DWHV01\PDWH_REP].[EDW_Manager].[Extract].[ProcessSettings]
GO
