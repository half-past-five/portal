--DROP ALL TABLES 
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

--DROP TRIGGERS
DROP TRIGGER IF EXISTS dbo.PrivilagesReject;

--DROP SPOCS
DROP PROCEDURE IF EXISTS dbo.Authenticate;
DROP PROCEDURE IF EXISTS dbo.Q1; 
DROP PROCEDURE IF EXISTS dbo.Q7; 
DROP PROCEDURE IF EXISTS dbo.Q8; 
DROP PROCEDURE IF EXISTS dbo.Q9;  

--CREATE TABLES 
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
	CONSTRAINT [PK-User] PRIMARY KEY NONCLUSTERED ([User ID])
)


CREATE TABLE [dbo].[T1-Company](
	[Registration Number] int not null, --NOT SPECIFIED BY US
	[Brand Name] varchar(50) not null,
	[Induction Date] date not null,
	[Admin ID] int
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
)	


CREATE TABLE dbo.[T1-Multiple Choice Question] (
	[Question ID] int not null,
	[Selectable Amount] int not null, 
)
	

CREATE TABLE dbo.[T1-Multiple Choice Answer] ( --gia tuto en ekatalava akrivos pos en nan sindedemeno me to multiple choice question 
	[Answers Table] varchar(30) not null,
	[Question ID] int not null,	
)
	

CREATE TABLE dbo.[T1-Arithmetic Question] (
	[Question ID] int not null,
	--[Range] int not null
	[MIN value] int not null, 
	[MAX value] int not null, --min & max value added for range	
)
	

CREATE TABLE [dbo].[T1-Questionnaire](
	[Questionnaire ID] int IDENTITY(1,1) not null,
	[Title] varchar(20) not null,
	[Version] int not null,
	[Parent ID] int,
	[Creator ID] int,
	UNIQUE (Title, [Version]),
	CONSTRAINT [PK-Questionnaire] PRIMARY KEY NONCLUSTERED ([Questionnaire ID])
	)
	

CREATE TABLE dbo.[T1-Completed Questionnaire] (
	[Questionnaire ID] int not null,
	[URL] nvarchar(2083) not null,
)
	

CREATE TABLE [dbo].[T1-Log](
	[Event]	varchar(100) not null,
	)


CREATE TABLE [dbo].[T1-Privilages](
	[Privilage Number] int not null,
	[Privilage Decription] varchar(20) not null
	CONSTRAINT [PK-Privilages] PRIMARY KEY NONCLUSTERED ([Privilage Number])
	)


--ANY INSERTS
INSERT INTO [T1-User] ([Name], [Birth Date], [Sex], [Position], [Username], [Password], [Privilages], [Company ID], [Manager ID]) VALUES ('Katrina Rosario', '1965/4/30', 'F', 'Development', 'K1', 'password K1', '2', '0001', '2')
INSERT INTO [T1-User] ([Name], [Birth Date], [Sex], [Position], [Username], [Password], [Privilages], [Company ID], [Manager ID]) VALUES ('Natalie Hudson', '1979/8/18', 'F', 'Marketing', 'N2', 'password N2', '3', '0001', '2')
INSERT INTO [T1-User] ([Name], [Birth Date], [Sex], [Position], [Username], [Password], [Privilages], [Company ID], [Manager ID]) VALUES ('David Madden', '1973/4/19', 'F', 'Development', 'D3', 'password D3', '3', '0002', '3')
INSERT INTO [T1-User] ([Name], [Birth Date], [Sex], [Position], [Username], [Password], [Privilages], [Company ID], [Manager ID]) VALUES ('Avah Potts', '1973/9/14', 'F', 'Marketing', 'A4', 'password A4', '2', '0002', '3')

INSERT INTO [T1-Privilages] ([Privilage Number], [Privilage Decription]) VALUES ('1', 'DO')
INSERT INTO [T1-Privilages] ([Privilage Number], [Privilage Decription]) VALUES ('2', 'DE')
INSERT INTO [T1-Privilages] ([Privilage Number], [Privilage Decription]) VALUES ('3', 'AX')

INSERT INTO	[T1-Question] ([Creator ID], [Type], [Description], [Text]) VALUES ('1', 'Free Text', 'The first question', 'Do you like db?')
INSERT INTO [T1-Free Text Question] ([Question ID]) VALUES ('1')
INSERT INTO	[T1-Question] ([Creator ID], [Type], [Description], [Text]) VALUES ('1', 'Arithmetic', 'The second question', 'How much do you like db?')
INSERT INTO [T1-Arithmetic Question] ([Question ID], [MIN value], [MAX value]) VALUES ('1', '0', '10')

INSERT INTO [T1-Company] ([Registration Number], [Brand Name], [Induction Date], [Admin ID]) VALUES ('0001', 'Company 1', '2020/11/10', '1')

--FOREIGN KEYS 
ALTER TABLE dbo.[T1-User] WITH NOCHECK ADD
CONSTRAINT [FK-User-Manager] FOREIGN KEY ([Manager ID]) REFERENCES [T1-User]([User ID]),
CONSTRAINT [FK-User-Privilages] FOREIGN KEY ([Privilages]) REFERENCES [T1-Privilages]([Privilage Number]), --trigger for this
CONSTRAINT [FK-User-Company] FOREIGN KEY ([Company ID]) REFERENCES [dbo].[T1-Company]([Registration Number]) ON UPDATE CASCADE ON DELETE CASCADE,
CONSTRAINT [Range-Privilage] CHECK (Privilages between 1 and 3)

ALTER TABLE dbo.[T1-Company]  ADD 
CONSTRAINT [FK-Company-AdminUser]  FOREIGN KEY ([Admin ID]) REFERENCES [dbo].[T1-User]([User ID])

ALTER TABLE dbo.[T1-Question] ADD
CONSTRAINT [FK-Question-CreatorUser] FOREIGN KEY ([Creator ID]) REFERENCES [dbo].[T1-User]([User ID]) ON UPDATE CASCADE ON DELETE SET NULL

ALTER TABLE dbo.[T1-Free Text Question] ADD
CONSTRAINT [FK-Free Text-Main Question] FOREIGN KEY ([Question ID]) REFERENCES [dbo].[T1-Question]([Question ID]) ON UPDATE CASCADE ON DELETE CASCADE

ALTER TABLE dbo.[T1-Multiple Choice Question] ADD
CONSTRAINT [FK-Multiple Choice-Main Question] FOREIGN KEY ([Question ID]) REFERENCES [dbo].[T1-Question]([Question ID]) ON UPDATE CASCADE ON DELETE CASCADE

ALTER TABLE dbo.[T1-Multiple Choice Answer] ADD
CONSTRAINT [FK-Answer-Multiple Choice Question] FOREIGN KEY ([Question ID]) REFERENCES [dbo].[T1-Question]([Question ID]) ON UPDATE CASCADE ON DELETE CASCADE

ALTER TABLE dbo.[T1-Arithmetic Question] ADD
CONSTRAINT [FK-Arithmetic-Main Question] FOREIGN KEY ([Question ID]) REFERENCES [dbo].[T1-Question]([Question ID]) ON UPDATE CASCADE ON DELETE CASCADE

ALTER TABLE [dbo].[T1-Questionnaire] ADD
CONSTRAINT [FK-Questionnaire-ParentQuestionnaire] FOREIGN KEY ([Parent ID]) REFERENCES [dbo].[T1-Questionnaire]([Questionnaire ID]), --ask pankris
CONSTRAINT [FK-Questionnaire-CreatorUser] FOREIGN KEY ([Creator ID]) REFERENCES [dbo].[T1-User]([User ID]) ON UPDATE CASCADE ON DELETE SET NULL

ALTER TABLE dbo.[T1-Completed Questionnaire] ADD
CONSTRAINT [FK-Completed-Questionnaire] FOREIGN KEY ([Questionnaire ID]) REFERENCES [dbo].[T1-Questionnaire]([Questionnaire ID]) ON UPDATE CASCADE ON DELETE CASCADE

ALTER TABLE dbo.[T1-Question Questionnaire Pairs] ADD
CONSTRAINT [FK-Question-ID] FOREIGN KEY ([Question ID]) REFERENCES [dbo].[T1-Question]([Question ID]) ON UPDATE CASCADE ON DELETE CASCADE,
CONSTRAINT [FK-Questionnaire-ID] FOREIGN KEY ([Questionnaire ID]) REFERENCES [dbo].[T1-Questionnaire]([Questionnaire ID])

--TRIGGERS
GO
CREATE TRIGGER dbo.PrivilagesReject ON [T1-Privilages]
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
RAISERROR ('Cannot alter Privilages TABLE', 16, 1);
ROLLBACK TRANSACTION;
RETURN
END;

--SPOCS
GO
CREATE PROCEDURE dbo.Authenticate @username varchar(30), @password varchar(30)
AS
SELECT CONVERT(varchar, Privilages) as Privilages
FROM [T1-User]
WHERE Username = @username and [Password] = @password

GO
CREATE PROCEDURE dbo.Q1 @name varchar(50), @bday date, @sex char(1), 
@position varchar(30), @username varchar(30), @password varchar(30), @manager_id int, 
@company_reg_num int, @company_brand_name varchar(50)
AS
ALTER TABLE [T1-User] NOCHECK CONSTRAINT ALL;
ALTER TABLE [T1-Company] NOCHECK CONSTRAINT ALL;
INSERT INTO [T1-User] ([Name], [Birth Date], [Sex], [Position], [Username], [Password], [Privilages], [Company ID], [Manager ID]) VALUES (@name, @bday, @sex, @position, @username, @password,'2', @company_reg_num, @manager_id)
DECLARE @admin_id int 
SELECT @admin_id = u.[User ID]
FROM [T1-User] u
WHERE u.Username = @username AND u.[Password] = @password
INSERT INTO [T1-Company] ([Registration Number], [Brand Name], [Induction Date], [Admin ID]) VALUES (@company_reg_num, @company_brand_name, CAST( GETDATE() AS Date ), @admin_id)
ALTER TABLE [T1-User] CHECK CONSTRAINT ALL
ALTER TABLE [T1-Company] CHECK CONSTRAINT ALL

GO
CREATE PROCEDURE dbo.Q7 @user_id varchar(30)
AS
SELECT Title, [Version], COUNT([Question ID]) as q_count
FROM [T1-Completed Questionnaire] cq,  [T1-Questionnaire] q, [T1-User] u, [T1-Question Questionnaire Pairs] qqp
WHERE 
cq.[Questionnaire ID] = q.[Questionnaire ID] AND
qqp.[Questionnaire ID] = cq.[Questionnaire ID] AND
q.[Creator ID] = u.[User ID] AND
u.[User ID] = @user_id
GROUP BY Title, [Version]
ORDER BY q_count

GO
CREATE PROCEDURE dbo.Q8 @user_id varchar(30)
AS
SELECT apps_table.[Question ID], q.[Text]
FROM [T1-Question] q,
	(
	SELECT [Question ID], COUNT(qqp.[Questionnaire ID]) as appearances
	FROM [T1-Question Questionnaire Pairs] qqp, [T1-Completed Questionnaire] cq, [T1-Questionnaire] q, [T1-User] u
	WHERE
	qqp.[Questionnaire ID] = cq.[Questionnaire ID] AND
	q.[Questionnaire ID] = cq.[Questionnaire ID] AND
	u.[Company ID] = (SELECT [Company ID] FROM [T1-User] WHERE [User ID] = @user_id)
	GROUP BY [Question ID]
	) apps_table
WHERE 
apps_table.appearances = (SELECT MAX(apps_table.appearances) FROM apps_table) AND
apps_table.[Question ID] = q.[Question ID]

GO
CREATE PROCEDURE dbo.Q9
AS
SELECT Title, [Version], COUNT([Question ID]) as q_count
FROM [T1-Question Questionnaire Pairs] qqp, [T1-Completed Questionnaire] cq, [T1-Questionnaire] q
WHERE
cq.[Questionnaire ID] = q.[Questionnaire ID] AND
qqp.[Questionnaire ID] = cq.[Questionnaire ID]
GROUP BY Title, [Version]

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
	(SELECT QQP2[Question ID]
	FROM [T1-Question Questionnaire Pairs] QQP2
	WHERE QQP2.[Questionnaire ID] = Qn.[Questionnaire ID]
	)
)

GO
CREATE PROCEDURE dbo.Q15 @k_min varchar(30)
AS
SELECT TOP (@kMin) *
FROM [T1-Question] Q
WHERE Q.[Question ID] IN
(
	SELECT QQP.[Question ID], COUNT(*) AS q_COUNT
	FROM [T1-Question Questionnaire Pairs] QQP
	GROUP BY QQP.[Question ID]
	ORDER BY COUNT(*) ASC
)

GO
CREATE PROCEDURE dbo.Q16
AS
SELECT *
FROM [T1-Question] Q
WHERE NOT EXISTS
(
	--All Questionnaire ids
	(SELECT Qn.[T1-Questionnaire ID]
	FROM [T1-Questionnaire] Qn
	)
	EXCEPT
	--All Questionnaire id of current question
	(SELECT QQR.[T1-Questionnaire ID]
	FROM [T1-Question Questionnaire Pairs] QQP
	WHERE QQR.[Question ID] = Q.[Question ID]
	)
)

exec Q1 @name='Loukis', @bday='2000/6/26', @sex='M', 
@position='Manager', @username='lpapal03', @password='hehehe', @manager_id=NULL, 
@company_reg_num ='999', @company_brand_name='Noname Company'

