USE master
Create Credential [https://XXXXXX.blob.core.windows.net/databases1] 
With 
identity='Shared Access Signature',
SECRET = 'YOUR KEY' -- Execute PowerShell CreateCredential to get key

GO

CREATE DATABASE TestDB1  
ON 
(NAME = TestDB1_data, 
   FILENAME = 'https://XXXXXX.blob.core.windows.net/databases1/TestDB1Data.mdf') 
 LOG ON 
(NAME = TestDB1_log, 
    FILENAME = 'https://XXXXXX.blob.core.windows.net/databases1/TestDB1Log.ldf') 
GO 

USE TestDB1; 
GO 
CREATE TABLE Table1 (Col1 int primary key, Col2 varchar(20)); 
GO 
INSERT INTO Table1 (Col1, Col2) VALUES (1, 'string1'), (2, 'string2'); 
GO 

select * from Table1
