USE [ESG]
GO
/****** Object:  Synonym [ESG].[ESG_Holdings]    Script Date: 4/18/2023 12:13:15 PM ******/
DROP SYNONYM IF EXISTS [ESG].[ESG_Holdings]
GO
/****** Object:  Synonym [ESG].[ESG_Holdings]    Script Date: 4/18/2023 12:13:15 PM ******/
CREATE SYNONYM [ESG].[ESG_Holdings] FOR [PD01DWHV01\PDWH_REP].[EDW].[ESG].[Holdings]
GO
