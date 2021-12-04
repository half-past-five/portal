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

---------CREATE TABLES----------

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

CREATE TABLE [dbo].[T1-Company](
	[Company ID] int IDENTITY(1,1) not null,
	[Registration Number] int not null, --NOT SPECIFIED BY US
	[Brand Name] varchar(50) not null,
	[Induction Date] date not null,
	CONSTRAINT [PK-Company] PRIMARY KEY NONCLUSTERED ([Company ID]),
	UNIQUE([Registration Number])
)


CREATE TABLE dbo.[T1-User] (
	[User ID] int IDENTITY(1,1) not null, --IDENTITY added 
	[IDCard] int not null, --ADD DEFAULT
	[Name] varchar(30) not null,
	[Birth Date] date not null,
	Sex char(1) not null,
	Position varchar(30) DEFAULT 'employee' not null,
	Username varchar(30) not null,
	[Password] varchar(30) not null,
	Privilages int not null,
	[Company ID] int,
	[Manager ID] int DEFAULT NULL,
	UNIQUE(Username),
	UNIQUE(IDCard),
	CONSTRAINT [PK-User] PRIMARY KEY NONCLUSTERED ([User ID]),
	CHECK ([Privilages] in ('1', '2', '3'))
)


CREATE TABLE dbo.[T1-Question] (
	[Question ID] int IDENTITY(1,1) not null,
	[Question Code] varchar(30) not null,	
	[Creator ID] int,
	[Type] varchar(30),
	[Description] varchar(50) DEFAULT 'This is decription' not null,
	[Text] varchar(100) not null,
	UNIQUE([Question Code]),
	CONSTRAINT [PK-Question] PRIMARY KEY NONCLUSTERED ([Question ID]),
	CHECK ([Type] in ('Free Text','Multiple Choice','Arithmetic'))
)
	

CREATE TABLE dbo.[T1-Free Text Question] (
	[Question ID] int not null,
	[Restriction] varchar(30) DEFAULT null
	UNIQUE([Question ID])
)	

CREATE TABLE dbo.[T1-Arithmetic Question] (
	[Question ID] int not null,
	[MIN value] int DEFAULT null, 
	[MAX value] int DEFAULT null,--min & max value added for range
	UNIQUE([Question ID]),
	CHECK ([MAX value] >= [MIN value])
	
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

	CREATE TABLE dbo.[T1-Question Questionnaire Pairs] (
	[Question ID] int not null,
	[Questionnaire ID] int not null,
	UNIQUE([Question ID], [Questionnaire ID])
	)
	

CREATE TABLE [dbo].[T1-Log](
	[Event]	varchar(100) not null,
	)

CREATE TABLE [dbo].[T1-Questionnaire Log](
	[Event]	varchar(100) not null,
	[Questionnaire ID] int not null,
	[User ID] int not null
)
---------- INSERTS ----------
--RUN 1.[T1-Company]
--RUN 2.[T1-User]
--RUN 3.[T1-Question]
--RUN 4.[T1-Questionnaire]
--RUN 5.[T1-Question Questionnaire Pairs]
---------- INSERTS ----------

--FOREIGN KEYS 
ALTER TABLE dbo.[T1-User] WITH NOCHECK ADD
CONSTRAINT [FK-User-Manager] FOREIGN KEY ([Manager ID]) REFERENCES [T1-User]([User ID]), --TRIGGER
CONSTRAINT [FK-User-Company] FOREIGN KEY ([Company ID]) REFERENCES [dbo].[T1-Company]([Company ID]) ON UPDATE CASCADE ON DELETE CASCADE

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

ALTER TABLE dbo.[T1-Questionnaire Log] ADD
CONSTRAINT [FK-Log-Questionnaire] FOREIGN KEY ([Questionnaire ID]) REFERENCES dbo.[T1-Questionnaire]([Questionnaire ID]) ON UPDATE CASCADE
CONSTRAINT [FK-Log-User] FOREIGN KEY ([User ID]) REFERENCES dbo.[T1-User]([User ID]) ON UPDATE CASCADE ON DELETE CASCADE

