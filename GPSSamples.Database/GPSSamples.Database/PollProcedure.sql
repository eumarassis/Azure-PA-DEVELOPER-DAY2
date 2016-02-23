USE [AdventureWorks2014]
GO

/****** Object:  StoredProcedure [dbo].[SP_LogicApp_PollCount]    Script Date: 2/23/2016 8:18:05 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_LogicApp_PollCount]
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT COUNT (*) FROM
	 (SELECT  TOP 5 Name  FROM [Production].[Product] WHERE Color = 'Black' ORDER BY ProductId DESC) as teste

END

GO

