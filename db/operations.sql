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

-- permits finer-grained control of the checkout process
create or replace function boatree_checkout_link(_link_id integer)  returns void as $$
declare 
	_zz integer;
	_tree_type char(1);
	_ts timestamp without time zone;
	_new_node_id integer;
	_new_link_id integer;
begin
	_ts := localtimestamp;
	
    raise notice 'boatree_checkout_link(%, %)', _link_id, _ws_id;

    _zz :=  null;
	select count(*) ct from tree_link where id = _link_id into _zz;
	if _zz <> 1 
	then
		raise exception 'link % not found', _link_id;
		return;
	end if;

	_zz :=  null;
	select count(*) ct from tree_link l, tree_node n
	where l.id = _link_id 
		and l.super_node_id = n.id
		and n.uri is null
	into _zz;
	if _zz <> 1 
	then
		raise exception 'supernode of link % is not a draft node', _link_id;
		return;
	end if;

	_zz :=  null;
	select count(*) ct from tree_link l, tree_node n
	where l.id = _link_id 
		and l.sub_node_id = n.id
		and n.uri is not null
	into _zz;
	if _zz <> 1 
	then
		raise exception 'subnode of link % is not a final node', _link_id;
		return;
	end if;

	-----------------------------------------------------
	-- END OF CHECKS, BEGINNING OF OPERATIONS  

  	insert into tree_node (
  		created_at,
  		updated_at,
  		name,
  		tree_id
  	)
  	select
  		_ts, _ts, sub._name || '*', sup.tree_id
  	from tree_node sup, tree_node sub, tree_link l
  	where 
  		l.id = _link_id
  		and l.super_node_id = sup.id
  		and l.sub_node_id = sub.id
  	returning id into _new_node_id;
	
	insert into tree_link (
	  	created_at,updated_at,super_node_id,sub_node_id,link_type
	)
	select _ts, _ts, _new_node_id, l2.sub_node_id, l2.link_type
		from tree_link l, tree_link l2
		where l.id - _link_id
		and l.sub_node_id = l2.super_node_id
	;
	
	update tree_link
	set sub_node_id = _new_node_id
	where id = _link_id;
end 
$$
language plpgsql;

create or replace function boatree_checkout_node(_node_id integer, _ws_id integer) returns integer as $$
declare 
	_zz integer;
	_uri varchar;
	_ts timestamp without time zone;
	_tree_type char(1);
begin
	_ts := localtimestamp;
	
    raise notice 'boatree_checkout_node(%, %)', _node_id, _ws_id;

    _zz :=  null;
	select count(*) ct from tree_node where id = _node_id into _zz;
	if _zz <> 1 
	then
		raise exception 'node % not found', _node_id;
		return null;
	end if;
	
	_uri := null;
	select uri from tree_node where id = _node_id into _uri;
	if _uri is null
	then
		raise exception 'node % is not finalised', _node_id;
		return null;
	end if;

    _zz :=  null;
	select count(*) ct from tree where id = _ws_id into _zz;
	if _zz <> 1 
	then
		raise exception 'tree % not found', _ws_id;
		return null;
	end if;

	select tree_type from tree where id = _ws_id into _tree_type;
	if _tree_type <> 'W'
	then
		raise exception 'tree % is not a workspace', _ws_id;
		return null;
	end if;

	/**
	 * Ok. Now we need to find all final nodes that need checking out. To do this, we find all supernodes of
	 * _node_id and then trim it that list down from the top node of _ws_id. If the node is not in the ws at all, then the resulting
	 * set will be empty.
	 */
	
    create temporary table new_nodes (
		curr_node_id integer primary key,
		new_node_id integer
	)
	on commit drop;

	insert into new_nodes(curr_node_id)
	with recursive supernodes as (
		select l.super_node_id, l.sub_node_id from tree_link l where sub_node_id = _node_id
		union all
		select l.super_node_id, l.sub_node_id from tree_link l, supernodes
			where l.sub_node_id = supernodes.super_node_id
	),
	subnodes as (
		select s.* from supernodes s, tree t where t.id = _ws_id and t.tree_node_id = s.super_node_id
		union all
		select s.* from supernodes s, subnodes b where b.sub_node_id = s.super_node_id
	)
	select distinct b.sub_node_id 
		from subnodes b, tree_node n
		where b.sub_node_id = n.id
		and n.uri is not null
	;
	
    _zz :=  null;
	select count(*) ct from new_nodes into _zz;
	if _zz = 0 
	then
		raise exception 'node % does not appear to be in workspace %', _node_id, _ws_id;
		return null;
	end if;
		
	-----------------------------------------------------
	-- END OF CHECKS, BEGINNING OF OPERATIONS  
	
	
	update new_nodes set new_node_id = nextval('tree_node_id_seq');
	
	insert into tree_node (
	  id,
	  created_at,
	  updated_at,
	  name,
	  tree_id,
	  prev_node_id
	)
	select
		new_node_id,
		_ts, _ts,
		n.name || '*', 
		_ws_id, -- new node is owned by the workspace
		curr_node_id -- prev version
	from new_nodes, tree_node n where curr_node_id = n.id;
	
	insert into tree_link (
	  	created_at,updated_at,super_node_id,sub_node_id,link_type
	)
	select _ts, _ts, new_node_id, l.sub_node_id, l.link_type
		from tree_link l, new_nodes
		where curr_node_id = l.super_node_id
	;
		
	update tree_link l
		set sub_node_id =  (select new_node_id from new_nodes where curr_node_id = sub_node_id)
		where 
			(select tree_id from tree_node n where n.id = l.super_node_id) = _ws_id
			and (select uri from tree_node n where n.id = l.super_node_id) is null
			and sub_node_id in (select curr_node_id from new_nodes);
	
	_zz := null;
    select new_node_id from new_nodes where curr_node_id = _node_id into _zz;
	return _zz;
end 
$$
language plpgsql;
  

create or replace function boatree_delete_node(_node_id integer) returns void as $$
declare 
	_zz integer;
	_uri varchar;
	_ts timestamp without time zone;
	_tree_type char(1);
begin
	_ts := localtimestamp;
	
    raise notice 'boatree_delete_node(%)', _node_id;
    
    _zz :=  null;
	select count(*) ct from tree_node where id = _node_id into _zz;
	if _zz <> 1 
	then
		raise exception 'node % not found', _node_id;
		return;
	end if;
	
	_uri := null;
	select uri from tree_node where id = _node_id into _uri;
	if _uri is not null
	then
		raise exception 'node % is finalised', _node_id;
		return;
	end if;
	
    _zz :=  null;
	select count(*) ct from tree where tree_node_id = _node_id into _zz;
	if _zz <> 0 
	then
		raise exception 'node % is a workspace top node', _node_id;
		return;
	end if;
	
	update tree_node
	set updated_at = _ts
	where id in (
		select super_node_id from tree_link where sub_node_id = _node_id
	);
	
	delete from tree_link where sub_node_id = _node_id;
	
	perform _boatree_delete_draft_node(_node_id, _ts);
end 
$$
language plpgsql;


create or replace function boatree_delete_workspace(_ws_id integer) returns void as $$
declare 
	_zz integer;
begin
    raise notice 'boatree_delete_workspace(%)', _ws_id;

	-- check that ws exists

    _zz :=  null;
	select count(*) ct from tree where id = _ws_id and tree_type = 'W' into _zz;
	if _zz <> 1 
	then
		raise exception 'Workspace % not found', _ws_id;
		return;
	end if;

	perform _boatree_delete_t_or_ws(_ws_id);
end 
$$
language plpgsql;
    
create or replace function boatree_delete_tree(_tree_id integer) returns void as $$
declare 
	_zz integer;
begin
    raise notice 'boatree_delete_tree(%)', _tree_id;

	-- check that ws exists

    _zz :=  null;
	select count(*) ct from tree where id = _tree_id and tree_type = 'T' into _zz;
	if _zz <> 1 
	then
		raise exception 'Tree % not found', _tree_id;
		return;
	end if;

	perform _boatree_delete_t_or_ws(_tree_id);
end 
$$
language plpgsql;
    
create or replace function _boatree_delete_t_or_ws(_id integer) returns void as $$
declare 
	_zz integer;
begin
	-- ok. Deletion of an entire tree has some pretty serious checks. Basically: none of the nodes in the tree may
	-- be linked from another tree.
	
	-- We also check that deleting the tree will not result in orphaned draft nodes, but in a well-formed
	-- dataset this never happens.
	
	-- Tree deletion *may* result in orphaned final nodes, but only where odd things have been going on.

	-- check that no-one else links to this tree
    _zz :=  null;
	select count(*) ct 
	from tree_node supn, tree_node subn, tree_link l
	where subn.tree_id = _id
	and subn.id = l.sub_node_id
	and supn.id = l.super_node_id
	and supn.tree_id <> _id
	into _zz;
	if _zz <> 0 
	then
		raise exception 'Tree/Workspace % has nodes that are linked to from other trees', _id;
		return;
	end if;

	-- THIS NEVER HAPPENS. Check that deleting the nodes in this tree will not result in draft nodes
	-- being left orphan
	
    _zz :=  null;
	select count(*) ct 
	from tree_node supn, tree_node subn, tree_link l
	where supn.tree_id = _id
	and supn.id = l.super_node_id
	and subn.id = l.sub_node_id
	and supn.tree_id <> _id
	and subn.uri is null -- only interested in this for draft nodes, at the moment
	-- is this subnode, in a different tree, not the subnode of *any* other tree node?
	and not exists (
		select othernode.id
		from tree_node othernode, tree_link otherlink
		where otherlink.sub_node_id = subn.id
		and otherlink.super_node_id = othernode.id
		and othernode.tree_id <> _id
	)
	into _zz;
	if _zz <> 0 
	then
		raise exception 'THIS NEVER HAPPENS - deleting tree/workspace % will result in orphaned draft nodes', _id;
		return;
	end if;
	
	-----------------------------------------------------
	-- END OF CHECKS, BEGINNING OF OPERATIONS  

	delete from tree_link
	where super_node_id in (
		select id from tree_node where tree_id = _id
	);
	
	update tree set tree_node_id = null where id = _id;

	delete from tree_node where tree_id = _id;
	
	delete from tree where id = _id;
end 
$$
language plpgsql;
    
create or replace function boatree_finalise_node(_node_id integer) returns integer as $$
declare 
	_zz integer;
	_ts timestamp without time zone;
begin
	_ts := localtimestamp;
	
    raise notice 'boatree_finalise_node(''%'')', _node_id;

    -- node muse exist, be a draft node, and not be a tree root
    
    _zz :=  null;
	select count(*) ct from tree_node where id = _node_id and uri is null into _zz;
	if _zz <> 1 
	then
		raise exception 'Draft node % not found', _node_id;
		return null;
	end if;

	_zz :=  null;
	select count(*) ct from tree where tree_node_id = _node_id into _zz;
	if _zz <> 0 
	then
		raise exception 'Cannot finalise tree root %', _node_id;
		return null;
	end if;
	
	-----------------------------------------------------
	-- END OF CHECKS, BEGINNING OF OPERATIONS  

	update tree_node
	set uri = 'http://example.org/boatree/node#' || id,
		updated_at = _ts
	where id in (
		with recursive n as (
			select id from tree_node where id = _node_id
			union all
			select tree_node.id
			from tree_node, tree_link, n
			where n.id = tree_link.super_node_id
			and tree_link.sub_node_id = tree_node.id
			and tree_node.uri is null
		)
		select id from n
	);
	
	return _node_id;    
end 
$$
language plpgsql;

create or replace function boatree_revert_node(_node_id integer) returns void as $$
declare 
	_zz integer;
	_copy_of integer;
	_copy_of_curr integer;
	_ts timestamp without time zone;
begin
	_ts := localtimestamp;
	
    raise notice 'boatree_revert_node(''%'')', _node_id;

    -- node must exist, be a draft node, not be a tree root, and be a 'copy_of'
    
    _zz :=  null;
	select count(*) ct from tree_node where id = _node_id and uri is null and prev_node_id is not null into _zz;
	if _zz <> 1 
	then
		raise exception 'Draft checked-out node % not found', _node_id;
		return;
	end if;

	-- this never happens
	_zz :=  null;
	select count(*) ct from tree where tree_node_id = _node_id into _zz;
	if _zz <> 0 
	then
		raise exception 'Cannot revert tree root %', _node_id;
		return;
	end if;

	-----------------------------------------------------
	-- END OF CHECKS, BEGINNING OF OPERATIONS  

	
	select prev_node_id from tree_node where id = _node_id into _copy_of;
	
	with recursive curr as (
		select tree_node.id, tree_node.next_node_id from tree_node where id = _copy_of
		union all
		select tree_node.id, tree_node.next_node_id from tree_node, curr where curr.next_node_id is not null and tree_node.id = curr.next_node_id
	)
	select id from curr where next_node_id is null into _copy_of_curr;
	
	update tree_node
	set updated_at = _ts
	where id in (
		select super_node_id from tree_link where sub_node_id = _node_id
	);
	
	update tree_link
	set updated_at = _ts, sub_node_id = _copy_of
	where sub_node_id = _node_id and link_type = 'F';
	
	update tree_link
	set updated_at = _ts, sub_node_id = _copy_of_curr
	where sub_node_id = _node_id and link_type <> 'F';
	
	perform _boatree_delete_draft_node(_node_id, _ts);
end 
$$
language plpgsql;

create or replace function _boatree_delete_draft_node(_node_id integer, _ts timestamp without time zone) returns void as $$
begin
	-----------------------------------------------------
	-- END OF CHECKS, BEGINNING OF OPERATIONS  

    create temporary table nodes (
		id integer primary key
	)
	on commit drop;
	
	insert into nodes
	select id from (
		with recursive n as (
			select id from tree_node where id = _node_id
			union all
			select tree_node.id
			from tree_node, tree_link, n
			where n.id = tree_link.super_node_id
			and tree_link.sub_node_id = tree_node.id
			and tree_node.uri is null
		),
		allinks as (
			select tree_link.* from tree_link, n where tree_link.sub_node_id = n.id
		),
		externallinks as (
			select allinks.* from allinks where allinks.super_node_id not in (select id from n)
		),
		-- we need to find the subtrees that are linked to externally and cannot be deleted
		externallinksubtree as (
			select externallinks.sub_node_id as id from externallinks
			union all
			select tree_link.sub_node_id as id
				from externallinksubtree, tree_link, n
				where externallinksubtree.id = tree_link.super_node_id
				and tree_link.sub_node_id = n.id -- clip the search at ununteresting nodes
		)
		select id from n where n.id not in (select id from externallinksubtree)
	) n;

	delete from tree_link where super_node_id in ( select id from nodes);
	
	-- this would fail if our draft tree contains diamonds, if not for the extra checks in the nodes query
	delete from tree_node where id in ( select id from nodes);
end 
$$
language plpgsql;

