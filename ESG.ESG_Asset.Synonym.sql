USE [ESG]
GO
/****** Object:  Synonym [ESG].[ESG_Asset]    Script Date: 4/18/2023 12:13:15 PM ******/
DROP SYNONYM IF EXISTS [ESG].[ESG_Asset]
GO
/****** Object:  Synonym [ESG].[ESG_Asset]    Script Date: 4/18/2023 12:13:15 PM ******/
CREATE SYNONYM [ESG].[ESG_Asset] FOR [PD01DWHV01\PDWH_REP].[EDW].[ESG].[Asset]
GO
