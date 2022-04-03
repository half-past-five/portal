-- DROP DATABASE --
:r C:\xampp\htdocs\hpf\portal\DROP_DATABASE.sql

-- BEGIN CREATION --
CREATE TABLE dbo.Doctors(
	[UID] int identity not null,
	national_id int unique,
	email varchar(50) unique not null,
	username varchar(20) unique not null,
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
INSERT INTO Patients VALUES (1013129,'lpapal03@ucy.ac.cy', 'Loukas', 'Papalazarou', '+35796888185', 'Andrea Paraskeva', 1)
INSERT INTO Patients VALUES (1011182,'klarko01@ucy.ac.cy', 'Konstantinos', 'Larkou', '+35799893353', 'Tasou Markou 1', 1)
INSERT INTO Patients VALUES (1011111,'mchrys01@ucy.ac.cy', 'Mikaella', 'Chrysostomou', '+35799999999', 'Poli tou Erota', 1)
INSERT INTO Doctors VALUES (1111111, 'admin.hpf@gmail.com', 'admin','admin', 'ADMIN', 'ADMIN', '+35799999999', NULL, NULL)

-- STORED PROCEDURES --
GO
CREATE PROCEDURE Authenticate @username varchar(20), @password varchar(20)
AS
SELECT D.UID
FROM Doctors AS D
WHERE @username = D.username AND
	  @password = D.password

GO
CREATE PROCEDURE ShowPatients @doctor_UID int
AS
SELECT national_id AS ID, first_name AS [First Name], last_name AS [Last Name]
FROM Patients AS P
WHERE P.doctor_id = @doctor_UID
GO


EXEC ShowPatients @doctor_UID = 1
