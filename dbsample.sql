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

---------- INSERTS ----------
--RUN 1.[T1-Company]
--RUN 2.[T1-User]
--RUN 3.[T1-Question]
--RUN 7.[T1-Questionnaire]
--RUN 7.[T1-Question Questionnaire Pairs]
---------- INSERTS ----------

---------- TRIGGERS ----------
GO
CREATE TRIGGER [Reject_Questionnaire_Delete] ON [T1-Questionnaire]
AFTER DELETE
AS
BEGIN
RAISERROR('Cannot delete questionnaire', 16, 1);
ROLLBACK TRANSACTION;
RETURN 
END
delete from [T1-Questionnaire] 
---------- VIEWS ----------

--Questions per Questionnaire VIEW creation
GO
CREATE VIEW dbo.[Questions per Questionnaire] AS
SELECT  QQP.[Questionnaire ID], COUNT(QQP.[Questionnaire ID]) as noOfQuestions
FROM  [T1-Question Questionnaire Pairs] QQP, [T1-Questionnaire] Q
WHERE QQP.[Questionnaire ID] = Q.[Questionnaire ID] AND Q.[URL] <> 'NULL'
GROUP BY QQP.[Questionnaire ID]

---------- UDFs ----------
GO  
CREATE FUNCTION dbo.canUserSeeQuestion(@caller_id int, @question_id int)  
RETURNS bit   
AS    
BEGIN  
IF @question_id NOT IN (
SELECT [Question ID]
FROM [T1-Question]
WHERE [Creator ID] in (
	SELECT [User ID]
	FROM [T1-User] u
	WHERE u.[Company ID] = (
		SELECT [Company ID] FROM [T1-User] WHERE [User ID] = @caller_id
		)
	)
) RETURN 0
RETURN 1
END;


GO  
CREATE FUNCTION dbo.canUserSeeQuestionnaire(@caller_id int, @questionnaire_id int)  
RETURNS bit   
AS    
BEGIN  
IF @questionnaire_id NOT IN (
SELECT [Questionnaire ID]
FROM [T1-Questionnaire]
WHERE [Creator ID] in (
	SELECT [User ID]
	FROM [T1-User] u
	WHERE u.[Company ID] = (
		SELECT [Company ID] FROM [T1-User] WHERE [User ID] = @caller_id
		)
	)
) RETURN 0
RETURN 1
END;


GO
CREATE FUNCTION dbo.generateURL(@questionnaire_id int)
RETURNS varchar(100)
AS
BEGIN
DECLARE @out_put varchar(100)
SET @out_put ='https://www.obervers.com/questionnaire_no_' + CAST(@questionnaire_id AS varchar(30))
RETURN @out_put
END;



GO
CREATE FUNCTION dbo.canUserSeeUser(@username1 varchar(30), @username2 varchar(30))
RETURNS BIT
AS
BEGIN
IF (SELECT [Company ID] FROM [T1-User] WHERE @username1 = [Username]) = (SELECT [Company ID] FROM [T1-User] WHERE @username2 = [Username]) RETURN 1
RETURN 0
END;


--select dbo.generateURL('1')
--select dbo.canUserSeeQuestion('3', '4')
--select dbo.canUserSeeQuestionnaire('1', '4')


---------- SPOCS ----------

--QUERY AUTHENTICATE--
GO
CREATE PROCEDURE dbo.Authenticate @username varchar(30), @password varchar(30)
AS
SELECT CONVERT(varchar, [User ID]) as [User ID], CONVERT(varchar, Privilages) as Privilages
FROM [T1-User]
WHERE Username = @username and [Password] = @password


--QUERY SHOW ALL QUESTIONS--
GO
CREATE PROCEDURE dbo.ShowQuestions @caller_id int
AS
SELECT *
FROM [T1-Question]
WHERE [Creator ID] in (
	SELECT [User ID]
	FROM [T1-User] u
	WHERE u.[Company ID] = (
		SELECT [Company ID] FROM [T1-User] WHERE [User ID] = @caller_id
		)
	)


--SHOW QUESTION DETAILS--
GO
CREATE PROCEDURE dbo.ShowQuestionDetails @caller_id int, @question_id int
AS
IF (SELECT dbo.canUserSeeQuestion(@caller_id, @question_id)) = 0 RETURN
DECLARE @q_type varchar(30)
SET @q_type = (SELECT [Type] FROM [T1-Question] WHERE [Question ID] = @question_id)

IF @q_type = 'Free Text'
	BEGIN
	SELECT * FROM [T1-Free Text Question] WHERE [Question ID] = @question_id
	END
IF @q_type = 'Arithmetic'
	BEGIN
	SELECT * FROM [T1-Arithmetic Question] WHERE [Question ID] = @question_id
	END
IF @q_type = 'Multiple Choice'
	BEGIN
	SELECT * FROM [T1-Multiple Choice Question] WHERE [Question ID] = @question_id
	END				


--QUERY SHOW ALL COMPANY'S QUESTIONNAIRES --
GO
CREATE PROCEDURE dbo.ShowQuestionnaires @caller_id int
AS
SELECT *
FROM [T1-Questionnaire]
WHERE [Creator ID] in (
	SELECT [User ID]
	FROM [T1-User] u
	WHERE u.[Company ID] = (
		SELECT [Company ID] FROM [T1-User] WHERE [User ID] = @caller_id
		)
	)


--QUERY SHOW ALL COMPANY USERS--
GO
CREATE PROCEDURE dbo.ShowQUsers @caller_id int
AS
DECLARE @admin_company_id int
SELECT @admin_company_id = u.[Company ID]
FROM [T1-User] u
WHERE u.[User ID] = @caller_id 
SELECT CONVERT(varchar(30), [User ID]) as [User ID], CONVERT(varchar(30), [Name]) as [Name], CONVERT(varchar(30), [Birth Date]) as [Birth Date], CONVERT(varchar(30), [Sex]) as [Sex], CONVERT(varchar(30), [Position]) as [Position],
CONVERT(varchar(30), [Username]) as [Username], CONVERT(varchar(30), [Password]) as [Password], CONVERT(varchar(30), [Privilages]) as [Privilages],
CONVERT(varchar(30), [Company ID]) as [Company ID], CONVERT(varchar(30), [Manager ID]) as [Manager ID]  
FROM [T1-User] u
WHERE u.[Company ID] = @admin_company_id



--INSERT ANSWER TO MULTIPLE CHOICE--
GO
CREATE PROCEDURE dbo.InsertAnswerMultChoice @caller_id int, @question_id int, @answer varchar(50)
AS
--check if caller is correct
IF dbo.canUserSeeQuestion(@caller_id, @question_id) = 0 RETURN
--check if multiple choice
IF 'Multiple Choice' NOT IN (SELECT [Type] FROM [T1-Question] WHERE @question_id = [Question ID]) RETURN
INSERT INTO [T1-Multiple Choice Answers]([Question ID], [Answer]) VALUES (@question_id, @answer)


--EDIT ANSWER TO MULTIPLE CHOICE--
GO
CREATE PROCEDURE dbo.EditAnswerMultChoice @caller_id int, @question_id int, @answer varchar(50), @new_answer varchar(50)
AS
--check if caller is correct
IF dbo.canUserSeeQuestion(@caller_id, @question_id) = 0 RETURN
--check if multiple choice
IF 'Multiple Choice' NOT IN (SELECT [Type] FROM [T1-Question] WHERE @question_id = [Question ID]) RETURN
UPDATE [T1-Multiple Choice Answers] SET [Answer] = @new_answer WHERE @answer = [Answer] AND @question_id = [Question ID]


--REMOVE ANSWER FROM MULT CHOICE--
GO
CREATE PROCEDURE dbo.RemoveAnswerMultChoice @caller_id int, @question_id int, @answer varchar(50)
AS
--check if caller is correct
IF dbo.canUserSeeQuestion(@caller_id, @question_id) = 0 RETURN
--check if multiple choice
IF 'Multiple Choice' NOT IN (SELECT [Type] FROM [T1-Question] WHERE @question_id = [Question ID]) RETURN
DELETE FROM [T1-Multiple Choice Answers] WHERE @answer = [Answer] AND @question_id = [Question ID]


--SHOW ALL ANSWERS OF MULT CHOICE
GO
CREATE PROCEDURE dbo.ShowAnswerMultChoice @caller_id int, @question_id int
AS
--check if caller is correct
IF dbo.canUserSeeQuestion(@caller_id, @question_id) = 0 RETURN
--check if multiple choice
IF 'Multiple Choice' NOT IN (SELECT [Type] FROM [T1-Question] WHERE @question_id = [Question ID]) RETURN
SELECT [Answer] FROM [T1-Multiple Choice Answers] WHERE @question_id = [Question ID]


--SET QUESTIONNAIRE TO 'NOT DONE'--
GO
CREATE PROCEDURE dbo.setQuestionnaireNotDone @caller_id int, @questionnaire_id int
AS
IF dbo.canUserSeeQuestion(@caller_id, @questionnaire_id) = 0 RETURN
UPDATE [T1-Questionnaire] SET [URL] = NULL


--QUERY 1--
GO
CREATE PROCEDURE dbo.Q1 @name varchar(50), @bday date, @sex char(1), 
@position varchar(30), @username varchar(30), @password varchar(30), @manager_id int, 
@company_reg_num int, @company_brand_name varchar(50), @IDCard int
AS
ALTER TABLE [T1-User] NOCHECK CONSTRAINT ALL;
ALTER TABLE [T1-Company] NOCHECK CONSTRAINT ALL;
INSERT INTO [T1-Company] ([Registration Number], [Brand Name], [Induction Date]) VALUES (@company_reg_num, @company_brand_name, CAST( GETDATE() AS Date ))
INSERT INTO [T1-User] ([Name], [Birth Date], [Sex], [Position], [Username], [Password], [Privilages], [Company ID], [Manager ID], [IDCard]) VALUES (@name, @bday, @sex, @position, @username, @password,'2', @company_reg_num, @manager_id, @IDCard)
ALTER TABLE [T1-User] CHECK CONSTRAINT ALL
ALTER TABLE [T1-Company] CHECK CONSTRAINT ALL

--QUERY 2a--
GO
CREATE PROCEDURE dbo.Q2a @action varchar(30), @company_id  varchar(30), @brand_name varchar(30), @new_date varchar(30)
AS
IF @action = 'insert'
	BEGIN
	INSERT INTO [T1-Company] ([Registration Number], [Brand Name], [Induction Date]) VALUES (@company_id, @brand_name, CAST( GETDATE() AS Date ))
	END
IF @action = 'update'
	BEGIN
	IF @brand_name <> '' BEGIN UPDATE [T1-Company] SET [Brand Name] = @brand_name WHERE @company_id=[Registration Number] END 
	IF @new_date <> '' BEGIN UPDATE [T1-Company] SET [Induction Date] = CAST( @new_date AS Date ) WHERE @company_id=[Registration Number] END 
	END
IF @action = 'show'
	BEGIN
	SELECT
	CAST([Registration Number] AS varchar(30)) as [Registration Number],
	CAST([Brand Name] AS varchar(30)) as [Brand Name],
	CAST([Induction Date] AS varchar(30)) as [Induction Date]
	FROM [T1-Company]
	WHERE @company_id = [Registration Number]
	END


--QUERY 2b--
GO
CREATE PROCEDURE dbo.Q2b @action varchar(30), @name varchar(50), @bday date, @sex char(1), 
@position varchar(30), @username varchar(30), @password varchar(30), @manager_id int, @company_id int
AS
IF  @action = 'insert'
	BEGIN
	INSERT INTO [T1-User] ([Name], [Birth Date], [Sex], [Position], [Username], [Password], [Privilages], [Company ID], [Manager ID]) VALUES (@name, @bday, @sex, @position, @username, @password,'2', @company_id, @manager_id)
	END

IF @action = 'update'
	BEGIN
	IF @name <>'' BEGIN UPDATE [T1-User] SET [Name] = @name WHERE Username = @username END
	IF @bday <>'' BEGIN UPDATE [T1-User] SET [Birth Date] = @bday WHERE Username = @username END
	IF @sex <>'' BEGIN UPDATE [T1-User] SET [Sex] = @sex WHERE Username = @username END
	IF @position <>'' BEGIN UPDATE [T1-User] SET [Position] = @position WHERE Username = @username END
	IF @password <>'' BEGIN UPDATE [T1-User] SET [Password] = @password WHERE Username = @username END
	IF @manager_id <>'' BEGIN UPDATE [T1-User] SET [Manager ID] = @manager_id WHERE Username = @username END
	IF @company_id <>'' BEGIN UPDATE [T1-User] SET [Company ID] = @company_id WHERE Username = @username END
	END
IF  @action = 'show'
	BEGIN
	SELECT 
	CAST([Name] AS varchar(30)) as [Name],
	CAST([Birth Date] AS varchar(30)) as [Birth Date],
	CAST([Sex] AS varchar(30)) as [Sex],
	CAST([Position] AS varchar(30)) as [Position],
	CAST([Password] AS varchar(30)) as [Password],
	CAST([Company ID]  AS varchar(30)) as [Company ID],
	CAST([Manager ID] AS varchar(30)) as [Manager ID]
	FROM [T1-User] U
	WHERE @username = U.Username
	END


--QUERY 3--
GO
CREATE PROCEDURE dbo.Q3 @admin_id int, @name varchar(50), @bday date, @sex char(1), 
@position varchar(30), @username varchar(30), @password varchar(30), @manager_id int
AS
DECLARE @admin_company_id int
SELECT @admin_company_id = u.[Company ID]
FROM [T1-User] u
WHERE u.[User ID] = @admin_id 
INSERT INTO [T1-User] ([Name], [Birth Date], [Sex], [Position], [Username], [Password], [Privilages], [Company ID], [Manager ID]) VALUES (@name, @bday, @sex, @position, @username, @password,'3', @admin_company_id, @manager_id)


--QUERY 4--
GO
CREATE PROCEDURE dbo.Q4 @admin_id int, @action varchar(30), @name varchar(50), @bday date, @sex char(1), 
@position varchar(30), @username varchar(30), @password varchar(30), @manager_id int
AS
DECLARE @admin_company_id int
SELECT @admin_company_id = u.[Company ID]
FROM [T1-User] u
WHERE u.[User ID] = @admin_id 
IF  @action = 'insert'
	BEGIN
	INSERT INTO [T1-User] ([Name], [Birth Date], [Sex], [Position], [Username], [Password], [Privilages], [Company ID], [Manager ID]) VALUES (@name, @bday, @sex, @position, @username, @password,'3', @admin_company_id, @manager_id)
	END

DECLARE @caller_usernme varchar(30)
SET @caller_usernme = (SELECT [Username] FROM [T1-User] WHERE @admin_id = [User ID])
IF dbo.canUserSeeUser(@caller_usernme, @username) = 0 RETURN 

IF @action = 'update'
	BEGIN
	IF @name <>'' BEGIN UPDATE [T1-User] SET [Name] = @name WHERE Username = @username END
	IF @bday <>'' BEGIN UPDATE [T1-User] SET [Birth Date] = @bday WHERE Username = @username END
	IF @sex <>'' BEGIN UPDATE [T1-User] SET [Sex] = @sex WHERE Username = @username END
	IF @position <>'' BEGIN UPDATE [T1-User] SET [Position] = @position WHERE Username = @username END
	IF @password <>'' BEGIN UPDATE [T1-User] SET [Password] = @password WHERE Username = @username END
	IF @manager_id <>'' BEGIN UPDATE [T1-User] SET [Manager ID] = @manager_id WHERE Username = @username END
	END
IF  @action = 'show'
	BEGIN
	SELECT 
	CAST([Name] AS varchar(30)) as [Name],
	CAST([Birth Date] AS varchar(30)) as [Birth Date],
	CAST([Sex] AS varchar(30)) as [Sex],
	CAST([Position] AS varchar(30)) as [Position],
	CAST([Password] AS varchar(30)) as [Password],
	CAST([Privilages] AS varchar(30)) as [Privilages],
	CAST([Company ID]  AS varchar(30)) as [Company ID],
	CAST([Manager ID] AS varchar(30)) as [Manager ID]
	FROM [T1-User] U
	WHERE @username = U.Username AND [Company ID] = @admin_company_id
	END


--QUERY 5--
GO
CREATE PROCEDURE dbo.Q5 @caller_id int, @action varchar(20), @question_id int, @type varchar(30),
@description varchar(50), @text varchar(100), @free_text_restriction varchar(30), @mult_choice_selectable_amount int,
@arithm_min int, @arithm_max int
AS
IF @action = 'insert'
	BEGIN
	INSERT INTO [T1-Question]([Creator ID], [Type], [Description], [Text]) VALUES(@caller_id, @type, @description, @text)
	DECLARE @new_question_id int = SCOPE_IDENTITY()
	IF @type = 'Free Text'
		BEGIN
		INSERT INTO [T1-Free Text Question] ([Question ID], [Restriction]) VALUES (@new_question_id, @free_text_restriction)
		END
	IF @type = 'Multiple Choice'
		BEGIN
		INSERT INTO [T1-Multiple Choice Question] ([Question ID], [Selectable Amount]) VALUES (@new_question_id, @mult_choice_selectable_amount)
		END
	IF @type = 'Arithmetic'
		BEGIN
		INSERT INTO [T1-Arithmetic Question] ([Question ID], [MIN value], [MAX value]) VALUES (@new_question_id, @arithm_min, @arithm_max)
 		END
	END

--IF Q does not belog to users cimpany OR Q is in qqp -> abort
IF dbo.canUserSeeQuestion(@caller_id, @question_id) = 0 RETURN
IF @question_id IN (SELECT [Question ID] FROM [T1-Question Questionnaire Pairs]) RETURN 

IF @action = 'update'
	BEGIN
	IF @description <>'' BEGIN UPDATE [T1-Question] SET [Description] = @description WHERE [Question ID] = @question_id END
	IF @text <>'' BEGIN UPDATE [T1-Question] SET [Text] = @text WHERE [Question ID] = @question_id END
	IF @type = 'Free Text'
		BEGIN
		IF @free_text_restriction <>'' BEGIN UPDATE [T1-Free Text Question] SET [Restriction] = @free_text_restriction WHERE [Question ID] = @question_id END
		END
	IF @type = 'Multiple Choice'
		BEGIN
		IF @mult_choice_selectable_amount <> '' BEGIN UPDATE [T1-Multiple Choice Question] SET [Selectable Amount] = @mult_choice_selectable_amount WHERE [Question ID] = @question_id END
		END
	IF @type = 'Arithmetic'
		BEGIN
		IF @arithm_min <> '' BEGIN UPDATE [T1-Arithmetic Question] SET [MIN value] = @arithm_min WHERE [Question ID] = @question_id END
		IF @arithm_max <> '' BEGIN UPDATE [T1-Arithmetic Question] SET [MAX value] = @arithm_max WHERE [Question ID] = @question_id END
		END
	END
IF @action = 'delete'
	BEGIN
	DELETE FROM [T1-Question] WHERE [Question ID] = @question_id --cascades to specific question types
	END



--QUERY 6a (CREATE NEW)--
GO
CREATE PROCEDURE dbo.Q6a @caller_id int, @title varchar(30)
AS
INSERT INTO [T1-Questionnaire]([Title], [Version], [Parent ID], [Creator ID], [URL]) VALUES (@title, '1', NULL, @caller_id, NULL) 


--QUERY 6b (SHOW QUESTIONS OF QUESTIONNAIRE)-- ***NOT DONE***
GO
CREATE PROCEDURE dbo.Q6b @caller_id int, @questionnaire_id int
AS
IF dbo.canUserSeeQuestionnaire(@caller_id, @questionnaire_id) = 0 RETURN 
SELECT q.[Question ID],q.[Creator ID], q.[Type], q.[Description], q.[Text]
FROM [T1-Questionnaire] qr, [T1-Question] q, [T1-Question Questionnaire Pairs] qqp
WHERE qr.[Creator ID] in (
	SELECT [User ID]
	FROM [T1-User] u
	WHERE u.[Company ID] = (
		SELECT [Company ID] FROM [T1-User] WHERE [User ID] = @caller_id
		)
	)
AND qr.[Questionnaire ID] = qqp.[Questionnaire ID] AND q.[Question ID] = qqp.[Question ID] AND qr.[Questionnaire ID]=@questionnaire_id

/*
exec Q6b @caller_id='1', @questionnaire_id='1'
exec Q6a @caller_id = '1', @title = 'newquest'
exec ShowQuestionnaires @caller_id = '1'
exec Q6c @caller_id = '1', @questionnaire_id = '13', @question_id = '1'
*/


--QUERY 6c (ADD QUESTION TO QUESTIONNAIRE)--
GO
CREATE PROCEDURE dbo.Q6c @caller_id int, @questionnaire_id int, @question_id int
AS
IF (SELECT [URL] FROM [T1-Questionnaire] q WHERE @questionnaire_id = q.[Questionnaire ID]) <> NULL RETURN 
IF (SELECT dbo.canUserSeeQuestion(@caller_id, @question_id)) = 0 RETURN --user has access to question
IF (SELECT dbo.canUserSeeQuestionnaire(@caller_id, @questionnaire_id)) = 0 RETURN --user has access to questionnaire
INSERT INTO [T1-Question Questionnaire Pairs]([Questionnaire ID], [Question ID]) VALUES (@questionnaire_id, @question_id)

/*
exec ShowQuestions @caller_id = '1'
exec ShowQuestionnaires @caller_id = '1'
exec ShowQuestionsOfQuestionnaire @caller_id = '1', @questionnaire_id = '1'
exec Q6c @caller_id = '1', @questionnaire_id = '1', @question_id = '1'
exec Q6d @caller_id = '1', @questionnaire_id = '1', @question_id = '1'
*/


--QUERY 6d (REMOVE QUESTION FROM QUESTIONNAIRE)--
GO
CREATE PROCEDURE dbo.Q6d @caller_id int, @questionnaire_id int, @question_id int
AS
IF (SELECT dbo.canUserSeeQuestion(@caller_id, @question_id)) = 0 RETURN --user has access to question
IF (SELECT dbo.canUserSeeQuestionnaire(@caller_id, @questionnaire_id)) = 0 RETURN --user has access to questionnaire
DELETE FROM [T1-Question Questionnaire Pairs] WHERE [Question ID] = @question_id AND [Questionnaire ID] = @questionnaire_id


--QUERY 6e (CHANGE QUERY STATE)--
GO
CREATE PROCEDURE dbo.Q6e @caller_id int, @questionnaire_id int
AS
IF (SELECT dbo.canUserSeeQuestionnaire(@caller_id, @questionnaire_id)) = 0 RETURN --user has access to questionnaire
UPDATE [T1-Questionnaire] SET [URL] = dbo.generateURL(@questionnaire_id) WHERE [Questionnaire ID] = @questionnaire_id
--exec Q6e @caller_id='1', @questionnaire_id='6'


--QUERY 6f (CLONE)-- ***NOT DONE***
GO
CREATE PROCEDURE dbo.Q6f @caller_id int, @questionnaire_id int
AS
IF (SELECT dbo.canUserSeeQuestionnaire(@caller_id, @questionnaire_id)) = 0 RETURN
IF (SELECT [URL] FROM [T1-Questionnaire] WHERE [Questionnaire ID] = @questionnaire_id) = NULL RETURN --cannot be cloned because its not completed
DECLARE @title varchar(30)
SET @title = (SELECT [Title] q FROM [T1-Questionnaire] q WHERE [Questionnaire ID] = @questionnaire_id)
DECLARE @version int 
SET @version = (SELECT [Version] q FROM [T1-Questionnaire] q WHERE [Questionnaire ID] = @questionnaire_id)
SET @version = @version + 1
INSERT INTO [T1-Questionnaire]([Title], [Version], [Parent ID], [Creator ID], [URL]) VALUES (@title, @version, @questionnaire_id, @caller_id, NULL) 


--QUERY 7-- WORKS
GO
CREATE PROCEDURE dbo.Q7 @user_id int
AS

SELECT Q.Title, Q.Version, QPQ.noOfQuestions
FROM [T1-Questionnaire] Q, [Questions per Questionnaire] QPQ
WHERE [Creator ID] in (
	SELECT [User ID]
	FROM [T1-User] u
	WHERE u.[Company ID] = (
		SELECT [Company ID] FROM [T1-User] WHERE [User ID] = @user_id
						)
					)
AND QPQ.[Questionnaire ID] = Q.[Questionnaire ID]
ORDER BY QPQ.noOfQuestions ASC



--QUERY 8--
GO
CREATE PROCEDURE dbo.Q8 @user_id int
AS
--DECLARE @user_id int
--SET @user_id = 1
DECLARE @maxNoOfQuestionnaires 	 int;
SET @maxNoOfQuestionnaires = (SELECT MAX(QuestionnaireCount.noOfQuestionnaires)	
								FROM  (	SELECT  QQP.[Question ID], COUNT(QQP.[Question ID]) as noOfQuestionnaires
										FROM  [T1-Question Questionnaire Pairs] QQP, [T1-Questionnaire] Qnnaire, [T1-User] U, [T1-Company] C
										WHERE QQP.[Questionnaire ID] = Qnnaire.[Questionnaire ID] AND Qnnaire.[URL] <> 'NULL' AND Qnnaire.[Creator ID] = U.[User ID] AND U.[Company ID] = C.[Company ID] AND Qnnaire.[Creator ID] in (
												SELECT [User ID]
												FROM [T1-User] u
												WHERE u.[Company ID] = (
												SELECT [Company ID] FROM [T1-User] WHERE [User ID] =  @user_id
												)
												)
										GROUP BY QQP.[Question ID]
										) as QuestionnaireCount
										)
--print @maxNoOfQuestionnaires 	
SELECT *
FROM  (	SELECT  QQP.[Question ID], COUNT(QQP.[Question ID]) as noOfAppearances
		FROM  [T1-Question Questionnaire Pairs] QQP, [T1-Questionnaire] Qnnaire, [T1-User] U, [T1-Company] C
		WHERE QQP.[Questionnaire ID] = Qnnaire.[Questionnaire ID] AND Qnnaire.[URL] <> 'NULL' AND Qnnaire.[Creator ID] = U.[User ID] AND U.[Company ID] = C.[Company ID] AND Qnnaire.[Creator ID] in (
		SELECT [User ID]
		FROM [T1-User] u
		WHERE u.[Company ID] = (
		SELECT [Company ID] FROM [T1-User] WHERE [User ID] =  @user_id
		)
		)
		GROUP BY QQP.[Question ID]
		) as QuestionnaireCount
WHERE QuestionnaireCount.noOfAppearances = @maxNoOfQuestionnaires 	



--QUERY 9 
GO
CREATE PROCEDURE dbo.Q9
AS
SELECT Title, [Version], COUNT([Question ID]) as q_count
FROM [T1-Question Questionnaire Pairs] qqp,[T1-Questionnaire] q
WHERE
q.URL <> 'NULL' AND qqp.[Questionnaire ID] = q.[Questionnaire ID]

GROUP BY Title, [Version]


--Query 10 
GO
CREATE PROCEDURE dbo.Q10 @user_id int
AS

/* tuto gia kathe company
SELECT C.[Brand Name],AVG(QpQ.noOfQuestions) AS 'AVG number of Questions' 
	FROM [Questions per Questionnaire] QpQ, [T1-Questionnaire] Qnnaire, [T1-User] U, [T1-Company] C
	WHERE QpQ.[Questionnaire ID] =	Qnnaire.[Questionnaire ID] AND Qnnaire.[Creator ID] = U.[User ID] AND U.[Company ID] = C.[Registration Number]
	GROUP BY C.[Brand Name]
*/		


SELECT C.[Brand Name],AVG(QpQ.noOfQuestions) AS 'AVG number of Questions' 
	FROM [Questions per Questionnaire] QpQ, [T1-Questionnaire] Qnnaire, [T1-User] U, [T1-Company] C
	WHERE QpQ.[Questionnaire ID] =	Qnnaire.[Questionnaire ID] AND Qnnaire.[Creator ID] = U.[User ID] AND U.[Company ID] = C.[Company ID] AND Qnnaire.[Creator ID] in (
		SELECT [User ID]
		FROM [T1-User] u
		WHERE u.[Company ID] = (
		SELECT [Company ID] FROM [T1-User] WHERE [User ID] =  @user_id
		)
	)
	GROUP BY C.[Brand Name]
	

--Query 11 
GO
CREATE PROCEDURE dbo.Q11 @user_id int
AS
--declare @user_id int
--@user_id = '6'
DECLARE @avgNoOfQuestions int;

SET @avgNoOfQuestions  = (SELECT AVG(QpQ.noOfQuestions) 
	FROM [Questions per Questionnaire] QpQ, [T1-Questionnaire] Qnnaire
	WHERE QpQ.[Questionnaire ID] =	Qnnaire.[Questionnaire ID] AND Qnnaire.[Creator ID] IN (
		SELECT [User ID]
		FROM [T1-User] U
		WHERE U.[Company ID] = (SELECT [Company ID] FROM [T1-User] WHERE [User ID] = @user_id )
					)
					)

print @avgNoOfQuestions 	

SELECT  Qnnaire.Title, Qnnaire.Version, QPQ.noOfQuestions
FROM [Questions per Questionnaire] QpQ, [T1-Questionnaire] Qnnaire 
WHERE QpQ.[Questionnaire ID] =	Qnnaire.[Questionnaire ID] AND QpQ.noOfQuestions > @avgNoOfQuestions AND Qnnaire.[Creator ID] IN (
		SELECT [User ID]
		FROM [T1-User] U
		WHERE U.[Company ID] = (SELECT [Company ID] FROM [T1-User] WHERE [User ID] = @user_id )
		)



--Query 12 
GO
CREATE PROCEDURE dbo.Q12 @user_id int
AS
DECLARE @minNoOfQuestions int;
SET @minNoOfQuestions  = (SELECT MIN(QpQ.noOfQuestions) a
	FROM [Questions per Questionnaire] QpQ, [T1-Questionnaire] Qnnaire
	WHERE QpQ.[Questionnaire ID] =	Qnnaire.[Questionnaire ID] AND Qnnaire.[Creator ID] IN (
		SELECT [User ID]
		FROM [T1-User] U
		WHERE U.[Company ID] = (SELECT [Company ID] FROM [T1-User] WHERE [User ID] = @user_id )
					)
					)
--print @minNoOfQuestions 				
SELECT  Qnnaire.Title, Qnnaire.Version, QPQ.noOfQuestions
FROM [Questions per Questionnaire] QpQ, [T1-Questionnaire] Qnnaire 
WHERE QpQ.[Questionnaire ID] =	Qnnaire.[Questionnaire ID] AND QpQ.noOfQuestions = @minNoOfQuestions AND Qnnaire.[Creator ID] IN (
		SELECT [User ID]
		FROM [T1-User] U
		WHERE U.[Company ID] = (SELECT [Company ID] FROM [T1-User] WHERE [User ID] = @user_id )
					)



--Query 13 
GO
CREATE PROCEDURE dbo.Q13 @user_id int
AS
/*
DECLARE @user_id int
SET @user_id = 1
*/
--SELECT DISTINCT CompanyQuestionnaires1.[Questionnaire ID],CompanyQuestionnaires1.Title,CompanyQuestionnaires1.noOfQuestions
SELECT *
FROM (	SELECT   Qnnaire.[Questionnaire ID],Qnnaire.Title, Qnnaire.Version, QPQ.noOfQuestions
		FROM [Questions per Questionnaire] QpQ, [T1-Questionnaire] Qnnaire 
		WHERE QpQ.[Questionnaire ID] =	Qnnaire.[Questionnaire ID] AND Qnnaire.[Creator ID] IN (
				SELECT [User ID]
				FROM [T1-User] U
				WHERE U.[Company ID] = (SELECT [Company ID] FROM [T1-User] WHERE [User ID] = @user_id )
				)
				)as CompanyQuestionnaires1 ,

	(	SELECT   Qnnaire.[Questionnaire ID],Qnnaire.Title, Qnnaire.Version, QPQ.noOfQuestions
		FROM [Questions per Questionnaire] QpQ, [T1-Questionnaire] Qnnaire 
		WHERE QpQ.[Questionnaire ID] =	Qnnaire.[Questionnaire ID] AND Qnnaire.[Creator ID] IN (
				SELECT [User ID]
				FROM [T1-User] U
				WHERE U.[Company ID] = (SELECT [Company ID] FROM [T1-User] WHERE [User ID] = @user_id )
				)
				)as CompanyQuestionnaires2				
		WHERE NOT EXISTS(
		--All questions of questionaire in CompanyQuestionnaires1
		(SELECT QQP1.[Question ID]
		FROM [T1-Question Questionnaire Pairs] QQP1
		WHERE QQP1.[Questionnaire ID] =  CompanyQuestionnaires1.[Questionnaire ID] 
		) 
		EXCEPT
		--Questions of another questionaire in CompanyQuestionnaires2
		(SELECT QQP2.[Question ID]
		FROM [T1-Question Questionnaire Pairs] QQP2
		WHERE QQP2.[Questionnaire ID] = CompanyQuestionnaires2.[Questionnaire ID] 
		)
		
		) 
		AND CompanyQuestionnaires1.noOfQuestions = CompanyQuestionnaires2.noOfQuestions
		AND CompanyQuestionnaires1.[Questionnaire ID] <> CompanyQuestionnaires2.[Questionnaire ID]
		ORDER BY CompanyQuestionnaires1.noOfQuestions ASC
	

--QUERY 14--
GO
CREATE PROCEDURE dbo.Q14 @user_id int, @qn_id int 
AS

/* --for testing 
DECLARE @qn_id int
SET @qn_id = 7
DECLARE @user_id int
SET @user_id = 1
*/


SELECT *
FROM [T1-Questionnaire] Qn
WHERE  NOT EXISTS
(
	--All questions of questionaire
	(SELECT QQP1.[Question ID]
	FROM [T1-Question Questionnaire Pairs] QQP1 ,[T1-Questionnaire] Qnnaire 
		WHERE QQP1.[Questionnaire ID] =	Qnnaire.[Questionnaire ID] AND Qnnaire.[Creator ID] IN (
				SELECT [User ID]
				FROM [T1-User] U
				WHERE U.[Company ID] = (SELECT [Company ID] FROM [T1-User] WHERE [User ID] = @user_id ) AND QQP1.[Questionnaire ID] = @qn_id
	))
	EXCEPT
	--Questions of current questionaire
	(SELECT QQP2.[Question ID]
	FROM [T1-Question Questionnaire Pairs] QQP2,[T1-Questionnaire] Qnnaire 
		WHERE QQP2.[Questionnaire ID] =	Qnnaire.[Questionnaire ID] AND Qnnaire.[Creator ID] IN (
				SELECT [User ID]
				FROM [T1-User] U
				WHERE U.[Company ID] = (SELECT [Company ID] FROM [T1-User] WHERE [User ID] = @user_id ) AND QQP2.[Questionnaire ID] = Qn.[Questionnaire ID]
	))
)AND Qn.URL <> 'NULL' AND Qn.[Questionnaire ID] <> @qn_id


--QUERY 15--

GO
CREATE PROCEDURE dbo.Q15 @user_id int, @k_min int 
AS
/*
DECLARE @k_min int
SET @k_min = 1
DECLARE @user_id int
SET @user_id = 31
*/

SELECT Q.[Question ID], MinimumQ.qn_COUNT AS 'Questionnaire Count'
FROM [T1-Question] Q,(	SELECT TOP (@k_min) QQP.[Question ID], COUNT(*) AS q_COUNT , COUNT(Qnnaire.[Questionnaire ID]) AS qn_COUNT
						FROM [T1-Question Questionnaire Pairs] QQP, [T1-Questionnaire] Qnnaire
						WHERE QQP.[Questionnaire ID] =	Qnnaire.[Questionnaire ID] AND Qnnaire.[URL] <> 'NULL' AND Qnnaire.[Creator ID] IN (
							SELECT [User ID]
							FROM [T1-User] U
							WHERE U.[Company ID] = (SELECT [Company ID] FROM [T1-User] WHERE [User ID] = @user_id )
										)
						GROUP BY QQP.[Question ID]
						ORDER BY q_COUNT ASC
					) MinimumQ
WHERE Q.[Question ID] = MinimumQ.[Question ID] 



--QUERY 16--
GO
CREATE PROCEDURE dbo.Q16 @user_id int
AS

/*DECLARE @user_id int
SET @user_id = 276
*/
DECLARE @noOfQuestionnaires int

set @noOfQuestionnaires =(SELECT    COUNT( Qnnaire.[Questionnaire ID])
		FROM [Questions per Questionnaire] QpQ, [T1-Questionnaire] Qnnaire 
		WHERE QpQ.[Questionnaire ID] =	Qnnaire.[Questionnaire ID] AND Qnnaire.[Creator ID] IN (
				SELECT [User ID]
				FROM [T1-User] U
				WHERE U.[Company ID] = (SELECT [Company ID] FROM [T1-User] WHERE [User ID] = @user_id )
				)
				)

	print @noOfQuestionnaires

SELECT *
FROM ( SELECT QQP.[Question ID], COUNT(QQP.[Questionnaire ID]) AS noOfQuestionAppearances 
FROM [T1-Question Questionnaire Pairs] QQP, [T1-Questionnaire] Qnnaire 
		WHERE QQP.[Questionnaire ID] =	Qnnaire.[Questionnaire ID] AND Qnnaire.URL <> 'NULL' AND Qnnaire.[Creator ID] IN (
				SELECT [User ID]
				FROM [T1-User] U
				WHERE U.[Company ID] = (SELECT [Company ID] FROM [T1-User] WHERE [User ID] = @user_id )
				)
GROUP BY QQP.[Question ID]) as  array
WHERE array.noOfQuestionAppearances = @noOfQuestionnaires


/*
---------- TESTING ----------

exec Q1 @name='Loukis', @bday='2000/6/26', @sex='M', 
@position='Manager', @username='lpapal03', @password='hehehe', @manager_id=NULL, 
@company_reg_num ='999', @company_brand_name='Noname Company'

exec Q2b @action='insert', @name = 'KAS', @bday='2000/6/26', @sex='F', 
@position='Katotatos', @username='klarko02', @password='hihi', @manager_id=NULL, @company_id = '1'

exec Q3 @admin_id='3', @name='Kostis', @bday='2000/6/26', @sex='M', 
@position='Sales', @username='kost05', @password='hehehe', @manager_id='4'

exec Q4 @action='show', @admin_id='2', @name='Kostis', @bday='2000/6/26', @sex='M', 
@position='Sales', @username='kost06', @password='hehehe', @manager_id='4'


exec Q5 @caller_id = '3', @action='insert', @question_id = NULL, @type= 'Multiple Choice',
@description='test question', @text='do u liek db?', @free_text_restriction='<=100', @mult_choice_selectable_amount='3',
@mult_choice_answers='Answer 1, Answer 2, Answer 3', @arithm_min='10', @arithm_max='100'

exec Q7 @user_id = '276' --sosto

exec Q8 @user_id = '276' --oi

exec Q9 --idios arithmos

exec Q10 @user_id = '276' --oi 16.125(16)

exec Q11 @user_id = '276' --sosto

exec Q12 @user_id = '276' --sosto

exec Q13 @user_id = '14' --oi? mporei na doulevi je na men eshi ta idia(evalan ofkera gia test)

exec Q14 @user_id = '276', @qn_id = '1' --oi? mporei na men eshi me ta idia

exec Q15 @user_id = '276', @k_min = '15'

exec Q16 @user_id = '276' --oi


exec Q17

select *
from [T1-Question Questionnaire Pairs] q
where q.[Question ID] = '948'

select * from [T1-Questionnaire] where [Questionnaire ID] = 197
/*
@description varchar(50), @text varchar(100), @free_text_restriction varchar(30), @mult_choice_selectable_amount int,
@mult_choice_answers varchar(1000), @arithm_min int, @arithm_max int
*/

--Query 13 testing 
/*
exec Q13 @user_id = '6'
exec Q13 @user_id = '20'
exec Q13 @user_id = '31'
exec Q13 @user_id = '44'
exec Q13 @user_id = '58'
exec Q13 @user_id = '71'
exec Q13 @user_id = '82'
exec Q13 @user_id = '93'
exec Q13 @user_id = '108'
exec Q13 @user_id = '123'
exec Q13 @user_id = '140'
exec Q13 @user_id = '152'
exec Q13 @user_id = '164'
exec Q13 @user_id = '179'
exec Q13 @user_id = '194'
exec Q13 @user_id = '209'
exec Q13 @user_id = '223'
exec Q13 @user_id = '236'
exec Q13 @user_id = '253'
exec Q13 @user_id = '268'
exec Q13 @user_id = '279'
exec Q13 @user_id = '293'
exec Q13 @user_id = '308'
exec Q13 @user_id = '320'
exec Q13 @user_id = '333'
exec Q13 @user_id = '349'
exec Q13 @user_id = '362'
exec Q13 @user_id = '374'
exec Q13 @user_id = '384'
exec Q13 @user_id = '394'
*/

*/

