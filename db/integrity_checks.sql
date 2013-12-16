create or replace function boatree_check_valid() returns void as $$
declare 
	_zz	integer;
	_msg varchar;
begin	
	perform boatree_validate_create_results_table();
	perform boatree_validate_all();
	select count(*) 
	from validation_results 
	where status in ('e', 'w')
	into _zz;
	if _zz <> 0 then
		raise exception 'Validation failed: % warnings/messages', _zz;
	end if;
end	
$$ 
language plpgsql;


create or replace function boatree_validate_create_results_table() returns void as $$
begin
	discard temp;
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
	perform boatree_validate_no_loops();
	perform boatree_validate_draft_nodes();
	perform boatree_validate_tree_roots();
	perform boatree_validate_links();
	perform boatree_validate_orphans();
end 
$$ 
language plpgsql;


create or replace function boatree_validate_end_node() returns void as $$
declare
	_block integer;
	_zz integer;
begin
	_block := boatree_validate_msgblock('end node', 'k');
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
	exception
		when others then
			perform boatree_validate_msg('ERR ' || sqlstate || ': ' || sqlerrm, 'e');
			perform boatree_validate_msgsetstatus(_block, 'e');	
	end; 
	perform boatree_validate_msgendblock();
end 
$$ 
language plpgsql;

create or replace function boatree_validate_no_loops() returns void as $$
declare
	_block integer;
	_zz integer;
begin
	_block := boatree_validate_msgblock('no loops', 'k');
	begin
		_zz := null;
		with recursive ll as (
			select super_node_id, sub_node_id from tree_link
			union all
			select ll.super_node_id, tree_link.sub_node_id
			from tree_link, ll
			where ll.sub_node_id = tree_link.super_node_id
			and ll.sub_node_id <> ll.super_node_id -- kill infinite loop
		)
		select count(*) from ll where  ll.sub_node_id = ll.super_node_id into _zz;
		perform boatree_validate_equalsi('there should be no loops in the super/subnode structure', 0, _zz);

		_zz := null;
		with recursive ll as (
			select id, next_node_id from tree_node
			union all
			select ll.id, tree_node.next_node_id
			from tree_node, ll
			where ll.next_node_id = tree_node.id
			and ll.id <> ll.next_node_id -- kill infinite loop
		)
		select count(*) from ll where  ll.id = ll.next_node_id into _zz;
		perform boatree_validate_equalsi('there should be no loops in the node.next structure', 0, _zz);

		_zz := null;
		with recursive ll as (
			select id, prev_node_id from tree_node
			union all
			select ll.id, tree_node.prev_node_id
			from tree_node, ll
			where ll.prev_node_id = tree_node.id
			and ll.id <> ll.prev_node_id -- kill infinite loop
		)
		select count(*) from ll where  ll.id = ll.prev_node_id into _zz;
		perform boatree_validate_equalsi('there should be no loops in the node.prev structure', 0, _zz);

		-- This check is wrong. Not in the sense of 'wrongly implemented', but in the sense of
		-- 'what we are trying to implement should not be done'.
		-- We do not fobid these kinds of loops, because they are a legitimate data artiafct.
		-- This is what happens when a rollback of a branch occurs: a node's 'next' node 
		-- becomes the node that it was originally a copy of.
		--
		--	_zz := null;
		--	with recursive ll as (
		--		select id, next_node_id from tree_node
		--		union all
		--		select ll.id, nn.next_node_id
		--		from (
		--			select id, next_node_id from tree_node
		--			union all
		--			select prev_node_id as id, id as next_node_id from tree_node
		--		) nn, ll
		--		where ll.next_node_id = nn.id
		--		and ll.id <> ll.next_node_id -- kill infinite loop
		--	)
		--	select count(*) from ll where  ll.id = ll.next_node_id into _zz;
		--	perform boatree_validate_equalsi('there should be no loops in the union of the node.next and inverse node.prev structure', 0, _zz);
		
	exception
		when others then
			perform boatree_validate_msg('ERR ' || sqlstate || ': ' || sqlerrm, 'e');
			perform boatree_validate_msgsetstatus(_block, 'e');	
	end; 
	perform boatree_validate_msgendblock();
end 
$$ 
language plpgsql;

create or replace function boatree_validate_draft_nodes() returns void as $$
declare
	_block integer;
	_zz integer;
begin
	_block := boatree_validate_msgblock('draft nodes', 'k');
	begin
		_zz := null;
		select count(*) 
		from
			tree_node p, tree_link l, tree_node c
		where p.id = l.super_node_id and l.sub_node_id = c.id
			and p.tree_id <> c.tree_id
			and c.uri is null
		into _zz;
		perform boatree_validate_equalsi('draft nodes may only be child nodes of nodes in the same tree', 0, _zz);

		_zz := null;
		select count(*) 
		from
			tree_node d
		where
			d.uri is null
			and not exists (select 1 from tree_link where sub_node_id = d.id)
			and not exists (select 1 from tree where tree_node_id = d.id)
		into _zz;
		perform boatree_validate_equalsi('draft nodes must be attached to a supernode, unless they are a tree root', 0, _zz);

		_zz := null;
		select count(*) 
		from
			tree_node p, tree_link l, tree_node c
		where p.id = l.super_node_id and l.sub_node_id = c.id
			and p.uri is not null
			and c.uri is null
		into _zz;
		perform boatree_validate_equalsi('a finalised supernode may never have a draft subnode', 0, _zz);
	exception
		when others then
			perform boatree_validate_msg('ERR ' || sqlstate || ': ' || sqlerrm, 'e');
			perform boatree_validate_msgsetstatus(_block, 'e');	
	end; 
	perform boatree_validate_msgendblock();
end 
$$ 
language plpgsql;


create or replace function boatree_validate_tree_roots() returns void as $$
declare
	_block integer;
	_zz integer;
begin
	_block := boatree_validate_msgblock('tree roots', 'k');
	begin

		_zz := null;
		select count(*) 
		from
			tree
		where tree_node_id is null
		into _zz;
		perform boatree_validate_equalsi('all trees should have a top node', 0, _zz);

		_zz := null;
		select count(*) 
		from
			tree, tree_node
		where tree.tree_node_id = tree_node.id
			and tree.tree_type = 'W'
			and tree_node.uri is not null
		into _zz;
		perform boatree_validate_equalsi('all workspaces should have a draft top node', 0, _zz);

		_zz := null;
		select count(*) 
		from
			tree, tree_node
		where tree.tree_node_id = tree_node.id
			and tree.tree_type = 'T'
			and tree_node.uri is null
		into _zz;
		perform boatree_validate_equalsi('all trees should have a final top node', 0, _zz);

		_zz := null;
		select count(*) from (
			select tree.id, count(*) n 
			from
				tree, tree_link
			where 
				tree.tree_type = 'T'
				and tree.tree_node_id = tree_link.super_node_id
				and tree_link.link_type = 'T'
			group by tree.id
		) ct
		where n <> 1
		into _zz;
		perform boatree_validate_equalsi('all tree top nodes should have one tracking link', 0, _zz);

		_zz := null;
		select count(*) from (
			select tree.id, count(*) n 
			from
				tree, tree_link
			where 				
				tree.tree_type = 'T'
				and tree.tree_node_id = tree_link.super_node_id
				and tree_link.link_type <> 'T'
			group by tree.id
		) ct
		where n <> 0
		into _zz;
		perform boatree_validate_equalsi('all tree top nodes should have no other links', 0, _zz);

		
		_zz := null;
		select count(*) 
		from
			tree, tree_node
		where tree.tree_node_id = tree_node.id
			and (tree_node.next_node_id is not null or tree_node.prev_node_id is not null)
		into _zz;
		perform boatree_validate_equalsi('tree top nodes are never versioned', 0, _zz);
	exception
		when others then
			perform boatree_validate_msg('ERR ' || sqlstate || ': ' || sqlerrm, 'e');
			perform boatree_validate_msgsetstatus(_block, 'e');	
	end; 
	perform boatree_validate_msgendblock();
end 
$$ 
language plpgsql;


create or replace function boatree_validate_links() returns void as $$
declare
	_block integer;
	_zz integer;
begin
	_block := boatree_validate_msgblock('links', 'k');
	begin
		_zz := null;
		select count(*) 
		from
			tree_link, tree_node
		where 
			tree_link.sub_node_id = tree_node.id
			and tree_link.link_type = 'T'
			and tree_node.next_node_id is not null
		into _zz;
		perform boatree_validate_equalsi('tracking links always point to current nodes', 0, _zz);

		_zz := null;
		select count(*) 
		from
			tree_node p, tree_link l, tree_node c
		where 
			l.super_node_id = p.id
			and l.sub_node_id = c.id
			and l.link_type = 'V'
			and p.next_node_id is null
			and c.next_node_id is not null
		into _zz;
		perform boatree_validate_equalsi('versioning links from current nodes always point to current nodes', 0, _zz);

	exception
		when others then
			perform boatree_validate_msg('ERR ' || sqlstate || ': ' || sqlerrm, 'e');
			perform boatree_validate_msgsetstatus(_block, 'e');	
	end; 
	perform boatree_validate_msgendblock();
end 
$$ 
language plpgsql;


create or replace function boatree_validate_orphans() returns void as $$
declare
	_outerblock integer;
	_block integer;
	_tree_block integer;
	_zz integer;
	_tree_id integer;
	_tree_name varchar;
begin
	_outerblock := boatree_validate_msgblock('orphans');
	_block := boatree_validate_msgblock('absolute orphans', 'k');
	begin
		for _tree_id, _tree_name in select id, name from tree LOOP
			_zz := null;
			select count(*) from tree, tree_node
			where tree.id = tree_id
				and tree_node.tree_id = tree.id
				and tree_node.next_node_id is null
				and tree_node.id <> tree.tree_node_id
				and not exists (
					select 1 from tree_link where tree_link.sub_node_id = tree_node.id
				)
			into _zz;
			perform boatree_validate_equalsi('tree ''' || _tree_name || ' [' || _tree_id || ']'' has no orphans', 0, _zz);
			if _zz <> 0 then
				perform boatree_validate_msgsetstatus(_block, 'w');
			end if;

		end loop;
		
	exception
		when others then
			perform boatree_validate_msg('ERR ' || sqlstate || ': ' || sqlerrm, 'e');
			perform boatree_validate_msgsetstatus(_block, 'e');	
	end; 
	perform boatree_validate_msgendblock();

	_block := boatree_validate_msgblock('local orphans', 'k');
	begin
		for _tree_id, _tree_name in select id, name from tree LOOP
			_zz := null;
			select count(*) from tree, tree_node
			where tree.id = tree_id
				and tree_node.tree_id = tree.id
				and tree_node.next_node_id is null
				and tree_node.id <> tree.tree_node_id
				and not exists (
					select 1 from tree_link, tree_node nn where tree_link.sub_node_id = tree_node.id
					and tree_link.super_node_id = nn.id
					and nn.tree_id = tree.id
				)
			into _zz;
			perform boatree_validate_equalsi('tree ''' || _tree_name || ' [' || _tree_id || ']'' has no local orphans', 0, _zz);
			if _zz <> 0 then
				perform boatree_validate_msgsetstatus(_block, 'w');
			end if;

		end loop;
		
	exception
		when others then
			perform boatree_validate_msg('ERR ' || sqlstate || ': ' || sqlerrm, 'e');
			perform boatree_validate_msgsetstatus(_block, 'e');	
	end; 
	perform boatree_validate_msgendblock();
	perform boatree_validate_msgendblock();
end 
$$ 
language plpgsql;

