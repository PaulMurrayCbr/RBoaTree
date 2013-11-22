
create or replace function testintfunc() returns integer as $$
begin
	raise notice 'this is a function';	
	return 4;
end 
$$ 
language plpgsql;

create or replace function testintfuncarg(a integer) returns integer as $$
begin
	raise notice 'this is a function';	
	return a + 4;
end 
$$ 
language plpgsql;

create or replace function testproc() returns void  as $$
begin
	raise notice 'this is a procedure';	
end 
$$ 
language plpgsql;

create or replace function testexcep() returns void  as $$
begin
	raise exception 'this is a stored procedure exception';	
end 
$$ 
language plpgsql;

