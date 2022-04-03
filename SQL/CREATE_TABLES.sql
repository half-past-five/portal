-- BEGIN CREATION --
CREATE TABLE dbo.Doctors(
	[UID] int identity not null,
	national_id int unique,
	email varchar(50) unique not null,
	username varchar(20) unique not null,
	[password] varchar(20) not null,
	[first_name] varchar(20) not null,
	[last_name] varchar(30),
	[telephone] varchar(20),
	[address] varchar(50),
	[hospital_id] int -- FK
	)

CREATE TABLE dbo.Patients(
	[UID] int identity not null,
	national_id int unique,
	email varchar(50) unique not null,
	[first_name] varchar(20) not null,
	[last_name] varchar(30),
	[telephone] varchar(20),
	[address] varchar(50),
	[doctor_id] int -- FK
	)

CREATE TABLE dbo.Drugs(
	drug_id int identity not null,
	[name] varchar(40) not null,
	[type] varchar(30) not null,
	)

CREATE TABLE dbo.Drug_side_effects(
	[id] int identity not null,
	[name] varchar(30) not null
	)

CREATE TABLE dbo.Drugs_with_side_effects(
	side_effect_id int not null, -- FK
	drug_id int not null -- FK
	)

CREATE TABLE dbo.Patients_log(
	patient_id int not null, -- FK
	[datetime] datetime not null,
	[drug_id] int, -- FK
	[description] varchar(100)
	)

-- END CREATION --


-- DUMMY DATA --
INSERT INTO Patients VALUES (1013129,'lpapal03@ucy.ac.cy', 'Loukas', 'Papalazarou', '+35796888185', 'Andrea Paraskeva', 1)
INSERT INTO Doctors VALUES (1111111, 'admin.hpf@gmail.com', 'admin','admin', 'ADMIN', 'ADMIN', '+35799999999', NULL, NULL)





