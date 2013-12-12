create or replace function boatree_versioning_init() returns void as
$$
begin
	discard temp;

	create temporary table versioning_nodes (
		curr_node_id integer primary key,
		new_node_id integer not null
	)
	on commit preserve rows;
	
	raise notice 'table versioning_nodes created';
	
end;
$$ language plpgsql;

create or replace function boatree_versioning_add(_curr_node_id integer, _new_node_id integer) returns void as
$$
begin
	insert into versioning_nodes(curr_node_id, new_node_id) values(_curr_node_id, _new_node_id);
end;
$$ language plpgsql;

create or replace function boatree_versioning_exec() returns void as
$$
begin
	raise exception 'TODO!';
end;
$$ language plpgsql;
