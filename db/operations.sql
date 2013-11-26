/*
 * This file is the core of the system. It contains methods for each atomic operation which may legally be performed on the system.
 * Each operation checks its arguments, throwing an exception if they are unacceptable, and performs a transformastion.
 */

create or replace function boatree_reset() returns void as $$
begin
	raise notice 'boatree_reset()';	
    delete from tree_link;
    update tree set tree_node_id = null;
    delete from tree_node;
    delete from tree;
    insert into tree(id, tree_type, name) values (0, 'E', '[END]');
    insert into tree_node(id, name, tree_id, uri) values (0, '[END]', 0, 'http://biodiversitry.org.au/boatree/structure#END');
    update tree set tree_node_id = 0 where id = 0;
end 
$$ 
language plpgsql;

/**
 * 
 */

create or replace function boatree_create_tree(_name varchar, _uri varchar) returns integer as $$
declare 
	_zz integer;
	_tree_id integer;
	_tree_node_id integer;
	_root_node_id integer;
	_ts timestamp without time zone;
begin
	_ts := localtimestamp;
	
	raise notice 'create_tree(''||_name||'', ''||_uri\\'')';
	
	if _name is null then
		raise exception 'name must not be null';
	end if;
	
	if _uri is null then
		raise exception 'uri must not be null';
	end if;
	
	select id into _zz from tree_node  where tree_node.uri = _uri;
	
	if _zz is not null then
		raise exception 'uri already exists';
	end if;

	-----------------------------------------------------
	-- END OF CHECKS, BEGINNING OF OPERATIONS  
	
	-- note that it is ok to have dupicate names. Unwise, but permissible
	
	insert into tree(
		created_at,
  		updated_at,
  		name,
  		tree_type
  	)
  	values ( _ts, _ts, _name, 'T')
  	returning id into _tree_id;
	
  	insert into tree_node (
  		created_at,
  		updated_at,
  		name,
  		tree_id,
  		uri
  	)
  	values(_ts, _ts, _name, _tree_id, _uri)
  	returning id into _tree_node_id;
  	
  	insert into tree_node (
  		created_at,
  		updated_at,
  		name,
  		tree_id,
  		uri
  	)
  	values(_ts, _ts, _name || ' [ROOT]', _tree_id, 'http://example.org/boatree/node#' || currval('tree_node_id_seq'))
  	returning id into _root_node_id;

  	update tree set tree_node_id = _tree_node_id where id = _tree_id;

  	insert into tree_link(
  		created_at,
  		updated_at,
  		super_node_id,
  		sub_node_id,
  		link_type
  	)
  	values (
  		_ts, _ts, _tree_node_id, _root_node_id, 'T'
  	);
  	
  	return _tree_id;
end 
$$
language plpgsql;

create or replace function boatree_create_workspace(_name varchar) returns integer as $$
declare 
	_zz integer;
	_tree_id integer;
	_tree_node_id integer;
	_ts timestamp without time zone;
begin
	_ts := localtimestamp;
	
	raise notice 'create_workspace(''||_name||'')';
	
	if _name is null then
		raise exception 'name must not be null';
	end if;
	
	-----------------------------------------------------
	-- END OF CHECKS, BEGINNING OF OPERATIONS  
	
	-- note that it is ok to have dupicate names. Unwise, but permissible
	
	insert into tree(
		created_at,
  		updated_at,
  		name,
  		tree_type
  	)
  	values ( _ts, _ts, _name, 'W')
  	returning id into _tree_id;
	
  	insert into tree_node (
  		created_at,
  		updated_at,
  		name,
  		tree_id
  	)
  	values(_ts, _ts, _name, _tree_id)
  	returning id into _tree_node_id;
  	
  	update tree set tree_node_id = _tree_node_id where id = _tree_id;

  	return _tree_id;
end 
$$
language plpgsql;

