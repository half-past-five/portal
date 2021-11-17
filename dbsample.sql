DECLARE @sql nvarchar(MAX) 
SET @sql = N'' 

SELECT @sql = @sql + N'ALTER TABLE ' + QUOTENAME(KCU1.TABLE_SCHEMA) 
    + N'.' + QUOTENAME(KCU1.TABLE_NAME) 
    + N' DROP CONSTRAINT ' -- + QUOTENAME(rc.CONSTRAINT_SCHEMA)  + N'.'  -- not in MS-SQL
    + QUOTENAME(rc.CONSTRAINT_NAME) + N'; ' + CHAR(13) + CHAR(10) 
FROM INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS AS RC 

INNER JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE AS KCU1 
    ON KCU1.CONSTRAINT_CATALOG = RC.CONSTRAINT_CATALOG  
    AND KCU1.CONSTRAINT_SCHEMA = RC.CONSTRAINT_SCHEMA 
    AND KCU1.CONSTRAINT_NAME = RC.CONSTRAINT_NAME 

-- PRINT @sql 
EXECUTE(@sql) 


DROP TABLE IF EXISTS [dbo].[T1-Question Questionnaire Pairs]
DROP TABLE IF EXISTS [dbo].[T1-Log]
DROP TABLE IF EXISTS [dbo].[T1-Privilages]
DROP TABLE IF EXISTS [dbo].[T1-Company]
DROP TABLE IF EXISTS [dbo].[T1-Completed Questionnaire]--removed duplicate
DROP TABLE IF EXISTS [dbo].[T1-Questionnaire]
DROP TABLE IF EXISTS [dbo].[T1-User]
DROP TABLE IF EXISTS [dbo].[T1-Question]
DROP TABLE IF EXISTS [dbo].[T1-Free Text Question] --"Question" added
DROP TABLE IF EXISTS [dbo].[T1-Multiple Choice Question] -- "Question" added
DROP TABLE IF EXISTS [dbo].[T1-Arithmetic Question]
DROP TABLE IF EXISTS [dbo].[T1-Multiple Choice Answer]


--TABLE QQpairs added
CREATE TABLE dbo.[T1-Question Questionnaire Pairs] (
	[Question ID] int not null,
	[Questionnaire Title] varchar(20) not null,
	[Questionnaire Version]  int not null
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
	[Company ID] int not null,
	[Manager ID] int not null
	UNIQUE(Username)
)


CREATE TABLE [dbo].[T1-Company](
	[Registration Number] int IDENTITY(1,1) not null, --IDENTITY added 
	[Brand Name] varchar(50) not null,
	[Induction Date] date not null,
	[Inductor ID] int,
	[Admin ID] int,

	)


CREATE TABLE dbo.[T1-Question] (
	[Question ID] int IDENTITY(1,1) not null,
	[Type] varchar(30) not null,
	[User ID] int not null,
	[Description] varchar(50) not null,
	[Text] varchar(100) not null,

)
	

CREATE TABLE dbo.[T1-Free Text Question] (
	[Question ID] int not null,
)	


CREATE TABLE dbo.[T1-Multiple Choice Question] (
	[Question ID] int not null,
	[SelecTABLE Amount] int not null, 
)
	

CREATE TABLE dbo.[T1-Multiple Choice Answer] ( --gia tuto en ekatalava akrivos pos en nan sindedemeno me to multiple choice question 
	[Answer] varchar(30) not null,
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
	[Creator ID] int not null,
	UNIQUE (Title, [Version])
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
	)


	--User constraints added	
	ALTER TABLE dbo.[T1-User] ADD
	CONSTRAINT [PK-User] PRIMARY KEY ([User ID]),
	CONSTRAINT [FK-User-Manager] FOREIGN KEY ([Manager ID]) REFERENCES [dbo].[T1-User]([User ID]) ON UPDATE CASCADE ON DELETE CASCADE,
	CONSTRAINT [FK-User-Privilages] FOREIGN KEY ([Privilages]) REFERENCES [dbo].[T1-Privilages]([Privilage Number]),
	CONSTRAINT [Range-Privilage] CHECK (Privilages between 1 and 3)

	--Company constraints added
	ALTER TABLE dbo.[T1-Company]  ADD 
	CONSTRAINT [PK-Company] PRIMARY KEY ([Registration Number]),
	CONSTRAINT [FK-Company-InductorUser] FOREIGN KEY ([Inductor ID]) REFERENCES [dbo].[T1-User]([User ID]) ON UPDATE CASCADE ON DELETE SET NULL,
	CONSTRAINT [FK-Company-AdminUser]  FOREIGN KEY ([Admin ID]) REFERENCES [dbo].[T1-User]([User ID]) ON UPDATE CASCADE ON DELETE SET NULL

	ALTER TABLE dbo.[T1-User] ADD
	CONSTRAINT [FK-User-Company] FOREIGN KEY ([Company ID]) REFERENCES [dbo].[T1-Company]([Registration Number]) ON UPDATE CASCADE ON DELETE CASCADE,
	CONSTRAINT [PK-Username] PRIMARY KEY([Username]) 

	--Question constraints added
	ALTER TABLE dbo.[T1-Question] ADD
	CONSTRAINT [PK-Question] PRIMARY KEY ([Question ID]),
	CONSTRAINT [FK-Question-CreatorUser] FOREIGN KEY ([User ID]) REFERENCES [dbo].[T1-User]([User ID]) ON UPDATE CASCADE ON DELETE SET NULL

		--Free text question constraints added
	ALTER TABLE dbo.[T1-Free Text Question] ADD
	CONSTRAINT [FK-Free Text-Main Question] FOREIGN KEY ([Question ID]) REFERENCES [dbo].[T1-Question]([Question ID]) ON UPDATE CASCADE ON DELETE CASCADE

	--Multiple choice question constraints added
	ALTER TABLE dbo.[T1-Multiple Choice Question] ADD
   CONSTRAINT [FK-Multiple Choice-Main Question] FOREIGN KEY ([Question ID]) REFERENCES [dbo].[T1-Question]([Question ID]) ON UPDATE CASCADE ON DELETE CASCADE

   --Multiple choice question constraints added
	ALTER TABLE dbo.[T1-Multiple Choice Answer] ADD
	CONSTRAINT [FK-Answer-Multiple Choice Question] FOREIGN KEY ([Question ID]) REFERENCES [dbo].[T1-Question]([Question ID]) ON UPDATE CASCADE ON DELETE CASCADE

	--Arithmetic question constraints added
	ALTER TABLE dbo.[T1-Arithmetic Question] ADD
	CONSTRAINT [FK-Arithmetic-Main Question] FOREIGN KEY ([Question ID]) REFERENCES [dbo].[T1-Question]([Question ID]) ON UPDATE CASCADE ON DELETE CASCADE

	--Question constraints added
	ALTER TABLE [dbo].[T1-Questionnaire] ADD
	CONSTRAINT [PK-Questionnaire] PRIMARY KEY ([Title],[Version]),
	CONSTRAINT [FK-Questionnaire-ParentQuestionnaire] FOREIGN KEY ([Parent ID]) REFERENCES [dbo].[T1-Questionnaire]([Questionnaire ID]) ON UPDATE CASCADE ON DELETE SET NULL, --ask pankris
	CONSTRAINT [FK-Questionnaire-CreatorUser] FOREIGN KEY ([Creator ID]) REFERENCES [dbo].[T1-User]([User ID]) ON UPDATE CASCADE ON DELETE SET NULL

	--Completed Questionnaire constraints added
	ALTER TABLE dbo.[T1-Completed Questionnaire] ADD
	CONSTRAINT [FK-Completed-Questionnaire] FOREIGN KEY ([Questionnaire ID]) REFERENCES [dbo].[T1-Questionnaire]([Questionnaire ID]) ON UPDATE CASCADE ON DELETE CASCADE

	--Privilages constraints added
	ALTER TABLE [dbo].[T1-Privilages] ADD
	CONSTRAINT [PK-Privilages] PRIMARY KEY ([Privilage Number])

	
	IF OBJECT_ID ('PrivilagesReject', 'TR') IS NOT NULL DROP TRIGGER PrivilagesReject;

	CREATE TRIGGER PrivilagesReject ON [T1-Privilages]
	AFTER INSERT, UPDATE, DELETE
	AS
	BEGIN
	RAISERROR ('Cannot alter Privilages TABLE', 16, 1);
	ROLLBACK TRANSACTION;
	RETURN
	END;

	DELETE from [T1-Privilages] where [Privilage Number] = '1'



INSERT INTO [T1-User] ([Name], [Birth Date], [Sex], [Position], [Username], [Password], [Privilages], [Company ID], [Manager ID])
VALUES ('Loukis', '2000/5/3', 'F', 'Manaaagweeeeeer', 'lpapal03', 'hehe', '1', '000', '0')

select * from [T1-User]

delete from [T1-User] where Username='lpapal03'
