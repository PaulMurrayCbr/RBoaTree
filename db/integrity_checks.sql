create or replace function boatree_validate_no_op() returns void as $$
begin
	raise notice 'Integrity check';	
end 
$$ 
language plpgsql;

create or replace function boatree_validate_error() returns void as $$
begin
	raise exception 'This check always returns an exception';	
end 
$$ 
language plpgsql;

create or replace function boatree_validate_end_node() returns void as $$
begin
	raise exception 'TODO!';	
end 
$$ 
language plpgsql;
