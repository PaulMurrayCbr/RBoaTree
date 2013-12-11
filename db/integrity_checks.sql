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

create or replace function boatree_validate_msg(_msg varchar, _status char(1) = null) returns integer as $$
declare
	_id integer;
begin
	insert into validation_results(created_at, updated_at, status, msg)
	values ( localtimestamp, localtimestamp, _status, _msg)
	returning id into _id;
	return _id;
end 
$$ 
language plpgsql;

create or replace function boatree_validate_msgblock(_msg varchar, _status char(1) = null) returns integer as $$
declare
	_id integer;
begin
	insert into validation_results(created_at, updated_at, start_sublist, status, msg)
	values ( localtimestamp, localtimestamp, true, _status, _msg)
	returning id into _id;
	return _id;
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

create or replace function boatree_validate_msgsetstatus(_id integer, _status char(1)) returns void as $$
begin
	update validation_results set status = _status where id = _id;
end 
$$ 
language plpgsql;

create or replace function boatree_validate_equalsi(_msg varchar,  _expected integer, _value integer) returns integer as $$
begin
	if _value = _expected then
		return boatree_validate_msg(_msg, 'k');
	else
		return boatree_validate_msg(_msg || ': expected ' || _expected || ', got ' || _value, 'w');
	end if;
end 
$$ 
language plpgsql;

create or replace function boatree_validate_nulli(_msg varchar,  _value integer) returns integer as $$
begin
	if _value is null then
		return boatree_validate_msg(_msg, 'k');
	else
		return boatree_validate_msg(_msg || ': expected NULL, got ' || _value, 'w');
	end if;
end 
$$ 
language plpgsql;

create or replace function boatree_validate_all() returns void as $$
begin
	perform boatree_validate_end_node();
end 
$$ 
language plpgsql;


create or replace function boatree_validate_end_node() returns void as $$
declare
	_block integer;
	_zz integer;
begin
	_block := boatree_validate_msgblock('boatree_validate_end_node');
	begin
		_zz := null;
		select count(*) from tree where id = 0 into _zz;
		perform boatree_validate_equalsi('there should be an end tree', 1, _zz);

		_zz := null;
		select count(*) from tree_node where id = 0 into _zz;
		perform boatree_validate_equalsi('there should be an end node', 1, _zz);

		_zz := null;
		select tree_node_id from tree where id = 0 into _zz;
		perform boatree_validate_equalsi('the tree node of the end tree should be end node', 0, _zz);
		
		_zz := null;
		select tree_id from tree_node where id = 0 into _zz;
		perform boatree_validate_equalsi('the tree of the end node should be the end tree', 0, _zz);

		_zz := null;
		select prev_node_id from tree_node where id = 0 into _zz;
		perform boatree_validate_nulli('the end node should have no prev', _zz);

		_zz := null;
		select next_node_id from tree_node where id = 0 into _zz;
		perform boatree_validate_nulli('the end node should have no next', _zz);

		_zz := null;
		select count(*) from tree_link where super_node_id = 0 into _zz;
		perform boatree_validate_equalsi('the end node should have no subnodes', 0, _zz);

		_zz := null;
		select count(*) from tree_link where sub_node_id = 0 into _zz;
		perform boatree_validate_msg(_zz || ' nodes have the end node as a subnode', 'i');

		_zz := null;
		select count(*) from tree_node where prev_node_id = 0 into _zz;
		perform boatree_validate_equalsi('the end node should not be the prev of any node', 0, _zz);
		
		_zz := null;
		select count(*) from tree_node where next_node_id = 0 into _zz;
		perform boatree_validate_msg(_zz || ' nodes have the end node as a next node', 'i');

		perform boatree_validate_msgsetstatus(_block, 'k');	
	exception
		when others then
			perform boatree_validate_msg('ERR ' || sqlstate || ': ' || sqlerrm, 'e');
			perform boatree_validate_msgsetstatus(_block, 'e');	
	end; 
	perform boatree_validate_msgendblock();
end 
$$ 
language plpgsql;
