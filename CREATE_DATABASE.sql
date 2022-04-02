-- BEGIN CREATION --
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
INSERT INTO Doctors VALUES (1111111, 'doc01', 'doc01password', 'Antreas', 'Antreou', '+35799999999', 'Andrea Andreou', NULL)

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
