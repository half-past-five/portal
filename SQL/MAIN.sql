-- DROP DATABASE --
:r D:\MY_FILES\JA_Beyond\Healthcare_Provider_Portal\SQL\DROP_DATABASE.sql

:r D:\MY_FILES\JA_Beyond\Healthcare_Provider_Portal\SQL\CREATE_TABLES.sql

:r D:\MY_FILES\JA_Beyond\Healthcare_Provider_Portal\SQL\CREATE_STORED_PROCEDURES.sql

EXEC ShowPatients @doctor_UID = 1

EXEC Authenticate @username = 'admin', @password = 'admin'