USE [AdventureWorks2014]
GO

/****** Object:  StoredProcedure [dbo].[SP_LogicApp_PollQuery]    Script Date: 2/23/2016 8:18:26 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SP_LogicApp_PollQuery]
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @STATUS VARCHAR (50);

	SET @STATUS = 'Processed' + convert(varchar(25), getdate(), 9);

	WITH CTE AS (
		SELECT TOP 5 *, GetDate() as 'PollTime' FROM [Production].[Product] WHERE Color = 'Black' and ProductStatus is null ORDER BY ProductId DESC
	)
	UPDATE CTE SET ProductStatus = @STATUS;
	
	SELECT TOP 5 *, GetDate() as 'PollTime' FROM [Production].[Product] WHERE Color = 'Black' AND ProductStatus = @STATUS ORDER BY ProductId DESC
END

GO

