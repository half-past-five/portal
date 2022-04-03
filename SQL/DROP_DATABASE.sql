-- DROP ENTIRE DATABASE -- 
declare @name varchar(100)
declare @table varchar(100)
-- Drop all foreign key constraints: this goes through alter table
declare c cursor for
	select a.name as [constraint], b.name as [table] from dbo.sysobjects a
		inner join dbo.sysobjects b on a.parent_obj = b.id
		where a.xtype='F' and b.xtype='U'
open c
fetch next from c into @name, @table
while @@FETCH_STATUS = 0
begin
	exec ('alter table [' + @table + '] drop constraint [' + @name + ']')
	fetch next from c into @name, @table
end
close c
deallocate c
go
if exists (select * from dbo.sysobjects where name='TestFramework_DropAll' and xtype='P')
	drop procedure TestFramework_DropAll
go
create procedure TestFramework_DropAll (@xtype varchar(2), @drop varchar(20))
as
begin
	declare @name varchar(100)
	declare c cursor for select name from sysobjects where xtype=@xtype
	open c
	fetch next from c into @name
	while @@FETCH_STATUS = 0
	begin
		if @name != 'TestFramework_DropAll'
			exec ('DROP ' + @drop + ' [' + @name + ']')
		fetch next from c into @name
	end
	close c
	deallocate c
end
go
-- Drop stuff in this order to avoid dependency errors
exec TestFramework_DropAll 'V', 'view'
go
exec TestFramework_DropAll 'FN', 'function'
go
exec TestFramework_DropAll 'IF', 'function'
go
exec TestFramework_DropAll 'TF', 'function'
go
exec TestFramework_DropAll 'U', 'table'
go
exec TestFramework_DropAll 'P', 'procedure'
go
-- User defined types are a special case as they are not listed in sysobjects
declare c cursor for
	select name from sys.types where is_user_defined=1
declare @name varchar(100)
open c
fetch next from c into @name
while @@FETCH_STATUS = 0
begin
	exec ('drop type [' + @name + ']')
	fetch next from c into @name
end
close c
deallocate c
go
exec TestFramework_DropAll 'D', 'default'
go
drop procedure TestFramework_DropAll
go
-- END OF DROP --