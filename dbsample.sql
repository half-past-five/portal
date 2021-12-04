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

--LOG--
GO
CREATE PROCEDURE dbo.[Log] @event varchar(100)
AS
INSERT INTO [T1-Log]([Event]) VALUES (CAST( GETDATE() AS varchar ) + @event)


--SEE QUESTIONNAIRE LOG--
GO
CREATE PROCEDURE dbo.[ShowQuestionnaireLog] @caller_id int, @user_id int, @questionnaire_id int
AS
IF (SELECT Privilages FROM [T1-User] WHERE [User ID] = @caller_id) <> 1 RETURN
IF @user_id <> '' AND @questionnaire_id <> '' BEGIN (SELECT * FROM [T1-Questionnaire Log] ql WHERE ql.[Questionnaire ID] = @questionnaire_id AND ql.[User ID] = @user_id) RETURN END
IF @user_id <> '' BEGIN (SELECT * FROM [T1-Questionnaire Log] ql WHERE ql.[User ID] = @user_id) RETURN END
IF @questionnaire_id <> '' BEGIN (SELECT * FROM [T1-Questionnaire Log] ql WHERE ql.[Questionnaire ID] = @questionnaire_id) RETURN END
SELECT * FROM [T1-Questionnaire Log] 


--QUERY AUTHENTICATE--
GO
CREATE PROCEDURE dbo.Authenticate @username varchar(30), @password varchar(30)
AS
SELECT CONVERT(varchar, [User ID]) as [User ID], CONVERT(varchar, Privilages) as Privilages
FROM [T1-User]
WHERE Username = @username and [Password] = @password

DECLARE @log varchar(100) = '   '
SET @log = @log + 'Login attempt with username: ' + @username
EXEC [LOG] @log


--QUERY SHOW ALL TABLES
GO
CREATE PROCEDURE dbo.ShowTable @vTableName varchar(30)
AS
IF @vTableName = 'T1-Company'
BEGIN
EXECUTE
('
	SELECT
	CAST([Registration Number] AS varchar(30)) as [Registration Number],
	CAST([Brand Name] AS varchar(30)) as [Brand Name],
	CAST([Induction Date] AS varchar(30)) as [Induction Date]
	FROM [T1-Company]
')
END

IF @vTableName = 'T1-User'
BEGIN
EXECUTE
('
	SELECT
	CAST([User ID] AS varchar(30)) as [User ID],
	CAST([Name] AS varchar(30)) as [Name],
	CAST([IDCard] AS varchar(30)) as [IDCard],
	CAST([Birth Date] AS varchar(30)) as [Birth Date],
	CAST([Sex] AS varchar(30)) as [Sex],
	CAST([Position] AS varchar(30)) as [Position],
	CAST([Username] AS varchar(30)) as [Username],
	CAST([Password] AS varchar(30)) as [Password],
	CAST([Company ID]  AS varchar(30)) as [Company ID],
	CAST([Manager ID] AS varchar(30)) as [Manager ID]
	FROM [T1-User]
')
END

IF @vTableName = 'T1-Question'
BEGIN
EXECUTE
('
	SELECT 
	CAST([Question ID] AS varchar(30) as [Question ID]),
	CAST([Question Code] AS varchar(30) as [Question Code]),
	CAST([Creator ID] AS varchar(30) as [Creator ID]),
	CAST([Type] AS varchar(30) as [Type]),
	CAST([Description] AS varchar(30) as [Description]),
	CAST([Text] AS varchar(30) as [Text])
	FROM [T1-Question]
')
END

IF @vTableName = 'T1-Questionnaire'
BEGIN
EXECUTE
('
	SELECT 
	CAST([Questionnaire ID] AS varchar(30) as [Questionnaire ID]),
	CAST([Title] AS varchar(30) as [Title]),
	CAST([Version] AS varchar(30) as [Version]),
	CAST([Parent ID] AS varchar(30) as [Parent ID]),
	CAST([Creator ID] AS varchar(30) as [Creator ID]),
	CAST([URL] AS varchar(30) as [URL])
	FROM [T1-Questionnaire]
')
END

IF @vTableName = 'T1-Question Questionnaire Pairs'
BEGIN
EXECUTE
('
	SELECT 
	CAST([Question ID] AS varchar(30) as [Question ID]),
	CAST([Questionnaire ID] AS varchar(30) as [Questionnaire ID])
	FROM [T1-Question Questionnaire Pairs]
')
END


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

DECLARE @log varchar(100) = '   '
SET @log = @log + 'User ID ' + CONVERT(varchar, @caller_id) + ' executed query ShowQuestions' 
EXEC [LOG] @log


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

DECLARE @log varchar(100) = '   '
SET @log = @log + 'User ID ' + CONVERT(varchar, @caller_id) + '  executed query ShowQuestionDetails' 
EXEC [LOG] @log



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

DECLARE @log varchar(100) = '   '
SET @log = @log + 'User ID ' + CONVERT(varchar, @caller_id) + ' executed query ShowQuestionnaires' 
EXEC [LOG] @log



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

DECLARE @log varchar(100) = '   '
SET @log = @log + 'User ID ' + CONVERT(varchar, @caller_id) + ' executed query ShowQUsers' 
EXEC [LOG] @log



--INSERT ANSWER TO MULTIPLE CHOICE--
GO
CREATE PROCEDURE dbo.InsertAnswerMultChoice @caller_id int, @question_id int, @answer varchar(50)
AS
--observer cannot edit questions
IF (SELECT Privilages FROM [T1-User] WHERE [User ID] = @caller_id) = 1 RETURN 
--check if caller is correct
IF dbo.canUserSeeQuestion(@caller_id, @question_id) = 0 RETURN
--check if multiple choice
IF 'Multiple Choice' NOT IN (SELECT [Type] FROM [T1-Question] WHERE @question_id = [Question ID]) RETURN
INSERT INTO [T1-Multiple Choice Answers]([Question ID], [Answer]) VALUES (@question_id, @answer)

DECLARE @log varchar(100) = '   '
SET @log = @log + 'User ID ' + CONVERT(varchar, @caller_id) + ' executed query InsertAnswerMultChoice' 
EXEC [LOG] @log



--EDIT ANSWER TO MULTIPLE CHOICE--
GO
CREATE PROCEDURE dbo.EditAnswerMultChoice @caller_id int, @question_id int, @answer varchar(50), @new_answer varchar(50)
AS
--observer cannot edit questions
IF (SELECT Privilages FROM [T1-User] WHERE [User ID] = @caller_id) = 1 RETURN 
--check if caller is correct
IF dbo.canUserSeeQuestion(@caller_id, @question_id) = 0 RETURN
--check if multiple choice
IF 'Multiple Choice' NOT IN (SELECT [Type] FROM [T1-Question] WHERE @question_id = [Question ID]) RETURN
UPDATE [T1-Multiple Choice Answers] SET [Answer] = @new_answer WHERE @answer = [Answer] AND @question_id = [Question ID]

DECLARE @log varchar(100) = '   '
SET @log = @log + 'User ID ' + CONVERT(varchar, @caller_id) + ' executed query EditAnswerMultChoice' 
EXEC [LOG] @log



--REMOVE ANSWER FROM MULT CHOICE--
GO
CREATE PROCEDURE dbo.RemoveAnswerMultChoice @caller_id int, @question_id int, @answer varchar(50)
AS
--observer cannot edit questions
IF (SELECT Privilages FROM [T1-User] WHERE [User ID] = @caller_id) = 1 RETURN 
--check if caller is correct
IF dbo.canUserSeeQuestion(@caller_id, @question_id) = 0 RETURN
--check if multiple choice
IF 'Multiple Choice' NOT IN (SELECT [Type] FROM [T1-Question] WHERE @question_id = [Question ID]) RETURN
DELETE FROM [T1-Multiple Choice Answers] WHERE @answer = [Answer] AND @question_id = [Question ID]

DECLARE @log varchar(100) = '   '
SET @log = @log + 'User ID ' + CONVERT(varchar, @caller_id) + ' executed query RemoveAnswerMultChoice' 
EXEC [LOG] @log



--SHOW ALL ANSWERS OF MULT CHOICE
GO
CREATE PROCEDURE dbo.ShowAnswerMultChoice @caller_id int, @question_id int
AS
--check if caller is correct
IF dbo.canUserSeeQuestion(@caller_id, @question_id) = 0 RETURN
--check if multiple choice
IF 'Multiple Choice' NOT IN (SELECT [Type] FROM [T1-Question] WHERE @question_id = [Question ID]) RETURN
SELECT [Answer] FROM [T1-Multiple Choice Answers] WHERE @question_id = [Question ID]

DECLARE @log varchar(100) = '   '
SET @log = @log + 'User ID ' + CONVERT(varchar, @caller_id) + ' executed query ShowAnswerMultChoice' 
EXEC [LOG] @log


--QUERY 1--
GO
CREATE PROCEDURE dbo.Q1 @name varchar(50), @bday date, @sex char(1), 
@position varchar(30), @username varchar(30), @password varchar(30), @manager_id int, 
@company_reg_num int, @company_brand_name varchar(50), @IDCard int, @caller_id int
AS
--only observer can do
IF (SELECT Privilages FROM [T1-User] WHERE [User ID] = @caller_id) <> 1 RETURN 
ALTER TABLE [T1-User] NOCHECK CONSTRAINT ALL;
ALTER TABLE [T1-Company] NOCHECK CONSTRAINT ALL;
INSERT INTO [T1-Company] ([Registration Number], [Brand Name], [Induction Date]) VALUES (@company_reg_num, @company_brand_name, CAST( GETDATE() AS Date ))
INSERT INTO [T1-User] ([Name], [Birth Date], [Sex], [Position], [Username], [Password], [Privilages], [Company ID], [Manager ID], [IDCard]) VALUES (@name, @bday, @sex, @position, @username, @password,'2', @company_reg_num, @manager_id, @IDCard)
ALTER TABLE [T1-User] CHECK CONSTRAINT ALL
ALTER TABLE [T1-Company] CHECK CONSTRAINT ALL

DECLARE @log varchar(100) = '   '
SET @log = @log + 'An observer added company with registration number ' +  CONVERT(varchar, @company_reg_num)
EXEC [LOG] @log

--QUERY 2a--
GO
CREATE PROCEDURE dbo.Q2a @action varchar(30), @company_id  varchar(30), @brand_name varchar(30), @new_date varchar(30), @caller_id int
AS
--only observer can do
IF (SELECT Privilages FROM [T1-User] WHERE [User ID] = @caller_id) <> 1 RETURN 
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

DECLARE @log varchar(100) = '   '
SET @log = @log + 'An observer edited company ' +  CONVERT(varchar, @brand_name)
EXEC [LOG] @log


--QUERY 2b--
GO
CREATE PROCEDURE dbo.Q2b @action varchar(30), @name varchar(50), @bday date, @sex char(1), 
@position varchar(30), @username varchar(30), @password varchar(30), @manager_id int, @company_id int, @IDCard int, @caller_id int
AS
--only observer can do
IF (SELECT Privilages FROM [T1-User] WHERE [User ID] = @caller_id) <> 1 RETURN 
IF  @action = 'insert'
	BEGIN
	INSERT INTO [T1-User] ([Name], [Birth Date], [Sex], [Position], [Username], [Password], [Privilages], [Company ID], [Manager ID], [IDCard]) VALUES (@name, @bday, @sex, @position, @username, @password,'2', @company_id, @manager_id, @IDCard)
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
	IF @IDCard <>'' BEGIN UPDATE [T1-User] SET [IDCard] = @IDCard WHERE Username = @username END
	END
IF  @action = 'show'
	BEGIN
	SELECT 
	CAST([Name] AS varchar(30)) as [Name],
	CAST([IDCard] AS varchar(30)) as [IDCard],
	CAST([Birth Date] AS varchar(30)) as [Birth Date],
	CAST([Sex] AS varchar(30)) as [Sex],
	CAST([Position] AS varchar(30)) as [Position],
	CAST([Password] AS varchar(30)) as [Password],
	CAST([Company ID]  AS varchar(30)) as [Company ID],
	CAST([Manager ID] AS varchar(30)) as [Manager ID]
	FROM [T1-User] U
	WHERE @username = U.Username
	END

DECLARE @log varchar(100) = '   '
SET @log = @log + 'An observer edited company admin with username  ' +  CONVERT(varchar, @username)
EXEC [LOG] @log


--QUERY 3--
GO
CREATE PROCEDURE dbo.Q3 @admin_id int, @idcard int, @name varchar(50), @bday date, @sex char(1), 
@position varchar(30), @username varchar(30), @password varchar(30), @manager_id int
AS
--only admin can do
IF (SELECT Privilages FROM [T1-User] WHERE [User ID] = @admin_id) <> 2 RETURN 
DECLARE @admin_company_id int
SELECT @admin_company_id = u.[Company ID]
FROM [T1-User] u
WHERE u.[User ID] = @admin_id 
INSERT INTO [T1-User] ([Name], [Birth Date], [Sex], [Position], [Username], [Password], [Privilages], [Company ID], [Manager ID], [IDCard]) VALUES (@name, @bday, @sex, @position, @username, @password,'3', @admin_company_id, @manager_id, @idcard)


DECLARE @log varchar(100) = '   '
SET @log = @log + 'Admin with ID ' + CONVERT(varchar, @admin_id) + 'added user with username ' + CONVERT(varchar, @username)
EXEC [LOG] @log


--QUERY 4--
GO
CREATE PROCEDURE dbo.Q4 @admin_id int, @idcard int, @action varchar(30), @name varchar(50), @bday date, @sex char(1), 
@position varchar(30), @username varchar(30), @password varchar(30), @manager_id int
AS
--only admin can do
IF (SELECT Privilages FROM [T1-User] WHERE [User ID] = @admin_id) <> 2 RETURN 
DECLARE @admin_company_id int
SELECT @admin_company_id = u.[Company ID]
FROM [T1-User] u
WHERE u.[User ID] = @admin_id 
IF  @action = 'insert'
	BEGIN
	INSERT INTO [T1-User] ([Name], [Birth Date], [Sex], [Position], [Username], [Password], [Privilages], [Company ID], [Manager ID], [IDCard]) VALUES (@name, @bday, @sex, @position, @username, @password,'3', @admin_company_id, @manager_id, @idcard)
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
	IF @idcard <> '' BEGIN UPDATE [T1-User] SET [IDCard] = @idcard WHERE Username = @username END
	END
IF  @action = 'show'
	BEGIN
	SELECT
	CAST([IDCard] AS varchar(30)) as [IDCard],
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


DECLARE @log varchar(100) = '   '
SET @log = @log + 'Admin with ID ' + CONVERT(varchar, @admin_id) + 'edit user with username ' + CONVERT(varchar, @username)
EXEC [LOG] @log

--QUERY 5--
GO
CREATE PROCEDURE dbo.Q5 @caller_id int, @action varchar(20), @question_id int, @code varchar(30), @type varchar(30),
@description varchar(50), @text varchar(100), @free_text_restriction varchar(30), @mult_choice_selectable_amount int,
@arithm_min int, @arithm_max int
AS
--observer cannot do
IF (SELECT Privilages FROM [T1-User] WHERE [User ID] = @caller_id) = 1 RETURN 
IF @action = 'insert'
	BEGIN
	INSERT INTO [T1-Question]([Creator ID], [Type], [Description], [Text], [Question Code]) VALUES(@caller_id, @type, @description, @text, @code)
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
	IF @code <>'' BEGIN UPDATE [T1-Question] SET [Question Code] = @code WHERE [Question ID] = @question_id END

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

DECLARE @log varchar(100) = '   '
SET @log = @log + 'User with ID ' + CONVERT(varchar, @caller_id) + 'edited question with id ' + CONVERT(varchar, @question_id)
EXEC [LOG] @log



--QUERY 6a (CREATE NEW)--
GO
CREATE PROCEDURE dbo.Q6a @caller_id int, @title varchar(30)
AS
--observer cannot do
IF (SELECT Privilages FROM [T1-User] WHERE [User ID] = @caller_id) = 1 RETURN 
INSERT INTO [T1-Questionnaire]([Title], [Version], [Parent ID], [Creator ID], [URL]) VALUES (@title, '1', NULL, @caller_id, NULL)

DECLARE @log varchar(100) = '   '
SET @log = @log + 'User with ID ' + CONVERT(varchar, @caller_id) + 'created new quesitonnaire '
EXEC [LOG] @log

INSERT INTO [T1-Questionnaire Log]([Event],[Questionnaire ID], [User ID]) VALUES ('Questionnaire added', SCOPE_IDENTITY(), @caller_id)



--QUERY 6b (SHOW QUESTIONS OF QUESTIONNAIRE)-- 
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

DECLARE @log varchar(100) = '   '
SET @log = @log + 'User with ID ' + CONVERT(varchar, @caller_id) + ' executed Show Questionnaires '
EXEC [LOG] @log

INSERT INTO [T1-Questionnaire Log]([Event],[Questionnaire ID], [User ID]) VALUES ('Questionnaire viewed', @questionnaire_id, @caller_id)


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
--observer cannot do
IF (SELECT Privilages FROM [T1-User] WHERE [User ID] = @caller_id) = 1 RETURN 
IF (SELECT [URL] FROM [T1-Questionnaire] q WHERE @questionnaire_id = q.[Questionnaire ID]) <> NULL RETURN 
IF (SELECT dbo.canUserSeeQuestion(@caller_id, @question_id)) = 0 RETURN --user has access to question
IF (SELECT dbo.canUserSeeQuestionnaire(@caller_id, @questionnaire_id)) = 0 RETURN --user has access to questionnaire
INSERT INTO [T1-Question Questionnaire Pairs]([Questionnaire ID], [Question ID]) VALUES (@questionnaire_id, @question_id)

DECLARE @log varchar(100) = '   '
SET @log = @log + 'User with ID ' + CONVERT(varchar, @caller_id) + 'added question with ID ' + CONVERT(varchar, @question_id) + 'to questuonnaire with ID ' + CONVERT(varchar, @questionnaire_id)
EXEC [LOG] @log

SET @log = 'Added question ' + CONVERT(varchar, @question_id) + ' to questionnaire'
INSERT INTO [T1-Questionnaire Log]([Event],[Questionnaire ID], [User ID]) VALUES (@log, @questionnaire_id, @caller_id)


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
--observer cannot do
IF (SELECT Privilages FROM [T1-User] WHERE [User ID] = @caller_id) = 1 RETURN 
IF (SELECT [URL] FROM [T1-Questionnaire] q WHERE @questionnaire_id = q.[Questionnaire ID]) <> NULL RETURN
IF (SELECT dbo.canUserSeeQuestion(@caller_id, @question_id)) = 0 RETURN --user has access to question
IF (SELECT dbo.canUserSeeQuestionnaire(@caller_id, @questionnaire_id)) = 0 RETURN --user has access to questionnaire
DELETE FROM [T1-Question Questionnaire Pairs] WHERE [Question ID] = @question_id AND [Questionnaire ID] = @questionnaire_id

DECLARE @log varchar(100) = '   '
SET @log = @log + 'User with ID ' + CONVERT(varchar, @caller_id) + 'removed question with ID ' + CONVERT(varchar, @question_id) + 'to questuonnaire with ID ' + CONVERT(varchar, @questionnaire_id)
EXEC [LOG] @log

SET @log = 'Removed question ' + CONVERT(varchar, @question_id) + ' from questionnaire'
INSERT INTO [T1-Questionnaire Log]([Event],[Questionnaire ID], [User ID]) VALUES (@log, @questionnaire_id, @caller_id)



--QUERY 6e (CHANGE QUERY STATE)--
GO
CREATE PROCEDURE dbo.Q6e @caller_id int, @questionnaire_id int
AS
--observer cannot do
IF (SELECT Privilages FROM [T1-User] WHERE [User ID] = @caller_id) = 1 RETURN 
IF (SELECT dbo.canUserSeeQuestionnaire(@caller_id, @questionnaire_id)) = 0 RETURN --user has access to questionnaire
IF (SELECT [URL] FROM [T1-Questionnaire] WHERE [Questionnaire ID] = @questionnaire_id) IS NULL
	BEGIN
	UPDATE [T1-Questionnaire] SET [URL] = dbo.generateURL(@questionnaire_id) WHERE [Questionnaire ID] = @questionnaire_id
	RETURN
	END
UPDATE [T1-Questionnaire] SET [URL] = NULL WHERE [Questionnaire ID] = @questionnaire_id

DECLARE @log varchar(100) = '   '
SET @log = @log + 'User with ID ' + CONVERT(varchar, @caller_id) + 'changed state of questuonnaire with ID ' + CONVERT(varchar, @questionnaire_id)
EXEC [LOG] @log

INSERT INTO [T1-Questionnaire Log]([Event],[Questionnaire ID], [User ID]) VALUES ('Changed state of questionnaire', @questionnaire_id, @caller_id)



--QUERY 6f (CLONE)--
GO
CREATE PROCEDURE dbo.Q6f @caller_id int, @questionnaire_id int
AS
--observer cannot do
IF (SELECT Privilages FROM [T1-User] WHERE [User ID] = @caller_id) = 1 RETURN 
IF (SELECT dbo.canUserSeeQuestionnaire(@caller_id, @questionnaire_id)) = 0 RETURN
IF (SELECT [URL] FROM [T1-Questionnaire] WHERE [Questionnaire ID] = @questionnaire_id) IS NULL RETURN --cannot be cloned because its not completed
DECLARE @title varchar(30)
SET @title = (SELECT [Title] q FROM [T1-Questionnaire] q WHERE [Questionnaire ID] = @questionnaire_id)
DECLARE @version int

SET @version = (SELECT MAX([Version]) FROM [T1-Questionnaire] q WHERE [Title] = (SELECT [Title] FROM [T1-Questionnaire] WHERE [Questionnaire ID] = @questionnaire_id))
SET @version = @version + 1
INSERT INTO [T1-Questionnaire]([Title], [Version], [Parent ID], [Creator ID], [URL]) VALUES (@title, @version, @questionnaire_id, @caller_id, NULL)
DECLARE @new_questionnaire_id int = SCOPE_IDENTITY()
DECLARE @temp TABLE(QID int)
INSERT INTO @temp SELECT [Question ID] FROM [T1-Question Questionnaire Pairs] qqp WHERE qqp.[Questionnaire ID] = @questionnaire_id
DECLARE @qid int
WHILE EXISTS(SELECT * FROM @temp)
BEGIN
	SET @qid = (SELECT TOP 1 QID FROM @temp)
	INSERT INTO [T1-Question Questionnaire Pairs]([Questionnaire ID], [Question ID]) VALUES (@new_questionnaire_id, @qid)
	DELETE TOP(1) FROM @temp 
END 

DECLARE @log varchar(100) = '   '
SET @log = @log + 'User with ID ' + CONVERT(varchar, @caller_id) + 'cloned questuonnaire with ID ' + CONVERT(varchar, @questionnaire_id)
EXEC [LOG] @log

INSERT INTO [T1-Questionnaire Log]([Event],[Questionnaire ID], [User ID]) VALUES ('Cloned questionnaire', @questionnaire_id, @caller_id)




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

DECLARE @log varchar(100) = '   '
SET @log = @log + 'User with ID ' + CONVERT(varchar, @user_id) + ' executed Q7'
EXEC [LOG] @log



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

DECLARE @log varchar(100) = '   '
SET @log = @log + 'User with ID ' + CONVERT(varchar, @user_id) + ' executed Q8'
EXEC [LOG] @log


--QUERY 9 
GO
CREATE PROCEDURE dbo.Q9
AS
SELECT Title, [Version], COUNT([Question ID]) as q_count
FROM [T1-Question Questionnaire Pairs] qqp,[T1-Questionnaire] q
WHERE
q.URL <> 'NULL' AND qqp.[Questionnaire ID] = q.[Questionnaire ID]

GROUP BY Title, [Version]

DECLARE @log varchar(100) = '   '
SET @log = @log + 'Q9 executed'
EXEC [LOG] @log


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

DECLARE @log varchar(100) = '   '
SET @log = @log + 'User with ID ' + CONVERT(varchar, @user_id) + ' executed Q10'
EXEC [LOG] @log
	

--Query 11 
GO
CREATE PROCEDURE dbo.Q11 @user_id int
AS

DECLARE @avgNoOfQuestions int;

SET @avgNoOfQuestions  = (SELECT AVG(QpQ.noOfQuestions) 
	FROM [Questions per Questionnaire] QpQ, [T1-Questionnaire] Qnnaire
	WHERE QpQ.[Questionnaire ID] =	Qnnaire.[Questionnaire ID] AND Qnnaire.[Creator ID] IN (
		SELECT [User ID]
		FROM [T1-User] U
		WHERE U.[Company ID] = (SELECT [Company ID] FROM [T1-User] WHERE [User ID] = @user_id )
					)
					)

--print @avgNoOfQuestions 	

SELECT  Qnnaire.Title, Qnnaire.Version, QPQ.noOfQuestions
FROM [Questions per Questionnaire] QpQ, [T1-Questionnaire] Qnnaire 
WHERE QpQ.[Questionnaire ID] =	Qnnaire.[Questionnaire ID] AND QpQ.noOfQuestions > @avgNoOfQuestions AND Qnnaire.[Creator ID] IN (
		SELECT [User ID]
		FROM [T1-User] U
		WHERE U.[Company ID] = (SELECT [Company ID] FROM [T1-User] WHERE [User ID] = @user_id )
		)

DECLARE @log varchar(100) = '   '
SET @log = @log + 'User with ID ' + CONVERT(varchar, @user_id) + ' executed Q11'
EXEC [LOG] @log



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

DECLARE @log varchar(100) = '   '
SET @log = @log + 'User with ID ' + CONVERT(varchar, @user_id) + ' executed Q12'
EXEC [LOG] @log


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

DECLARE @log varchar(100) = '   '
SET @log = @log + 'User with ID ' + CONVERT(varchar, @user_id) + ' executed Q13'
EXEC [LOG] @log
	

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

DECLARE @log varchar(100) = '   '
SET @log = @log + 'User with ID ' + CONVERT(varchar, @user_id) + ' executed Q14'
EXEC [LOG] @log


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

DECLARE @log varchar(100) = '   '
SET @log = @log + 'User with ID ' + CONVERT(varchar, @user_id) + ' executed Q15'
EXEC [LOG] @log



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
		WHERE QpQ.[Questionnaire ID] =	Qnnaire.[Questionnaire ID]   AND Qnnaire.URL <> 'NULL' AND Qnnaire.[Creator ID] IN (
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

DECLARE @log varchar(100) = '   '
SET @log = @log + 'User with ID ' + CONVERT(varchar, @user_id) + ' executed Q16'
EXEC [LOG] @log


--QUERY 17--
GO
CREATE PROCEDURE dbo.Q17 @user_id int, @qn_id int 
AS

;WITH Result AS(
        SELECT  *
        FROM	[T1-Questionnaire] Qnnaire
        WHERE   Qnnaire.[Questionnaire ID] = @qn_id 
        UNION ALL
        SELECT  Qnnaire.*
        FROM	[T1-Questionnaire] Qnnaire INNER JOIN Result ON Qnnaire.[Parent ID] = Result.[Questionnaire ID]
		--WHERE	Qnnaire.URL <> NULL
		)

SELECT [Questionnaire ID] AS 'IDs of children Questionnaires'
FROM Result
WHERE [Questionnaire ID] <> @qn_id

;WITH Result AS(
        SELECT  *
        FROM	[T1-Questionnaire] Qnnaire
        WHERE   Qnnaire.[Questionnaire ID] = @qn_id 
        UNION ALL
        SELECT  Qnnaire.*
        FROM	[T1-Questionnaire] Qnnaire INNER JOIN Result ON Qnnaire.[Parent ID] = Result.[Questionnaire ID]
		--WHERE	Qnnaire.URL <> NULL
		)

SELECT  SUM(QpQ.noOfQuestions) as 'Total Number of Questions'
FROM Result, [Questions per Questionnaire] QpQ
		WHERE QpQ.[Questionnaire ID] =	Result.[Questionnaire ID] AND Result.[Questionnaire ID] <> @qn_id  AND Result.[Creator ID] IN (
				SELECT [User ID]
				FROM [T1-User] U
				WHERE U.[Company ID] = (SELECT [Company ID] FROM [T1-User] WHERE [User ID] = @user_id )
				)

DECLARE @log varchar(100) = '   '
SET @log = @log + 'User with ID ' + CONVERT(varchar, @user_id) + ' executed Q17'
EXEC [LOG] @log


/*
---------- TESTING ----------

exec ShowTable @vTableName = 'T1-User'

exec Q1 @name='Konstantinos Larkos', @bday='2000/6/26', @sex='M', 
@position='Employee', @username='klarko03', @password='hihi', @manager_id=NULL, 
@company_reg_num ='988', @company_brand_name='Test Company', @IDCard = '988'

exec Q2a @action='insert', @company_id='985', @brand_name='Test 2a', @new_date = '2000/6/26'

exec Q2b @action='update', @name = 'KAS', @bday='2000/6/26', @sex='F', 
@position='Katotatos', @username='ckasou02', @password='hihi', @manager_id=NULL, @company_id = '1', @IDCard = '55556'

exec Q2b @action='show', @name = '', @bday='', @sex='', 
@position='', @username='ckasou01', @password='', @manager_id=NULL, @company_id = '', @IDCard = ''
select * from [T1-Log]
exec Q3 @admin_id='6',@idcard=11111111, @name='Kostis', @bday='2000/6/26', @sex='M', 
@position='Sales', @username='kost05', @password='hehehe', @manager_id='4'

exec Q4 @action='show', @idcard = 100000001, @admin_id='6', @name='Kosteassss', @bday='2000/6/26', @sex='F', 
@position='Sales', @username='kost05', @password='hehehe', @manager_id='4'

exec Q5 @caller_id=6, @action='update', @question_id=1, @code='CODE999', @type='Arithmetic',
@description='pejesi', @text='ekourastika?', @free_text_restriction=NULL, @mult_choice_selectable_amount=NULL,
@arithm_min=1, @arithm_max=1

select * from [T1-Question]

exec Q7 @user_id = '276' --sosto

exec Q8 @user_id = '276' --oi

exec Q9 --idios arithmos

exec Q10 @user_id = '276' --sosto

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

@description varchar(50), @text varchar(100), @free_text_restriction varchar(30), @mult_choice_selectable_amount int,
@mult_choice_answers varchar(1000), @arithm_min int, @arithm_max int


--Query 13 testing 

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
