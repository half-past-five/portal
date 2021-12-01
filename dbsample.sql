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
	[Registration Number] int not null, --NOT SPECIFIED BY US
	[Brand Name] varchar(50) not null,
	[Induction Date] date not null,
	CONSTRAINT [PK-Company] PRIMARY KEY NONCLUSTERED ([Registration Number])
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
	CONSTRAINT [PK-Question] PRIMARY KEY NONCLUSTERED ([Question ID]),
	CHECK ([Type] in ('Free Text','Multiple Choice','Arithmetic'))
)
	

CREATE TABLE dbo.[T1-Free Text Question] (
	[Question ID] int not null,
	[Question Code] varchar(30) not null,
	[Restriction] varchar(30) DEFAULT null
	UNIQUE([Question ID])
)	

CREATE TABLE dbo.[T1-Arithmetic Question] (
	[Question ID] int not null,
	[Question Code] varchar(30) not null,
	[MIN value] int DEFAULT null, 
	[MAX value] int DEFAULT null, --min & max value added for range	
	CHECK ([MAX value] > [MIN value])
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

---------- INSERTS ----------

--COMPANY DATA
INSERT INTO [T1-Company]([Registration Number],[Brand Name],[Induction Date]) VALUES (728386,'Zing Zang','2021/06/20');
INSERT INTO [T1-Company]([Registration Number],[Brand Name],[Induction Date]) VALUES (250001,'Icy Cool','2021/03/26');
INSERT INTO [T1-Company]([Registration Number],[Brand Name],[Induction Date]) VALUES (907205,'Riverbed','2020/06/07');
INSERT INTO [T1-Company]([Registration Number],[Brand Name],[Induction Date]) VALUES (320807,'Avatar Tech','2020/11/03');
INSERT INTO [T1-Company]([Registration Number],[Brand Name],[Induction Date]) VALUES (493089,'Vantage Group','2020/04/03');
INSERT INTO [T1-Company]([Registration Number],[Brand Name],[Induction Date]) VALUES (616571,'Effectus Solutions','2020/03/07');
INSERT INTO [T1-Company]([Registration Number],[Brand Name],[Induction Date]) VALUES (206439,'Life Of Pie','2020/05/13');
INSERT INTO [T1-Company]([Registration Number],[Brand Name],[Induction Date]) VALUES (982085,'Band Of Flowers','2021/08/25');
INSERT INTO [T1-Company]([Registration Number],[Brand Name],[Induction Date]) VALUES (862528,'Progressive Technology Solutions','2021/01/01');
INSERT INTO [T1-Company]([Registration Number],[Brand Name],[Induction Date]) VALUES (928187,'Wire Attire','2020/01/13');
INSERT INTO [T1-Company]([Registration Number],[Brand Name],[Induction Date]) VALUES (424588,'Tech Partners','2020/06/15');
INSERT INTO [T1-Company]([Registration Number],[Brand Name],[Induction Date]) VALUES (732380,'Klasp','2020/08/28');
INSERT INTO [T1-Company]([Registration Number],[Brand Name],[Induction Date]) VALUES (613487,'Cool Collective','2020/10/22');
INSERT INTO [T1-Company]([Registration Number],[Brand Name],[Induction Date]) VALUES (311955,'Birdsong','2020/06/01');
INSERT INTO [T1-Company]([Registration Number],[Brand Name],[Induction Date]) VALUES (871797,'Slick Systems','2021/05/16');
INSERT INTO [T1-Company]([Registration Number],[Brand Name],[Induction Date]) VALUES (977622,'DeployDash','2020/02/01');
INSERT INTO [T1-Company]([Registration Number],[Brand Name],[Induction Date]) VALUES (121278,'Clip Shop','2021/03/07');
INSERT INTO [T1-Company]([Registration Number],[Brand Name],[Induction Date]) VALUES (821815,'Nationale Digitale','2021/02/09');
INSERT INTO [T1-Company]([Registration Number],[Brand Name],[Induction Date]) VALUES (693458,'Top in Tech','2021/08/19');
INSERT INTO [T1-Company]([Registration Number],[Brand Name],[Induction Date]) VALUES (725083,'Success Tech','2021/04/10');
INSERT INTO [T1-Company]([Registration Number],[Brand Name],[Induction Date]) VALUES (807847,'The Whisperer','2020/09/28');
INSERT INTO [T1-Company]([Registration Number],[Brand Name],[Induction Date]) VALUES (928539,'The Nosh Pit','2021/02/24');
INSERT INTO [T1-Company]([Registration Number],[Brand Name],[Induction Date]) VALUES (949326,'Futuratech','2021/07/08');
INSERT INTO [T1-Company]([Registration Number],[Brand Name],[Induction Date]) VALUES (314761,'Compelling Convo','2020/02/20');
INSERT INTO [T1-Company]([Registration Number],[Brand Name],[Induction Date]) VALUES (830305,'Files and Firewalls','2021/09/11');
INSERT INTO [T1-Company]([Registration Number],[Brand Name],[Induction Date]) VALUES (201463,'InDesign','2021/07/13');
INSERT INTO [T1-Company]([Registration Number],[Brand Name],[Induction Date]) VALUES (164419,'Turners Tech Helpers','2020/06/09');
INSERT INTO [T1-Company]([Registration Number],[Brand Name],[Induction Date]) VALUES (218264,'Techware','2020/08/12');
INSERT INTO [T1-Company]([Registration Number],[Brand Name],[Induction Date]) VALUES (695397,'Will Thrill','2021/10/20');
INSERT INTO [T1-Company]([Registration Number],[Brand Name],[Induction Date]) VALUES (217528,'The Lonely Traveler','2021/06/13');

--USER data
INSERT INTO [T1-User]([IDCard],[Name],[Birth Date],[Sex],[Username],[Password],[Privilages],[Company ID]) VALUES (1,'Konstantinos Larkos','2000/06/04 00:00:00.000','M','klarko01','hihi',1,0);
INSERT INTO [T1-User]([IDCard],[Name],[Birth Date],[Sex],[Username],[Password],[Privilages],[Company ID]) VALUES (2,'Christos Kasoulides','2000/06/04 00:00:00.000','M','ckasou01','hoho',1,0);
INSERT INTO [T1-User]([IDCard],[Name],[Birth Date],[Sex],[Username],[Password],[Privilages],[Company ID]) VALUES (3,'Loukas Papalazarou','2000/06/04 00:00:00.000','M','lpapal03','hoho',1,0);
INSERT INTO [T1-User]([IDCard],[Name],[Birth Date],[Sex],[Username],[Password],[Privilages],[Company ID]) VALUES (4,'Christos Eleftheriou','2000/06/04 00:00:00.000','M','celeft01','hoho',1,0);
INSERT INTO [T1-User]([IDCard],[Name],[Birth Date],[Sex],[Username],[Password],[Privilages],[Company ID]) VALUES (5,'Marios Vasileiou','2000/06/04 00:00:00.000','M','mvasei01','hoho',1,0);
INSERT INTO [T1-User]([IDCard],[Name],[Birth Date],[Sex],[Username],[Password],[Privilages],[Company ID]) VALUES (648692,'Sibill Nicks','1982/10/02 00:00:00.000','M','User6','Pass6',2,1);
INSERT INTO [T1-User]([IDCard],[Name],[Birth Date],[Sex],[Username],[Password],[Privilages],[Company ID]) VALUES (1071309,'Silvester Cloke','1998/02/03 00:00:00.000','M','User7','Pass7',3,1);
INSERT INTO [T1-User]([IDCard],[Name],[Birth Date],[Sex],[Username],[Password],[Privilages],[Company ID]) VALUES (398688,'Vaggelis Burnell','1989/07/19 00:00:00.000','M','User8','Pass8',3,1);
INSERT INTO [T1-User]([IDCard],[Name],[Birth Date],[Sex],[Username],[Password],[Privilages],[Company ID]) VALUES (701468,'Jeremy Parr','1973/02/16 00:00:00.000','M','User9','Pass9',3,1);
INSERT INTO [T1-User]([IDCard],[Name],[Birth Date],[Sex],[Username],[Password],[Privilages],[Company ID]) VALUES (552697,'Stefanos Lock','1979/04/02 00:00:00.000','M','User10','Pass10',3,1);
INSERT INTO [T1-User]([IDCard],[Name],[Birth Date],[Sex],[Username],[Password],[Privilages],[Company ID]) VALUES (699428,'Lawrence Dennis','1970/09/08 00:00:00.000','M','User11','Pass11',3,1);
INSERT INTO [T1-User]([IDCard],[Name],[Birth Date],[Sex],[Username],[Password],[Privilages],[Company ID]) VALUES (120928,'Jesse Mutter','1986/04/22 00:00:00.000','M','User12','Pass12',3,1);
INSERT INTO [T1-User]([IDCard],[Name],[Birth Date],[Sex],[Username],[Password],[Privilages],[Company ID]) VALUES (434463,'Osmund Smith','1989/09/09 00:00:00.000','M','User13','Pass13',3,1);
INSERT INTO [T1-User]([IDCard],[Name],[Birth Date],[Sex],[Username],[Password],[Privilages],[Company ID]) VALUES (149604,'Dimosthenis Low','1998/08/26 00:00:00.000','M','User14','Pass14',3,1);
INSERT INTO [T1-User]([IDCard],[Name],[Birth Date],[Sex],[Username],[Password],[Privilages],[Company ID]) VALUES (737153,'Humphry Fowler','1964/12/16 00:00:00.000','M','User15','Pass15',3,1);
INSERT INTO [T1-User]([IDCard],[Name],[Birth Date],[Sex],[Username],[Password],[Privilages],[Company ID]) VALUES (256357,'Apostolos Woodman','1990/10/29 00:00:00.000','M','User16','Pass16',3,1);
INSERT INTO [T1-User]([IDCard],[Name],[Birth Date],[Sex],[Username],[Password],[Privilages],[Company ID]) VALUES (124505,'Pompey Putt','1986/03/24 00:00:00.000','M','User17','Pass17',3,1);
INSERT INTO [T1-User]([IDCard],[Name],[Birth Date],[Sex],[Username],[Password],[Privilages],[Company ID]) VALUES (225897,'Ellis Braund','1980/09/15 00:00:00.000','M','User18','Pass18',3,1);
INSERT INTO [T1-User]([IDCard],[Name],[Birth Date],[Sex],[Username],[Password],[Privilages],[Company ID]) VALUES (919447,'Xenofon Symons','1983/04/19 00:00:00.000','M','User19','Pass19',3,1);
INSERT INTO [T1-User]([IDCard],[Name],[Birth Date],[Sex],[Username],[Password],[Privilages],[Company ID]) VALUES (568619,'Erasmus Germon','1992/03/28 00:00:00.000','M','User20','Pass20',2,2);
INSERT INTO [T1-User]([IDCard],[Name],[Birth Date],[Sex],[Username],[Password],[Privilages],[Company ID]) VALUES (247771,'Isabella  Vittery','1978/04/08 00:00:00.000','F','User21','Pass21',3,2);
INSERT INTO [T1-User]([IDCard],[Name],[Birth Date],[Sex],[Username],[Password],[Privilages],[Company ID]) VALUES (668258,'Petros Jarvis','1975/03/05 00:00:00.000','M','User22','Pass22',3,2);
INSERT INTO [T1-User]([IDCard],[Name],[Birth Date],[Sex],[Username],[Password],[Privilages],[Company ID]) VALUES (364868,'Ann Halfyard','1992/05/30 00:00:00.000','M','User23','Pass23',3,2);
INSERT INTO [T1-User]([IDCard],[Name],[Birth Date],[Sex],[Username],[Password],[Privilages],[Company ID]) VALUES (700410,'Maurice Drake','1973/11/13 00:00:00.000','M','User24','Pass24',3,2);
INSERT INTO [T1-User]([IDCard],[Name],[Birth Date],[Sex],[Username],[Password],[Privilages],[Company ID]) VALUES (264470,'Petros Smith','1964/08/14 00:00:00.000','M','User25','Pass25',3,2);
INSERT INTO [T1-User]([IDCard],[Name],[Birth Date],[Sex],[Username],[Password],[Privilages],[Company ID]) VALUES (1023827,'Marinos Edmonston','1987/01/19 00:00:00.000','M','User26','Pass26',3,2);
INSERT INTO [T1-User]([IDCard],[Name],[Birth Date],[Sex],[Username],[Password],[Privilages],[Company ID]) VALUES (1013321,'Dimitri Howis','1970/06/07 00:00:00.000','M','User27','Pass27',3,2);
INSERT INTO [T1-User]([IDCard],[Name],[Birth Date],[Sex],[Username],[Password],[Privilages],[Company ID]) VALUES (859388,'Silvester Westcott','1984/10/10 00:00:00.000','M','User28','Pass28',3,2);
INSERT INTO [T1-User]([IDCard],[Name],[Birth Date],[Sex],[Username],[Password],[Privilages],[Company ID]) VALUES (605170,'Joice Padfield','1989/09/07 00:00:00.000','M','User29','Pass29',3,2);
INSERT INTO [T1-User]([IDCard],[Name],[Birth Date],[Sex],[Username],[Password],[Privilages],[Company ID]) VALUES (255531,'Joseph James','1975/08/05 00:00:00.000','M','User30','Pass30',3,2);
INSERT INTO [T1-User]([IDCard],[Name],[Birth Date],[Sex],[Username],[Password],[Privilages],[Company ID]) VALUES (1050840,'Christopher Discombe','1995/08/29 00:00:00.000','M','User31','Pass31',2,3);
INSERT INTO [T1-User]([IDCard],[Name],[Birth Date],[Sex],[Username],[Password],[Privilages],[Company ID]) VALUES (474820,'Ellen  Vodden','1973/11/04 00:00:00.000','F','User32','Pass32',3,3);
INSERT INTO [T1-User]([IDCard],[Name],[Birth Date],[Sex],[Username],[Password],[Privilages],[Company ID]) VALUES (247797,'Panayiotis Lock','1964/12/25 00:00:00.000','M','User33','Pass33',3,3);
INSERT INTO [T1-User]([IDCard],[Name],[Birth Date],[Sex],[Username],[Password],[Privilages],[Company ID]) VALUES (327940,'Rose  Perry','1978/10/04 00:00:00.000','F','User34','Pass34',3,3);
INSERT INTO [T1-User]([IDCard],[Name],[Birth Date],[Sex],[Username],[Password],[Privilages],[Company ID]) VALUES (542602,'Lancelot Pinsent','1997/06/04 00:00:00.000','M','User35','Pass35',3,3);

--QUESTION data
INSERT INTO [T1-Question]([Question Code],[Creator ID],[Type],[Text]) VALUES ('FTX1',9,'Free Text','(FTX1): This is a free text question');
INSERT INTO [T1-Question]([Question Code],[Creator ID],[Type],[Text]) VALUES ('FTX2',9,'Free Text','(FTX2): This is a free text question');
INSERT INTO [T1-Question]([Question Code],[Creator ID],[Type],[Text]) VALUES ('FTX3',9,'Free Text','(FTX3): This is a free text question');
INSERT INTO [T1-Question]([Question Code],[Creator ID],[Type],[Text]) VALUES ('FTX4',12,'Free Text','(FTX4): This is a free text question');
INSERT INTO [T1-Question]([Question Code],[Creator ID],[Type],[Text]) VALUES ('FTX5',13,'Free Text','(FTX5): This is a free text question');
INSERT INTO [T1-Question]([Question Code],[Creator ID],[Type],[Text]) VALUES ('FTX6',14,'Free Text','(FTX6): This is a free text question');
INSERT INTO [T1-Question]([Question Code],[Creator ID],[Type],[Text]) VALUES ('FTX7',15,'Free Text','(FTX7): This is a free text question');
INSERT INTO [T1-Question]([Question Code],[Creator ID],[Type],[Text]) VALUES ('FTX8',17,'Free Text','(FTX8): This is a free text question');
INSERT INTO [T1-Question]([Question Code],[Creator ID],[Type],[Text]) VALUES ('FTX9',20,'Free Text','(FTX9): This is a free text question');

--FREE TEXT Question
INSERT INTO [T1-Free Text Question]([Question ID],[Question Code]) VALUES (11,'FTX1');
INSERT INTO [T1-Free Text Question]([Question ID],[Question Code]) VALUES (12,'FTX2');
INSERT INTO [T1-Free Text Question]([Question ID],[Question Code]) VALUES (13,'FTX3');
INSERT INTO [T1-Free Text Question]([Question ID],[Question Code]) VALUES (19,'FTX4');
INSERT INTO [T1-Free Text Question]([Question ID],[Question Code]) VALUES (23,'FTX5');

--ARITHMETIC Question
INSERT INTO [T1-Arithmetic Question]([Question ID],[Question Code]) VALUES (1,'NUM1');
INSERT INTO [T1-Arithmetic Question]([Question ID],[Question Code]) VALUES (5,'NUM2');
INSERT INTO [T1-Arithmetic Question]([Question ID],[Question Code]) VALUES (7,'NUM3');
INSERT INTO [T1-Arithmetic Question]([Question ID],[Question Code]) VALUES (10,'NUM4');
INSERT INTO [T1-Arithmetic Question]([Question ID],[Question Code]) VALUES (16,'NUM5');

INSERT INTO [T1-Arithmetic Question]([Question ID],[Question Code],[MIN value],[MAX value]) VALUES (6,'NUB1',780,1484);
INSERT INTO [T1-Arithmetic Question]([Question ID],[Question Code],[MIN value],[MAX value]) VALUES (20,'NUB2',242,373);
INSERT INTO [T1-Arithmetic Question]([Question ID],[Question Code],[MIN value],[MAX value]) VALUES (22,'NUB3',326,1297);
INSERT INTO [T1-Arithmetic Question]([Question ID],[Question Code],[MIN value],[MAX value]) VALUES (35,'NUB4',872,1562);
INSERT INTO [T1-Arithmetic Question]([Question ID],[Question Code],[MIN value],[MAX value]) VALUES (37,'NUB5',374,467);

--QUESTIONNAIRE data
INSERT INTO [T1-Questionnaire]([Title],[Version],[Parent ID],[Creator ID],[URL]) VALUES ('QS10010001',2,8,10,'http://someserver.com/QS10010001');
INSERT INTO [T1-Questionnaire]([Title],[Version],[Parent ID],[Creator ID],[URL]) VALUES ('QS10013002',1,NULL,13,NULL);
INSERT INTO [T1-Questionnaire]([Title],[Version],[Parent ID],[Creator ID],[URL]) VALUES ('QS10018003',3,1,18,'http://someserver.com/QS10018003');
INSERT INTO [T1-Questionnaire]([Title],[Version],[Parent ID],[Creator ID],[URL]) VALUES ('QS10013004',4,3,13,'http://someserver.com/QS10013004');
INSERT INTO [T1-Questionnaire]([Title],[Version],[Parent ID],[Creator ID],[URL]) VALUES ('QS10006005',5,4,6,'http://someserver.com/QS10006005');
INSERT INTO [T1-Questionnaire]([Title],[Version],[Parent ID],[Creator ID],[URL]) VALUES ('QS10012006',1,NULL,12,NULL);
INSERT INTO [T1-Questionnaire]([Title],[Version],[Parent ID],[Creator ID],[URL]) VALUES ('QS10011007',1,NULL,11,NULL);

--QUESTION QUESTIONNAIRE PAIRS data
INSERT INTO [T1-Question Questionnaire Pairs]([Question ID],[Questionnaire ID]) VALUES (1,1);
INSERT INTO [T1-Question Questionnaire Pairs]([Question ID],[Questionnaire ID]) VALUES (1,2);
INSERT INTO [T1-Question Questionnaire Pairs]([Question ID],[Questionnaire ID]) VALUES (1,5);

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
--print @maxNoOfQuestionnaires 	
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

exec Q8 @user_id = '1'

exec Q9

/*

@description varchar(50), @text varchar(100), @free_text_restriction varchar(30), @mult_choice_selectable_amount int,
@mult_choice_answers varchar(1000), @arithm_min int, @arithm_max int

*/


--BRANCH TESTING