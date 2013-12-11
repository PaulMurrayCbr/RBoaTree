=begin
This class holds the SQL that performs transformations on the boatree data structure.
The idea is that *All* transformations on the data are *only* done here. Ruby activerecord is not used anywhere
to write to the database.
 
=end

module BoatreeOperations
  include BoatreeSql
  include FlashHelper
  
  def boatree_test
    flash_sql << 'Some tests'
    db_call_discard_exception :testproc 
    db_call_discard_exception :testintfunc 
    db_call_discard_exception :testintfuncarg, 6 
    flash_sql << 'these next TWO should'
    db_call_discard_exception :testexcep
    db_call_discard_exception :testexcep
  end

  def boatree_clear
    db_perform do
      db_call :boatree_reset
      ok "All data cleared, database reset"
      return nil
    end
  end

  def boatree_create_tree(tree_name, tree_uri)
    db_perform do
      tree_id = db_call :boatree_create_tree, tree_name, tree_uri
      ok "Tree #{tree_name} created with uri #{tree_uri}"
      return tree_id
    end
  end
    
  def boatree_create_workspace(workspace_name)
    db_perform do
      tree_id = db_call :boatree_create_workspace, workspace_name
      ok "Workspace #{workspace_name} created"
      return tree_id
    end
  end
    
  def boatree_create_draft_node(supernode_id, node_name, link_type)
    db_perform do
      link_id = db_call :boatree_create_draft_node, supernode_id, node_name, link_type
      ok "Node link #{link_id} created under node #{supernode_id}"
      return link_id
    end
  end

  def boatree_adopt_node(supernode_id, subnode_id, link_type)
    db_perform do
      link_id = db_call :boatree_adopt_node, supernode_id, subnode_id, link_type
      ok "Node link #{link_id} created under node #{supernode_id}"
      return link_id
    end
  end
  
  def boatree_checkout_node(node_id, workspace_id)
    db_perform do
      new_node_id = db_call :boatree_checkout_node, node_id, workspace_id
      ok "Node #{node_id} checked out in workspace #{workspace_id} as #{new_node_id}"
      return new_node_id
    end
  end

  def boatree_delete_node(node_id)
    db_perform do
      db_call :boatree_delete_node, node_id
      ok "Node #{node_id} deleted"
      return nil
    end
  end

  def boatree_delete_workspace(ws_id)
    db_perform do
      db_call :boatree_delete_workspace, ws_id
      ok "Workspace #{ws_id} deleted"
      return nil
    end
  end

  def boatree_delete_tree(tree_id)
    db_perform do
      db_call :boatree_delete_tree, tree_id
      ok "Tree #{tree_id} deleted"
      return nil
    end
  end

  def boatree_finalise_node(node_id)
    db_perform do
      db_call :boatree_finalise_node, node_id
      ok "Node #{node_id} finalised"
      return nil
    end
  end
end
