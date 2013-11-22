
create or replace function boatree_reset() returns void as $$
begin
	raise notice 'Erasing all trees, resetting to a blank data set';	
    delete from tree_link;
    update tree set root_node_id = null;
    delete from tree_node;
    delete from tree;
    insert into tree(id, tree_type, name) values (0, 'E', '[END]');
    insert into tree_node(id, name, tree_id, uri) values (0, '[END]', 0, 'http://biodiversitry.org.au/boatree/structure#END');
    update tree set root_node_id = 0 where id = 0;
end 
$$ 
language plpgsql;

