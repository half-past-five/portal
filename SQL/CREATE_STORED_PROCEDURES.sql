-- STORED PROCEDURES --
GO
CREATE PROCEDURE Authenticate @username varchar(20), @password varchar(20)
AS
SELECT D.UID
FROM Doctors AS D
WHERE @username = D.username AND
	  @password = D.password
GO

GO
CREATE PROCEDURE ShowPatients @doctor_UID int
AS
SELECT national_id AS ID, first_name AS [First Name], last_name AS [Last Name]
FROM Patients AS P
WHERE P.doctor_id = @doctor_UID
GO