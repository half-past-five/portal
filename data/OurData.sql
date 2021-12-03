---------- INSERTS ----------

--COMPANY DATA
INSERT INTO [T1-Company] ([Registration Number], [Brand Name], [Induction Date]) VALUES ('1', 'Company 1', '2020/11/10')
INSERT INTO [T1-Company] ([Registration Number], [Brand Name], [Induction Date]) VALUES ('2', 'Company 2', '2020/11/10')
INSERT INTO [T1-Company] ([Registration Number], [Brand Name], [Induction Date]) VALUES ('3', 'Company 3', '2020/11/10')
INSERT INTO [T1-Company] ([Registration Number], [Brand Name], [Induction Date]) VALUES ('99', 'Kass Business', '2020/11/10')


--USER data
INSERT INTO [T1-User] ([Name], [Birth Date], [Sex], [Position], [Username], [Password], [Privilages], [Company ID], [Manager ID]) VALUES ('Manager 1', '2000/6/26', 'M', 'Development', 'manager1', 'hoho', '2', '1', NULL)
INSERT INTO [T1-User] ([Name], [Birth Date], [Sex], [Position], [Username], [Password], [Privilages], [Company ID], [Manager ID]) VALUES ('Manager 2', '2000/6/26', 'M', 'Development', 'manager2', 'hoho', '2', '2', NULL)
INSERT INTO [T1-User] ([Name], [Birth Date], [Sex], [Position], [Username], [Password], [Privilages], [Company ID], [Manager ID]) VALUES ('Manager 3', '2000/6/26', 'M', 'Development', 'manager3', 'hoho', '2', '3', NULL)
INSERT INTO [T1-User] ([Name], [Birth Date], [Sex], [Position], [Username], [Password], [Privilages], [Company ID], [Manager ID]) VALUES ('User 1', '2000/6/26', 'M', 'Marketing', 'user1', 'hoho', '3', 1, '1')
INSERT INTO [T1-User] ([Name], [Birth Date], [Sex], [Position], [Username], [Password], [Privilages], [Company ID], [Manager ID]) VALUES ('User 2', '2000/6/26', 'M', 'Marketing', 'user2', 'hoho', '3', 2, '2')
INSERT INTO [T1-User] ([Name], [Birth Date], [Sex], [Position], [Username], [Password], [Privilages], [Company ID], [Manager ID]) VALUES ('User 3', '2000/6/26', 'M', 'Marketing', 'user3', 'hoho', '3', 3, '3')
INSERT INTO [T1-User] ([Name], [Birth Date], [Sex], [Position], [Username], [Password], [Privilages], [Company ID], [Manager ID]) VALUES ('Kass', '2000/6/26', 'M', 'ADMIN', 'ckasou01', 'hoho', '2', '99', NULL)
--OBSERVER ADMIN
INSERT INTO [T1-User] ([Name], [Birth Date], [Sex], [Position], [Username], [Password], [Privilages], [Company ID], [Manager ID]) VALUES ('Larkos', '2000/6/26', 'M', 'OBSERVER', 'klarko01', 'hihi', '1', NULL, NULL)
INSERT INTO [T1-User] ([Name], [Birth Date], [Sex], [Position], [Username], [Password], [Privilages], [Company ID], [Manager ID]) VALUES ('Loukis', '2000/6/26', 'M', 'OBSERVER', 'lpapal03', 'hihi', '1', NULL, NULL)
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

--FREE TEXT QUESTIONS
INSERT INTO [T1-Free Text Question] ([Question ID], [Restriction]) VALUES ('1', '<1')
INSERT INTO [T1-Free Text Question] ([Question ID], [Restriction]) VALUES ('2', '<2')
INSERT INTO [T1-Free Text Question] ([Question ID], [Restriction]) VALUES ('3', '<3')
INSERT INTO [T1-Free Text Question] ([Question ID], [Restriction]) VALUES ('4', '<4')
INSERT INTO [T1-Free Text Question] ([Question ID], [Restriction]) VALUES ('5', '<5')
INSERT INTO [T1-Free Text Question] ([Question ID], [Restriction]) VALUES ('6', '<6')
INSERT INTO [T1-Free Text Question] ([Question ID], [Restriction]) VALUES ('7', '<7')
INSERT INTO [T1-Free Text Question] ([Question ID], [Restriction]) VALUES ('8', '<8')
INSERT INTO [T1-Free Text Question] ([Question ID], [Restriction]) VALUES ('9', '<9')
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