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


----------CREATE TABLES----------


CREATE TABLE dbo.[T1-Question Questionnaire Pairs] (
	[Question ID] int not null,
	[Questionnaire ID] int not null,
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
)	


CREATE TABLE dbo.[T1-Multiple Choice Question] (
	[Question ID] int not null,
	[Selectable Amount] int not null
)

CREATE TABLE dbo.[T1-Multiple Choice Answers] (
	[Question ID] int,
	[Answer ID] int
	)

CREATE TABLE dbo.[T1-Answers](
	[Answer ID] int IDENTITY(1,1) not null,
	[Answer] varchar(50) not null,
	CONSTRAINT [PK-Answer] PRIMARY KEY NONCLUSTERED ([Answer ID]),
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
INSERT INTO [T1-User] ([Name], [Birth Date], [Sex], [Position], [Username], [Password], [Privilages], [Company ID], [Manager ID]) VALUES ('Loukas Papalazarou', '2000/6/26', 'M', 'Development', 'lpapal03', 'hehehe', '1', NULL, '2')
INSERT INTO [T1-User] ([Name], [Birth Date], [Sex], [Position], [Username], [Password], [Privilages], [Company ID], [Manager ID]) VALUES ('Kon Larkou', '1979/8/18', 'F', 'Marketing', 'klarko01', 'hihi', '1', NULL,  NULL)
INSERT INTO [T1-User] ([Name], [Birth Date], [Sex], [Position], [Username], [Password], [Privilages], [Company ID], [Manager ID]) VALUES ('Kasoul', '1979/8/18', 'F', 'Marketing', 'ckasou01', 'hoho', '2', '1', '4')
INSERT INTO [T1-User] ([Name], [Birth Date], [Sex], [Position], [Username], [Password], [Privilages], [Company ID], [Manager ID]) VALUES ('Manager', '1979/8/18', 'M', 'CEO', 'manag01', 'hoho', '3', '1', NULL)
INSERT INTO [T1-User] ([Name], [Birth Date], [Sex], [Position], [Username], [Password], [Privilages], [Company ID], [Manager ID]) VALUES ('Christos', '1979/8/18', 'M', 'Katouris', 'celeft01', 'hoho', '3', '1', '4')


INSERT INTO [T1-Company] ([Registration Number], [Brand Name], [Induction Date]) VALUES ('1', 'Company 1', '2020/11/10')
INSERT INTO [T1-Company] ([Registration Number], [Brand Name], [Induction Date]) VALUES ('2', 'Company 2', '2020/11/10')

INSERT INTO	[T1-Question] ([Creator ID], [Type], [Description], [Text]) VALUES ('1', 'Free Text', 'The first question', 'Do you like db?')
INSERT INTO [T1-Free Text Question] ([Question ID]) VALUES ('1')
INSERT INTO	[T1-Question] ([Creator ID], [Type], [Description], [Text]) VALUES ('1', 'Arithmetic', 'The second question', 'How much do you like db?')
INSERT INTO [T1-Arithmetic Question] ([Question ID], [MIN value], [MAX value]) VALUES ('1', '0', '10')

INSERT INTO	[T1-Question] ([Creator ID], [Type], [Description], [Text]) VALUES ('3', 'Free Text', 'The first question', '1?')
INSERT INTO	[T1-Question] ([Creator ID], [Type], [Description], [Text]) VALUES ('4', 'Free Text', 'The first question', '2??')
--DATA FOR QUESTIONNAIRE

INSERT INTO [dbo].[T1-Questionnaire]([Title],[Version],[Parent ID],[Creator ID],[URL])VALUES('Qnnaire 1',1,1,3,'https://www.qnnaire1.com')																			   
INSERT INTO [dbo].[T1-Questionnaire]([Title],[Version],[Parent ID],[Creator ID],[URL])VALUES('Qnnaire 2',1,2,3,'https://www.qnnaire2.com')																	   
INSERT INTO [dbo].[T1-Questionnaire]([Title],[Version],[Parent ID],[Creator ID],[URL])VALUES('Qnnaire 2-1',2,2,3,'https://www.qnnaire2-1.com')																	   
INSERT INTO [dbo].[T1-Questionnaire]([Title],[Version],[Parent ID],[Creator ID],[URL])VALUES('Qnnaire 2-2',3,2,4,NULL)																   
INSERT INTO [dbo].[T1-Questionnaire]([Title],[Version],[Parent ID],[Creator ID],[URL])VALUES('Qnnaire 1-1',2,1,4,'https://www.qnnaire1-1.com')																   
INSERT INTO [dbo].[T1-Questionnaire]([Title],[Version],[Parent ID],[Creator ID],[URL])VALUES('Qnnaire 1-2',3,1,4,NULL)


--DATA FOR QQP

INSERT INTO [dbo].[T1-Question Questionnaire Pairs]([Question ID],[Questionnaire ID])VALUES(1,1)
	 
INSERT INTO [dbo].[T1-Question Questionnaire Pairs]([Question ID],[Questionnaire ID])VALUES(1,1)
	 
INSERT INTO [dbo].[T1-Question Questionnaire Pairs]([Question ID],[Questionnaire ID])VALUES(1,1)
	 
INSERT INTO [dbo].[T1-Question Questionnaire Pairs]([Question ID],[Questionnaire ID])VALUES(1,2)
	 
INSERT INTO [dbo].[T1-Question Questionnaire Pairs]([Question ID],[Questionnaire ID])VALUES(1,2)
	 
INSERT INTO [dbo].[T1-Question Questionnaire Pairs]([Question ID],[Questionnaire ID])VALUES(1,2)
	 
INSERT INTO [dbo].[T1-Question Questionnaire Pairs]([Question ID],[Questionnaire ID])VALUES(2,3)
	 
INSERT INTO [dbo].[T1-Question Questionnaire Pairs]([Question ID],[Questionnaire ID])VALUES(2,3)
	 
INSERT INTO [dbo].[T1-Question Questionnaire Pairs]([Question ID],[Questionnaire ID])VALUES(2,4)
	 
INSERT INTO [dbo].[T1-Question Questionnaire Pairs]([Question ID],[Questionnaire ID])VALUES(2,4)
	 
INSERT INTO [dbo].[T1-Question Questionnaire Pairs]([Question ID],[Questionnaire ID])VALUES(2,5)
	 
INSERT INTO [dbo].[T1-Question Questionnaire Pairs]([Question ID],[Questionnaire ID])VALUES(2,5)



--FOREIGN KEYS 
ALTER TABLE dbo.[T1-User] WITH NOCHECK ADD
CONSTRAINT [FK-User-Manager] FOREIGN KEY ([Manager ID]) REFERENCES [T1-User]([User ID]),
CONSTRAINT [FK-User-Company] FOREIGN KEY ([Company ID]) REFERENCES [dbo].[T1-Company]([Registration Number]) ON UPDATE CASCADE ON DELETE CASCADE

ALTER TABLE dbo.[T1-Question] ADD
CONSTRAINT [FK-Question-CreatorUser] FOREIGN KEY ([Creator ID]) REFERENCES [dbo].[T1-User]([User ID]) ON UPDATE CASCADE ON DELETE SET NULL

ALTER TABLE dbo.[T1-Free Text Question] ADD
CONSTRAINT [FK-Free Text-Main Question] FOREIGN KEY ([Question ID]) REFERENCES [dbo].[T1-Question]([Question ID]) ON UPDATE CASCADE ON DELETE CASCADE

ALTER TABLE dbo.[T1-Multiple Choice Question] ADD
CONSTRAINT [FK-Multiple Choice-Main Question] FOREIGN KEY ([Question ID]) REFERENCES [dbo].[T1-Question]([Question ID]) ON UPDATE CASCADE ON DELETE CASCADE

ALTER TABLE dbo.[T1-Arithmetic Question] ADD
CONSTRAINT [FK-Arithmetic-Main Question] FOREIGN KEY ([Question ID]) REFERENCES [dbo].[T1-Question]([Question ID]) ON UPDATE CASCADE ON DELETE CASCADE

ALTER TABLE [dbo].[T1-Questionnaire] ADD
CONSTRAINT [FK-Questionnaire-ParentQuestionnaire] FOREIGN KEY ([Parent ID]) REFERENCES [dbo].[T1-Questionnaire]([Questionnaire ID]), --ask pankris
CONSTRAINT [FK-Questionnaire-CreatorUser] FOREIGN KEY ([Creator ID]) REFERENCES [dbo].[T1-User]([User ID]) ON UPDATE CASCADE ON DELETE SET NULL

ALTER TABLE dbo.[T1-Question Questionnaire Pairs] ADD
CONSTRAINT [FK-Question-ID] FOREIGN KEY ([Question ID]) REFERENCES [dbo].[T1-Question]([Question ID]) ON UPDATE CASCADE ON DELETE CASCADE,
CONSTRAINT [FK-Questionnaire-ID] FOREIGN KEY ([Questionnaire ID]) REFERENCES [dbo].[T1-Questionnaire]([Questionnaire ID])

---------- VIEWS ----------

--Questions per Questionnaire VIEW creation
GO
CREATE VIEW dbo.[Questions per Questionnaire] AS
SELECT  QQP.[Questionnaire ID], COUNT(QQP.[Questionnaire ID]) as noOfQuestions
FROM  [T1-Question Questionnaire Pairs] QQP, [T1-Questionnaire] Q
WHERE QQP.[Questionnaire ID] = Q.[Questionnaire ID] AND Q.[URL] <> NULL
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


--QUERY SHOW ALL QUESTIONNAIRES--
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
IF @action = 'update'
	BEGIN
	IF @question_id NOT IN (SELECT [Question ID] FROM [T1-Question Questionnaire Pairs])
		BEGIN
		print('do update')
		END
	END   
--QUESTION SHOULD NOT APPEAR IN QQ-PAIRS
/*
IF @action = 'update'
IF @action = 'delete'
*/


--QUERY 6a (CREATE NEW)--
GO
CREATE PROCEDURE dbo.Q6a @caller_id int, @title varchar(30)
AS
INSERT INTO [T1-Questionnaire]([Title], [Version], [Parent ID], [Creator ID], [URL]) VALUES (@title, '1', NULL, @caller_id, NULL) 


--QUERY 6b (ADD QUESTION TO QUESTIONNAIRE)--
GO
CREATE PROCEDURE dbo.Q6b @caller_id int, @questionnaire_id int, @question_id int
AS
IF (SELECT dbo.canUserSeeQuestion(@caller_id, @question_id)) = 0 RETURN --user has access to question
IF (SELECT dbo.canUserSeeQuestionnaire(@caller_id, @questionnaire_id)) = 0 RETURN --user has access to questionnaire
INSERT INTO [T1-Question Questionnaire Pairs]([Question ID], [Questionnaire ID]) VALUES (@questionnaire_id, @question_id)


--QUERY 6c (REMOVE QUESTION FROM QUESTIONNAIRE)--
GO
CREATE PROCEDURE dbo.Q6c @caller_id int, @questionnaire_id int, @question_id int
AS
IF (SELECT dbo.canUserSeeQuestion(@caller_id, @question_id)) = 0 RETURN --user has access to question
IF (SELECT dbo.canUserSeeQuestionnaire(@caller_id, @questionnaire_id)) = 0 RETURN --user has access to questionnaire
DELETE FROM [T1-Question Questionnaire Pairs] WHERE [Question ID] = @question_id AND [Questionnaire ID] = @questionnaire_id


--QUERY 7-- WORKS
GO
CREATE PROCEDURE dbo.Q7 @user_id varchar(30)
AS
--DECLARE @user_id varchar(30) --FOR TESTING
--set @user_id = '1'

SELECT Title, [Version], COUNT([Question ID]) as q_count
FROM  [T1-Questionnaire] q, [T1-User] u, [T1-Question Questionnaire Pairs] qqp
WHERE 
--cq.[Questionnaire ID] = q.[Questionnaire ID] AND
--qqp.[Questionnaire ID] = cq.[Questionnaire ID] AND

q.URL <> 'NULL' AND --To null thelei to me quotes
qqp.[Questionnaire ID] = q.[Questionnaire ID] AND
q.[Creator ID] = u.[User ID] AND
u.[User ID] = @user_id
GROUP BY Title, [Version]
ORDER BY q_count


--QUERY 8-- ***NEEDS FIX***
GO
CREATE PROCEDURE dbo.Q8 @user_id varchar(30)
AS

--DECLARE @user_id varchar(30) --FOR TESTING
--set @user_id = '1'

SELECT apps_table.[Question ID], q.[Text]
FROM [T1-Question] q,
	(
	SELECT [Question ID], COUNT(qqp.[Questionnaire ID]) as appearances
	FROM [T1-Question Questionnaire Pairs] qqp, [T1-Questionnaire] q, [T1-User] u
	WHERE
	
	--qqp.[Questionnaire ID] = cq.[Questionnaire ID] AND
	--q.[Questionnaire ID] = cq.[Questionnaire ID] AND

	qqp.[Questionnaire ID] = q.[Questionnaire ID] AND
	u.[Company ID] = (SELECT [Company ID] FROM [T1-User] WHERE [User ID] = @user_id)
	GROUP BY [Question ID]
	) apps_table
WHERE 
apps_table.appearances = (SELECT MAX(apps_table.appearances) FROM apps_table) AND
apps_table.[Question ID] = q.[Question ID]


--QUERY 9-- WORKS
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
CREATE PROCEDURE dbo.Q10
AS
SELECT C.[Brand Name],AVG(Result.noOFQuestionnaires) as avgNoOfQuestionnaires
FROM [T1-Question] Q, [T1-User] U, [T1-Company] C, [T1-Questionnaire] Qnnaire,
	(SELECT  QQP.[Questionnaire ID], COUNT(QQP.[Questionnaire ID]) as noOfQuestionnaires
	FROM  [T1-Question Questionnaire Pairs] QQP
	GROUP BY QQP.[Questionnaire ID]) Result
WHERE Q.[Creator ID] = U.[User ID] AND U.[Company ID] = C.[Registration Number] AND Qnnaire.[Creator ID] = U.[User ID] 
GROUP BY C.[Brand Name]	

--Query 10 with view WORKS

SELECT C.[Brand Name],AVG(QpQ.noOfQuestions) as [Average number Of Questionnaires]
FROM 
--[T1-Question] Q,
[T1-User] U, [T1-Company] C, [T1-Questionnaire] Qnnaire, [Questions per Questionnaire] QpQ
WHERE 
--Q.[Creator ID] = U.[User ID] AND 
U.[Company ID] = C.[Registration Number] AND Qnnaire.[Creator ID] = U.[User ID] 
GROUP BY C.[Brand Name]	

--Drop Constraints
--ALTER TABLE [dbo].[T1-Questionnaire] ADD
--CONSTRAINT [FK-Questionnaire-ParentQuestionnaire] FOREIGN KEY ([Parent ID]) REFERENCES [dbo].[T1-Questionnaire]([Questionnaire ID]), --ask pankris
--CONSTRAINT [FK-Questionnaire-CreatorUser] FOREIGN KEY ([Creator ID]) REFERENCES [dbo].[T1-User]([User ID]) ON UPDATE CASCADE ON DELETE SET NULL

--ALTER TABLE [dbo].[T1-Questionnaire]
--DROP CONSTRAINT [FK-Questionnaire-ParentQuestionnaire]

--ALTER TABLE [dbo].[T1-Questionnaire]
--DROP CONSTRAINT [FK-Questionnaire-CreatorUser]

 
--Query 11 
GO
CREATE PROCEDURE dbo.Q11
AS
DECLARE @maxFromAverage float;

SET @maxFromAverage = (	SELECT MAX(CompanyAvg.avgNoOfQuestions) 
						FROM	(SELECT C.[Brand Name],AVG(QpQ.noOfQuestions) AS avgNoOfQuestions
								FROM [T1-Question] Q, [T1-User] U, [T1-Company] C, [T1-Questionnaire] Qnnaire, [Questions per Questionnaire] QpQ
								WHERE Q.[Creator ID] = U.[User ID] AND U.[Company ID] = C.[Registration Number] AND Qnnaire.[Creator ID] = U.[User ID] 
								GROUP BY C.[Brand Name]) as CompanyAvg)

SELECT Qnnaire.Title, Qnnaire.Version
FROM [T1-Questionnaire] Qnnaire, [Questions per Questionnaire] QpQ
WHERE QpQ.[Questionnaire ID] = Qnnaire.[Questionnaire ID] AND QpQ.NoOfQuestions > @maxFromAverage


--Query 12 WORKS
GO
CREATE PROCEDURE dbo.Q12
AS
DECLARE @minNoOfQuestions int;

SET @minNoOfQuestions  = (SELECT MIN(QpQ.noOfQuestions) from [Questions per Questionnaire] QpQ)
	
print @minNoOfQuestions 				

SELECT QpQ.[Questionnaire ID]
FROM [Questions per Questionnaire] QpQ
WHERE QpQ.noOfQuestions = @minNoOfQuestions 



--Query 13
GO
CREATE PROCEDURE dbo.Q13
AS

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
CREATE PROCEDURE dbo.Q14 @qn_id varchar(30)
AS
SELECT *
FROM [T1-Questionnaire] Qn
WHERE NOT EXISTS
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
)


--QUERY 15--

GO
CREATE PROCEDURE dbo.Q15 @k_min int
AS
SELECT Q.[Question ID], Q.[Creator ID], Q.[Description], Q.[Type], Q.[Text]
FROM [T1-Question] Q,
(
	SELECT TOP (@k_min) QQP.[Question ID], COUNT(*) AS q_COUNT
	FROM [T1-Question Questionnaire Pairs] QQP
	GROUP BY QQP.[Question ID]
) MinimumQ
WHERE Q.[Question ID] = MinimumQ.[Question ID]


--QUERY 16--
GO
CREATE PROCEDURE dbo.Q16
AS
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

/*

@description varchar(50), @text varchar(100), @free_text_restriction varchar(30), @mult_choice_selectable_amount int,
@mult_choice_answers varchar(1000), @arithm_min int, @arithm_max int

*/