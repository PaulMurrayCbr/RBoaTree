create or replace function get_tree_placements(start_node_id integer)
returns table(tree_id integer) as
$$
begin
	-- not sure how to do this as a prepared cursor with a parameter
	-- and I don't really care at this stage
	return query execute '
		with recursive tw as (
		    select id as super_node_id from tree_node where id = ' || start_node_id || '
		union all
		    select tree_link.super_node_id from tree_link, tree_node, tw
		    where tree_link.sub_node_id = tw.super_node_id
		        and tree_link.super_node_id = tree_node.id
		        and (tree_node.next_node_id is null or tree_link.link_type <> ''V'')
		)    
		select tree.id as tree_id from tw, tree
		where tree.tree_node_id = tw.super_node_id
			and tree.tree_type = ''T''
	';
end;
$$ language plpgsql;
