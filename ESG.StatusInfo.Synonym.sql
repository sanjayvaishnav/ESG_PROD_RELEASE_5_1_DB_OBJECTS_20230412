USE [ESG]
GO
/****** Object:  Synonym [ESG].[StatusInfo]    Script Date: 4/18/2023 12:13:15 PM ******/
DROP SYNONYM IF EXISTS [ESG].[StatusInfo]
GO
/****** Object:  Synonym [ESG].[StatusInfo]    Script Date: 4/18/2023 12:13:15 PM ******/
CREATE SYNONYM [ESG].[StatusInfo] FOR [PD01DWHV01\PDWH_REP].[EDW_Manager].[Extract].[StatusInfo]
GO
