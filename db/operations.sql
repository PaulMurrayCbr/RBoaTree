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
	
	raise notice 'create_tree(''%'', ''%'')', _name, _uri;
	
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
  	values(_ts, _ts, _name || ' [TOP]', _tree_id, _uri)
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
	
    raise notice 'create_workspace(''%'')', _name;
	
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

create or replace function boatree_create_draft_node(_supernode_id integer, _node_name varchar, _link_type char(1)) returns integer as $$
declare 
	_zz integer;
	_tree_id integer;
	_node_id integer;
	_link_id integer;
	_uri varchar;
	_ts timestamp without time zone;
begin
	_ts := localtimestamp;
	
    raise notice 'boatree_create_draft_node(%, ''%'', ''%'')', _supernode_id, _node_name, _link_type;

    _zz := null;
	select count(*) ct from tree_node where id = _supernode_id into _zz;
	if _zz <> 1 
	then
		raise exception 'node % not found', _supernode_id;
		return null;
	end if;

	_uri := null;
	select uri from tree_node where id = _supernode_id into _uri;
	if _uri is not null 
	then
		raise exception 'node % is not a draft node', _supernode_id;
		return null;
	end if;
	
	if _link_type not in ('F','T','V') 
	then
		raise exception 'link type is ''%'', should be one of ''F'', ''T'', or ''V''', _link_type;
		return null;
	end if;
	
	-----------------------------------------------------
	-- END OF CHECKS, BEGINNING OF OPERATIONS  
	
	select tree_id from tree_node where id = _supernode_id into _tree_id;

	insert into tree_node (
  		created_at,
  		updated_at,
  		name,
  		tree_id
  	)
  	values(_ts, _ts, _node_name, _tree_id)
  	returning id into _node_id;
	
  	insert into tree_link(
  		created_at,
  		updated_at,
  		super_node_id,
  		sub_node_id,
  		link_type
  	)
  	values (
  		_ts, _ts, _supernode_id, _node_id, _link_type
  	)
  	returning id into _link_id;

  	return _link_id;
end 
$$
language plpgsql;


create or replace function boatree_adopt_node(_supernode_id integer, _subnode_id integer, _link_type char(1)) returns integer as $$
declare 
	_zz integer;
	_tree_id integer;
	_node_id integer;
	_link_id integer;
	_uri varchar;
	_ts timestamp without time zone;
begin
	_ts := localtimestamp;
	
    raise notice 'boatree_adopt_node(%, ''%'', ''%'')', _supernode_id, _subnode_id, _link_type;

    _zz :=  null;
	select count(*) ct from tree_node where id = _supernode_id into _zz;
	if _zz <> 1 
	then
		raise exception 'node % not found', _supernode_id;
		return null;
	end if;

	_uri := null;
	select uri from tree_node where id = _supernode_id into _uri;
	if _uri is not null 
	then
		raise exception 'node % is not a draft node', _supernode_id;
		return null;
	end if;
	
    _zz :=  null;
	select count(*) ct from tree_node where id = _subnode_id into _zz;
	if _zz <> 1 
	then
		raise exception 'node % not found', _subnode_id;
		return null;
	end if;

	_uri := null;
	select uri from tree_node where id = _subnode_id into _uri;
	if _uri is null 
	then
		raise exception 'node % is  a draft node', _subnode_id;
		return null;
	end if;
	
	if _link_type not in ('F','T','V') 
	then
		raise exception 'link type is ''%'', should be one of ''F'', ''T'', or ''V''', _link_type;
		return null;
	end if;
	
	-----------------------------------------------------
	-- END OF CHECKS, BEGINNING OF OPERATIONS  
	
  	insert into tree_link(
  		created_at,
  		updated_at,
  		super_node_id,
  		sub_node_id,
  		link_type
  	)
  	values (
  		_ts, _ts, _supernode_id, _subnode_id, _link_type
  	)
  	returning id into _link_id;

  	return _link_id;
end 
$$
language plpgsql;
