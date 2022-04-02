---------- DROP DB ----------

--triggers
DECLARE @sql VARCHAR(MAX)='';
SELECT @sql=@sql+'drop trigger ['+name +'];' FROM sys.objects 
WHERE type = 'tr' AND  is_ms_shipped = 0
exec(@sql);
GO


--spocs
DECLARE @sql VARCHAR(MAX)='';
SELECT @sql=@sql+'drop procedure ['+name +'];' FROM sys.objects 
WHERE type = 'p' AND  is_ms_shipped = 0
exec(@sql);
GO

DROP VIEW IF EXISTS dbo.[Questions per Questionnaire]

IF OBJECT_ID (N'dbo.canUserSeeQuestion', N'FN') IS NOT NULL DROP FUNCTION canUserSeeQuestion;
IF OBJECT_ID (N'dbo.canUserSeeQuestionnaire', N'FN') IS NOT NULL DROP FUNCTION canUserSeeQuestionnaire; 
IF OBJECT_ID (N'dbo.generateURL', N'FN') IS NOT NULL DROP FUNCTION generateURL;
IF OBJECT_ID (N'dbo.canUserSeeUser', N'FN') IS NOT NULL DROP FUNCTION canUserSeeUser; 

CREATE TABLE dbo.Doctors(
	[UID] int identity not null,
	national_id int unique,
	email varchar(50) unique not null,
	[password] varchar(20) not null,
	[first_name] varchar(20) not null,
	[last_name] varchar(30),
	[telephone] varchar(20),
	[address] varchar(50),
	[hospital_id] int
	)

CREATE TABLE dbo.Patients(
	[UID] int identity not null,
	national_id int unique,
	email varchar(50) unique not null,
	[first_name] varchar(20) not null,
	[last_name] varchar(30),
	[telephone] varchar(20),
	[address] varchar(50),
	[doctor_id] int
	)
-- END CREATION --


-- DUMMY DATA --
INSERT INTO Patients VALUES (1013129,'lpapal03@ucy.ac.cy', 'Loukas', 'Papalazarou', '+35796888185', 'Andrea Paraskeva', NULL)
INSERT INTO Doctors VALUES (1111111, 'doc01@ucy.ac.cy', 'doc01password', 'Antreas', 'Antreou', '+35799999999', 'Andrea Andreou', NULL)

-- STORED PROCEDURES --
GO
CREATE PROCEDURE Authenticate @email varchar(20), @password varchar(20)
AS
SELECT D.UID
FROM Doctors AS D
WHERE @email = D.email AND
	  @password = D.password

GO
EXEC Authenticate @email = 'doc01', @password = 'doc01password'
