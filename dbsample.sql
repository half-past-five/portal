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
DROP PROCEDURE IF EXISTS dbo.Q7;  
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
	[Inductor ID] int,
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
INSERT INTO [T1-User] ([Name], [Birth Date], [Sex], [Position], [Username], [Password], [Privilages], [Company ID], [Manager ID]) VALUES ('Katrina Rosario', '1965/4/30', 'F', 'Development', 'K1', 'password K1', '2', '1339', '19')
INSERT INTO [T1-User] ([Name], [Birth Date], [Sex], [Position], [Username], [Password], [Privilages], [Company ID], [Manager ID]) VALUES ('Natalie Hudson', '1979/8/18', 'F', 'Marketing', 'N2', 'password N2', '3', '1772', '20')
INSERT INTO [T1-User] ([Name], [Birth Date], [Sex], [Position], [Username], [Password], [Privilages], [Company ID], [Manager ID]) VALUES ('David Madden', '1973/4/19', 'F', 'Development', 'D3', 'password D3', '1', '1976', '12')
INSERT INTO [T1-User] ([Name], [Birth Date], [Sex], [Position], [Username], [Password], [Privilages], [Company ID], [Manager ID]) VALUES ('Avah Potts', '1973/9/14', 'F', 'Marketing', 'A4', 'password A4', '1', '1333', '14')
INSERT INTO [T1-User] ([Name], [Birth Date], [Sex], [Position], [Username], [Password], [Privilages], [Company ID], [Manager ID]) VALUES ('Mariam Buckley', '1968/1/8', 'F', 'Sales', 'M5', 'password M5', '3', '1075', '1')
INSERT INTO [T1-User] ([Name], [Birth Date], [Sex], [Position], [Username], [Password], [Privilages], [Company ID], [Manager ID]) VALUES ('Sidney Newton', '1983/5/25', 'F', 'Marketing', 'S6', 'password S6', '1', '1336', '4')
INSERT INTO [T1-User] ([Name], [Birth Date], [Sex], [Position], [Username], [Password], [Privilages], [Company ID], [Manager ID]) VALUES ('Ismael Thompson', '1955/5/23', 'M', 'Marketing', 'I7', 'password I7', '1', '1009', '14')
INSERT INTO [T1-User] ([Name], [Birth Date], [Sex], [Position], [Username], [Password], [Privilages], [Company ID], [Manager ID]) VALUES ('Aydan Liu', '1995/6/30', 'M', 'Sales', 'A8', 'password A8', '2', '1734', '15')
INSERT INTO [T1-User] ([Name], [Birth Date], [Sex], [Position], [Username], [Password], [Privilages], [Company ID], [Manager ID]) VALUES ('John Brooks', '1956/8/15', 'M', 'Marketing', 'J9', 'password J9', '1', '1229', '1')
INSERT INTO [T1-User] ([Name], [Birth Date], [Sex], [Position], [Username], [Password], [Privilages], [Company ID], [Manager ID]) VALUES ('Daniela Anderson', '1987/12/10', 'M', 'Marketing', 'D10', 'password D10', '3', '1632', '13')
INSERT INTO [T1-User] ([Name], [Birth Date], [Sex], [Position], [Username], [Password], [Privilages], [Company ID], [Manager ID]) VALUES ('Tania Beard', '1998/9/2', 'F', 'Marketing', 'T11', 'password T11', '3', '1660', '1')
INSERT INTO [T1-User] ([Name], [Birth Date], [Sex], [Position], [Username], [Password], [Privilages], [Company ID], [Manager ID]) VALUES ('Jennifer Mcconnell', '1983/12/13', 'F', 'Sales', 'J12', 'password J12', '1', '1165', '9')
INSERT INTO [T1-User] ([Name], [Birth Date], [Sex], [Position], [Username], [Password], [Privilages], [Company ID], [Manager ID]) VALUES ('Irene Mccall', '1992/1/8', 'F', 'Marketing', 'I13', 'password I13', '2', '1273', '10')
INSERT INTO [T1-User] ([Name], [Birth Date], [Sex], [Position], [Username], [Password], [Privilages], [Company ID], [Manager ID]) VALUES ('Shaylee Decker', '1981/11/28', 'F', 'Development', 'S14', 'password S14', '1', '1967', '9')
INSERT INTO [T1-User] ([Name], [Birth Date], [Sex], [Position], [Username], [Password], [Privilages], [Company ID], [Manager ID]) VALUES ('Cindy Pratt', '2000/5/21', 'F', 'Development', 'C15', 'password C15', '2', '1914', '4')
INSERT INTO [T1-User] ([Name], [Birth Date], [Sex], [Position], [Username], [Password], [Privilages], [Company ID], [Manager ID]) VALUES ('Colt Gonzalez', '1991/8/2', 'M', 'Marketing', 'C16', 'password C16', '1', '1342', '16')
INSERT INTO [T1-User] ([Name], [Birth Date], [Sex], [Position], [Username], [Password], [Privilages], [Company ID], [Manager ID]) VALUES ('Kiera Andrade', '1989/7/31', 'F', 'Development', 'K17', 'password K17', '3', '1438', '18')
INSERT INTO [T1-User] ([Name], [Birth Date], [Sex], [Position], [Username], [Password], [Privilages], [Company ID], [Manager ID]) VALUES ('Bruce Jackson', '1980/8/17', 'M', 'Marketing', 'B18', 'password B18', '2', '1716', '2')
INSERT INTO [T1-User] ([Name], [Birth Date], [Sex], [Position], [Username], [Password], [Privilages], [Company ID], [Manager ID]) VALUES ('Axel Trujillo', '1950/5/3', 'F', 'Marketing', 'A19', 'password A19', '2', '1883', '1')
INSERT INTO [T1-User] ([Name], [Birth Date], [Sex], [Position], [Username], [Password], [Privilages], [Company ID], [Manager ID]) VALUES ('Elaine Allison', '1960/3/8', 'M', 'Marketing', 'E20', 'password E20', '1', '1499', '2')

INSERT INTO [T1-Privilages] ([Privilage Number], [Privilage Decription]) VALUES ('1', 'DO')
INSERT INTO [T1-Privilages] ([Privilage Number], [Privilage Decription]) VALUES ('2', 'DE')
INSERT INTO [T1-Privilages] ([Privilage Number], [Privilage Decription]) VALUES ('3', 'AX')

INSERT INTO	[T1-Question] ([Creator ID], [Type], [Description], [Text]) VALUES ('4', 'Free Text', 'Desc', 'Txt')
INSERT INTO [T1-Free Text Question] ([Question ID]) VALUES ('1')


--FOREIGN KEYS 
ALTER TABLE dbo.[T1-User] WITH NOCHECK ADD
CONSTRAINT [FK-User-Manager] FOREIGN KEY ([Manager ID]) REFERENCES [T1-User]([User ID]),
CONSTRAINT [FK-User-Privilages] FOREIGN KEY ([Privilages]) REFERENCES [T1-Privilages]([Privilage Number]), --trigger for this
CONSTRAINT [FK-User-Company] FOREIGN KEY ([Company ID]) REFERENCES [dbo].[T1-Company]([Registration Number]) ON UPDATE CASCADE ON DELETE CASCADE,
CONSTRAINT [Range-Privilage] CHECK (Privilages between 1 and 3)

ALTER TABLE dbo.[T1-Company]  ADD 
CONSTRAINT [FK-Company-InductorUser] FOREIGN KEY ([Inductor ID]) REFERENCES [dbo].[T1-User]([User ID]),
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
CREATE PROCEDURE dbo.Q9
AS
SELECT Title, [Version], COUNT([Question ID]) as q_count
FROM [T1-Question Questionnaire Pairs] qqp, [T1-Completed Questionnaire] cq, [T1-Questionnaire] q
WHERE
cq.[Questionnaire ID] = q.[Questionnaire ID] AND
qqp.[Questionnaire ID] = cq.[Questionnaire ID]
GROUP BY Title, [Version]




