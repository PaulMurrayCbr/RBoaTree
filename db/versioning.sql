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
declare
	_zz integer;
	_ts timestamp without time zone;
begin
	_ts := localtimestamp;

	_zz := null;
	select count(*)
	from versioning_nodes vn, tree_node n
	where vn.curr_node_id = n.id
		and (
			n.uri is null
			or n.next_node_id is not null
		)
	into _zz;
	if _zz <> 0 then
		raise exception 'Only current nodes may be versioned';
	end if;
	
	_zz := null;
	select count(*)
	from versioning_nodes vn, tree_node n
	where vn.new_node_id = n.id
		and (
			n.uri is null
			or n.next_node_id is not null
		)
	into _zz;
	if _zz <> 0 then
		raise exception 'Only current nodes may be replacement nodes';
	end if;
	
	_zz := null;
	select count(*)
	from versioning_nodes vn, tree t
	where vn.curr_node_id = t.tree_node_id
	into _zz;
	if _zz <> 0 then
		raise exception 'Tree top nodes may not be versioned';
	end if;
	
	_zz := null;
	select count(*)
	from versioning_nodes vn, tree t
	where vn.new_node_id = t.tree_node_id
	into _zz;
	if _zz <> 0 then
		raise exception 'Tree top nodes may not be replacement nodes';
	end if;
	
	-- ok. Now we work out the set of all nodes that need versioning, then 
	-- the set of nodes that will need an auto-gnerated replacement
	
	create temporary table all_versioning_nodes (
		curr_node_id integer primary key,
		new_node_id integer
	)
	on commit drop;
	
	insert into all_versioning_nodes(curr_node_id)
	select id from (
		with recursive n as (
			select vn.curr_node_id as id from versioning_nodes vn
			union all
			select tree_link.super_node_id as id
			from n, tree_node, tree_link
			where n.id = tree_link.sub_node_id
			and tree_link.super_node_id = tree_node.id
			and tree_link.link_type = 'V'
			and tree_node.uri is not null
			and tree_node.next_node_id is null
		)
		select distinct n.id from n
	) nn;
	
	-- another integrity check: you may not use a node which is being versioned as a replacement node
	
	_zz := null;
	select count(*)
	from versioning_nodes vn, all_versioning_nodes avn
	where vn.new_node_id = avn.curr_node_id
	into _zz;
	if _zz <> 0 then
		raise exception 'A node being versioned cannot be used as a replacement node';
	end if;
	
	-- I THINK I MIGHT BE MISSING SOMETHING: what if a replacement node is a supernode, but is attached by a tracking link?
	-- will that cause a loop?
	-- this is a TODO - this comment needs to be resolved one way or the other
	-- for now I'll continue on.
	
	-- update - yes, this is a problem. Do we prohibit any supernode? What about if it uses a fixed link?
	
	-- oh well. To contuinbue:

	
	----------------------------
	-- START OF OPERATIONS
	
	create temporary table new_versioning_nodes (
		curr_node_id integer primary key,
		new_node_id integer
	)
	on commit preserve rows;
	
	insert into new_versioning_nodes
	select avn.curr_node_id, nextval('tree_node_id_seq')
	from all_versioning_nodes avn
	where avn.curr_node_id not in (select vn.curr_node_id from versioning_nodes vn);
	
	insert into tree_node(
	  -- ActiveRecord columns
	  id,
	  created_at,
	  updated_at,
	  -- boatree columns
	  name,
	  tree_id,
	  prev_node_id,
	  uri
	)
	select
		v.new_node_id,
		_ts, _ts,
		n.name, n.tree_id, n.id,
		'http://example.org/boatree/node#' || v.new_node_id
	from
		new_versioning_nodes v, tree_node n
		where v.curr_node_id = n.id;
	
	-- ok. recompute all_versioning_nodes
	
	delete from all_versioning_nodes;
	
	insert into all_versioning_nodes select * from versioning_nodes;
	insert into all_versioning_nodes select * from new_versioning_nodes;
	
	insert into tree_link (
	  created_at,
	  updated_at,
	  -- boatree columns
	  super_node_id, 
	  sub_node_id,
	  link_type
	)
	select
		_ts, _ts,
		nvn.new_node_id, l.sub_node_id, l.link_type 
	from new_versioning_nodes nvn, tree_link l
	where nvn.curr_node_id = l.super_node_id;
	
	-- ok. this next bit turns all the nodes to be versioned into old nodes.
	
	update tree_node
	set next_node_id = (
		select avn.new_node_id from all_versioning_nodes avn where avn.curr_node_id = tree_node.id
	)
	where tree_node.id in (
		select avn.curr_node_id from all_versioning_nodes avn
	);

	-- and now we can fix all the links.
	
	update tree_link l
	set sub_node_id = (
		select avn.new_node_id from all_versioning_nodes avn where avn.curr_node_id = l.sub_node_id
	)
	where 
		l.sub_node_id in (select avn.curr_node_id from all_versioning_nodes avn)
		and (
			l.link_type = 'T'
			or (
				l.link_type = 'V'
				and (select next_node_id from tree_node n where n.id = l.super_node_id) is null
			)
		)
	;

	-- and that, by gum, should be it!
end;
$$ language plpgsql;
