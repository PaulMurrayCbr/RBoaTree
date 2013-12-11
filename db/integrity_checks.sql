create or replace function boatree_validate_create_results_table() returns void as $$
begin
	create temporary table validation_results (
	  -- ActiveRecord columns
	  id serial NOT NULL PRIMARY KEY,
	  created_at timestamp without time zone,
	  updated_at timestamp without time zone,
	  -- data rows
	  start_sublist boolean not null default false,
	  end_sublist boolean not null default false,
	  status char(1),
	  msg varchar
	)
	on commit preserve rows;
end 
$$ 
language plpgsql;

create or replace function boatree_validate_msg(_msg varchar, _status char(1) = null) returns void as $$
begin
	insert into validation_results(created_at, updated_at, status, msg)
	values ( localtimestamp, localtimestamp, _status, _msg);
end 
$$ 
language plpgsql;

create or replace function boatree_validate_msgblock(_msg varchar, _status char(1) = null) returns void as $$
begin
	insert into validation_results(created_at, updated_at, start_sublist, status, msg)
	values ( localtimestamp, localtimestamp, true, _status, _msg);
end 
$$ 
language plpgsql;

create or replace function boatree_validate_msgendblock() returns void as $$
begin
	insert into validation_results(created_at, updated_at, end_sublist)
	values ( localtimestamp, localtimestamp, true);
end 
$$ 
language plpgsql;


create or replace function boatree_validate_no_op() returns void as $$
begin
	raise notice 'Integrity check';	
end 
$$ 
language plpgsql;

create or replace function boatree_validate_error() returns void as $$
begin
	raise exception 'This check always returns an exception, to test the validation framework itself';	
end 
$$ 
language plpgsql;

create or replace function boatree_validate_sample_message() returns void as $$
begin
		perform boatree_validate_msg('test message 1', null);
		perform boatree_validate_msgblock('test start block', null);
		perform boatree_validate_msg('test message 2', null);
		perform boatree_validate_msgendblock();
		perform boatree_validate_msgblock('test colors', null);
		perform boatree_validate_msg('Ok', 'k');
		perform boatree_validate_msg('Info', 'i');
		perform boatree_validate_msg('Warn', 'w');
		perform boatree_validate_msg('Err', 'e');
		perform boatree_validate_msgendblock();
end 
$$ 
language plpgsql;



create or replace function boatree_validate_end_node() returns void as $$
begin
	raise exception 'TODO!';	
end 
$$ 
language plpgsql;
