USE [ESG]
GO
/****** Object:  Synonym [ESG].[ESG_Currency]    Script Date: 4/18/2023 12:13:15 PM ******/
DROP SYNONYM IF EXISTS [ESG].[ESG_Currency]
GO
/****** Object:  Synonym [ESG].[ESG_Currency]    Script Date: 4/18/2023 12:13:15 PM ******/
CREATE SYNONYM [ESG].[ESG_Currency] FOR [PD01DWHV01\PDWH_REP].[EDW].[ESG].[Currency]
GO
