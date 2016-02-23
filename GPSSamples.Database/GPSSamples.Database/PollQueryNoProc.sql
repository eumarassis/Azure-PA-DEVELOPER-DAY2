-- Poll query

SELECT COUNT(*) FROM ProductLogicApps WHERE OrderStatus = 'ProcessedForCollection'

-- Poll query 2

SELECT *, GetDate() as 'PollTime' FROM [ProductLogicApps] WHERE OrderStatus = 'ProcessedForCollection' ORDER BY ProductId DESC; 

UPDATE [ProductLogicApps] SET OrderStatus = 'ProcessedByLogicApp' WHERE ProductID IN (SELECT TOP 10 ProductID FROM [ProductLogicApps] WHERE OrderStatus = 'ProcessedForCollection' ORDER BY ProductId DESC);