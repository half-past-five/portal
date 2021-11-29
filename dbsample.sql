---------- DROP DB ----------

--tables
DECLARE @Sql NVARCHAR(500) DECLARE @Cursor CURSOR
SET @Cursor = CURSOR FAST_FORWARD FOR
SELECT DISTINCT sql = 'ALTER TABLE [' + tc2.TABLE_SCHEMA + '].[' +  tc2.TABLE_NAME + '] DROP [' + rc1.CONSTRAINT_NAME + '];'
FROM INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS rc1
LEFT JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc2 ON tc2.CONSTRAINT_NAME =rc1.CONSTRAINT_NAME
OPEN @Cursor FETCH NEXT FROM @Cursor INTO @Sql
WHILE (@@FETCH_STATUS = 0)
BEGIN
Exec sp_executesql @Sql
FETCH NEXT FROM @Cursor INTO @Sql
END
CLOSE @Cursor DEALLOCATE @Cursor
GO
EXEC sp_MSforeachtable 'DROP TABLE ?'
GO

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



----------CREATE TABLES----------


CREATE TABLE dbo.[T1-Question Questionnaire Pairs] (
	[Question ID] int not null,
	[Questionnaire ID] int not null,
	UNIQUE([Question ID], [Questionnaire ID])
	)


CREATE TABLE dbo.[T1-User] (
	[User ID] int IDENTITY(1,1) not null, --IDENTITY added 
	[Name] varchar(30) not null,
	[Birth Date] date not null,
	Sex char(1) not null,
	Position varchar(30) not null,
	Username varchar(30) not null,
	[Password] varchar(30) not null,
	Privilages int not null,
	[Company ID] int,
	[Manager ID] int,
	UNIQUE(Username),
	CONSTRAINT [PK-User] PRIMARY KEY NONCLUSTERED ([User ID]),
	CHECK ([Privilages] in ('1', '2', '3'))
)


CREATE TABLE [dbo].[T1-Company](
	[Registration Number] int not null, --NOT SPECIFIED BY US
	[Brand Name] varchar(50) not null,
	[Induction Date] date not null,
	CONSTRAINT [PK-Company] PRIMARY KEY NONCLUSTERED ([Registration Number])
	)


CREATE TABLE dbo.[T1-Question] (
	[Question ID] int IDENTITY(1,1) not null,
	[Creator ID] int,
	[Type] varchar(30),
	[Description] varchar(50) not null,
	[Text] varchar(100) not null,
	CONSTRAINT [PK-Question] PRIMARY KEY NONCLUSTERED ([Question ID]),
	CHECK ([Type] in ('Free Text','Multiple Choice','Arithmetic'))
)
	

CREATE TABLE dbo.[T1-Free Text Question] (
	[Question ID] int not null,
	[Restriction] varchar(30)
	UNIQUE([Question ID])
)	


CREATE TABLE dbo.[T1-Multiple Choice Question] (
	[Question ID] int not null,
	[Selectable Amount] int not null
	UNIQUE([Question ID])
)

CREATE TABLE dbo.[T1-Multiple Choice Answers] (
	[Question ID] int,
	[Answer] varchar(50)
	UNIQUE([Question ID], [Answer])
	)
	

CREATE TABLE dbo.[T1-Arithmetic Question] (
	[Question ID] int not null,
	[MIN value] int not null, 
	[MAX value] int not null, --min & max value added for range	
	CHECK ([MAX value] > [MIN value])
)



CREATE TABLE [dbo].[T1-Questionnaire](
	[Questionnaire ID] int IDENTITY(1,1) not null,
	[Title] varchar(20) not null,
	[Version] int not null,
	[Parent ID] int,
	[Creator ID] int,
	[URL] nvarchar(2083),
	UNIQUE (Title, [Version]),
	CONSTRAINT [PK-Questionnaire] PRIMARY KEY NONCLUSTERED ([Questionnaire ID])
	)
	

CREATE TABLE [dbo].[T1-Log](
	[Event]	varchar(100) not null,
	)

---------- INSERTS ----------
--COMPANY DATA
INSERT INTO [T1-Company] ([Registration Number], [Brand Name], [Induction Date]) VALUES ('1', 'Company 1', '2020/11/10')
INSERT INTO [T1-Company] ([Registration Number], [Brand Name], [Induction Date]) VALUES ('2', 'Company 2', '2020/11/10')
INSERT INTO [T1-Company] ([Registration Number], [Brand Name], [Induction Date]) VALUES ('3', 'Company 3', '2020/11/10')


--USER data
INSERT INTO [T1-User] ([Name], [Birth Date], [Sex], [Position], [Username], [Password], [Privilages], [Company ID], [Manager ID]) VALUES ('Manager 1', '2000/6/26', 'M', 'Development', 'manager1', 'hohoho', '2', '1', NULL)
INSERT INTO [T1-User] ([Name], [Birth Date], [Sex], [Position], [Username], [Password], [Privilages], [Company ID], [Manager ID]) VALUES ('Manager 2', '2000/6/26', 'M', 'Development', 'manager2', 'hohoho', '2', '2', NULL)
INSERT INTO [T1-User] ([Name], [Birth Date], [Sex], [Position], [Username], [Password], [Privilages], [Company ID], [Manager ID]) VALUES ('Manager 3', '2000/6/26', 'M', 'Development', 'manager3', 'hohoho', '2', '3', NULL)
INSERT INTO [T1-User] ([Name], [Birth Date], [Sex], [Position], [Username], [Password], [Privilages], [Company ID], [Manager ID]) VALUES ('User 1', '2000/6/26', 'M', 'Marketing', 'user1', 'hohoho', '3', 1, '1')
INSERT INTO [T1-User] ([Name], [Birth Date], [Sex], [Position], [Username], [Password], [Privilages], [Company ID], [Manager ID]) VALUES ('User 2', '2000/6/26', 'M', 'Marketing', 'user2', 'hohoho', '3', 2, '2')
INSERT INTO [T1-User] ([Name], [Birth Date], [Sex], [Position], [Username], [Password], [Privilages], [Company ID], [Manager ID]) VALUES ('User 3', '2000/6/26', 'M', 'Marketing', 'user3', 'hohoho', '3', 3, '3')

--QUESTIONNAIRE data

INSERT INTO [dbo].[T1-Questionnaire]([Title],[Version],[Parent ID],[Creator ID],[URL])VALUES('Qnnaire 1',1,NULL,1,'https://www.qnnaire1.com')	
INSERT INTO [dbo].[T1-Questionnaire]([Title],[Version],[Parent ID],[Creator ID],[URL])VALUES('Qnnaire 2',1,NULL,2,'https://www.qnnaire2.com')	
INSERT INTO [dbo].[T1-Questionnaire]([Title],[Version],[Parent ID],[Creator ID],[URL])VALUES('Qnnaire 3',1,NULL,3,'https://www.qnnaire3.com')

INSERT INTO [dbo].[T1-Questionnaire]([Title],[Version],[Parent ID],[Creator ID],[URL])VALUES('Qnnaire 1-1',2,1,4,'https://www.qnnaire1-1.com')	
INSERT INTO [dbo].[T1-Questionnaire]([Title],[Version],[Parent ID],[Creator ID],[URL])VALUES('Qnnaire 2-1',2,2,5,'https://www.qnnaire2-1.com')	
INSERT INTO [dbo].[T1-Questionnaire]([Title],[Version],[Parent ID],[Creator ID],[URL])VALUES('Qnnaire 3-1',2,3,6,'https://www.qnnaire3-1.com')	

INSERT INTO [dbo].[T1-Questionnaire]([Title],[Version],[Parent ID],[Creator ID],[URL])VALUES('Qnnaire 1-1-1',3,4,1,'https://www.qnnaire1-1-1.com')	
INSERT INTO [dbo].[T1-Questionnaire]([Title],[Version],[Parent ID],[Creator ID],[URL])VALUES('Qnnaire 1-1-2',3,4,4,'https://www.qnnaire1-1-2.com')		
INSERT INTO [dbo].[T1-Questionnaire]([Title],[Version],[Parent ID],[Creator ID],[URL])VALUES('Qnnaire 2-1-1',3,5,2,'https://www.qnnaire2-1-1.com')	


INSERT INTO [dbo].[T1-Questionnaire]([Title],[Version],[Parent ID],[Creator ID],[URL])VALUES('Qnnaire 1-1-1',4,4,4,NULL)
INSERT INTO [dbo].[T1-Questionnaire]([Title],[Version],[Parent ID],[Creator ID],[URL])VALUES('Qnnaire 2-1-1',4,5,5,NULL)
INSERT INTO [dbo].[T1-Questionnaire]([Title],[Version],[Parent ID],[Creator ID],[URL])VALUES('Qnnaire 3-1-1',4,6,5,NULL)
--QUESTION data

INSERT INTO	[T1-Question] ([Creator ID], [Type], [Description], [Text]) VALUES ('1', 'Free Text', 'I am question 1', 'Text cell')
INSERT INTO	[T1-Question] ([Creator ID], [Type], [Description], [Text]) VALUES ('2', 'Free Text', 'I am question 2', 'Text cell')
INSERT INTO	[T1-Question] ([Creator ID], [Type], [Description], [Text]) VALUES ('3', 'Free Text', 'I am question 3', 'Text cell')
INSERT INTO	[T1-Question] ([Creator ID], [Type], [Description], [Text]) VALUES ('4', 'Free Text', 'I am question 4', 'Text cell')
INSERT INTO	[T1-Question] ([Creator ID], [Type], [Description], [Text]) VALUES ('5', 'Free Text', 'I am question 5', 'Text cell')
INSERT INTO	[T1-Question] ([Creator ID], [Type], [Description], [Text]) VALUES ('6', 'Free Text', 'I am question 6', 'Text cell')
INSERT INTO	[T1-Question] ([Creator ID], [Type], [Description], [Text]) VALUES ('1', 'Free Text', 'I am question 7', 'Text cell')
INSERT INTO	[T1-Question] ([Creator ID], [Type], [Description], [Text]) VALUES ('1', 'Free Text', 'I am question 8', 'Text cell')
INSERT INTO	[T1-Question] ([Creator ID], [Type], [Description], [Text]) VALUES ('2', 'Free Text', 'I am question 9', 'Text cell')


--QQP data

--Company 1 related
INSERT INTO [dbo].[T1-Question Questionnaire Pairs]([Question ID],[Questionnaire ID])VALUES(1,1)
INSERT INTO [dbo].[T1-Question Questionnaire Pairs]([Question ID],[Questionnaire ID])VALUES(4,1)
INSERT INTO [dbo].[T1-Question Questionnaire Pairs]([Question ID],[Questionnaire ID])VALUES(1,4)
INSERT INTO [dbo].[T1-Question Questionnaire Pairs]([Question ID],[Questionnaire ID])VALUES(4,4)
INSERT INTO [dbo].[T1-Question Questionnaire Pairs]([Question ID],[Questionnaire ID])VALUES(7,4)
INSERT INTO [dbo].[T1-Question Questionnaire Pairs]([Question ID],[Questionnaire ID])VALUES(1,7)
INSERT INTO [dbo].[T1-Question Questionnaire Pairs]([Question ID],[Questionnaire ID])VALUES(4,7)
INSERT INTO [dbo].[T1-Question Questionnaire Pairs]([Question ID],[Questionnaire ID])VALUES(7,7)
INSERT INTO [dbo].[T1-Question Questionnaire Pairs]([Question ID],[Questionnaire ID])VALUES(8,7)
INSERT INTO [dbo].[T1-Question Questionnaire Pairs]([Question ID],[Questionnaire ID])VALUES(1,8)
INSERT INTO [dbo].[T1-Question Questionnaire Pairs]([Question ID],[Questionnaire ID])VALUES(4,8)
INSERT INTO [dbo].[T1-Question Questionnaire Pairs]([Question ID],[Questionnaire ID])VALUES(7,8)
INSERT INTO [dbo].[T1-Question Questionnaire Pairs]([Question ID],[Questionnaire ID])VALUES(8,8)

																							 
--Company 2 related                                                                          
INSERT INTO [dbo].[T1-Question Questionnaire Pairs]([Question ID],[Questionnaire ID])VALUES(2,2)
INSERT INTO [dbo].[T1-Question Questionnaire Pairs]([Question ID],[Questionnaire ID])VALUES(2,5)
INSERT INTO [dbo].[T1-Question Questionnaire Pairs]([Question ID],[Questionnaire ID])VALUES(5,5)
INSERT INTO [dbo].[T1-Question Questionnaire Pairs]([Question ID],[Questionnaire ID])VALUES(2,9)
INSERT INTO [dbo].[T1-Question Questionnaire Pairs]([Question ID],[Questionnaire ID])VALUES(5,9)
INSERT INTO [dbo].[T1-Question Questionnaire Pairs]([Question ID],[Questionnaire ID])VALUES(9,9)
																							 
--Company 3 related                                                                          
INSERT INTO [dbo].[T1-Question Questionnaire Pairs]([Question ID],[Questionnaire ID])VALUES(3,3)
INSERT INTO [dbo].[T1-Question Questionnaire Pairs]([Question ID],[Questionnaire ID])VALUES(3,6)
INSERT INTO [dbo].[T1-Question Questionnaire Pairs]([Question ID],[Questionnaire ID])VALUES(6,6)
																							
--NOT COMPLETED (URL = NULL) qqp                                                            
INSERT INTO [dbo].[T1-Question Questionnaire Pairs]([Question ID],[Questionnaire ID])VALUES(1,10)
INSERT INTO [dbo].[T1-Question Questionnaire Pairs]([Question ID],[Questionnaire ID])VALUES(2,11)
INSERT INTO [dbo].[T1-Question Questionnaire Pairs]([Question ID],[Questionnaire ID])VALUES(3,12)


--FOREIGN KEYS 
ALTER TABLE dbo.[T1-User] WITH NOCHECK ADD
CONSTRAINT [FK-User-Manager] FOREIGN KEY ([Manager ID]) REFERENCES [T1-User]([User ID]), --TRIGGER
CONSTRAINT [FK-User-Company] FOREIGN KEY ([Company ID]) REFERENCES [dbo].[T1-Company]([Registration Number]) ON UPDATE CASCADE ON DELETE CASCADE

ALTER TABLE dbo.[T1-Question] ADD
CONSTRAINT [FK-Question-CreatorUser] FOREIGN KEY ([Creator ID]) REFERENCES [dbo].[T1-User]([User ID]) ON UPDATE CASCADE ON DELETE SET NULL

ALTER TABLE dbo.[T1-Free Text Question] ADD
CONSTRAINT [FK-Free Text-Mai n Question] FOREIGN KEY ([Question ID]) REFERENCES [dbo].[T1-Question]([Question ID]) ON UPDATE CASCADE ON DELETE CASCADE

ALTER TABLE dbo.[T1-Multiple Choice Question] ADD
CONSTRAINT [FK-Multiple Choice-Main Question] FOREIGN KEY ([Question ID]) REFERENCES [dbo].[T1-Question]([Question ID]) ON UPDATE CASCADE ON DELETE CASCADE

ALTER TABLE dbo.[T1-Multiple Choice Answers] ADD
CONSTRAINT [FK-Multiple Choice-Answers] FOREIGN KEY ([Question ID]) REFERENCES [dbo].[T1-Question]([Question ID]) ON UPDATE CASCADE ON DELETE CASCADE

ALTER TABLE dbo.[T1-Arithmetic Question] ADD
CONSTRAINT [FK-Arithmetic-Main Question] FOREIGN KEY ([Question ID]) REFERENCES [dbo].[T1-Question]([Question ID]) ON UPDATE CASCADE ON DELETE CASCADE

ALTER TABLE [dbo].[T1-Questionnaire] ADD
CONSTRAINT [FK-Questionnaire-ParentQuestionnaire] FOREIGN KEY ([Parent ID]) REFERENCES [dbo].[T1-Questionnaire]([Questionnaire ID]), --TRIGGER REJECT
CONSTRAINT [FK-Questionnaire-CreatorUser] FOREIGN KEY ([Creator ID]) REFERENCES [dbo].[T1-User]([User ID]) ON UPDATE CASCADE ON DELETE SET NULL

ALTER TABLE dbo.[T1-Question Questionnaire Pairs] ADD
CONSTRAINT [FK-Question-ID] FOREIGN KEY ([Question ID]) REFERENCES [dbo].[T1-Question]([Question ID]) ON UPDATE CASCADE ON DELETE CASCADE,
CONSTRAINT [FK-Questionnaire-ID] FOREIGN KEY ([Questionnaire ID]) REFERENCES [dbo].[T1-Questionnaire]([Questionnaire ID])--TRIGGER


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


--QUERY 1--
GO
CREATE PROCEDURE dbo.Q1 @name varchar(50), @bday date, @sex char(1), 
@position varchar(30), @username varchar(30), @password varchar(30), @manager_id int, 
@company_reg_num int, @company_brand_name varchar(50)
AS
ALTER TABLE [T1-User] NOCHECK CONSTRAINT ALL;
ALTER TABLE [T1-Company] NOCHECK CONSTRAINT ALL;
INSERT INTO [T1-Company] ([Registration Number], [Brand Name], [Induction Date]) VALUES (@company_reg_num, @company_brand_name, CAST( GETDATE() AS Date ))
INSERT INTO [T1-User] ([Name], [Birth Date], [Sex], [Position], [Username], [Password], [Privilages], [Company ID], [Manager ID]) VALUES (@name, @bday, @sex, @position, @username, @password,'2', @company_reg_num, @manager_id)
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
IF (SELECT dbo.canUserSeeQuestionnaire(@caller_id, @questionnaire_id)) = 0 RETURN
SELECT *
FROM [T1-Question Questionnaire Pairs] qqp, [T1-Question] q
WHERE qqp.[Questionnaire ID] = @questionnaire_id AND qqp.[Question ID] = q.[Question ID]

--exec Q6b @caller_id='3', @questionnaire_id='1'


--QUERY 6c (ADD QUESTION TO QUESTIONNAIRE)--
GO
CREATE PROCEDURE dbo.Q6c @caller_id int, @questionnaire_id int, @question_id int
AS
IF (SELECT dbo.canUserSeeQuestion(@caller_id, @question_id)) = 0 RETURN --user has access to question
IF (SELECT dbo.canUserSeeQuestionnaire(@caller_id, @questionnaire_id)) = 0 RETURN --user has access to questionnaire
UPDATE [T1-Questionnaire] SET [URL] = NULL
INSERT INTO [T1-Question Questionnaire Pairs]([Question ID], [Questionnaire ID]) VALUES (@questionnaire_id, @question_id)
UPDATE [T1-Questionnaire] SET [URL] = dbo.generateURL(@questionnaire_id) WHERE [Questionnaire ID] = @questionnaire_id


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

--QUERY 6f (CLONE)--
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

DECLARE @maxNoOfQuestionnaires 	 int;
SET @maxNoOfQuestionnaires = (SELECT MAX(QuestionnaireCount.noOfQuestionnaires)	
								FROM  (	SELECT  QQP.[Question ID], COUNT(QQP.[Question ID]) as noOfQuestionnaires
										FROM  [T1-Question Questionnaire Pairs] QQP, [T1-Questionnaire] Qnnaire, [T1-User] U, [T1-Company] C
										WHERE QQP.[Questionnaire ID] = Qnnaire.[Questionnaire ID] AND Qnnaire.[URL] <> 'NULL' AND Qnnaire.[Creator ID] = U.[User ID] AND U.[Company ID] = C.[Registration Number] AND Qnnaire.[Creator ID] in (
												SELECT [User ID]
												FROM [T1-User] u
												WHERE u.[Company ID] = (
												SELECT [Company ID] FROM [T1-User] WHERE [User ID] =  @user_id
												)
												)
										GROUP BY QQP.[Question ID]
										) as QuestionnaireCount
										)
print @maxNoOfQuestionnaires 	

SELECT *
FROM  (	SELECT  QQP.[Question ID], COUNT(QQP.[Question ID]) as noOfAppearances
		FROM  [T1-Question Questionnaire Pairs] QQP, [T1-Questionnaire] Qnnaire, [T1-User] U, [T1-Company] C
		WHERE QQP.[Questionnaire ID] = Qnnaire.[Questionnaire ID] AND Qnnaire.[URL] <> 'NULL' AND Qnnaire.[Creator ID] = U.[User ID] AND U.[Company ID] = C.[Registration Number] AND Qnnaire.[Creator ID] in (
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
	WHERE QpQ.[Questionnaire ID] =	Qnnaire.[Questionnaire ID] AND Qnnaire.[Creator ID] = U.[User ID] AND U.[Company ID] = C.[Registration Number] AND Qnnaire.[Creator ID] in (
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



--Query 12 
GO
CREATE PROCEDURE dbo.Q12 @user_id int
AS
DECLARE @minNoOfQuestions int;
SET @minNoOfQuestions  = (SELECT MIN(QpQ.noOfQuestions) 
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


SELECT *
FROM (	SELECT   Qnnaire.[Questionnaire ID],Qnnaire.Title, Qnnaire.Version, QPQ.noOfQuestions
		FROM [Questions per Questionnaire] QpQ, [T1-Questionnaire] Qnnaire 
		WHERE QpQ.[Questionnaire ID] =	Qnnaire.[Questionnaire ID] AND Qnnaire.[Creator ID] IN (
				SELECT [User ID]
				FROM [T1-User] U
				WHERE U.[Company ID] = (SELECT [Company ID] FROM [T1-User] WHERE [User ID] = 1 )
				)
				)as CompanyQuestionnaires
WHERE NOT EXISTS(
		--All questions of questionaire
		(SELECT QQP1.[Question ID]
		FROM [T1-Question Questionnaire Pairs] QQP1
		WHERE QQP1.[Questionnaire ID] =  CompanyQuestionnaires.[Questionnaire ID]
		)
		EXCEPT
		--Questions of current questionaire
		(SELECT QQP2.[Question ID]
		FROM [T1-Question Questionnaire Pairs] QQP2
		WHERE QQP2.[Questionnaire ID] = CompanyQuestionnaires.[Questionnaire ID]
		) ) 
		


	SELECT DISTINCT	Qnnaire1.[Questionnaire ID] AS '1st Qnnaire ID',Qnnaire1.Title AS '1st Qnnaire Title',Qnnaire1.Version AS '1st Qnnaire Version',QpQ1.noOfQuestions AS '1st Qnnaire noOfQuestions',
			Qnnaire2.[Questionnaire ID] AS '2nd Qnnaire ID',Qnnaire2.Title AS '2nd Qnnaire Title',Qnnaire2.Version AS '2nd Qnnaire Version',QpQ2.noOfQuestions AS '2nd Qnnaire noOfQuestions'
	FROM [T1-Questionnaire] Qnnaire1,[T1-Questionnaire] Qnnaire2,[Questions per Questionnaire] QpQ1,[Questions per Questionnaire] QpQ2
	WHERE NOT EXISTS(
		--All questions of questionaire
		(SELECT QQP1.[Question ID]
		FROM [T1-Question Questionnaire Pairs] QQP1
		WHERE QQP1.[Questionnaire ID] = Qnnaire1.[Questionnaire ID]
		)
		EXCEPT
		--Questions of current questionaire
		(SELECT QQP2.[Question ID]
		FROM [T1-Question Questionnaire Pairs] QQP2
		WHERE QQP2.[Questionnaire ID] = Qnnaire2.[Questionnaire ID]
		) ) 
		AND QpQ1.[Questionnaire ID] = Qnnaire1.[Questionnaire ID] 
		AND QpQ2.[Questionnaire ID] = Qnnaire2.[Questionnaire ID] 
		AND QpQ1.noOfQuestions = QpQ2.noOfQuestions
		AND QpQ1.[Questionnaire ID] <> QpQ2.[Questionnaire ID]

--QUERY 14--
GO
CREATE PROCEDURE dbo.Q14 @qn_id int
AS
SELECT *
FROM [T1-Questionnaire] Qn
WHERE  NOT EXISTS
(
	--All questions of questionaire
	(SELECT QQP1.[Question ID]
	FROM [T1-Question Questionnaire Pairs] QQP1
	WHERE QQP1.[Questionnaire ID] = @qn_id
	)
	EXCEPT
	--Questions of current questionaire
	(SELECT QQP2.[Question ID]
	FROM [T1-Question Questionnaire Pairs] QQP2
	WHERE QQP2.[Questionnaire ID] = Qn.[Questionnaire ID]
	)
) AND Qn.URL <> 'NULL'


--QUERY 15--

GO
CREATE PROCEDURE dbo.Q15 @user_id int, @k_min int 
AS

/*
DECLARE @k_min int
SET @k_min = 1
DECLARE @user_id int
SET @user_id = 1
*/

SELECT Q.[Question ID]
FROM [T1-Question] Q,(	SELECT TOP (@k_min) QQP.[Question ID], COUNT(*) AS q_COUNT
						FROM [T1-Question Questionnaire Pairs] QQP, [T1-Questionnaire] Qnnaire
						WHERE QQP.[Questionnaire ID] =	Qnnaire.[Questionnaire ID] AND Qnnaire.[Creator ID] IN (
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
CREATE PROCEDURE dbo.Q16
AS

DECLARE @user_id int
SET @user_id = 1

DECLARE @cnt int

set @cnt = (SELECT COUNT([Questionnaire ID])
FROM [T1-Questionnaire] 
WHERE [Creator ID] in (
	SELECT [User ID]
	FROM [T1-User] u
	WHERE u.[Company ID] = (
		SELECT [Company ID] FROM [T1-User] WHERE [User ID] = @user_id
		)
	)
	)


print @cnt


SELECT Qnnaire.[Questionnaire ID]
FROM [T1-Questionnaire] Qnnaire, [Questions per Questionnaire] QpQ
WHERE Qnnaire.[Questionnaire ID] = QpQ.[Questionnaire ID] AND QpQ.noOfQuestions = @cnt AND Qnnaire.[Creator ID] in
				(	SELECT [User ID]
					FROM [T1-User] u
					WHERE u.[Company ID] = (
						SELECT [Company ID] FROM [T1-User] WHERE [User ID] = @user_id
						)
						)
	
/*
SELECT *
FROM (SELECT  QQP.[Question ID], COUNT(QQP.[Question ID]) as noOfQuestionnaires
FROM  [T1-Question Questionnaire Pairs] QQP, [T1-Questionnaire] Qnnaire, [T1-User] U, [T1-Company] C
WHERE QQP.[Questionnaire ID] = Qnnaire.[Questionnaire ID] AND Qnnaire.[URL] <> 'NULL' AND Qnnaire.[Creator ID] = U.[User ID] AND U.[Company ID] = C.[Registration Number] AND Qnnaire.[Creator ID] in (
			SELECT [User ID]
			FROM [T1-User] u
			WHERE u.[Company ID] = (
			SELECT [Company ID] FROM [T1-User] WHERE [User ID] =  @user_id
			)
			)
			GROUP BY QQP.[Question ID]) as QuestionnaireCount
WHERE QuestionnaireCount.noOfAppearances = @maxNoOfQuestionnaires 	
			
			*/






SELECT *
FROM [T1-Question] Q
WHERE NOT EXISTS
(
	--All Questionnaire ids
	(SELECT Qn.[Questionnaire ID]
	FROM [T1-Questionnaire] Qn
	)
	EXCEPT
	--All Questionnaire id of current question
	(SELECT QQP.[Questionnaire ID]
	FROM [T1-Question Questionnaire Pairs] QQP
	WHERE QQP.[Question ID] = Q.[Question ID]
	)
)

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

exec Q7 @user_id = '1'
/*

@description varchar(50), @text varchar(100), @free_text_restriction varchar(30), @mult_choice_selectable_amount int,
@mult_choice_answers varchar(1000), @arithm_min int, @arithm_max int

*/


--BRANCH TESTING